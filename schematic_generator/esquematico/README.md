# Esquemáticos RTL do APB e RSA32

O Yosys elabora os fontes de `src/amba_3_apb/` e `src/rsa32/v2/`; o
`schem.mjs` transforma a netlist JSON em grafos SVG com layout do ELK.
A hierarquia é preservada: cada módulo elaborado tem uma folha, incluindo
os somadores Kogge–Stone. Operadores aritméticos continuam como blocos RTL.

A lista de fontes é a mesma usada pelo fluxo integrado de simulação.
`src/rsa32/v1/` e `src/amba_3_apb/legacy/` ficam fora da elaboração. As versões
v1 e v2 declaram módulos com os mesmos nomes e não devem ser lidas juntas.

## Requisitos e instalação

- Yosys no `PATH`, com suporte a SystemVerilog e `proc -noopt`.
- Node.js 18 ou mais novo e npm.

```bash
cd schematic_generator/esquematico
npm ci
```

O `package-lock.json` fixa a versão do `elkjs`. Para selecionar outro
executável do Yosys, defina `YOSYS`, por exemplo `YOSYS=yowasp-yosys`.

## Gerar os diagramas

Dentro de `schematic_generator/esquematico/`:

```bash
# Periférico APB completo, com wrapper e núcleo RSA v2:
npm run apb

# Apenas o núcleo RSA v2 e seus submódulos:
npm run rsa

# Outro módulo como topo, incluindo seus submódulos:
npm run generate -- --top amba_3_apb_data_io_top

# Elabora todo o APB, mas desenha apenas os módulos com esse nome:
npm run apb -- --modulo amba_3_apb_rsa_wrapper

# Somente a netlist e a verificação estrutural, sem depender do elkjs:
npm run generate -- --top rsa --elab-only
```

Também é possível chamar o script de qualquer diretório. Na raiz do projeto:

```bash
node schematic_generator/esquematico/generate.mjs --top apb
node schematic_generator/esquematico/generate.mjs --top rsa
```

Opções:

- `--top <nome>`: módulo RTL usado como topo. `apb` é um atalho para
  `amba_3_apb_rsa_apb_top` (padrão); `rsa` é um atalho para `rsa_core`.
- `--out <pasta>`: pasta de saída, relativa ao diretório da chamada.
  Sem a opção, usa `schematic_generator/esquematico/saida/<topo>/`.
- `--modulo <regex>`: filtra as folhas, sem alterar a elaboração do topo.
  Se nenhuma folha corresponder, o comando termina com erro.
- `--busca`: testa 40 layouts por folha e guarda a melhor configuração em
  `cfg/`. Pode demorar bastante nos somadores; comece sem essa opção.
- `--elab-only`: executa apenas o Yosys.
- `--help`: mostra a ajuda.

Use `--out` para guardar seleções diferentes separadamente. Uma nova geração
sobrescreve arquivos com o mesmo nome, mas não remove SVGs de execuções
anteriores. A lista atual de folhas está sempre em `sheets.json`.

## Saída

Os comandos `npm run apb` e `npm run rsa` geram, respectivamente:

```text
saida/amba_3_apb_rsa_apb_top/
saida/rsa_core/
```

Cada pasta contém:

- `netlist.json`: netlist elaborada pelo Yosys.
- `elab.ys` e `yosys.log`: comandos da elaboração e relatório estrutural.
- `NN_<modulo>.svg`: diagramas que podem ser abertos no navegador ou Inkscape.
- `sheets.json`: inventário das folhas, nets, parâmetros e conferência.
- `cfg/`: configurações de layout salvas quando se usa `--busca`.

Um módulo reutilizado com os mesmos parâmetros tem uma única folha; o
carimbo registra o caminho da primeira instância. Variantes parametrizadas
com o mesmo nome recebem um sufixo no arquivo/cache, evitando colisões
entre os somadores de 32, 33 e 64 bits. Os parâmetros constam em `sheets.json`.
Dependências e resultados locais são ignorados pelo Git.

## PDF com capítulos APB e RSA

Após gerar os dois conjuntos com `npm run apb` e `npm run rsa`, execute:

```bash
/usr/bin/python3 generate_pdf.py
```

O arquivo `saida/esquematicos_apb_rsa.pdf` reúne os 10 módulos APB e as 7
folhas RSA, com uma abertura para cada capítulo, sumários clicáveis e
marcadores de navegação. Cada diagrama ocupa uma página com suas proporções
originais e mantém os elementos vetoriais. O núcleo RSA aparece no capítulo
RSA. A conversão usa Pycairo e PyGObject com librsvg, disponíveis no Python
do sistema deste ambiente. `--out <arquivo.pdf>` permite escolher a saída.

## Fluxo manual
Para executar as etapas separadamente, dentro desta pasta:

```bash
yosys -Q -T -l yosys.log elab.ys
node schem.mjs rsa_apb.json saida/manual --base .
```

`elab.ys` seleciona o topo APB; `sources.ys` centraliza a lista de fontes;
`processes.ys` converte processos em muxes e flops e executa `check -assert`.
O script `generate.mjs` reutiliza os mesmos arquivos e seleciona o topo.
O CSS de `style.css` é embutido em cada SVG.

Ao chamar `schem.mjs` diretamente, `--base` deve indicar o diretório onde o
Yosys foi executado, para que os atributos `src` localizem os fontes RTL.
`generate.mjs` configura esse caminho automaticamente.

## Conferência e limites

O gerador confere os bits das conexões desenhadas contra a netlist e verifica
a presença das células e dos nomes públicos de nets. Uma conferência com
erros faz o comando retornar código diferente de zero. O término esperado é:

```text
conferencia: desenho igual a netlist em todas as folhas
```

Essa conferência compara o grafo do desenho com a netlist; não substitui uma
simulação ou prova de equivalência do RTL. O layout pode conter cruzamentos,
e os somadores estruturais produzem folhas grandes. A disposição também
pode variar com a versão do Yosys. A fonte preferida dos rótulos é IBM Plex
Mono, com alternativas monoespaçadas definidas no SVG.
