import { describe, it, expect, vi, beforeEach } from 'vitest';
import { generateBudgetPDF, generateContractPDF } from './pdfGenerator';

const autoTableMock = vi.fn();
const jsPDFMock = vi.fn();

vi.mock('jspdf', () => ({
  jsPDF: function (...args: any[]) {
    return jsPDFMock(...args);
  },
}));

vi.mock('jspdf-autotable', () => ({
  default: (...args: any[]) => autoTableMock(...args),
}));

const createDocMock = () => ({
  internal: { pageSize: { width: 210, height: 297 } },
  setFontSize: vi.fn(),
  setTextColor: vi.fn(),
  text: vi.fn(),
  setDrawColor: vi.fn(),
  setLineWidth: vi.fn(),
  line: vi.fn(),
  setFont: vi.fn(),
  save: vi.fn(),
  splitTextToSize: vi.fn((text: string) => text.split('\n')),
  lastAutoTable: { finalY: 60 },
});

describe('pdfGenerator', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    autoTableMock.mockImplementation((doc: any) => {
      doc.lastAutoTable = { finalY: 60 };
    });
  });

  it('generates budget with products and extras', () => {
    const doc = createDocMock();
    jsPDFMock.mockReturnValue(doc);

    generateBudgetPDF(
      {
        id: '1',
        event_date: '2024-01-02',
        service_type: 'Boda',
        num_people: 100,
        total_amount: 1000,
        tax_amount: 160,
        tax_rate: 16,
        requires_invoice: true,
        client: { name: 'Ana', phone: '555', email: 'ana@example.com' } as any,
      } as any,
      { name: 'Eventos Ana', business_name: 'Eventos Ana' } as any,
      [
        {
          products: { name: 'Menu' },
          quantity: 2,
          unit_price: 100,
          discount: 10,
        } as any,
      ],
      [{ description: 'Extra', price: 50 } as any]
    );

    expect(autoTableMock).toHaveBeenCalled();
    expect(doc.save).toHaveBeenCalledWith('Presupuesto_Ana.pdf');
  });

  it('generates budget with empty items', () => {
    const doc = createDocMock();
    jsPDFMock.mockReturnValue(doc);

    generateBudgetPDF(
      {
        id: '1',
        event_date: '2024-01-02',
        service_type: 'Boda',
        num_people: 100,
        total_amount: 500,
        requires_invoice: false,
        client: { name: 'Ana' } as any,
      } as any,
      null,
      [],
      []
    );

    expect(autoTableMock).not.toHaveBeenCalled();
    expect(doc.text).toHaveBeenCalledWith(
      'No hay productos o servicios registrados.',
      20,
      expect.any(Number)
    );
  });

  it('generates contract and saves pdf', () => {
    const doc = createDocMock();
    jsPDFMock.mockReturnValue(doc);

    generateContractPDF(
      {
        id: '1',
        event_date: '2024-01-02',
        service_type: 'Boda',
        num_people: 100,
        total_amount: 2000,
        deposit_percent: 50,
        cancellation_days: 10,
        refund_percent: 10,
        client: { name: 'Ana' } as any,
      } as any,
      { name: 'Eventos Ana', business_name: 'Eventos Ana' } as any
    );

    expect(doc.save).toHaveBeenCalledWith('Contrato_Ana.pdf');
    expect(doc.text).toHaveBeenCalled();
  });
});
