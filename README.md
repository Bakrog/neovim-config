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
* [debugpy](https://github.com/microsoft/debugpy)
* [llvm](https://formulae.brew.sh/formula/llvm)
* [chromadb](https://docs.trychroma.com/docs/overview/introduction)
    * `mkdir -p ~/.local/share/chroma/data`
    * `docker run -d -v ~/.local/share/chroma/data:/data -p 8000:8000 chromadb/chroma`
* [vectorcode](https://github.com/Davidyz/VectorCode)
    * `~/.config/vectorcode/config.json`:
```json
{
    "host": "127.0.0.1",
    "port": 8000
}
```


## Installation

1. Clone this repository to `~/.config/nvim`:

```sh
git clone git@github.com:Bakrog/neovim-config.git ~/.config/nvim
```

2. Start neovim and everything should be installed automatically.

3. Create your projects.json file with the command:

```sh
touch lua/flaviosiqueira/projects.json
```
