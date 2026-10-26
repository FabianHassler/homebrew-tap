class Fig2devRs < Formula
  desc "Fig2dev, the xfig figure converter, ported to Rust"
  homepage "https://github.com/FabianHassler/fig2dev"
  url "https://github.com/FabianHassler/fig2dev/archive/refs/tags/v0.9.2.tar.gz"
  sha256 "223fed5a7e30608d6fe164022dbe47f425d89becc77d33075f7a5266721c5a2d"
  license all_of: [
    "Xfig",
    any_of: ["MIT", "Apache-2.0"],
  ]
  head "https://github.com/FabianHassler/fig2dev.git", branch: "main"

  depends_on "rust" => :build
  depends_on "ghostscript" => :recommended

  conflicts_with "fig2dev", because: "both install a `fig2dev` executable"

  def install
    system "cargo", "install", *std_cargo_args(path: "apps/fig2dev")
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
    system bin/"fig2dev", "-L", "svg", "box.fig", "box.svg"
    assert_match "<svg", (testpath/"box.svg").read
    system bin/"fig2dev", "-L", "eps", "box.fig", "box.eps"
    assert_match "%!PS-Adobe", (testpath/"box.eps").read
  end
end
