{ pkgs ? import <nixpkgs> {} }:

let
  # Compile your custom version of GKrellM 2.4.0 from your local recipe
  gkrellm-custom = pkgs.callPackage ./gkrellm-base.nix {
    inherit (pkgs) libX11 libSM libICE;
  };

  inherit (pkgs) stdenv pkg-config glib gtk2 alsa-lib imlib2 automake autoconf;

  # Initialize the template builder using the custom GKrellM binary dependency
  mkGkrellmPlugin = pkgs.callPackage ./mkGkrellmPlugin.nix {
    inherit stdenv pkg-config glib gtk2 alsa-lib;
    gkrellm = gkrellm-custom;
  };
in
{
  gkrellm = gkrellm-custom;

  gkleds = mkGkrellmPlugin { 
    pname = "gkleds"; 
    version = "0.8.2"; 

   src = pkgs.fetchurl {
      name = "gkleds-0.8.2.tar.gz";
      url = "https://ftp.riken.jp/Linux/gentoo/distfiles/96/gkleds-0.8.2.tar.gz";
      sha256 = "sha256-Uh2X9OA2tJkTu13utUHtgV5pRPpFAD8sRRyqzFyGvqg=";
    }; # Explicitly closed bracket ensures correct syntax tree mapping
  
  # Automatically feeds the modern GCC compiler with include shortcuts to find the custom GKrellM headers
    NIX_CFLAGS_COMPILE = [
      "-I${gkrellm-custom}/include"
      "-I${gkrellm-custom}/include/gkrellm2"
    ];
 
   nativeBuildInputs = [
      pkg-config
      gtk2
      glib
    ];
   
    buildInputs = [
      pkgs.libXtst
      pkgs.libX11
    ];

    configurePhase = ''
      runHook preConfigure
      ./configure --prefix=$out
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild
      make
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/gkrellm2/plugins
      cp -f src/.libs/*.so $out/gkrellm2/plugins/gkleds.so 2>/dev/null || cp -f src/*.so $out/gkrellm2/plugins/gkleds.so
      strip --strip-unneeded $out/gkrellm2/plugins/*.so
      runHook postInstall
    '';
  };

  gkrellmoon = mkGkrellmPlugin { 
    pname = "gkrellmoon";
    version = "0.6";
   
    src = pkgs.fetchurl {
    url = "http://downloads.sourceforge.net/project/gkrellmoon/gkrellmoon/0.6/gkrellmoon-0.6.tar.gz";
    sha256 = "0liq0x25bdx927l5hciwa7rmz04fdnhl9y298jgcmwc0kl2n4ad1";
    };

    postPatch = ''
      echo "Applying clean target modifications..."
      substituteInPlace MoonRise.c \
        --replace ", frac(), jd();" ";" \
        --replace "Tau, epsilon, Moon();" "Tau, epsilon;" \
        --replace "gdouble angle2pi();" ""
        
      substituteInPlace CalcEphem.c \
        --replace ", frac();" ";" \
        --replace ", jd();" ";" \
        --replace "gdouble jd();" ""

      substituteInPlace Moon.c \
        --replace "gdouble frac(), cosEPS" "gdouble cosEPS" \
        --replace ", Moon();" ";"
    '';

    NIX_CFLAGS_COMPILE = [
      "-I${gkrellm-custom}/include"
      "-I${gkrellm-custom}/include/gkrellm2"
    ];

    buildPhase = ''
      runHook preBuild
      make
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/gkrellm2/plugins
      cp -f *.so $out/gkrellm2/plugins/ 2>/dev/null || cp -f src/*.so $out/gkrellm2/plugins/
      strip --strip-unneeded $out/gkrellm2/plugins/*.so
      runHook postInstall
    '';
  };

  # Maintained local configurations for the other plugins
  gkrellm-volume = mkGkrellmPlugin {
    pname = "gkrellm-volume";
    version = "2.1.13";
   
    src = pkgs.fetchurl {
    url = "http://www.minix3.org/pkgsrc/distfiles/local/3.4.0/gkrellm-volume-2.1.13.tar.gz";
    sha256 = "0hssn7hmccrw4xklvqnj2whq48sk65qs3yvf660mywj2sb00myl5";
   };
   
    patches = [ ./gkrellm-volume/gkrellm-volume-2.1.13-reenable.patch ];
      NIX_CFLAGS_COMPILE = [
      "-Wno-error=incompatible-pointer-types"
      "-Wno-error=address" 
      "-I${gkrellm-custom}/include"
      "-I${gkrellm-custom}/include/gkrellm2"
     ];
      
     postPatch = ''
    substituteInPlace volume.c \
      --replace "if (right_click_cmd)" "if (1)"
  '';
   
  nativeBuildInputs = [ pkg-config ]; # pkg-config must be a native build input to run during the build
  buildInputs = [
    gtk2
    glib
    alsa-lib
  ];

  buildPhase = ''
    runHook preBuild
    make clean
    make enable_alsa=1
    runHook postBuild
  '';
  
  #dontConfigure = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/gkrellm2/plugins/ 
    cp *.so $out/gkrellm2/plugins/
    strip --strip-unneeded $out/gkrellm2/plugins/*.so
    runHook postInstall
  '';
  };
  
  gkrellAclock = mkGkrellmPlugin {
      pname = "gkrellAclock";
      version = "0.4.0";
     
      src = pkgs.fetchurl {
        name = "gkrellAclock-0.4.0.tar.gz";
        url = "http://oborlinux.free.fr/arch/gkrellaclock-0.3.4.tar.gz";
        sha256 = "sha256-WSPF+mwxzrGUTlchnYk2NOUD1E3F6R8966RvDXHnh7c=";
      };
      NIX_CFLAGS_COMPILE = [ 
        "-I${gkrellm-custom}/include" 
        "-I${gkrellm-custom}/include/gkrellm2"
        "-Wno-error=incompatible-pointer-types"
      ];
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk2 glib pkgs.xorg.libX11 ];
      buildPhase = "runHook preBuild; make clean; make; runHook postBuild;";
      installPhase = "mkdir -p $out/lib/gkrellm2/plugins; cp *.so $out/lib/gkrellm2/plugins/";
    };

  gkrellm-alltraxclock = mkGkrellmPlugin {
      pname = "gkrellm-alltraxclock";
      version = "0.1.4";
      
      src = pkgs.fetchurl {
        name = "gkrellm-alltraxclock-0.1.4.tar.gz";
        url = "https://launchpad.net/debian/+archive/primary/+sourcefiles/alltraxclock/2.0.2-2/alltraxclock_2.0.2.orig.tar.gz";
        sha256 = "sha256-QW0fgpQXg72YIroy8IcWRicBAT7Q4Q1NBkDZ1OfRgY0="; 
      };
     
      NIX_CFLAGS_COMPILE = [ 
        "-I${gkrellm-custom}/include" 
        "-I${gkrellm-custom}/include/gkrellm2"
        "-Wno-error=incompatible-pointer-types"
      ];
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk2 glib pkgs.libX11 ];
      buildPhase = "runHook preBuild; make; runHook postBuild;";
      installPhase = "mkdir -p $out/lib/gkrellm2/plugins; cp *.so $out/lib/gkrellm2/plugins/";
    };

  gkrellm-countdown = mkGkrellmPlugin {
      pname = "gkrellm-countdown";
      version = "0.1.2";
      
      src = pkgs.fetchurl {
        name = "gkrellm-countdown-0.1.2.tar.gz";
        url = "https://slackware.uk/people/alphageek/slackware-10.2/source/gkrellm-countdown/gkrellm-countdown-0.1.2.tar.gz";
        sha256 = "sha256-sF7nfDw76sSLK7vKQUDL9NV17bAs/f1TW8DsGXPvPdI="; # Hash finto per scatenare il download
      };
      NIX_CFLAGS_COMPILE = [ 
        "-I${gkrellm-custom}/include" 
        "-I${gkrellm-custom}/include/gkrellm2"
        "-Wno-error=incompatible-pointer-types"
      ];
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk2 glib pkgs.libX11 ];
      buildPhase = "runHook preBuild; make; runHook postBuild;";
      installPhase = "mkdir -p $out/lib/gkrellm2/plugins; cp *.so $out/lib/gkrellm2/plugins/";
    };

  gkrellm-hdplop = mkGkrellmPlugin {
      pname = "gkrellm-hdplop";
      version = "0.1.1";
      
      src = pkgs.fetchurl {
        name = "gkrellm-hdplop-0.1.1.tar.gz";
        url = "https://www.dockapps.net/download/wmhdplop-0.9.12.tar.gz";
        sha256 = "sha256-ZgYx6ObIm3FXovSFJYrQ0yOhSPm0pwSQObl7xEIL25o="; # Hash finto per innescare lo scaricamento
      };
      
      patches = [./gkrellm-hdplop/wmhdplop-0.9.10-cflags.patch];
      postPatch = ''
    substituteInPlace wmhdplop.c \
      --replace "void next_displayed_hd()" "void next_displayed_hd(...)" \
      --replace "void prev_displayed_hd()" "void prev_displayed_hd(...)"

    substituteInPlace wmhdplop.h \
      --replace "void next_displayed_hd();" "void next_displayed_hd(...);" \
      --replace "void prev_displayed_hd();" "void prev_displayed_hd(...);"
  '';
  
      NIX_CFLAGS_COMPILE = [ 
        "-I${gkrellm-custom}/include" 
        "-I${gkrellm-custom}/include/gkrellm2"
        "-Wno-error=incompatible-pointer-types"
      ];
      
        # Force-regenerate build configuration files to prevent aclocal failures after patching
         preConfigure = '' autoreconf -vfi '';
      nativeBuildInputs = [ pkg-config automake autoconf ];
      buildInputs = [ gtk2 glib pkgs.libX11 imlib2];
      buildPhase = "runHook preBuild; make; runHook postBuild;";
      installPhase = "mkdir -p $out/lib/gkrellm2/plugins; cp *.so $out/lib/gkrellm2/plugins/";
    };

    gkrellshoot = mkGkrellmPlugin {
      pname = "gkrellshoot";
      version = "0.4.4";
      
      src = pkgs.fetchurl {
        name = "gkrellshoot-0.4.4.tar.gz";
        url = "https://downloads.sourceforge.net/gkrellshoot/gkrellshoot-0.4.4.tar.gz";
        sha256 = "sha256-HMH/igDNjnb37907r/yb0zDsu1SejBzooEos+oZ7wWQ="; 
      };
     
      NIX_CFLAGS_COMPILE = [ 
        "-I${gkrellm-custom}/include" 
        "-I${gkrellm-custom}/include/gkrellm2"
        "-Wno-error=incompatible-pointer-types"
        "-fpermissive"
        "-Wno-error=implicit-int"
        "-Wno-error=implicit-function-declaration"  
      ];
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk2 glib pkgs.libX11 ];
      buildPhase = "runHook preBuild; make; runHook postBuild;";
      installPhase = "mkdir -p $out/lib/gkrellm2/plugins; cp *.so $out/lib/gkrellm2/plugins/";
    };

  gkrellm-thinkbat = mkGkrellmPlugin {
      pname = "gkrellm-thinkbat";
      version = "0.2.3";
     
      src = pkgs.fetchurl {
        name = "gkrellm-thinkbat-0.2.2.tar.gz";
        url = "http://archive.ubuntu.com/ubuntu/pool/universe/g/gkrellm-thinkbat/gkrellm-thinkbat_0.2.3.orig.tar.gz";
        sha256 = "sha256-i8ALb+8c6VwcNOmVDEK+GRXBd0NYnzS9jcmuNxcj8N4=";
      };
      
       postPatch = ''
        substituteInPlace collect_data.h \
          --replace "int read_from_file();" "int read_from_file(char *file);"
      '';
      
      NIX_CFLAGS_COMPILE = [ 
        "-I${gkrellm-custom}/include" 
        "-I${gkrellm-custom}/include/gkrellm2"
        "-Wno-error=incompatible-pointer-types"
      ];
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk2 glib pkgs.libX11 ];
      buildPhase = "runHook preBuild; make; runHook postBuild;";
      installPhase = "mkdir -p $out/lib/gkrellm2/plugins; cp *.so $out/lib/gkrellm2/plugins/";
    };

  gkrellm-timers = mkGkrellmPlugin {
      pname = "gkrellm-timers";
      version = "0.1.2";
      
      src = pkgs.fetchurl {
        name = "gkrellm-timers-0.1.2.tar.gz";
        url = "https://github.com/zuckschwerdt/gkrellm-timers/archive/1.3.tar.gz";
        sha256 = "sha256-heMBNuuQ6NVu1N6Ez+CnaNVFmh+DPThCDIKVb86+364="; # Hash esca finto per scatenare il download
      };
      NIX_CFLAGS_COMPILE = [ 
        "-I${gkrellm-custom}/include" 
        "-I${gkrellm-custom}/include/gkrellm2"
        "-Wno-error=incompatible-pointer-types"
      ];
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ gtk2 glib pkgs.libX11 ];
      buildPhase = "runHook preBuild; make; runHook postBuild;";
      installPhase = "mkdir -p $out/lib/gkrellm2/plugins; cp *.so $out/lib/gkrellm2/plugins/";
    };

    gkrellm-xkb = mkGkrellmPlugin {
      pname = "gkrellm-xkb";
      version = "1.05";
      
      src = pkgs.fetchurl {
        name = "gkrellm-xkb-1.05.tar.gz";
        url = "https://0.archive.ubuntu.com/ubuntu/pool/universe/g/gkrellm-xkb/gkrellm-xkb_1.05.orig.tar.gz";
        sha256 = "sha256-AhbzoY+++tD2cgNLgPl1RanbNcV1Zgt74aSXgxdIGYE="; # Hash esca finto per scatenare il download
      };
      
      postPatch = ''
        substituteInPlace main.c  --replace "static void draw_flag();" "static void draw_flag(int redraw);"
         '';
      NIX_CFLAGS_COMPILE = [ 
    "-I${gkrellm-custom}/include"
    "-I${gkrellm-custom}/include/gkrellm2"
    "-Wno-error=incompatible-pointer-types"
   ];
     nativeBuildInputs = [ pkg-config ];
     buildInputs = [ gtk2 glib pkgs.libX11 ];
     buildPhase = "runHook preBuild; make; runHook postBuild;";
     installPhase = "mkdir -p $out/lib/gkrellm2/plugins; cp *.so $out/lib/gkrellm2/plugins/";
};
    
  gkrelltop = mkGkrellmPlugin {
	pname = "gkrelltop";
	version = "2.2.13";
	
	src = pkgs.fetchurl {
	name = "gkrelltop-2.2.13.tar.gz";
	url = "http://downloads.sourceforge.net/gkrelltop/gkrelltop_2.2.13.orig.tar.gz";
	sha256 = "sha256-slhcQYbMOAX83nNkWnHY6z95g1jK6zHPP1mHlebqQuY="; # Hash esca finto per forzare il download
	};
	
	patches = [ ./gkrelltop/gkrelltop-2.2.13-fix-build-system-1.patch ];
	
	NIX_CFLAGS_COMPILE = [
	"-I${gkrellm-custom}/include"
	"-I${gkrellm-custom}/include/gkrellm2"
	"-Wno-error=incompatible-pointer-types"
	];
	
	nativeBuildInputs = [ pkg-config ];
	buildInputs = [ gtk2 glib pkgs.libX11 ];
	buildPhase = "runHook preBuild; make clean; make; runHook postBuild;";
	installPhase = "mkdir -p $out/lib/gkrellm2/plugins; cp *.so $out/lib/gkrellm2/plugins/";
};
    
  #gkrellAclock = mkGkrellmPlugin { pname = "gkrellAclock"; version = "local"; src = ./gkrellAclock; };
  #gkrellm-alltraxclock = mkGkrellmPlugin { pname = "gkrellm-alltraxclock"; version = "local"; src = ./gkrellm-alltraxclock; };
  #gkrellm-countdown = mkGkrellmPlugin { pname = "gkrellm-countdown"; version = "local"; src = ./gkrellm-countdown; };
  #gkrellm-hdplop = mkGkrellmPlugin { pname = "gkrellm-hdplop"; version = "local"; src = ./gkrellm-hdplop; };
  #gkrellmoon = mkGkrellmPlugin { pname = "gkrellmoon"; version = "local"; src = ./gkrellmoon; };
  #gkrellm-thinkbat = mkGkrellmPlugin { pname = "gkrellm-thinkbat"; version = "local"; src = ./gkrellm-thinkbat; };
  #gkrellm-timers = mkGkrellmPlugin { pname = "gkrellm-timers"; version = "local"; src = ./gkrellm-timers; };
  #gkrellm-xkb = mkGkrellmPlugin { pname = "gkrellm-xkb"; version = "local"; src = ./gkrellm-xkb; };
  #gkrellshoot = mkGkrellmPlugin { pname = "gkrellshoot"; version = "local"; src = ./gkrellshoot; };
}
