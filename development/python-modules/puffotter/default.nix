{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonApplication rec {
  pname = "puffotter";
  version = "0.17.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Xb8N35gJ20py8Zy4AAWTw9QEGJ2qk23ySobAt7Ym06c=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    colorama
    requests
    sentry-sdk
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    crypto = [
      bcrypt
    ];
  };

  pythonImportsCheck = [ "puffotter" ];

  meta = with lib; {
    description = "Convenience library for python";
    homepage = "https://pypi.org/project/puffotter/";
    license = licenses.gpl3; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "puffotter";
  };
}
