// spike_dpi.cc — Mock Spike：返回三条固定提交，便于环境闭环验证
#include "svdpi.h"
#include <cstdint>
#include <string>
#include <vector>

struct Commit
{
  bool valid; //se há commit nessa entrada
  uint64_t pc;// PC da instrução
  uint32_t instr;//instrução executada
  uint8_t rd_addr;//registrador destino
  uint64_t rd_data;//valor escrito no regfile
  bool mem_we;//store?
  uint64_t mem_addr; //acesso à memória - address
  uint64_t mem_wdata;// acesso à memória - write data
  bool trap;//exceção
  uint8_t priv;//nível de privilégio (U/S/M)
};

static std::vector<Commit> trace;// lista de commits esperados
static size_t idx = 0;//ponteiro de execução

//O que deveria fazer num Spike real:
extern "C" void dpi_spike_init(const char *elf_path)
{
  (void)elf_path; // Mock 不解析 ELF 
  trace.clear();
  //stub  -  ignora o ELF completamente e injeta 3 instruções fixas:
  /*| PC     | instr      | rd | valor |
    | ------ | ---------- | -- | ----- |
    | 0x1000 | 0x01300093 | x1 | 19    |
    | 0x1004 | 0x00108113 | x2 | 20    |
    | 0x1008 | 0x00209193 | x3 | 21    |
    */
  trace.push_back({true, 0x00001000ULL, 0x01300093u, 1, 19ULL, false, 0, 0, false, 3});
  trace.push_back({true, 0x00001004ULL, 0x00108113u, 2, 20ULL, false, 0, 0, false, 3});
  trace.push_back({true, 0x00001008ULL, 0x00209193u, 3, 21ULL, false, 0, 0, false, 3});
  idx = 0;
}

//Funcao principal, chamada pelo SystemVerilog
extern "C" int dpi_spike_next(
    svBit *valid,
    unsigned long long *pc,
    int *instr,
    unsigned char *rd_addr,
    unsigned long long *rd_data,
    svBit *mem_we,
    unsigned long long *mem_addr,
    unsigned long long *mem_wdata,
    svBit *trap,
    unsigned char *priv)
{   //Se ainda existem commits:
    //1) Pega o commit atual
    //2) Copia para os ponteiros SV
    //3) Avança idx
  if (idx < trace.size())
  {
    const Commit &c = trace[idx++];
    *valid = c.valid ? 1 : 0;
    *pc = c.pc;
    *instr = (int)c.instr;
    *rd_addr = c.rd_addr;
    *rd_data = c.rd_data;
    *mem_we = c.mem_we ? 1 : 0;
    *mem_addr = c.mem_addr;
    *mem_wdata = c.mem_wdata;
    *trap = c.trap ? 1 : 0;
    *priv = c.priv;
    return 1; // tem commit válido nesse ciclo
  }
  else
  {
    *valid = 0;
    return 0; // não há mais instruções
  }
}

extern "C" void dpi_spike_fini()
{
    //Não faz nada.
    //Em Spike real:
        //fechar arquivos
        //liberar memória
        //finalizar trace
    // no-op for mock
}
