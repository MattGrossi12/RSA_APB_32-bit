# RSA_APB

Periférico RSA com interface AMBA 3 APB (APB3), descrito em SystemVerilog.
O projeto contém RTL do periférico, um núcleo RSA, testbenches estruturais e
scripts auxiliares de síntese, LEC e simulação.

## Estrutura do repositório

```text
.
├── constraints/                 # SDCs por módulo
├── docs/                        # Especificações e material de referência
├── images/                      # Diagramas e imagens do projeto
├── logs/<modulo>/{genus,lec,xrun}/
├── ps_files/<modulo>/{db,netlist,sdc}/
├── reports/<modulo>/
├── scripts/<modulo>/
│   ├── bash/                    # Entradas dos fluxos
│   └── tcl/
│       └── legacy/              # Tcl legado preservado
├── src/
│   ├── amba_3_apb/              # RTL APB e wrapper RSA
│   │   ├── legacy/              # RTL legado, fora do fluxo ativo
│   │   └── rsa_apb_top.sv
│   └── rsa32/
│       └── rsa_core_32.sv       # Declara rsa_core e módulos auxiliares
├── testbenchs/<modulo>/testbench.sv
└── waveforms/
```

## Imagens do projeto

### Sequência de controle do wrapper RSA

<div align="center">
  <img src="images/img1.svg" alt="Diagrama de estados do controle do wrapper RSA: START, carregamento de mensagem, expoente e módulo, espera por core_done ou core_err, e retorno por DONE ou ERROR.">
  <p><em>Figura 1 — Estados e transições do controle do wrapper RSA, incluindo reset síncrono e conclusão ou erro do núcleo.</em></p>
</div>

### Transferência de dados para o núcleo

<div align="center">
  <img src="images/img2.svg" alt="Diagrama temporal dos ciclos C0 a C5 com START, LOAD, BUSY, DONE e DIN para mensagem, expoente e módulo.">
  <p><em>Figura 2 — Sequência temporal de inicialização, carregamento dos operandos e sinalização de ocupado/concluído do núcleo RSA.</em></p>
</div>

### Máquina de estados do protocolo APB

<div align="center">
  <img src="images/img3.png" alt="Diagrama da máquina APB com os estados IDLE, SETUP e ACCESS, e transições controladas por PSELx, PENABLE e PREADY.">
  <p><em>Figura 3 — Fases IDLE, SETUP e ACCESS de uma transferência APB, incluindo espera quando PREADY está baixo.</em></p>
</div>

### Exemplo de escrita APB

<div align="center">
  <img src="images/img4.svg" alt="Diagrama temporal de uma escrita APB para o endereço 0x0C com o dado 0x12345678, passando por SETUP e ACCESS.">
  <p><em>Figura 4 — Exemplo de transferência de escrita APB e captura dos dados na borda final do acesso.</em></p>
</div>

### Geração da interrupção

<div align="center">
  <img src="images/img5.svg" alt="Diagrama lógico da IRQ combinando STATUS.DONE e STATUS.ERROR com IER.DONE_IE e IER.ERR_IE.">
  <p><em>Figura 5 — Lógica de interrupção: flags DONE e ERROR habilitadas pelos bits correspondentes do registrador IER.</em></p>
</div>

## Diagrama editável

O diagrama de topo da arquitetura pode ser editado no diagrams.net:
[Abrir diagrama de topo](https://app.diagrams.net/#G1pJmIWxV6VePdHCURcpEqT6SSo5kHxkri#%7B%22pageId%22%3A%22MEHrRE8WjDQsoYR0GH0S%22%7D).

O diretório `scripts/amba_3_apb_data_i_demux/` e o RTL
`src/amba_3_apb/legacy/amba_3_apb_data_i_demux.sv` são artefatos legados;
`amba_3_apb_data_i_demux` não faz parte dos blocos ativos do projeto.

## Módulos RTL

| Módulo e fonte | Responsabilidade |
|---|---|
| `amba_3_apb_control`<br>[Fonte RTL](src/amba_3_apb/amba_3_apb_control.sv) | Controle APB e habilitações<br>de escrita e IRQ. |
| `amba_3_apb_data_io_top`<br>[Fonte RTL](src/amba_3_apb/amba_3_apb_data_io_top.sv) | Redução e validação do endereço;<br>caminho de leitura. |
| `amba_3_apb_data_o_mux`<br>[Fonte RTL](src/amba_3_apb/amba_3_apb_data_o_mux.sv) | Multiplexação combinacional<br>dos dados de leitura. |
| `amba_3_apb_regbank`<br>[Fonte RTL](src/amba_3_apb/amba_3_apb_regbank.sv) | Registradores de controle, status,<br>operandos e resultado. |
| `amba_3_apb_reset`<br>[Fonte RTL](src/amba_3_apb/amba_3_apb_reset.sv) | Sincronização de reset<br>e reset do núcleo. |
| `amba_3_apb_rsa_wrapper_control`<br>[Fonte RTL](src/amba_3_apb/amba_3_apb_rsa_wrapper_control.sv) | FSM de controle<br>do wrapper RSA. |
| `amba_3_apb_rsa_wrapper_data`<br>[Fonte RTL](src/amba_3_apb/amba_3_apb_rsa_wrapper_data.sv) | Caminho de dados e carregamento<br>dos operandos do núcleo. |
| `amba_3_apb_rsa_wrapper_top`<br>[Fonte RTL](src/amba_3_apb/amba_3_apb_rsa_wrapper_top.sv) | Integração do controle, dados<br>e núcleo RSA. |
| `rsa_apb_top`<br>[Fonte RTL](src/amba_3_apb/rsa_apb_top.sv) | Topo do periférico<br>com interface APB. |
| `rsa_core` e auxiliares<br>[Fonte RTL](src/rsa32/rsa_core_32.sv) | Núcleo RSA e módulos<br>`rsa_core_mult`, `rsa_core_mod`, `rsa_core_ctrl`. |

O arquivo e o módulo de topo agora compartilham o nome `rsa_apb_top`. O testbench
correspondente fica em [`testbenchs/rsa_apb_top/testbench.sv`](testbenchs/rsa_apb_top/testbench.sv).
Os outros testbenches por módulo estão em `testbenchs/<nome_do_modulo>/`.
Atualmente são estruturais: declaram sinais e instanciam o DUT, mas não contêm
estímulos nem verificações.

## Diagrama de arquitetura de topo

O diagrama abaixo representa a arquitetura-alvo e a relação entre os blocos:

```mermaid
flowchart TD
    EXT["APB3 externo"] --> IO["data_io_top / data_o_mux"]
    EXT --> C["apb_control"]
    EXT --> R["regbank"]
    IO -->|"oaddr + addr_valid"| C
    R -->|"dados de leitura"| IO
    C -->|"WE"| R
    R -->|"START + operandos"| WT["rsa_wrapper_top"]
    WT --> WC["rsa_wrapper_control"]
    WT --> WD["rsa_wrapper_data"]
    WT --> CORE["rsa_core"]
    WC --> WD
    WD --> CORE
    CORE --> WC
    WT -->|"BUSY, DONE, ERROR, DOUT"| R
    WT -->|"BUSY"| C
    R -->|"SRST"| RESET["reset"]
    EXT --> RESET
    RESET -->|"rsa_rst"| WT
```

Este é um diagrama de referência da arquitetura; ele não afirma que todas as
instâncias e conexões já estejam completas no RTL de `rsa_apb_top`.

Documentação detalhada dos blocos APB:
[`src/amba_3_apb/`](src/amba_3_apb/).
A análise do topo APB está em
[`src/rsa32/README_rsa_apb_top.md`](src/rsa32/README_rsa_apb_top.md).

## Organização dos resultados

- Os SDCs estão em `constraints/<nome_do_modulo>.sdc`.
- Os resultados de síntese são separados em
  `ps_files/<nome_do_modulo>/{netlist,sdc,db}/`.
- Os relatórios ficam em `reports/<nome_do_modulo>/`.
- Os logs são centralizados em `logs/<nome_do_modulo>/{genus,lec,xrun}/`.
- Formas de onda são armazenadas em `waveforms/`.

Os arquivos `insira_aqui.txt` mantêm pastas vazias rastreáveis pelo Git até que
sejam gerados os respectivos resultados.

## Melhorias recomendadas

1. **Completar e validar a integração de `rsa_apb_top`:** confirmar que as
   instâncias e conexões usam as interfaces RTL atuais e que todas as saídas APB
   têm drivers.
2. **Criar listas de fontes por fluxo/módulo:** os Tcl de síntese referenciam
   `filelist.f`; manter listas explícitas e versionadas evita depender de
   arquivos externos ou de diretórios de execução implícitos.
3. **Parametrizar os scripts compartilhados:** os scripts foram copiados por
   módulo e repetem lógica. Um fluxo comum com o módulo como argumento reduz
   divergências de caminhos e opções.
4. **Adicionar verificação automatizada:** elaborar os testbenches com clock,
   reset, estímulos e assertions; executar lint, compilação/elaboração e testes
   em CI antes de considerar o fluxo funcional.
5. **Alinhar os artefatos aos módulos ativos:** revisar os diretórios SDC,
   relatórios e resultados que ainda incluem o módulo legado
   `amba_3_apb_data_i_demux`.
6. **Documentar e versionar requisitos das ferramentas:** registrar versões de
   simulador, Genus/LEC, bibliotecas e variáveis de ambiente necessárias para
   reproduzir os fluxos.

As sugestões acima são propostas de trabalho; não alteram o comportamento do
RTL nem afirmam que os fluxos proprietários foram executados.
