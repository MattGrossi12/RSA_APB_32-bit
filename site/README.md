# Página de documentação e verificação

A página tem cinco seções:

- **RTL:** diagrama do Drive, arquitetura do README, resumos dos onze módulos e seus arquivos.
- **Testbench:** sequência dos testes e principais tasks da bancada.
- **Scripts:** comandos de simulação e geração da página.
- **Docs:** READMEs, plano de teste e PDFs do APB.
- **Resultados de simulação:** logs do topo e cobertura LCOV/Verilator.

Os números e trechos dos logs vêm das simulações executadas no projeto.

O tema usa fundo azul quase preto (`#050b16`), painéis em azul escuro e
diagramas Mermaid com a mesma paleta. Os SVGs ilustrativos em `images/`
têm fundo próprio, para preservar o contraste ao aparecerem no README
independentemente do tema do GitHub.

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

## Diagrama do README e módulos novos

A seção **Arquitetura do RTL** mostra o Mermaid da seção **Diagrama de
arquitetura de topo** do README principal. O build lê essa definição, e a
página permite ampliar o desenho, ajustar o zoom e consultar seu código. O
painel do README tem 1008 pixels de altura, e o desenho abre com 1,8 vez
a escala ajustada à largura. Os controles **+** e **−** permitem mudar a
escala. A rolagem dá acesso às demais conexões; o botão
**Ajustar** volta a encaixar sua largura no painel. As edições nesse
Mermaid entram no site no próximo build; o diagrama do Drive continua sendo
consultado diretamente pelo visualizador.

O painel do Drive também tem a altura triplicada: usa
`clamp(1320px, 195vh, 2340px)` no desktop e 1560 pixels no celular.

O desenho inclui `amba_3_apb_adrec` dentro de `data_io_top` e a saída
`rsa_rst_o` do bloco de reset. O catálogo tem onze módulos, e a seção
Testbench inclui a bancada do adrec, com acesso ao arquivo SystemVerilog.

## Gerar localmente

Na raiz, após instalar as dependências dos simuladores e `genhtml`:

```bash
./scripts/amba_3_apb_rsa_apb_top/bash/iverilog.sh
./scripts/amba_3_apb_rsa_apb_top/bash/verilator.sh
python3 scripts/pages/build.py
python3 -m http.server 8000 --directory _site
```

Abra `http://localhost:8000`. Se os logs e relatórios já estiverem atualizados,
basta executar o gerador Python e o servidor. O Python usa apenas a biblioteca
padrão. O diretório `_site/` é gerado e ignorado pelo Git.

## Fontes da página

- `modules.json`: nomes e resumos dos módulos, escritos para a página.
- `README.md` principal: diagrama Mermaid da arquitetura de topo.
- Os READMEs listados no catálogo: diagramas Mermaid e documentação completa.
  Se o catálogo não definir um resumo, o gerador usa o parágrafo de Objetivo.
- `index.html` e `assets/`: interface responsiva sem framework ou bundler.
- `scripts/pages/build.py`: coleta as evidências e empacota o site completo.
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

O workflow instala Icarus/LCOV, compila o Verilator oficial na versão 5.052
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

O build local foi conferido contra os números dos relatórios existentes:
238 comparações, 645/717 linhas LCOV e 5271/6506 branches LCOV. O diagrama
do README e os onze diagramas dos módulos renderizaram no Chrome. Foram exercitados busca, ampliação dos
diagramas, troca de simulador/trecho, ordenação da cobertura e viewport de
390 pixels sem transbordamento horizontal da página. Os 332 links internos
do HTML gerado foram conferidos. O workflow foi validado estruturalmente;
sua execução e publicação remota dependem do envio ao GitHub e da habilitação
de Pages no repositório.

O diagrama remoto também foi validado incorporado à página: o visualizador
carregou o conteúdo real do XML público do Drive, e os controles de atualização
manual, pausa e consulta automática foram exercitados no navegador. A URL de
edição foi conferida para apontar ao arquivo original.

Também foram conferidas as cinco seções do menu, os resumos revisados dos
módulos e os links para testbench, scripts e documentos. A reorganização da
página mantém os mesmos resultados das 238 comparações da bancada.

O diagrama de topo também foi conferido com os controles de zoom, ajuste de
largura e rolagem, incluindo a exibição do adrec e a abertura em tamanho maior.
