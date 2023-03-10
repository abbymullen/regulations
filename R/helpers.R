regs_tokenizer <- function(x) {
  tokenizers::tokenize_ngrams(x, n_min = 3, n = 5, simplify = TRUE)
}

clean_texts <- function(texts, stops) {
  require(stringr)
  out <- vector("character", length(texts))
  names(out) <- names(texts)
  for (i in seq_len(length(out))) {
    current_text <- stringr::str_to_lower(texts[i])
    for (y in seq_len(length(stops))) {
      current_text <- stringr::str_replace_all(current_text, stops[y], "")
    }
    out[i] <- current_text
  }
  return(out)
}

testdocs <- c(
  "This document contains a forbidden phrase which ought to be removed posthaste.",
  "This document ought to be removed as soon as possible"
  )
testout <- clean_texts(testdocs, c("ought to be removed", "forbidden phrase"))
expectedout <- c("this document contains a  which  posthaste.", "this document  as soon as possible")

stopifnot(all(testout == expectedout))

