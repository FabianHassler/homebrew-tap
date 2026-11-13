cask "rustfig" do
  version "0.9.0-beta.11"
  sha256 "859319bb8c0f6ede2423f02023c20082e745aed574e84ecbcfac3a377a82f4ab"

  url "https://github.com/FabianHassler/rustfig/releases/download/v#{version}/RustFig-#{version}-macos.dmg"
  name "RustFig"
  desc "Drawing program reimplementing xfig, with Quick Look previews for .fig files"
  homepage "https://github.com/FabianHassler/rustfig"

  depends_on arch: :arm64
  depends_on macos: :monterey

  app "RustFig.app"

  caveats <<~EOS
    RustFig is not signed by Apple. If macOS refuses to open it, install with
      brew install --cask --no-quarantine fabianhassler/tap/rustfig
    or allow it once in System Settings > Privacy & Security.

    Open RustFig once so that macOS registers its Quick Look extensions
    (thumbnails in the Finder, space bar preview for .fig files).
    The command-line tools come with the formula: brew install fabianhassler/tap/rustfig
  EOS
end
