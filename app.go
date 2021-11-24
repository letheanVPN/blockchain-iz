package main

import (
	"context"
	"embed"
	"errors"
	"fmt"
	"github.com/leaanthony/debme"
	"os"
	"os/exec"
	"path/filepath"
	goruntime "runtime"

	"github.com/wailsapp/wails/v2/pkg/runtime"
)

//go:embed build/cli/*
var lthn embed.FS

var spawnCmd *exec.Cmd

// App struct
type App struct {
	ctx context.Context
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{}
}

// startup is called at application startup
func (b *App) startup(ctx context.Context) {
	// Perform your setup here
	b.ctx = ctx
	homeDir, _ := os.UserHomeDir()
	exeName := ""
	fmt.Println(goruntime.GOOS)
	if goruntime.GOOS == "windows" {
		exeName = "lthn.exe"
	} else {
		exeName = "lthn"
	}

	exePath := filepath.Join(homeDir, "Lethean", exeName)

	if _, err := os.Stat(exePath); err == nil {

	} else if errors.Is(err, os.ErrNotExist) {
		root, _ := debme.FS(lthn, "build/cli")
		err := root.CopyFile(exeName, exePath, 0777)
		if err != nil {
			return
		}
		//_ = os.WriteFile(exePath, data, 0777)
	}

	spawnCmd = exec.Command(exePath, "backend", "start")
	_, err := spawnCmd.Output()
	if err != nil {
		panic(err)
	}

}

// domReady is called after the front-end dom has been loaded
func (b *App) domReady(ctx context.Context) {
	// Add your action here
}

// shutdown is called at application termination
func (b *App) shutdown(ctx context.Context) {
	// Perform your teardown here
	err := spawnCmd.Process.Kill()
	if err != nil {
		return
	}
}

// Greet returns a greeting for the given name
func (b *App) Greet(name string) string {
	return fmt.Sprintf("Hello %s, It's show time!", name)
}

// Shows a Dialog
func (b *App) ShowDialog() {
	_, err := runtime.MessageDialog(b.ctx, runtime.MessageDialogOptions{
		Type:    runtime.InfoDialog,
		Title:   "Native Dialog from Go",
		Message: "This is a Native Dialog send from Go.",
	})

	if err != nil {
		panic(err)
	}
}
