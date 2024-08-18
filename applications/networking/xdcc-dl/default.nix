{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "xdcc-dl";
  version = "5.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "namboy94";
    repo = "xdcc-dl";
    rev = version;
    hash = "sha256-76cyrnDjtJ1QnwiSI9vzMrVCBmE1ginFfCTtj2ca4hY=";
  };

  nativeBuildInputs =  with python3.pkgs; [
    setuptools
    wheel
  ];
 
 postPatch = ''
    # https://github.com/megadose/holehe/pull/178
    substituteInPlace setup.py \
      --replace "bs4" "beautifulsoup4" \
     --replace "typing" "typing-extensions" 
  '';
  propagatedBuildInputs = with python3.pkgs; [
    beautifulsoup4
    colorama
    names
    requests
    cfscrape
    typing-extensions
    irc
    sentry-sdk
    names
   # puffotter
  ];

 pythonImportsCheck = [ "xdcc_dl" ];

  meta = with lib; {
    description = "An XDCC File Downloader based on the irclib framework";
    homepage = "https://github.com/namboy94/xdcc-dl";
    changelog = "https://github.com/namboy94/xdcc-dl/blob/${src.rev}/CHANGELOG";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "xdcc-dl";
  };
}
