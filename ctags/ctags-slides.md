% Using tags with Perl
% Dmitri Tikhonov
% PPW 2014

# Outline

- Short demo
- Tools to create tag files
- Setting up Vim
- Basic Vim commands
- What is inside tag files?
- Tag for other things
- Write your own tag-producing code
- Merging tag files
- Contribute to development

# Short Demo

# Tools to create tag files

- Exuberant Ctags
    - Supports multiple languages
    - Written in C
    - Fast, basic, gets job done
    - I am the maintainer of the Perl part
- Perl::Tags
    - Perl source only
    - Written in Perl
    - Indexes more objects; may be slow
    - I contributed some tidbits to it

# Exuberant Ctags

## Supports Many Languages

Ant Asm Asp Awk Basic BETA C C++ C# Cobol DosBatch Eiffel Erlang Flex
Fortran Go HTML Java JavaScript Lisp Lua Make MatLab ObjectiveC OCaml
Pascal Perl PHP Python REXX Ruby Scheme Sh SLang SML SQL Tcl Tex Vera
Verilog VHDL Vim YACC

# ctags command line

- Extensive set of command-line options
- Which files to index
- Specifying output
- Associate files with languages
- And more
- ...and more

# Which files to index

~~~
# Index one file:
ctags my-file.pm

# Index a bunch recursively
ctags -R dir dir dir

# Index everything in @INC:
ctags -R `perl -e 'print "@INC"'`
~~~

# Specifying output

- By default, `tags` is created
- Use `-f` option to override
- `-f-` prints to stdout

# Setting up Vim

- :set iskeyword+=:

# Basic Vim commands

- Ctrl + ]
- g + ]
- Ctrl + t
- :tags

# What is inside tag files?

# Tag for other things

# Write your own tag-producing code

# Merging tag files

# Contribute to development
