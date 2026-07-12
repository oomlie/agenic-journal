{
  description = "agenic-journal: text-based, git-backed daily journaling CLI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "agenic-journal";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/bin $out/share/agenic-journal
            install -Dm755 scripts/journal $out/bin/journal
            cp -r templates .githooks $out/share/agenic-journal/
            wrapProgram $out/bin/journal --prefix PATH : ${pkgs.lib.makeBinPath [
              pkgs.git pkgs.python3 pkgs.gnused pkgs.gnugrep pkgs.coreutils pkgs.findutils
            ]}
          '';
        };
        apps.default = { type = "app"; program = "${self.packages.${system}.default}/bin/journal"; };
        devShells.default = pkgs.mkShell { packages = [ pkgs.git pkgs.python3 ]; };
      });
}
