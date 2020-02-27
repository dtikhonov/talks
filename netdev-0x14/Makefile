html: lsquic-slides.html

pdf: lsquic-slides.pdf

lsquic-slides.html: lsquic-slides.md Makefile
	pandoc --self-contained -t s5 -s lsquic-slides.md -o lsquic-slides.html

lsquic-slides.pdf: lsquic-slides.md Makefile
	pandoc -t beamer -V theme:Madrid -V aspectratio:169 \
		-V mainfont:"Times New Roman" -s lsquic-slides.md -o lsquic-slides.pdf
