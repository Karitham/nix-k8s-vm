{
  pkgs,
  modulesPath,
  ...
}: {
  # https://github.com/tfc/nixos-openstreetmap
  imports = [(modulesPath + "/virtualisation/qemu-vm.nix")];
  virtualisation.diskSize = 1024 * 8;
  virtualisation.memorySize = 1024 * 4;
  virtualisation.graphics = false;

  # https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/nixos/modules/virtualisation/qemu-vm.nix
  virtualisation.forwardPorts = [
    {
      from = "host";
      host.port = 2221;
      guest.port = 22;
    }
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # You need at least port 6443 for the API server.
  networking.firewall.enable = false;

  services.k3s.enable = true;

  environment.systemPackages = with pkgs; [jq kubernetes-helm];
  environment.variables = {
    KUBECONFIG = "/root/.kube/config";
  };

  # copy kubeconfig /root/.kube/config
  system.activationScripts.copyKubeconfig = ''
    mkdir -p /root/.kube
    ln -s /etc/rancher/k3s/k3s.yaml /root/.kube/config
    chmod 600 /root/.kube/config
  '';
}
