package main

import (
	"encoding/json"
	"fmt"
)

type Req struct {
	Cap *float64 `json:"cap"`
}

func main() {
	var r Req
	err := json.Unmarshal([]byte(`{"cap": ""}`), &r)
	fmt.Printf("empty string error: %v\n", err)
}
