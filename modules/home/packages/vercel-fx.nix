{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
}: let
  releases = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      sha256 = "f37eea7eaf248f7a75765fc3f71be77bcfbc43eaef5cbe76d721dadb97479cfe";
    };
    x86_64-darwin = {
      platform = "macos-x86_64";
      sha256 = "becc6f68d42ff20606cd783b72630287ab92bc6eef2d700ed39de17d52b7dd3e";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      sha256 = "432a343b7d0fb15dce454ab1e100401df1ee4f01fb1e689a64557e6b9a57ece5";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      sha256 = "e4912040c1fb2a1cda4162fd8f40fc66aa80a1a0a306af6332b5426bdcac99b6";
    };
  };
  release = releases.${stdenvNoCC.hostPlatform.system};
in
  stdenvNoCC.mkDerivation rec {
    pname = "vercel-fx";
    version = "0.0.18";

    src = fetchurl {
      url = "https://github.com/vercel-labs/fx/releases/download/v${version}/fx-${release.platform}.tar.gz";
      inherit (release) sha256;
    };

    sourceRoot = ".";
    dontBuild = true;
    # Preserve upstream's signed macOS binaries and static Linux binaries.
    dontFixup = true;
    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall
      install -Dm755 fx "$out/libexec/vercel-fx"
      makeWrapper "$out/libexec/vercel-fx" "$out/bin/vercel-fx" \
        --set-default FX_AUTO_UPGRADE 0 \
        --prefix FX_SKILL_SYMLINK_AUTHORITIES : /nix/store
      install -Dm644 LICENSE "$out/share/licenses/vercel-fx/LICENSE"
      install -Dm644 THIRD_PARTY_NOTICES.md "$out/share/licenses/vercel-fx/THIRD_PARTY_NOTICES.md"
      runHook postInstall
    '';

    meta = {
      description = "Minimal native coding agent from Vercel Labs";
      homepage = "https://github.com/vercel-labs/fx";
      license = lib.licenses.asl20;
      mainProgram = "vercel-fx";
      platforms = builtins.attrNames releases;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
