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
  /*| PC     | instr      | rd | valor |
    | ------ | ---------- | -- | ----- |
*/
extern "C" void dpi_spike_init(const char *elf_path)
{
  (void)elf_path; // Mock 不解析 ELF 
    printf("dpi_spike_init called\n");
    trace.clear();

// TRACE BEGIN
trace.push_back({true, 0x00000000ULL, 0x00a00293u, 5, 0x0000000aULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000004ULL, 0x00000313u, 6, 0x00000000ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000008ULL, 0x800003b7u, 7, 0x80000000ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000000cULL, 0x00a00e93u, 29, 0x0000000aULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000009ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000009ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000008ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000008ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000007ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000007ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000006ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000006ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000005ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000005ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000004ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000004ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000003ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000003ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000002ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000002ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000001ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000001ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000001cULL, 0xfffe8e93u, 29, 0x00000000ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000028ULL, 0x01d38e33u, 28, 0x80000000ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000000ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x00000000ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x80000001ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000009ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000001ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x00000001ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x80000002ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000008ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000002ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x00000003ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x80000003ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000007ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000003ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x00000006ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x80000004ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000006ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000004ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x0000000aULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x80000005ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000005ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000005ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x0000000fULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x80000006ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000004ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000006ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x00000015ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x80000007ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000003ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000007ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x0000001cULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x80000008ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000002ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000008ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x00000024ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x80000009ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000001ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000040ULL, 0x00038e03u, 28, 0x00000009ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x0000004cULL, 0x01c30333u, 6, 0x0000002dULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000050ULL, 0x00138393u, 7, 0x8000000aULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000054ULL, 0xfff28293u, 5, 0x00000000ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000064ULL, 0x00c000efu, 1, 0x00000068ULL, false, 0, 0, false, 3});
trace.push_back({true, 0x00000070ULL, 0x07b00f13u, 30, 0x0000007bULL, false, 0, 0, false, 3});

// TRACE END

  idx = 0;
    printf("trace size = %zu\n", trace.size());
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
    //printf("dpi_spike_next called idx=%zu\n", idx);
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
