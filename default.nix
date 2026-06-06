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
  version = "unstable-2026-06-05";
  rev = "fda54bad780224f26b6ec2da14bdf6fdd397b4ff";

  src = fetchFromGitHub {
    owner = "liliu-z";
    repo = "magpie";
    inherit rev;
    hash = "sha256-hSNDYoSWk3CgfLaWXH0/5nCQLGdB91KHaY1MeAEgYpw=";
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
