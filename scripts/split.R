library(fs)
library(stringr)

filenames <- fs::dir_ls("data/regulations")
outdir <- "data/regulations-split"
fs::dir_create(outdir)

for (f in filenames) {
  lines <- readLines(f, encoding = "UTF-8")
  linenum <- 1
  for (l in lines) {

    outf <- str_c(outdir,
                  "/",
                  tools::file_path_sans_ext(basename(f)),
                  "-",
                  str_pad(linenum, 5, "left", pad = "0"),
                  ".txt")
    writeLines(l, outf)
    linenum <- linenum + 1
  }
}
