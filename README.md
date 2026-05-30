# PLs sobre Direitos Sexuais e Reprodutivos (2018–2020)

Análise exploratória de corpus codificado — piloto.

**Site do projeto:** https://luizpf42.github.io/dsr-pls-2018-2020/

**Relatório de visualizações:** https://luizpf42.github.io/dsr-pls-2018-2020/dsr_pilot.html

## Origem e equipe

Este projeto deriva de pesquisas desenvolvidas pelo [Núcleo de Estudos sobre o Crime e a Pena](https://direitosp.fgv.br/nucleos-de-pesquisa/nucleo-estudos-sobre-crime-pena) da FGV Direito SP, coordenado pela profa. [Marta Rodriguez de Assis Machado](http://lattes.cnpq.br/8601296185222408).

A extração do corpus e o desenvolvimento das ferramentas de análise foram realizados por [Luiz Claudio Pimenta Filho](http://lattes.cnpq.br/1096752907228813). A codificação e análise qualitativa das proposições foram realizadas por [Matheus de Barros](http://lattes.cnpq.br/3707929725934308).

## Sobre o projeto

Este repositório contém o código e os dados de uma análise exploratória das justificativas legislativas de proposições brasileiras (2018–2020) relacionadas a direitos sexuais e reprodutivos (DSR). O corpus foi codificado qualitativamente via [Taguette](https://www.taguette.org/about.html) e exportado para análise e visualização em R e Quarto.

As visualizações partem dos códigos analíticos atribuídos às proposições e incluem: frequência de códigos por polaridade, distribuição de polaridade por documento, posição média dos códigos no texto, n-gramas por categoria, e exploração individual por PL/PDL.

## Extração do corpus

As proposições foram extraídas da [API de Dados Abertos da Câmara dos Deputados](https://dadosabertos.camara.leg.br/swagger/api.html), cobrindo o período de 1988 a 2020. Para cada ano, foram baixados os arquivos JSON de proposições disponibilizados pela API.

A seleção das proposições relevantes foi feita por busca textual nas ementas, combinando dois grupos de termos:

**Termos autossuficientes** — qualquer ocorrência já qualifica a proposição:

- Variações de: *aborto*, *nascituro*, *feto*, *embrião*, *anencefalia*
- Expressões: *interrupção da gravidez*, *interrupção da gestação*
- Expressões: *direito à vida*, *dignidade da vida*

**Termos combinados** — qualificam a proposição quando aparecem juntos:

- Referências ao Código Penal (termo *Código Penal*, número *2.848* ou variações)
- Combinadas com referências aos artigos 124 a 128 (que tipificam o aborto no CP)

O corpus final foi restrito às proposições do período 2018–2020 para análise qualitativa.

## Estrutura do repositório

O projeto segue a estrutura de um pacote R (convenções do
[usethis](https://usethis.r-lib.org/)/[devtools](https://devtools.r-lib.org/) e do
livro [R Packages](https://r-pkgs.org/)):

```
DESCRIPTION              # metadados do pacote
NAMESPACE                # gerado pelo roxygen2
R/                       # código do pacote (funções, doc do pacote)
data-raw/                # preparação dos dados (convenção usethis::use_data_raw)
  export_data.R          # exporta o banco SQLite -> inst/relatorio/dsr_data.json
  sql_raw.sqlite3        # banco SQLite do Taguette (dados brutos, não versionado)
inst/relatorio/          # relatório Quarto
  _quarto.yml            # configuração do site Quarto (output-dir aponta para docs/)
  index.qmd              # página inicial (descrição do projeto)
  dsr_pilot.qmd          # relatório de visualizações (Observable JS)
  dsr_data.json          # dados exportados (consumidos pelo relatório)
docs/                    # site renderizado (servido pelo GitHub Pages)
.github/workflows/       # CI (opcional)
```

## Reprodução local

### Pré-requisitos

- [Quarto](https://quarto.org/docs/get-started/) (>= 1.4)
- R com os pacotes de exportação:

```r
install.packages(c("DBI", "RSQLite", "dplyr", "jsonlite", "stringr"))
```

### Passos

A partir da **raiz do projeto**:

1. Clone o repositório
2. Coloque o banco `data-raw/sql_raw.sqlite3` na pasta (não é versionado)
3. Gere os dados do relatório:

```r
source("data-raw/export_data.R")
```

4. Renderize o relatório Quarto:

```bash
quarto render inst/relatorio
```

5. Abra o site gerado na pasta `docs/`

## Publicação

O site é publicado via **GitHub Pages**, servido a partir da pasta `docs/` na branch `main`.

O `_quarto.yml` está configurado com `output-dir: ../../docs`, de modo que `quarto render inst/relatorio` gera o site diretamente na pasta `docs/` da raiz. Para publicar uma atualização:

1. Rode `quarto render inst/relatorio`
2. Faça commit e push da pasta `docs/`
3. O GitHub Pages atualiza o site automaticamente em alguns minutos

Configuração do Pages: **Settings → Pages → Source: Deploy from a branch**, branch `main`, pasta `/docs`.

Documentação: <https://quarto.org/docs/publishing/github-pages.html>

## Notas técnicas

- O HTML gerado é autocontido (`embed-resources: true`): um único arquivo sem dependências externas
- Os dados ficam embutidos no JSON; o browser não acessa o banco SQLite diretamente
- As visualizações usam [Observable Plot](https://observablehq.com/plot/) via Quarto OJS
- O banco SQLite do Taguette fica em `data-raw/` e não é versionado

## To-do

- [ ] Adicionar raspadores em R
- [ ] Adicionar PDFs completos das justificativas
- [ ] Cruzar PLs com autores e partidos via API da Câmara
- [ ] Visualizações sobre posicionamento por partido
- [ ] Visualizações sobre posicionamento por conteúdo argumentativo
- [ ] Análise de co-autoria e redes partidárias por posição
- [ ] Série temporal: evolução do volume de proposições por ano (1988–2020)
- [ ] Comparação entre PLs aprovados, arquivados e em tramitação
- [ ] Extração e análise dos textos legais (não só justificativas) para recodificação
- [ ] Expansão do corpus para outras casas legislativas (Senado)
- [ ] Integração com dados de votações nominais para verificar coerência entre autoria e voto
