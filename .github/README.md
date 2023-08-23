# GHIFARI160's dotfiles

[GHIFARI160](https://github.com/ghifari160)'s dotfiles.

## License

MIT License.

[Bootstrapper](../bootstrapper) includes [third party libraries](../bootstrapper/THIRDPARTY).

## Cheatsheet

- _(macOS)_ Assign "Full Disk Access" and "App Management" permissions to Terminal
- _(macOS)_ Sign in to the App Store
- _(non-Ubuntu Linux)_ Apply software updates
- _(non-Ubuntu Linux)_ Download and install `curl`, `git`, and Homebrew dependencies
- Create a temporary
  [GitHub Personal Access Token](https://github.com/settings/personal-access-tokens/new) with
  account permissions:
  - GPG keys: Read-only
  - Git SSH keys: Read and write
- Run the setup script

``` shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Ghifari160/dotfiles/yadm/setup.sh)"
```
