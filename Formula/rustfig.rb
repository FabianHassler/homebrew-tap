class Rustfig < Formula
  desc "Drawing program reimplementing xfig, with fig2dev built in"
  homepage "https://github.com/FabianHassler/rustfig"
  url "https://github.com/FabianHassler/rustfig/archive/refs/tags/v0.9.0-beta.5.tar.gz"
  sha256 "bf53d798fbeaa97b6977dc30ef4eda94dc48d9d8d598b098ba83d00fa332a4be"
  license all_of: [
    "Xfig",
    any_of: ["MIT", "Apache-2.0"],
  ]
  head "https://github.com/FabianHassler/rustfig.git", branch: "main"

  option "with-fig2dev", "Also install RustFig's fig2dev as `fig2dev` (replaces Homebrew's fig2dev)"

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
  end

  def caveats
    <<~EOS
      RustFig runs fig2dev's command line as `rustfig fig2dev ARGS...`.
      For a plain `fig2dev` command, install with --with-fig2dev (a link
      to rustfig) or install fabianhassler/tap/fig2dev-rs. Either replaces
      Homebrew's fig2dev: `brew unlink fig2dev` first. xfig-qt can then use
      it when installed with --without-fig2dev.
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
    assert_path_exists share/"rustfig/libraries/Feynman/fermion.fig"
    system bin/"rustfig", "fig2dev", "-L", "eps", "box.fig", "box.eps"
    assert_match "%!PS-Adobe", (testpath/"box.eps").read
    if build.with? "fig2dev"
      system bin/"fig2dev", "-L", "svg", "box.fig", "box.svg"
      assert_match "<svg", (testpath/"box.svg").read
    end
  end
end
