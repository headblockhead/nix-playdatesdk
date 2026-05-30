{
  description = "All you need: Lua and C APIs, docs, as well as a Simulator for local development, with profiling and more. ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      version = "3.0.6";
      sdk = pkgs.fetchurl {
        url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-${version}.tar.gz";
        hash = "sha256-j7MnjJqHXOJqLl/8VVP3Kj1O83IwkuxS6CRPH17OzBI=";
      };

      src =
        pkgs.runCommand "playdate-sdk" { }
          "mkdir -p $out; tar xfz ${sdk} -C $out --strip-components=1";

      pdc = pkgs.stdenv.mkDerivation {
        name = "pdc-${version}";
        inherit src;

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
        ];
        buildInputs = with pkgs; [
          libpng
          stdenv.cc.cc.lib
        ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp ${src}/bin/pdc $out/bin/pdc
          wrapProgram $out/bin/pdc --set PLAYDATE_SDK_PATH ${src}
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          homepage = "https://play.date/dev";
          platforms = platforms.linux;
        };
      };
      pdutil = pkgs.stdenv.mkDerivation {
        name = "pdutil-${version}";
        inherit src;

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
        ];
        buildInputs = with pkgs; [ libpng ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp ${src}/bin/pdutil $out/bin/pdutil
          wrapProgram $out/bin/pdutil --set PLAYDATE_SDK_PATH ${src}
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          homepage = "https://play.date/dev";
          platforms = platforms.linux;
        };
      };

      PlaydateSimulator = pkgs.stdenv.mkDerivation {
        name = "PlaydateSimulator-${version}";
        inherit src;

        nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
        buildInputs = with pkgs; [
          gtk3
          webkitgtk_4_1
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
      writeableSDKPath = "$HOME/.local/share/playdate-sdk-${version}";
    in
    rec {
      packages.x86_64-linux.pdc = pdc;
      packages.x86_64-linux.pdutil = pdutil;
      packages.x86_64-linux.PlaydateSimulator = pkgs.writeShellScriptBin "PlaydateSimulator" ''
        if [ ! -d "${writeableSDKPath}" ]; then
          mkdir -p "${writeableSDKPath}"
          cp -r ${src}/. "${writeableSDKPath}"
          chmod -R u+w "${writeableSDKPath}"
          printf "Playdate SDK copied to ${writeableSDKPath}\n"
        fi
        PLAYDATE_SDK_PATH=${writeableSDKPath} ${PlaydateSimulator}/bin/PlaydateSimulator "$@"
      '';
      packages.x86_64-linux.default = packages.x86_64-linux.PlaydateSimulator;
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          packages.x86_64-linux.pdc
          packages.x86_64-linux.pdutil
          packages.x86_64-linux.PlaydateSimulator
        ];
      };
    };
}
