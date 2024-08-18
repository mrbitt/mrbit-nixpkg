{ lib
, buildGoModule
, fetchFromSourcehut
}:

buildGoModule rec {
  pname = "xdcc";
  version = "0.3.1";

  src = fetchFromSourcehut {
    owner = "~dax";
    repo = "xdcc";
    rev = version;
    hash = "sha256-Jv59hwLQpwL39K+GFrazLvX8uoiz6ZlL8NeLAbdX/hE=";
  };

  vendorHash = "sha256-3raBIpN5J45Ccsvs2zWsZ3YJPAOHDV74ahyTWBp7RE0=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "";
    homepage = "https://git.sr.ht/~dax/xdcc/archive/0.3.1.tar.gz";
    license = licenses.isc;
    maintainers = with maintainers; [ ];
    mainProgram = "xdcc";
  };
}
