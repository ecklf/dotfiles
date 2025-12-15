{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API (iHD) userspace
      vpl-gpu-rt # oneVPL (QSV) runtime
      intel-compute-runtime # OpenCL (NEO) + Level Zero for Arc/Xe
    ];
  };
  # Prefer modern iHD backend
  # https://wiki.nixos.org/wiki/Intel_Graphics
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}
