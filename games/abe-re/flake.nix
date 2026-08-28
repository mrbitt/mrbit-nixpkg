# SPDX-FileCopyrightText: 2025 Marcin Serwin <marcin@serwin.dev>
# SPDX-License-Identifier: GPL-2.0-or-later
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f { pkgs = nixpkgs.legacyPackages.${system}; });
    in
    {
      packages = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.callPackage ./package.nix { };
        }
      );
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              pdpmake
              pkg-config
              sdl3
              gdb
              clang-tools
              tinyxxd
              valgrind
              reuse
            ];
            shellHook = ''
              export MAKEFLAGS="-j`nproc`"
              export SDL_LOGGING=*=trace
              export NIX_HARDENING_ENABLE="";
              export UBSAN_OPTIONS=abort_on_error=1:halt_on_error=1
              export CFLAGS="-std=c99 -O0 -g3 -fsanitize=address,undefined \
                -Wall -Wextra -Wpedantic -Werror -Wdouble-promotion \
                -Wno-format-zero-length"
            '';
          };
        }
      );
    };
}

