package main

import (
	"encoding/json"
	"fmt"
	"github.com/google/uuid"
)

type Req struct {
	ID uuid.UUID `json:"id"`
}

func main() {
	var r Req
	err := json.Unmarshal([]byte(`{"id": null}`), &r)
	fmt.Printf("null error: %v, id: %v\n", err, r.ID)

	var r2 Req
	err = json.Unmarshal([]byte(`{"id": ""}`), &r2)
	fmt.Printf("empty string error: %v, id: %v\n", err, r2.ID)
}
