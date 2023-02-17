.PHONY : similarities
similarities : 
	rm -r data/regulations-split
	Rscript scripts/split.R
	Rscript scripts/regulations-pairwise.R

.PHONY: doccf
doccf : 
	Rscript scripts/docs-with-borrowing.R

.PHONY : clean
clean :
	rm -r tmp/* 2> /dev/null || true


