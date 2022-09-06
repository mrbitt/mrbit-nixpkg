{ mkDerivation, cmake, fetchFromGitHub, libvncserver, qemu, qtbase, lib
}:

mkDerivation rec {
  pname = "aqemu";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "TBK";
    repo = "aqemu";
    rev = "v${version}";
    sha256 = "00a2mmg0lzs4nk1nygp2ji7nkwyvazvl9bsa1pgj86vmnr1brghc";
  };
  
  prePatch = '' sed -i 's|#include <vector>|#include <vector>\n#include <stdexcept>|' src/docopt/docopt_value.h '';
  
  nativeBuildInputs = [ cmake ];

  buildInputs = [ libvncserver qtbase qemu ];

  meta = with lib; {
    description = "A virtual machine manager GUI for qemu";
    homepage = "https://github.com/tobimensch/aqemu";
    license = licenses.gpl2;
    maintainers = with maintainers; [ hrdinka ];
    platforms = with platforms; linux;
  };
}
