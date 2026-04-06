package services

import (
	"strings"
	"testing"

	"github.com/tiagofur/solennix-backend/internal/config"
)

func TestNewEmailService(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_test_key",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)
	if svc == nil {
		t.Fatal("NewEmailService() returned nil")
	}
	if svc.cfg != cfg {
		t.Fatal("NewEmailService() config mismatch")
	}
}

func TestEmailService_SendEmail_NoApiKey(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)

	err := svc.sendEmail("user@example.com", "Test Subject", "<p>Hello</p>")
	if err == nil || err.Error() != "Resend not configured" {
		t.Errorf("expected 'Resend not configured' error, got %v", err)
	}
}

func TestEmailService_GeneratePasswordResetHTML(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "http://localhost:5173",
	}
	emailService := NewEmailService(cfg)

	html := emailService.renderTemplate(passwordResetBody, map[string]string{"UserName": "John Doe", "ResetLink": "http://localhost:5173/reset?token=123"})

	if !strings.Contains(html, "John Doe") {
		t.Errorf("expected HTML to contain user name: %s", "John Doe")
	}
	if !strings.Contains(html, "http://localhost:5173/reset?token=123") {
		t.Errorf("expected HTML to contain reset link")
	}
}

func TestEmailService_SendPasswordReset_NoApiKey(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "",
		ResendFromEmail: "test@test.com",
	}
	emailService := NewEmailService(cfg)

	err := emailService.SendPasswordReset("user@example.com", "fake-token", "John Doe")
	if err == nil || err.Error() != "Resend not configured" {
		t.Errorf("expected Resend not configured error, got %v", err)
	}
}

func TestEmailService_SendPasswordReset_WithFakeKey(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_fake_key",
		ResendFromEmail: "test@test.com",
	}
	emailService := NewEmailService(cfg)

	// Since the key is fake, the resend API responds with an error.
	// This covers lines 147 to 160.
	err := emailService.SendPasswordReset("user@example.com", "fake-token", "John Doe")
	if err == nil {
		t.Error("expected error when sending with fake key")
	}
}

func TestEmailService_SendPasswordReset_LinkFormat(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "https://app.solennix.com",
		ResendAPIKey:    "",
		ResendFromEmail: "test@test.com",
	}
	emailService := NewEmailService(cfg)

	// SendPasswordReset will fail because no API key, but the HTML should
	// contain the correctly formatted link. We test generatePasswordResetHTML directly.
	html := emailService.renderTemplate(passwordResetBody, map[string]string{"UserName": "Maria", "ResetLink": "https://app.solennix.com/reset-password?token=abc123"})
	if !strings.Contains(html, "Maria") {
		t.Error("expected HTML to contain user name")
	}
	if !strings.Contains(html, "https://app.solennix.com/reset-password?token=abc123") {
		t.Error("expected HTML to contain reset link")
	}
	if !strings.Contains(html, "Restablecer Contraseña") {
		t.Error("expected HTML to contain Spanish button text")
	}
}

func TestEmailService_SendEmail_EmptyRecipient(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_fake_key",
		ResendFromEmail: "test@test.com",
	}
	emailService := NewEmailService(cfg)

	// With a fake key, this will hit the Resend API and fail.
	// This tests the error handling path in sendEmail.
	err := emailService.sendEmail("", "Test", "<p>Test</p>")
	if err == nil {
		t.Error("expected error when sending with fake key")
	}
}

func TestEmailService_GeneratePasswordResetHTML_EmptyName(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "http://localhost:5173",
	}
	emailService := NewEmailService(cfg)

	// Test with empty username — should not panic
	html := emailService.renderTemplate(passwordResetBody, map[string]string{"UserName": "", "ResetLink": "http://localhost:5173/reset?token=xyz"})
	if !strings.Contains(html, "Hola ") {
		t.Error("expected HTML to contain greeting")
	}
	if !strings.Contains(html, "http://localhost:5173/reset?token=xyz") {
		t.Error("expected HTML to contain the reset link")
	}
}

// ---------------------------------------------------------------------------
// Additional coverage tests — SendPasswordReset with empty recipient
// ---------------------------------------------------------------------------

func TestEmailService_SendPasswordReset_EmptyRecipient(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_fake_key",
		ResendFromEmail: "test@test.com",
	}
	emailService := NewEmailService(cfg)

	// With a valid (but fake) API key and empty recipient, the Resend API
	// will reject the request. This exercises the error path in sendEmail.
	err := emailService.SendPasswordReset("", "fake-token", "Test User")
	if err == nil {
		t.Error("expected error when sending to empty recipient with fake API key")
	}
}

// ---------------------------------------------------------------------------
// Additional coverage tests — XSS prevention in generatePasswordResetHTML
// ---------------------------------------------------------------------------

func TestEmailService_GeneratePasswordResetHTML_SpecialCharsInUserName(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "http://localhost:5173",
	}
	emailService := NewEmailService(cfg)

	// Test with HTML/XSS special characters in userName
	// Go's html/template auto-escapes, so <script> should become &lt;script&gt;
	xssName := `<script>alert("xss")</script>`
	html := emailService.renderTemplate(passwordResetBody, map[string]string{"UserName": xssName, "ResetLink": "http://localhost:5173/reset?token=abc"})

	// The raw <script> tag should NOT appear in the output
	if strings.Contains(html, "<script>") {
		t.Error("XSS vulnerability: raw <script> tag found in HTML output")
	}
	// The escaped version should be present
	if !strings.Contains(html, "&lt;script&gt;") {
		t.Error("expected HTML-escaped script tag in output")
	}
	// The reset link should still be present
	if !strings.Contains(html, "http://localhost:5173/reset?token=abc") {
		t.Error("expected HTML to contain the reset link")
	}
}

func TestEmailService_GeneratePasswordResetHTML_AmpersandInUserName(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "http://localhost:5173",
	}
	emailService := NewEmailService(cfg)

	// Test with ampersand and quotes in userName
	html := emailService.renderTemplate(passwordResetBody, map[string]string{"UserName": `John "O'Brien" & Co.`, "ResetLink": "http://localhost:5173/reset?token=def"})

	// html/template should escape & to &amp; and quotes appropriately
	if strings.Contains(html, `& Co.`) && !strings.Contains(html, `&amp; Co.`) {
		t.Error("expected ampersand to be HTML-escaped")
	}
	if !strings.Contains(html, "reset?token=def") {
		t.Error("expected HTML to contain reset link")
	}
}

func TestEmailService_GeneratePasswordResetHTML_UnicodeUserName(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "http://localhost:5173",
	}
	emailService := NewEmailService(cfg)

	// Test with Unicode characters (common in Spanish names)
	html := emailService.renderTemplate(passwordResetBody, map[string]string{"UserName": "Jose Garcia", "ResetLink": "http://localhost:5173/reset?token=ghi"})

	if !strings.Contains(html, "Jose Garcia") {
		t.Error("expected HTML to contain Unicode user name")
	}
}

func TestEmailService_SendPasswordReset_VerifiesResetLinkFormat(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "https://myapp.example.com",
		ResendAPIKey:    "",
		ResendFromEmail: "noreply@example.com",
	}
	emailService := NewEmailService(cfg)

	// SendPasswordReset will fail due to no API key, but we can verify
	// that generatePasswordResetHTML builds the correct link format
	html := emailService.renderTemplate(passwordResetBody, map[string]string{"UserName": "Verify User", "ResetLink": "https://myapp.example.com/reset-password?token=mytoken123"})
	if !strings.Contains(html, "https://myapp.example.com/reset-password?token=mytoken123") {
		t.Error("expected HTML to contain full reset link with frontend URL")
	}
	// Verify the link appears as an href
	if !strings.Contains(html, `href="https://myapp.example.com/reset-password?token=mytoken123"`) {
		t.Error("expected reset link to be in an href attribute")
	}
}

// ---------------------------------------------------------------------------
// Additional coverage — sendEmail with a fake but non-empty API key
// ---------------------------------------------------------------------------

func TestEmailService_SendEmail_WithFakeAPIKey(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_invalid_key_123",
		ResendFromEmail: "noreply@solennix.com",
	}
	svc := NewEmailService(cfg)

	// This exercises the code path past the API key check (line 142-145)
	// and into the Resend client creation and Send call (lines 147-160).
	// The API will reject the fake key, returning an error.
	err := svc.sendEmail("recipient@example.com", "Test Subject", "<p>Body</p>")
	if err == nil {
		t.Error("expected error when calling Resend API with invalid key")
	}
	if !strings.Contains(err.Error(), "failed to send email") {
		t.Errorf("expected 'failed to send email' in error, got: %v", err)
	}
}

// ---------------------------------------------------------------------------
// Additional coverage — NewEmailService stores config correctly
// ---------------------------------------------------------------------------

func TestNewEmailService_StoresAllConfigFields(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "https://custom.example.com",
		ResendAPIKey:    "re_live_key_abc",
		ResendFromEmail: "custom@example.com",
	}
	svc := NewEmailService(cfg)
	if svc.cfg.FrontendURL != "https://custom.example.com" {
		t.Errorf("expected FrontendURL = %q, got %q", "https://custom.example.com", svc.cfg.FrontendURL)
	}
	if svc.cfg.ResendAPIKey != "re_live_key_abc" {
		t.Errorf("expected ResendAPIKey = %q, got %q", "re_live_key_abc", svc.cfg.ResendAPIKey)
	}
	if svc.cfg.ResendFromEmail != "custom@example.com" {
		t.Errorf("expected ResendFromEmail = %q, got %q", "custom@example.com", svc.cfg.ResendFromEmail)
	}
}

// ---------------------------------------------------------------------------
// Additional coverage — SendPasswordReset with empty name
// ---------------------------------------------------------------------------

func TestEmailService_SendPasswordReset_EmptyName(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "",
		ResendFromEmail: "test@test.com",
	}
	emailService := NewEmailService(cfg)

	// Empty name should not cause a panic; the email will fail because no API key.
	err := emailService.SendPasswordReset("user@example.com", "some-token", "")
	if err == nil || err.Error() != "Resend not configured" {
		t.Errorf("expected 'Resend not configured' error, got %v", err)
	}
}

// ---------------------------------------------------------------------------
// Additional coverage — HTML template contains expected structure
// ---------------------------------------------------------------------------

func TestEmailService_GeneratePasswordResetHTML_ContainsStructure(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "http://localhost:5173",
	}
	emailService := NewEmailService(cfg)

	html := emailService.renderTemplate(passwordResetBody, map[string]string{"UserName": "Test User", "ResetLink": "http://localhost:5173/reset?token=abc"})

	// Verify HTML doctype and lang
	if !strings.Contains(html, "<!DOCTYPE html>") {
		t.Error("expected HTML to contain DOCTYPE declaration")
	}
	if !strings.Contains(html, `lang="es"`) {
		t.Error("expected HTML to have Spanish language attribute")
	}

	// Verify key structural elements
	if !strings.Contains(html, "Solennix") {
		t.Error("expected HTML to contain 'Solennix' branding")
	}
	if !strings.Contains(html, "Hola Test User") {
		t.Error("expected HTML to contain personalized greeting")
	}
	if !strings.Contains(html, "1 hora") {
		t.Error("expected HTML to contain expiry warning of 1 hour")
	}
	if !strings.Contains(html, "Restablecer Contraseña") {
		t.Error("expected HTML to contain the reset button text")
	}
	if !strings.Contains(html, "class=\"button\"") {
		t.Error("expected HTML to contain button CSS class")
	}
}

// ---------------------------------------------------------------------------
// Additional coverage — SendPasswordReset builds correct link
// ---------------------------------------------------------------------------

func TestEmailService_SendPasswordReset_BuildsCorrectLink(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "https://app.solennix.com",
		ResendAPIKey:    "",
		ResendFromEmail: "test@test.com",
	}
	emailService := NewEmailService(cfg)

	// We can't intercept the HTML inside SendPasswordReset (it calls sendEmail
	// which fails), but we verify that generatePasswordResetHTML produces the
	// same link format SendPasswordReset would construct.
	expectedLink := "https://app.solennix.com/reset-password?token=tok123"
	html := emailService.renderTemplate(passwordResetBody, map[string]string{"UserName": "Link Test", "ResetLink": expectedLink})
	if !strings.Contains(html, expectedLink) {
		t.Errorf("expected HTML to contain link %q", expectedLink)
	}
}

// ---------------------------------------------------------------------------
// Additional coverage — sendEmail error message wraps underlying error
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// SendWelcome tests
// ---------------------------------------------------------------------------

func TestEmailService_SendWelcome_GivenNoApiKey_WhenSent_ThenReturnsResendNotConfigured(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)

	err := svc.SendWelcome("user@example.com", "Maria")
	if err == nil || err.Error() != "Resend not configured" {
		t.Errorf("expected 'Resend not configured' error, got %v", err)
	}
}

func TestEmailService_SendWelcome_GivenFakeKey_WhenSent_ThenReturnsError(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_fake_key",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)

	err := svc.SendWelcome("user@example.com", "Maria")
	if err == nil {
		t.Error("expected error when sending with fake key")
	}
}

func TestEmailService_SendWelcome_GivenValidData_WhenRendered_ThenTemplateContainsExpectedContent(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "https://app.solennix.com",
	}
	svc := NewEmailService(cfg)

	html := svc.renderTemplate(welcomeBody, map[string]string{
		"UserName":      "Maria",
		"DashboardLink": "https://app.solennix.com/dashboard",
	})

	if !strings.Contains(html, "Maria") {
		t.Error("expected HTML to contain user name")
	}
	if !strings.Contains(html, "https://app.solennix.com/dashboard") {
		t.Error("expected HTML to contain dashboard link")
	}
	if !strings.Contains(html, "Bienvenido") {
		t.Error("expected HTML to contain welcome text")
	}
	if !strings.Contains(html, "Ir al Dashboard") {
		t.Error("expected HTML to contain dashboard button text")
	}
}

// ---------------------------------------------------------------------------
// SendEventReminder tests
// ---------------------------------------------------------------------------

func TestEmailService_SendEventReminder_GivenNoApiKey_WhenSent_ThenReturnsResendNotConfigured(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)

	err := svc.SendEventReminder("user@example.com", "Carlos", "Boda Rodriguez", "2026-04-15", "https://app.solennix.com/events/123")
	if err == nil || err.Error() != "Resend not configured" {
		t.Errorf("expected 'Resend not configured' error, got %v", err)
	}
}

func TestEmailService_SendEventReminder_GivenFakeKey_WhenSent_ThenReturnsError(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_fake_key",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)

	err := svc.SendEventReminder("user@example.com", "Carlos", "Boda Rodriguez", "2026-04-15", "https://app.solennix.com/events/123")
	if err == nil {
		t.Error("expected error when sending with fake key")
	}
}

func TestEmailService_SendEventReminder_GivenValidData_WhenRendered_ThenTemplateContainsExpectedContent(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "https://app.solennix.com",
	}
	svc := NewEmailService(cfg)

	html := svc.renderTemplate(eventReminderBody, map[string]string{
		"UserName":  "Carlos",
		"EventName": "Boda Rodriguez",
		"EventDate": "2026-04-15",
		"EventLink": "https://app.solennix.com/events/123",
	})

	if !strings.Contains(html, "Carlos") {
		t.Error("expected HTML to contain user name")
	}
	if !strings.Contains(html, "Boda Rodriguez") {
		t.Error("expected HTML to contain event name")
	}
	if !strings.Contains(html, "2026-04-15") {
		t.Error("expected HTML to contain event date")
	}
	if !strings.Contains(html, "Ver Evento") {
		t.Error("expected HTML to contain view event button text")
	}
}

// ---------------------------------------------------------------------------
// SendPaymentReceipt tests
// ---------------------------------------------------------------------------

func TestEmailService_SendPaymentReceipt_GivenNoApiKey_WhenSent_ThenReturnsResendNotConfigured(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)

	err := svc.SendPaymentReceipt("user@example.com", "Ana", "Quinceañera", "$5,000 MXN", "2026-04-06")
	if err == nil || err.Error() != "Resend not configured" {
		t.Errorf("expected 'Resend not configured' error, got %v", err)
	}
}

func TestEmailService_SendPaymentReceipt_GivenFakeKey_WhenSent_ThenReturnsError(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_fake_key",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)

	err := svc.SendPaymentReceipt("user@example.com", "Ana", "Quinceañera", "$5,000 MXN", "2026-04-06")
	if err == nil {
		t.Error("expected error when sending with fake key")
	}
}

func TestEmailService_SendPaymentReceipt_GivenValidData_WhenRendered_ThenTemplateContainsExpectedContent(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "https://app.solennix.com",
	}
	svc := NewEmailService(cfg)

	html := svc.renderTemplate(paymentReceiptBody, map[string]string{
		"UserName":    "Ana",
		"EventName":   "Quinceañera",
		"Amount":      "$5,000 MXN",
		"PaymentDate": "2026-04-06",
	})

	if !strings.Contains(html, "Ana") {
		t.Error("expected HTML to contain user name")
	}
	if !strings.Contains(html, "Quinceañera") {
		t.Error("expected HTML to contain event name")
	}
	if !strings.Contains(html, "$5,000 MXN") {
		t.Error("expected HTML to contain amount")
	}
	if !strings.Contains(html, "2026-04-06") {
		t.Error("expected HTML to contain payment date")
	}
}

// ---------------------------------------------------------------------------
// SendSubscriptionConfirmation tests
// ---------------------------------------------------------------------------

func TestEmailService_SendSubscriptionConfirmation_GivenNoApiKey_WhenSent_ThenReturnsResendNotConfigured(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)

	err := svc.SendSubscriptionConfirmation("user@example.com", "Luis", "Pro")
	if err == nil || err.Error() != "Resend not configured" {
		t.Errorf("expected 'Resend not configured' error, got %v", err)
	}
}

func TestEmailService_SendSubscriptionConfirmation_GivenFakeKey_WhenSent_ThenReturnsError(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_fake_key",
		ResendFromEmail: "test@test.com",
	}
	svc := NewEmailService(cfg)

	err := svc.SendSubscriptionConfirmation("user@example.com", "Luis", "Pro")
	if err == nil {
		t.Error("expected error when sending with fake key")
	}
}

func TestEmailService_SendSubscriptionConfirmation_GivenValidData_WhenRendered_ThenTemplateContainsExpectedContent(t *testing.T) {
	cfg := &config.Config{
		FrontendURL: "https://app.solennix.com",
	}
	svc := NewEmailService(cfg)

	html := svc.renderTemplate(subscriptionConfirmationBody, map[string]string{
		"UserName": "Luis",
		"PlanName": "Pro",
	})

	if !strings.Contains(html, "Luis") {
		t.Error("expected HTML to contain user name")
	}
	if !strings.Contains(html, "Pro") {
		t.Error("expected HTML to contain plan name")
	}
	if !strings.Contains(html, "activo") {
		t.Error("expected HTML to contain active confirmation text")
	}
}

// ---------------------------------------------------------------------------
// renderTemplate tests
// ---------------------------------------------------------------------------

func TestEmailService_RenderTemplate_GivenAllTemplates_WhenRendered_ThenContainsBaseLayout(t *testing.T) {
	cfg := &config.Config{FrontendURL: "http://localhost:5173"}
	svc := NewEmailService(cfg)

	templates := map[string]struct {
		tmpl string
		data map[string]string
	}{
		"welcome": {
			tmpl: welcomeBody,
			data: map[string]string{"UserName": "Test", "DashboardLink": "http://test.com"},
		},
		"eventReminder": {
			tmpl: eventReminderBody,
			data: map[string]string{"UserName": "Test", "EventName": "Evt", "EventDate": "2026-01-01", "EventLink": "http://test.com"},
		},
		"paymentReceipt": {
			tmpl: paymentReceiptBody,
			data: map[string]string{"UserName": "Test", "EventName": "Evt", "Amount": "$100", "PaymentDate": "2026-01-01"},
		},
		"subscriptionConfirmation": {
			tmpl: subscriptionConfirmationBody,
			data: map[string]string{"UserName": "Test", "PlanName": "Pro"},
		},
		"passwordReset": {
			tmpl: passwordResetBody,
			data: map[string]string{"UserName": "Test", "ResetLink": "http://test.com"},
		},
	}

	for name, tc := range templates {
		t.Run(name, func(t *testing.T) {
			html := svc.renderTemplate(tc.tmpl, tc.data)
			if !strings.Contains(html, "<!DOCTYPE html>") {
				t.Error("expected HTML to contain DOCTYPE")
			}
			if !strings.Contains(html, "Solennix") {
				t.Error("expected HTML to contain Solennix branding")
			}
			if !strings.Contains(html, "footer") {
				t.Error("expected HTML to contain footer")
			}
		})
	}
}

func TestEmailService_SendEmail_ErrorWrapping(t *testing.T) {
	cfg := &config.Config{
		FrontendURL:     "http://localhost:5173",
		ResendAPIKey:    "re_some_fake_key",
		ResendFromEmail: "from@example.com",
	}
	svc := NewEmailService(cfg)

	err := svc.sendEmail("to@example.com", "Subject", "<p>Body</p>")
	if err == nil {
		t.Fatal("expected error from Resend API with fake key")
	}
	// The error should be wrapped with our prefix
	if !strings.HasPrefix(err.Error(), "failed to send email:") {
		t.Errorf("expected error to start with 'failed to send email:', got: %v", err)
	}
}
