# nix-systems

Dynamically generated system definitions for Nix flakes.

## Usage

```nix
{
  inputs.nix-systems.url = "github:srid/nix-systems";

  outputs = { nix-systems, ... }: {
    # Use a specific system
    systems = import (nix-systems + "/x86_64-linux");
  };
}
```

## Build

```bash
nix build
```

Produces `result/` with subdirectories for each supported system:
- `x86_64-linux/`
- `aarch64-linux/`
- `aarch64-darwin/`

Each contains `flake.nix` and `default.nix` with the system list.

## Comparison

| Feature | This repo | [nix-systems](https://github.com/nix-systems) |
|---------|-----------|-----------------------------------------------|
| Approach | Single flake, dynamically generated | Separate repository per system |
| Respects [Hacker Ethic](https://en.wikipedia.org/wiki/Hacker_ethic) | Yes | [No](https://x.com/sridca/status/1798025800798683161) |

## License

MIT
