package handlers

import (
	"fmt"
	"regexp"
)

const contractTemplateMaxLength = 20000

var contractTemplateTokenRegex = regexp.MustCompile(`\[([a-z_]+)\]`)

var allowedContractTemplateTokens = map[string]struct{}{
	"provider_name":             {},
	"provider_business_name":    {},
	"provider_email":            {},
	"current_date":              {},
	"event_date":                {},
	"event_start_time":          {},
	"event_end_time":            {},
	"event_time_range":          {},
	"event_service_type":        {},
	"event_num_people":          {},
	"event_location":            {},
	"event_city":                {},
	"event_total_amount":        {},
	"event_deposit_percent":     {},
	"event_refund_percent":      {},
	"event_cancellation_days":   {},
	"client_name":               {},
	"client_phone":              {},
	"client_email":              {},
	"client_address":            {},
	"client_city":               {},
	"contract_city":             {},
}

func validateContractTemplate(template string) error {
	if len(template) > contractTemplateMaxLength {
		return ValidationError{Field: "contract_template", Message: fmt.Sprintf("must be %d characters or fewer", contractTemplateMaxLength)}
	}

	matches := contractTemplateTokenRegex.FindAllStringSubmatch(template, -1)
	for _, match := range matches {
		token := match[1]
		if _, ok := allowedContractTemplateTokens[token]; !ok {
			return ValidationError{Field: "contract_template", Message: fmt.Sprintf("contains unsupported token [%s]", token)}
		}
	}

	return nil
}
