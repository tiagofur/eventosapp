package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/tiagofur/eventosapp-backend/internal/models"
)

type UserRepo struct {
	pool *pgxpool.Pool
}

func NewUserRepo(pool *pgxpool.Pool) *UserRepo {
	return &UserRepo{pool: pool}
}

func (r *UserRepo) Create(ctx context.Context, user *models.User) error {
	query := `
		INSERT INTO users (email, password_hash, name, business_name, plan)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, created_at, updated_at`
	return r.pool.QueryRow(ctx, query,
		user.Email, user.PasswordHash, user.Name, user.BusinessName, user.Plan,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
}

func (r *UserRepo) GetByEmail(ctx context.Context, email string) (*models.User, error) {
	user := &models.User{}
	query := `SELECT id, email, password_hash, name, business_name,
		default_deposit_percent, default_cancellation_days, default_refund_percent,
		plan, stripe_customer_id, created_at, updated_at
		FROM users WHERE email = $1`
	err := r.pool.QueryRow(ctx, query, email).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.Name, &user.BusinessName,
		&user.DefaultDepositPercent, &user.DefaultCancellationDays, &user.DefaultRefundPercent,
		&user.Plan, &user.StripeCustomerID, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}
	return user, nil
}

func (r *UserRepo) GetByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	user := &models.User{}
	query := `SELECT id, email, password_hash, name, business_name,
		default_deposit_percent, default_cancellation_days, default_refund_percent,
		plan, stripe_customer_id, created_at, updated_at
		FROM users WHERE id = $1`
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.Name, &user.BusinessName,
		&user.DefaultDepositPercent, &user.DefaultCancellationDays, &user.DefaultRefundPercent,
		&user.Plan, &user.StripeCustomerID, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}
	return user, nil
}

func (r *UserRepo) Update(ctx context.Context, id uuid.UUID, name, businessName *string,
	depositPercent, cancellationDays, refundPercent *float64) (*models.User, error) {
	query := `
		UPDATE users SET
			name = COALESCE($2, name),
			business_name = COALESCE($3, business_name),
			default_deposit_percent = COALESCE($4, default_deposit_percent),
			default_cancellation_days = COALESCE($5, default_cancellation_days),
			default_refund_percent = COALESCE($6, default_refund_percent),
			updated_at = NOW()
		WHERE id = $1
		RETURNING id, email, password_hash, name, business_name,
			default_deposit_percent, default_cancellation_days, default_refund_percent,
			plan, stripe_customer_id, created_at, updated_at`
	user := &models.User{}
	err := r.pool.QueryRow(ctx, query, id, name, businessName,
		depositPercent, cancellationDays, refundPercent).Scan(
		&user.ID, &user.Email, &user.PasswordHash, &user.Name, &user.BusinessName,
		&user.DefaultDepositPercent, &user.DefaultCancellationDays, &user.DefaultRefundPercent,
		&user.Plan, &user.StripeCustomerID, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to update user: %w", err)
	}
	return user, nil
}
