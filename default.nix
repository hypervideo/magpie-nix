{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  git,
  gh,
  ripgrep,
}:

buildNpmPackage rec {
  pname = "magpie";
  version = "unstable-2026-05-27";
  rev = "cafd72bcd58e3b51d0bc2984f823b327868095b4";

  src = fetchFromGitHub {
    owner = "liliu-z";
    repo = "magpie";
    inherit rev;
    hash = "sha256-bXZv9cTADQfRoe2OYBLIeGOevv/9yeb6fLwEn4J59NY=";
  };

  npmDepsHash = "sha256-+lpRNck3gCyr8OUZtKtyEJmtXHm3FmNq9lOdn6EnDNU=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/magpie \
      --prefix PATH : ${lib.makeBinPath [
        git
        gh
        ripgrep
      ]}
  '';

  meta = with lib; {
    description = "Multi-AI adversarial PR review tool";
    homepage = "https://github.com/liliu-z/magpie";
    license = licenses.isc;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "magpie";
  };
}
