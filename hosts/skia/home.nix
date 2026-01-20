{pkgs, ...}: {
  home.modules = {
    developer = false;
    personal = false;
    work = false;
    hipster = false;
    extraPackages = [
      pkgs.k9s # Kubernetes CLI To Manage Your Clusters In Style
      pkgs.kubectl # Production-Grade Container Scheduling and Management
      pkgs.kubectl-cnpg # Plugin for kubectl to manage a CloudNativePG cluster in Kubernetes
      pkgs.kubectx # Fast way to switch between clusters and namespaces in kubectl!
      pkgs.kubent # Easily check your cluster for use of deprecated APIs
      pkgs.kubernetes-helm # Package manager for kubernetes
      pkgs.skaffold # Easy and Repeatable Kubernetes Development
      pkgs.dive # A tool for exploring each layer in a docker image
      pkgs.docker # NVIDIA Container Toolkit
      pkgs.docker-compose # Multi-container orchestration for Docker
      pkgs.lazydocker # A simple terminal UI for both docker and docker-compose
    ];
  };
}
