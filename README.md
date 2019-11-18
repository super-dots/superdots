# superdots

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Intro](#intro)
- [Quick Start](#quick-start)
- [System Functions](#system-functions)
- [Efficiency Functions](#efficiency-functions)
- [Plugins](#plugins)
- [History](#history)
- [Notes](#notes)

## Intro

Superdots is a shell environment plugin framework that focuses on workflow
efficiency. Specific focus is placed on the efficiency of:

* Shell environment management
* Dot-file Organization (e.g. vim configurations/scripts)
* User-friendly command saving/recall ([`fn*` functions](#fn-functions))
* Context switching ([`work` function](#work-function))

As opposed to [other](https://github.com/ohmybash/oh-my-bash) [terminal](https://github.com/Bash-it/bash-it)
[frameworks](https://github.com/robbyrussell/oh-my-zsh) that focus on
encapsulating specific functionality as plugins, superdots sets its focus on
capturing the higher level, overall shell environment of users as shareable
plugins.

As an example, user1 could share their tmux, vim, and bash configurations as
a single superdots plugin. Another user's personal workspace might
be a mix of user1's superdots plugin (bash/tmux/vim settings) and their own
personal customizations.

Another common situation is when separate personal and work shell
environments are needed. A work shell environment is often a blend of personal
settings and work-specific configurations. A user could define their
base/personal shell environment in a superdots plugin saved to GitHub, and
define a separate work-specific superdots plugin that is committed to a
repository at work.

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

| Command   | Example             | Note                                                                          |
|-----------|---------------------|-------------------------------------------------------------------------------|
| `fn_edit` | `fn_edit python`    | Edit `${SUPERDOTS}/dots/local/bash-sources/python.sh` file for editing in vim |
| `fn_new`  | `fn_new python`     | Expand new_fn snippet within `${SUPERDOTS}/dots/local/bash-sources/python.sh` |
| `fn`      | `fn a_function`     | A proxy to support tab-completion with superdots-specific functions           |
| `fn_src`  | `fn_src a_function` | Print the source of the function `a_function` to stdout                       |
| `work`    | `work new_project`  | Creates or reattaches to an existing tmux session named `new_project`         |

### Fn Functions

`fn_edit`

![fn_edit](https://user-images.githubusercontent.com/5090146/69009445-0ff10c80-090a-11ea-9c7a-ef7b6a789da9.gif)

`fn_new`

![fn_new](https://user-images.githubusercontent.com/5090146/69009491-6d855900-090a-11ea-8d01-a7f5f880ceb0.gif)

`fn` - tab completion

![fn](https://user-images.githubusercontent.com/5090146/69009521-bd642000-090a-11ea-9433-02f123025738.gif)

`fn_src` - Display source of the specified function

![fn_src](https://user-images.githubusercontent.com/5090146/69000367-6bc48280-0883-11ea-8cb2-41b158cf9231.gif)

### Work Function

`work` - new session

![work](https://user-images.githubusercontent.com/5090146/69009645-3c0d8d00-090c-11ea-9506-f3ff840313b1.gif)

`work` - reattach to an existing session

![work_reattach](https://user-images.githubusercontent.com/5090146/69009647-4b8cd600-090c-11ea-8de2-5a871be6e501.gif)

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

A list of plugins is kept below:

---

**DISCLAIMER** The maintainers of superdots make no claim as to the reliability, security, or intentions of the following superdots plugins.

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
* 
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
