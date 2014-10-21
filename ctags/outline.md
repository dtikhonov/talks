Using tags with Perl code
=========================

Abstract
--------

A tags file is an index of Perl code: function definitions, packages,
constants, and so on.  Most popular text editors support tags and
make Perl code easy to browse.  We will cover how to create tags files
for Perl code: tools, editors, patterns.

We will take a quick glance at structure of tags file and see that it
is pretty simple.  One can create tags files for Perl-related stuff,
for example configuration files read by AppConfig.

Outline
-------

- Short demonstration of browsing tagged Perl code
- Tools to generate tags file
    - Exuberant Ctags (my preferred tool)
    - Perl::Tags
- Running ctags
- Setting up Vim
- Basic Vim commands related to tags
- Advanced use: tag other things, like config file
- Write a short script to tag ini-style config files (AppConfig)
- Use more than one tags file in Vim
- Merging tags files
- Contribute to development: both Exuberant Ctags and
  Perl::Tags are on GitHub.

Requirements
------------

A computer running *NIX with Perl, Vim, and Exuberant Ctags.  Preferably,
the latest version of Ctags.

# vim:tw=73:spell:
