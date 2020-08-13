pdf: lsquic-slides.pdf

html: lsquic-slides.html

lsquic-slides.html: lsquic-slides.md Makefile
	pandoc --self-contained -t dzslides -s lsquic-slides.md -o lsquic-slides.html

lsquic-slides.pdf: lsquic-slides.md Makefile
	pandoc -t beamer -V theme:Madrid -V aspectratio:169 \
		-V mainfont:"Times New Roman" -s lsquic-slides.md -o lsquic-slides.pdf
