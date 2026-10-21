# Metodologia para sites de portfólio técnico

Este documento registra a abordagem utilizada na apresentação do RSA_APB e
serve como referência para projetos futuros. O objetivo é reunir identidade
visual, descrição da engenharia desenvolvida e evidências verificáveis em
um site de portfólio, com navegação direta e documentação acessível.

As instruções de execução deste repositório estão no [README do site](README.md).
Os nomes das ferramentas, caminhos, quantidades de imagens e parâmetros do
RSA_APB são exemplos de aplicação; devem ser adaptados ao próximo projeto.

## 1. Definir o conteúdo a partir do projeto

A preparação começa pela leitura dos fontes, READMEs, scripts e relatórios.
O conteúdo deve refletir o trabalho existente no repositório, incluindo
limites conhecidos da implementação e da verificação.

Registrar antes de desenhar a página:

- Nome, finalidade e escopo técnico do projeto.
- Interfaces, módulos e decisões de arquitetura relevantes.
- Etapas efetivamente desenvolvidas e ferramentas utilizadas.
- Imagens, diagramas, logs e relatórios disponíveis.
- Evidências que sustentam cada resultado apresentado.
- Seções necessárias e respectivos identificadores de navegação.

Para as imagens, manter um inventário com arquivo, conteúdo, ferramenta,
etapa do desenvolvimento e legenda. Conferir a própria captura: o nome do
arquivo ou uma tabela inicial podem conter classificações incorretas.

O formato também deve ser verificado pelo conteúdo. Neste projeto,
`img1.png`, `img2.png` e `img4.png` contêm SVG; o build publica cópias com
extensão `.svg`, preservando os originais. A extensão publicada precisa
corresponder ao formato para que o servidor envie o tipo de conteúdo correto.

## 2. Organizar a narrativa do portfólio

A sequência apresenta primeiro a identidade e a visão geral, depois o
desenvolvimento e seus resultados, encerrando com o detalhamento técnico.

| Ordem | Conteúdo | Papel na apresentação |
| --- | --- | --- |
| Abertura | Título, breve descrição, tecnologias e índice | Situar o projeto e oferecer acesso direto ao conteúdo. |
| Arquitetura | Diagrama de topo e organização funcional | Explicitar interfaces, responsabilidades e integração. |
| Implementação | Síntese, implementação física ou etapa equivalente | Apresentar o percurso da descrição à implementação. |
| Representações | Hierarquias, esquemáticos e vistas das ferramentas | Relacionar o particionamento funcional à estrutura implementada. |
| Verificação | Cobertura e relatórios | Documentar o alcance dos testes e permitir consultar as fontes. |
| Simulações | Formas de onda, comparações e logs | Registrar o comportamento observado e os critérios de avaliação. |
| Materiais de apoio | Bancadas, scripts, especificações e documentos | Preservar os recursos de reprodução e aprofundamento. |
| Blocos | Diagramas completos e descrições dos módulos | Detalhar as responsabilidades e interfaces da microarquitetura. |

Essa ordem é uma referência, não uma exigência de incluir seções sem
conteúdo. Em outro domínio, substituir as etapas de hardware pelas etapas
efetivamente realizadas, mantendo a progressão entre visão geral,
implementação, evidência e detalhamento.

No RSA_APB, a abertura antecede nove seções técnicas no mesmo `index.html`.
Os links utilizam âncoras HTML, preservando os endereços anteriores e a
navegação sem JavaScript.

## 3. Escrever como apresentação de engenharia

O texto principal apresenta o artefato desenvolvido, as decisões de
implementação e o método de avaliação. Não precisa ensinar ao visitante
como operar as ferramentas nem definir conceitos básicos da área.

Tratar cada elemento de texto de acordo com sua função:

| Elemento | Critério de redação |
| --- | --- |
| Título | Identificar o assunto com termos técnicos reconhecíveis. |
| Descrição da seção | Apresentar o trabalho realizado e o papel da etapa no projeto, em um parágrafo breve. |
| Legenda | Identificar o bloco, a condição ou o resultado registrado na imagem. |
| Descrição do módulo | Relacionar responsabilidade arquitetural, estrutura e comportamento observável. |
| Texto de interface | Informar a ação ou o estado do componente de forma objetiva. |
| README operacional | Documentar comandos, dependências e procedimentos de reprodução. |

Aplicar os seguintes critérios editoriais:

- Usar português natural, com precisão de sinais, interfaces e etapas.
- Descrever escolhas estruturais e suas consequências quando sustentadas
  pela implementação.
- Preferir informações concretas a expressões como “ajuda a entender”,
  “uma visão mais detalhada” ou “o diagrama apresenta”.
- Evitar convites informais nas descrições, como “vamos explorar”, “aqui
  dá para ver” e “um passeio pelos blocos”.
- Evitar adjetivos promocionais sem medidas ou resultados que os sustentem.
- Não substituir clareza por frases longas ou vocabulário burocrático.
- Manter procedimentos de execução nos scripts, exemplos e documentos de
  apoio; reservar o texto principal à apresentação do projeto.
- Preservar títulos e descrições já aprovados ao revisar outros elementos.

Uma referência de redação aplicada neste projeto:

> O RTL do RSA_APB foi sintetizado e mapeado em células padrão no Genus,
> com posicionamento e roteamento realizados no Innovus. A netlist e os
> atrasos exportados em SDF foram incorporados à simulação estrutural
> para análise do comportamento temporal da implementação.

O parágrafo identifica o trabalho executado, as ferramentas e os artefatos
produzidos. Não atribui à simulação uma comprovação de fechamento de timing.
Em projetos futuros, a redação deve ser igualmente específica às evidências
disponíveis, sem reutilizar essas afirmações automaticamente.

## 4. Construir a abertura com imagens do próprio projeto

A landing page reúne:

- Nome do projeto como único `h1` da página.
- Breve descrição técnica de finalidade, escopo e desenvolvimento.
- Identificação das tecnologias relevantes.
- Índice com links para todas as seções principais.
- Acesso ao repositório e ao conteúdo técnico.
- Composição de imagens reais do projeto ao fundo.

O fundo pode ser montado em HTML e CSS, reutilizando capturas existentes.
No RSA_APB, nove imagens formam um mosaico inclinado, com gradientes escuros
entre a composição e o conteúdo. A inclinação e a quantidade são escolhas
visuais deste projeto; o requisito reutilizável é manter imagens
reconhecíveis e texto legível em diferentes larguras.

As imagens decorativas usam `alt=""` e ficam em um contêiner com
`aria-hidden="true"`. As figuras técnicas do conteúdo têm texto alternativo
e legenda próprios. A navegação do índice utiliza links nativos, sem
depender de eventos JavaScript para alcançar as seções.

Neste layout, a documentação permanece abaixo da abertura. A barra lateral
fica fixa à rolagem dentro de seu próprio contêiner, sem sobrepor a landing
page; em telas menores, passa a integrar o fluxo da página.

## 5. Manter um sistema visual consistente

Definir cores, tipografia, espaçamentos e componentes compartilhados antes
de expandir as seções. O tema deve alcançar a documentação e os relatórios
incorporados, além da página principal.

Paleta de referência do RSA_APB:

| Uso | Cor |
| --- | --- |
| Fundo | `#050b16` |
| Superfície dos painéis | `#0a1424` |
| Superfície secundária | `#112039` |
| Bordas | `#24344c` |
| Texto principal | `#e9edf2` |
| Texto secundário | `#99a6b7` |
| Destaques e ações | `#ffa776` |
| Indicadores positivos | `#72d9ad` |

Usar tipografia de sistema para a leitura e monoespaçada para sinais,
código, índices e métricas. Concentrar a identidade nos elementos da
abertura e manter as seções técnicas visualmente sóbrias.

O comportamento responsivo deve contemplar texto, imagens, índice, tabelas,
visualizadores e navegação lateral. Imagens técnicas mantêm a proporção e
oferecem ampliação; tabelas extensas podem ter rolagem local, sem alargar a
página inteira. Foco de teclado visível e preferência por movimento
reduzido fazem parte do comportamento dos componentes.

## 6. Apresentar imagens e diagramas como evidências

Nas galerias, cada figura recebe legenda específica e acesso à versão
ampliada. O visualizador deve permitir fechar pelo botão e por Escape,
restaurar o foco ao elemento de origem e oferecer o arquivo original.
O link direto para a imagem permanece útil mesmo sem o modal.

Os diagramas Mermaid são extraídos dos documentos de origem. Exibir todas
as definições relevantes, incluindo visões complementares, em vez de
selecionar apenas o primeiro diagrama de cada arquivo. Manter o código
Mermaid disponível quando a biblioteca externa não carregar.

Para diagramas remotos, registrar a origem e oferecer acesso independente
ao arquivo. No RSA_APB, o diagrama de topo permanece conectado ao Drive
pelo visualizador do diagrams.net e é consultado ao abrir a página. A
atualização periódica e os controles de recarga foram removidos para
preservar a leitura e a navegação dentro do desenho.

Dimensionar o visualizador após observar o conteúdo real. A redução de 40%
da altura adotada no RSA_APB foi um ajuste específico desta apresentação;
não deve ser aplicada como proporção obrigatória em novos projetos.

## 7. Integrar relatórios e métricas com rastreabilidade

Os indicadores devem ser calculados dos artefatos de verificação, mantendo
acesso aos logs, aos relatórios completos e às fontes correspondentes.

Na integração de cobertura deste projeto:

1. O gerador lê `coverage.info` e calcula os totais e valores por arquivo.
2. Os links são construídos a partir das fontes registradas no LCOV.
3. O relatório HTML completo é copiado para o site, com seus recursos.
4. O tema do projeto é acrescentado ao CSS gerado, preservando as regras de
   layout da ferramenta e evitando duplicação a cada aplicação.
5. A página oferece tanto a incorporação do relatório quanto sua abertura
   independente e os downloads dos artefatos.

Conferir se os destinos dos links realmente existem. Usar caminhos relativos
para que a navegação funcione em um subdiretório do GitHub Pages.

Apresentar métricas LCOV e métricas nativas do simulador com suas respectivas
identificações. Capturas do IMC e relatórios do Verilator não são
automaticamente comparáveis: estímulos, instrumentação e contagem podem
ser diferentes. Identificar também se o testbench está excluído da medição.

Uma captura de ferramenta documenta uma representação ou um resultado
visível. Ela não substitui o relatório que comprova aprovação de
equivalência, atendimento temporal ou outra conclusão de verificação.

## 8. Separar fontes, geração e publicação

A implementação utiliza HTML, CSS e JavaScript sem framework para a
interface e Python para reunir a documentação e os artefatos. Essa escolha
atende ao caráter estático da apresentação e à publicação no GitHub Pages.

| Recurso neste repositório | Responsabilidade |
| --- | --- |
| [index.html](index.html) | Estrutura da abertura e das seções técnicas. |
| [assets/landing.css](assets/landing.css) | Mosaico, composição da abertura e transição para a documentação. |
| [assets/style.css](assets/style.css) | Tema e componentes da documentação. |
| [assets/app.js](assets/app.js) | Diagramas, busca, ampliação, logs e indicadores. |
| [modules.json](modules.json) | Catálogo dos módulos, descrições e referências aos fontes. |
| [document.html](document.html) | Apresentação dos documentos convertidos de Markdown. |
| [build.py](../scripts/pages/build.py) | Leitura dos artefatos e geração do site. |
| [documents.py](../scripts/pages/documents.py) | Conversão de documentos e ajuste dos links. |
| [coverage_theme.py](../scripts/pages/coverage_theme.py) | Aplicação do tema ao relatório LCOV. |
| [pages.yml](../.github/workflows/pages.yml) | Geração e publicação pelo GitHub Actions. |

O diretório `_site/` é uma saída gerada, não a fonte da interface. Alterações
permanentes são realizadas nos templates, estilos, catálogo e scripts.
Dados de execução também não devem ser mantidos manualmente no JavaScript:
o gerador produz `assets/data.js` a partir dos arquivos de entrada.

A geração verifica imagens, documentos, diagramas, logs completos e
destinos dos relatórios antes de disponibilizar um artefato para publicação.
Remover caminhos absolutos locais dos arquivos que serão distribuídos.
Registrar a origem dos dados e o contexto da geração com precisão: o horário
de modificação de um log não prova quando a simulação ocorreu, e o commit
do gerador não prova qual versão do RTL produziu um relatório anterior.

## 9. Revisar em uma prévia local antes de publicar

A revisão visual utiliza um servidor HTTP local, com o conteúdo gerado.
Abrir somente o template HTML não reproduz a montagem dos dados, dos
documentos e dos relatórios.

Exemplo de geração, executado na raiz do repositório, com os artefatos
válidos do RSA_APB já disponíveis:

```bash
python3 -m venv /tmp/portfolio-site-env
/tmp/portfolio-site-env/bin/pip install -r scripts/pages/requirements.txt
/tmp/portfolio-site-env/bin/python scripts/pages/build.py --output /tmp/portfolio-site-build
python3 -m http.server 8000 --bind 127.0.0.1 --directory /tmp/portfolio-site-build
```

O endereço da prévia é `http://localhost:8000/`. A saída separada evita
sobrescrever um site anteriormente gerado durante a preparação da revisão.
O terminal do servidor permanece ativo durante a navegação; `Ctrl+C`
encerra a prévia.

Se faltarem artefatos válidos ou a bancada atual falhar, manter a falha
visível. Uma revisão exclusivamente visual pode utilizar um snapshot
anterior em uma cópia isolada, identificado por um aviso de resultados
históricos. O snapshot deve preservar a correspondência entre logs,
métricas e relatórios; ele não comprova a verificação da versão atual.

Diretórios e scripts temporários usados durante uma sessão de trabalho não
são dependências permanentes do projeto. O procedimento de reprodução
deve permanecer documentado e versionado no próprio repositório.

## 10. Validar o conteúdo e a navegação

A revisão deve verificar:

- Legibilidade da abertura e do índice sobre o mosaico de imagens.
- Presença de todos os destinos do índice e ausência de IDs duplicados.
- Funcionamento dos links diretos anteriormente existentes.
- Navegação principal disponível sem JavaScript.
- Carregamento das imagens, proporção e funcionamento da ampliação.
- Diagramas completos e código Mermaid acessível em caso de falha de rede.
- Links dos relatórios e correspondência entre métricas e artefatos.
- Aplicação do tema tanto no relatório incorporado quanto em sua página.
- Ausência de erros JavaScript durante a navegação.
- Ausência de transbordamento horizontal em celular, tablet e desktop.
- Funcionamento do foco de teclado e do fechamento dos diálogos.
- Identificação correta da versão e da origem dos resultados apresentados.

Neste projeto, a revisão responsiva incluiu larguras entre 320 e 1920
pixels. Esses valores são uma referência de validação, não substituem a
inspeção dos componentes e das quebras de texto do próximo site.

Depois das verificações, produzir o artefato de publicação pelo fluxo do
repositório. Prévia visual, versionamento e publicação são etapas distintas;
o escopo combinado para o projeto determina quais serão executadas.

## 11. Adaptar a metodologia ao próximo repositório

Ao reutilizar esta implementação:

1. Substituir identidade, descrição, repositório e metadados do projeto.
2. Inventariar os novos artefatos e definir as seções que possuem evidências.
3. Atualizar o índice e os identificadores, preservando links que já tenham
   sido publicados.
4. Selecionar imagens do novo projeto e revisar suas legendas e formatos.
5. Adaptar o catálogo de módulos e os documentos de origem.
6. Ajustar os leitores de logs e cobertura ao formato dos novos relatórios.
7. Revisar caminhos, ferramentas, versões e dependências do workflow.
8. Aplicar o padrão editorial e revisar a abertura, as descrições e as
   legendas separadamente.
9. Gerar uma prévia local, validar os componentes e registrar limitações.
10. Publicar o resultado conforme o fluxo adotado no novo repositório.

Não transportar automaticamente as quantidades fixas de imagens, os nomes
dos módulos, os identificadores do Drive ou as correções de caminhos
específicas do RSA_APB. Reutilizar a organização e os componentes, adaptando
o conteúdo e a integração com os artefatos.

### Briefing reutilizável

```text
Crie a apresentação deste projeto como um portfólio técnico, seguindo
README_METODOLOGIA.md. Primeiro examine fontes, documentos, imagens e
relatórios disponíveis. Organize a página com uma abertura de identidade,
breve descrição, índice e composição de imagens reais; em seguida,
apresente arquitetura, implementação, verificação e detalhes dos blocos.
Use redação profissional centrada no trabalho realizado e nas evidências.
Integre os relatórios ao tema, preserve links diretos e mantenha os dados
vinculados aos artefatos de origem. Prepare uma prévia local e confira a
navegação e o layout em celular e desktop. Identifique qualquer limitação
de validação e execute a publicação conforme o escopo deste projeto.
```
