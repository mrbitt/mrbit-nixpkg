{stdenv, fetchurl, gkrellm }:

stdenv.mkDerivation rec {
  pname = "gkrellm-themes";
  version = "20030109";
  dontStrip = true;

  src = fetchurl {
    url = "http://www.muhri.net/gkrellm/GKrellM-Skins.tar.gz";
    sha256 = "1l9hgn9j3w6vczli77ms3262wnd00jiakjw9dkgr08nc202d1lm0";
  };

    buildInputs = [ gkrellm ];
    dontConfigure = true;

    installPhase = ''
     mkdir -p $out
     cd $out
        # unpack the debian archive
     tar -zxvf "${src}"
     cd $out/GKrellM-skins
      # Deduped tarballs
       rm -f aliens.tgz cyrus.gkrellm.tar.gz glass.gkrellm.tar.gz IReX.tar.gz
      # Corrupted tarballs
       rm -f Crux_chaos.tar.gz egan-gkrellm.tar.gz

       # Unpack the tarballs, omitting trash
      mkdir -p $out/usr/share/gkrellm2/themes $out/bin
      for file in *gz ; do
        tar zxC "$out/usr/share/gkrellm2/themes" -f $file \
       --exclude CVS \
       --exclude "*~" \
       --exclude "*.swp" \
       --exclude .xvpics \
       --no-same-owner \
       --no-same-permissions
      done
      substituteAll "${./gkrellthemes.sh}" "$out/bin/gkrellthemes"
                      chmod a+x "$out/bin/gkrellthemes"
                      substituteAll "${./gkrellthemesOFF.sh}" "$out/bin/gkrellthemesOFF"
                      chmod a+x "$out/bin/gkrellthemesOFF"
    # Random fixes
   cd "$out/usr/share/gkrellm2/themes/twilite"
   rm -f './.png' && ln -s 'green/frame_right.png' './.png'

     # delete GKrellM-skins directiry
   rm -rf "$out/GKrellM-skins" '';
}

