# kit

A git wrapper for Bash and ZSH. `kit clone` automatically calculates the directory to clone the repo to whereas
`kit push` calculates the remote to push to.

## Install

```sh
wget https://raw.githubusercontent.com/kfkonrad/kit-bash-pkg/master/kit.sh -O ~/kit.sh
OR
curl https://raw.githubusercontent.com/kfkonrad/kit-bash-pkg/master/kit.sh -o ~/kit.sh
```

To load `kit.sh` automatically run either of the following commands depending on your shell:

```sh
echo source ~/kit.sh >> ~/.bashrc
OR
echo source ~/kit.sh >> ~/.zshrc
```

By the way: If you prefer using Fish there's a version of `kit` with the exact same feature-set for that, too.
See [kit-fish-pkg](https://github.com/kfkonrad/kit-fish-pkg).

## Usage

### `kit clone`

```sh
kit clone ssh://git@github.com:fish-shell/fish-shell.git
OR
kit clone git@github.com:fish-shell/fish-shell.git
OR
kit clone https://github.com/fish-shell/fish-shell.git
```

`kit clone` supports the same parameters as `git clone` except that you must not give the optional directory-parameter - `kit clone` will generate that for you.

`kit clone <URL>` will clone the repo to `~/workspace/<domain>/<uri-path>` (e.g. `~/workspace/github/fish-shell/fish-shell`) so that the domain (without TLD) and path in the URL are translated to a path under `~/workspace`. Non-existing intermediary directories will be auto-generated as well. Both https and ssh/git are supported.

### `kit push`

```sh
kit push
```

`kit push` wraps arount git push and sets the `-u`-parameter automatically.
The branch name for `-u` is always the name of the current local branch.
If only one remote is configured, that value will always be used.
If multiple remotes exist, `origin` will be used (regardless of whether a remote with that name exists) unless the user overrides that by setting `$kit_default_remote`.

### `kit help`

```sh
kit help
kit -h
kit --help
```

Shows a rudimentary help.

### `kit version`

```sh
kit version
kit -v
kit --version
```

Displays current version of `kit`.

## Advanced usage

### `kit clone`

- You can change the base directory from `~/workspace` by setting `$kit_base_dir`
- If `$kit_cd_after_clone` is set (to any value), `kit clone` will cd into the newly cloned repo
- You can customize the behavior for generating the `<domain>`-part by providing a variable with an sed filter expression
- You can also customize the behavior for generating the `<uri-path>`-part by providing a variable with an sed filter expression
- All filters can be used independently
- A domain-specific filter takes precedence over a custom filter

#### Domain filters

- If you want to change the behavior for all domains, set a variable `$kit_domain_filter`
- To change the behavior for a specific domain, set a variable `$kit_domain_filter_<domain>`. Make sure to replace all dots and dashes with underscores in the variable name
- The domain being filtered is always the FQDN of the git server, e.g. `github.com` for both `git@github.com:fish-shell/fish-shell.git` and `https://github.com/fish-shell/fish-shell.git`
- I.e. any schema and URL path is stripped from the input before a filter is applied

#### Path filters

- By default no path filter is applied
- To change the behavior for all domains set `$kit_path_filter`
- To change the behavior for a specific domain, set a variable `$kit_path_filter_<domain>` with the same naming conventing as above
- Any path filter should assume no leading colon or slash is present

#### Examples for filters

- Using only domain filters
  - Not filtering any domain name at all
    - `set kit_domain_filter ""`
    - `github.com/fish-shell/fish/shell` will be cloned into the path `~/workspace/github.com/fish-shell/fish-shell`
    - `gitlab.com/gitlab-org/gitlab` will be cloned into the path `~/workspace/gitlab.com/gitlab-org/gitlab`
  - Remove the dot in `github.com`
    - `set kit_domain_filter_github_com 's/\.//'`
    - `github.com/fish-shell/fish/shell` will be cloned into the path `~/workspace/githubcom/fish-shell/fish-shell`
    - `gitlab.com/gitlab-org/gitlab` will be cloned into the path `~/workspace/gitlab/gitlab-org/gitlab`
  - With both of these filters set
    - `github.com/fish-shell/fish/shell` will be cloned into the path `~/workspace/githubcom/fish-shell/fish-shell`
    - `gitlab.com/gitlab-org/gitlab` will be cloned into the path `~/workspace/gitlab.com/gitlab-org/gitlab`
- Only using path filters
  - Convet all alpha characters to lowercase
    - `set kit_path_filter 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
    - `https://github.com/google/CFU-Playground.git` will be cloned into the path `~/workspace/github/google/cfu-playground`
  - shorten a long user/group name for `github.com`
    - `set kit_path_filter_github_com 's/^kubernetes/k8s/'`
    - `https://github.com/kubernetes/kubernetes.git` will be cloned into the path `~/workspace/github/k8s/kubernetes`
- Using both domain and path filters
  - Shortening github.com to gh and replacing cloud with just-a-computer in the path
    - `set kit_path_filter_github_com 's/cloud/just-a-computer/'`
    - `set kit_domain_filter_github_com 's/github\.com/gh/'`
    - `git@github.com:google/go-cloud.git` will be cloned into the path `~/workspace/gh/google/go-just-a-computer`

## License

[MIT][mit] © [Kevin Konrad][author] et [al][contributors]

[mit]:            https://opensource.org/licenses/MIT
[author]:         https://github.com/kfkonrad
[contributors]:   https://github.com/kfkonrad/kit-bash-pkg/graphs/contributors
