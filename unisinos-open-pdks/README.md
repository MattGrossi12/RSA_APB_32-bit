# Testes de PDKs abertos — RSA APB

Este documento registra as adaptações necessárias para testar a síntese lógica
com Genus e a síntese física com Innovus do projeto `amba_3_apb_rsa_apb_top`.
Os resultados de cada tecnologia foram mantidos em diretórios separados dentro
de `ps_files/`.

## Resumo dos resultados

| PDK | Tecnologia | Resultado | Particularidade principal |
|---|---:|---|---|
| SKY130 HD | 130 nm | Síntese e fluxo físico concluídos | Liberty comprimido `.lib.gz` e LEF tecnológico `sky130_fd_sc.tlef`. |
| GF180MCU | 180 nm | Síntese física concluída | Liberty TT de 5 V ausente no caminho inicialmente informado; foi usado o arquivo `.lib.gz` do PDK. |
| ICsprout55 H7CR | 55 nm | Síntese física concluída após ajustes | Necessidade de `core7`, correção do site tecnológico e tratamento de comandos CCOpt incompatíveis. |
| IHP SG13G2 | 130 nm | Síntese lógica testada | Localização variável da biblioteca `sg13g2_stdcell` e validação dos arquivos antes do fluxo. |
| FreePDK45 / Nangate45 | 45 nm | Síntese testada | LEF, Liberty, GDS e CDL separados para síntese, Innovus e LVS. |
| ASAP7 | 7 nm | Fluxo completo concluído | QRC externo obrigatório e correção do argumento para `create_rc_corner`. |
## SKY130

O diretório disponível continha:

- `sky130_fd_sc_hd__tt_025C_1v80.lib.gz`;
- `sky130_fd_sc_hd_merged.lef`;
- `sky130_fd_sc.tlef`;
- modelos Verilog `primitives.v` e `sky130_fd_sc_hd.v`.

O nome correto do LEF tecnológico era `sky130_fd_sc.tlef`, e não
`sky130_fd_sc_hd.tlef`. O Liberty foi lido diretamente comprimido; não foi
necessário descompactá-lo. As mensagens sobre `pg_pin` e células físicas sem
pinos de saída foram tratadas como avisos de modelagem e não impediram a
sintetização.

## GF180MCU

O fluxo foi configurado para a biblioteca `gf180mcu_fd_sc_mcu7t5v0`, com o
LEF tecnológico `gf180mcu_5LM_1TM_9K_7t_tech.lef` e o LEF das células.

O arquivo `.lib` descompactado indicado inicialmente em
`workspace/gf180_lib` não existia. A solução foi utilizar o Liberty TT
disponível no PDK:

```text
gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib.gz
```

O fluxo físico usou a variante de 5 níveis de sinal mais 1 nível de alimentação
e o GDS comprimido da biblioteca `5LM`.

## ICsprout55 H7CR

Foram usados:

- `ics55_LLSC_H7CR_typ_tt_1p2_25_nldm.lib`;
- `N551P6M.lef`;
- `ics55_LLSC_H7CR_ecos.lef`;
- `ics55_LLSC_H7CR.v`.

O Innovus inicialmente falhou no CTS porque não encontrava buffers/inversores
adequados e porque o site padrão não correspondia ao LEF. A configuração foi
ajustada para usar `core7` em `coresite/`, e as células de CTS utilizáveis foram
identificadas a partir da biblioteca H7CR.

Também foi necessário remover ou proteger chamadas incompatíveis, como
`set_ccopt_property`, quando a versão do Innovus não disponibilizava esse
comando. A tecnologia apresentou avisos sobre resistências de vias, tabelas RC
incompletas e sites não utilizados; esses avisos não foram a causa das falhas
finais.

## IHP SG13G2

O fluxo foi preparado para `sg13g2_stdcell`, com descoberta dinâmica do
diretório da biblioteca porque a instalação podia aparecer em mais de um nível
da árvore do PDK. Foram validados Liberty, LEF tecnológico, LEF das células e
Verilog antes de iniciar o Genus.

Durante os testes, foi necessário tratar corretamente células físicas e
elementos específicos da biblioteca. A síntese lógica foi o objetivo validado;
os resultados foram preservados em `ps_files/rsa_apb_top_ihp130`.

## FreePDK45 / Nangate Open Cell Library

Foi separado o material lógico e físico da biblioteca Nangate45:

- `NangateOpenCellLibrary_typical.lib` para temporização;
- `freepdk45.tech.lef` para tecnologia;
- `NangateOpenCellLibrary.macro.mod.lef` para células;
- GDS para stream-out;
- CDL para LVS.

O resultado foi preservado em `ps_files/rsa_apb_top_freepdk45`, separado dos
demais resultados históricos.

## ASAP7

O ASAP7 foi o último fluxo avançado concluído. A configuração usou as cinco
partes Liberty TT/RVT da biblioteca `asap7sc7p5t_rvt`, o LEF tecnológico
`asap7_tech.lef` e o LEF `asap7sc7p5t_28_R.lef`.

O ponto mais importante foi adicionar o arquivo QRC externo:

```text
/home/aluno/eda-pdks-docker/pdks/asap7sc7p5t_28/qrc/qrcTechFile_typ03_unscaledV02
```

O argumento aceito pela versão do Innovus foi `-qrc_tech` em
`create_rc_corner`; a tentativa anterior com `-qx_tech_file` era inválida.
Com essa correção, o full flow completou as etapas de inicialização, check,
floorplan, power, place, CTS, route, postroute, verify e export.

Os resultados históricos dessa rodada permanecem em `ps_files/rsa_apb_top_asap7`.

## Diretivas de uso no Genus

Para usar qualquer PDK no Genus, o Tcl deve definir a biblioteca de células,
configurar `init_lib_search_path`, ler o Liberty com `read_libs`, carregar o
LEF tecnológico antes do LEF das células e validar os arquivos com
`file readable`. Em seguida, o fluxo lê o RTL, aplica o SDC e executa
`syn_generic`, `syn_map` e `syn_opt`.

O GDS, CDL e QRC não são necessários para a síntese lógica. O LEF é usado para
síntese física ou para preparar a transferência ao Innovus.

### SKY130 — Genus

```tcl
set SKY130 "$PDK_BASE/lambdapdk-v0.2.22-967925fc5309e6d4/lambdapdk/sky130"
set STD_CELL "$SKY130/libs/sky130hd"
set LIB_DIR "$STD_CELL/nldm"
set_db init_lib_search_path [list $LIB_DIR]
read_libs [list $LIB_DIR/sky130_fd_sc_hd__tt_025C_1v80.lib.gz]
set_db lef_library [list \
    $SKY130/base/apr/sky130_fd_sc.tlef \
    $STD_CELL/lef/sky130_fd_sc_hd_merged.lef]
set STD_CELL_VERILOG [list \
    $STD_CELL/verilog/primitives.v \
    $STD_CELL/verilog/sky130_fd_sc_hd.v]
```

O nome correto do LEF tecnológico é `sky130_fd_sc.tlef`. O Liberty `.lib.gz`
pode ser lido diretamente.

### GF180MCU — Genus

```tcl
set GF180 "$PDK_BASE/lambdapdk-v0.2.22-967925fc5309e6d4/lambdapdk/gf180"
set STD_CELL "$GF180/libs/gf180mcu_fd_sc_mcu7t5v0"
set LIB_DIR "$STD_CELL/nldm"
set LIB_FILE "$LIB_DIR/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib.gz"
set_db init_lib_search_path [list $LIB_DIR]
read_libs [list $LIB_FILE]
set_db lef_library [list \
    $GF180/base/apr/gf180mcu_5LM_1TM_9K_7t_tech.lef \
    $STD_CELL/lef/gf180mcu_fd_sc_mcu7t5v0.lef]
```

O arquivo TT descompactado que havia sido indicado não existia; foi usado o
arquivo `.lib.gz` fornecido pelo PDK.

### ICsprout55 H7CR — Genus

```tcl
set ICS55 "$PDK_BASE/icsprout55-v1.10.102-a7b1e2edbb12d056"
set STD_CELL "$ICS55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/ics55_LLSC_H7CR"
set LIB_DIR "$PDK_BASE/icsprout55-liberty-r-v1.10.102-c9ed7480e1a5b5d5/liberty"
set_db init_lib_search_path [list $LIB_DIR]
read_libs [list $LIB_DIR/ics55_LLSC_H7CR_typ_tt_1p2_25_nldm.lib]
set_db lef_library [list \
    $ICS55/prtech/techLEF/N551P6M.lef \
    $STD_CELL/lef/ics55_LLSC_H7CR_ecos.lef]
set STD_CELL_VERILOG "$STD_CELL/verilog/ics55_LLSC_H7CR.v"
```

### IHP SG13G2 — Genus

```tcl
set STD_CELL [lindex $candidates 0]
set LIB_DIR "$STD_CELL/lib"
set LIB_FILE "$LIB_DIR/sg13g2_stdcell_typ_1p20V_25C.lib"
set_db init_lib_search_path [list $LIB_DIR]
read_libs [list $LIB_FILE]
set_db lef_library [list \
    $STD_CELL/lef/sg13g2_tech.lef \
    $STD_CELL/lef/sg13g2_stdcell.lef]
set STD_CELL_VERILOG "$STD_CELL/verilog/sg13g2_stdcell.v"
```

O diretório `sg13g2_stdcell` deve ser localizado dinamicamente e todos os
arquivos devem ser validados antes da leitura.

### FreePDK45 / Nangate45 — Genus

```tcl
set FREEPDK45 "$PDK_BASE/lambdapdk-v0.2.22-967925fc5309e6d4/lambdapdk/freepdk45"
set STD_CELL "$FREEPDK45/libs/nangate45"
set LIB_DIR "$STD_CELL/nldm"
set_db init_lib_search_path [list $LIB_DIR]
read_libs [list $LIB_DIR/NangateOpenCellLibrary_typical.lib]
set_db lef_library [list \
    $FREEPDK45/base/apr/freepdk45.tech.lef \
    $STD_CELL/lef/NangateOpenCellLibrary.macro.mod.lef]
```

### ASAP7 — Genus

```tcl
set ASAP7 "$PDK_BASE/lambdapdk-v0.2.22-967925fc5309e6d4/lambdapdk/asap7"
set STD_CELL "$ASAP7/libs/asap7sc7p5t_rvt"
set LIB_DIR "$STD_CELL/nldm"
set LIB_FILES [list \
    $LIB_DIR/asap7sc7p5t_AO_RVT_TT_nldm.lib.gz \
    $LIB_DIR/asap7sc7p5t_INVBUF_RVT_TT_nldm.lib.gz \
    $LIB_DIR/asap7sc7p5t_OA_RVT_TT_nldm.lib.gz \
    $LIB_DIR/asap7sc7p5t_SEQ_RVT_TT_nldm.lib.gz \
    $LIB_DIR/asap7sc7p5t_SIMPLE_RVT_TT_nldm.lib.gz]
set_db init_lib_search_path [list $LIB_DIR]
read_libs $LIB_FILES
set_db lef_library [list \
    $ASAP7/base/apr/asap7_tech.lef \
    $STD_CELL/lef/asap7sc7p5t_28_R.lef]
```

Os cinco Liberty comprimidos são aceitos diretamente pelo Genus.

## Diretivas de uso no Innovus

No Innovus, os caminhos do Liberty e dos LEFs ficam no contexto comum; o MMMC
deve criar `library_set`, `rc_corner`, `delay_corner`, `constraint_mode` e
`analysis_view`; e a inicialização deve definir `design_process_node`, nets de
alimentação, `read_mmmc`, `read_physical` e `read_netlist`.

O GDS é reservado ao stream-out e o QRC à extração RC. O argumento validado
para o QRC foi `-qrc_tech` em `create_rc_corner`.

### SKY130 — Innovus

```tcl
set SKY130 "$PDK_BASE/lambdapdk-v0.2.22-967925fc5309e6d4/lambdapdk/sky130"
set STD_CELL "$SKY130/libs/sky130hd"
set LIB_DIR "$STD_CELL/nldm"
set LIB_FILES [list $LIB_DIR/sky130_fd_sc_hd__tt_025C_1v80.lib.gz]
set TECH_LEF "$SKY130/base/apr/sky130_fd_sc.tlef"
set CELL_LEF "$STD_CELL/lef/sky130_fd_sc_hd_merged.lef"
set STD_CELL_GDS "$STD_CELL/gds/sky130_fd_sc_hd.gds"
set_db design_process_node 130
set_db lef_library [list $TECH_LEF $CELL_LEF]
create_library_set -name lib_typical -timing $LIB_FILES
```

O GDS é incluído somente na etapa de stream-out. O Liberty comprimido é aceito
diretamente pelo `create_library_set`.

### GF180MCU — Innovus

```tcl
set GF180 "$PDK_BASE/lambdapdk-v0.2.22-967925fc5309e6d4/lambdapdk/gf180"
set STD_CELL "$GF180/libs/gf180mcu_fd_sc_mcu7t5v0"
set LIB_FILE "$STD_CELL/nldm/gf180mcu_fd_sc_mcu7t5v0__tt_025C_5v00.lib.gz"
set TECH_LEF "$GF180/base/apr/gf180mcu_5LM_1TM_9K_7t_tech.lef"
set CELL_LEF "$STD_CELL/lef/gf180mcu_fd_sc_mcu7t5v0.lef"
set STD_CELL_GDS "$STD_CELL/gds/5LM/gf180mcu_fd_sc_mcu7t5v0.gds.gz"
set_db design_process_node 180
set_db lef_library [list $TECH_LEF $CELL_LEF]
create_library_set -name lib_typical -timing [list $LIB_FILE]
```

Os anéis e stripes devem usar os nomes de camada efetivamente declarados pelo
LEF, e não nomes genéricos como `Metal4` ou `Metal5`.

### ICsprout55 H7CR — Innovus

```tcl
set ICS55 "$PDK_BASE/icsprout55-v1.10.102-a7b1e2edbb12d056"
set STD_CELL "$ICS55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/ics55_LLSC_H7CR"
set LIB_DIR "$PDK_BASE/icsprout55-liberty-r-v1.10.102-c9ed7480e1a5b5d5/liberty"
set LIB_FILE "$LIB_DIR/ics55_LLSC_H7CR_typ_tt_1p2_25_nldm.lib"
set TECH_LEF "$ICS55/prtech/techLEF/N551P6M.lef"
set CELL_LEF "$STD_CELL/lef/ics55_LLSC_H7CR_ecos.lef"
set_db design_process_node 55
set_db lef_library [list $TECH_LEF $CELL_LEF]
create_library_set -name lib_typical -timing [list $LIB_FILE]
set_db floorplan_default_tech_site core7
```

No CTS, use somente buffers e inversores disponíveis na biblioteca. Comandos
CCOpt que não existam na versão instalada devem ser protegidos ou removidos.

### IHP SG13G2 — Innovus

```tcl
set STD_CELL [lindex $candidates 0]
set LIB_FILE "$STD_CELL/lib/sg13g2_stdcell_typ_1p20V_25C.lib"
set TECH_LEF "$STD_CELL/lef/sg13g2_tech.lef"
set CELL_LEF "$STD_CELL/lef/sg13g2_stdcell.lef"
set STD_CELL_GDS "$STD_CELL/gds/sg13g2_stdcell.gds"
set_db design_process_node 130
set_db lef_library [list $TECH_LEF $CELL_LEF]
create_library_set -name lib_typical -timing [list $LIB_FILE]
```

O diretório `sg13g2_stdcell` deve ser localizado e validado antes da criação
do MMMC.

### FreePDK45 / Nangate45 — Innovus

```tcl
set FREEPDK45 "$PDK_BASE/lambdapdk-v0.2.22-967925fc5309e6d4/lambdapdk/freepdk45"
set STD_CELL "$FREEPDK45/libs/nangate45"
set LIB_FILE "$STD_CELL/nldm/NangateOpenCellLibrary_typical.lib"
set TECH_LEF "$FREEPDK45/base/apr/freepdk45.tech.lef"
set CELL_LEF "$STD_CELL/lef/NangateOpenCellLibrary.macro.mod.lef"
set STD_CELL_GDS "$STD_CELL/gds/NangateOpenCellLibrary.gds"
set STD_CELL_CDL "$STD_CELL/cdl/NangateOpenCellLibrary.cdl"
set_db design_process_node 45
set_db lef_library [list $TECH_LEF $CELL_LEF]
create_library_set -name lib_typical -timing [list $LIB_FILE]
```

O CDL permanece separado para LVS e não é carregado pelo Innovus.

### ASAP7 — Innovus

```tcl
set ASAP7 "$PDK_BASE/lambdapdk-v0.2.22-967925fc5309e6d4/lambdapdk/asap7"
set STD_CELL "$ASAP7/libs/asap7sc7p5t_rvt"
set LIB_DIR "$STD_CELL/nldm"
set LIB_FILES [list \
    $LIB_DIR/asap7sc7p5t_AO_RVT_TT_nldm.lib.gz \
    $LIB_DIR/asap7sc7p5t_INVBUF_RVT_TT_nldm.lib.gz \
    $LIB_DIR/asap7sc7p5t_OA_RVT_TT_nldm.lib.gz \
    $LIB_DIR/asap7sc7p5t_SEQ_RVT_TT_nldm.lib.gz \
    $LIB_DIR/asap7sc7p5t_SIMPLE_RVT_TT_nldm.lib.gz]
set TECH_LEF "$ASAP7/base/apr/asap7_tech.lef"
set CELL_LEF "$STD_CELL/lef/asap7sc7p5t_28_R.lef"
set QRC_FILE "/home/aluno/eda-pdks-docker/pdks/asap7sc7p5t_28/qrc/qrcTechFile_typ03_unscaledV02"
set STD_CELL_GDS "$STD_CELL/gds/asap7sc7p5t_28_R.gds.gz"
set_db design_process_node 7
set_db lef_library [list $TECH_LEF $CELL_LEF]
create_library_set -name lib_typical -timing $LIB_FILES
create_rc_corner -name rc_typical -temperature 25 -qrc_tech $QRC_FILE
```

O argumento correto para o QRC é `-qrc_tech`; a alternativa
`-qx_tech_file` não funcionou na versão utilizada.

## Estado atual

O fluxo ativo seleciona SKY130, GPDK45, FreePDK45 ou ICsprout55 pelo argumento
`-p sky130|gpdk45|free45|ics55`, com GPDK45 como padrão. Não é necessário
editar os Tcl para alternar entre essas tecnologias:

```bash
./scripts/amba_3_apb_rsa_apb_top/bash/genus_no_gui.sh -p sky130
./scripts/amba_3_apb_rsa_apb_top/bash/innovus_no_gui.sh -p sky130
```

O PDK ICsprout55 usa a flag `ics55` e o sufixo `_ics55` nos resultados.
Cada execução fica isolada por PDK e identificador de síntese. Os registros
anteriores deste documento descrevem as rodadas históricas; ASAP7, GF180 e
IHP não fazem parte do novo seletor.

Consulte o [guia de execução por PDK](../scripts/amba_3_apb_rsa_apb_top/README.md).
Os parâmetros tecnológicos estão em
[`tcl/pdks/`](../scripts/amba_3_apb_rsa_apb_top/tcl/pdks/).
As etapas compartilhadas estão em:

- [run_genus.tcl](../scripts/amba_3_apb_rsa_apb_top/tcl/run_genus.tcl);
- [innovus_common.tcl](../scripts/amba_3_apb_rsa_apb_top/tcl/innovus_common.tcl);
- [innovus_mmmc.tcl](../scripts/amba_3_apb_rsa_apb_top/tcl/innovus_mmmc.tcl);
- [innovus_init.tcl](../scripts/amba_3_apb_rsa_apb_top/tcl/innovus_init.tcl).
