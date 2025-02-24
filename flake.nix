{
  description = "A collection of tools to help with developing for Panic's Playdate.";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11"; };

  outputs = { self, nixpkgs }:
    with import nixpkgs { system = "x86_64-linux"; };
    let
      version = "2.6.2";
      playdateSDK = pkgs.fetchurl {
        url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-${version}.tar.gz";
        sha256 = "sha256-GDqXXPgBYSiKuxcV3M/Ho5ALX5IAOkx6neK6bZKYt7E=";
      };
      dynamicLinker = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
      pdsBuildInputs = [
        pkgs.zlib
        pkgs.libpng
        pkgs.udev
        pkgs.gtk3
        pkgs.pango
        pkgs.cairo
        pkgs.gdk-pixbuf
        pkgs.glib
        pkgs.webkitgtk_4_0
        pkgs.xorg.libX11
        pkgs.stdenv.cc.cc.lib
        pkgs.libxkbcommon
        pkgs.wayland
        pkgs.libpulseaudio
        pkgs.gsettings-desktop-schemas
      ];
    in
    rec {
      packages.x86_64-linux.pdc = stdenv.mkDerivation {
        name = "pdc-${version}";
        src = playdateSDK;
        nativeBuildInputs = [ autoPatchelfHook ];

        buildInputs = [ pkgs.zlib pkgs.libpng pkgs.stdenv.cc.cc.lib ];
        installPhase = ''
          runHook preInstall
            tar xfz $src
            mkdir -p $out/bin
            cp -r PlaydateSDK-${version}/bin/pdc $out/bin/pdc
            runHook postInstall
        '';
        sourceRoot = ".";
        meta = with lib; {
          homepage = "https://play.date/dev";
          description = "The PlayDateCompiler, used for compiling Playdate projects - part of the PlaydateSDK";
          platforms = platforms.linux;
        };
      };
      packages.x86_64-linux.pdutil = stdenv.mkDerivation {
        name = "pdutil-${version}";
        src = playdateSDK;
        nativeBuildInputs = [ autoPatchelfHook ];

        buildInputs = [ pkgs.zlib pkgs.libpng ];
        installPhase = ''
                          runHook preInstall
                  tar xfz $src
                  mkdir -p $out/bin
                  cp -r PlaydateSDK-${version}/bin/pdutil $out/bin/pdutil
          runHook postInstall
        '';
        sourceRoot = ".";
        meta = with lib; {
          homepage = "https://play.date/dev";
          description = "The PlayDateUtil, used for interacting with the PlayDate device - part of the PlaydateSDK";
          platforms = platforms.linux;
        };
      };
      packages.x86_64-linux.PlaydateSimulator = stdenv.mkDerivation {
        name = "PlaydateSimulator-${version}";
        src = playdateSDK;
        nativeBuildInputs = [ pkgs.makeWrapper wrapGAppsHook ];
        dontFixup = true;
        buildInputs = pdsBuildInputs;
        installPhase = ''
                  runHook preInstall
                    tar xfz $src
                    mkdir -p $out/opt/playdate-sdk-${version}
                    cp -r PlaydateSDK-${version}/* $out/opt/playdate-sdk-${version}
                    ln -s $out/opt/playdate-sdk-${version} $out/opt/playdate-sdk
              patchelf \
                --set-interpreter "${dynamicLinker}" \
                --set-rpath "${lib.makeLibraryPath pdsBuildInputs}"\
                $out/opt/playdate-sdk-${version}/bin/PlaydateSimulator

                    mkdir -p $out/bin
          makeWrapper $out/opt/playdate-sdk-${version}/bin/PlaydateSimulator $out/bin/PlaydateSimulator \
            --suffix XDG_DATA_DIRS : ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}
                runHook postInstall
        '';
        sourceRoot = ".";
        meta = with lib; {
          homepage = "https://play.date/dev";
          description = "The PlaydateSimulator, used for simulating and interacting with the PlayDate device - part of the PlaydateSDK";
          platforms = platforms.linux;
        };
      };
      devShells.x86_64-linux.default = pkgs.mkShell {
        shellHook = ''
          if ! [[ -d $HOME/playdatesdk-${version} ]]; then
            printf "Installing PlaydateSDK to $HOME/playdatesdk-${version}"
            tar -xzf ${playdateSDK}
            mkdir $HOME/playdatesdk-${version}
            mv PlaydateSDK-${version}/* $HOME/playdatesdk-${version}
            ln -sf ${packages.x86_64-linux.pdc}/bin/pdc $HOME/playdatesdk-${version}/bin/pdc
            ln -sf ${packages.x86_64-linux.pdutil}/bin/pdutil $HOME/playdatesdk-${version}/bin/pdutil
            ln -sf ${packages.x86_64-linux.PlaydateSimulator}/bin/PlaydateSimulator $HOME/playdatesdk-${version}/bin/PlaydateSimulator
            printf "\nInstalled PlaydateSDK to $HOME/playdatesdk-${version}!\n"
          fi
          export SDL_AUDIODRIVER=pulseaudio
          export PLAYDATE_SDK_PATH=$HOME/playdatesdk-${version}
          printf "reminder: PlaydateSimulator must be manually configured to use $HOME/playdatesdk-${version} as the SDK path\n"
        '';
        packages = [ packages.x86_64-linux.pdc packages.x86_64-linux.pdutil packages.x86_64-linux.PlaydateSimulator ];
      };
    };
}
