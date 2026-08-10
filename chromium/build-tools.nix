{
  fetchpatch,
  fetchFromGitHub,
  fetchFromGitiles,
  rustPlatform,
  buildGoModule,
  buildPackages,
  zstd,
  pkg-config,
  openssl,
  chromiumSrc,
}:

{
  # Match tools/rust/update_rust.py in Chromium 156.0.8078.47.
  crubit = rustPlatform.buildRustPackage (finalAttrs: {
    pname = "crubit";
    version = "0-unstable-2026-09-11";

    src = fetchFromGitiles {
      url = "https://chromium.googlesource.com/external/github.com/google/crubit.git";
      rev = "a355b02da81bc9f350925c73ec0322ce4d5140f1";
      hash = "sha256-Z2wsYe2Tln+CeAV9naC1QRnmvrz3HZXF06cNIp1RqU4=";
    };
    cargoHash = "sha256-5EB6yTk+eGffjUK/TXf6ZxCU0p05Dh1nL8q3Nl6TiiY=";

    patches = [
      (fetchpatch {
        name = "partial-rustfmt.patch";
        url = "https://github.com/google/crubit/commit/3ed0fa613223e09172e22363953f6587fe5d8bb7.patch";
        includes = [ "cc_bindings_from_rs/rustversion_impl.rs" ];
        hash = "sha256-+JMYo6ujPF4lQNUUAXwV6D2A4Ss39y8fh+V9lv8BZ2I=";
      })
      (fetchpatch {
        name = "fix-rust-1.99-compat.patch";
        url = "https://github.com/google/crubit/commit/943b515b25ca3868050b3ea3410b0b979ccc28a2.patch";
        hash = "sha256-pgoAX+pjliRM230w2GS07hbrR2USe5heQP4ETjiacrA=";
      })
    ];

    buildInputs = [ buildPackages.rustc.llvmPackages.llvm ];
    cargoBuildFlags = [
      "--bin"
      "cc_bindings_from_rs"
    ];
    cargoTestFlags = finalAttrs.cargoBuildFlags;
    env.RUSTC_BOOTSTRAP = 1;
  });

  gnrt = rustPlatform.buildRustPackage (finalAttrs: {
    pname = "gnrt";
    version = "156.0.8078.47";
    src = chromiumSrc;
    sourceRoot = "tools/crates/gnrt";

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;
      nativeBuildInputs = [ zstd ];
      hash = "sha256-hb/HSco4PeudjnZFGb2+IHw4rQ7ShI42XWqKOwdgrb4=";
    };

    nativeBuildInputs = [
      zstd
      pkg-config
    ];
    buildInputs = [ openssl ];
    meta.mainProgram = "gnrt";
  });

  # Must match devtools-frontend's vendored node_modules.
  esbuild = buildGoModule (finalAttrs: {
    pname = "esbuild";
    version = "0.28.2";
    src = fetchFromGitHub {
      owner = "evanw";
      repo = "esbuild";
      tag = "v${finalAttrs.version}";
      hash = "sha256-I1u+9U5Oj/KzxSjCxwyitwSuDKimatkbC3R2OtaUsfM=";
    };
    vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
  });
}
