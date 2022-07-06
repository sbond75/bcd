# Based on https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/top-level/perl-packages.nix#L318

{ lib, buildPerlPackage, callPackage }:

buildPerlPackage {
  pname = "podlators";
  version = "4.14";
  src = fetchFromGithub {
    url = "mirror://cpan/authors/id/R/RR/RRA/${name}-${version}.tar.gz";
    sha256 = "1ynh8qa99dcvqcqzbpy0s5jrxvn7wa5ydz3lfd56n358l5jfzns9";
  };
  propagatedBuildInputs = [ PodSimple
                            #JSONPP
                            #(callPackage ./perl6-slurp.nix {})
                            #PerlCritic
                          ];
  buildInputs = [  ];
};
