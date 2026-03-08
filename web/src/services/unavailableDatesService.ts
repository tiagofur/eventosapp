import { api } from '../lib/api';

export interface UnavailableDate {
  id: string;
  user_id: string;
  start_date: string;
  end_date: string;
  reason?: string;
  created_at: string;
  updated_at: string;
}

export const unavailableDatesService = {
  getDates: async (start: string, end: string): Promise<UnavailableDate[]> => {
    try {
      const response = await api.get<UnavailableDate[]>(`/unavailable-dates?start=${start}&end=${end}`);
      return response || [];
    } catch (error) {
      console.error('Error fetching unavailable dates:', error);
      throw error;
    }
  },

  addDates: async (data: { start_date: string; end_date: string; reason?: string }): Promise<UnavailableDate> => {
    const response = await api.post<UnavailableDate>('/unavailable-dates', data);
    return response;
  },

  removeDate: async (id: string): Promise<void> => {
    await api.delete<any>(`/unavailable-dates/${id}`);
  }
};
