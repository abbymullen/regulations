suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(textreuse))
options("mc.cores" = 8L)

regs <- read_csv("data/regulations.csv",
                 col_types = cols(
                   id = col_character(),
                   date = col_integer(),
                   navy = col_character(),
                   title = col_character()
                 ))

h <- 960
b <- 480
minhash <- minhash_generator(n = h, seed = 2008)

sections <- TextReuseCorpus(dir = "data/regulations-split",
                            tokenizer = tokenize_ngrams,
                            n = 5,
                            keep_tokens = FALSE,
                            minhash_func = minhash)

buckets <- lsh(sections, bands = b)

scores <- buckets %>%
  lsh_candidates() %>%
  lsh_compare(sections, jaccard_similarity)

scores_swapped <- scores %>%
  rename(b2 = a, a2 = b) %>%
  rename(a = a2, b = b2)

scores_for_join <- bind_rows(scores, scores_swapped) %>%
  rename(borrower_section = a,
         match_section = b)


get_doc <- function(x) {
  str_extract(x, "\\w{2,3}-\\d{4}")
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
  select("borrower_section", "match_section", score, starts_with("borrower_"), starts_with("match_"), everything()) |>
  arrange(desc(score))

fs::dir_create("tmp")

write_rds(best_matches, "tmp/best-matches.rds", compress = "xz")
write_rds(sections, "tmp/sections.rds", compress = "xz")
