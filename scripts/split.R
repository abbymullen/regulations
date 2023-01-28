library(fs)
library(stringr)
library(readr)

filenames <- fs::dir_ls("data/regulations")
outdir <- "data/regulations-split"
if(fs::dir_exists(outdir)) {
  stop("Delete the existing splits before running this script")
}
fs::dir_create(outdir)

for (f in filenames) {
  lines <- read_lines(f)
  linenum <- 1
  for (l in lines) {

    outf <- str_c(outdir,
                  "/",
                  tools::file_path_sans_ext(basename(f)),
                  "-",
                  str_pad(linenum, 5, "left", pad = "0"),
                  ".txt")
    write_lines(l, outf)
    linenum <- linenum + 1
  }
}
