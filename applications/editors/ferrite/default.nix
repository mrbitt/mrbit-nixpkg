{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  fontconfig,
  freetype,
  libgit2,
  libxkbcommon,
  libGL,
  oniguruma,
  mold,
  copyDesktopItems,
  makeDesktopItem,
  rust-jemalloc-sys,
  vulkan-loader,
  zlib,
  stdenv,
  wayland,
  makeWrapper,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ferrite";
  version = "0.2.9";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "OlaProeis";
    repo = "Ferrite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-upaVP9qFNoV2AYf0/BwnqM8aXiEitZdcbg2Vu0G2Oc8=";
  };

  cargoHash = "sha256-lcWNoTnorzZAaXFdvfOvmlrtLyxR/Tv2lwLf2kCenVw=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    copyDesktopItems
    mold # Linker ultra-rapido
  ];

  buildInputs = [
    fontconfig
    freetype
    libgit2
    libxkbcommon
    oniguruma
    libGL
    rust-jemalloc-sys
    vulkan-loader
    zlib
  ]
  ++ lib.optionals stdenv.isLinux [
    wayland
  ];

  env = {
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

    postInstall = ''
    wrapProgram $out/bin/ferrite \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ wayland libxkbcommon libGL ]}"
      
    install -Dm644 assets/icons/icon_256.png $out/share/icons/hicolor/256x256/apps/ferrite.png
    #install -Dm644 assets/icons/linux/ferrite.desktop -t "$out/share/applications"
    install -Dm644 assets/icons/linux/16x16/ferrite.png "$out/share/icons/hicolor/16x16/apps/ferrite.png"
    install -Dm644 assets/icons/linux/32x32/ferrite.png "$out/share/icons/hicolor/32x32/apps/ferrite.png"
    install -Dm644 assets/icons/linux/48x48/ferrite.png "$out/share/icons/hicolor/48x48/apps/ferrite.png"
    install -Dm644 assets/icons/linux/64x64/ferrite.png "$out/share/icons/hicolor/64x64/apps/ferrite.png"
    install -Dm644 assets/icons/linux/128x128/ferrite.png "$out/share/icons/hicolor/128x128/apps/ferrite.png"
    #install -Dm644 assets/icons/linux/256x256/ferrite.png "$out/share/icons/hicolor/256x256/apps/ferrite.png"
    install -Dm644 assets/icons/linux/512x512/ferrite.png "$out/share/icons/hicolor/512x512/apps/ferrite.png"
  '';

    # Definizione del file .desktop
  desktopItems = [
    (makeDesktopItem {
	  name = "ferrite";
      exec = "ferrite %F";
      icon = "ferrite"; # Assicurati che l'icona esista o usa un nome generico
      desktopName = "Ferrite";
      genericName = "Text Editor";
      comment = "A fast, lightweight text editor for Markdown, JSON, and more";
      categories = [ "TextEditor" "Utility"];
      terminal = false;
    })
  ];
 
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A fast, lightweight text editor for Markdown, JSON, YAML, and TOML files. Built with Rust and egui for a native, responsive experience";
    homepage = "https://github.com/OlaProeis/Ferrite";
    changelog = "https://github.com/OlaProeis/Ferrite/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ferrite";
  };
})
