import { render, screen } from '@testing-library/react';
import { FormProvider, useForm } from 'react-hook-form';
import { EventGeneralInfo } from './EventGeneralInfo';

const FormWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const methods = useForm({
    defaultValues: {
      client_id: '',
      event_date: '2024-01-02',
      service_type: 'Boda',
      num_people: 100,
      status: 'quoted',
    },
  });

  return <FormProvider {...methods}>{children}</FormProvider>;
};

const renderWithForm = (ui: React.ReactNode) => render(<FormWrapper>{ui}</FormWrapper>);

describe('EventGeneralInfo', () => {
  it('renders client options and history', () => {
    renderWithForm(
      <EventGeneralInfo
        clients={[
          {
            id: '1',
            name: 'Ana Perez',
            total_events: 3,
            total_spent: 1200.5,
          } as any,
        ]}
        clientIdValue="1"
      />
    );

    expect(screen.getByText('Seleccionar cliente')).toBeInTheDocument();
    expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    expect(screen.getByText(/Historial del Cliente/i)).toBeInTheDocument();
    expect(screen.getByText(/3 eventos realizados/i)).toBeInTheDocument();
    expect(screen.getByText(/Total gastado: \$1200.50/i)).toBeInTheDocument();
  });
});
