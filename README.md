# FabianHassler/homebrew-tap

Homebrew formulae by Fabian Hassler.

| Formula | What |
|---|---|
| `xfig-qt` | [xfig](https://github.com/FabianHassler/xfig-qt) 3.2.9a as a native Qt 6 application, without X11 |
| `rustfig` | [RustFig](https://github.com/FabianHassler/rustfig), a reimplementation of xfig in Rust, with fig2dev built in (`rustfig fig2dev …`) |
| `fig2dev-rs` | [fig2dev](https://github.com/FabianHassler/fig2dev) 3.2.9a ported to Rust, installed as `fig2dev` |

```sh
brew install fabianhassler/tap/xfig-qt
brew install fabianhassler/tap/rustfig
brew install fabianhassler/tap/fig2dev-rs
```

Homebrew's X11 `xfig` also installs an `xfig` command: `brew unlink xfig`
first if you have it. Likewise `fig2dev-rs`, `rustfig --with-fig2dev` and
Homebrew's C `fig2dev` all install `fig2dev`: keep one of them linked.

`xfig-qt` uses the C `fig2dev` by default. To run it on RustFig's instead:

```sh
brew uninstall --ignore-dependencies fig2dev   # if installed
brew install fabianhassler/tap/rustfig --with-fig2dev
brew install fabianhassler/tap/xfig-qt --without-fig2dev
```
