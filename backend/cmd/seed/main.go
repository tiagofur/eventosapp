// Seed command — populates a user's account with realistic demo data
// for App Store screenshots.
//
// Usage:
//
//	go run ./cmd/seed -email=demo@solennix.com
//	go run ./cmd/seed -user-id=<uuid>
//
// Idempotent: wipes existing clients/events/products/inventory/payments
// for the target user before inserting fresh data.
package main

import (
	"context"
	"flag"
	"fmt"
	"log/slog"
	"math/rand"
	"os"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/tiagofur/solennix-backend/internal/config"
)

func main() {
	var email, userIDStr string
	flag.StringVar(&email, "email", "", "Target user email")
	flag.StringVar(&userIDStr, "user-id", "", "Target user UUID")
	flag.Parse()

	if email == "" && userIDStr == "" {
		fmt.Println("usage: seed -email=<email> | -user-id=<uuid>")
		os.Exit(2)
	}

	cfg, err := config.Load()
	must(err, "load config")

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	must(err, "connect db")
	defer pool.Close()

	var userID uuid.UUID
	if userIDStr != "" {
		userID, err = uuid.Parse(userIDStr)
		must(err, "parse user id")
	} else {
		err = pool.QueryRow(ctx, `SELECT id FROM users WHERE email=$1`, email).Scan(&userID)
		must(err, "lookup user by email")
	}

	slog.Info("seeding user", "id", userID)

	if err := seed(ctx, pool, userID); err != nil {
		slog.Error("seed failed", "error", err)
		os.Exit(1)
	}
	slog.Info("seed complete")
}

func must(err error, msg string) {
	if err != nil {
		slog.Error(msg, "error", err)
		os.Exit(1)
	}
}

func seed(ctx context.Context, pool *pgxpool.Pool, uid uuid.UUID) error {
	rng := rand.New(rand.NewSource(42))

	// Wipe existing demo data for this user (cascade handles children).
	wipeStmts := []string{
		`DELETE FROM payments WHERE user_id=$1`,
		`DELETE FROM events WHERE user_id=$1`,
		`DELETE FROM clients WHERE user_id=$1`,
		`DELETE FROM products WHERE user_id=$1`,
		`DELETE FROM inventory WHERE user_id=$1`,
	}
	for _, q := range wipeStmts {
		if _, err := pool.Exec(ctx, q, uid); err != nil {
			return fmt.Errorf("wipe: %w", err)
		}
	}

	// --- CLIENTS ---
	type client struct {
		name, phone, email, city, notes string
	}
	clients := []client{
		{"María Fernanda López", "+52 55 1234 5678", "maria.lopez@gmail.com", "Ciudad de México", "Boda en jardín, prefiere paleta en tonos pastel."},
		{"Roberto Sánchez Pérez", "+52 33 2345 6789", "rsanchez@empresa.mx", "Guadalajara", "Cliente corporativo recurrente."},
		{"Valentina Ramírez", "+52 81 3456 7890", "vale.ramirez@hotmail.com", "Monterrey", "Quinceañera de su hija Sofía."},
		{"Carlos Eduardo Mendoza", "+52 55 4567 8901", "carlos.mendoza@icloud.com", "Ciudad de México", "Bautizo en salón familiar."},
		{"Isabella Torres Vega", "+52 222 567 8901", "isabella.torres@gmail.com", "Puebla", "Boda civil + religiosa."},
		{"Alejandro Gutiérrez", "+52 998 678 9012", "alex.gutierrez@outlook.com", "Cancún", "Evento empresarial en playa."},
		{"Gabriela Ruiz Hernández", "+52 664 789 0123", "gabi.ruiz@gmail.com", "Tijuana", "Cumpleaños 50."},
		{"Diego Armando Castro", "+52 477 890 1234", "diego.castro@empresa.mx", "León", "Cena de fin de año corporativa."},
	}

	clientIDs := make([]uuid.UUID, len(clients))
	for i, c := range clients {
		id := uuid.New()
		clientIDs[i] = id
		_, err := pool.Exec(ctx, `
			INSERT INTO clients (id, user_id, name, phone, email, city, notes, total_events, total_spent)
			VALUES ($1,$2,$3,$4,$5,$6,$7,0,0)`,
			id, uid, c.name, c.phone, c.email, c.city, c.notes)
		if err != nil {
			return fmt.Errorf("client %s: %w", c.name, err)
		}
	}

	// --- PRODUCTS ---
	type product struct {
		name, category string
		price          float64
	}
	products := []product{
		{"Paquete Boda Elegante (100 pax)", "Banquete", 85000},
		{"Paquete Boda Premium (150 pax)", "Banquete", 135000},
		{"Paquete Quinceañera Completo", "Banquete", 72000},
		{"Paquete Bautizo Familiar (50 pax)", "Banquete", 28000},
		{"Coctel Corporativo", "Coctelería", 18500},
		{"Barra Libre Premium (4 hrs)", "Bebidas", 22000},
		{"Servicio de Mesero (por hora)", "Servicio", 250},
		{"Renta Mobiliario Dorado", "Mobiliario", 12500},
		{"Centros de Mesa Florales", "Decoración", 850},
		{"Iluminación Arquitectónica", "Decoración", 8500},
		{"DJ + Audio Profesional", "Entretenimiento", 15000},
		{"Fotografía Boda (8 hrs)", "Fotografía", 18000},
		{"Video Highlights", "Fotografía", 12000},
		{"Mesa de Postres", "Repostería", 6500},
		{"Pastel de Bodas 4 Pisos", "Repostería", 4800},
	}
	for _, p := range products {
		_, err := pool.Exec(ctx, `
			INSERT INTO products (id, user_id, name, category, base_price, is_active)
			VALUES ($1,$2,$3,$4,$5,true)`,
			uuid.New(), uid, p.name, p.category, p.price)
		if err != nil {
			return fmt.Errorf("product %s: %w", p.name, err)
		}
	}

	// --- INVENTORY ---
	type inv struct {
		name, unit, typ string
		stock, min      float64
		cost            float64
	}
	items := []inv{
		{"Mesa redonda dorada 10 pax", "pza", "equipment", 25, 10, 0},
		{"Silla Tiffany dorada", "pza", "equipment", 300, 100, 0},
		{"Mantel blanco satinado", "pza", "equipment", 40, 15, 0},
		{"Copa vino tinto", "pza", "equipment", 400, 150, 0},
		{"Copa flauta champaña", "pza", "equipment", 300, 100, 0},
		{"Vajilla completa (por pax)", "set", "equipment", 350, 100, 0},
		{"Cristalería premium", "set", "equipment", 200, 80, 0},
		{"Cubertería bañada en oro", "set", "equipment", 250, 100, 0},
		{"Sombrillas jardín", "pza", "equipment", 12, 4, 0},
		{"Calentador de terraza", "pza", "equipment", 8, 3, 0},
		{"Servilletas tela color crema", "pza", "ingredient", 500, 200, 8},
		{"Flores frescas (bouquet)", "bouquet", "ingredient", 0, 20, 350},
		{"Velas decorativas", "pza", "ingredient", 180, 50, 45},
		{"Hielo premium", "kg", "ingredient", 120, 50, 25},
		{"Vino tinto reserva", "botella", "ingredient", 48, 24, 380},
		{"Champaña brut", "botella", "ingredient", 36, 12, 650},
		{"Whisky 12 años", "botella", "ingredient", 12, 6, 950},
		{"Tequila reposado premium", "botella", "ingredient", 18, 8, 520},
		{"Refrescos surtidos", "botella", "ingredient", 240, 100, 18},
		{"Agua embotellada", "botella", "ingredient", 360, 150, 10},
	}
	for _, it := range items {
		var cost interface{}
		if it.cost > 0 {
			cost = it.cost
		}
		_, err := pool.Exec(ctx, `
			INSERT INTO inventory (id, user_id, ingredient_name, current_stock, minimum_stock, unit, unit_cost, type)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
			uuid.New(), uid, it.name, it.stock, it.min, it.unit, cost, it.typ)
		if err != nil {
			return fmt.Errorf("inventory %s: %w", it.name, err)
		}
	}

	// --- EVENTS (mix of past/today/upcoming) ---
	type ev struct {
		clientIdx                   int
		daysFromToday               int
		serviceType                 string
		numPeople                   int
		status                      string
		total                       float64
		location, city, startT, end string
		notes                       string
	}
	today := time.Now()
	_ = rng
	events := []ev{
		{0, 18, "Boda", 120, "confirmed", 142500, "Jardín Los Olivos", "Ciudad de México", "17:00", "01:00", "Ceremonia civil + recepción."},
		{1, 5, "Corporativo", 80, "confirmed", 45000, "Hotel Camino Real", "Guadalajara", "19:00", "23:00", "Cena anual de la empresa."},
		{2, 32, "Quinceañera", 150, "confirmed", 98500, "Salón Imperial", "Monterrey", "18:00", "02:00", "Vals a las 20:00."},
		{3, 12, "Bautizo", 45, "confirmed", 32000, "Casa del cliente", "Ciudad de México", "13:00", "18:00", "Servicio de comida tradicional."},
		{4, 60, "Boda", 180, "quoted", 165000, "Hacienda San Antonio", "Puebla", "17:30", "02:00", "Pendiente confirmar menú final."},
		{5, 45, "Corporativo", 100, "confirmed", 88000, "Playa Delfines", "Cancún", "19:00", "00:00", "Evento al aire libre, requiere carpa."},
		{6, -7, "Cumpleaños", 60, "completed", 38500, "Restaurante Las Rosas", "Tijuana", "20:00", "01:00", "Cena de gala, 50 aniversario."},
		{7, -14, "Corporativo", 200, "completed", 125000, "Salón Dorado", "León", "20:00", "01:00", "Fin de año."},
		{0, 0, "Degustación", 8, "confirmed", 4500, "Oficina Solennix", "Ciudad de México", "12:00", "14:00", "Muestra de menú para boda."},
		{2, 90, "Quinceañera", 120, "quoted", 82000, "Hotel Presidente", "Monterrey", "19:00", "02:00", "Pendiente firma de contrato."},
		{4, -30, "Boda Civil", 40, "completed", 28500, "Jardín San José", "Puebla", "13:00", "18:00", "Boda íntima."},
		{1, 75, "Corporativo", 150, "quoted", 92000, "Expo Guadalajara", "Guadalajara", "18:00", "23:00", "Lanzamiento de producto."},
	}

	type evRow struct {
		id     uuid.UUID
		total  float64
		status string
	}
	evRows := make([]evRow, 0, len(events))
	for _, e := range events {
		id := uuid.New()
		date := today.AddDate(0, 0, e.daysFromToday).Format("2006-01-02")
		client := clientIDs[e.clientIdx]
		tax := e.total * 0.16 / 1.16
		_, err := pool.Exec(ctx, `
			INSERT INTO events (id, user_id, client_id, event_date, start_time, end_time,
				service_type, num_people, status, discount, discount_type, requires_invoice,
				tax_rate, tax_amount, total_amount, location, city, notes)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,0,'percent',false,16,$10,$11,$12,$13,$14)`,
			id, uid, client, date, e.startT, e.end, e.serviceType, e.numPeople, e.status,
			tax, e.total, e.location, e.city, e.notes)
		if err != nil {
			return fmt.Errorf("event %s: %w", e.serviceType, err)
		}
		evRows = append(evRows, evRow{id, e.total, e.status})
	}

	// --- PAYMENTS (deposits for confirmed/completed) ---
	for _, r := range evRows {
		if r.status == "quoted" {
			continue
		}
		deposit := r.total * 0.5
		depositDate := today.AddDate(0, 0, -20).Format("2006-01-02")
		_, err := pool.Exec(ctx, `
			INSERT INTO payments (id, event_id, user_id, amount, payment_date, payment_method, notes)
			VALUES ($1,$2,$3,$4,$5,'transfer','Anticipo 50%')`,
			uuid.New(), r.id, uid, deposit, depositDate)
		if err != nil {
			return fmt.Errorf("payment deposit: %w", err)
		}
		if r.status == "completed" {
			balance := r.total - deposit
			balDate := today.AddDate(0, 0, -1).Format("2006-01-02")
			_, err := pool.Exec(ctx, `
				INSERT INTO payments (id, event_id, user_id, amount, payment_date, payment_method, notes)
				VALUES ($1,$2,$3,$4,$5,'cash','Liquidación')`,
				uuid.New(), r.id, uid, balance, balDate)
			if err != nil {
				return fmt.Errorf("payment balance: %w", err)
			}
		}
	}

	// Refresh client aggregates
	_, err := pool.Exec(ctx, `
		UPDATE clients c SET
			total_events = COALESCE((SELECT COUNT(*) FROM events e WHERE e.client_id = c.id),0),
			total_spent  = COALESCE((SELECT SUM(total_amount) FROM events e WHERE e.client_id = c.id AND e.status IN ('confirmed','completed')),0)
		WHERE c.user_id=$1`, uid)
	if err != nil {
		return fmt.Errorf("refresh client aggregates: %w", err)
	}

	return nil
}
