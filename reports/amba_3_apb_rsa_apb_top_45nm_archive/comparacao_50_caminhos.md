# Comparação dos 50 caminhos críticos: síntese 6 e atual

> Histórico: neste documento, “atual” refere-se à RSA v2 a **100 MHz**, preservada em `genus_synth7/`. A execução mais recente, a 250 MHz, está na [nova comparação](comparacao_sinteses_250mhz.md).

Análise em 23/10/2026 dos 50 primeiros caminhos de menor folga de cada `timing_max.rpt`. As duas execuções mais recentes são a síntese 6 (22/10, 14:48) e a atual com RSA v2 (23/10, 15:50). Nenhuma nova síntese foi executada.

A comparação principal usa `genus_synth6/` e `genus_synth7/`: ambas com Genus 22.18-s061_1, corner typical, clock de 10 ns, incerteza de setup de 0,2 ns e SDCs exportados iguais, desconsiderando comentários. O histórico das demais sínteses aparece ao final.

**Resultado:** o pior slack melhorou e o gargalo saiu da redução modular para a lógica APB. O multiplicador não mostrou ganho relevante no caminho que pôde ser associado diretamente. As mesmas saídas APB passaram a apresentar piores margens. Portanto, a melhora global não se distribuiu por todos os caminhos.

## Distribuição dos 50 caminhos

| Destino / bloco | Síntese 6 | Atual |
|---|---:|---:|
| Redução modular | 21 | 0 |
| Multiplicador | 11 | 1 |
| Saída PRDATA | 18 | 1 |
| Saída PSLVERR | 0 | 1 |
| Banco MSG | 0 | 32 |
| Banco EXP | 0 | 5 |
| Banco MOD | 0 | 10 |
| **Total** | **50** | **50** |

| Tipo de caminho | Síntese 6 | Atual |
|---|---:|---:|
| Reg→Reg | 32 | 1 |
| Entrada→Reg | 0 | 47 |
| Entrada→Saída | 18 | 2 |

Na atual, **49/50 caminhos partem de `paddr_i[8]`**. A exceção é o Path 35, entre registradores do multiplicador. Os 32 bits de MSG ocupam os Paths 3–34, todos com 3,178 ns de folga e 4,557 ns de atraso de dados.

## Folgas do conjunto

| Estatística dos 50 caminhos | Síntese 6 (ns) | Atual (ns) | Δ atual − anterior (ns) |
|---|---:|---:|---:|
| Mínima | 1,7150 | 2,5680 | +0,8530 |
| Mediana | 3,8255 | 3,1780 | −0,6475 |
| Média | 3,5324 | 3,2062 | −0,3262 |
| Máxima entre os 50 | 4,1320 | 3,3430 | −0,7890 |

Os caminhos têm valores arredondados a ps. O QoR, mais preciso para o pior slack, registra **1,7154 → 2,5676 ns**, ganho de **0,8522 ns**. A média dos 50 cai aproximadamente 0,326 ns; a mediana cai 0,6475 ns. Essas estatísticas descrevem dois conjuntos de caminhos diferentes e não medem a variação dos mesmos 50 circuitos.

Os 50 caminhos das duas execuções têm folga positiva. Maior folga significa maior margem sob as restrições presentes; isso não equivale diretamente a frequência máxima ou throughput.

## Comparação de caminhos identificáveis

Os números de ranking não identificam circuitos: o Path 1 de uma execução não corresponde necessariamente ao Path 1 da outra. Procurando nos 100 caminhos disponíveis, os pares abaixo têm os mesmos destinos; somente o multiplicador também conserva a mesma origem e polaridade.

| Destino | Ranking anterior → atual | Origem anterior → atual | Atraso de dados anterior → atual (ns) | Folga anterior → atual (ns) | Δ folga (ns) |
|---|---|---|---:|---:|---:|
| `(F) pslverr_o` | 67 → 1 | `(F) paddr_i[5]` → `(F) paddr_i[8]` | 1,562 → 3,232 | 4,238 → 2,568 | −1,670 |
| `(F) prdata_o[0]` | 66 → 2 | `(F) paddr_i[5]` → `(F) paddr_i[8]` | 1,597 → 3,174 | 4,203 → 2,626 | −1,577 |
| `(R) MULT.p[63]/D` | 14 → 35 | `(R) MULT.p[0]/CK` → `(R) MULT.p[0]/CK` | 6,406 → 6,395 | 3,291 → 3,286 | −0,005 |

- **PSLVERR:** o pior caminho reportado até a saída perde **1,670 ns** de folga; seu atraso cresce de 1,562 para 3,232 ns. A origem muda de `paddr_i[5]` para `paddr_i[8]`.
- **PRDATA[0]:** o pior caminho reportado até a saída perde **1,577 ns** de folga; atraso de 1,597 para 3,174 ns, também com mudança de origem. Esses caminhos de saída estavam nas posições 67 e 66 da síntese 6; foram consultados além dos 50 para permitir a associação por destino.
- **Multiplicador, `p_reg[0]/CK → p_reg[63]/D`:** atraso de 6,406 para 6,395 ns, melhora de apenas **11 ps**. O setup aumenta de 103 para 119 ps; a folga final cai **5 ps**, de 3,291 para 3,286 ns. Seu ranking muda de 14 para 35 porque o restante do conjunto mudou.
- **Redução modular:** de 21 caminhos entre os 50 anteriores para nenhum dos 100 atuais. Isso mostra que ela deixou de dominar o ranking reportado. Seu novo pior atraso exato não está disponível nesses arquivos, e não foi estimado por comparação entre posições diferentes.

## Onde se concentram os atrasos atuais

O Path 1 passa por `g87961__2398/Y` (AND3XL), com fanout 34, carga 96,1 fF, transição de 1,343 ns e atraso de 0,714 ns. A célula seguinte, `g90097/Y` (NOR3BX1), acrescenta 0,559 ns. As duas somam **1,273 ns** dos 3,232 ns do caminho.

O Path 3, representativo dos 32 caminhos até MSG, compartilha esse trecho e ainda passa por `g87693__90185/Y` (NOR2X1): fanout 32, carga 103,7 fF, transição de 1,650 ns e atraso de **0,927 ns**. Esses valores apontam a lógica de decodificação/controle APB e suas cargas como prioridade para investigar uma próxima otimização. São observações dos caminhos de setup, não um relatório de violação de transição máxima.

O caminho associado do multiplicador atravessa **30 ADDFX1 e 32 ADDHX1** em ambas as versões. O mapeamento ainda apresenta uma longa cadeia aritmética nesse caminho, consistente com a ausência de redução relevante de atraso observada.

## Os 50 caminhos de cada execução

Abreviações: `MOD.` = redução modular; `MULT.` = multiplicador; `REGBANK.` = banco APB. `(R)` e `(F)` preservam as polaridades do relatório. `/CK` e `/D` identificam os pinos. Atraso de dados e folga estão em ns; os nomes completos e as linhas de origem estão no CSV.

### Síntese 6

[Relatório de origem](genus_synth6/timing_max.rpt).

| Posição | Origem | Destino | Atraso de dados (ns) | Folga (ns) |
|---:|---|---|---:|---:|
| 1 | `(R) MOD.t[0]/CK` | `(R) MOD.t[62]/D` | 8,014 | +1,715 |
| 2 | `(R) MOD.t[0]/CK` | `(R) MOD.t[63]/D` | 7,924 | +1,805 |
| 3 | `(R) MOD.t[0]/CK` | `(R) MOD.t[61]/D` | 7,759 | +1,971 |
| 4 | `(R) MOD.t[0]/CK` | `(R) MOD.t[60]/D` | 7,638 | +2,091 |
| 5 | `(R) MOD.t[0]/CK` | `(R) MOD.t[59]/D` | 7,517 | +2,212 |
| 6 | `(R) MOD.t[0]/CK` | `(R) MOD.t[58]/D` | 7,396 | +2,333 |
| 7 | `(R) MOD.t[0]/CK` | `(R) MOD.t[57]/D` | 7,276 | +2,453 |
| 8 | `(R) MOD.t[0]/CK` | `(R) MOD.t[56]/D` | 7,155 | +2,574 |
| 9 | `(R) MOD.t[0]/CK` | `(R) MOD.t[55]/D` | 7,034 | +2,695 |
| 10 | `(R) MOD.t[0]/CK` | `(R) MOD.t[54]/D` | 6,914 | +2,816 |
| 11 | `(R) MOD.t[0]/CK` | `(R) MOD.t[53]/D` | 6,793 | +2,936 |
| 12 | `(R) MOD.t[0]/CK` | `(R) MOD.t[52]/D` | 6,672 | +3,057 |
| 13 | `(R) MOD.t[0]/CK` | `(R) MOD.t[51]/D` | 6,552 | +3,178 |
| 14 | `(R) MULT.p[0]/CK` | `(R) MULT.p[63]/D` | 6,406 | +3,291 |
| 15 | `(R) MOD.t[0]/CK` | `(R) MOD.t[50]/D` | 6,431 | +3,298 |
| 16 | `(R) MULT.p[0]/CK` | `(R) MULT.p[62]/D` | 6,321 | +3,376 |
| 17 | `(R) MOD.t[0]/CK` | `(R) MOD.t[49]/D` | 6,310 | +3,419 |
| 18 | `(R) MULT.p[0]/CK` | `(R) MULT.p[61]/D` | 6,239 | +3,458 |
| 19 | `(R) MULT.p[0]/CK` | `(R) MULT.p[60]/D` | 6,157 | +3,540 |
| 20 | `(R) MOD.t[0]/CK` | `(R) MOD.t[48]/D` | 6,190 | +3,540 |
| 21 | `(R) MULT.p[0]/CK` | `(R) MULT.p[59]/D` | 6,076 | +3,621 |
| 22 | `(R) MOD.t[0]/CK` | `(R) MOD.t[47]/D` | 6,069 | +3,660 |
| 23 | `(R) MULT.p[0]/CK` | `(R) MULT.p[58]/D` | 5,994 | +3,703 |
| 24 | `(R) MOD.t[0]/CK` | `(R) MOD.t[46]/D` | 5,948 | +3,781 |
| 25 | `(R) MULT.p[0]/CK` | `(R) MULT.p[57]/D` | 5,912 | +3,785 |
| 26 | `(R) MULT.p[0]/CK` | `(R) MULT.p[56]/D` | 5,830 | +3,866 |
| 27 | `(R) MOD.t[0]/CK` | `(R) MOD.t[45]/D` | 5,827 | +3,902 |
| 28 | `(R) MULT.p[0]/CK` | `(R) MULT.p[55]/D` | 5,749 | +3,948 |
| 29 | `(R) MOD.t[0]/CK` | `(R) MOD.t[44]/D` | 5,707 | +4,022 |
| 30 | `(R) MULT.p[0]/CK` | `(R) MULT.p[54]/D` | 5,667 | +4,030 |
| 31 | `(R) MULT.p[0]/CK` | `(R) MULT.p[53]/D` | 5,585 | +4,112 |
| 32 | `(F) paddr_i[5]` | `(R) prdata_o[5]` | 1,674 | +4,126 |
| 33 | `(F) paddr_i[5]` | `(R) prdata_o[6]` | 1,674 | +4,126 |
| 34 | `(F) paddr_i[5]` | `(R) prdata_o[7]` | 1,674 | +4,126 |
| 35 | `(F) paddr_i[5]` | `(R) prdata_o[8]` | 1,674 | +4,126 |
| 36 | `(F) paddr_i[5]` | `(R) prdata_o[13]` | 1,674 | +4,126 |
| 37 | `(F) paddr_i[5]` | `(R) prdata_o[15]` | 1,674 | +4,126 |
| 38 | `(F) paddr_i[5]` | `(R) prdata_o[19]` | 1,674 | +4,126 |
| 39 | `(F) paddr_i[5]` | `(R) prdata_o[9]` | 1,672 | +4,128 |
| 40 | `(F) paddr_i[5]` | `(R) prdata_o[16]` | 1,672 | +4,128 |
| 41 | `(F) paddr_i[5]` | `(R) prdata_o[17]` | 1,672 | +4,128 |
| 42 | `(F) paddr_i[5]` | `(R) prdata_o[20]` | 1,672 | +4,128 |
| 43 | `(F) paddr_i[5]` | `(R) prdata_o[22]` | 1,672 | +4,128 |
| 44 | `(F) paddr_i[5]` | `(R) prdata_o[25]` | 1,672 | +4,128 |
| 45 | `(F) paddr_i[5]` | `(R) prdata_o[28]` | 1,672 | +4,128 |
| 46 | `(F) paddr_i[5]` | `(R) prdata_o[30]` | 1,672 | +4,128 |
| 47 | `(R) MOD.t[0]/CK` | `(R) MOD.t[42]/D` | 5,600 | +4,129 |
| 48 | `(F) paddr_i[5]` | `(R) prdata_o[2]` | 1,668 | +4,132 |
| 49 | `(F) paddr_i[5]` | `(R) prdata_o[3]` | 1,668 | +4,132 |
| 50 | `(F) paddr_i[5]` | `(R) prdata_o[4]` | 1,668 | +4,132 |

### Atual (v2)

[Relatório de origem](genus_synth7/timing_max.rpt).

| Posição | Origem | Destino | Atraso de dados (ns) | Folga (ns) |
|---:|---|---|---:|---:|
| 1 | `(F) paddr_i[8]` | `(F) pslverr_o` | 3,232 | +2,568 |
| 2 | `(F) paddr_i[8]` | `(F) prdata_o[0]` | 3,174 | +2,626 |
| 3 | `(F) paddr_i[8]` | `(R) REGBANK.msg[6]/D` | 4,557 | +3,178 |
| 4 | `(F) paddr_i[8]` | `(R) REGBANK.msg[26]/D` | 4,557 | +3,178 |
| 5 | `(F) paddr_i[8]` | `(R) REGBANK.msg[30]/D` | 4,557 | +3,178 |
| 6 | `(F) paddr_i[8]` | `(R) REGBANK.msg[0]/D` | 4,557 | +3,178 |
| 7 | `(F) paddr_i[8]` | `(R) REGBANK.msg[1]/D` | 4,557 | +3,178 |
| 8 | `(F) paddr_i[8]` | `(R) REGBANK.msg[2]/D` | 4,557 | +3,178 |
| 9 | `(F) paddr_i[8]` | `(R) REGBANK.msg[11]/D` | 4,557 | +3,178 |
| 10 | `(F) paddr_i[8]` | `(R) REGBANK.msg[5]/D` | 4,557 | +3,178 |
| 11 | `(F) paddr_i[8]` | `(R) REGBANK.msg[4]/D` | 4,557 | +3,178 |
| 12 | `(F) paddr_i[8]` | `(R) REGBANK.msg[3]/D` | 4,557 | +3,178 |
| 13 | `(F) paddr_i[8]` | `(R) REGBANK.msg[7]/D` | 4,557 | +3,178 |
| 14 | `(F) paddr_i[8]` | `(R) REGBANK.msg[8]/D` | 4,557 | +3,178 |
| 15 | `(F) paddr_i[8]` | `(R) REGBANK.msg[10]/D` | 4,557 | +3,178 |
| 16 | `(F) paddr_i[8]` | `(R) REGBANK.msg[12]/D` | 4,557 | +3,178 |
| 17 | `(F) paddr_i[8]` | `(R) REGBANK.msg[17]/D` | 4,557 | +3,178 |
| 18 | `(F) paddr_i[8]` | `(R) REGBANK.msg[13]/D` | 4,557 | +3,178 |
| 19 | `(F) paddr_i[8]` | `(R) REGBANK.msg[16]/D` | 4,557 | +3,178 |
| 20 | `(F) paddr_i[8]` | `(R) REGBANK.msg[14]/D` | 4,557 | +3,178 |
| 21 | `(F) paddr_i[8]` | `(R) REGBANK.msg[15]/D` | 4,557 | +3,178 |
| 22 | `(F) paddr_i[8]` | `(R) REGBANK.msg[9]/D` | 4,557 | +3,178 |
| 23 | `(F) paddr_i[8]` | `(R) REGBANK.msg[29]/D` | 4,557 | +3,178 |
| 24 | `(F) paddr_i[8]` | `(R) REGBANK.msg[28]/D` | 4,557 | +3,178 |
| 25 | `(F) paddr_i[8]` | `(R) REGBANK.msg[23]/D` | 4,557 | +3,178 |
| 26 | `(F) paddr_i[8]` | `(R) REGBANK.msg[27]/D` | 4,557 | +3,178 |
| 27 | `(F) paddr_i[8]` | `(R) REGBANK.msg[25]/D` | 4,557 | +3,178 |
| 28 | `(F) paddr_i[8]` | `(R) REGBANK.msg[24]/D` | 4,557 | +3,178 |
| 29 | `(F) paddr_i[8]` | `(R) REGBANK.msg[22]/D` | 4,557 | +3,178 |
| 30 | `(F) paddr_i[8]` | `(R) REGBANK.msg[21]/D` | 4,557 | +3,178 |
| 31 | `(F) paddr_i[8]` | `(R) REGBANK.msg[19]/D` | 4,557 | +3,178 |
| 32 | `(F) paddr_i[8]` | `(R) REGBANK.msg[18]/D` | 4,557 | +3,178 |
| 33 | `(F) paddr_i[8]` | `(R) REGBANK.msg[20]/D` | 4,557 | +3,178 |
| 34 | `(F) paddr_i[8]` | `(R) REGBANK.msg[31]/D` | 4,557 | +3,178 |
| 35 | `(R) MULT.p[0]/CK` | `(R) MULT.p[63]/D` | 6,395 | +3,286 |
| 36 | `(F) paddr_i[8]` | `(F) REGBANK.mod[0]/D` | 4,430 | +3,332 |
| 37 | `(F) paddr_i[8]` | `(F) REGBANK.exp[6]/D` | 4,430 | +3,343 |
| 38 | `(F) paddr_i[8]` | `(F) REGBANK.exp[27]/D` | 4,430 | +3,343 |
| 39 | `(F) paddr_i[8]` | `(F) REGBANK.mod[5]/D` | 4,430 | +3,343 |
| 40 | `(F) paddr_i[8]` | `(F) REGBANK.mod[13]/D` | 4,430 | +3,343 |
| 41 | `(F) paddr_i[8]` | `(F) REGBANK.exp[21]/D` | 4,430 | +3,343 |
| 42 | `(F) paddr_i[8]` | `(F) REGBANK.mod[30]/D` | 4,430 | +3,343 |
| 43 | `(F) paddr_i[8]` | `(F) REGBANK.exp[15]/D` | 4,430 | +3,343 |
| 44 | `(F) paddr_i[8]` | `(F) REGBANK.mod[17]/D` | 4,430 | +3,343 |
| 45 | `(F) paddr_i[8]` | `(F) REGBANK.mod[22]/D` | 4,430 | +3,343 |
| 46 | `(F) paddr_i[8]` | `(F) REGBANK.mod[9]/D` | 4,430 | +3,343 |
| 47 | `(F) paddr_i[8]` | `(F) REGBANK.mod[26]/D` | 4,430 | +3,343 |
| 48 | `(F) paddr_i[8]` | `(F) REGBANK.mod[19]/D` | 4,430 | +3,343 |
| 49 | `(F) paddr_i[8]` | `(F) REGBANK.mod[12]/D` | 4,430 | +3,343 |
| 50 | `(F) paddr_i[8]` | `(F) REGBANK.exp[19]/D` | 4,430 | +3,343 |

## Contexto das outras sínteses

Consolidação dos primeiros 50 caminhos disponíveis. As sínteses 1 e 2 contêm somente 20 caminhos cada; não há dados suficientes para completar 50 sem gerar novos relatórios.

| Síntese | N analisado | Clock / corner | MOD | MULT | Saídas APB | Banco APB | Menor folga (ns) | Média das folgas (ns) |
|---|---:|---|---:|---:|---:|---:|---:|---:|
| Síntese 1 | 20 | 10 ns / typical | 16 | 4 | 0 | 0 | 1,915 | 2,9879 |
| Síntese 2 | 20 | 4 ns / typical | 14 | 6 | 0 | 0 | 0,007 | 0,2475 |
| Síntese 3 | 50 | 5 ns / typical | 29 | 21 | 0 | 0 | 0,004 | 0,6848 |
| Síntese 4 | 50 | 5 ns / typical | 28 | 22 | 0 | 0 | 0,007 | 0,6913 |
| Síntese 5 | 50 | 10 ns / fast | 14 | 1 | 33 | 2 | 4,321 | 4,7811 |
| Síntese 6 | 50 | 10 ns / typical | 21 | 11 | 18 | 0 | 1,715 | 3,5324 |
| Atual (v2) | 50 | 10 ns / typical | 0 | 1 | 2 | 47 | 2,568 | 3,2062 |

As sínteses 2–4 usam alvos de clock mais exigentes; a 5 usa corner fast. As sínteses 1–4 não têm a incerteza de setup de 0,2 ns usada em 5, 6 e na atual. Por isso, as folgas dessas linhas não isolam diferenças do RTL. A comparação principal com a síntese 6 mantém as restrições equivalentes.

[CSV dos caminhos analisados](comparacao_50_caminhos.csv): 290 linhas, sendo 50 de cada execução com relatório suficiente e 20 das sínteses 1 e 2. Filtre `folder` por `genus_synth6` e `genus_synth7` para obter os 100 caminhos da comparação principal.

[Comparação anterior de área, potência e QoR](comparacao_sinteses.md).
