{
  description = "Tooling for the homelab-k3s cluster";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (pkgs: let
      helm = pkgs.wrapHelm pkgs.kubernetes-helm {
        plugins = with pkgs.kubernetes-helmPlugins; [
          helm-diff
          helm-secrets
        ];
      };
    in {
      default = pkgs.mkShell {
        packages = [
          helm
          # helmfile shells out to helm, so it needs the same plugin directory
          # or `helmfile apply` cannot find helm-diff.
          (pkgs.helmfile-wrapped.override {inherit (helm) pluginsDir;})
          pkgs.fluxcd
        ];
      };
    });
  };
}
