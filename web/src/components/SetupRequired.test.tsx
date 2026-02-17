import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { SetupRequired } from './SetupRequired';

describe('SetupRequired', () => {
  it('renders setup instructions', () => {
    render(<SetupRequired />);
    expect(screen.getByText('Configuración Requerida')).toBeInTheDocument();
    expect(screen.getAllByText(/Supabase/i).length).toBeGreaterThan(0);
    expect(screen.getAllByText(/variables de entorno/i).length).toBeGreaterThan(0);
  });
});
