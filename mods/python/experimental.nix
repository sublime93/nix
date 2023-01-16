final: prev: prev.hax.pythonPackageOverlay
  (self: super: with super; rec {
    pynecone-io =
      let
        newStarlette = let version = "0.23.1"; in
          starlette.overridePythonAttrs (_: {
            inherit version;
            format = "pyproject";
            nativeBuildInputs = [
              hatchling
            ];
            src = pkgs.fetchFromGitHub {
              owner = "encode";
              repo = "starlette";
              rev = "refs/tags/${version}";
              hash = "sha256-LcFrdaRgFBqcdylCzNlewj/papsg/sZ1FMVxBDLvQWI=";
            };
            patches = [ ];
            checkInputs = [
              httpx
            ];
          });
        newFastapi = let version = "0.88.0"; in
          fastapi.overridePythonAttrs (_: {
            inherit version;
            src = pkgs.fetchFromGitHub {
              owner = "tiangolo";
              repo = "fastapi";
              rev = "refs/tags/${version}";
              hash = "sha256-2rjKmQcehqkL5OnmtLRTvsyUSpK2aUgyE9VLvz+oWNw=";
            };
            propagatedBuildInputs = [
              newStarlette
              newPydantic
            ];
            disabledTestPaths = _.disabledTestPaths ++ [ "tests/test_generate_unique_id_function.py" ];
          });
        newPydantic = let version = "1.10.2"; in
          (pydantic.override { withDocs = false; }).overridePythonAttrs (_: {
            inherit version;
            src = pkgs.fetchFromGitHub {
              owner = "pydantic";
              repo = "pydantic";
              rev = "refs/tags/v${version}";
              sha256 = "sha256-NQMnqcN2muQd6J4RtL5IcSO5OdQnIR28rmwCSWGfe14=";
            };
          });
        newRedis = let version = "4.4.0"; in
          redis.overridePythonAttrs (_: {
            inherit version;
            src = fetchPypi {
              inherit version;
              pname = "redis";
              sha256 = "sha256-e4yH0ZxF0/EnGxJIWNKlwTFgxOdNSDXignNAD6NNUig=";
            };
          });
        sqlalchemy2-stubs = buildPythonPackage rec {
          pname = "sqlalchemy2-stubs";
          version = "0.0.2a30";

          src = fetchPypi {
            inherit pname version;
            sha256 = "0qi5k8k1qv9i5khx3ylyhb52xra67gmiq4pmbwhp3r6b85kn1rx6";
          };

          propagatedBuildInputs = [ typing-extensions ];
          meta = with lib; { };
        };
        sqlmodel = buildPythonPackage rec {
          pname = "sqlmodel";
          version = "0.0.8";

          src = fetchPypi {
            inherit pname version;
            sha256 = "sha256-M3G00a1Z0v/QxTBYLCFAtsBrCQsyr5ucZBKYbXsRcDY=";
          };

          propagatedBuildInputs = [
            newPydantic
            sqlalchemy
            sqlalchemy2-stubs
          ];

          meta = with lib; { };
        };
        typer = buildPythonPackage rec {
          pname = "typer";
          version = "0.4.2";

          format = "flit";
          src = fetchPypi {
            inherit pname version;
            sha256 = "00zcc8gk37q7j5y0ycawf6699mp5fyk6paavid3p7paj05n1q9mq";
          };

          propagatedBuildInputs = [
            click
          ];
          meta = with lib; { };
        };
      in
      buildPythonPackage rec {
        pname = "pynecone";
        version = "0.1.12";
        format = "pyproject";


        src = pkgs.fetchFromGitHub {
          owner = "pynecone-io";
          repo = "pynecone";
          rev = "v${version}";
          sha256 = "sha256-Vrhq6TratGfwA+WKf17k3z/8zNSRNhnpgubBUic457s=";
        };

        propagatedBuildInputs = [
          pkgs.nodejs-18_x
          gunicorn
          httpx
          plotly
          poetry-core
          rich
          uvicorn
          websockets
          # special
          sqlmodel
          typer
          newFastapi
          newPydantic
          newRedis
        ];

        preBuild = ''
          ${pkgs.gnused}/bin/sed -i -E 's#BUN_PATH =.*#BUN_PATH = "${pkgs.bun}/bin/bun"#g' ./pynecone/constants.py
        '';

        pythonImportsCheck = [
          "pynecone"
        ];

        meta = with lib; {
          description = "Web apps in pure Python";
          homepage = "https://github.com/pynecone-io/pynecone";
          license = licenses.asl20;
          maintainers = with maintainers; [ jpetrucciani ];
        };
      };

    # emmett
    emmett-rest = buildPythonPackage rec {
      pname = "rest";
      version = "1.4.5";
      format = "pyproject";

      disabled = pythonOlder "3.7";
      src = pkgs.fetchFromGitHub {
        owner = "emmett-framework";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-9sWZSYQAY5Mmk8pkcYZoFEZ20g/MOEyatjTE8xwd1Ks=";
      };

      propagatedBuildInputs = [
        poetry-core
        pydantic
        emmett
      ];

      checkInputs = [
        pytestCheckHook
      ];

      # TODO: re-enable tests
      doCheck = false;

      pythonImportsCheck = [
        "emmett_rest"
      ];

      meta = with lib; {
        description = "REST extension for Emmett framework";
        changelog = "https://github.com/emmett-framework/rest/blob/master/CHANGES.md";
        homepage = "https://github.com/emmett-framework/rest";
        license = licenses.bsd3;
        maintainers = with maintainers; [ jpetrucciani ];
      };
    };

    renoir = buildPythonPackage rec {
      pname = "renoir";
      version = "1.6.0";
      format = "pyproject";

      disabled = pythonOlder "3.7";
      src = pkgs.fetchFromGitHub {
        owner = "emmett-framework";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-PTmaOCkkKYsPTzD9m9T1IIew00OskZ/bXXvzcmVRWUA=";
      };

      propagatedBuildInputs = [
        poetry-core
        pyyaml
      ];

      checkInputs = [
        pytestCheckHook
      ];

      preBuild = ''
        mv ./pyproject.toml ./pyproject.bak
        ${yq}/bin/tomlq -yt 'del(.tool.poetry.include)' ./pyproject.bak > ./pyproject.toml
      '';

      pythonImportsCheck = [
        "renoir"
      ];

      meta = with lib; {
        description = "A templating engine designed with simplicity in mind";
        changelog = "https://github.com/emmett-framework/renoir/blob/master/CHANGES.md";
        homepage = "https://github.com/emmett-framework/renoir";
        license = licenses.bsd3;
        maintainers = with maintainers; [ jpetrucciani ];
      };
    };

    severus = buildPythonPackage rec {
      pname = "severus";
      version = "1.2.0";
      format = "pyproject";

      disabled = pythonOlder "3.7";
      src = pkgs.fetchFromGitHub {
        owner = "emmett-framework";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-JO9AGKqko2xKU8siKDkhCclWO6yqW9sSzFGpeQLSCXI=";
      };

      propagatedBuildInputs = [
        poetry-core
        pyyaml
      ];

      preBuild = ''
        sed -i -E 's#pyyaml = "\^5.3.1"#pyyaml = "\^6.0.0"#' ./pyproject.toml
        mv ./pyproject.toml ./pyproject.bak
        ${yq}/bin/tomlq -yt 'del(.tool.poetry.include)' ./pyproject.bak > ./pyproject.toml
      '';

      pythonImportsCheck = [
        "severus"
      ];

      checkInputs = [
        pytestCheckHook
      ];

      meta = with lib; {
        description = "An internationalization engine designed with simplicity in mind";
        changelog = "https://github.com/emmett-framework/severus/blob/master/CHANGES.md";
        homepage = "https://github.com/emmett-framework/severus";
        license = licenses.bsd3;
        maintainers = with maintainers; [ jpetrucciani ];
      };
    };

    emmett = buildPythonPackage rec {
      pname = "emmett";
      version = "2.4.13";
      format = "pyproject";

      disabled = pythonOlder "3.7";
      src = pkgs.fetchFromGitHub {
        owner = "emmett-framework";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-crKVQ1URCRztp7vMQKHxwDf5y72opKlPezW6LX/QXzU=";
      };

      propagatedBuildInputs = [
        click
        h11
        h2
        pendulum
        (pydal.overridePythonAttrs (_: rec {
          version = "17.3";
          src = pkgs.fetchFromGitHub {
            owner = "web2py";
            repo = "pydal";
            rev = "v17.03";
            sha256 = "sha256-ZxdWhdtZDMXf5oIjprVNS4iSLei4w/wtT/5cqMXbIXw=";
          };
        }))
        pyaes
        python-rapidjson
        pyyaml
        renoir
        severus
        uvicorn
        websockets
        httptools
        uvloop
      ];

      pythonImportsCheck = [
        "emmett"
      ];

      preBuild = ''
        sed -i -E 's#pyyaml = "\^5.4"#pyyaml = "\^6.0.0"#' ./pyproject.toml
        sed -i -E 's#uvicorn = "\~0.19.0"#uvicorn = "\~0.20.0"#' ./pyproject.toml
        sed -i -E 's#h2 = ">= 3.2.0\, < 4.1.0"#h2 = ">= 4.1.0"#' ./pyproject.toml
        mv ./pyproject.toml ./pyproject.bak
        ${yq}/bin/tomlq -yt 'del(.tool.poetry.include)' ./pyproject.bak > ./pyproject.toml
      '';

      checkInputs = [
        pytestCheckHook
      ];

      meta = with lib; {
        description = "The web framework for inventors";
        homepage = "https://emmett.sh";
        changelog = "https://github.com/emmett-framework/emmett/blob/master/CHANGES.md";
        license = licenses.bsd3;
        maintainers = with maintainers; [ jpetrucciani ];
      };
    };

    granian = buildPythonPackage rec {
      pname = "granian";
      version = "0.2.1";

      format = "pyproject";
      src = pkgs.fetchFromGitHub {
        owner = "emmett-framework";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-8xgHhrV9gdE5b9meNr2rRxPbufRPVy2kClZeIRoEZgM=";
      };

      cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
        inherit src sourceRoot;
        name = "${pname}-${version}";
        sha256 = "sha256-cyDQ+mN6xT3hF0FPy5QmXE+2rTFnw5mIShyoGZanS6A=";
      };
      sourceRoot = "";

      preBuild = ''
        sed -i -E 's#typer\~=0.4.1#typer\~=0.6.1#' ./pyproject.toml
      '';

      propagatedBuildInputs = [
        typer
        uvloop
      ];

      nativeBuildInputs = [
        setuptools-rust
        pkgs.installShellFiles
      ] ++ (with pkgs.rustPlatform; [
        cargoSetupHook
        maturinBuildHook
        rust.cargo
        rust.rustc
      ]);

      postInstall = ''
        installShellCompletion --cmd granian \
          --bash <($out/bin/granian --show-completion bash) \
          --fish <($out/bin/granian --show-completion fish) \
          --zsh  <($out/bin/granian --show-completion zsh)
      '';

      meta = with lib; {
        description = "A Rust HTTP server for Python applications";
        homepage = "https://github.com/emmett-framework/granian";
        license = licenses.bsd3;
        maintainers = with maintainers; [ jpetrucciani ];
      };
    };

  })
  [ "python310" "python311" ]
  final
  prev
