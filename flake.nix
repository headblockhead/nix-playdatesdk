{
  description = "All you need: Lua and C APIs, docs, as well as a Simulator for local development, with profiling and more. ";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      version = "2.7.3";
      sdk = pkgs.fetchurl {
        url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-${version}.tar.gz";
        hash = "sha256-Zc9J5np1a88pCHvktK7jUnNCtx/369dXfea2vJf3DWo=";
      };

      src = pkgs.runCommand "playdate-sdk" { } "mkdir -p $out; tar xfz ${sdk} -C $out --strip-components=1";
    in
    rec {
      packages.x86_64-linux.pdc = pkgs.stdenv.mkDerivation {
        name = "pdc-${version}";
        inherit src;

        nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
        buildInputs = with pkgs; [ libpng stdenv.cc.cc.lib ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp ${src}/bin/pdc $out/bin/pdc
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          homepage = "https://play.date/dev";
          platforms = platforms.linux;
        };
      };
      packages.x86_64-linux.pdutil = pkgs.stdenv.mkDerivation {
        name = "pdutil-${version}";
        inherit src;

        nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
        buildInputs = with pkgs; [ libpng ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp ${src}/bin/pdutil $out/bin/pdutil
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          homepage = "https://play.date/dev";
          platforms = platforms.linux;
        };
      };
      packages.x86_64-linux.PlaydateSimulator = pkgs.stdenv.mkDerivation {
        name = "PlaydateSimulator-${version}";
        inherit src;

        nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
        buildInputs = with pkgs; [
          gtk3
          webkitgtk
        ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp ${src}/bin/PlaydateSimulator $out/bin/PlaydateSimulator
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          homepage = "https://play.date/dev";
          platforms = platforms.linux;
        };
      };
      packages.x86_64-linux.default = packages.x86_64-linux.PlaydateSimulator;
      apps.x86_64-linux.copy-sdk =
        let
          copy-playdate-sdk = pkgs.writeShellScriptBin "copy-playdate-sdk" ''
            mkdir -p $HOME/.local/share/playdate-sdk-${version}
            cp -r ${src}/. $HOME/.local/share/playdate-sdk-${version}
            chmod -R u+w $HOME/.local/share/playdate-sdk-${version}
            echo "Playdate SDK copied to $HOME/.local/share/playdate-sdk-${version}"
          '';
        in
        {
          type = "app";
          program = "${copy-playdate-sdk}/bin/copy-playdate-sdk";
        };
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          packages.x86_64-linux.pdc
          packages.x86_64-linux.pdutil
          packages.x86_64-linux.PlaydateSimulator
        ];
        PLAYDATE_SDK = "${src}";
      };
    };
}
