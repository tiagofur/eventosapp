package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/tiagofur/eventosapp-backend/internal/models"
)

type PaymentRepo struct {
	pool *pgxpool.Pool
}

func NewPaymentRepo(pool *pgxpool.Pool) *PaymentRepo {
	return &PaymentRepo{pool: pool}
}

func (r *PaymentRepo) GetByEventID(ctx context.Context, eventID uuid.UUID) ([]models.Payment, error) {
	query := `SELECT id, event_id, user_id, amount, payment_date, payment_method, notes, created_at
		FROM payments WHERE event_id = $1 ORDER BY payment_date DESC`
	return r.queryPayments(ctx, query, eventID)
}

func (r *PaymentRepo) GetByDateRange(ctx context.Context, start, end string) ([]models.Payment, error) {
	query := `SELECT id, event_id, user_id, amount, payment_date, payment_method, notes, created_at
		FROM payments WHERE payment_date >= $1 AND payment_date <= $2 ORDER BY payment_date DESC`
	return r.queryPayments(ctx, query, start, end)
}

func (r *PaymentRepo) GetByEventIDs(ctx context.Context, eventIDs []uuid.UUID) ([]models.Payment, error) {
	if len(eventIDs) == 0 {
		return nil, nil
	}
	query := `SELECT id, event_id, user_id, amount, payment_date, payment_method, notes, created_at
		FROM payments WHERE event_id = ANY($1) ORDER BY payment_date DESC`
	return r.queryPayments(ctx, query, eventIDs)
}

func (r *PaymentRepo) Create(ctx context.Context, p *models.Payment) error {
	query := `INSERT INTO payments (event_id, user_id, amount, payment_date, payment_method, notes)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at`
	return r.pool.QueryRow(ctx, query,
		p.EventID, p.UserID, p.Amount, p.PaymentDate, p.PaymentMethod, p.Notes,
	).Scan(&p.ID, &p.CreatedAt)
}

func (r *PaymentRepo) Update(ctx context.Context, p *models.Payment) error {
	query := `UPDATE payments SET amount=$2, payment_date=$3, payment_method=$4, notes=$5
		WHERE id=$1
		RETURNING event_id, user_id, created_at`
	return r.pool.QueryRow(ctx, query,
		p.ID, p.Amount, p.PaymentDate, p.PaymentMethod, p.Notes,
	).Scan(&p.EventID, &p.UserID, &p.CreatedAt)
}

func (r *PaymentRepo) Delete(ctx context.Context, id uuid.UUID) error {
	tag, err := r.pool.Exec(ctx, "DELETE FROM payments WHERE id=$1", id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("payment not found")
	}
	return nil
}

func (r *PaymentRepo) queryPayments(ctx context.Context, query string, args ...interface{}) ([]models.Payment, error) {
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var payments []models.Payment
	for rows.Next() {
		var p models.Payment
		if err := rows.Scan(&p.ID, &p.EventID, &p.UserID, &p.Amount,
			&p.PaymentDate, &p.PaymentMethod, &p.Notes, &p.CreatedAt); err != nil {
			return nil, err
		}
		payments = append(payments, p)
	}
	return payments, nil
}
