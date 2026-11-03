class Rustfig < Formula
  desc "Drawing program reimplementing xfig, with fig2dev built in"
  homepage "https://github.com/FabianHassler/rustfig"
  url "https://github.com/FabianHassler/rustfig/archive/refs/tags/v0.9.0-beta.8.tar.gz"
  sha256 "15cf5bfa6a04c80b3d250bf6b412c330649cdd82e5cf4770933036915106bd8c"
  license all_of: [
    "Xfig",
    any_of: ["MIT", "Apache-2.0"],
  ]
  head "https://github.com/FabianHassler/rustfig.git", branch: "main"

  option "with-fig2dev", "Also install RustFig's fig2dev as `fig2dev` (replaces Homebrew's fig2dev)"
  option "with-xfig", "Also install an `xfig` command that starts RustFig (replaces Homebrew's xfig)"

  depends_on "rust" => :build
  depends_on "ghostscript" => :recommended

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "gtk+3"
    depends_on "libxcb"
    depends_on "libxkbcommon"
    depends_on "wayland"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "apps/rustfig")
    system "cargo", "install", *std_cargo_args(path: "apps/cli")
    # the figure libraries, found as ../share/rustfig/libraries
    (share/"rustfig").install "libraries"
    # started under the name fig2dev, rustfig runs fig2dev's command line
    bin.install_symlink "rustfig" => "fig2dev" if build.with? "fig2dev"
    # xfig's command line works as is: `xfig file.fig` opens RustFig
    bin.install_symlink "rustfig" => "xfig" if build.with? "xfig"
    if OS.linux?
      # file-manager thumbnails (freedesktop thumbnailer) and the MIME types
      (share/"thumbnailers/rustfig.thumbnailer").write <<~EOS
        [Thumbnailer Entry]
        TryExec=#{opt_bin}/rustfig
        Exec=#{opt_bin}/rustfig thumbnail %i %o --size %s
        MimeType=image/x-xfig;application/x-xfig;text/x-xfig;application/x-rustfig;
      EOS
      # same text as xtask/src/package.rs mime_xml()
      (share/"mime/packages/rustfig.xml").write <<~EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
          <mime-type type="image/x-xfig">
            <comment>xfig drawing</comment>
            <alias type="application/x-xfig"/>
            <alias type="text/x-xfig"/>
            <magic priority="50">
              <match type="string" offset="0" value="#FIG"/>
            </magic>
            <glob pattern="*.fig"/>
            <glob pattern="*.fig.gz"/>
            <glob pattern="*.fig.Z"/>
            <glob pattern="*.fig.bz2"/>
            <glob pattern="*.fig.xz"/>
          </mime-type>
          <mime-type type="application/x-rustfig">
            <comment>RustFig drawing</comment>
            <sub-class-of type="application/json"/>
            <glob pattern="*.rustfig"/>
          </mime-type>
        </mime-info>
      EOS
    end
  end

  def caveats
    <<~EOS
      RustFig runs fig2dev's command line as `rustfig fig2dev ARGS...`.
      For a plain `fig2dev` command, install with --with-fig2dev (a link
      to rustfig) or install fabianhassler/tap/fig2dev-rs. Either replaces
      Homebrew's fig2dev: `brew unlink fig2dev` first. xfig-qt can then use
      it when installed with --without-fig2dev.
      With --with-xfig, `xfig` starts RustFig (unlink Homebrew's xfig first).
      On macOS, the app with Quick Look previews of .fig files comes as a
      cask: brew install --cask fabianhassler/tap/rustfig
      On Linux, file managers show .fig thumbnails when Homebrew's share
      folder is on XDG_DATA_DIRS, e.g. in ~/.profile:
        export XDG_DATA_DIRS="$(brew --prefix)/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      then run: update-mime-database "$(brew --prefix)/share/mime"
    EOS
  end

  test do
    (testpath/"box.fig").write <<~FIG
      #FIG 3.2
      Landscape
      Center
      Inches
      Letter
      100.00
      Single
      -2
      1200 2
      2 2 0 1 0 7 50 -1 -1 0.000 0 0 -1 0 0 5
      \t 0 0 1200 0 1200 1200 0 1200 0 0
    FIG
    system bin/"rustfig-cli", "info", "box.fig"
    system bin/"rustfig", "thumbnail", "box.fig", "box.png", "--size", "64"
    assert_path_exists testpath/"box.png"
    assert_path_exists share/"rustfig/libraries/Feynman/fermion.fig"
    system bin/"rustfig", "fig2dev", "-L", "eps", "box.fig", "box.eps"
    assert_match "%!PS-Adobe", (testpath/"box.eps").read
    system bin/"xfig", "-help" if build.with? "xfig"
    if build.with? "fig2dev"
      system bin/"fig2dev", "-L", "svg", "box.fig", "box.svg"
      assert_match "<svg", (testpath/"box.svg").read
    end
  end
end
