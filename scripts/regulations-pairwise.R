suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(textreuse))
suppressPackageStartupMessages(library(fs))
suppressPackageStartupMessages(library(readr))
source("R/helpers.R")
options("mc.cores" = 8L)

regs <- read_csv("data/regulations.csv",
                 col_types = cols(
                   id = col_character(),
                   date = col_integer(),
                   navy = col_character(),
                   title = col_character()
                 ))


raw_texts <- fs::dir_ls("data/regulations-split") |> map_chr(read_file)
names(raw_texts) <- raw_texts |>
  names() |>
  basename() |>
  tools::file_path_sans_ext()

stop_phrases <- read_lines("data/stops.txt")
texts <- clean_texts(raw_texts, stop_phrases)

sections <- TextReuseCorpus(text = texts,
                            tokenizer = regs_tokenizer,
                            keep_tokens = FALSE)

comparisons <- pairwise_compare(sections, jaccard_similarity,
                                progress = TRUE)

scores <- comparisons |>
  as_tibble(rownames = NA) |>
  rownames_to_column() |>
  rename(a = rowname) |>
  pivot_longer(-a, names_to = "b", values_to = "score") |>
  filter(!is.na(score),
         score != 0)

scores_swapped <- scores %>%
  rename(b2 = a, a2 = b) %>%
  rename(a = a2, b = b2)

scores_for_join <- bind_rows(scores, scores_swapped) %>%
  rename(borrower_section = a,
         match_section = b)


get_doc <- function(x) {
  stringr::str_extract(x, "\\w{2,3}-\\d{4}")
}

regs_borrower <- regs |>
  select(borrower_doc = id,
         borrower_date = date,
         borrower_navy = navy)

regs_match <- regs |>
  select(match_doc = id,
         match_date = date,
         match_navy = navy)

all_matches <- scores_for_join |>
  mutate(borrower_doc = get_doc(borrower_section),
         match_doc = get_doc(match_section)) |>
  left_join(regs_borrower, by = "borrower_doc") |>
  left_join(regs_match, by = "match_doc")

best_matches <- all_matches |>
  filter(borrower_date >= match_date) |>
  filter(borrower_doc != match_doc) |>
  select("borrower_section",
         "match_section",
         score,
         starts_with("borrower_"),
         starts_with("match_"),
         everything()) |>
  arrange(desc(score))

fs::dir_create("tmp")

write_rds(best_matches, "tmp/best-matches.rds", compress = "xz")
write_rds(sections, "tmp/sections.rds", compress = "xz")
