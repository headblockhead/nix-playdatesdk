{
  description = "A collection of tools to help with developing for Panic's Playdate.";

  outputs = { self, nixpkgs }: 
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
    pdsdk = pkgs.callPackage ./sdk.nix {};
    pds = pkgs.buildFHSUserEnv {
      name = "PlaydateSimulator";
      targetPkgs = pkgs:
      [
          pkgs.wrapGAppsHook
          pkgs.glib
          pkgs.gdk-pixbuf
          pkgs.cairo
          pkgs.pango
          pkgs.udev
          pkgs.alsa-lib
          pkgs.gtk3
          pkgs.webkitgtk
          pkgs.pkg-config
          pdsdk
          pkgs.xorg.libX11
          pkgs.xorg.libXcursor
          pkgs.xorg.libXrandr
        ];
        runScript = ''~/playdate_sdk-1.12.3/bin/PlaydateSimulator'';
    };
    pdc = pkgs.buildFHSUserEnv {
      name = "pdc";
      targetPkgs = pkgs:
      [
        pkgs.zlib
          pkgs.libpng
          pkgs.pkg-config
          pdsdk
        ];
        runScript = ''~/playdate_sdk-1.12.3/bin/pdc'';
      };
    pdutil = pkgs.buildFHSUserEnv {
      name = "pdutil";
      targetPkgs = pkgs:
      [
        pkgs.zlib
          pkgs.libpng
          pkgs.pkg-config
          pdsdk
        ];
        runScript = ''~/playdate_sdk-1.12.3/bin/pdutil'';
    };
    shell = pkgs.mkShell {
      shellHook = ''
        # Copy the Playdate SDK into the home folder if it is not there.
        if ! [[ -d ~/playdate_sdk ]]; then cp -r $(realpath $(dirname $(realpath $(which PlaydateSimulatorFromSDK)))/../) ~;chmod -R +rw ~/playdate_sdk-1.12.3/;chown -R $USER ~/playdate_sdk-1.12.3/; fi;
        # Set the PLAYDATE_SDK_PATH to the copy.
        export PLAYDATE_SDK_PATH=~/playdate_sdk-1.12.3
        # Set the GSETTINGS_SCHEMA_DIR to the proper location to let PlaydateSimulator use org.gtk.Settings.FileChooser for picking the SDK location.
        export GSETTINGS_SCHEMA_DIR=${pkgs.glib.getSchemaPath pkgs.gtk3}
        # Set the XDG_DATA_DIRS to the proper location to let PlaydateSimualtor show proper icons in the FileChooser.
        export XDG_DATA_DIRS=$HOME/.nix-profile/share:/usr/local/share:/usr/share
                '';
      packages = [ 
        pdsdk
        pdc
        pdutil
        pds
      ];
    };
  in
  {
    packages.x86_64-linux.PlaydateSimualtor = pds;
    packages.x86_64-linux.pdc = pdc;
    packages.x86_64-linux.pdutil = pdutil;
    defaultPackage.x86_64-linux = shell;
  };
}
