class Rustfig < Formula
  desc "Drawing program reimplementing xfig, with fig2dev built in"
  homepage "https://github.com/FabianHassler/rustfig"
  license all_of: [
    "Xfig",
    any_of: ["MIT", "Apache-2.0"],
  ]
  head "https://github.com/FabianHassler/rustfig.git", branch: "main"

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
  end

  def caveats
    <<~EOS
      RustFig runs fig2dev's command line as `rustfig fig2dev ARGS...`.
      For a plain `fig2dev` command, install fabianhassler/tap/fig2dev-rs.
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
    system bin/"rustfig", "fig2dev", "-L", "eps", "box.fig", "box.eps"
    assert_match "%!PS-Adobe", (testpath/"box.eps").read
  end
end
