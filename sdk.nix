{ pkgs, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "playdate_sdk";
  version = "1.12.3";
  src = fetchurl {
    url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-1.12.3.tar.gz";
    sha256 = "6QZb7Ie6LaSAa5fK8qjDGSWt4AzgCimFo2IGp685XWo=";
  };
  builder = ./sdk-install.sh;
  system = builtins.currentSystem;
}

