{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "5.1.5";
  kde-channel = "stable";
  sha256 = "sha256-HHdevvD3mammt0RAw9kGq5E8J1QbF37WIXBN5xTppNM=";
})
