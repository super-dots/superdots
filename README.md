# superdots

Super dot files.

* Organized
* Usable
* Extendable

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Intro](#intro)
- [Quick Start](#quick-start)
- [System Functions](#system-functions)
- [Efficiency Functions](#efficiency-functions)
  * [Fn Functions](#fn-functions)
  * [Work Function](#work-function)
- [Plugins](#plugins)
  * [Using Existing Plugins](#using-existing-plugins)
  * [Creating Plugins](#creating-plugins)
- [History](#history)
  * [Inspiration](#inspiration)

## Intro

Superdots is a plugin-supporting framework for being efficient in \*nix
environments through:

* User-friendly bash snippet management (`fn*` functions)
* Dot file organization
* Tmux workspace management (`work` function)
* Vim organization

This means you can:

* Easily codify, save, recall, and share accumulated command-line experience
* Have separate/public superdots from your work/private superdots
* Try out someone else's superdots

For example, have you ever tried saving some useful bash snippet you
wrote or came across? How many steps did it take to save it? How many steps did
it take to remember how to use it? What about organizing your bash snippets,
editing them, or sharing with other people?

Superdots aims to solve these problems and make everyone more efficient in
\*nix environments.

## Quick Start

Install superdots by running the commands below:

```bash
git clone https://github.com/super-dots/superdots ~/.superdots
~/.superdots/bin/install
```

![superdots_install](https://user-images.githubusercontent.com/5090146/68075572-ab10b080-fd66-11e9-8e43-91c91a826aa5.gif)

**NOTE**: superdots currently comes default with the [fn-vim](https://github.com/super-dots/fn-vim)
plugin, which adds nicer support for `fn*` functions in vim. If you want a
completely clean super-dots installation, use the `--bare` flag when running
`bin/install`:

```
USAGE: bin/install [--bare] [--help]

This script installs superdots. The default installation comes with
fn-vim installed as a plugin. Use the '--bare' option to install a
bare superdots:

            --bare      Do not install any default plugins
            --help,-h   Show this help message
```

## System Functions

System functions that you will use with superdots are:

| Command             | Example                                      | Note                                       |
|---------------------|----------------------------------------------|--------------------------------------------|
| `superdots`         | `superdots a-user/a-superdots`               | Records github.com/a-user/a-superdots      |
|                     | `superdots git@some.host:group/project.git`  |                                            |
|                     | `superdots https://github.com/group/project` |                                            |
| `superdots-install` | `superdots-install`                          | Ensures all recorded plugins are installed |
| `superdots-update`  | `superdots-update`                           | Updates all recorded superdots plugins     |

## Efficiency Functions

Core functions of superdots are:

| Command   | Example            | Note                                                                          |
|-----------|--------------------|-------------------------------------------------------------------------------|
| `fn_edit` | `fn_edit python`   | Edit `${SUPERDOTS}/dots/local/bash-sources/python.sh` file for editing in vim |
| `fn_new`  | `fn_new python`    | Expand new_fn snippet within `${SUPERDOTS}/dots/local/bash-sources/python.sh` |
| `fn`      | `fn a_function`    | A proxy to support tab-completion with superdots-specific functions           |
| `work`    | `work new_project` | Creates or reattaches to an existing tmux session named `new_project`         |

### Fn Functions

`fn_edit`

TODO add gif

`fn_new`

TODO add gif

`fn` - tab completion

TODO add gif

### Work Function

`work` - new session

TODO add gif

`work` - reattach to an existing session

TODO add gif

`work` - tab completion

TODO add gif

## Plugins

### Using Existing Plugins

After installing superdots, you can record references to external superdots
plugins in your `~/.bashrc` with:

```bash
# ~/.bashrc

superdots a-username/another-superdots-plugin
superdots other-username/their-superdots-plugin
```

Superdots plugins must be explicitly installed using the `superdots-install`
command. This command will clone the referenced repositories into
`$SUPERDOTS/dots`, and source the bash files contained within the repository.

**WAIT** That sounds dangerous! Frankly, it is! This is no different than
pip-installing unknown or untrusted python packages, using vim-plug to install
unverified vim plugins, or installing 1000s of node packages through npm. Be
smart, and exercise the same caution that you do with other package and plugin
managers.

A list of plugins is kept below, sorted by the number of stars the repository
has:

---

**DISCLAIMER** The maintainers of superdots make no claim as to the reliability, security, or intentions of the following superdots plugins. |

---

| repo                                                                  | stars                                                                                     | contributors                                                                               | description                     |
|-----------------------------------------------------------------------|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|---------------------------------|
| [super-dots/fn-vim](https://github.com/super-dots/fn-vim)             | ![GitHub stars](https://img.shields.io/github/stars/super-dots/fn-vim?style=social)       | ![GitHub contributors](https://img.shields.io/github/contributors/super-dots/fn-vim)       | Vim-specific `fn*` integrations |
| [d0c-s4vage/my-superdots](https://github.com/d0c-s4vage/my-superdots) | ![GitHub stars](https://img.shields.io/github/stars/d0c-s4vage/my-superdots?style=social) | ![GitHub contributors](https://img.shields.io/github/contributors/d0c-s4vage/my-superdots) | d0c-s4vage's personal superdots |

### Creating Plugins

Creating your own superdots plugin is straightforward. For best results, use
the [plugin-template](https://github.com/super-dots/plugin-template)
cookiecutter template to initialize a new superdots plugin.

The minimum requirement is a directory structure as shown below:

```
./
├── bash-source-pre
├── bash-sources
└── vim-sources

3 directories, 0 files
```

Your plugin can be added to your `~/.bashrc` as a superdots plugin with the
`superdots` command:

```bash
# ~/.bashrc

superdots my-username/my-superdots-plugin # Github
superdots git@somewhere.else:my-username/my-superdots-plugin.git # elsewhere
superdots https://gitlab.com/my-username/my-superdots-plugin.git # elsewhere
```

This functionality should feel similar to [vim-plug](https://github.com/junegunn/vim-plug).

## History

Superdots has evolved over the years as a result of @d0c-s4vage tiring of
having to copy around his dot files as he switched jobs, upgraded computers,
and tried keeping his personal and work metadata in-sync. Things developed
slowly from:

* Copying around dot files, to
* Creating a place to put [dot files on Github](https://github.com/d0c-s4vage/superdots/commit/19ab35560ea0e0e2dfccb2e233d8ad514e04621d), to
* Adding `.vimrc` [to github](https://github.com/d0c-s4vage/superdots/commit/106dfe55950f58c819cc8b50998d3e5d124a0cff)
* [Organizing and categorizing](https://github.com/d0c-s4vage/superdots/commit/81c8dd245a370960a01510a6a511cb7757aa8d2d) `.vimrc` into `vim-scripts`
* Slowly adding [.screenrc](https://github.com/d0c-s4vage/superdots/commit/a16db13babc2fa478fd8ac048a34f1c873114d54), and [organized bash sources](https://github.com/d0c-s4vage/superdots/commit/c8f98cfa1525c01bcad660ee497220ce9addee61) 
* Developing `work` function [for tmux session management](https://github.com/d0c-s4vage/superdots/commit/bf2b25f88d30133a48723595ac54983175384df6#diff-51ee3d2b64fe89b649ef89f583d29ab5R4)
* Developing [bash function management](https://github.com/d0c-s4vage/superdots/commit/f07bf231ee014e2b72a86a6625ef2887ef29d58a) (`fn*` functions), to
* Refactoring to support plugins (this repository), which:
  * Allows separate personal (public on Github) and local (i.e. work) dot file
    management.
  * Let's you easily try out other people's preserved bash knowledge/experience/command snippets via plugins

### Inspiration

Superdots takes inspiration from vim's plugin structure, specifically
[vim-plug](https://github.com/junegunn/vim-plug)'s approach to it.

## Notes

### Vim-Plug

Be aware that vim-plug currently doesn't support multiple plugin sections. See

* [vim-plug#300](https://github.com/junegunn/vim-plug/issues/300)
* [vim-plug#615](https://github.com/junegunn/vim-plug/issues/615)

The last superdots plugin loaded will have the final say on vim-plug
definitions.
