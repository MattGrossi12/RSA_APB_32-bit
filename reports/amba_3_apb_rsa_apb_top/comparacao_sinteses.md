# Comparação das sete sínteses do topo APB RSA

> Histórico: neste documento, “atual” refere-se à RSA v2 a **100 MHz**, preservada em `genus_synth7/`. A execução mais recente, a 250 MHz, está na [nova comparação](comparacao_sinteses_250mhz.md).

Comparação dos relatórios existentes, realizada em 23/10/2026. Nenhuma nova síntese foi executada.
Topo: `amba_3_apb_rsa_apb_top`. A síntese atual está em `genus_synth7/`; as seis anteriores estão em `genus_synth1/` a `genus_synth6/`.

A atual melhora a folga crítica em **0,8522 ns** em relação à síntese 6, com **6,33% mais área de células**, **7,18% mais área total reportada** e **0,10% mais potência estimada**. A síntese 6 é a referência mais direta: mesmo corner, período, incerteza e SDC.

## Resultados reportados

| Síntese | Corner | Clock (ns / MHz) | Incerteza (ns) | Células | Área de células (µm²) | Área total reportada (µm²) | Folga crítica (ns) | Potência (mW) |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| [Síntese 1](genus_synth1/qor.rpt) | typical | 10,0 / 100 | 0,0 | 2200 | 8.635,500 | 11.665,056 | +1,9154 | 1,30821 |
| [Síntese 2](genus_synth2/qor.rpt) | typical | 4,0 / 250 | 0,0 | 2702 | 9.137,351 | 12.723,950 | +0,0072 | 3,42829 |
| [Síntese 3](genus_synth3/qor.rpt) | typical | 5,0 / 200 | 0,0 | 2619 | 9.035,024 | 12.517,148 | +0,0039 | 2,82316 |
| [Síntese 4](genus_synth4/qor.rpt) | typical | 5,0 / 200 | 0,0 | 2621 | 9.044,258 | 12.530,107 | +0,0068 | 2,82265 |
| [Síntese 5](genus_synth5/qor.rpt) | fast | 10,0 / 100 | 0,2 | 2063 | 8.203,212 | 11.292,636 | +4,3212 | 1,79719 |
| [Síntese 6](genus_synth6/qor.rpt) | typical | 10,0 / 100 | 0,2 | 2200 | 8.635,500 | 11.665,056 | +1,7154 | 1,30821 |
| [Atual (RSA v2)](genus_synth7/qor.rpt) | typical | 10,0 / 100 | 0,2 | 2501 | 9.182,016 | 12.503,084 | +2,5676 | 1,30958 |

Todas as execuções reportam TNS = 0 e zero caminhos com violação de setup. Isso vale para as condições analisadas; os arquivos comparados são de temporização máxima e não estabelecem fechamento de hold ou pós-roteamento.

A área total é a soma de área de células e área estimada de redes, conforme `area.rpt`/`qor.rpt`; não é a área de core ou die. O modo é `physical library`. As dimensões em micrômetros da LEF confirmam a unidade de área: ADDFX1 tem SIZE 3 BY 1.71 e área reportada de 5,130 µm².

## Atual versus cada síntese anterior

Variação = (atual / anterior − 1) × 100. A diferença de folga é atual − anterior. Valores de potência, área e folga de cenários diferentes descrevem os resultados, mas não isolam o efeito do RTL.

| Referência | Δ células | Δ área de células | Δ área total reportada | Δ potência | Δ folga (ns) | Condição de comparação |
|---|---:|---:|---:|---:|---:|---|
| Síntese 1 | +13,68% | +6,33% | +7,18% | +0,10% | +0,6522 | Mesmo período/corner; síntese 1 sem incerteza de setup. |
| Síntese 2 | −7,44% | +0,49% | −1,74% | −61,80% | +2,5604 | Síntese 2 otimizada para 4 ns, sem incerteza. |
| Síntese 3 | −4,51% | +1,63% | −0,11% | −53,61% | +2,5637 | Síntese 3 otimizada para 5 ns, sem incerteza. |
| Síntese 4 | −4,58% | +1,52% | −0,22% | −53,60% | +2,5608 | Síntese 4 otimizada para 5 ns, sem incerteza. |
| Síntese 5 | +21,23% | +11,93% | +10,72% | −27,13% | −1,7536 | Síntese 5 no corner fast, contra typical da atual. |
| Síntese 6 | +13,68% | +6,33% | +7,18% | +0,10% | +0,8522 | Mesmo período, corner, incerteza e SDC. |

## O que mudou em relação à síntese 6

- Folga crítica: **1,7154 → 2,5676 ns**, ganho de **0,8522 ns** (49,68% sobre a folga anterior). Esse percentual representa margem de temporização, não aumento de frequência ou throughput.
- Células: **2.200 → 2.501** (+301; +13,68%). As sete sínteses têm **705 células sequenciais**. As combinacionais passam de **1.495 para 1.796** (+20,13%).
- Área de células: **8.635,500 → 9.182,016 µm²** (+546,516 µm²; +6,33%). A atual tem a maior área de células entre as sete.
- A área sequencial também mudou, apesar da contagem constante: **5.345,802 → 5.687,460 µm²**. Portanto, o custo de área não vem só das células combinacionais adicionais; o mapeamento dos registradores também mudou.
- Área total reportada: **11.665,056 → 12.503,084 µm²** (+7,18%).
- Potência total estimada: **1,30821 → 1,30958 mW** (+0,00137 mW; aproximadamente +0,10%). Os dois logs identificam análise **vectorless**; esses valores não são medição de consumo com a atividade da bancada UVM.

A comparação dos SDCs exportados encontrou somente a diferença no comentário com a data de geração:

- [SDC da síntese 6](../../ps_files/rsa_apb_top/sdc/synth_amba_3_apb_rsa_apb_top_2026-10-22_14-47-43.sdc)
- [SDC atual](../../ps_files/rsa_apb_top/sdc/synth_amba_3_apb_rsa_apb_top_2026-10-23_15-49-54.sdc)

## Caminho crítico

Na [síntese 6](genus_synth6/timing_max.rpt), o caminho crítico é interno ao módulo de redução modular: `t_reg[0] → t_reg[62]`, com atraso de dados de **8,014 ns** e folga de **1,715 ns** (valor arredondado no relatório de caminhos).

Na [atual](genus_synth7/timing_max.rpt), o caminho crítico passou para **`paddr_i[8] → pslverr_o`**, na lógica APB. O atraso de dados é **3,232 ns**; o cálculo inclui **2 ns de input delay**, **2 ns de output delay** e **0,2 ns de incerteza**. Por isso, não se deve comparar diretamente 8,014 e 3,232 ns como se fossem o mesmo caminho.

O pior caminho entre registradores presente nos 100 caminhos atuais é o **Path 35**, no multiplicador: `p_reg[0] → p_reg[63]`, atraso de **6,395 ns**, setup de **0,119 ns** e folga de **3,286 ns**. A redução modular não aparece entre os 100 caminhos reportados; o arquivo não permite determinar seu pior atraso exato.

O log atual confirma a leitura dos cinco arquivos de `src/rsa32/v2`. A mudança de gargalo é consistente com a alteração da lógica aritmética, mas estes relatórios, isoladamente, não atribuem todo o ganho a um único somador ou alteração de RTL.

## Como interpretar as outras execuções

- Sínteses **1 e 6** têm as mesmas áreas, contagens de células e potência reportada. A folga da 6 é 0,200 ns menor, correspondente à incerteza de setup adicionada. Seus relatórios não mostram melhoria de PPA entre elas.
- Síntese **2** atende a **250 MHz** com **7,2 ps de folga**, sob suas restrições. Ela demonstra fechamento para um alvo mais exigente; a atual foi sintetizada a **100 MHz**. A maior folga atual não comprova que a v2 supera a síntese 2 em frequência máxima.
- Sínteses **3 e 4** atendem a **200 MHz** com **3,9 e 6,8 ps**, respectivamente. Têm resultados próximos e restrições mais exigentes do que a atual.
- Síntese **5** tem a menor área e a maior folga reportadas, mas usa **fast.lib**, com PVT nominal de **1,32 V / 0 °C**; a atual usa **typical.lib**, **1,20 V / 25 °C**. O corner diferente impede tratá-la como evidência de um RTL superior.

Para avaliar o potencial de frequência da v2 frente às sínteses 2–4, seria necessário sintetizar as versões com o mesmo corner, período, incerteza, atrasos de entrada/saída, carga e esforço de otimização. Essa execução adicional não foi realizada nesta comparação.

## Verificações e rastreabilidade

Os sete `check_design.rpt` apresentam zero referências não resolvidas, zero pinos/portas sem driver e zero múltiplos drivers. Persistem duas portas sem carga e células físicas sem libcell (10 nos casos typical, 11 no fast); essas contagens não são regressões introduzidas pela síntese atual.

Fontes de cada linha: `area.rpt`, `qor.rpt`, `timing_max.rpt`, `power.rpt`, `clocks.rpt`, `gates.rpt` e `check_design.rpt`, na pasta indicada. Os valores de área e contagem foram conferidos entre os relatórios de área e QoR. Tempos originais em ps foram convertidos para ns; potência em W foi convertida para mW.

As datas abaixo são as registradas dentro de `qor.rpt`, e não as datas de cópia das pastas:

- Síntese 1: `Oct 20 2026  10:01:22 am`.
- Síntese 2: `Oct 22 2026  01:43:23 pm`.
- Síntese 3: `Oct 22 2026  02:03:34 pm`.
- Síntese 4: `Oct 22 2026  02:07:01 pm`.
- Síntese 5: `Oct 22 2026  02:39:11 pm`.
- Síntese 6: `Oct 22 2026  02:48:22 pm`.
- Atual (RSA v2): `Oct 23 2026  03:50:33 pm`.

[Dados completos em CSV](comparacao_sinteses.csv).
[Log da síntese atual](../../logs/amba_3_apb_rsa_apb_top/genus/amba_3_apb_rsa_apb_top_2026-10-23_15-49-54.log).
