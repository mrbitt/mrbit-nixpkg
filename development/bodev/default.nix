{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  libxkbcommon,
  vulkan-loader,
  stdenv,
  darwin,
  xorg,
  libX11,
  libXi,
  libXext,
  wrapGAppsHook4,
  wayland,
  dbus,
  makeWrapper,
}:

let
  cargo = lib.importTOML ./Cargo.toml;
in
rustPlatform.buildRustPackage rec {
  pname = "bodev";
  version = "0.1.3";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "sgued";
    repo = "bodev";
    rev = "v${version}";
    hash = "sha256-cLSOyXGIY9sd06t2sBf2xiqtMEw56sm5YD5PhiWesgc=";
    fetchSubmodules = true;
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "accesskit-0.16.0" = "sha256-yeBzocXxuvHmuPGMRebbsYSKSvN+8sUsmaSKlQDpW4w=";
      "atomicwrites-0.4.2" = "sha256-QZSuGPrJXh+svMeFWqAXoqZQxLq/WfIiamqvjJNVhxA=";
      "clipboard_macos-0.1.0" = "sha256-+8CGmBf1Gl9gnBDtuKtkzUE5rySebhH7Bsq/kNlJofY=";
      "cosmic-client-toolkit-0.1.0" = "sha256-/DJ/PfqnZHB6VeRi7HXWp0Vruk+jWBe+VCLPpiJeEv4=";
      "cosmic-freedesktop-icons-0.2.6" = "sha256-+WmCBP9BQx7AeGdFW2KM029vuweYKM/OzuCap5aTImw=";
      "cosmic-settings-daemon-0.1.0" = "sha256-9Pq5WFBeIRvP2VZaa3BzoqiQmzN6taa20u7k+2aF3v0=";
      "cosmic-text-0.12.1" = "sha256-TIvN35U7ryXM56osaW5872hryXUCpLfCLD2vv5K6cmU=";
      "dpi-0.1.1" = "sha256-whi05/2vc3s5eAJTZ9TzVfGQ/EnfPr0S4PZZmbiYio0=";
      "iced_glyphon-0.6.0" = "sha256-u1vnsOjP8npQ57NNSikotuHxpi4Mp/rV9038vAgCsfQ=";
      "smithay-clipboard-0.8.0" = "sha256-4InFXm0ahrqFrtNLeqIuE3yeOpxKZJZx+Bc0yQDtv34=";
      "softbuffer-0.4.1" = "sha256-a0bUFz6O8CWRweNt/OxTvflnPYwO5nm6vsyc/WcXyNg=";
      "taffy-0.3.11" = "sha256-SCx9GEIJjWdoNVyq+RZAGn0N71qraKZxf9ZWhvyzLaI=";
    };
  };

  nativeBuildInputs = [
    pkg-config makeWrapper
  ];

  buildInputs = [
    libxkbcommon
    vulkan-loader
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreGraphics
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Foundation
    darwin.apple_sdk.frameworks.Metal
    darwin.apple_sdk.frameworks.QuartzCore
  ] ++ lib.optionals stdenv.isLinux [
    wayland libX11 libXi libXext dbus
  ];

 # preConfigure = ''
 #   export LIBRARY_PATH=${libXi}/lib:${libX11}/lib:${libXext}/lib
 # '';

      
    doCheck = false;
 postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
     mkdir -p $out/share/applications
     mkdir -p $out/share/icons
       cp $src/dist/fr.sgued.bodev.desktop $out/share/applications
       cp $src/assets/icon64.png $out/share/icons/fr.sgued.bodev.png
     wrapProgram $out/bin/bodev --prefix LD_LIBRARY_PATH : ${libX11}/lib
  '';
 
 postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/${pname}
  '';
 
  meta = {
    description = "Low level Dev tools";
    homepage = "https://codeberg.org/sgued/bodev";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "bodev";
  };
}
