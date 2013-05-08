thoughtbot dotfiles
===================

Prerequisites
-------------

You need to have the following installed: zsh, oh-my-zsh, vim, ag, tmux, and git.

Install
-------

Clone:

    git clone git://github.com/crueber/dotfiles.git
    cd dotfiles
    ./install.sh

This will create symlinks for config files in your home directory. 

What's in it?
-------------

[vim](http://www.vim.org/) configuration:

* [Ctrl-P](https://github.com/kien/ctrlp.vim) for fuzzy file/buffer/tag finding.
* [Rails.vim](https://github.com/tpope/vim-rails) for enhanced navigation of
  Rails file structure via `gf` and `:A` (alternate), `:Rextract` partials,
  `:Rinvert` migrations, etc.
* Run [RSpec](https://www.relishapp.com/rspec) specs from vim.
* Set `<leader>` to a single space.
* Switch between the last two files with space-space.
* Syntax highlighting for CoffeeScript, Textile, Cucumber, Haml, Markdown, and
  HTML.
* Use [Ag](https://github.com/ggreer/the_silver_searcher) instead of Grep when
  available.
* Use [Exuberant Ctags](http://ctags.sourceforge.net/) for tab completion.
* Use [Vundle](https://github.com/gmarik/vundle) to manage plugins.

[tmux](http://robots.thoughtbot.com/post/2641409235/a-tmux-crash-course)
configuration:

* Improve color resolution.
* Remove administrative debris (session name, hostname, time) in status bar.
* Set prefix to `Ctrl+a` (like GNU screen).
* Soften status bar color from harsh green to light gray.

[git](http://git-scm.com/) configuration:

* Adds a `create-branch` alias to create feature branches.
* Adds a `delete-branch` alias to delete feature branches.
* Adds a `merge-branch` alias to merge feature branches into master.

Shell aliases and scripts:

* `b` for `bundle`.
* `g` with no arguments is `git status` and with arguments acts like `git`.
* `git-churn` to show churn for the files changed in the branch.
* `load-backup-into development` or `load-backup-into staging` to load latest
  production database backup into development/staging.
* `m` for `rake db:migrate && rake db:rollback && rake db:migrate && rake db:test:prepare`.
* `mcd` to make a directory and change into it.
* `production backup`, `production migrate`, `production tail`, `watch
  production ps`, etc. to interact with production Heroku environment. This
  script also acts as a pass-through so you can do anything with it that you can
  do with `heroku _______ -r production`.
* `rake` is `zeus rake` if using [Zeus](https://github.com/burke/zeus) on the
  project in current directory.
* `replace foo bar **/*.rb` to find and replace within a given list of files.
* `rk` for `rake`.
* `rspec` is `zeus rspec` if using Zeus on the project in current directory.
* `staging` version of `production` script.
* `tat` to attach to tmux session named the same as the current directory.
* `v` for `$VISUAL`.

Credits
-------

This dotfiles repository is maintained by [@crueber](http://www.twitter.com/crueber)

Original dotfiles repository concept and basis taken from [ThoughtBot Dotfiles Repository](https://github.com/thoughtbot/dotfiles)
