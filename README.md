# nix-playdatesdk
A nix flake to provide the PlayDate SDK tools.

## Usage

To run the Playdate Compiler, use:

```bash
nix run github:headblockhead/nix-playdatesdk#pdc
```

To run the Playdate Utility, use:

```bash
nix run github:headblockhead/nix-playdatesdk#pdutil
```

To run the Playdate Simulator, use:

```bash
nix run github:headblockhead/nix-playdatesdk#PlaydateSimulator
```

Or use the development shell to access all tools in the SDK.

```bash
nix develop github:headblockhead/nix-playdatesdk
```
