import { api } from '@/lib/api';
import type { User } from '@/types/auth';

export interface TeamInviteAcceptResponse {
  user: User;
  tokens: {
    access_token: string;
    refresh_token: string;
    expires_at: number;
  };
}

export const authService = {
  async acceptTeamInvite(token: string, password: string): Promise<TeamInviteAcceptResponse> {
    return api.post<TeamInviteAcceptResponse>('/auth/team-invite/accept', {
      token,
      password,
    });
  },
};
