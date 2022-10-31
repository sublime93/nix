final: prev:
with prev;
rec {
  nixup = pog {
    name = "nixup";
    description = "a quick tool to create a base nix environment!";
    flags = [
      {
        name = "mkderivation";
        description = "use 'stdenv.mkDerivation' instead of 'buildEnv'";
        bool = true;
      }
      _.flags.nix.with_elixir
      _.flags.nix.with_golang
      _.flags.nix.with_nim
      _.flags.nix.with_node
      _.flags.nix.with_python
      _.flags.nix.with_ruby
      _.flags.nix.with_rust
      _.flags.nix.with_terraform
      _.flags.nix.with_vlang
    ];
    script = ''
      directory="$(pwd | ${_.sed} 's#.*/##')"
      jacobi=$(${nix_hash_jpetrucciani}/bin/nix_hash_jpetrucciani);
      rev=$(echo "$jacobi" | ${_.jq} -r '.rev')
      sha=$(echo "$jacobi" | ${_.jq} -r '.sha256')
      py=""
      [ "$with_python" = "1" ] && py="python = [(python310.withPackages ( p: with p; [${"\n"}requests]))];"
      vlang=""
      [ "$with_vlang" = "1" ] && vlang="vlang = [vlang.withPackages (p: with p; [])];" && mkderivation=1;
      nim=""
      [ "$with_nim" = "1" ] && nim="nim = [nim.withPackages (p: with p; [])];"
      node=""
      [ "$with_node" = "1" ] && node="node = [nodejs-18_x${"\n"}nodePackages.prettier];" && mkderivation=1;
      golang=""
      [ "$with_golang" = "1" ] && golang="go = [go_1_19${"\n"}go-tools];"
      rust=""
      [ "$with_rust" = "1" ] && rust="rust = [cargo${"\n"}rust-analyzer rustc rustfmt];"
      ruby=""
      [ "$with_ruby" = "1" ] && ruby="ruby = [(ruby_3_1.withPackages ( p: with p; []))${"\n"}sqlite];"
      terraform=""
      [ "$with_terraform" = "1" ] && terraform="terraform = [terraform${"\n"}terraform-ls terrascan tfsec];"
      elixir=""
      [ "$with_elixir" = "1" ] && elixir="elixir = [elixir${"\n"}(with beamPackages; [${"\n"}hex])(ifIsLinux [inotify-tools]) (ifIsDarwin [ terminal-notifier (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ])])];"
      envtype=""
      [ "$mkderivation" = "1" ] && envtype="${"\n"}mkDerivation = true;";
      ${prev.coreutils}/bin/cat -s <<EOF | ${_.nixpkgs-fmt}
        { jacobi ? import
            (
              fetchTarball {
                name = "jacobi-$(date '+%F')";
                url = "https://nix.cobi.dev/x/$rev";
                sha256 = "$sha";
              }
            )
            {}
        }:
        let
          inherit (jacobi.hax) ifIsLinux ifIsDarwin;
        
          name = "$directory";
          tools = with jacobi; {
            cli = [
              jq
              nixpkgs-fmt
            ];
            ''${golang} ''${node} ''${py} ''${rust} ''${ruby} ''${terraform} ''${vlang} ''${nim} ''${elixir}
          };

          env = jacobi.enviro {
            inherit name tools; $envtype
          };
        in
        env
      EOF
    '';
  };

  y2n = writeBashBinChecked "y2n" ''
    yaml="$1"
    json=$(${_.y2j} "$yaml") \
      nix eval --raw --impure --expr \
      'with import ${pkgs.path} {}; lib.generators.toPretty {} (builtins.fromJSON (builtins.getEnv "json"))'
  '';

  cache = writeBashBinCheckedWithFlags {
    name = "cache";
    description = "an easy tool to build nix configs and cache them to cachix!";
    flags = [
      {
        name = "cache_name";
        description = "the cachix to push to";
        default = "medable";
      }
      {
        name = "oldmac";
        description = "optionally build for x86_64-darwin (mac only)";
        bool = true;
      }
    ];
    script = ''
      ${pkgs.nix}/bin/nix-build ''${oldmac:+--system x86_64-darwin} | ${_.cachix} push "$cache_name"
    '';
  };

  nixrender =
    pog {
      name = "nixrender";
      description = "a quick and easy way to use nix to render various other config files!";
      flags = [ ];
      arguments = [
        { name = "nix_file"; }
      ];
      script = ''
        template="$1"
        rendered="$(${pkgs.nix}/bin/nix eval --raw -f "$template")"
        echo "$rendered"
      '';
    };

  hexrender =
    let
      _ = {
        prettier = "${pkgs.nodePackages.prettier}/bin/prettier --write --config ${../../.prettierrc.js}";
        mktemp = "${pkgs.coreutils}/bin/mktemp --suffix=.yaml";
        realpath = "${pkgs.coreutils}/bin/realpath";
        nix = "${pkgs.nix}/bin/nix";
      };
    in
    pog {
      name = "hexrender";
      description = "a quick and easy way to use nix to render various other config files!";
      flags = [
        # {
        #   name = "sort";
        #   description = "apply sort to the resulting yaml";
        # }
        # {
        #   name = "crds";
        #   description = "filter the results to only the crds";
        # }
      ];
      arguments = [
        { name = "nix_file"; }
      ];
      script = helpers: with helpers; ''
        ${var.notEmpty "1"} && spell="$1"
        ${var.empty "spell"} && spell="$(${_.mktemp})" && cp /dev/stdin "$spell"
        spell_render="$(${_.mktemp})"
        fullpath="$(${_.realpath} "$spell")"
        debug "casting $fullpath - hex files at ${./hex}"
        ${_.nix} eval --raw --impure --expr "import ${./hex}/spell.nix \"$fullpath\"" >"$spell_render"
        # if ${flag "crds"}; then
        #   debug "filtering to crds only"
        #   tmp_filter="$(${_.mktemp})"
        #   cat "$rendered"
        # fi
        # if ${flag "sort"}; then
        #   debug "sorting yaml"
        #   tmp_sort="$(${_.mktemp})"
        #   cat "$rendered"
        # fi
        debug "formatting $fullpath"
        ${_.prettier} --parser yaml "$spell_render" &>/dev/null
        cat "$spell_render"
      '';
    };

  hex = pog {
    name = "hex";
    description = "a quick and easy way to render full kubespecs from nix files";
    flags = [
      {
        name = "target";
        description = "the file to render specs from";
        default = "./specs.nix";
      }
      {
        name = "dryrun";
        description = "just run the diff, don't prompt to apply";
        bool = true;
      }
      {
        name = "render";
        description = "only render and patch, do not diff or apply";
        bool = true;
      }
      {
        name = "check";
        description = "whether to check the hex for deprecations";
        bool = true;
      }
      {
        name = "prettify";
        description = "whether to run prettier on the hex output yaml";
        bool = true;
      }
      {
        name = "force";
        description = "force apply the resulting hex without a diff (WARNING - BE CAREFUL)";
        bool = true;
      }
    ];
    script =
      let
        steps = {
          render = "render";
          patch = "patch";
          diff = "diff";
          apply = "apply";
        };
        _ = {
          k = "${pkgs.kubectl}/bin/kubectl";
          hr = "${hexrender}/bin/hexrender";
          delta = "${pkgs.delta}/bin/delta";
          mktemp = "${pkgs.coreutils}/bin/mktemp";
          prettier = "${pkgs.nodePackages.prettier}/bin/prettier --write --config ${../../.prettierrc.js}";
        };
      in
      helpers: with helpers; ''
        export USE_GKE_GCLOUD_AUTH_PLUGIN=True
        ${file.notExists "target"} && die "the file to render ('$target') does not exist!"
        rendered=$(${_.mktemp})
        diffed=$(${_.mktemp})
        debug "''${GREEN}render to '$rendered'"
        ${timer.start steps.render}
        ${_.hr} "$target" >"$rendered"
        render_exit_code=$?
        render_runtime=${timer.stop steps.render}
        debug "''${GREEN}rendered to '$rendered' in $render_runtime''${RESET}"
        if [ $render_exit_code -ne 0 ]; then
          die "nixrender failed!" 2
        fi
        ${flag "prettify"} && ${_.prettier} --parser yaml "$rendered" >/dev/null
        if ${flag "render"}; then
          cat "$rendered"
          exit 0
        fi
        if ${flag "force"}; then
          ${timer.start steps.apply}
          ${pkgs.kubectl}/bin/kubectl apply -f "$rendered"
          apply_runtime=${timer.stop steps.apply}
          debug "''${GREEN}force applied '$rendered' in $apply_runtime''${RESET}"
          exit 0
        fi
        ${timer.start steps.diff}
        ${_.k} diff -f "$rendered" >"$diffed"
        diff_exit_code=$?
        diff_runtime=${timer.stop steps.diff}
        debug "''${GREEN}diffed '$rendered' to '$diffed' in $diff_runtime [exit code $diff_exit_code]''${RESET}"
        if [ $diff_exit_code -ne 0 ] && [ $diff_exit_code -ne 1 ]; then
          die "diff of hex failed!" 3
        fi
        if [ -s "$diffed" ]; then
          debug "''${GREEN}changes detected!''${RESET}"
        else
          blue "no changes in hex detected!"
          exit 0
        fi
        ${_.delta} <"$diffed"
        ${flag "dryrun"} && exit 0
        echo "---"
        ${confirm {prompt="Would you like to apply these changes?";}}
        echo "---"
        ${timer.start steps.apply}
        ${_.k} apply -f "$rendered"
        apply_runtime=${timer.stop steps.apply}
        debug "''${GREEN}applied '$rendered' in $apply_runtime''${RESET}"
      '';
  };

  nix_pog_scripts = [
    nixup
    y2n
    cache
    nixrender
    hex
    hexrender
  ];
}
