# Comparação da síntese RSA v2 a 250 MHz com as anteriores

Comparação em 23/10/2026. Última execução: `amba_3_apb_rsa_apb_top_2026-10-23_16-20-34`, relatórios gerados às 16:21. Esta análise utiliza relatórios existentes; nenhuma nova síntese foi executada.

**A síntese atual atende ao setup de 250 MHz no corner typical, com folga crítica de apenas 0,7 ps, TNS = 0 e zero caminhos com violação.** Em relação à síntese 2, também a 250 MHz, usa 4,89% mais área de células e apresenta 1,42% menos potência estimada. A atual inclui 200 ps de incerteza de clock, ausentes na síntese 2; portanto, a comparação não isola somente o efeito do RTL.

## Condições efetivamente usadas

Conferidas no [SDC exportado da execução](../../ps_files/rsa_apb_top/sdc/synth_amba_3_apb_rsa_apb_top_2026-10-23_16-20-34.sdc), no relatório de clocks e no log:

- Período: **4,0 ns**, frequência alvo: **250 MHz**.
- Input delay máximo: **0,5 ns**; output delay máximo: **0,2 ns**.
- Incerteza de setup: **0,2 ns**; delays mínimos de entrada e saída: **0 ns**.
- `presetn_i` excluído dos delays síncronos de entrada.
- Biblioteca **typical.lib**, nominal **1,20 V / 25 °C**; interconexão `global`; área `physical library`.
- Esforços `syn_generic`, `syn_map` e `syn_opt`: **high**.
- O log registra os cinco fontes de `src/rsa32/v2`.

## Visão geral das oito execuções

| Síntese | Clock (MHz) | Corner | Incerteza (ns) | Células | Área de células (µm²) | Área total reportada (µm²) | Folga (ps) | Potência (mW) |
|---|---:|---|---:|---:|---:|---:|---:|---:|
| [Síntese 1](genus_synth1/qor.rpt) | 100 | typical | 0,0 | 2.200 | 8.635,500 | 11.665,056 | +1.915,4 | 1,30821 |
| [Síntese 2](genus_synth2/qor.rpt) | 250 | typical | 0,0 | 2.702 | 9.137,351 | 12.723,950 | +7,2 | 3,42829 |
| [Síntese 3](genus_synth3/qor.rpt) | 200 | typical | 0,0 | 2.619 | 9.035,024 | 12.517,148 | +3,9 | 2,82316 |
| [Síntese 4](genus_synth4/qor.rpt) | 200 | typical | 0,0 | 2.621 | 9.044,258 | 12.530,107 | +6,8 | 2,82265 |
| [Síntese 5](genus_synth5/qor.rpt) | 100 | fast | 0,2 | 2.063 | 8.203,212 | 11.292,636 | +4.321,2 | 1,79719 |
| [Síntese 6](genus_synth6/qor.rpt) | 100 | typical | 0,2 | 2.200 | 8.635,500 | 11.665,056 | +1.715,4 | 1,30821 |
| [Síntese 7 — v2 a 100 MHz](genus_synth7/qor.rpt) | 100 | typical | 0,2 | 2.501 | 9.182,016 | 12.503,084 | +2.567,6 | 1,30958 |
| [Atual v2 — 250 MHz](genus/qor.rpt) | 250 | typical | 0,2 | 2.734 | 9.584,208 | 13.145,605 | +0,7 | 3,37975 |

Todas as oito execuções reportam zero violações de setup nas condições usadas. A área total reportada soma área de células e estimativa de redes; não representa área de core/die. As potências são estimativas de síntese; o log atual identifica análise **vectorless**, sem atividade medida pela bancada UVM.

## Comparação principal: atual versus síntese 2, ambas a 250 MHz

| Métrica | Síntese 2 | Atual | Variação |
|---|---:|---:|---:|
| Células | 2.702 | 2.734 | +1,18% |
| Área de células (µm²) | 9.137,351 | 9.584,208 | +4,89% |
| Área total reportada (µm²) | 12.723,950 | 13.145,605 | +3,31% |
| Potência estimada (mW) | 3,42829 | 3,37975 | −1,42% |
| Folga crítica (ps) | +7,2 | +0,7 | −6,5 ps |
| Incerteza de setup (ps) | 0 | 200 | +200 ps |

Os delays máximos de interface são os mesmos (entrada 0,5 ns e saída 0,2 ns), mas a atual tem incerteza de setup adicional e exclui o reset assíncrono dos delays síncronos. A síntese 2 aplicava os delays sem separar `-max`/`-min`, incluindo `presetn_i`. Portanto, o fechamento de setup atual foi obtido sob uma margem de clock mais exigente, mas isso não estabelece uma comparação idêntica de restrições ou de hold.

O pior caminho da síntese 2 era interno à redução modular: `t_reg[0]/CK → t_reg[63]/D`, atraso de dados de 3,931 ns e setup de 62 ps. O pior caminho atual está no multiplicador: `p_reg[1]/CK → p_reg[58]/D`, atraso de 3,659 ns e setup de 140 ps. As origens e destinos são diferentes; a diferença de atrasos não deve ser apresentada como aceleração do mesmo caminho.

## Comparação com a mesma v2 a 100 MHz: síntese 7

| Métrica | V2 a 100 MHz | V2 atual a 250 MHz | Variação |
|---|---:|---:|---:|
| Células | 2.501 | 2.734 | +9,32% |
| Área de células (µm²) | 9.182,016 | 9.584,208 | +4,38% |
| Área total reportada (µm²) | 12.503,084 | 13.145,605 | +5,14% |
| Potência estimada (mW) | 1,30958 | 3,37975 | +158,08% |

As duas execuções têm **705 células sequenciais**. As combinacionais aumentaram de **1.796 para 2.029**. O alvo de frequência sobe 2,5 vezes; o Genus altera o mapeamento para atendê-lo. A potência estimada aumenta aproximadamente 2,58 vezes, enquanto a área de células cresce 4,38%. Essa comparação envolve também a mudança dos delays de interface de 2/2 ns para 0,5/0,2 ns.

A perda da folga de 2,5676 ns para 0,0007 ns acompanha o alvo mais exigente; isoladamente, ela não significa piora do RTL. Sob as condições atuais, os relatórios demonstram fechamento de setup a 250 MHz, enquanto a síntese 7 tinha sido otimizada para 100 MHz.

## Distribuição dos 50 caminhos críticos

| Destino | Síntese 2: somente 20 disponíveis | Síntese 7: 50 caminhos | Atual: 50 caminhos |
|---|---:|---:|---:|
| Multiplicador | 6 | 1 | 11 |
| Redução modular | 14 | 0 | 15 |
| Banco EXP | 0 | 5 | 24 |
| Banco MSG | 0 | 32 | 0 |
| Banco MOD | 0 | 10 | 0 |
| Saída PRDATA | 0 | 1 | 0 |
| Saída PSLVERR | 0 | 1 | 0 |

Na atual, os seis primeiros caminhos são do multiplicador; quatro deles têm menos de 10 ps de folga no relatório arredondado. O primeiro caminho da redução modular está na posição 7, com folga de 96 ps, partindo do registrador de estado para `n_reg[29]`. O primeiro caminho APB aparece na posição 27, até o banco EXP, com folga de 222 ps.

Nenhum caminho de saída APB aparece entre os 100 reportados atualmente. Isso mostra que as saídas deixaram de dominar a lista nas novas condições; o arquivo não permite determinar a pior folga exata dessas saídas. Parte da mudança é consequência dos delays externos menores e da nova otimização, não apenas do RTL.

### Dez primeiros caminhos atuais

| Posição | Origem | Destino | Atraso de dados (ns) | Setup (ns) | Folga (ps) |
|---:|---|---|---:|---:|---:|
| 1 | `(R) MULT.p[1]/CK` | `(R) MULT.p[58]/D` | 3,659 | 0,140 | 1 |
| 2 | `(R) MULT.p[1]/CK` | `(R) MULT.p[60]/D` | 3,659 | 0,140 | 1 |
| 3 | `(R) MULT.p[1]/CK` | `(R) MULT.p[61]/D` | 3,657 | 0,140 | 3 |
| 4 | `(R) MULT.p[1]/CK` | `(R) MULT.p[56]/D` | 3,698 | 0,099 | 3 |
| 5 | `(R) MULT.p[1]/CK` | `(R) MULT.p[62]/D` | 3,660 | 0,122 | 17 |
| 6 | `(R) MULT.p[1]/CK` | `(R) MULT.p[57]/D` | 3,669 | 0,111 | 20 |
| 7 | `(R) MOD.state[1]/CK` | `(R) MOD.n[29]/D` | 3,569 | 0,135 | 96 |
| 8 | `(R) MOD.state[1]/CK` | `(R) MOD.n[17]/D` | 3,569 | 0,135 | 96 |
| 9 | `(R) MOD.state[1]/CK` | `(R) MOD.n[19]/D` | 3,569 | 0,135 | 96 |
| 10 | `(R) MOD.state[1]/CK` | `(R) MOD.n[25]/D` | 3,569 | 0,135 | 96 |

O `timing_max.rpt` arredonda a ps; por isso o Path 1 aparece com 1 ps, enquanto o QoR registra 0,7 ps. O cálculo arredondado desse caminho é: `4,000 − 0,200 − 0,140 − 3,659 = 0,001 ns`.

## Atual em relação a todas as anteriores

| Referência | Δ células | Δ área de células | Δ área total reportada | Δ potência estimada | Diferença de cenário |
|---|---:|---:|---:|---:|---|
| Síntese 1 | +24,27% | +10,99% | +12,69% | +158,35% | 100 MHz, sem incerteza; delays de interface diferentes. |
| Síntese 2 | +1,18% | +4,89% | +3,31% | −1,42% | 250 MHz, mas sem a incerteza de 200 ps da atual. |
| Síntese 3 | +4,39% | +6,08% | +5,02% | +19,72% | 200 MHz, sem incerteza. |
| Síntese 4 | +4,31% | +5,97% | +4,91% | +19,74% | 200 MHz, sem incerteza. |
| Síntese 5 | +32,53% | +16,83% | +16,41% | +88,06% | 100 MHz e corner fast, 1,32 V / 0 °C. |
| Síntese 6 | +24,27% | +10,99% | +12,69% | +158,35% | 100 MHz, input/output de 2 ns. |
| Síntese 7 | +9,32% | +4,38% | +5,14% | +158,08% | Mesma v2, mas 100 MHz e input/output de 2 ns. |

Variações percentuais = (atual/anterior − 1) × 100. Resultados em clocks/corners distintos descrevem cenários diferentes e não isolam a eficiência de uma versão do RTL.

## Conclusão e limites

**A v2 atingiu o alvo de setup de 250 MHz nesta síntese typical, com custo maior de área.** Frente à antiga execução também a 250 MHz, oferece potência estimada ligeiramente menor e atende à incerteza adicional de 200 ps. A folga residual de 0,7 ps é muito pequena; estes arquivos não demonstram fechamento pós-CTS/pós-roteamento, hold ou outros corners.

O próximo bloco a investigar para ganhar margem é o multiplicador. Para atribuir ganhos exclusivamente ao RTL, seria necessário comparar as versões com exatamente o mesmo SDC e condições de biblioteca. Essa nova execução não foi realizada aqui.

O `check_design.rpt` atual confirma zero referências não resolvidas, zero módulos vazios e zero pinos/portas sem driver ou com múltiplos drivers. A contagem de duas portas sem carga e dez células físicas sem libcell permanece como nas sínteses typical anteriores.

[Dados completos em CSV](comparacao_sinteses_250mhz.csv).
[Relatório de temporização atual](genus/timing_max.rpt).
[Log da execução atual](../../logs/amba_3_apb_rsa_apb_top/genus/amba_3_apb_rsa_apb_top_2026-10-23_16-20-34.log).
[Análise histórica da v2 a 100 MHz](comparacao_sinteses.md).
