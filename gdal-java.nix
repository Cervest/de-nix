# Adapted from https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/gdal/default.nix

# { stdenv, fetchFromGitHub, fetchpatch, unzip, libjpeg, libtiff, zlib, postgresql
# , libmysqlclient, libgeotiff, pythonPackages, proj, geos, openssl, libpng
# , sqlite, libspatialite, poppler, hdf4, qhull, giflib, expat, libiconv, libxml2
# , autoreconfHook, netcdfSupport ? true, netcdf, hdf5, curl, pkg-config }:
with (import <nixpkgs> {});

with stdenv.lib;

stdenv.mkDerivation rec {
  pname = "gdal-java";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "gdal";
    rev = "v${version}";
    sha256 = "053q5dzrjw2pcgkvcgwxgfy0xg0297pm9cqi4gvcx457yjyy092q";
  };

  sourceRoot = "source/gdal";

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [
    unzip
    # libjpeg
    libtiff
    # libpng
    proj
    openssl
    sqlite
    # libspatialite
    # libgeotiff
    # poppler
    # hdf4
    # qhull
    # giflib
    # expat
    # libxml2
    # postgresql
    # netcdf
    # hdf5
    curl
    swig
    ant
    jdk11
    # pythonPackages.python
    # pythonPackages.numpy
    # pythonPackages.wrapPython
  ];

  configureFlags = [
    "--with-java=${jdk11}"
    # "--with-expat=${expat.dev}"
    # "--with-jpeg=${libjpeg.dev}"
    "--with-libtiff=${libtiff.dev}" # optional (without largetiff support)
    # "--with-png=${libpng.dev}" # optional
    # "--with-poppler=${poppler.dev}" # optional
    # "--with-libz=${zlib.dev}" # optional
    # "--with-pg=yes" # since gdal 3.0 doesn't use ${postgresql}/bin/pg_config
    # "--with-mysql=${libmysqlclient}/bin/mysql_config"
    # "--with-geotiff=${libgeotiff}"
    "--with-sqlite3=${sqlite.dev}"
    # "--with-spatialite=${libspatialite}"
    # "--with-python" # optional
    "--with-proj=${proj.dev}" # optional
    "--with-geos=${geos}/bin/geos-config" # optional
    # "--with-hdf4=${hdf4.dev}" # optional
    # "--with-hdf5=${hdf5.dev}" # optional
    # "--with-xml2=${libxml2.dev}/bin/xml2-config" # optional
    # "--with-netcdf=${netcdf}"
  ];

  hardeningDisable = [ "format" ];

  CXXFLAGS = "-fpermissive";

  # - Unset CC and CXX as they confuse libtool.
  # - teach gdal that libdf is the legacy name for libhdf
  preConfigure = ''
    substituteInPlace configure \
      --replace "-lmfhdf -ldf" "-lmfhdf -lhdf"
  '';

  # preBuild = ''
  #   substituteInPlace swig/python/GNUmakefile \
  #     --replace "ifeq (\$(STD_UNIX_LAYOUT),\"TRUE\")" "ifeq (1,1)"
  # '';

  # postInstall = ''
  #   wrapPythonPrograms
  # '';

  postPhases = [ "javaBindings" ];

  javaBindings = ''
    cd swig/java
    echo JAVA_HOME="${jdk11}" >> java.opt
    make
    cp libgdalalljni.so gdal.jar $out
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Translator library for raster geospatial data formats";
    homepage = "https://www.gdal.org/";
    license = stdenv.lib.licenses.mit;
    maintainers = [ "Mike" ];
    platforms = with stdenv.lib.platforms; linux ++ darwin;
  };
}
