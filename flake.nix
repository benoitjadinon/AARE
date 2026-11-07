{
  description = "AARE (Android Auto Reverse Engineered) development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f (import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      }));
    in {
      devShells = forAllSystems (pkgs:
        let
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            platformVersions = [ "37" ];
            buildToolsVersions = [ "36.0.0" "37.0.0" ];
            includeEmulator = false;
          };
          androidSdk = androidComposition.androidsdk;
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              jdk21
              androidSdk
              android-tools
              ffmpeg
              python3
              git
            ];

            shellHook = ''
              export JAVA_HOME="${pkgs.jdk21.home}"
              export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
              export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"
              export PATH="$ANDROID_HOME/platform-tools:$PATH"
            '';
          };
        }
      );
    };
}
