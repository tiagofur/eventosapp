import { render, screen, fireEvent } from '@testing-library/react';
import { EventExtras } from './EventExtras';

describe('EventExtras', () => {
  it('renders extras and handles changes', () => {
    const onAddExtra = vi.fn();
    const onRemoveExtra = vi.fn();
    const onExtraChange = vi.fn();

    const { container } = render(
      <EventExtras
        extras={[
          { description: 'Transporte', cost: 50, price: 80, exclude_utility: false },
        ]}
        onAddExtra={onAddExtra}
        onRemoveExtra={onRemoveExtra}
        onExtraChange={onExtraChange}
      />
    );

    expect(screen.getByDisplayValue('Transporte')).toBeInTheDocument();
    expect(screen.getByText('$80.00')).toBeInTheDocument();

    fireEvent.change(screen.getByPlaceholderText('Descripción'), { target: { value: 'Gasolina' } });
    expect(onExtraChange).toHaveBeenCalledWith(0, 'description', 'Gasolina');

    fireEvent.click(container.querySelectorAll('button')[0]);
    expect(onRemoveExtra).toHaveBeenCalledWith(0);

    fireEvent.click(screen.getByRole('button', { name: /Agregar Extra/i }));
    expect(onAddExtra).toHaveBeenCalled();
  });

  it('updates costs and toggles exclude utility', () => {
    const onAddExtra = vi.fn();
    const onRemoveExtra = vi.fn();
    const onExtraChange = vi.fn();

    render(
      <EventExtras
        extras={[
          { description: 'Transporte', cost: 50, price: 80, exclude_utility: false },
        ]}
        onAddExtra={onAddExtra}
        onRemoveExtra={onRemoveExtra}
        onExtraChange={onExtraChange}
      />
    );

    fireEvent.click(screen.getByRole('checkbox'));
    expect(onExtraChange).toHaveBeenCalledWith(0, 'exclude_utility', true);

    fireEvent.change(screen.getByDisplayValue('50'), { target: { value: '60' } });
    expect(onExtraChange).toHaveBeenCalledWith(0, 'cost', 60);

    fireEvent.change(screen.getByDisplayValue('80'), { target: { value: '90' } });
    expect(onExtraChange).toHaveBeenCalledWith(0, 'price', 90);
  });
});
