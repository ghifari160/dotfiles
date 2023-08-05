package arg

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
)

var (
	ErrHelp = errors.New("print help message")
)

type Args struct {
	SudoAskpass  string
	Username     string
	Machine      string
	Token        string
	BootstrapDir string
}

func (Args) PrintHelp() {
	fmt.Printf("Usage: %s %s %s %s %s bootstrapper",
		"[SUDO_ASKPASS=/path/to/askpass]",
		"USERNAME=username",
		"MACHINE=machine",
		"TOKEN=github_token",
		"[BOOTSTRAP_DIR=/path/to/bootstrap.d]")
	fmt.Println("Options:")
	fmt.Println("  SUDO_ASKPASS     path to askpass program")
	fmt.Println("  USERNAME         username for SSH key generation")
	fmt.Println("  MACHINE          machine name for SSH key generation")
	fmt.Println("  TOKEN            GitHub access token")
	fmt.Println("  BOOTSTRAP_DIR    path to bootstrap directory (defaults to `$HOME/.config/yadm/bootstrap.d`)")
	fmt.Println()
}

func (ar *Args) MustParse(args []string) {
	err := ar.Parse(args)
	if err != nil {
		ar.PrintHelp()
		os.Exit(0)
	}
}

func (ar *Args) Parse(args []string) error {
	if len(args) < 2 {
		args = []string{}
	} else {
		args = args[1:]
	}

	err := ar.parse(args)
	if errors.Is(err, ErrHelp) {
		ar.PrintHelp()
		os.Exit(0)
	}

	return err
}

func (ar *Args) parse(args []string) error {
	for _, a := range args {
		if a == "--help" || a == "-h" {
			return ErrHelp
		}
	}

	ar.SudoAskpass = os.Getenv("SUDO_ASKPASS")
	ar.Username = os.Getenv("USERNAME")
	ar.Machine = os.Getenv("MACHINE")
	ar.Token = os.Getenv("TOKEN")
	ar.BootstrapDir = os.Getenv("BOOTSTRAP_DIR")

	if ar.BootstrapDir == "" {
		home, err := os.UserHomeDir()
		if err != nil {
			return err
		}

		ar.BootstrapDir = filepath.Join(home, ".config", "yadm", "bootstrap.d")
	}

	return nil
}
