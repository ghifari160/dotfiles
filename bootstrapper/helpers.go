package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/ghifari160/dotfiles/bootstrapper/arg"
	"github.com/mattn/go-isatty"
)

const (
	TTYBlue  = "\033[34m"
	TTYRed   = "\033[31m"
	TTYReset = "\033[0m"
)

var pattern = regexp.MustCompile(`(?:\033\[[0-9]{1,2}m)`)
var skip = regexp.MustCompile(`(?:##|~\$)(?:.*)$`)

func Log(a ...any) {
	Printf("%s%s%s\n", TTYBlue, fmt.Sprint(a...), TTYReset)
}

func Warn(a ...any) {
	Printf("%s%s%s\n", TTYRed, fmt.Sprint(a...), TTYReset)
}

func Abort(a ...any) {
	Printf("%s%s%s\n", TTYRed, fmt.Sprint(a...), TTYReset)
	os.Exit(1)
}

func Printf(format string, a ...any) {
	s := nonTTYClean(fmt.Sprintf(format, a...))

	fmt.Print(s)
}

func nonTTYClean(s string) string {
	if isatty.IsTerminal(os.Stdout.Fd()) || isatty.IsCygwinTerminal(os.Stdout.Fd()) {
		return s
	}

	return CleanString(s)
}

func CleanString(s string) string {
	return pattern.ReplaceAllString(s, "")
}

func SanitizeToken(s string) string {
	token := strings.Split(s, "_")

	var replace strings.Builder
	for range token[len(token)-1] {
		replace.WriteString("*")
	}
	token[len(token)-1] = replace.String()

	return strings.Join(token, "_")
}

func ValidateArgs() {
	if args.Username == "" {
		Abort("USERNAME required")
	}

	if args.Machine == "" {
		Abort("MACHINE required")
	}

	if args.Token == "" {
		Abort("TOKEN required")
	}

	Log("Bootstrapping with:")
	Log("Askpass:       ", args.SudoAskpass)
	Log("Username:      ", args.Username)
	Log("Machine:       ", args.Machine)
	Log("Token:         ", SanitizeToken(args.Token))
	Log("Bootstrap Dir: ", args.BootstrapDir)
}

func ExecuteScript(script string) error {
	FindBash()

	cmdArgs := make([]string, 0)

	cmdArgs = append(cmdArgs, "-c")
	cmdArgs = append(cmdArgs, cmdBuilder(args, script))

	cmd := exec.Command(Bash, cmdArgs...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	Log("Executing ", script)

	err := cmd.Run()
	if err != nil {
		Warn("Failed with ", script)
		return err
	}

	Log("Done with ", script)

	return nil
}

func FindBash() {
	if Bash != "" {
		return
	}

	path, err := exec.LookPath("bash")
	if err != nil {
		Abort("Cannot find bash: ", err)
	}

	Bash = path
}

func ReadDir(bootstrapDir string) (scripts []string, err error) {
	scripts = make([]string, 0)

	tree, err := os.ReadDir(bootstrapDir)
	if err != nil {
		return
	}

	for _, entry := range tree {
		info, _ := entry.Info()
		path := filepath.Join(bootstrapDir, entry.Name())

		if info.IsDir() {
			Log("Skipping ", path)
			continue
		}

		if skip.MatchString(path) {
			Log("Skipping ", path)
			continue
		}

		if info.Mode()&0100 == 0 {
			Log("Skipping ", path)
			continue
		}

		scripts = append(scripts, path)
	}

	sort.Strings(scripts)

	return
}

func cmdBuilder(args arg.Args, script string) string {
	cmd := make([]string, 0)

	if args.SudoAskpass != "" {
		kvBuilder(&cmd, "SUDO_ASKPASS", args.SudoAskpass)
	}

	kvBuilder(&cmd, "USERNAME", args.Username)
	kvBuilder(&cmd, "MACHINE", args.Machine)
	kvBuilder(&cmd, "TOKEN", args.Token)

	cmd = append(cmd, script)

	return strings.Join(cmd, " ")
}

func kvBuilder(cmd *[]string, key, val string) {
	*cmd = append(*cmd, fmt.Sprintf("%s=\"%s\"", key, val))
}
