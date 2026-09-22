{
  lib,
  stdenv,
  fetchFromGitea,
  meson,
  ninja,
  python3,
  qt6,
}:

let
  # Create a scoped python environment containing the required packages
  pythonEnv = python3.withPackages (ps: with ps; [
    pyside6
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vish";
  version = "1.1.5";
  strictDeps = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "Lluciocc";
    repo = "Vish";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8AB1HYSmtbe3+d38ka34nitvYwDkuC4uEPJTdXwGko0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    python3
    qt6.wrapQtAppsHook # Fondamentale per far rilevare correttamente i temi e l'interfaccia Qt6 su Linux
  ];

  buildInputs = [
   qt6.qtbase
    pythonEnv
  ];

  # Sostituisce il percorso statico di Flatpak (/app) con la destinazione finale in Nix ($out)
  postFixup = ''
    if [ -f $out/bin/vish ]; then
      substituteInPlace $out/bin/vish \
        --replace-warn "/app/" "$out/"
    
     # 2. Hardcode the absolute path of the Python environment inside the execution script
      substituteInPlace $out/bin/vish \
        --replace-warn "exec python3" "exec ${pythonEnv}/bin/python3"
 
    fi
  '';

  meta = {
    description = "Visual Scripting for Bash";
    homepage = "https://codeberg.org";
    license = with lib.licenses; [
      gpl3Only
      mit
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "vish";
    platforms = lib.platforms.all;
  };
})
