import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@tests/customRender';
import { KeyboardShortcutsHelp } from './KeyboardShortcutsHelp';

describe('KeyboardShortcutsHelp', () => {
  const shortcuts = [
    { key: 'g d', label: 'G D', description: 'Ir al Dashboard' },
    { key: 'n', label: 'N', description: 'Crear nuevo (contextual)' },
    { key: '?', label: '?', description: 'Mostrar atajos de teclado' },
  ];

  it('does not render when closed', () => {
    render(
      <KeyboardShortcutsHelp
        open={false}
        onClose={vi.fn()}
        shortcuts={shortcuts}
      />,
    );

    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('renders modal sections and shortcut rows when open', () => {
    render(
      <KeyboardShortcutsHelp
        open={true}
        onClose={vi.fn()}
        shortcuts={shortcuts}
        currentSection="events"
      />,
    );

    expect(screen.getByRole('dialog')).toBeInTheDocument();
    expect(screen.getByText('Ir al Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Crear nuevo (contextual)')).toBeInTheDocument();
    expect(screen.getByText('⌘K')).toBeInTheDocument();
    expect(screen.getByText('?')).toBeInTheDocument();
  });

  it('falls back to raw section key when label mapping does not exist', () => {
    render(
      <KeyboardShortcutsHelp
        open={true}
        onClose={vi.fn()}
        shortcuts={shortcuts}
        currentSection="clients"
      />,
    );

    expect(screen.getByText('clients')).toBeInTheDocument();
  });

  it('calls onClose on overlay and close button click', () => {
    const onClose = vi.fn();
    const { container } = render(
      <KeyboardShortcutsHelp
        open={true}
        onClose={onClose}
        shortcuts={shortcuts}
      />,
    );

    const overlay = container.querySelector('[aria-hidden="true"]');
    expect(overlay).not.toBeNull();
    fireEvent.click(overlay!);
    expect(onClose).toHaveBeenCalledTimes(1);

    const closeButton = screen.getByRole('button');
    fireEvent.click(closeButton);
    expect(onClose).toHaveBeenCalledTimes(2);
  });
});