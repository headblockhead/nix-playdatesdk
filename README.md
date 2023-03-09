# nix-playdatesdk
A nix flake to provide the PlayDate SDK tools.

## Using this flake
Simply run ```nix develop github:headblockhead/nix-playdatesdk``` and the commands ```PlaydateSimulator```, ```pdc``` and ```pdutil``` will make themselves avalible, or run ```nix shell github:headblockhead/nix-playdatesdk\#PlaydateSimualtor```,```nix shell github:headblockhead/nix-playdatesdk\#pdc``` or ```nix shell github:headblockhead/nix-playdatesdk\#pdutil``` for individual packages.

## Warning!
Unless you are inside the `nix develop` shell (which will download the sdk to your `$HOME`), you will have to download the SDK from Panic at https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-1.13.2.tar.gz and set PLAYDATE_SDK_PATH yourself.
