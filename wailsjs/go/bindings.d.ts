interface go {
  "main": {
    "App": {
		ShowDialog():Promise<void>
    },
  }

}

declare global {
	interface Window {
		go: go;
	}
}
