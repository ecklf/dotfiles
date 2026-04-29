# Overlay for latest AI coding agents (codex, opencode)
# These packages are fetched directly from GitHub releases for the latest versions
final: prev: let
  # Helper to select the correct architecture
  getArch = system:
    {
      "aarch64-darwin" = "darwin-arm64";
      "x86_64-darwin" = "darwin-x64";
      "aarch64-linux" = "linux-arm64";
      "x86_64-linux" = "linux-x64";
    }
    .${system}
    or (throw "Unsupported system: ${system}");

  getCodexArch = system:
    {
      "aarch64-darwin" = "aarch64-apple-darwin";
      "x86_64-darwin" = "x86_64-apple-darwin";
      "aarch64-linux" = "aarch64-unknown-linux-gnu";
      "x86_64-linux" = "x86_64-unknown-linux-gnu";
    }
    .${system}
    or (throw "Unsupported system: ${system}");

  system = prev.stdenv.hostPlatform.system;
in {
  # OpenCode - latest from GitHub releases
  opencode = prev.stdenv.mkDerivation rec {
    pname = "opencode";
    version = "1.14.28";

    src = prev.fetchurl {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-${getArch system}.zip";
      hash =
        {
          "aarch64-darwin" = "sha256-oKl3Qc1rJ/tVWJQrLVZGDIW3bToDrTlpCj+ShUXDHMM=";
          "x86_64-darwin" = "sha256-BsLDCY+DMqgsHB4enfdWFaX082Q4QeLe1OpUhGeuWBM=";
          # Linux hashes need to be updated when testing on Linux
          "aarch64-linux" = prev.lib.fakeHash;
          "x86_64-linux" = prev.lib.fakeHash;
        }
        .${system}
        or prev.lib.fakeHash;
    };

    nativeBuildInputs = [prev.unzip];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 opencode $out/bin/opencode
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "AI-powered coding assistant";
      homepage = "https://github.com/anomalyco/opencode";
      license = licenses.mit;
      platforms = ["aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux"];
      mainProgram = "opencode";
    };
  };

  # Codex (OpenAI) - latest from GitHub releases
  codex = prev.stdenv.mkDerivation rec {
    pname = "codex";
    version = "0.125.0";

    src = prev.fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${getCodexArch system}.tar.gz";
      hash =
        {
          "aarch64-darwin" = "sha256-apJtwMuWOdNJtivtoZB8U8sTSXCefcnPxTJo9DjLdJ8=";
          "x86_64-darwin" = "sha256-w+F0OfTkpYe34WCDvSAZ5ug3H/6tAv2iqiqGXNqFk0g=";
          "aarch64-linux" = "sha256-LQdlJ/11eGVvG4eQZlCtkySndCmYAzmZQRVrYGoWFuY=";
          "x86_64-linux" = "sha256-7qo2FVpOk6PsuvAE6K2cH02dz6J+EYYP58VhBMV9qRw=";
        }
        .${system}
        or prev.lib.fakeHash;
    };

    nativeBuildInputs = [prev.gnutar prev.gzip];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 codex-${getCodexArch system} $out/bin/codex
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "OpenAI Codex CLI - AI-powered coding assistant";
      homepage = "https://github.com/openai/codex";
      license = licenses.asl20;
      platforms = ["aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux"];
      mainProgram = "codex";
    };
  };
}
