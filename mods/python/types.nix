(final: prev: with prev; rec {
  boto3-stubs = buildPythonPackage rec {
    pname = "boto3-stubs";
    version = "1.20.35";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1nnd8jjakbcfjsfwn0w7i8mkqj7zji7x2vzmgklbrh3hw10ig95p";
    };

    propagatedBuildInputs = [ botocore-stubs ];
    checkInputs = [
      boto3
    ];
    pythonImportsCheck = [
      "boto3-stubs"
    ];

    meta = {
      description =
        "Type annotations for boto3 1.20.35, generated by mypy-boto3-builder 6.3.1";
      homepage = "https://github.com/vemel/mypy_boto3_builder";
    };
  };

  botocore-stubs = buildPythonPackage rec {
    pname = "botocore-stubs";
    version = "1.24.6";

    src = fetchPypi {
      inherit pname version;
      sha256 = "093zsj2wk7xw89yvs7w88z9w3811vkpgfv4q3wk9j6gd6n3hr1pw";
    };

    pythonImportsCheck = [
      "botocore-stubs"
    ];

    meta = {
      description =
        "Type annotations for botocore 1.24.6 generated with mypy-boto3-builder 7.1.2";
      homepage = "https://github.com/vemel/mypy_boto3_builder";
    };
  };
})
