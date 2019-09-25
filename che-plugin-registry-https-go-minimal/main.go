package main

import (
    "log"
	"net/http"
	"os"
	"strings"
)

func main() {

	path := "/" // path on web server
	directory := "html" // path in container relative to this app
	http.Handle("/", http.StripPrefix(strings.TrimRight(path, "/"), http.FileServer(http.Dir(directory))))

    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    log.Println("** Service Started on Port " + port + " **")

    // Use ListenAndServeTLS() instead of ListenAndServe() which accepts two extra parameters. 
    // We need to specify both the certificate file and the key file (which we've named 
    // https-server.crt and https-server.key).
    err := http.ListenAndServeTLS(":"+port, "https-server.crt", "https-server.key", nil);
    if err != nil {
        log.Fatal(err)
    }
}
