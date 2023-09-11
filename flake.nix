{
  description = "HS dev environment";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  inputs.nix-npm-buildpackage.url = "github:serokell/nix-npm-buildpackage";

  outputs = { self, nixpkgs, flake-utils, nix-npm-buildpackage }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.extend
          nix-npm-buildpackage.overlays.default;
        nodejs = pkgs.nodejs-18_x;
        hubspot-cli = pkgs.buildYarnPackage {
          src = pkgs.fetchFromGitHub {
            owner = "HubSpot";
            repo = "hubspot-cli";
            sparseCheckout = [ "packages/cli" ];
            rev = "0f88273233124d513c4338fed7bd01fa4678251d";
            sha256 = "sha256-Kt8KcEsP85plrE2RjbujXW0rpF7/4BJG3XiGHDWPVi0=";
          };
          postInstall = ''
                          makeWrapper $out/packages/cli/bin/hs $out/bin/hs 
            	    '';
        };
      in {
        packages.default = hubspot-cli;
        app.default = {
          type = "app";
          program = "${hubspot-cli}/bin/hs";
        };
      });
}

