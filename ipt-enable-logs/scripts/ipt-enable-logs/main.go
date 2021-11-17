package main

import (
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
)

func main() {
	cmd := exec.Command("iptables-save")
	outputBytes, err := cmd.Output()
	if err != nil {
		_ = fmt.Errorf("Failed to run iptables-save: %v", err)
		os.Exit(1)
	}

	str := string(outputBytes)
	lines := strings.Split(str, "\n")
	re := regexp.MustCompile(`-A UBIOS_([A-Z_]+) .* --comment (\d+) -j ([A-Z]+)`)

	for i, line := range lines {
		if i != 0 {
			fmt.Println()
		}
		if !strings.HasSuffix(line, "-j LOG") {
			fmt.Print(line)
			continue
		}

		matches := re.FindSubmatch([]byte(lines[i+1]))
		commentNr, err := strconv.Atoi(string(matches[2]))
		if err != nil {
			commentNr = 0
		}
		actionName := getActionName(string(matches[3]))
		ruleName := getRuleName(string(matches[1]), commentNr)
		fmt.Printf(`%s --log-prefix "[%s-%s] "`, line, actionName, ruleName)
	}
}

func getActionName(action string) string {
	action = strings.Replace(action, "RETURN", "A", 1)
	action = strings.Replace(action, "REJECT", "R", 1)
	action = strings.Replace(action, "DROP", "D", 1)
	action = strings.Replace(action, "MASQUERADE", "M", 1)

	return action
}

func getRuleName(rule string, commentNr int) string {
	rule = strings.Replace(rule, "PREROUTING", "PRER", 1)
	rule = strings.Replace(rule, "POSTROUTING", "POSTR", 1)
	rule = strings.Replace(rule, "HOOK", "HK", 1)
	rule = strings.Replace(rule, "USER", "U", 1)
	if commentNr != 0 {
		rule = fmt.Sprintf("%s-%d", rule, commentNr)
	}
	return rule
}
