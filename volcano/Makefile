html: volcano-slides.html

pdf: volcano-slides.pdf

volcano-slides.html: volcano-slides.md Makefile
	pandoc --self-contained -t dzslides -s volcano-slides.md -o volcano-slides.html

volcano-slides.pdf: volcano-slides.md Makefile
	pandoc -t beamer -s volcano-slides.md -o volcano-slides.pdf
