package main

import (
	"errors"
	"os"

	"github.com/ghifari160/dotfiles/bootstrapper/arg"
)

var args arg.Args

var Bash string

func main() {
	args.MustParse(os.Args)

	ValidateArgs()

	_, err := os.Stat(args.BootstrapDir)
	if errors.Is(err, os.ErrNotExist) {
		Abort("Missing bootstrap directory!")
	} else if err != nil {
		Abort("Cannot read bootstrap directory: ", err)
	}

	scripts, err := ReadDir(args.BootstrapDir)
	if err != nil {
		Abort("Cannot read bootstrap directory: ", err)
	}

	Log("Executing ", len(scripts), " bootstrap scripts")

	for _, script := range scripts {
		err := ExecuteScript(script)
		if err != nil {
			os.Exit(1)
		}
	}

	Log("Done with bootstrapper")
}
