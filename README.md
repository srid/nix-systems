# nix-systems

Dynamically generated system definitions for Nix flakes.

> [!IMPORTANT]
> We plan to move to statically-generated lists to minimize evaluation and building. See https://github.com/srid/nix-systems/issues/2

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

| Feature | This repo | [Numtide's nix-systems](https://github.com/nix-systems) |
|---------|-----------|-----------------------------------------------|
| Approach | Single flake, dynamically generated | Separate repository per system |
| Respects [Hacker Ethic](https://en.wikipedia.org/wiki/Hacker_ethic) | Yes | No[^no] |

[^no]: See https://x.com/sridca/status/1798466886197207084 & https://x.com/sridca/status/1808605343674450157

## License

MIT
