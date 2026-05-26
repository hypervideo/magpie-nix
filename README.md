# magpie-nix

Nix flake packaging for [liliu-z/magpie](https://github.com/liliu-z/magpie), a multi-AI adversarial PR review tool.

Upstream does not currently publish tags or releases, so this flake pins the upstream `main` branch by commit SHA and exposes it as an `unstable-YYYY-MM-DD` package version.

## Use Directly

```bash
nix run github:hypervideo/magpie-nix -- --help
```

## Consume From Another Flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    magpie-nix.url = "github:hypervideo/magpie-nix";
  };

  outputs =
    { nixpkgs, magpie-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ magpie-nix.overlays.default ];
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.magpie ];
      };
    };
}
```

## Updates

`.github/workflows/update-magpie.yml` runs daily and on demand. It checks the latest upstream `main` commit, refreshes the source hash and `npmDepsHash`, builds the package, and commits the update back to `main`.
