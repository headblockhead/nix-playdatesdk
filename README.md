# nix-playdatesdk
A nix flake to provide the PlayDate SDK tools.

## Usage

Use the development shell to use all tools in the SDK.

```bash
nix develop github:headblockhead/nix-playdatesdk
```

Or, run an individual tool.

```bash
nix run github:headblockhead/nix-playdatesdk#pdc
```

> [!NOTE]
> `PlaydateSimulator` requires a writeable copy of the SDK to run, to store its Disk.
> You can use the copy-sdk script to create a writeable copy of the SDK to `$HOME/.local/share/playdate-sdk-${version}`.
> ```bash
> nix run github:headblockhead/nix-playdatesdk#copy-sdk
> ```
> Then, choose the directory when prompted by the simulator.
