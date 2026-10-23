# Slack e datapath de todas as sínteses

Relatórios consultados em 23/10/2026. A execução atual é de 23/10 às 16:21. Nenhuma nova síntese foi executada.

O datapath abaixo é o campo `Data Path` do caminho de menor folga global, e inclui o atraso do clock ao Q quando o caminho parte de um registrador. O slack global vem do QoR, que tem maior precisão do que `timing_max.rpt`. As colunas não representam necessariamente o mesmo circuito entre execuções.

| Síntese | Período (ns) | Corner | Datapath crítico (ns) | Slack global (ps) | Bloco do caminho crítico |
|---|---:|---|---:|---:|---|
| [Síntese 1](genus_synth1/timing_max.rpt) | 10,0 | typical | 8,014 | +1915,4 | Redução modular |
| [Síntese 2](genus_synth2/timing_max.rpt) | 4,0 | typical | 3,931 | +7,2 | Redução modular |
| [Síntese 3](genus_synth3/timing_max.rpt) | 5,0 | typical | 4,934 | +3,9 | Redução modular |
| [Síntese 4](genus_synth4/timing_max.rpt) | 5,0 | typical | 4,931 | +6,8 | Redução modular |
| [Síntese 5](genus_synth5/timing_max.rpt) | 10,0 | fast | 5,439 | +4321,2 | Redução modular |
| [Síntese 6](genus_synth6/timing_max.rpt) | 10,0 | typical | 8,014 | +1715,4 | Redução modular |
| [Síntese 7](genus_synth7/timing_max.rpt) | 10,0 | typical | 3,232 | +2567,6 | APB: endereço → PSLVERR |
| [Atual — v2 a 250 MHz](genus/timing_max.rpt) | 4,0 | typical | 3,659 | +0,7 | Multiplicador |

## O que os resultados mostram

- **Sínteses 1 e 6:** datapath idêntico de 8,014 ns. O slack da 6 é 200 ps menor, exatamente a incerteza de setup adicionada. A redução de slack não representa aumento de atraso de dados.
- **Sínteses 3 e 4:** praticamente equivalentes: 4,934 e 4,931 ns de datapath; a 4 é cerca de 3 ps mais rápida no caminho crítico reportado.
- **Síntese 5:** usa corner fast; os 5,439 ns de datapath e o slack maior não podem ser atribuídos somente ao RTL em comparação aos casos typical.
- **Síntese 7:** os 3,232 ns pertencem a um caminho combinacional de entrada até saída APB. O orçamento ainda inclui 2 ns de input delay, 2 ns de output delay e 0,2 ns de incerteza. Seu pior caminho reg→reg relatado tem datapath de **6,395 ns**, no multiplicador, e slack de 3,286 ns.
- **Atual versus síntese 2:** ambas têm período de 4 ns. O datapath do caminho crítico global passa de **3,931 para 3,659 ns**, redução numérica de **272 ps (6,92%)**, mas o bloco crítico muda de redução modular para multiplicador. Não são os mesmos pontos de origem e destino. O setup passa de 62 para 140 ps e a incerteza de 0 para 200 ps; por isso o slack cai de **7,2 para 0,7 ps**, apesar do datapath menor.

A atual atende ao setup de 250 MHz no cenário typical e nas restrições usadas, com pequena folga residual. O valor menor do datapath crítico é um resultado favorável do mapeamento atual; a comparação não isola o efeito do RTL porque as restrições e os caminhos diferem.

## Datapath do pior caminho entre registradores reportado

Esta tabela destaca o caso da síntese 7, em que o pior caminho global não parte de um registrador. As folgas deste quadro vêm do relatório de caminhos e estão arredondadas a ps.

| Síntese | Posição no relatório | Datapath reg→reg (ns) | Slack reg→reg (ps) | Bloco |
|---|---:|---:|---:|---|
| Síntese 1 | 1 | 8,014 | +1915 | Redução modular |
| Síntese 2 | 1 | 3,931 | +7 | Redução modular |
| Síntese 3 | 1 | 4,934 | +4 | Redução modular |
| Síntese 4 | 1 | 4,931 | +7 | Redução modular |
| Síntese 5 | 1 | 5,439 | +4321 | Redução modular |
| Síntese 6 | 1 | 8,014 | +1715 | Redução modular |
| Síntese 7 | 35 | 6,395 | +3286 | Multiplicador |
| Atual — v2 a 250 MHz | 1 | 3,659 | +1 | Multiplicador |

## Por que menor datapath não garante maior slack

Nos caminhos reg→reg considerados, com latências ideais, a relação simplificada é:

```text
slack = período − incerteza − setup − datapath

Síntese 2: 4,000 − 0,000 − 0,062 − 3,931 = 0,007 ns
Atual:     4,000 − 0,200 − 0,140 − 3,659 = 0,001 ns
```

Essas contas usam os valores arredondados do relatório de caminhos. O QoR registra 7,2 ps e 0,7 ps, respectivamente. Nos caminhos entrada→saída, entram também os delays externos; na síntese 7: `10,000 − 2,000 − 2,000 − 0,200 − 3,232 = 2,568 ns`.

Atrasos menores e maior folga são desejáveis, mas precisam ser avaliados junto ao período, corner, setup, incerteza e tipo do caminho. Os relatórios são de temporização máxima e não comprovam fechamento de hold ou pós-roteamento.

[CSV com origens, destinos e orçamento de cada caminho](comparacao_slack_datapath.csv).
[Comparação completa da última síntese a 250 MHz](comparacao_sinteses_250mhz.md).
