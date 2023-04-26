final: prev: with prev; rec {
  llama-cpp-python =
    let
      osSpecific = with pkgs.darwin.apple_sdk.frameworks; if pkgs.stdenv.isDarwin then [ Accelerate ] else [ ];
      llama-cpp-pin = pkgs.fetchFromGitHub {
        owner = "ggerganov";
        repo = "llama.cpp";
        rev = "54bb60e26858be251a0eb3cb70f80322aff804a0";
        hash = "sha256-a+MQ/CUQd+aTQy04P2re5LK4fdLrWRepbBYSv9wXvVE=";
      };
    in
    buildPythonPackage rec {
      pname = "llama-cpp-python";
      version = "0.1.38";

      format = "pyproject";
      src = pkgs.fetchFromGitHub {
        owner = "abetlen";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-/Ykndsp6puFxa+FSHNln9M2frS7/sMMBJSNJ/mU/CSI=";
      };

      preConfigure = ''
        cp -r ${llama-cpp-pin}/. ./vendor/llama.cpp
        chmod -R +w ./vendor/llama.cpp
      '';
      preBuild = ''
        cd ..
      '';
      buildInputs = osSpecific;

      nativeBuildInputs = [
        prev.pkgs.cmake
        prev.pkgs.ninja
        poetry-core
        scikit-build
        setuptools
      ];

      propagatedBuildInputs = [
        typing-extensions
      ];

      pythonImportsCheck = [ "llama_cpp" ];

      meta = with lib; {
        description = "A Python wrapper for llama.cpp";
        homepage = "https://github.com/abetlen/llama-cpp-python";
        license = licenses.mit;
        maintainers = with maintainers; [ jpetrucciani ];
      };
    };

  geojson = prev.geojson.overridePythonAttrs {
    version = "2.5.0";
    src = fetchPypi {
      version = "2.5.0";
      pname = "geojson";
      hash = "sha256-bku3rOQiakXZyMixNIs/xDVAZYNZ+Tw/fgPvqfFfZYo=";
    };
    doCheck = false;
    pythonImportsCheck = [
      "geojson"
    ];
  };

  openapi-schema-pydantic = buildPythonPackage rec {
    pname = "openapi-schema-pydantic";
    version = "1.2.4";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-PiLPWLdKafdSzH5fFTf25EFkKC2ycAy7zTu5nd0GUZY=";
    };

    nativeBuildInputs = [
      setuptools
    ];

    propagatedBuildInputs = [
      pydantic
    ];

    pythonImportsCheck = [ "openapi_schema_pydantic" ];

    meta = with lib; {
      description = "OpenAPI (v3) specification schema as pydantic class";
      homepage = "https://pypi.org/project/openapi-schema-pydantic/1.2.4/";
      license = licenses.mit;
      maintainers = with maintainers; [ jpetrucciani ];
    };
  };

  hnswlib = buildPythonPackage rec {
    pname = "hnswlib";
    version = "0.7.0";

    src = pkgs.fetchFromGitHub {
      owner = "nmslib";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-XXz0NIQ5dCGwcX2HtbK5NFTalP0TjLO6ll6TmH3oflI=";
    };
    nativeBuildInputs = [ ];
    propagatedBuildInputs = [
      pybind11
      numpy
      setuptools
    ];
    pythonImportsCheck = [
      "hnswlib"
    ];
    doCheck = false;
    meta = with lib; {
      description = "Header-only C++/python library for fast approximate nearest neighbors";
      homepage = "https://github.com/nmslib/hnswlib";
      changelog = "https://github.com/nmslib/hnswlib/releases/tag/v${version}";
      license = licenses.asl20;
      maintainers = with maintainers; [ jpetrucciani ];
    };
  };

  pymilvus = prev.pymilvus.overridePythonAttrs (_: rec {
    pname = "pymilvus";
    version = "2.2.6";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-/i3WObwoY6Ffqw+Guij6+uGbKYKET2AJ+d708efmSx0=";
    };
    postPatch = "";
  });

  # chromadb = buildPythonPackage rec {
  #   pname = "chromadb";
  #   version = "0.3.21";
  #   format = "pyproject";

  #   src = fetchPypi {
  #     inherit pname version;
  #     hash = "sha256-ezQXiSZm3JDfEOr65xnuGJA3xEjByW5seWTaqHBIPDo=";
  #   };

  #   nativeBuildInputs = [
  #     setuptools
  #     setuptools-scm
  #   ];

  #   propagatedBuildInputs = [
  #     clickhouse-connect
  #     duckdb
  #     fastapi
  #     hnswlib
  #     numpy
  #     pandas
  #     posthog
  #     pydantic
  #     requests
  #     sentence-transformers
  #     uvicorn
  #   ];

  #   pythonImportsCheck = [ "chromadb" ];

  #   meta = with lib; {
  #     description = "Chroma";
  #     homepage = "https://github.com/chroma-core/chroma";
  #     license = licenses.asl20;
  #     maintainers = with maintainers; [ jpetrucciani ];
  #   };
  # };

  clickhouse-connect = buildPythonPackage rec {
    pname = "clickhouse-connect";
    version = "0.5.20";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-X8moSEnzw7b2kotFoN8X+mPrz05RizpI7HByCVfhhoM=";
    };

    nativeBuildInputs = [
      cython
      setuptools
    ];

    propagatedBuildInputs = [
      certifi
      lz4
      pytz
      urllib3
      zstandard
    ];

    passthru.optional-dependencies = {
      arrow = [
        pyarrow
      ];
      numpy = [
        numpy
      ];
      orjson = [
        orjson
      ];
      pandas = [
        pandas
      ];
      sqlalchemy = [
        sqlalchemy
      ];
      superset = [
        apache-superset
      ];
    };

    pythonImportsCheck = [ "clickhouse_connect" ];

    meta = with lib; {
      description = "ClickHouse core driver, SqlAlchemy, and Superset libraries";
      homepage = "https://github.com/ClickHouse/clickhouse-connect";
      license = licenses.asl20;
      maintainers = with maintainers; [ jpetrucciani ];
    };
  };

  posthog = buildPythonPackage rec {
    pname = "posthog";
    version = "2.5.0";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-dgHvdbSD62emIpyv7ALaliT21G32EGZ3HKnj+YYoT8M=";
    };

    propagatedBuildInputs = [
      backoff
      monotonic
      python-dateutil
      requests
      setuptools
      six
    ];

    passthru.optional-dependencies = {
      dev = [
        black
        flake8
        flake8-print
        isort
        pre-commit
      ];
      sentry = [
        django
        sentry-sdk
      ];
      test = [
        coverage
        flake8
        freezegun
        mock
        pylint
        pytest
      ];
    };

    pythonImportsCheck = [ "posthog" ];

    meta = with lib; {
      description = "Integrate PostHog into any python application";
      homepage = "https://github.com/posthog/posthog-python";
      license = licenses.mit;
      maintainers = with maintainers; [ jpetrucciani ];
    };
  };

  # gptcache = buildPythonPackage rec {
  #   pname = "gptcache";
  #   version = "0.1.10";
  #   format = "setuptools";

  #   src = pkgs.fetchFromGitHub {
  #     owner = "zilliztech";
  #     repo = pname;
  #     rev = version;
  #     hash = "sha256-3qwmd+H0ip3Jq1BqixKEBSKMxzYaKmh5rGBsPCo1ri4=";
  #   };

  #   propagatedBuildInputs = [
  #     cachetools
  #     chromadb
  #     faiss
  #     final.sqlalchemy_1
  #     hnswlib
  #     huggingface-hub
  #     numpy
  #     onnxruntime
  #     openai
  #     pydantic
  #     pymilvus
  #     transformers
  #   ];

  #   preBuild = ''
  #     substituteInPlace ./gptcache/utils/__init__.py --replace '_check_library("torch")' 'pass'
  #   '';

  #   pythonImportsCheck = [ "gptcache" ];

  #   meta = with lib; {
  #     description = "GPTCache, a powerful caching library for LLMs";
  #     homepage = "https://github.com/zilliztech/GPTCache";
  #     license = licenses.mit;
  #     maintainers = with maintainers; [ jpetrucciani ];
  #   };
  # };

  langchain = buildPythonPackage rec {
    pname = "langchain";
    version = "0.0.149";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-gdYJ1FK7Vic81Nq1q7YsJo9NQQLa/8rEo/uKxbj5oto=";
    };

    nativeBuildInputs = [
      poetry-core
    ];

    propagatedBuildInputs = [
      final.sqlalchemy_1
      aiohttp
      dataclasses-json
      jinja2
      numexpr
      numpy
      openapi-schema-pydantic
      pydantic
      pyowm
      pyyaml
      requests
      tenacity
      tqdm
    ];

    passthru.optional-dependencies = {
      all = [
        aleph-alpha-client
        anthropic
        beautifulsoup4
        cohere
        deeplake
        elasticsearch
        faiss-cpu
        google-api-python-client
        google-search-results
        # gptcache
        huggingface-hub
        jina
        jinja2
        manifest-ml
        networkx
        nlpcloud
        nltk
        nomic
        openai
        opensearch-py
        pgvector
        pinecone-client
        psycopg2-binary
        pypdf
        qdrant-client
        redis
        sentence-transformers
        spacy
        tensorflow-text
        tiktoken
        torch
        transformers
        weaviate-client
        wikipedia
        wolframalpha
      ];
      llms = [
        anthropic
        cohere
        huggingface-hub
        manifest-ml
        nlpcloud
        openai
        torch
        transformers
      ];
    };

    # gptcache was added as an optional dep, and it requires many other deps
    postPatch = ''
      ${pkgs.gnused}/bin/sed -i -E '/gptcache =/d' pyproject.toml
    '';

    pythonImportsCheck = [ "langchain" ];

    meta = with lib; {
      description = "Building applications with LLMs through composability";
      homepage = "https://github.com/hwchase17/langchain";
      changelog = "https://github.com/hwchase17/langchain/releases/tag/v${version}";
      license = licenses.mit;
      maintainers = with maintainers; [ jpetrucciani ];
    };
  };

  llama-index = buildPythonPackage rec {
    pname = "llama-index";
    version = "0.5.15";
    format = "setuptools";

    src = fetchPypi {
      pname = "llama_index";
      inherit version;
      hash = "sha256-6zKhSlCgFywLtKoVC3b9IOp4b5cdpmQ3KL7GfZJcoPw=";
    };

    nativeCheckInputs = [
      ipython
      pillow
    ];

    propagatedBuildInputs = [
      langchain
      tiktoken
      numpy
      openai
      pandas
    ];

    pythonImportsCheck = [ "llama_index" ];

    meta = with lib; {
      description = "Interface between LLMs and your data";
      homepage = "https://github.com/jerryjliu/llama_index";
      license = licenses.mit;
      maintainers = with maintainers; [ jpetrucciani ];
    };
  };

  accelerate = buildPythonPackage rec {
    pname = "accelerate";
    version = "0.18.0";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-HdNv2XLeSm0M/+Xk1tMGIv2FN2X3c7VYLPB5be7+EBY=";
    };

    propagatedBuildInputs = [
      numpy
      packaging
      psutil
      pyyaml
      torch
    ];

    passthru.optional-dependencies = {
      dev = [
        black
        datasets
        deepspeed
        evaluate
        hf-doc-builder
        parameterized
        pytest
        pytest-subtests
        pytest-xdist
        rich
        ruff
        scikit-learn
        scipy
        tqdm
        transformers
      ];
      quality = [
        black
        hf-doc-builder
        ruff
      ];
      rich = [
        rich
      ];
      sagemaker = [
        sagemaker
      ];
      test_dev = [
        datasets
        deepspeed
        evaluate
        scikit-learn
        scipy
        tqdm
        transformers
      ];
      test_prod = [
        parameterized
        pytest
        pytest-subtests
        pytest-xdist
      ];
      test_trackers = [
        comet-ml
        tensorboard
        wandb
      ];
      testing = [
        datasets
        deepspeed
        evaluate
        parameterized
        pytest
        pytest-subtests
        pytest-xdist
        scikit-learn
        scipy
        tqdm
        transformers
      ];
    };

    pythonImportsCheck = [ "accelerate" ];

    meta = with lib; {
      description = "Accelerate";
      homepage = "https://github.com/huggingface/accelerate";
      license = licenses.asl20;
      maintainers = with maintainers; [ jpetrucciani ];
    };
  };

  peft = buildPythonPackage rec {
    pname = "peft";
    version = "0.2.0";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-zjP0hMcDgZBwW2nk0iiSMMfBgZwQhHgUg6yOEY8Kca8=";
    };

    propagatedBuildInputs = [
      accelerate
      numpy
      packaging
      psutil
      pyyaml
      torch
      transformers
    ];

    passthru.optional-dependencies = {
      dev = [
        black
        hf-doc-builder
        ruff
      ];
      docs_specific = [
        hf-doc-builder
      ];
      quality = [
        black
        ruff
      ];
    };

    pythonImportsCheck = [ "peft" ];

    meta = with lib; {
      description = "Parameter-Efficient Fine-Tuning (PEFT";
      homepage = "https://github.com/huggingface/peft";
      license = licenses.asl20;
      maintainers = with maintainers; [ jpetrucciani ];
    };
  };
}
