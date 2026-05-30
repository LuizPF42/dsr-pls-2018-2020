# PLs sobre Direitos Sexuais e Reprodutivos (2018–2020)

Análise exploratória de corpus codificado — piloto.

**Visualização interativa:** https://rpubs.com/Luizpf42/dsr-pls-2018-2020

## Origem e equipe

Este projeto deriva de pesquisas desenvolvidas pelo [Núcleo de Estudos sobre o Crime e a Pena](https://direitosp.fgv.br/nucleos-de-pesquisa/nucleo-estudos-sobre-crime-pena) da FGV Direito SP, coordenado pela profa. [Marta Rodriguez de Assis Machado](http://lattes.cnpq.br/8601296185222408).

A extração do corpus e o desenvolvimento das ferramentas de análise foram realizados por [Luiz Claudio Pimenta Filho](http://lattes.cnpq.br/1096752907228813). A codificação e análise qualitativa das proposições foram realizadas por [Matheus de Barros](http://lattes.cnpq.br/3707929725934308).

## Sobre o projeto

Este repositório contém o código e os dados de uma análise exploratória de proposições legislativas brasileiras (2018–2020) relacionadas a direitos sexuais e reprodutivos (DSR). O corpus foi codificado qualitativamente via Taguette (usa estrutura Recogito?) e exportado para análise e visualização em R e Quarto.

## Extração do corpus

As proposições foram extraídas da [API de Dados Abertos da Câmara dos Deputados](https://dadosabertos.camara.leg.br/swagger/api.html), cobrindo o período de 1988 a 2020. Para cada ano, foram baixados os arquivos JSON de proposições disponibilizados pela API.

A seleção das proposições relevantes foi feita por busca textual nas ementas, combinando dois grupos de termos:

A seleção das proposições relevantes foi feita por busca textual nas ementas, combinando dois grupos de termos:

**Termos autossuficientes** — qualquer ocorrência já qualifica a proposição:

- Variações de: *aborto*, *nascituro*, *feto*, *embrião*, *anencefalia*
- Expressões: *interrupção da gravidez*, *interrupção da gestação*
- Expressões: *direito à vida*, *dignidade da vida*

**Termos combinados** — qualificam a proposição quando aparecem juntos:

- Referências ao Código Penal (termo *Código Penal*, número *2.848* ou variações)
- Combinadas com referências aos artigos 124 a 128 (que tipificam o aborto no CP)

O corpus final foi restrito às proposições do período 2018–2020 para análise qualitativa.

**Visualizações** — aparecem a partir dos códigos.

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
