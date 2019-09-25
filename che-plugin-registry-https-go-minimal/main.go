/* original source modified from 
    https://golangcode.com/basic-https-server-with-certificate/ and 
    https://golangcode.com/basic-docker-setup/ and  
    https://dev.to/hauxe/golang-http-serve-static-files-correctly-2oj2
*/ 

package main

import (
    "log"
	"net/http"
	"os"
    "strings"
)

// FileSystem custom file system handler
type FileSystem struct {
    fs http.FileSystem
}

// FileExists reports whether the named file exists as a boolean
func FileExists(name string) bool {
    if fi, err := os.Stat(name); err == nil {
        if fi.Mode().IsRegular() {
            return true
        }
    }
    return false
}

// DirExists reports whether the dir exists as a boolean
func DirExists(name string) bool {
    if fi, err := os.Stat(name); err == nil {
        if fi.Mode().IsDir() {
            return true
        }
    }
    return false
}

// TODO make this serve index files if they're found (not working yet)
func (fs FileSystem) Open(path string) (http.File, error) {
    if path != "/" && DirExists(path) {
        indexfiles := []string{"index.json", "README.md", "meta.yaml"}
        for _, indexfile := range indexfiles {
            log.Println("** Check for " + indexfile + " in " + path)
            if FileExists(strings.TrimSuffix(path, "/") + "/" + indexfile) {
                path = strings.TrimSuffix(path, "/") + "/" + indexfile
                log.Println("** Found " + path)
                break
            }
        }
    }

    f, err := fs.fs.Open(path)
	if err != nil {
		return nil, err
	}

    if DirExists(path) || FileExists(path) {
		index := path
		if _, err := fs.fs.Open(index); err != nil {
			return nil, err
		}
    }
    
    return f, nil
}

func main() {

	path := "/" // path on web server
	directory := "html" // path in container relative to this app

    // simple dir server
    http.Handle("/", http.StripPrefix(strings.TrimRight(path, "/"), http.FileServer(http.Dir(directory))))

    // TODO: more complex dir server: show README and index files (not working)
    // fileServer := http.FileServer(FileSystem{http.Dir(directory)})
    // http.Handle("/", http.StripPrefix(strings.TrimRight(path, "/"), fileServer))

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
