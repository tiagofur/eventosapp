import { api } from "../lib/api";

export const subscriptionService = {
  createCheckoutSession: async (): Promise<{ url: string }> => {
    return await api.post<{ url: string }>(
      "/subscriptions/checkout-session",
      {},
    );
  },

  createPortalSession: async (): Promise<{ url: string }> => {
    return await api.post<{ url: string }>("/subscriptions/portal-session", {});
  },

  debugUpgrade: async (): Promise<{ message: string }> => {
    return await api.post<{ message: string }>(
      "/subscriptions/debug-upgrade",
      {},
    );
  },

  debugDowngrade: async (): Promise<{ message: string }> => {
    return await api.post<{ message: string }>(
      "/subscriptions/debug-downgrade",
      {},
    );
  },
};
