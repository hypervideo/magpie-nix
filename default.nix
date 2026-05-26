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
  version = "unstable-2026-05-06";
  rev = "da7097c1b6deaf3817e1571a2effab0f9c8d09e9";

  src = fetchFromGitHub {
    owner = "liliu-z";
    repo = "magpie";
    inherit rev;
    hash = "sha256-DzTG3sJ3MUblyUNqJddig0fHhF6XlgzRNVDnKndBAnA=";
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
