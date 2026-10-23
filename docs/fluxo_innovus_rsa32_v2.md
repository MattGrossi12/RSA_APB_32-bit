# Fluxo Innovus para RSA32 v2

O Innovus implementa o topo `amba_3_apb_rsa_apb_top` a partir da netlist mapeada
pelo Genus. Os módulos de `src/rsa32/v2` já estão contidos nessa netlist.
O período de clock e os delays de interface vêm do SDC exportado pela mesma
execução de síntese.

## Execução

Com as ferramentas e licenças Cadence configuradas, execute na ordem:

```bash
./scripts/amba_3_apb_rsa_apb_top/bash/0.innovus_init.sh
./scripts/amba_3_apb_rsa_apb_top/bash/1.innovus_check.sh
./scripts/amba_3_apb_rsa_apb_top/bash/2.innovus_floorplan.sh
./scripts/amba_3_apb_rsa_apb_top/bash/3.innovus_power.sh
./scripts/amba_3_apb_rsa_apb_top/bash/4.innovus_place.sh
./scripts/amba_3_apb_rsa_apb_top/bash/5.innovus_cts.sh
./scripts/amba_3_apb_rsa_apb_top/bash/6.innovus_route.sh
./scripts/amba_3_apb_rsa_apb_top/bash/7.innovus_postroute.sh
./scripts/amba_3_apb_rsa_apb_top/bash/8.innovus_verify.sh
./scripts/amba_3_apb_rsa_apb_top/bash/9.innovus_export.sh
```

A etapa 0 seleciona a netlist `synth_amba_3_apb_rsa_apb_top_*.v` mais recente
por data de modificação e exige o SDC com o mesmo identificador. Ela executa
`init_design`, grava o banco inicial e registra a execução ativa. As próximas
etapas continuam nessa execução, mesmo que outra síntese seja criada depois.

Para selecionar uma síntese específica, informe `SYNTH_RUN` na inicialização.
Por exemplo, a execução da v2 a 250 MHz de 23/10/2026 às 16:20:

```bash
SYNTH_RUN=amba_3_apb_rsa_apb_top_2026-10-23_16-20-34 \
  ./scripts/amba_3_apb_rsa_apb_top/bash/0.innovus_init.sh
./scripts/amba_3_apb_rsa_apb_top/bash/1.innovus_check.sh
```

Também é possível informar `SYNTH_RUN` às outras etapas para trabalhar com
um banco já iniciado. A etapa acusa erro se o banco anterior dessa execução
estiver ausente.

## Bancos e resultados

Os resultados são separados por identificador da síntese:

| Artefato | Diretório |
|---|---|
| Bancos físicos | `ps_files/rsa_apb_top/innovus/rsa32_v2/<SYNTH_RUN>/` |
| Relatórios | `reports/amba_3_apb_rsa_apb_top/innovus/rsa32_v2/<SYNTH_RUN>/` |
| Logs | `logs/amba_3_apb_rsa_apb_top/innovus/rsa32_v2/<SYNTH_RUN>/<etapa>/` |
| Exportação | `ps_files/rsa_apb_top/innovus/rsa32_v2/<SYNTH_RUN>/export/` |

O arquivo `ps_files/rsa_apb_top/innovus/rsa32_v2/active_run` identifica a
execução ativa. Cada banco inicial contém `synthesis_inputs.txt` com os
caminhos da netlist e do SDC. Os bancos anteriores fora de `rsa32_v2/`
continuam disponíveis e não são usados automaticamente pelo novo fluxo.

A tecnologia é GSCLib045, com `design_process_node` de 45 nm e biblioteca
`typical.lib`. O floorplan usa densidade de 60% para dimensionar o core a
partir da área das células importadas. A etapa de exportação gera DEF,
netlist, SDF, SDC e GDS experimental, conforme os comandos do fluxo.

## GUI e simulação após roteamento

```bash
./scripts/amba_3_apb_rsa_apb_top/bash/innovus_gui.sh
./scripts/amba_3_apb_rsa_apb_top/bash/xrun_ps.sh
```

A GUI abre por padrão o banco **postroute da execução ativa**, mostra o
caminho completo no terminal e enquadra o desenho na tela. Se esse banco
estiver ausente, o script informa o erro. Para abrir uma etapa específica:

```bash
INNOVUS_DB_STAGE=place ./scripts/amba_3_apb_rsa_apb_top/bash/innovus_gui.sh
# Equivalente:
./scripts/amba_3_apb_rsa_apb_top/bash/innovus_gui.sh place
```

Para selecionar automaticamente a etapa mais avançada disponível:

```bash
./scripts/amba_3_apb_rsa_apb_top/bash/innovus_gui.sh auto
```

`xrun_ps.sh` usa a netlist e o SDF da exportação da mesma execução ativa.

Os scripts podem ser chamados de qualquer diretório. `INNOVUS_BIN` permite
informar o executável do Innovus; `INNOVUS_TECH_DIR` permite informar a raiz
da árvore GSCLib045 com `LIB/` e `LEF/`.
