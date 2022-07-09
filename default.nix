{ pkgs }:
with pkgs; [
  
    (callPackage ./applications/version-management/gitkraken { })
    (callPackage ./games/xpenguins {})
    (callPackage ./tools/misc/simpleclock { })
    (callPackage ./applications/science/math/perseus { })
    
]

