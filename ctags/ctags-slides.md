% Using tags with Perl
% Dmitri Tikhonov
% PPW 2014

# Outline

- Short Demo
- Tools to create tag files
- Exuberant Ctags
- ctags command line
- Which files to index
- Specifying output
- What Perl things are there?
- Very Small Example
- What is inside tag files?
- Basic Vim commands
- Fully Qualified Tags
- Tags for other things
- Using multiple tag files
- Write your own tag-producing code
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

# A bunch of files:
ctags -L bunch-of-files.txt
~~~

# Specifying output

- By default, `tags` is created
- Use `-f` option to override
- `-f-` prints to stdout
- Use `-a` to append to existing tags file
- Use `-e` for emacs (`TAGS` is created)

# Kinds of Perl tags

Ask `ctags --list-kinds=Perl`

- constants
- formats
- labels
- packages
- subroutines
- subroutine declarations

# Very Small Example

~~~perl
package My::Package;
use constant ABC => 123;
sub do_this;
do_this @ARGV;
sub do_this {
    AGAIN: write; shift;
    goto AGAIN if @_;
}
format =
@#####
$_[0]
.
~~~

# What is inside tag files?

- header
- one tag per line
- tags are sorted by default
- vim defaults to binary search

# Basic Vim commands

## Jump to tag:

- I'm feeling lucky: `:tag` or `Ctrl + ]`
- `:tselect` or `g + ]`
- `:tjump` or `g + Ctrl + ]`

## Jump back:
- `Ctrl + t`

## See where you've been:

- `:tags`

# Fully Qualified Tags: Why

## Use case 1

~~~perl
# For calls like this:
File::Temp::unlink0($fh, $local);
~~~

## Use case 2

~~~bash
vi -t Edit::This::function
~~~

# Fully Qualified Tags: How

## Extra option to ctags

`ctags --extra=+q`

## Setting up Vim

~~~vim
:au FileType perl setlocal iskeyword+=:
~~~

# Tags for other things

## Seen in Perl code:

- C
- JavaScript
- SQL
- More

# Using multiple tag files

- In Vim: `:set tags=tags1,tags2`
- Merging tag files
    - For default files, header is optional
    - Merging as easy as

~~~
LC_ALL=C sort tags1 tags2 > tags
~~~

# Write your own tag-producing code

- Easier than one may think
- Just generate some ex commands
- Example: .ini files used by `AppConfig`

# Contribute to development

- https://github.com/fishman/ctags
- https://github.com/osfameron/perl-tags
