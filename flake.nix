{
  description = "A collection of tools to help with developing for Panic's Playdate.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs"; };

  outputs = { self, nixpkgs }:
    with import nixpkgs { system = "x86_64-linux"; };
    let
      version = "1.13.1";
      playdateSDK = pkgs.fetchurl {
        url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-${version}.tar.gz";
        sha256 = "rMjVT9j2p3JBlJfCdmTOOLJ1k7580LETG+sAVIcKhzs=";
      };
      pdc = stdenv.mkDerivation rec {
        name = "pdc-${version}";
        src = playdateSDK;
        nativeBuildInputs = [ autoPatchelfHook ];

        buildInputs = [ pkgs.zlib pkgs.libpng ];
        installPhase = ''
          tar xvfz $src
          mkdir -p $out/bin
          cp -r PlaydateSDK-${version}/bin/pdc $out/bin/pdc
        '';
        sourceRoot = ".";
        meta = with lib; {
          homepage = "https://play.date/dev";
          description = "The PlayDateCompiler, used for compiling Playdate projects - part of the PlaydateSDK";
          platforms = platforms.linux;
        };
      };
      pdutil = stdenv.mkDerivation rec {
        name = "pdutil-${version}";
        src = playdateSDK;
        nativeBuildInputs = [ autoPatchelfHook ];

        buildInputs = [ pkgs.zlib pkgs.libpng ];
        installPhase = ''
                    tar xvfz $src
                    mkdir -p $out/bin
          cp -r PlaydateSDK-${version}/bin/pdutil $out/bin/pdutil
        '';
        sourceRoot = ".";
        meta = with lib; {
          homepage = "https://play.date/dev";
          description = "The PlayDateUtil, used for interacting with the PlayDate device - part of the PlaydateSDK";
          platforms = platforms.linux;
        };
      };
      PlaydateSimulator = stdenv.mkDerivation rec {
        name = "PlaydateSimulator-${version}";
        src = playdateSDK;
        nativeBuildInputs = [ autoPatchelfHook ];

        buildInputs = [ pkgs.webkitgtk ];
        installPhase = ''
          tar xvfz $src
          mkdir -p $out/bin
          cp -r PlaydateSDK-${version}/bin/PlaydateSimulator $out/bin/pds
        '';
        sourceRoot = ".";
        meta = with lib; {
          homepage = "https://play.date/dev";
          description = "The PlaydateSimulator, used for simulating and interacting with the PlayDate device - part of the PlaydateSDK";
          platforms = platforms.linux;
        };
      };
      PlaydateSimulatorWrapped = pkgs.buildFHSUserEnv {
        name = "PlaydateSimulator";
        targetPkgs = pkgs: [ pkgs.alsa-lib PlaydateSimulator ];
        runScript = "pds";
      };
      shell = pkgs.mkShell {
        shellHook = ''
                    if ! [[ -d $HOME/playdatesdk-${version} ]]; then
                          tar -xzvf ${playdateSDK}
                          mkdir $HOME/playdatesdk-${version}
                          mv PlaydateSDK-${version}/* $HOME/playdatesdk-${version}
                          ln -sf ${pdc}/bin/pdc $HOME/playdatesdk-${version}/bin/pdc
                          ln -sf ${pdutil}/bin/pdutil $HOME/playdatesdk-${version}/bin/pdutil
                          ln -sf ${PlaydateSimulatorWrapped}/bin/PlaydateSimulator $HOME/playdatesdk-${version}/bin/PlaydateSimulator
                          if ! [[ -d "$HOME/.Playdate Simulator/" ]]; then
                          mkdir $HOME/.Playdate\ Simulator/
                          echo "SDKDirectory=$HOME/playdatesdk-${version}" >> "$HOME/.Playdate Simulator/Playdate Simulator.ini"
          fi
                          fi
                          export PLAYDATE_SDK_PATH=$HOME/playdatesdk-${version}
        '';
        packages = [ PlaydateSimulatorWrapped pdc pdutil ];
      };

    in {
      packages.x86_64-linux.pdc = pdc;
      packages.x86_64-linux.pdutil = pdutil;
      packages.x86_64-linux.PlaydateSimulator = PlaydateSimulatorWrapped;
      defaultPackage.x86_64-linux = shell;
    };

}

