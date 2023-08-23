# Bootstrapper

Iterates through `BOOTSTRAP_DIR` and execute all bootstrapping scripts in order.
Bootstrapper ignores non-executable scripts (i.e. missing `x` permission bits),
[YADM](https://yadm.io/) [alternate files](https://yadm.io/docs/alternates) (`file##template`), and
editor backups (`file$~`).

This bootstrapper exists because there are some issues with bootstrapping using Bash scripts in
macOS.
