import { render, screen } from '@testing-library/react';
import { FormProvider, useForm } from 'react-hook-form';
import { EventFinancials } from './EventFinancials';

const FormWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const methods = useForm({
    defaultValues: {
      discount: 10,
      requires_invoice: true,
      tax_rate: 16,
      tax_amount: 32,
      total_amount: 232,
    },
  });

  return <FormProvider {...methods}>{children}</FormProvider>;
};

const renderWithForm = (ui: React.ReactNode) => render(<FormWrapper>{ui}</FormWrapper>);

describe('EventFinancials', () => {
  it('renders tax and totals summary', () => {
    renderWithForm(
      <EventFinancials
        selectedProducts={[{ product_id: 'p1', quantity: 2, price: 100, discount: 0 }]}
        extras={[{ price: 20, cost: 10, exclude_utility: false }]}
        productUnitCosts={{ p1: 30 }}
      />
    );

    expect(screen.getByText('IVA (16%):')).toBeInTheDocument();
    expect(screen.getByText('$232.00')).toBeInTheDocument();
  });
});
