# mrbit-nixpkg
espressioni for NixOS

Installation

For now:

 1   Clone this repo to your HOME and add it your PATH
 2   Clone NixOS/nixpkgs to your HOME and add its location to the variable NIXPKGS_REPO

 It's also possible to install it directly from this repository:

    nix-env -f https://github.com/mrbitt/mrbit-nixpkg/archive/master.zip -i

 Disclaimer

Please note that this project is not intended to replace any current nixos utils.


It's also possible to install in Local config and packages for Nix

Comprising

    My preferred packages for day-to-day operation on Linux (NixOS) and Darwin (vanilla nixpkgs installation)

    Some derivations that aren't part of my user profile but that I use a lot anyway

Quick start (clobbers any previously installed packages in the profile)

$ cd $HOME

$ git clone https://github.com/NixOS/nixpkgs

$ git clone git@github.com:mrbitt/mrbit-nixpkg .nixpkgs

$ nix-env -r -iA nixpkgs.desktop

Background

I don't want to maintain a local fork of the nixpkgs repo with my personal packages, at least unless and until I think it's worth trying to get them merged.

Instead I use packageOverrides. packageOverrides is (as far as I can work out) a function that should accept a set of packages and return another set of packages: nixpkgs calls it with the set of all available packages and merges whatever it returns onto the same set.

There is a config.nix file in this repo. If you already have a $HOME/.nixpkgs/config.nix then merge the contents of this one with that one. If not, you can tell Nix to use this one by setting $NIXPKGS_CONFIG to point to it, or (may be easier) by creating a symlink from $HOME/.nixpkgs to this repo.
