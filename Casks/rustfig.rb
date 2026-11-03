cask "rustfig" do
  version "0.9.0-beta.8"
  sha256 "f98d4abeff8ce206d48d91b397d61ebcf7a989e9be479f5414e581c7aadaec8e"

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
