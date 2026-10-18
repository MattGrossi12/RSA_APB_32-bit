# Página de documentação e verificação

O site estático reúne resumos dos dez módulos, diagramas Mermaid dos READMEs,
trechos dos logs do topo, cobertura por arquivo e o relatório LCOV completo.
As métricas são calculadas a partir dos artefatos reais, sem percentuais
fixados na interface.

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

- `modules.json`: catálogo de módulos, títulos e destaques funcionais.
- Os READMEs listados no catálogo: primeiro parágrafo de Objetivo e Mermaid.
- `index.html` e `assets/`: interface responsiva sem framework ou bundler.
- `scripts/pages/build.py`: coleta as evidências e empacota o site completo.
- Os dois `simulation.log` do topo: resumos e trechos de reset/regbank/RSA.
- `coverage.info`: porcentagens LCOV por arquivo e totais, calculadas a partir
  dos registros DA/BRDA. Não se confundem com as métricas nativas.
- `coverage_summary.txt`: métricas nativas do Verilator, em seção separada.
- O diretório HTML do genhtml: copiado para `_site/coverage/`, incluindo as
  páginas anotadas e seus recursos.

O build falha quando faltam evidências, diagramas, relatórios ou algum módulo
do catálogo não tem cobertura, evitando publicar dados de exemplo como reais.
Os logs e o arquivo LCOV baixáveis têm os caminhos absolutos do checkout
removidos. A página apresenta o instante de simulação em Brasília e o commit
de origem; mudanças locais são identificadas como workspace.

O Mermaid 12.2.0 é carregado de jsDelivr. Se a conexão falhar, o restante da
página continua funcionando e a definição Mermaid permanece acessível. Não
há fontes, imagens ou frameworks externos adicionais.

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
238 comparações, 645/717 linhas LCOV e 5263/6478 branches LCOV. Os dez
diagramas renderizaram no Chrome. Foram exercitados busca, ampliação dos
diagramas, troca de simulador/trecho, ordenação da cobertura e viewport de
390 pixels sem transbordamento horizontal da página. Os 306 links internos
do HTML gerado foram conferidos. O workflow foi validado estruturalmente;
sua execução e publicação remota dependem do envio ao GitHub e da habilitação
de Pages no repositório.
