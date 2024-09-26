{ lib
, stdenv
, fetchFromGitHub
, postgresql
, postgresqlTestExtension
, testers
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pg_repack";
  version = "1.5.0";

  buildInputs = postgresql.buildInputs ++ [ postgresql ];

  src = fetchFromGitHub {
    owner = "reorg";
    repo = "pg_repack";
    rev = "ver_${finalAttrs.version}";
    sha256 = "sha256-do80phyMxwcRIkYyUt9z02z7byNQhK+pbSaCUmzG+4c=";
  };

  installPhase = ''
    install -D bin/pg_repack -t $out/bin/
    install -D lib/pg_repack${postgresql.dlSuffix} -t $out/lib/
    install -D lib/{pg_repack--${finalAttrs.version}.sql,pg_repack.control} -t $out/share/postgresql/extension
  '';

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };
    extension = postgresqlTestExtension {
      inherit (finalAttrs) finalPackage;
      sql = "CREATE EXTENSION pg_repack;";
    };
  };

  meta = with lib; {
    description = "Reorganize tables in PostgreSQL databases with minimal locks";
    longDescription = ''
      pg_repack is a PostgreSQL extension which lets you remove bloat from tables and indexes, and optionally restore
      the physical order of clustered indexes. Unlike CLUSTER and VACUUM FULL it works online, without holding an
      exclusive lock on the processed tables during processing. pg_repack is efficient to boot,
      with performance comparable to using CLUSTER directly.
    '';
    homepage = "https://github.com/reorg/pg_repack";
    license = licenses.bsd3;
    maintainers = with maintainers; [ danbst ];
    inherit (postgresql.meta) platforms;
    mainProgram = "pg_repack";
  };
})
