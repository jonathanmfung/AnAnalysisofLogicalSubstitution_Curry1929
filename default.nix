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
    name = "AnAnalysisofLogicalSubstitution_Curry1929";
    src = ./.;
    nativeBuildInputs = [
      pkgs.coreutils
      pkgs.findutils
      tex
    ];

    FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.source-sans-pro ]; };

    buildPhase = ''
      runHook preBuild
      export PATH="${pkgs.lib.makeBinPath nativeBuildInputs}"
      mkdir -p .cache/texmf-var
      env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
        latexmk -interaction=nonstopmode -pdf -lualatex \
        AnAnalysisofLogicalSubstitution_Curry1929.tex
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp AnAnalysisofLogicalSubstitution_Curry1929.pdf $out/
      runHook postInstall
    '';
  };
}
