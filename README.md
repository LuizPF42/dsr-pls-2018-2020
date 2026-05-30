# PLs sobre Direitos Sexuais e Reprodutivos (2018–2020)

Análise exploratória de corpus codificado — piloto.

**Visualização interativa:** https://rpubs.com/Luizpf42/dsr-pls-2018-2020

## Sobre o projeto

Este repositório contém o código e os dados de uma análise exploratória de proposições legislativas brasileiras (2018–2020) relacionadas a direitos sexuais e reprodutivos (DSR). O corpus foi codificado qualitativamente no Recogito e exportado para análise e visualização em R e Quarto.

As visualizações incluem: frequência de códigos analíticos por polaridade, distribuição de polaridade por documento, posição média dos códigos no texto, n-gramas por categoria, e exploração individual por PL/PDL.

## Estrutura do repositório

```
dsr_pilot.qmd       # documento Quarto com as visualizações (Observable JS)
export_data.R       # script R que exporta o banco SQLite para dsr_data.json
dsr_data.json       # dados exportados (gerado por export_data.R)
data_raw/           # banco SQLite original do Recogito (não versionado)
```

## Reprodução local

### Pré-requisitos

- [Quarto](https://quarto.org/docs/get-started/) (>= 1.4)
- R com os pacotes:

```r
install.packages(c("DBI", "RSQLite", "dplyr", "jsonlite", "stringr"))
```

### Passos

1. Clone o repositório
2. Coloque o arquivo `.sqlite3` na pasta `data_raw/`
3. Ajuste `DB_PATH` em `export_data.R` se necessário
4. Rode o script de exportação no R:

```r
source("export_data.R")
```

5. Renderize o documento Quarto:

```bash
quarto render dsr_pilot.qmd
```

6. Abra `dsr_pilot.html` no browser

## Notas técnicas

- O HTML gerado é autocontido (`embed-resources: true`): um único arquivo sem dependências externas
- Os dados ficam embutidos no JSON; o browser não acessa o banco SQLite diretamente
- As visualizações usam [Observable Plot](https://observablehq.com/plot/) via Quarto OJS
- O banco SQLite original não está versionado por conter dados de projeto em andamento
