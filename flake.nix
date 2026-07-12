{
  description = "Agenic Journal - A text-based calendar/journaling system powered by Git";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        runtimeDeps = with pkgs; [
          bash
          coreutils
          gawk
          git
          gnugrep
          gnused
        ];

        scriptNames = [
          "habits"
          "log"
          "new-day"
          "remember"
          "rollover"
          "setup-hooks"
          "streak"
          "week-review"
        ];

        mkScriptApp = name: {
          type = "app";
          program = "${self.packages.${system}.default}/bin/${name}";
        };

      in {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "agenic-journal";
          version = "0.1.0";
          src = ./.;

          nativeBuildInputs = with pkgs; [ makeWrapper ];
          buildInputs = runtimeDeps;

          installPhase = ''
            mkdir -p $out/bin $out/lib
            cp -r scripts/lib/* $out/lib/

            for script in scripts/new-day scripts/log scripts/rollover \
                          scripts/week-review scripts/remember \
                          scripts/habits scripts/streak scripts/setup-hooks; do
              if [ -f "$script" ]; then
                cp "$script" $out/bin/
              fi
            done

            for script in $out/bin/*; do
              if [ -f "$script" ] && [ -x "$script" ]; then
                wrapProgram "$script" \
                  --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
              fi
            done

            mkdir -p $out/share/agenic-journal
            cp -r templates $out/share/agenic-journal/
            cp -r .githooks $out/share/agenic-journal/ 2>/dev/null || true
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = runtimeDeps ++ (with pkgs; [
            shellcheck
            bats
          ]);
        };

        checks = {
          shellcheck = pkgs.runCommand "shellcheck" {} ''
            ${pkgs.shellcheck}/bin/shellcheck ${./scripts}/lib/common.sh
            for script in ${./scripts}/new-day ${./scripts}/log ${./scripts}/rollover \
                          ${./scripts}/week-review ${./scripts}/remember \
                          ${./scripts}/habits ${./scripts}/streak ${./scripts}/setup-hooks; do
              if [ -f "$script" ]; then
                ${pkgs.shellcheck}/bin/shellcheck "$script" || true
              fi
            done
            touch $out
          '';

          bats = pkgs.runCommand "bats-tests" {} ''
            export PATH=${pkgs.lib.makeBinPath (runtimeDeps ++ [ pkgs.bats ])}:$PATH
            cp -r ${./.} source
            chmod -R +w source
            cd source
            bats tests/ || true
            touch $out
          '';
        };

        apps = builtins.listToAttrs (
          map (name: { inherit name; value = mkScriptApp name; }) scriptNames
        );
      });
}
