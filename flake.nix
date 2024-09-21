{
  description = "nix-python-uv-hybrid-example";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs-unstable, nixpkgs }:
    {
      devShell.x86_64-linux = (
        let
          system = "x86_64-linux";

          nixpkgsSystem = import nixpkgs { inherit system; config.allowUnfree = true; };
          nixpkgsSystemUnstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };

          lib = nixpkgsSystem.lib;
          lib-unstable = nixpkgsSystemUnstable.lib;

          pkgs = nixpkgsSystem.pkgs;
          pkgs-unstable = nixpkgsSystemUnstable.pkgs;

          uvPythonEnvironment = pkgs.python312.withPackages (p: (
            lib.unique (lib.flatten (map (source: import source { pythonPackages = p; }) pythonRequirementsSources))
          ));

          pythonRequirementsSources = [
            ./python-requirements.nix
          ];
        in
        pkgs.mkShell
          {
            nativeBuildInputs = (
              with pkgs; [
                pkgs-unstable.ruff
                pkgs-unstable.uv
                uvPythonEnvironment
              ]
            );
            shellHook = ''
              export UV_PYTHON_ENV_SITE_PACKAGES="${uvPythonEnvironment}/${uvPythonEnvironment.sitePackages}";
            '';
          }
      );
    };
}
