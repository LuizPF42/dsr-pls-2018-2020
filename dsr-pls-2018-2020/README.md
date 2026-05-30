# PLs DSR 2018–2020 — Piloto Quarto

Visualização interativa de corpus codificado no Recogito.

## Estrutura

```
dsr_pilot.qmd       # documento Quarto principal
export_data.R       # script que gera dsr_data.json a partir do SQLite
dsr_data.json       # dados exportados (gerado pelo script acima)
```

## Pré-requisitos

- [Quarto](https://quarto.org/docs/get-started/) (>= 1.4)
- R com os pacotes: `DBI`, `RSQLite`, `dplyr`, `jsonlite`, `stringr`

Instale os pacotes R se necessário:
```r
install.packages(c("DBI", "RSQLite", "dplyr", "jsonlite", "stringr"))
```

## Uso local

1. Coloque o arquivo `.sqlite3` na mesma pasta
2. Ajuste `DB_PATH` em `export_data.R` se necessário
3. Rode o script de exportação:
```r
source("export_data.R")
```
4. Renderize o documento:
```bash
quarto render dsr_pilot.qmd
```
5. Abra `dsr_pilot.html` no browser

## Publicar no GitHub Pages

1. Crie um repositório no GitHub
2. Suba os três arquivos: `dsr_pilot.qmd`, `dsr_data.json`, `export_data.R`
3. Adicione um arquivo `_quarto.yml` na raiz:
```yaml
project:
  type: website
  output-dir: docs

website:
  title: "PLs DSR 2018–2020"
```
4. Rode `quarto render` localmente — isso gera a pasta `docs/`
5. Suba a pasta `docs/` para o GitHub
6. No repositório: Settings → Pages → Source: `main` branch, pasta `/docs`
7. O site estará disponível em `https://seu-usuario.github.io/nome-do-repo`

## Notas

- O HTML gerado é autocontido (`embed-resources: true`): um único arquivo sem dependências externas
- Os dados ficam embutidos no JSON, não no SQLite — o browser não acessa o banco diretamente
- As visualizações usam [Observable Plot](https://observablehq.com/plot/) via Quarto OJS
