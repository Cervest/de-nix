# de-nix

## Nix
Nix is a package manager, a Linux distribution built on top of that package manager and a functional DSL for building packages and environments.

`nix-shell` can be [installed](https://nixos.org/download.html) on top of other Linux distros and OSX, and is very useful for creating reproducible development environments.
- Every package it installs is scoped to the current environment, so your path will only have the packages specified. This means that you can have multiple versions installed without collisions.
- Unlike Docker, it just drops you into a bash shell, from which you can open editors and IDEs, which makes it much more useful for development. And you don’t have to worry about mounting files.

The documentation online is geared towards the package management aspect, so the following is a short introduction on how to use it for development.

## Precompiled Packages
You can quickly drop into a shell with precompiled binaries by using `nix-shell -p gdal`. For the available packages see [here](https://nixos.org/nixos/packages.html?channel=nixos-20.03).

To clean up installed binaries, run `nix-collect-garbage`. Anything not currently being used will be deleted, which includes anything temporarily installed using nix-shell.

This is great for programs that you only need occasionally, but not for situations where you need 18 different versions of Ruby because the official channels. Stick with `asdf` for that.

## shell.nix
Rather than passing in a list of packages you want, you can pre-configure a shell. If you just run `nix-shell` in a folder with a `shell.nix` file, it will load it automatically.

It will use the builtin function `mkShell`.
```
with (import <nixpkgs> {});

mkShell {
  name = "my-env";

  buildInputs = [
    clang
    gdal
  ];

  inherit clang gdal;
}
```
1. with (import <nixpkgs> {});
- imports the 'standard' package definitions, so you can reference them

2. buildInputs = [ ... ];
- mostly, .nix files describe how to build packages, hence the name buildInputs. For our purposes, this will just define which packages are available in the shell.

3. inherit clang gdal;
- this is a shortcut for `clang = clang; gdal = gdal;`
- any variable defined within the mkShell scope will become available in the shell as an environment variable
- when you convert a package-object to a string, you get its path. This means that in the shell, you could do `echo $clang` to print `/nix/store/5pc7rp4hm228nql5xh8ik0pvwd96iipm-clang-wrapper-7.1.0`. This is how you reference libraries when building packages, despite the paths being dynamic
- note that Nix, like all sensible programming languages, does without pointless commas in lists

## shell.nix + Custom Derivations
If you need a package that’s not available already, or if you need to alter an existing package, you can create a package derivation in one file, and import it into your shell.nix

The simplest way to get started is to copy the existing derivation from the [nixpkgs repo](https://github.com/NixOS/nixpkgs). Due to the way the official derivations are built, they’ll start with something like this:
```
{ lib
, stdenv
, fetchFromGitHub
...more libraries
, doxygen
}:
```
Replace that expression with `with (import <nixpkgs> {});`. (This is necessary because you’re not building all of the packages, so you want to pass in the pre-built packages that it depends on.)

Then make any changes you need to do to the derivation.

Finally, in your shell.nix, you can simply import that file as a package. For example, because version 2 of TileDB wasn’t available, I adapted the existing derivation for it, and imported that file into my shell.nix.
```
with (import <nixpkgs> {});

mkShell rec {
  name = "grib-test-cpp";

  tiledb2 = (import ./tiledb2.nix);

  buildInputs = [
    clang
    gdal
    tiledb2
  ];

  inherit gdal;

}
```
Here, I’ve added a `rec`, for recursive, which means that the object returned by mkShell can refer to its own attributes. That’s because I want to assign the tiledb2 package to a variable, and then reference that variable in the buildInputs. I don’t need to inherit tiledb2, because it’s already saved to a variable. Also, it’s important that my adapated package has a new name, otherwise it would conflict with the `tiledb` from the standard package library.

You don’t need to do anything to build the TileDB derivation, just run `nix-shell` and it will build it automatically when it imports it. And if you run `nix-collect-garbage` it will delete it again.

Finally, you can add a `shellHook` block that runs after the shell loads.
```
with (import <nixpkgs> {});

mkShell rec {
  name = "de-flood-hazards";

  jdal = (import ../de-nix/gdal-java.nix);

  buildInputs = [
    jdal
  ];

  shellHook = ''
    export JVM_OPTS="$JVM_OPTS -Djava.library.path=${jdal}"
  '';

}
```


## Nix -> Docker images
To do!
