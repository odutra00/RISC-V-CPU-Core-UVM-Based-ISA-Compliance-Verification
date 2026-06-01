    // cpu_writer.commit_val
    //!adaptação para o ambiente UVM. Mantem cpu.v como original.  Expõe
    //!e cria sinais adicionais necessários à interface do uvm em questao.
    //!O wrapper implementa "register-write commit",
    //!não "architectural-state commit"
    //!Commit arquitetural completo (mais rigoroso) usaria
    //!assign commit_valid =
    //!   regFileWE_WB |
    //!   memWrite_MEM |
    //!   branchTaken_EX |
    //!   jalFlag_ID |
    //!   jalrFlag_EX;
    //! que verificaria qualquer mudança de estado arquitetural, incluindo:
    //!    escrita em registrador
    //!    escrita em memória
    //!    mudança de PC por branch/jump
module cpu_wrapper #(
    parameter MEMORY_SIZE_PROG = 1024,
    parameter MEMORY_SIZE_RAM  = 1024,
    parameter ADDR_WIDTH       = 32,
    parameter DATA_WIDTH       = 32,
    parameter INST_WIDTH       = 32,
    parameter INIT_FILE_PROG   = "assembly/main_text.hex",
    parameter INIT_FILE_RAM    = "assembly/main_data.hex",
    parameter REG_FILE_WIDTH   = 5,
    parameter BYTE_WORD_PROG   = 0,
    parameter BYTE_WORD_DADOS  = 1
)(
    input  logic clk,
    input  logic rst_n,      //! reset ativo em 0 (padrão do ambiente UVM)
    commit_if.drv cmt        //! interface de commit do ambiente UVM
);

    //! pipeline auxiliar para alinhar a instrução até WB
    logic [INST_WIDTH-1:0] inst_ID_commit;
    logic [INST_WIDTH-1:0] inst_EX_commit;
    logic [INST_WIDTH-1:0] inst_MEM_commit;
    logic [INST_WIDTH-1:0] inst_WB_commit;

    //------------------------------------------------------------------
    // DUT
    //------------------------------------------------------------------
    cpu #(
        .MEMORY_SIZE_PROG(MEMORY_SIZE_PROG),
        .MEMORY_SIZE_RAM(MEMORY_SIZE_RAM),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INST_WIDTH(INST_WIDTH),
        .INIT_FILE_PROG(INIT_FILE_PROG),
        .INIT_FILE_RAM(INIT_FILE_RAM),
        .REG_FILE_WIDTH(REG_FILE_WIDTH),
        .BYTE_WORD_PROG(BYTE_WORD_PROG),
        .BYTE_WORD_DADOS(BYTE_WORD_DADOS)
    ) DUT (
        .clk(clk),
        .rst(~rst_n)   //! cpu.v usa reset ativo alto
    );

    //------------------------------------------------------------------
    // adaptação para commit_if
    //------------------------------------------------------------------
    //! register-write commit only
    assign cmt.valid   = DUT.regFileWE_WB && (DUT.rd_WB != 5'd0);
    //! interface pede 64 bits
    assign cmt.pc      = {{32{1'b0}}, (DUT.pc_WB_Arch - 32'd4)};
    assign cmt.instr   = inst_MEM_commit;//pega do mem pq foram removidos registros EX/MEM para compensar escritas sincronas em regfile e dataMemory;
    assign cmt.rd_addr = DUT.rd_WB;
    assign cmt.rd_data = {{32{1'b0}}, DUT.writeBack_WB};

    //! não usados nesta microarquitetura didática
    assign cmt.mem_we    = 1'b0;
    assign cmt.mem_addr  = 64'd0;
    assign cmt.mem_wdata = 64'd0;
    assign cmt.trap      = 1'b0;
    assign cmt.priv      = 2'd3;   //! Machine mode

    //------------------------------------------------------------------
    // pipeline auxiliar do commit
    //------------------------------------------------------------------
    //!Os dados necessários ao commit com o testbench uvm estarão em WB
    //!que é quando ocorre mudança de estado arquitetural (escrita no registerFile).
    //!O que não estiver disponível em WB na cpu.v, pipelinaremos aqui no wrapper
    //!/////////////////// ATENÇÃO //////////////////////////////////////
    //! Pipeline de commit assume ausência de stalls/forwarding no pipeline de cpu.v
    //! Bolhas devem ser inseridas manualmente com NOPs no assembly.
    //! EM caso de pipeline com STALL/Bolhas inseridas automaticamente em caso Load/USE
    //! esse artifício quebra o pipeline abaixo e o teste não comparará de acordo.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            inst_ID_commit  <= '0;
            inst_EX_commit  <= '0;
            inst_MEM_commit <= '0;
            inst_WB_commit  <= '0;
        end
        else begin
            inst_ID_commit  <= DUT.inst_IF;
            inst_EX_commit  <= inst_ID_commit;
            inst_MEM_commit <= inst_EX_commit;
            inst_WB_commit  <= inst_MEM_commit;
        end
    end

endmodule
