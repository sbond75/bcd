# Tip: direnv to keep dependencies for a specific project in Nix
# Run: nix-shell

# { pkgs ? import (builtins.fetchTarball { # https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs :
#   # Descriptive name to make the store path easier to identify
#   name = "nixos-unstable-2020-09-03";
#   # Commit hash for nixos-unstable as of the date above
#   url = "https://github.com/NixOS/nixpkgs/archive/702d1834218e483ab630a3414a47f3a537f94182.tar.gz";
#   # Hash obtained using `nix-prefetch-url --unpack <url>`
#   sha256 = "1vs08avqidij5mznb475k5qb74dkjvnsd745aix27qcw55rm0pwb";
# }) { }}:
# with pkgs;

{ pkgs ? import (builtins.fetchTarball { # https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs :
  # Descriptive name to make the store path easier to identify
  name = "nixos-unstable-2022-06-02";
  # Commit hash for nixos-unstable as of the date above
  url = "https://github.com/NixOS/nixpkgs/archive/d2a0531a0d7c434bd8bb790f41625e44d12300a4.tar.gz";
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "13nwivn77w705ii86x1s4zpjld6r2l197pw66cr1nhyyhi5x9f7d";
}) { }}:
with pkgs;

let
  my-python-packages = python3Full.withPackages(ps: with ps; [
    distorm3 # disassembler for x86 (tool you can use)
  ]);
  my-hivex = (callPackage ./hivex.nix {});
in mkShell {
  buildInputs = [
    my-python-packages
    glib
    pkg-config
    #(python3Packages.toPythonModule (callPackage ./hivex.nix {})) # https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/python-packages.nix#L71
    #(callPackage ./hivex-python-package.nix {})
    my-hivex

    (ntfs3g.overrideAttrs (oldAttrs: rec {
      patchPhase = (oldAttrs.patchPhase or "") + ''

        substituteInPlace libntfs-3g/volume.c --replace \
          "ntfs_log_error(\"Windows is hibernated, refused to mount.\n\");
        		errno = EPERM;
        		goto out;" \
          "{ ntfs_log_error(\"Windows is hibernated, mount anyway?\n\"); char c; scanf(\" %c\", &c); if (c == 'y' || c == 'Y') {} else {
                                    errno = EPERM; goto out; }}"
      '';
    }))

    libxml2
  ];

  # Hack to get hivex on the Python path for now
  shellHook = ''
    export PYTHONPATH="$PYTHONPATH:${my-hivex.outPath}/${python3.sitePackages}"
  '';
}
