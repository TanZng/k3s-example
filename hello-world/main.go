package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.Error(w, "404 not found.", http.StatusNotFound)
		return
	}

	if r.Method != "GET" {
		http.Error(w, "Method is not supported.", http.StatusNotFound)
		return
	}

	name, err := os.Hostname()
	if err != nil {
		panic(err)
	}

	envvalue := os.Getenv("FOO")

	fmt.Fprintf(w, "<h1> Hello world! 👋🏼🗺</h1>")
	fmt.Fprintf(w, "<h3>This is the hostname: %s</h3>", name)
	fmt.Fprintf(w, "<h3>This is the value of FOO env var: %s</h3>", envvalue)
}

func main() {
	http.HandleFunc("/", helloHandler) // Update this line of code

	fmt.Printf("Starting server at port 8080... 🚀\n")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
