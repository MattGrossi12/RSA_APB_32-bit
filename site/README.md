# Página de documentação e verificação

A página tem cinco seções:

- **RTL:** diagrama do Drive, resumos dos onze módulos e seus arquivos.
- **Testbench:** sequência dos testes e principais tasks da bancada.
- **Scripts:** comandos de simulação e geração da página.
- **Docs:** READMEs, plano de teste e PDFs do APB.
- **Resultados de simulação:** logs do topo e cobertura LCOV/Verilator.

Os números e trechos dos logs vêm das simulações executadas no projeto.

O tema usa fundo azul quase preto (`#050b16`), painéis em azul escuro e
diagramas Mermaid com a mesma paleta. Os SVGs ilustrativos em `images/`
têm fundo próprio, para preservar o contraste ao aparecerem no README
independentemente do tema do GitHub.

O relatório HTML de cobertura usa o mesmo fundo `#050b16`, com tabelas em azul
escuro e cores distintas para cobertura alta, média, baixa e linhas executadas.
O tema está em `assets/lcov.css`. O script do Verilator aplica o tema após o
genhtml, e o build do site também o aplica à cópia em `_site/coverage/`.
Para atualizar um relatório já existente, execute na raiz:

```bash
python3 scripts/pages/coverage_theme.py reports/amba_3_apb_rsa_apb_top/verilator/html
```

## Diagrama de topo conectado ao Drive

A seção RTL inclui o visualizador oficial do diagrams.net,
ligado ao XML público do arquivo `1pJmIWxV6VePdHCURcpEqT6SSo5kHxkri` no Drive.
O arquivo remoto é a fonte do diagrama; não é exportado ou copiado pelo build.
O código de conexão está em `assets/live-diagram.js`.

Depois de salvar uma edição no diagrams.net, a página solicita novamente o
arquivo a cada 60 segundos enquanto a aba está visível. **Atualizar agora**
antecipa a consulta; desmarcar **Atualizar a cada minuto** pausa as consultas
automáticas. A URL da consulta recebe um timestamp para evitar reutilizar o
mesmo recurso no visualizador. O provedor ainda pode levar algum tempo para
disponibilizar uma edição recém-salva; não é sincronização colaborativa em tempo real.

Não é necessário commit ou novo deploy para atualizar o conteúdo desse
diagrama. O arquivo precisa continuar público para leitura por link. O botão
**Editar diagrama** abre o arquivo original, mantendo as permissões de edição
do Google Drive. Falhas de rede ou de permissão aparecem no próprio visualizador;
o link **Abrir arquivo original** continua disponível fora dele.

No README do GitHub há um acesso destacado no início para essa seção do site:
o GitHub não permite executar o iframe ou scripts do visualizador no Markdown.

## Leitura dos READMEs

Os links dos READMEs abrem páginas HTML dentro do site, com o mesmo tema,
índice de seções, tabelas, blocos de código, imagens e diagramas Mermaid.
O plano de teste também usa esse formato. A opção **Baixar .md** dá acesso
ao arquivo original, e **Voltar à documentação** retorna à página principal.

A conversão é feita por `scripts/pages/documents.py` durante o build, usando
[Python-Markdown](https://python-markdown.github.io/extensions/). Os links entre
READMEs são convertidos para as páginas locais; as imagens são copiadas para
os assets do site, e os links de código apontam ao arquivo do repositório.
O texto e as tabelas ficam disponíveis mesmo com JavaScript desativado. Os
blocos Mermaid são desenhados pelo navegador; seu código continua disponível
quando o carregamento do Mermaid não é possível.

A página principal apresenta apenas o diagrama de topo do Drive e os diagramas
dos módulos. O painel do Drive usa `clamp(1320px, 195vh, 2340px)` no desktop
e 1560 pixels no celular.

## Gerar localmente

Na raiz, após instalar as dependências dos simuladores e `genhtml`, instale
as dependências Python em um ambiente virtual:

```bash
python3 -m venv /tmp/rsa-apb-pages-env
/tmp/rsa-apb-pages-env/bin/pip install -r scripts/pages/requirements.txt
./scripts/amba_3_apb_rsa_apb_top/bash/iverilog.sh
./scripts/amba_3_apb_rsa_apb_top/bash/verilator.sh
/tmp/rsa-apb-pages-env/bin/python scripts/pages/build.py
python3 -m http.server 8000 --directory _site
```

Abra `http://localhost:8000`. Se os logs e relatórios já estiverem atualizados,
basta executar o gerador Python com esse ambiente e iniciar o servidor. A
versão de Python-Markdown está fixada em `scripts/pages/requirements.txt`.
O diretório `_site/` é gerado e ignorado pelo Git.

## Fontes da página

- `modules.json`: nomes e resumos dos módulos, escritos para a página.
- `README.md` principal: conteúdo da página de documentação do projeto.
- Os READMEs listados no catálogo: diagramas Mermaid e documentação completa.
  Se o catálogo não definir um resumo, o gerador usa o parágrafo de Objetivo.
- `index.html` e `assets/`: interface responsiva sem framework ou bundler.
- `scripts/pages/build.py`: coleta as evidências e empacota o site completo.
- `scripts/pages/documents.py` e `document.html`: formatam os documentos,
  ajustam os links e criam as páginas em `_site/reference/*.html`.
- `scripts/pages/documents.py` e `document.html`: formatam os documentos,
  ajustam seus links e criam as páginas em `_site/reference/*.html`.
- Os dois `simulation.log` do topo: resumos e trechos de reset/regbank/RSA.
- `coverage.info`: porcentagens LCOV por arquivo e totais, calculadas a partir
  dos registros DA/BRDA. Não se confundem com as métricas nativas.
- `coverage_summary.txt`: métricas nativas do Verilator, em seção separada.
- O diretório HTML do genhtml: copiado para `_site/coverage/`, incluindo as
  páginas anotadas e seus recursos.
- O testbench, os scripts, o README principal e os PDFs: copiados para
  `_site/reference/`, junto dos READMEs dos módulos e do plano de teste.

O build falha quando faltam evidências, diagramas, relatórios ou algum módulo
do catálogo não tem cobertura, evitando publicar dados de exemplo como reais.
Os logs e o arquivo LCOV baixáveis têm os caminhos absolutos do checkout
removidos. A página apresenta o instante de simulação em Brasília e o commit
de origem; mudanças locais são identificadas como workspace.

O Mermaid 12.2.0 é carregado de jsDelivr. Se a conexão falhar, o restante da
página continua funcionando e a definição Mermaid permanece acessível. Não
há fontes ou frameworks externos adicionais. O diagrama de topo usa o
visualizador remoto do diagrams.net e seu arquivo público no Drive.

## Publicar no GitHub Pages

1. Envie os arquivos deste trabalho ao repositório.
2. Em **Settings → Pages → Build and deployment → Source**, selecione
   **GitHub Actions**.
3. Execute **Actions → Documentação e cobertura — GitHub Pages → Run workflow**
   na branch de publicação, ou envie um commit para `main`/`master`.

O workflow instala Icarus/LCOV e as dependências Python, compila o Verilator oficial na versão 5.052
(com cache), executa as simulações, gera o site e publica o artefato. A versão
foi fixada porque o script de cobertura utiliza os relatórios por tipo e
hierarquia dessa versão. A primeira execução inclui a compilação da ferramenta.
Arquivos locais ignorados, como logs e relatórios, são recriados no runner.

O endereço padrão deste repositório será
`https://mattgrossi12.github.io/RSA_APB_32-bit/`; a URL efetiva será exibida no
job de deploy após a publicação. O site utiliza links relativos, compatíveis
com o subdiretório de um projeto GitHub Pages.

Referências oficiais:
[workflow GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)
e [Mermaid no navegador](https://mermaid.js.org/config/usage.html).

## Verificação da página

O build usa os logs do topo e os relatórios existentes, com 238 comparações.
A página principal mantém as cinco seções, onze módulos e o diagrama remoto.
As quinze páginas de documentação foram conferidas no Chrome, incluindo
navegação entre READMEs, índices, imagens, tabelas, diagramas e a exibição em
390 pixels sem transbordamento horizontal. A execução e a publicação remota dependem
do envio ao GitHub e da habilitação de Pages no repositório.

O diagrama remoto também foi validado incorporado à página: o visualizador
carregou o conteúdo real do XML público do Drive, e os controles de atualização
manual, pausa e consulta automática foram exercitados no navegador. A URL de
edição foi conferida para apontar ao arquivo original.

Também foram conferidas as cinco seções do menu, os resumos revisados dos
módulos e os links para testbench, scripts e documentos. A reorganização da
página mantém os mesmos resultados das 238 comparações da bancada.
