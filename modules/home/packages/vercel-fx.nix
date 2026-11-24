{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
}: let
  releases = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      sha256 = "5cacb5b3624a79db8fd4e31dcbc59d6a933d7e5ed4c397776d95df6b618296a9";
    };
    x86_64-darwin = {
      platform = "macos-x86_64";
      sha256 = "984eef6632d7bd27ff7b75befb52b9db32c25287905009db5822f6a669861fec";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      sha256 = "b4633b8987ec43f1b9454e4629f3b5a4f1e086aae36b84ae4fefeacd6a53761f";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      sha256 = "78c155d59fa59e42fd56d93037fd75041868c9c67865e8c7f0ca6dcdfac23e75";
    };
  };
  release = releases.${stdenvNoCC.hostPlatform.system};
in
  stdenvNoCC.mkDerivation rec {
    pname = "vercel-fx";
    version = "0.0.17";

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
