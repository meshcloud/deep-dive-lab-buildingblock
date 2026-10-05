{
  description = "Deep Dive Lab: working as an agentic platform engineer";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          # The meshStack CLI is not in nixpkgs — install it separately (see the hub docs). Everything
          # else the lab needs is here. `nix develop` writes flake.lock on first run.
          packages = [ pkgs.opentofu pkgs.jq pkgs.gh pkgs.openssh pkgs.python3 ];
        };
      });
}
