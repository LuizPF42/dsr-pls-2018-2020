# export_data.R
# Exporta o banco Recogito (SQLite) para dsr_data.json
# Rode este script uma vez antes de `quarto render dsr_pilot.qmd`

library(DBI)
library(RSQLite)
library(dplyr)
library(jsonlite)
library(stringr)

# Ajuste o caminho para o seu arquivo SQLite
DB_PATH <- "data_raw\\2026-05-28_PLs_DSR_2018-2020 - pdfs.sqlite3"

con <- dbConnect(SQLite(), DB_PATH)

# 1. Frequência de códigos
tag_freq <- dbGetQuery(con, "
  SELECT t.path AS code, COUNT(h.id) AS n
  FROM highlights h
  JOIN highlight_tags ht ON h.id = ht.highlight_id
  JOIN tags t ON ht.tag_id = t.id
  GROUP BY t.path
  ORDER BY n DESC
")

# 2. Polaridade por documento
doc_codes_raw <- dbGetQuery(con, "
  SELECT d.name AS doc, t.path AS code, COUNT(*) AS cnt
  FROM highlights h
  JOIN highlight_tags ht ON h.id = ht.highlight_id
  JOIN tags t ON ht.tag_id = t.id
  JOIN documents d ON h.document_id = d.id
  GROUP BY d.name, t.path
")

pro_codes <- c(
  "Separação de Poderes - Legislativo vs. Executivo (a favor do direito ao aborto)",
  "Defesa do direito ao aborto legal",
  "Autonomia e direitos sexuais e reprodutivos",
  "Saúde física e psicológica da mulher (pró DSR)",
  "Direito Internacional (pró direitos sexuais e reprodutivos)",
  "Interpretação sistemática pró DSR",
  "Menção a jurista (pró DSR)",
  "Fortalecimento da via penal (pró direitos sexuais e reprodutivos)"
)
contra_codes <- c(
  "Separação de Poderes - Legislativo vs. Executivo (contra direito ao aborto)",
  "Separação de Poderes - Legislativo vs. Judiciário (contra o direito ao aborto)",
  "Início da vida desde a concepção",
  "Fortalecimento da via penal (contra direitos sexuais e reprodutivos)",
  "Direito à vida do feto",
  "Saúde física e psicológica da mulher (contra DSR)",
  "Vontade popular",
  "Assassinato de bebês/nascituro/embriões/fetos",
  "Direito Civil e direitos do feto",
  "Dignidade do feto",
  "Condenação à morte por crime dos pais",
  "Direito Internacional (contra direitos sexuais e reprodutivos)",
  "Interpretação sistemática contra DSR",
  "Argumento científico contra DSR",
  "Lei Natural",
  "Soberania Nacional (contra DSR)",
  "Combate ao acesso ao aborto",
  "Contra o aborto legal",
  "Contra pesquisas com embriões",
  "Política internacional conservadora",
  "Argumento ou referência religiosa",
  "Menção a jurista (contra DSR)",
  "Benefício econômico contra aborto",
  "Caracterização negativa de mulheres"
)

doc_polarity <- doc_codes_raw |>
  mutate(
    side = case_when(
      code %in% pro_codes ~ "pro",
      code %in% contra_codes ~ "contra",
      TRUE ~ "neutral"
    )
  ) |>
  group_by(doc) |>
  summarise(
    pro   = sum(cnt[side == "pro"]),
    contra = sum(cnt[side == "contra"]),
    total = sum(cnt),
    .groups = "drop"
  ) |>
  mutate(
    doc = str_remove(doc, "\\.pdf$"),
    polarity = case_when(pro > contra ~ "pro", contra > pro ~ "contra", TRUE ~ "neutral")
  ) |>
  arrange(desc(total))

# 3. Posição média dos códigos no texto
offsets <- dbGetQuery(con, "
  SELECT h.document_id, h.start_offset, t.path AS code
  FROM highlights h
  JOIN highlight_tags ht ON h.id = ht.highlight_id
  JOIN tags t ON ht.tag_id = t.id
  ORDER BY h.document_id, h.start_offset
")

positions <- offsets |>
  group_by(document_id) |>
  mutate(max_off = max(start_offset, na.rm = TRUE),
         norm_pos = if_else(max_off > 0, start_offset / max_off, 0.5)) |>
  ungroup() |>
  group_by(code) |>
  summarise(avg_pos = round(mean(norm_pos), 3), n_obs = n(), .groups = "drop") |>
  left_join(tag_freq, by = "code") |>
  filter(n >= 2) |>
  arrange(avg_pos) |>
  select(code, avg_pos, n)

# 4. N-gramas por código
stopwords_pt <- c("que","com","para","por","dos","das","aos","nas","nos",
                   "ela","ele","eles","elas","seu","sua","seus","suas",
                   "uma","uns","umas","num","numa","não","mais","mas",
                   "também","como","quando","qual","quais","isso","esta",
                   "este","esse","essa","esses","essas","isto","aqui",
                   "ali","já","ainda","bem","sem","sob","até","após")

snippets <- dbGetQuery(con, "
  SELECT t.path AS code, h.snippet
  FROM highlights h
  JOIN highlight_tags ht ON h.id = ht.highlight_id
  JOIN tags t ON ht.tag_id = t.id
")

top_codes <- tag_freq |> filter(n >= 8) |> pull(code)

get_ngrams <- function(texts, n) {
  all_ng <- list()
  for (txt in texts) {
    txt <- str_to_lower(str_remove_all(txt, "<[^>]+>"))
    words <- str_extract_all(txt, "[a-záàâãéêíóôõúüç]+")[[1]]
    words <- words[nchar(words) > 2 & !words %in% stopwords_pt]
    if (length(words) < n) next
    for (i in seq_len(length(words) - n + 1)) {
      all_ng <- c(all_ng, list(words[i:(i + n - 1)]))
    }
  }
  if (length(all_ng) == 0) return(data.frame())
  ng_str <- sapply(all_ng, paste, collapse = "|")
  counts <- sort(table(ng_str), decreasing = TRUE)
  top <- head(counts, ifelse(n == 2, 8, 5))
  data.frame(
    gram = names(top),
    count = as.integer(top),
    stringsAsFactors = FALSE
  )
}

ngrams_data <- lapply(top_codes, function(code) {
  texts <- snippets$snippet[snippets$code == code]
  n_segs <- nrow(tag_freq[tag_freq$code == code, ])
  bg <- get_ngrams(texts, 2)
  tg <- get_ngrams(texts, 3)

  bg_list <- if (nrow(bg) > 0) {
    lapply(seq_len(nrow(bg)), function(i) {
      parts <- str_split(bg$gram[i], "\\|")[[1]]
      c(as.list(parts), list(bg$count[i]))
    })
  } else list()

  tg_list <- if (nrow(tg) > 0) {
    lapply(seq_len(nrow(tg)), function(i) {
      parts <- str_split(tg$gram[i], "\\|")[[1]]
      c(as.list(parts), list(tg$count[i]))
    })
  } else list()

  list(code = code, n = n_segs, bigrams = bg_list, trigrams = tg_list)
})

# 5. Códigos por documento (para aba Documentos)
doc_codes_detail <- dbGetQuery(con, "
  SELECT d.name AS doc, t.path AS code, COUNT(*) AS n
  FROM highlights h
  JOIN highlight_tags ht ON h.id = ht.highlight_id
  JOIN tags t ON ht.tag_id = t.id
  JOIN documents d ON h.document_id = d.id
  GROUP BY d.name, t.path
  ORDER BY d.name, n DESC
")

doc_codes <- doc_codes_detail |>
  mutate(doc = str_remove(doc, "\\.pdf$")) |>
  group_by(doc) |>
  summarise(codes = list(data.frame(code = code, n = n)), .groups = "drop")

doc_codes_list <- setNames(
  lapply(seq_len(nrow(doc_codes)), function(i) {
    df <- doc_codes$codes[[i]]
    lapply(seq_len(nrow(df)), function(j) list(code = df$code[j], n = df$n[j]))
  }),
  doc_codes$doc
)

dbDisconnect(con)

# Montar e salvar JSON
output <- list(
  tag_freq     = tag_freq,
  doc_polarity = doc_polarity,
  positions    = positions,
  ngrams       = ngrams_data,
  doc_codes    = doc_codes_list,
  meta         = list(total_docs = 45L, total_highlights = 287L, total_codes = 48L)
)

write_json(output, "dsr_data.json", auto_unbox = TRUE, pretty = TRUE)
cat("dsr_data.json gerado com sucesso.\n")
