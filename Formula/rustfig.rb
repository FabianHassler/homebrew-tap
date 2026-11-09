class Rustfig < Formula
  desc "Drawing program reimplementing xfig, with fig2dev built in"
  homepage "https://github.com/FabianHassler/rustfig"
  url "https://github.com/FabianHassler/rustfig/archive/refs/tags/v0.9.0-beta.9.tar.gz"
  sha256 "dcc401cba4c145f7886347b011347928c5ffcf7668e2499e4b7ac83673d337c5"
  license all_of: [
    "Xfig",
    any_of: ["MIT", "Apache-2.0"],
  ]
  head "https://github.com/FabianHassler/rustfig.git", branch: "main"

  option "with-fig2dev", "Also install RustFig's fig2dev as `fig2dev` (replaces Homebrew's fig2dev)"
  option "with-xfig", "Also install an `xfig` command that starts RustFig (replaces Homebrew's xfig)"

  depends_on "rust" => :build
  depends_on "ghostscript" => :optional

  on_linux do
    depends_on "pkgconf" => :build
    depends_on "gtk+3"
    depends_on "libxcb"
    depends_on "libxkbcommon"
    depends_on "wayland"
  end

  # From beta.9 on, rustfig is one program: started as rustfig-cli it runs the
  # command line, and `cargo xtask package --app-only` builds the macOS app.
  def one_program?
    build.head? || version > Version.new("0.9.0-beta.8")
  end

  def install
    if OS.mac? && one_program?
      # RustFig.app with the Quick Look extensions (Finder thumbnails and the
      # space-bar preview of .fig files); bin/rustfig is the app's program
      system "cargo", "run", "--release", "--locked", "-p", "xtask", "--", "package", "--app-only"
      prefix.install "target/package/RustFig.app"
      bin.install_symlink prefix/"RustFig.app/Contents/MacOS/rustfig"
    else
      system "cargo", "install", *std_cargo_args(path: "apps/rustfig")
    end
    if one_program?
      bin.install_symlink "rustfig" => "rustfig-cli"
    else
      system "cargo", "install", *std_cargo_args(path: "apps/cli")
    end
    # the figure libraries, found as ../share/rustfig/libraries (the app finds
    # them from RustFig.app/Contents/MacOS too)
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
      On macOS, RustFig.app with Quick Look previews of .fig files is in
        #{opt_prefix}/RustFig.app
      (from beta.9 on, and with --HEAD). For Launchpad and Spotlight, link it:
        ln -sf #{opt_prefix}/RustFig.app ~/Applications/
      Open the app once, so that macOS registers its Quick Look extensions
      (Finder thumbnails, space-bar preview):
        open #{opt_prefix}/RustFig.app
      The cask fabianhassler/tap/rustfig installs the same app into
      /Applications: use one of the two.
      On Linux, file managers show .fig thumbnails when Homebrew's share
      folder is on XDG_DATA_DIRS, e.g. in ~/.profile:
        export XDG_DATA_DIRS="$(brew --prefix)/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      then run: update-mime-database "$(brew --prefix)/share/mime"
      Ghostscript is only needed to show EPS pictures inside figures (canvas,
      PDF and bitmap exports): `brew install ghostscript`, or reinstall with
      --with-ghostscript.
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
