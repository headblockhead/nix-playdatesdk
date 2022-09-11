{
  description = "test";

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
        runScript = "PlaydateSimulator";
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
        runScript = "pdc";
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
        runScript = "pdutil";
    };
    shell = pkgs.mkShell {
      packages = [ 
        pdc
        pdutil
        pds
      ];
    };
  in
  {
    packages.x86_64-linux.PlaydateSimualtor = pds;
    packages.x86_64-linux.pdc = pdc;
    defaultPackage.x86_64-linux = shell;
  };
}
