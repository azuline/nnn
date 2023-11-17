{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, installShellFiles
, makeWrapper
, pkg-config
, file
, ncurses
, readline
, which
, pcre
  # options
, conf ? null
, withPcre ? false
, extraMakeFlags ? [ ]
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nnn";
  version = "4.9";

  src = ./.;

  configFile = lib.optionalString (conf != null) (builtins.toFile "nnn.h" conf);
  preBuild = lib.optionalString (conf != null) "cp ${finalAttrs.configFile} src/nnn.h";

  nativeBuildInputs = [ installShellFiles makeWrapper pkg-config ];
  buildInputs = [ readline ncurses ]
    ++ lib.optional withPcre pcre;

  makeFlags = [ "PREFIX=$(out)" ]
    ++ lib.optionals withPcre [ "O_PCRE=1" ]
    ++ extraMakeFlags;

  binPath = lib.makeBinPath [ file which ];

  installTargets = [ "install" ];

  postInstall = ''
    wrapProgram $out/bin/nnn --prefix PATH : "$binPath"
  '';

  meta = with lib; {
    description = "Small ncurses-based file browser forked from noice";
    homepage = "https://github.com/jarun/nnn";
    changelog = "https://github.com/jarun/nnn/blob/v${version}/CHANGELOG";
    license = licenses.bsd2;
    platforms = platforms.all;
    maintainers = with maintainers; [ jfrankenau Br1ght0ne ];
    mainProgram = "nnn";
  };
})
