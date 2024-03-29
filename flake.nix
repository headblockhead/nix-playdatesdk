{
  description = "A collection of tools to help with developing for Panic's Playdate.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05"; };

  outputs = { self, nixpkgs }:
    with import nixpkgs { system = "x86_64-linux"; };
    let
      version = "2.1.1";
      playdateSDK = pkgs.fetchurl {
        url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-${version}.tar.gz";
        sha256 = "19nz9dm4i1gazdhkjyk4b2p7g8l7v157b0pgs97kzvfjs57nhjc0";
      };
      pdc = stdenv.mkDerivation {
        name = "pdc-${version}";
        src = playdateSDK;
        nativeBuildInputs = [ autoPatchelfHook ];

        buildInputs = [ pkgs.zlib pkgs.libpng pkgs.stdenv.cc.cc.lib ];
        installPhase = ''
          tar xfz $src
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
      pdutil = stdenv.mkDerivation {
        name = "pdutil-${version}";
        src = playdateSDK;
        nativeBuildInputs = [ autoPatchelfHook ];

        buildInputs = [ pkgs.zlib pkgs.libpng ];
        installPhase = ''
          tar xfz $src
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
      PlaydateSimulator = stdenv.mkDerivation {
        name = "PlaydateSimulator-${version}";
        src = playdateSDK;
        nativeBuildInputs = [ autoPatchelfHook ];

        buildInputs = [ pkgs.webkitgtk ];
        installPhase = ''
          tar xfz $src
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
          printf "Configuring shell...\n"
          if ! [[ -d $HOME/playdatesdk-${version} ]]; then
            printf "Playdate SDK not found, installing PlaydateSDK to $HOME/playdatesdk-${version}"
            tar -xzf ${playdateSDK}
            mkdir $HOME/playdatesdk-${version}
            mv PlaydateSDK-${version}/* $HOME/playdatesdk-${version}
            ln -sf ${pdc}/bin/pdc $HOME/playdatesdk-${version}/bin/pdc
            ln -sf ${pdutil}/bin/pdutil $HOME/playdatesdk-${version}/bin/pdutil
            ln -sf ${PlaydateSimulatorWrapped}/bin/PlaydateSimulator $HOME/playdatesdk-${version}/bin/PlaydateSimulator
            printf "\nInstalled PlaydateSDK to $HOME/playdatesdk-${version}!\n"
          fi
          if ! [[ -d "$HOME/.Playdate Simulator/" ]]; then
            printf "Playdate Simulator config not found, configuring $HOME/.Playdate Simulator/Playdate Simulator.ini to use the Playdate SDK..."
            mkdir $HOME/.Playdate\ Simulator/
            echo "SDKDirectory=$HOME/playdatesdk-${version}" >> "$HOME/.Playdate Simulator/Playdate Simulator.ini"
            printf "\nConfigured Playdate Simulator!\n"
          fi
          export PLAYDATE_SDK_PATH=$HOME/playdatesdk-${version}
          printf "Finished configuring, you are ready to go!\n"
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
