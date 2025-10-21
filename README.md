# nix-systems

Statically generated system definitions for Nix flakes.

## Usage

```nix
{
  inputs.nix-systems.url = "github:srid/nix-systems";

  outputs = { nix-systems, ... }: {
    # Use a single system
    systems = import (nix-systems + "/x86_64-linux");

    # Or use a combination of systems
    systems = import (nix-systems + "/aarch64-darwin,x86_64-linux");

    # Or use all systems
    systems = import (nix-systems + "/aarch64-darwin,aarch64-linux,x86_64-linux");
  };
}
```

## Available Directories

This repository contains statically generated directories for:

**Single systems:**
- `x86_64-linux/`
- `aarch64-linux/`
- `aarch64-darwin/`

**2-system combinations:**
- `aarch64-darwin,aarch64-linux/`
- `aarch64-darwin,x86_64-linux/`
- `aarch64-linux,x86_64-linux/`

**All systems:**
- `aarch64-darwin,aarch64-linux,x86_64-linux/`

Each directory contains `flake.nix` and `default.nix` with the corresponding system list.

## Regenerating

To add new systems or update the structure, edit and run:

```bash
./generate.sh
```

## Comparison

| Feature | This repo | [Numtide's nix-systems](https://github.com/nix-systems) |
|---------|-----------|-----------------------------------------------|
| Approach | Single flake, statically generated | Separate repository per system |
| Requires `flake.lock` | No | Yes |
| Build/evaluation overhead | Minimal | Higher |
| Respects [Hacker Ethic](https://en.wikipedia.org/wiki/Hacker_ethic) | Yes | No[^no] |

[^no]: See https://x.com/sridca/status/1798466886197207084 & https://x.com/sridca/status/1808605343674450157

## License

MIT
