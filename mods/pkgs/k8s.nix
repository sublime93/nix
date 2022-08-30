final: prev:
with prev;
let
  inherit (stdenv) isLinux isDarwin isAarch64;
  isM1 = isDarwin && isAarch64;
in
rec {
  katafygio = prev.callPackage
    ({ stdenv, lib, buildGo119Module, fetchFromGitHub }:
      buildGo119Module rec {
        pname = "katafygio";
        version = "0.8.3";

        src = fetchFromGitHub {
          owner = "bpineau";
          repo = "katafygio";
          rev = "v${version}";
          sha256 = "sha256-fRMXRKr620l7Y6uaYur3LbCGgLeSJ27zEGK0Zq7LZEY=";
        };

        vendorSha256 = "sha256-4hf6OueNHkReXdn9RuO4G4Zrpghp45YkuEwmci4wjz8=";

        ldflags = [
          "-s"
          "-w"
          "-X github.com/bpineau/katafygio/cmd.version=${version}"
        ];

        meta = with lib; {
          inherit (src.meta) homepage;
          description = "Dump, or continuously backup Kubernetes objects as yaml files in git";
          license = licenses.mit;
          maintainers = with maintainers; [ jpetrucciani ];
        };
      }
    )
    { };

  goldilocks = prev.callPackage
    ({ stdenv, lib, buildGo119Module, fetchFromGitHub }:
      buildGo119Module rec {
        pname = "goldilocks";
        version = "4.3.3";

        src = fetchFromGitHub {
          owner = "FairwindsOps";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-M6SRXkr9hPXKwO+aQ1xYj5NUrRRo4g4vMi19XwINDXw=";
        };

        vendorSha256 = "sha256-pz+gjNvXsaFGLYWCPaa5zOc2TUovNaTFrvT/dW49KuQ=";

        meta = with lib; {
          inherit (src.meta) homepage;
          description = "Get your resource requests 'Just Right'";
          license = licenses.asl20;
          maintainers = with maintainers; [ jpetrucciani ];
        };
      }
    )
    { };

  polaris = prev.callPackage
    ({ stdenv, lib, buildGo119Module, fetchFromGitHub }:
      buildGo119Module rec {
        pname = "polaris";
        version = "6.0.0";

        src = fetchFromGitHub {
          owner = "FairwindsOps";
          repo = pname;
          rev = version;
          sha256 = "sha256-Q0jDySEmzCrjCmc4H9ap/AmopNtdAq4zOAh/6LZ/dFo=";
        };

        vendorSha256 = "sha256-SC86x2vE1TNZBxDNxyxjOPILdQbGAfSz5lmaC9qCkoE=";
        doCheck = false;

        meta = with lib; {
          inherit (src.meta) homepage;
          description = "Validation of best practices in your Kubernetes clusters";
          license = licenses.asl20;
          maintainers = with maintainers; [ jpetrucciani ];
        };
      }
    )
    { };

  cyclonus = prev.callPackage
    ({ stdenv, lib, buildGo119Module, fetchFromGitHub }:
      buildGo119Module rec {
        pname = "cyclonus";
        version = "0.5.0";

        src = fetchFromGitHub {
          owner = "mattfenwick";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-Q6FFSb2iczJQKFx6AVs3nsZfNE6qJ9YKgajeU7MmMfI=";
        };

        vendorSha256 = "sha256-/IQC1vJ4MebuNp+3hvTz85w1guq5e58XM/KMQKWWQoI=";

        meta = with lib; {
          inherit (src.meta) homepage;
          description = "tools for understanding, measuring, and applying network policies effectively in kubernetes";
          license = licenses.mit;
          maintainers = with maintainers; [ jpetrucciani ];
        };
      }
    )
    { };

  rbac-tool = prev.callPackage
    ({ stdenv, lib, buildGo119Module, fetchFromGitHub }:
      buildGo119Module rec {
        pname = "rbac-tool";
        version = "1.9.0";

        src = fetchFromGitHub {
          owner = "alcideio";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-EujU0Ljr+VhGQ3VMhpdP/mikHFKVARR2vRl94/tZ7As=";
        };

        vendorSha256 = "sha256-nADcFaVdC3UrZxqrwqjcNho/80n856Co2KG0AknflWM=";

        meta = with lib; {
          inherit (src.meta) homepage;
          description = "Visualize, Analyze, Generate & Query RBAC policies in Kubernetes";
          license = licenses.asl20;
          maintainers = with maintainers; [ jpetrucciani ];
        };
      }
    )
    { };

  kubediff = prev.callPackage
    ({ lib, stdenv, fetchFromGitHub, rustPlatform }:
      let
        pname = "kubediff";
        version = "0.1.0";
        osSpecific = with pkgs.darwin.apple_sdk.frameworks; if isDarwin then [ Security ] else [ ];
      in
      rustPlatform.buildRustPackage rec {
        inherit pname version;

        src = fetchFromGitHub {
          owner = "Ramilito";
          repo = "kubediff";
          rev = version;
          sha256 = "sha256-Tjm9UrxvaQk/q6UgWz5OFnwm9XJaTEDe390G5kwN6WM=";
        };

        buildInputs = osSpecific;

        cargoSha256 = "sha256-91RoYfOdAegrsVPbCmWwwzLouNhn7oSklDhYh4ojgmY=";

        meta = with lib; {
          description = "a way to diff k8s specs without managed fields";
          license = licenses.mit;
          maintainers = with maintainers; [ jpetrucciani ];
        };
      })
    { };

  kubectl = prev.kubectl.override {
    kubernetes = (prev.kubernetes.override { buildGoModule = buildGo119Module; }).overrideAttrs (old: rec {
      version = "1.25.0";

      src = fetchFromGitHub {
        owner = "kubernetes";
        repo = "kubernetes";
        rev = "v${version}";
        sha256 = "sha256-TECqNF/NOE6kl94nV7X/QVde0XGyTdKcUk3KhdDzcws=";
      };
    });
  };
}
