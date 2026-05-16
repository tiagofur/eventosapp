import { beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('@/lib/api', () => ({
  API_URL: 'https://api.test',
}));

import { downloadEventPDF, downloadQuickQuotePDF, type QuickQuotePDFRequest } from './pdfService';

describe('pdfService', () => {
  const fetchMock = vi.fn();
  const createObjectURLMock = vi.fn();
  const revokeObjectURLMock = vi.fn();

  let capturedAnchor: HTMLAnchorElement;
  let clickMock: ReturnType<typeof vi.fn>;
  let removeMock: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    vi.restoreAllMocks();
    vi.clearAllMocks();

    vi.stubGlobal('fetch', fetchMock);

    clickMock = vi.fn();
    removeMock = vi.fn();

    capturedAnchor = {
      href: '',
      download: '',
      click: clickMock,
      remove: removeMock,
    } as unknown as HTMLAnchorElement;

    vi.spyOn(document, 'createElement').mockReturnValue(capturedAnchor as any);
    vi.spyOn(document.body, 'appendChild').mockImplementation((node) => node);

    createObjectURLMock.mockReturnValue('blob:mock-url');
    Object.defineProperty(URL, 'createObjectURL', {
      value: createObjectURLMock,
      writable: true,
      configurable: true,
    });

    Object.defineProperty(URL, 'revokeObjectURL', {
      value: revokeObjectURLMock,
      writable: true,
      configurable: true,
    });

    document.cookie = 'csrf_token_v2=test%20token';
  });

  it('downloadEventPDF performs GET, includes CSRF header and downloads with server filename', async () => {
    const blob = new Blob(['pdf']);
    const headers = new Headers({
      'Content-Disposition': 'attachment; filename="event-budget.pdf"',
    });

    fetchMock.mockResolvedValue({
      ok: true,
      blob: async () => blob,
      headers,
    });

    await downloadEventPDF('event-1', 'budget');

    expect(fetchMock).toHaveBeenCalledWith('https://api.test/events/event-1/pdf/budget', {
      method: 'GET',
      credentials: 'include',
      headers: {
        'X-CSRF-Token': 'test token',
      },
    });
    expect(createObjectURLMock).toHaveBeenCalledWith(blob);
    expect(capturedAnchor.href).toBe('blob:mock-url');
    expect(capturedAnchor.download).toBe('event-budget.pdf');
    expect(document.body.appendChild).toHaveBeenCalledWith(capturedAnchor);
    expect(clickMock).toHaveBeenCalledTimes(1);
    expect(removeMock).toHaveBeenCalledTimes(1);
    expect(revokeObjectURLMock).toHaveBeenCalledWith('blob:mock-url');
  });

  it('downloadEventPDF falls back to type filename when Content-Disposition is missing', async () => {
    vi.spyOn(document, 'cookie', 'get').mockReturnValue('');

    fetchMock.mockResolvedValue({
      ok: true,
      blob: async () => new Blob(['pdf']),
      headers: new Headers(),
    });

    await downloadEventPDF('event-2', 'contract');

    expect(fetchMock).toHaveBeenCalledWith(
      'https://api.test/events/event-2/pdf/contract',
      expect.objectContaining({ headers: {} }),
    );
    expect(capturedAnchor.download).toBe('contract.pdf');
  });

  it('downloadEventPDF throws a descriptive error on non-ok response', async () => {
    fetchMock.mockResolvedValue({
      ok: false,
      status: 500,
      text: async () => 'boom',
    });

    await expect(downloadEventPDF('event-3', 'checklist')).rejects.toThrow(
      'PDF generation failed (500): boom',
    );
  });

  it('downloadEventPDF falls back to empty body when reading error text fails', async () => {
    fetchMock.mockResolvedValue({
      ok: false,
      status: 502,
      text: async () => {
        throw new Error('cannot read body');
      },
    });

    await expect(downloadEventPDF('event-4', 'equipment-list')).rejects.toThrow(
      'PDF generation failed (502): ',
    );
  });

  it('downloadQuickQuotePDF performs POST and downloads with fallback filename', async () => {
    const payload: QuickQuotePDFRequest = {
      products: [{ name: 'Mesa', quantity: 1, unit_price: 1000, discount: 0 }],
      extras: [],
      num_people: 50,
      discount: 0,
      discount_type: 'fixed',
      requires_invoice: false,
      tax_rate: 16,
    };

    const blob = new Blob(['pdf']);
    fetchMock.mockResolvedValue({
      ok: true,
      blob: async () => blob,
      headers: new Headers(),
    });

    await downloadQuickQuotePDF(payload);

    expect(fetchMock).toHaveBeenCalledWith('https://api.test/quick-quotes/pdf', {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': 'test token',
      },
      body: JSON.stringify(payload),
    });
    expect(capturedAnchor.download).toBe('quick-quote.pdf');
    expect(createObjectURLMock).toHaveBeenCalledWith(blob);
  });

  it('downloadQuickQuotePDF throws a descriptive error on non-ok response', async () => {
    const payload: QuickQuotePDFRequest = {
      products: [],
      extras: [],
      num_people: 0,
      discount: 0,
      discount_type: 'percent',
      requires_invoice: false,
      tax_rate: 16,
    };

    fetchMock.mockResolvedValue({
      ok: false,
      status: 400,
      text: async () => 'invalid request',
    });

    await expect(downloadQuickQuotePDF(payload)).rejects.toThrow(
      'Quick Quote PDF generation failed (400): invalid request',
    );
  });

  it('downloadQuickQuotePDF falls back to empty body when reading error text fails', async () => {
    const payload: QuickQuotePDFRequest = {
      products: [],
      extras: [],
      num_people: 0,
      discount: 0,
      discount_type: 'fixed',
      requires_invoice: false,
      tax_rate: 16,
    };

    fetchMock.mockResolvedValue({
      ok: false,
      status: 503,
      text: async () => {
        throw new Error('cannot read body');
      },
    });

    await expect(downloadQuickQuotePDF(payload)).rejects.toThrow(
      'Quick Quote PDF generation failed (503): ',
    );
  });
});
