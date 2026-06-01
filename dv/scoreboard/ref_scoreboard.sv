`include "uvm_macros.svh"
`include "riscv_defs.svh"
import uvm_pkg::*;

class ref_scoreboard extends uvm_component;
  `uvm_component_utils(ref_scoreboard)

  `uvm_analysis_imp_decl(_dut)
  `uvm_analysis_imp_decl(_ref)

  uvm_analysis_imp_dut #(commit_s, ref_scoreboard) imp_dut;
  uvm_analysis_imp_ref #(commit_s, ref_scoreboard) imp_ref;

  commit_s dut_q[$];
  commit_s ref_q[$];

  int unsigned match_cnt, mismatch_cnt;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp_dut = new("imp_dut", this);
    imp_ref = new("imp_ref", this);
  endfunction


  //------------------------------------------
  // recebe do DUT
  //------------------------------------------
  function void write_dut(commit_s tr);
    dut_q.push_back(tr);
    //-> compare_event;
    //compare_queues();
  endfunction


  //------------------------------------------
  // recebe do REF (Spike)
  //------------------------------------------
  function void write_ref(commit_s tr);
    ref_q.push_back(tr);
    //-> compare_event;
    //compare_queues();
  endfunction




    task run_phase(uvm_phase phase);
      forever begin
        wait (dut_q.size() > 0 && ref_q.size() > 0);
        compare_queues();
      end
    endtask

  //------------------------------------------
  // compara
  //------------------------------------------
  task compare_queues();
    while (dut_q.size() > 0 && ref_q.size() > 0) begin
      commit_s a = dut_q.pop_front();
      commit_s b = ref_q.pop_front();

      if (a.valid != b.valid) begin
        `uvm_error("CMP",
          $sformatf("valid mismatch: dut=%0b ref=%0b",
          a.valid,b.valid))
        mismatch_cnt++;
      end
      else if (a.valid) begin
        bit ok = 1;

        ok &= (a.pc      == b.pc);
        ok &= (a.instr   == b.instr);
        ok &= (a.rd_addr == b.rd_addr);
        ok &= (a.rd_data == b.rd_data);
        ok &= (a.trap    == b.trap);

        if (!ok) begin
          `uvm_error("CMP",
            $sformatf(
            "Mismatch: PC %h/%h instr %h/%h rd x%0d val %0d/%0d",
            a.pc,b.pc,
            a.instr,b.instr,
            a.rd_addr,
            a.rd_data,b.rd_data))
          mismatch_cnt++;
        end
        else begin
          match_cnt++;
          `uvm_info("CMP",
            $sformatf("Match PC=%h rd=x%0d val=%0d",
            a.pc,a.rd_addr,a.rd_data),
            UVM_LOW)
        end
      end
    end
  endtask


  function void report_phase(uvm_phase phase);

  `uvm_info("SUM",
    $sformatf("Matches=%0d Mismatches=%0d",
              match_cnt,
              mismatch_cnt),
    UVM_NONE)

  if (mismatch_cnt == 0 && match_cnt > 0)
    `uvm_info("PASS",
      "DUT == REF (mock) - PASS",
      UVM_NONE)

  else if (match_cnt == 0 && mismatch_cnt == 0)
    `uvm_warning("EMPTY",
      "No commits compared.")

endfunction

endclass
