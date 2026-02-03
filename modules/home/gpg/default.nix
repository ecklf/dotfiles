{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  programs.gpg = {
    enable = true;
    settings = {
      # Disable banner
      no-greeting = true;
      # Default key preferences
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      # Use AES256 as the preferred cipher
      cipher-algo = "AES256";
      # Use SHA512 as the preferred hash
      digest-algo = "SHA512";
      # Use UTF-8 for all messages
      display-charset = "utf-8";
      # Long key IDs are more secure
      keyid-format = "0xlong";
      # Show fingerprint
      with-fingerprint = true;
      # Automatically fetch keys from keyserver
      auto-key-retrieve = true;
    };
  };

  services.gpg-agent = lib.mkIf (!isDarwin) {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 14400;
    pinentry.package = pkgs.pinentry-tty;
  };
}
