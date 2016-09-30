package main

import (
	"log"
	"net/http"
)

// Version var
var Version string

func main() {
	log.Println(http.ListenAndServe(":8080", nil))
}
