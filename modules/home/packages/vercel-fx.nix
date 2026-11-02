{
  lib,
  stdenvNoCC,
  fetchurl,
}: let
  releases = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      sha256 = "2158a8d42e77457a774400d225d9802bb6c0e60a0bb0674a1116bc31252490d6";
    };
    x86_64-darwin = {
      platform = "macos-x86_64";
      sha256 = "b287974f97a0879f50b4439c46537fcd44b83326c11a230d87f596073f8d8d9b";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      sha256 = "ca9441b104357e2105039dbfd4c2eaf0d6ee65a84085f23f51e880c95cbf46af";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      sha256 = "f0fb822c7be546c80bcc89d50521bc1454435e0c6f586e8420c4e2b84fa80599";
    };
  };
  release = releases.${stdenvNoCC.hostPlatform.system};
in
  stdenvNoCC.mkDerivation rec {
    pname = "vercel-fx";
    version = "0.0.16";

    src = fetchurl {
      url = "https://github.com/vercel-labs/fx/releases/download/v${version}/fx-${release.platform}.tar.gz";
      inherit (release) sha256;
    };

    sourceRoot = ".";
    dontBuild = true;
    # Preserve upstream's signed macOS binaries and static Linux binaries.
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 fx "$out/bin/vercel-fx"
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
