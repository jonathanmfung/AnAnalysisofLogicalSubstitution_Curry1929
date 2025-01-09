let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };
  stdenv = pkgs.stdenv;
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-basic
      latex-bin
      luatex
      latexmk
      footmisc
      todonotes
      titlesec
      enumitem
      amsmath
      extsizes
      tocloft
      fancyhdr
      cleveref
      hyperref
      etoolbox
      ;
  };
in
{
  document = stdenv.mkDerivation rec {
    name = "cover_letter";
    src = ./.;
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.findutils
      tex
    ];

    TZDIR = "${pkgs.tzdata}/share/zoneinfo";
    FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.source-sans-pro ]; };

    buildPhase = ''
      runHook preBuild
      export PATH="${pkgs.lib.makeBinPath nativeBuildInputs}"
      export TZ="America/Los_Angeles"
      mkdir -p .cache/texmf-var
      env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
        latexmk -interaction=nonstopmode -pdf -lualatex \
        document.tex
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp document.pdf $out/
      runHook postInstall
    '';
  };
}
