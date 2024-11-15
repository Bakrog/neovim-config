# neovim config


This is a neovim configuration based on my preferences. All the keymappings
are based on my personal preferences, please change them to suit your setup.

## Dependencies

* [ripgrep](https://github.com/BurntSushi/ripgrep)
* [fd](https://github.com/sharkdp/fd)
* [fzf](https://github.com/junegunn/fzf)
* [cmake](https://formulae.brew.sh/formula/cmake)
* [nerd-fonts](https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#font-installation)
* [nextest](https://nexte.st/docs/installation/pre-built-binaries/#macos-universal)


## Installation

1. Clone this repository to `~/.config/nvim`:

```sh
git clone git@github.com:Bakrog/neovim-config.git ~/.config/nvim
```

2. Start neovim and everything should be installed automatically.

3. Ignore your projects.json file with the command:

```sh
git update-index --assume-unchanged lua/flaviosiqueira/plugins/11-projects.json
```
