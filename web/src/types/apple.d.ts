/** Apple Sign In JS SDK type declarations */
declare namespace AppleID {
  interface AuthI {
    init(config: {
      clientId: string;
      scope: string;
      redirectURI: string;
      usePopup: boolean;
    }): void;

    signIn(): Promise<SignInResponse>;
  }

  interface SignInResponse {
    authorization: {
      code: string;
      id_token: string;
      state?: string;
    };
    user?: {
      email?: string;
      name?: {
        firstName?: string;
        lastName?: string;
      };
    };
  }

  const auth: AuthI;
}
