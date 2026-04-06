package middleware

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
)

type mockUserGetter struct {
	plan  string
	err   error
	calls int
}

func (m *mockUserGetter) GetPlanByID(_ context.Context, _ uuid.UUID) (string, error) {
	m.calls++
	return m.plan, m.err
}

func TestNewCachedPlanResolver_GivenGetterAndTTL_ThenReturnsResolver(t *testing.T) {
	getter := &mockUserGetter{plan: "pro"}
	resolver := NewCachedPlanResolver(getter, 5*time.Minute)

	if resolver == nil {
		t.Fatal("NewCachedPlanResolver returned nil")
	}
	if resolver.getter != getter {
		t.Fatal("getter not set correctly")
	}
	if resolver.ttl != 5*time.Minute {
		t.Fatalf("ttl = %v, want %v", resolver.ttl, 5*time.Minute)
	}
}

func TestGetPlan_GivenValidUser_WhenFirstCall_ThenReturnsCorrectPlan(t *testing.T) {
	getter := &mockUserGetter{plan: "pro"}
	resolver := NewCachedPlanResolver(getter, 5*time.Minute)
	userID := uuid.New()

	plan := resolver.GetPlan(context.Background(), userID)

	if plan != "pro" {
		t.Fatalf("GetPlan() = %q, want %q", plan, "pro")
	}
	if getter.calls != 1 {
		t.Fatalf("getter called %d times, want 1", getter.calls)
	}
}

func TestGetPlan_GivenCachedResult_WhenSecondCall_ThenDoesNotHitGetter(t *testing.T) {
	getter := &mockUserGetter{plan: "business"}
	resolver := NewCachedPlanResolver(getter, 5*time.Minute)
	userID := uuid.New()

	plan1 := resolver.GetPlan(context.Background(), userID)
	plan2 := resolver.GetPlan(context.Background(), userID)

	if plan1 != "business" || plan2 != "business" {
		t.Fatalf("GetPlan() = %q / %q, want %q", plan1, plan2, "business")
	}
	if getter.calls != 1 {
		t.Fatalf("getter called %d times, want 1 (cached)", getter.calls)
	}
}

func TestGetPlan_GivenGetterError_WhenCalled_ThenFallsBackToBasic(t *testing.T) {
	getter := &mockUserGetter{err: errors.New("db down")}
	resolver := NewCachedPlanResolver(getter, 5*time.Minute)
	userID := uuid.New()

	plan := resolver.GetPlan(context.Background(), userID)

	if plan != "basic" {
		t.Fatalf("GetPlan() = %q, want %q (fallback)", plan, "basic")
	}
}

func TestGetPlan_GivenExpiredCache_WhenCalled_ThenRefreshesFromGetter(t *testing.T) {
	getter := &mockUserGetter{plan: "pro"}
	resolver := NewCachedPlanResolver(getter, 1*time.Millisecond)
	userID := uuid.New()

	plan1 := resolver.GetPlan(context.Background(), userID)
	if plan1 != "pro" {
		t.Fatalf("first GetPlan() = %q, want %q", plan1, "pro")
	}

	// Wait for cache to expire
	time.Sleep(5 * time.Millisecond)

	getter.plan = "business"
	plan2 := resolver.GetPlan(context.Background(), userID)

	if plan2 != "business" {
		t.Fatalf("second GetPlan() = %q, want %q (after cache expiry)", plan2, "business")
	}
	if getter.calls != 2 {
		t.Fatalf("getter called %d times, want 2 (after cache expiry)", getter.calls)
	}
}

func TestGetPlan_GivenDifferentUsers_WhenCalled_ThenCachesIndependently(t *testing.T) {
	getter := &mockUserGetter{plan: "pro"}
	resolver := NewCachedPlanResolver(getter, 5*time.Minute)

	user1 := uuid.New()
	user2 := uuid.New()

	plan1 := resolver.GetPlan(context.Background(), user1)
	if plan1 != "pro" {
		t.Fatalf("user1 plan = %q, want %q", plan1, "pro")
	}

	getter.plan = "business"
	plan2 := resolver.GetPlan(context.Background(), user2)
	if plan2 != "business" {
		t.Fatalf("user2 plan = %q, want %q", plan2, "business")
	}

	if getter.calls != 2 {
		t.Fatalf("getter called %d times, want 2 (different users)", getter.calls)
	}
}
