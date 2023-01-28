let
  pkgs = import ./default.nix { };
  inherit (pkgs.hax) isDarwin isX86Mac fetchFromGitHub;

  firstName = "jacobi";
  lastName = "petrucciani";
  personalEmail = "j@cobi.dev";
  workEmail = "jacobi.petrucciani@medable.com";

  onAws = builtins.getEnv "USER" == "ubuntu";
  promptChar = if isDarwin then "ᛗ" else "ᛥ";

  username =
    if isDarwin then
      firstName
    else
      (if onAws then "ubuntu" else firstName);
  homeDirectory =
    if isDarwin then
      "/Users/${firstName}"
    else
      (if onAws then "/home/ubuntu" else "/home/${firstName}");

  # home-manager pin
  hm = with builtins; fromJSON (readFile ./sources/home-manager.json);
  home-manager = fetchFromGitHub {
    inherit (hm) rev sha256;
    owner = "nix-community";
    repo = "home-manager";
  };

  sessionVariables = {
    EDITOR = "nano";
    HISTCONTROL = "ignoreboth";
    PAGER = "less";
    LESS = "-iR";
    BASH_SILENCE_DEPRECATION_WARNING = "1";

    # haskell?
    IHP_EDITOR = "code --goto";

    # thanks google
    USE_GKE_GCLOUD_AUTH_PLUGIN = "True";
  };

  optList = conditional: list: if conditional then list else [ ];

in
with pkgs.hax; {
  nixpkgs.overlays = import ./overlays.nix;
  nixpkgs.config = { allowUnfree = true; };

  programs.home-manager.enable = true;
  programs.home-manager.path = "${home-manager}";

  programs.btop.enable = true;
  programs.htop.enable = true;
  programs.dircolors.enable = true;

  # broken manpages upstream, see: https://github.com/nix-community/home-manager/issues/3342
  manual.manpages.enable = false;

  home = {
    inherit username homeDirectory sessionVariables;

    stateVersion = "22.11";

    packages = with pkgs;
      lib.flatten [
        bash-completion
        bashInteractive
        bat
        bzip2
        cacert
        cachix
        charm
        coreutils-full
        cowsay
        curl
        diffutils
        docker-client
        dogdns
        dos2unix
        dyff
        ed
        exa
        fd
        figlet
        file
        fq
        gawk
        genpass
        gitAndTools.delta
        gnugrep
        gnumake
        gnupg
        gnused
        gnutar
        google-cloud-sdk
        gron
        gum
        gzip
        htmlq
        jq
        just
        libarchive
        libnotify
        lolcat
        loop
        lsof
        man-pages
        manix
        moreutils
        nano
        nanorc
        netcat-gnu
        nil
        nix
        nix-info
        nix-output-monitor
        nix-prefetch-github
        nix-prefetch-scripts
        nix-tree
        nix-update
        nixpkgs-fmt
        nixpkgs-review
        openssh
        p7zip
        patch
        pigz
        procps
        pssh
        ranger
        re2c
        ripgrep
        ripgrep-all
        rlwrap
        ruff
        scc
        scrypt
        shellcheck
        shfmt
        skate
        statix
        step-cli
        terraform-ls
        time
        unzip
        watch
        wget
        which
        yank
        yq-go
        zip

        # python
        (python310.withPackages
          (pkgs: with pkgs; [
            # linting
            black
            mypy

            # common use case
            gamble
            httpx
            requests
            cryptography

            # text
            anybadge
            tabulate
            beautifulsoup4
            praw

            # api
            fastapi
            uvicorn

            # 3rd party apis
            geoip2

            # data
            numpy
            pandas
            scipy

            # type annotations (from nixpkgs)
            types-requests
            types-tabulate
            types-enum34
            types-ipaddress

            # my types (for nixpkgs)
            boto3-stubs
            botocore-stubs

            # my packages (for nixpkgs)
            notion-client
          ]
          ++ (optList (!isM1) [ ])
          ++ (optList isLinux [
            bpython
          ])
          )
        )

        # kubernetes
        kubectl
        kubectx
        fluxctl
        ## thanks google
        gke-gcloud-auth-plugin

        # load in my custom checked pog scripts
        hms
        aws_pog_scripts
        docker_pog_scripts
        ffmpeg_pog_scripts
        gcp_pog_scripts
        general_pog_scripts
        github_pog_scripts
        hax_pog_scripts
        helm_pog_scripts
        k8s_pog_scripts
        nix_pog_scripts
        python_pog_scripts
        ssh_pog_scripts

        # my pkgs
        cloudquery
        cyclonus
        goldilocks
        horcrux
        hunt
        mdctl
        overflow
        poglets
        q
        rare
        regula
        s3-edit
        ov
        cgapp

        # overlays
        nix_hash_unstable
        nix_hash_nixos_unstable
        nix_hash_jpetrucciani
        nix_hash_kwb
        nix_hash_hm
        nix_hash_darwin
        nix_hash_medable
        nix_hash_nix-security-box
        nix_hash_nix2container
        nix_hash_devenv
        nixup
        foo

        # keef's stuff
        hax.comma

        # sounds
        meme_sounds

        # mac specific
        (
          optList isDarwin [
            lima
          ]
        )

        # all except old mac
        (
          optList (!isX86Mac) [
            git-trim
            watcher
          ]
        )

        # linux specific
        (
          optList isLinux [
            binutils
            bitwarden-cli
            keybase
            ncdu
            sampler
            vtm

            # k8s tools
            katafygio
            kube-linter
            pluto
            rbac-tool
          ]
        )

        # ubuntu specific
        (
          optList isUbuntu [
            (
              writeBashBinChecked "u" ''
                sudo apt update
                sudo apt upgrade
              ''
            )
          ]
        )

        # android specific
        (
          optList isAndroid [
            starship
          ]
        )

      ];
  };

  programs.less.enable = true;
  programs.lesspipe.enable = true;

  programs.yt-dlp = {
    enable = true;
    extraConfig = ''
      --embed-thumbnail
      --embed-metadata
      --embed-subs
      --sub-langs all
      --downloader aria2c
      --downloader-args aria2c:'-c -x8 -s8 -k1M'
    '';
  };

  programs.bash = {
    inherit sessionVariables;
    enable = true;
    historyFileSize = -1;
    historySize = -1;
    shellAliases = {
      ls = "ls --color=auto";
      l = "${pkgs.exa}/bin/exa -alFT -L 1";
      ll = "ls -ahlFG";
      mkdir = "mkdir -pv";
      fzfp = "${pkgs.fzf}/bin/fzf --preview 'bat --style=numbers --color=always {}'";
      strip = ''${pkgs.gnused}/bin/sed -E 's#^\s+|\s+$##g' '';

      # git
      g = "git";
      ga = "git add -A .";
      cm = "git commit -m ";

      # misc
      space = "du -Sh | sort -rh | head -10";
      now = "date +%s";
      uneek = "awk '!a[$0]++'";
    } // docker_aliases // kubernetes_aliases;
    bashrcExtra =
      if isDarwin then ''
        export PATH="$PATH:${homeDirectory}/.nix-profile/bin"
      '' else "";
    initExtra = ''
      HISTCONTROL=ignoreboth
      set +h
      export PATH="$PATH:$HOME/.bin/"
      export PATH="$PATH:$HOME/.npm/bin/"

      # asdf and base nix
    '' + (if isM1 then ''
      export CONFIGURE_OPTS="--build aarch64-apple-darwin20"
    ''
    else ""
    ) + (
      if isDarwin then ''
        # add brew to path
        brew_path="/opt/homebrew/bin/brew"
        if [ -f /usr/local/bin/brew ]; then
          brew_path="/usr/local/bin/brew"
        fi
        eval "$($brew_path shellenv)"

        # load asdf if its there
        asdf_dir="$(brew --prefix asdf)"
        [[ -e "$asdf_dir/asdf.sh" ]] && source "$asdf_dir/asdf.sh"
        [[ -e "$asdf_dir/etc/bash_completion.d/asdf.bash" ]] && source "$asdf_dir/etc/bash_completion.d/asdf.bash"
      '' else ''
        [[ -e $HOME/.asdf/asdf.sh ]] && source $HOME/.asdf/asdf.sh
        [[ -e $HOME/.asdf/completions/asdf.bash ]] && source $HOME/.asdf/completions/asdf.bash
      ''
    ) + ''
      _kube_contexts() {
        local curr_arg;
        curr_arg=''${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=( $(compgen -W "- $(${pkgs.kubectl}/bin/kubectl config get-contexts --output='name')" -- $curr_arg ) );
      }

      _kube_namespaces() {
        local curr_arg;
        curr_arg=''${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=( $(compgen -W "- $(${pkgs.kubectl}/bin/kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')" -- $curr_arg ) );
      }

      # additional aliases
      [[ -e ~/.aliases ]] && source ~/.aliases

      # bash completions
      export XDG_DATA_DIRS="$HOME/.nix-profile/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      source <(${pkgs.kubectl}/bin/kubectl completion bash)
      source ~/.nix-profile/etc/profile.d/bash_completion.sh
      source ~/.nix-profile/share/bash-completion/completions/docker
      source ~/.nix-profile/share/bash-completion/completions/git
      source ~/.nix-profile/share/bash-completion/completions/ssh
      complete -o bashdefault -o default -o nospace -F __git_wrap__git_main g
      complete -F _docker d
      complete -F __start_kubectl k
      complete -F _kube_contexts kubectx kx
      complete -F _kube_namespaces kubens kns
    '' + (if isAndroid then ''
      eval "$(starship init bash)"
    '' else "") + (if isNixOS then ''
      ${pkgs.figlet}/bin/figlet "$(hostname)" | ${pkgs.lolcat}/bin/lolcat
      echo
    '' else "");
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.readline = {
    enable = true;
    variables = {
      show-all-if-ambiguous = true;
      skip-completed-text = true;
      bell-style = false;
    };
    bindings = {
      "\\e[1;5D" = "backward-word";
      "\\e[1;5C" = "forward-word";
      "\\e[5D" = "backward-word";
      "\\e[5C" = "forward-word";
      "\\e\\e[D" = "backward-word";
      "\\e\\e[C" = "forward-word";
    };
  };

  programs.helix = {
    enable = true;
  };

  programs.mcfly = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = false;
    defaultCommand = "fd -tf -c always -H --ignore-file ${./ignore} -E .git";
    defaultOptions = words "--ansi --reverse --multi --filepath-word";
  };

  programs.nnn = {
    enable = true;
  };

  home.file = {
    ssh_config = {
      target = ".ssh/config";
      text = pkgs.hax.ssh.config;
    };
    ssh_config_github = {
      target = ".ssh/config.d/github";
      text = pkgs.hax.ssh.github;
    };
    curlrc = {
      target = ".curlrc";
      text = ''
        --netrc-optional
      '';
    };
    sqliterc = {
      target = ".sqliterc";
      text = ''
        .output /dev/null
        .headers on
        .mode column
        .prompt "> " ". "
        .separator ROW "\n"
        .nullvalue NULL
        .output stdout
      '';
    };
    prettierrc = {
      target = ".prettierrc.js";
      text = ''
        const config = {
          printWidth: 100,
          arrowParens: 'always',
          singleQuote: true,
          tabWidth: 2,
          useTabs: false,
          semi: true,
          bracketSpacing: false,
          bracketSameLine: false,
          requirePragma: false,
          proseWrap: 'preserve',
          trailingComma: 'all',
        };
        module.exports = config;
      '';
    };
    ${attrIf isLinux "gpgconf"} = {
      target = ".gnupg/gpg.conf";
      text = ''
        use-agent
        pinentry-mode loopback
      '';
    };
    ${attrIf isLinux "gpgagentconf"} = {
      target = ".gnupg/gpg-agent.conf";
      text = ''
        allow-loopback-pinentry
      '';
    };
    ${attrIf isDarwin "gpgagentconf"} = {
      target = ".gnupg/gpg-agent.conf";
      text = ''
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
      '';
    };
    ${attrIf false "vscodeserver"} = {
      target = ".vscode-server/data/Machine/settings.json";
      text =
        let
          # options
          formatOnSave = "editor.formatOnSave";
          formatter = "editor.defaultFormatter";
          tabSize = "editor.tabSize";

          # vscode extensions
          extensions = {
            elixir-ls = "JakeBecker.elixir-ls";
            nixpkgs-fmt = "B4dM4n.nixpkgs-fmt";
            prettier = "esbenp.prettier-vscode";
            python = "ms-python.python";
            rust = "statiolake.vscode-rustfmt";
            shell-format = "foxundermoon.shell-format";
            terraform = "hashicorp.terraform";
          };
          nix-bin = "${homeDirectory}/.nix-profile/bin";
        in
        ''
          {
            "telemetry.telemetryLevel": "off",
            "${formatOnSave}": true,
            "${formatter}": "${extensions.prettier}",
            "python.formatting.blackPath": "${nix-bin}/black",
            "python.linting.mypyPath": "${nix-bin}/mypy",
            "python.linting.mypyEnabled": true,
            "python.linting.flake8Args": ["--max-line-length=120", "--ignore=W503,W605"],
            "python.languageServer": "Pylance",
            "python.analysis.diagnosticSeverityOverrides": {
              "reportMissingImports": "none",
              "reportInvalidStringEscapeSequence": "none"
            },
            "python.formatting.provider": "black",
            "ruff.path": ["${nix-bin}/ruff"],
            "prettier.configPath": "${homeDirectory}/.prettierrc.js",
            "nix.enableLanguageServer": true,
            "nix.serverPath": "${nix-bin}/nil",
            "nix.formatterPath": "${nix-bin}/nixpkgs-fmt",
            "nixEnvSelector.nixFile": "${workspaceRoot}/default.nix",
            "[nix]": {
              "${formatter}": "${extensions.nixpkgs-fmt}",
              "${tabSize}": 2
            },
            "[terraform]": {
              "${formatter}": "${extensions.terraform}",
              "${formatOnSave}": true,
              "${tabSize}": 2
            },
            "[json]": {
              "${formatter}": "${extensions.prettier}",
              "${formatOnSave}": true,
              "${tabSize}": 2
            },
            "[jsonc]": {
              "${formatter}": "${extensions.prettier}",
              "${formatOnSave}": true,
              "${tabSize}": 2
            },
            "[haskell]": {
              "${formatter}": "haskell.haskell",
              "${formatOnSave}": true
            },
            "[dockerfile]": { "${formatter}": "${extensions.prettier}" },
            "[elixir]": {"${formatter}": "${extensions.elixir-ls}"},
            "[ignore]": { "${formatter}": "${extensions.shell-format}" },
            "[properties]": { "${formatter}": "${extensions.shell-format}" },
            "[python]": {"${formatter}": "${extensions.python}"},
            "[rust]": { "${formatter}": "${extensions.rust}" },
            "[shellscript]": { "${formatter}": "${extensions.shell-format}" },
            "[typescript]": {"${formatter}": "${extensions.prettier}"},
            "[typescriptreact]": {"${formatter}": "${extensions.prettier}"},
            "terraform.languageServer.enable": true,
            "terraform.languageServer.args": ["serve"],
            "terraform.languageServer.ignoreSingleFileWarning": false,
            "terraform.languageServer.path": "${nix-bin}/terraform-ls",
            "zircon.shell": "${nix-bin}/bash",
            "shellformat.path": "${nix-bin}/shfmt"
          }
        '';
    };
  };

  # starship config
  programs.starship = {
    enable = !isAndroid;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[${promptChar}](bright-green)";
        error_symbol = "[${promptChar}](bright-red)";
      };
      golang = {
        style = "fg:#00ADD8";
        symbol = "go ";
      };
      directory.style = "fg:#d442f5";
      localip = {
        disabled = true;
      };
      nix_shell = {
        pure_msg = "";
        impure_msg = "";
        format = "via [$symbol$state($name)]($style) ";
      };
      kubernetes = {
        disabled = false;
        style = "fg:#326ce5";
      };
      terraform = {
        disabled = false;
        format = "via [$symbol $version]($style) ";
        symbol = "🌴";
      };
      nodejs = { symbol = "⬡ "; };
      hostname = {
        style = "bold fg:46";
      };
      username = {
        style_user = "bold fg:93";
      };

      # disabled plugins
      aws.disabled = true;
      cmd_duration.disabled = true;
      gcloud.disabled = true;
      package.disabled = true;
    };
  };

  # gitconfig
  programs.git =
    let
      gs = text:
        let
          script = pkgs.writers.writeBash "git-script" ''
            set -eo pipefail
            cd -- ''${GIT_PREFIX:-.}
            ${text}
          '';
        in
        "! ${script}";
    in
    {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "${firstName} ${lastName}";
      userEmail = if isDarwin then workEmail else personalEmail;
      aliases = {
        A = "add -A";
        pu = "pull";
        pur = "pull --rebase";
        cam = "commit -am";
        ca = "commit -a";
        cm = "commit -m";
        ci = "commit";
        co = "checkout";
        cod = gs ''git co $(git default) "$@"'';
        st = "status";
        br = gs ''
          esc=$'\e'
          reset=$esc[0m
          red=$esc[31m
          yellow=$esc[33m
          green=$esc[32m
          git -c color.ui=always branch -vv "$@" | ${pkgs.gnused}/bin/sed -E \
            -e "s/: (gone)]/: $red\1$reset]/" \
            -e "s/[:,] (ahead [0-9]*)([],])/: $green\1$reset\2/g" \
            -e "s/[:,] (behind [0-9]*)([],])/: $yellow\1$reset\2/g"
          git --no-pager stash list
        '';
        brf = gs "git f --quiet && git br";
        f = "fetch --all";
        hide = "update-index --skip-worktree";
        unhide = "update-index --no-skip-worktree";
        hidden = "! git ls-files -v | grep '^S' | cut -c3-";
        branch-name = "!git rev-parse --abbrev-ref HEAD";
        default = gs "git symbolic-ref refs/remotes/origin/HEAD | sed s@refs/remotes/origin/@@";
        # Delete the remote version of the current branch
        unpublish = "!git push origin :$(git branch-name)";
        # Push current branch
        put = gs ''git push --set-upstream origin $(git branch-name) "$@"'';
        # Pull without merging
        get = "!git pull origin $(git branch-name) --ff-only";
        # update a branch without checkout
        gd = gs "git fetch origin $(git default):$(git default)";
        # Pull Master without switching branches
        got =
          "!f() { CURRENT_BRANCH=$(git branch-name) && git checkout $1 && git pull origin $1 --ff-only && git checkout $CURRENT_BRANCH;  }; f";
        gone = gs ''git branch -vv | ${pkgs.gnused}/bin/sed -En "/: gone]/s/^..([^[:space:]]*)\s.*/\1/p"'';
        # Recreate your local branch based on the remote branch
        recreate = ''
          !f() { [[ -n $@ ]] && git checkout master && git branch -D "$@" && git pull origin "$@":"$@" && git checkout "$@"; }; f'';
        reset-submodule = "!git submodule update --init";
        s = gs "git br && git -c color.status=always status | grep -E --color=never '^\\s\\S|:$' || true";
        sl = "!git --no-pager log -n 15 --oneline --decorate";
        sla = "log --oneline --decorate --graph --all";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        shake = "remote prune origin";
      };
      extraConfig = {
        checkout.defaultRemote = "origin";
        color.ui = true;
        fetch.prune = true;
        init.defaultBranch = "main";
        pull.ff = "only";
        push.default = "simple";
        rebase.instructionFormat = "<%ae >%s";
        core = {
          editor = if isDarwin then "code --wait" else "nano";
          pager = "delta --dark";
          autocrlf = "input";
          hooksPath = "/dev/null";
        };
        delta = {
          navigate = true;
          line-numbers = true;
          side-by-side = true;
          line-numbers-left-format = "";
          line-numbers-right-format = "│ ";
        };
      };
      ${attrIf (!isNixOS) "signing"} = {
        key = "03C0CBEA6EAB9258";
        gpgPath = "gpg";
        signByDefault = true;
      };
    };

  programs.tmux = {
    enable = true;
    tmuxp.enable = false;
    historyLimit = 500000;
    shortcut = "s";
    extraConfig = ''
      set -g base-index 1
      set -g pane-base-index 1

      set -g status-keys vi
      setw -g mode-keys vi
      setw -g mouse on
      setw -g monitor-activity on

      # Moving between windows.
      unbind [
      unbind ]
      bind -r [ select-window -t :-
      bind -r ] select-window -t :+

      # Pane resizing.
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Maximize and restore a pane.
      unbind Up
      bind Up new-window -d -n tmp \; swap-pane -s tmp.1 \; select-window -t tmp
      unbind Down
      bind Down last-window \; swap-pane -s tmp.1 \; kill-window -t tmp

      # Log output to a text file on demand.
      bind P pipe-pane -o "cat >>~/#W.log" \; display "Toggled logging to ~/#W.log"

      # -- display -------------------------------------------------------------------
      # tabs
      set -g window-status-current-format "#[fg=black]#[bg=red] #I #[bg=brightblack]#[fg=brightwhite] #W#[fg=brightblack]#[bg=black]"
      set -g window-status-format "#[fg=black]#[bg=yellow] #I #[bg=brightblack]#[fg=brightwhite] #W#[fg=brightblack]#[bg=black]"

      # status bar
      set-option -g status-position bottom
      set-option -g status-justify left
      set -g status-fg colour1
      set -g status-bg colour0
      set -g status-left ' '
      set -g status-right '#(date +"%_I:%M")'
      set-option -g set-titles on
      #256 colors
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",xterm-256color:Tc"
      #Don't auto remane windows
      set-option -g allow-rename off
      # Source config
      unbind r
      bind r source-file ~/.tmux.conf \; display "Finished sourcing ~/.tmux.conf ."

      # Use Alt-arrow keys without prefix key to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Shift arrow to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # allow fn+left/right
      bind-key -n Home send Escape "OH"
      bind-key -n End send Escape "OF"

      setw -g monitor-activity off
      setw -g monitor-activity on
      set-option -g bell-action none
    '';
  };

  # fix vscode
  imports =
    if isNixOS then [
      "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/c54b714db58ad05d064f394d6603751ee6bd04f6"}/modules/vscode-server/home.nix"
    ] else [ ];

  ${attrIf isNixOS "services"}.vscode-server.enable = isNixOS;
}
