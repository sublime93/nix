final: prev:
with prev;
rec {
  _chart_scan = { name, index_url, chart_url, last ? 10 }:
    let
      mktemp = "${pkgs.coreutils}/bin/mktemp";
      jq = "${pkgs.jq}/bin/jq";
      yq = "${yq-go}/bin/yq";
      parallel = "${pkgs.parallel}/bin/parallel --will-cite --keep-order -j0 --colsep ' '";
    in
    pog {
      name = "chart_scan_${name}";
      description = "a quick and easy way to get the latest x releases of the '${name}' chart!";
      script = ''
        # temp files
        temp_json="$(${mktemp} --suffix=.json)"
        temp_csv="$(${mktemp} --suffix=.csv)"

        # grab index for this chart
        ${curl}/bin/curl -L -s '${index_url}' | \
            ${yq} '.[].${name}.[] | [{"version": .version, "date": .created}]' | \
            ${coreutils}/bin/head -n ${toString (last * 2)} | \
            ${yq} -o=json >"$temp_json"

        # form csv, hash in parallel
        echo "version,date,sha256" >>"$temp_csv"
        ${jq} -r '.[] | (.version + " " + .date)' <"$temp_json" | \
            ${parallel} 'echo -n "{1},{=2 uq(); =},"; nix-prefetch-url --unpack "${chart_url}" 2>/dev/null' >>"$temp_csv"

        # format as json
        ${yq} "$temp_csv" -p=csv -o=json
      '';
    };

  chart_scan_argo-cd = _chart_scan {
    name = "argo-cd";
    index_url = "https://argoproj.github.io/argo-helm/index.yaml";
    chart_url = "https://github.com/argoproj/argo-helm/releases/download/argo-cd-{1}/argo-cd-{1}.tgz";
  };

  chart_scan_datadog = _chart_scan {
    name = "datadog";
    index_url = "https://helm.datadoghq.com/index.yaml";
    chart_url = "https://github.com/DataDog/helm-charts/releases/download/datadog-{1}/datadog-{1}.tgz";
  };

  chart_scan_external-secrets = _chart_scan {
    name = "external-secrets";
    index_url = "https://charts.external-secrets.io/index.yaml";
    chart_url = "https://github.com/external-secrets/external-secrets/releases/download/helm-chart-{1}/external-secrets-{1}.tgz";
  };

  chart_scan_gitlab-runner = let base = "https://gitlab-charts.s3.amazonaws.com"; in
    _chart_scan {
      name = "gitlab-runner";
      index_url = "${base}/index.yaml";
      chart_url = "${base}/gitlab-runner-{1}.tgz";
    };

  chart_scan_traefik = let base = "https://helm.traefik.io/traefik"; in
    _chart_scan {
      name = "traefik";
      index_url = "${base}/index.yaml";
      chart_url = "${base}/traefik-{1}.tgz";
    };

  helm_pog_scripts = [
    chart_scan_argo-cd
    chart_scan_datadog
    chart_scan_external-secrets
    chart_scan_gitlab-runner
    chart_scan_traefik
  ];
}
