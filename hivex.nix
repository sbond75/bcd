# https://github.com/NixOS/nixpkgs/blob/nixos-22.05/pkgs/development/libraries/hivex/default.nix#L33

{ lib, stdenv, fetchurl, pkg-config, autoreconfHook, makeWrapper
, perlPackages, libxml2, libiconv, python3 }:

stdenv.mkDerivation rec {
  pname = "hivex";
  version = "1.3.21";

  src = fetchurl {
    url = "https://libguestfs.org/download/hivex/${pname}-${version}.tar.gz";
    sha256 = "sha256-ms4+9KL/LKUKmb4Gi2D7H9vJ6rivU+NF6XznW6S2O1Y=";
  };

  patches = [ ./hivex-syms.patch ];

  nativeBuildInputs = [ autoreconfHook makeWrapper pkg-config perlPackages.podlators # NOTE: podlators has to be in `nativeBuildInputs` or else the pod2man binary won't show up for some reason!
                      ];
  buildInputs = [
    libxml2
    python3
  ]
  ++ (with perlPackages; [ perl IOStringy
                           #(callPackage ./podlators.nix {})
                         ])
  ++ lib.optionals stdenv.isDarwin [ libiconv ];

  prePatch = ''
    substituteInPlace lib/hivex-internal.h --replace "#define HIVEX_MAX_SUBKEYS       70000" "#define HIVEX_MAX_SUBKEYS       700000" --replace "#define HIVEX_MAX_VALUES       110000" "#define HIVEX_MAX_VALUES       1100000" # https://github.com/libguestfs/hivex/blob/master/lib/hivex-internal.h , https://listman.redhat.com/archives/libguestfs/2016-December/msg00008.html ; to prevent `returning ERANGE because: nr_subkeys_in_nk > HIVEX_MAX_SUBKEYS (139314 > 70000)` on a valid registry hive file.
  '';
  
  # This is not really possible I guess, (`output` is undefined) (based on https://discourse.nixos.org/t/how-to-package-a-rust-application-with-python-bindings/3250 and https://nixos.org/guides/nix-pills/our-first-derivation.html ) : `configureFlags = [ "--with-python-installdir=${outputs.out.path}/${python3.sitePackages}" ];`, so we are using this:
  preConfigure = ''
    configureFlags="$configureFlags --with-python-installdir=$out/${python3.sitePackages}"
  '';
  
  postInstall = ''
    wrapProgram $out/bin/hivexregedit \
        --set PERL5LIB "$out/${perlPackages.perl.libPrefix}" \
        --prefix "PATH" : "$out/bin"
    wrapProgram $out/bin/hivexml \
        --prefix "PATH" : "$out/bin"
  '';

  meta = with lib; {
    broken = stdenv.isDarwin;
    description = "Windows registry hive extraction library";
    license = licenses.lgpl2;
    homepage = "https://github.com/libguestfs/hivex";
    maintainers = with maintainers; [offline];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
