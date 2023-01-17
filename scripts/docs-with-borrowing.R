library(tidyverse)
library(textreuse)

sections <- read_rds("tmp/sections.rds")
best_matches <- read_rds("tmp/best-matches.rds")

best_matches <- best_matches |>
  filter(score > 0.02) |>
  arrange(borrower_section, desc(score)) |>
  group_by(borrower_section) |>
  mutate(match_num = row_number(match_section)) |>
  ungroup()

max_matches <- max(best_matches$match_num)

output <- tibble(id = character(), text = character())

for (i in seq_len(max_matches)) {
  col_name <- str_c("match_", i)
  output[[col_name]] <- ""
}

row_num <- 1
for (section in names(sections)) {
  output[row_num, "id"] <- section
  output[row_num, "text"] <- sections[[section]] |> content() |> as.character()

  current_matches <- best_matches |> filter(borrower_section == section)

  for (match in seq_len(nrow(current_matches))) {
    match_col <- str_c("match_", current_matches[match, "match_num"])
    match_section <- current_matches[[match, "match_section"]]
    match_score <- current_matches[[match, "score"]]
    match_text <- sections[[match_section]] |> content() |> as.character()
    output[row_num, match_col] <- str_c(match_section, " (", match_score,  "): ", match_text)
  }

  row_num <- row_num + 1
}

output <- output |> filter(str_detect(id, "^usn"))

write_csv(output, "tmp/usn-regulations-with-matches.csv", na = "")
