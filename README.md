# nix-playdatesdk
A nix flake to provide the PlayDate SDK tools.

## Usage

Use the development shell.

```bash
nix develop github:headblockhead/nix-playdatesdk
```

Or, run an individual tool.

```bash
nix run github:headblockhead/nix-playdatesdk#pdc
```

> [!NOTE]
> The development shell creates a copy of the SDK at `$HOME/playdatesdk-${version}` as the Playdate Simulator requires a writeable copy of the Disk folder. If you don't want to use the shell, you can manually download the SDK and set the `PLAYDATE_SDK_PATH` environment variable to the path of the SDK.
