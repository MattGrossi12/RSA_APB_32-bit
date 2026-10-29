# Síntese do top por PDK

Os fluxos Genus e Innovus usam apenas `amba_3_apb_rsa_apb_top`.
Selecione a tecnologia com `-p`; sem esse argumento, o padrão é `gpdk45`.

| Flag e sufixo | PDK | Biblioteca | Site |
|---|---|---|---|
| `sky130` | SKY130, 130 nm | sky130_fd_sc_hd, TT 1,8 V / 25 °C | unithd |
| `gpdk45` | GPDK45, 45 nm | GSCLib045, typical | CoreSite |
| `free45` | FreePDK45, 45 nm | Nangate45, typical | FreePDK45_38x28_10R_NP_162NW_34O |
| `ics55` | ICsprout55, 55 nm | H7CR, TT 1,2 V / 25 °C | core7 |

ICsprout55 usa `ics55` nos comandos e nos nomes dos arquivos.
GPDK45 e FreePDK45 são configurações independentes.

## Execução

Na raiz do repositório, após configurar o ambiente e as licenças Cadence:

```bash
./scripts/amba_3_apb_rsa_apb_top/bash/genus_no_gui.sh -p sky130
./scripts/amba_3_apb_rsa_apb_top/bash/genus_no_gui.sh -p gpdk45
./scripts/amba_3_apb_rsa_apb_top/bash/genus_no_gui.sh -p free45
./scripts/amba_3_apb_rsa_apb_top/bash/genus_no_gui.sh -p ics55

./scripts/amba_3_apb_rsa_apb_top/bash/innovus_no_gui.sh -p sky130
./scripts/amba_3_apb_rsa_apb_top/bash/innovus_no_gui.sh -p gpdk45
./scripts/amba_3_apb_rsa_apb_top/bash/innovus_no_gui.sh -p free45
./scripts/amba_3_apb_rsa_apb_top/bash/innovus_no_gui.sh -p ics55
```

Os nomes anteriores `genus_nogui.sh` e `innovus_full_flow.sh` continuam
aceitando os mesmos argumentos. `-h` mostra a ajuda; argumentos adicionais
da ferramenta devem vir depois de `--`.

O Innovus executa as etapas 0 a 9 sobre a netlist mais recente **do PDK
selecionado**, exigindo o SDC com o mesmo identificador. O fluxo completo fixa
essa seleção antes de iniciar; outra síntese ou atualização de `active_run`
não muda a execução em andamento. Uma falha interrompe as etapas seguintes.

Para executar apenas uma etapa ou abrir a GUI:

```bash
./scripts/amba_3_apb_rsa_apb_top/bash/0.innovus_init.sh -p free45
./scripts/amba_3_apb_rsa_apb_top/bash/1.innovus_check.sh -p free45
./scripts/amba_3_apb_rsa_apb_top/bash/innovus_gui.sh place -p free45
./scripts/amba_3_apb_rsa_apb_top/bash/genus_gui.sh -p free45
```

Nas etapas individuais, informe sempre o mesmo `-p`. A GUI Innovus abre a
etapa mais avançada disponível por padrão. Para selecionar uma síntese
específica, copie seu identificador completo, incluindo o sufixo:

```bash
SYNTH_RUN=amba_3_apb_rsa_apb_top_2026-10-29_16-00-00_123456789_sky130 \
  ./scripts/amba_3_apb_rsa_apb_top/bash/innovus_no_gui.sh -p sky130
```

## Resultados

`RUN` tem o formato
`amba_3_apb_rsa_apb_top_<data>_<hora>_<nanossegundos>_<flag>`.
Cada síntese recebe um identificador novo, inclusive no mesmo segundo.

| Artefato | Caminho |
|---|---|
| Genus: banco, netlist, restrições e atrasos | `ps_files/rsa_apb_top_<flag>/{db,netlist,sdc,sdf}/synth_<RUN>.*` |
| Relatórios Genus | `reports/amba_3_apb_rsa_apb_top_<flag>/genus/<RUN>/*_<flag>.rpt` |
| Logs Genus | `logs/amba_3_apb_rsa_apb_top_<flag>/genus/<RUN>/` |
| Bancos Innovus | `ps_files/rsa_apb_top_<flag>/innovus/rsa32_v2/<RUN>/<etapa>_amba_3_apb_rsa_apb_top_<flag>/` |
| Relatórios Innovus | `reports/amba_3_apb_rsa_apb_top_<flag>/innovus/rsa32_v2/<RUN>/<etapa>/` |
| Logs Innovus | `logs/amba_3_apb_rsa_apb_top_<flag>/innovus/rsa32_v2/<RUN>/<etapa>/` |
| Exportação Innovus | `ps_files/rsa_apb_top_<flag>/innovus/rsa32_v2/<RUN>/export/*_<flag>.*` |

Os relatórios explícitos têm sufixo, como `area_sky130.rpt` e
`timing_max_gpdk45.rpt`. Os relatórios automáticos de temporização do Innovus
ficam em subpastas com sufixo. Arquivos internos das ferramentas podem manter
seus nomes próprios dentro da pasta isolada de execução.
Cada PDK possui seu próprio `active_run`. O arquivo
`synthesis_inputs_<flag>.txt` registra a síntese, Liberty, LEFs, netlist e SDC.
Os resultados históricos permanecem nos caminhos anteriores e não são
selecionados automaticamente quando não seguem a nova nomenclatura.

## Tcl e instalação dos PDKs

`tcl/run_genus_<flag>.tcl` e `tcl/run_innovus_<flag>.tcl` são as entradas
específicas. Os parâmetros tecnológicos ficam em `tcl/pdks/<flag>.tcl`,
compartilhados pelo Genus, inicialização Innovus e MMMC.
O RTL, as etapas e o SDC de entrada são comuns para facilitar comparações.
As configurações incluem Liberty, LEFs, nó, site, camadas, alimentação e
células de CTS. Os arquivos Liberty e LEF são verificados antes da leitura.

Os caminhos padrão correspondem aos PDKs instalados nesta máquina. Para
outra instalação, configure:

| Variável | Diretório |
|---|---|
| `PDK_BASE` | Cache dataroot dos PDKs abertos |
| `LAMBDAPDK_ROOT` | Diretório lambdapdk que contém sky130 e freepdk45 |
| `GPDK45_ROOT` | Raiz GSCLib045 com LIB e LEF; aceita também INNOVUS_TECH_DIR |
| `SKY130_ROOT` | Raiz sky130 com base e libs |
| `FREEPDK45_ROOT` | Raiz freepdk45 com base e libs |
| `ICS55_ROOT` | Raiz ICsprout55 com IP e prtech |
| `ICS55_LIB_ROOT` | Diretório do Liberty H7CR |
| `GENUS_BIN`, `INNOVUS_BIN` | Executáveis das ferramentas |

O MMMC usa o corner typical e os dados RC dos LEFs, sem o QRC específico
do antigo fluxo ASAP7. O GDS exportado continua experimental, sem incorporar
GDS das células ou um mapa de camadas validado. A seleção de PDK não altera
os scripts de simulação ou LEC.
