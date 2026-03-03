import { describe, it, expect, vi, beforeEach } from 'vitest';
import { exportToCsv } from './exportCsv';

describe('exportToCsv', () => {
  let appendChildSpy: ReturnType<typeof vi.spyOn>;
  let removeChildSpy: ReturnType<typeof vi.spyOn>;
  let createObjectURLSpy: ReturnType<typeof vi.fn>;
  let revokeObjectURLSpy: ReturnType<typeof vi.fn>;
  let clickSpy: ReturnType<typeof vi.fn>;
  let capturedLink: HTMLAnchorElement;
  let capturedBlobContent: string;
  let capturedBlobOptions: BlobPropertyBag | undefined;

  const OriginalBlob = globalThis.Blob;

  beforeEach(() => {
    vi.clearAllMocks();
    capturedBlobContent = '';
    capturedBlobOptions = undefined;

    clickSpy = vi.fn();
    capturedLink = {
      href: '',
      download: '',
      click: clickSpy,
    } as unknown as HTMLAnchorElement;

    vi.spyOn(document, 'createElement').mockReturnValue(capturedLink as any);
    appendChildSpy = vi.spyOn(document.body, 'appendChild').mockImplementation((node) => node);
    removeChildSpy = vi.spyOn(document.body, 'removeChild').mockImplementation((node) => node);

    createObjectURLSpy = vi.fn().mockReturnValue('blob:http://localhost/fake-url');
    revokeObjectURLSpy = vi.fn();
    globalThis.URL.createObjectURL = createObjectURLSpy as any;
    globalThis.URL.revokeObjectURL = revokeObjectURLSpy as any;

    // Intercept Blob constructor to capture raw string content
    globalThis.Blob = class extends OriginalBlob {
      constructor(parts?: BlobPart[], options?: BlobPropertyBag) {
        super(parts, options);
        if (parts && parts.length > 0) {
          capturedBlobContent = String(parts[0]);
        }
        capturedBlobOptions = options;
      }
    } as any;
  });

  // --- Download mechanics ---
  it('creates an anchor element, triggers click, and cleans up', () => {
    exportToCsv('test_export', ['Name', 'Age'], [['Alice', 30], ['Bob', 25]]);

    expect(document.createElement).toHaveBeenCalledWith('a');
    expect(createObjectURLSpy).toHaveBeenCalledTimes(1);
    expect(capturedLink.download).toBe('test_export.csv');
    expect(capturedLink.href).toBe('blob:http://localhost/fake-url');
    expect(clickSpy).toHaveBeenCalledTimes(1);
    expect(appendChildSpy).toHaveBeenCalledWith(capturedLink);
    expect(removeChildSpy).toHaveBeenCalledWith(capturedLink);
    expect(revokeObjectURLSpy).toHaveBeenCalledWith('blob:http://localhost/fake-url');
  });

  it('appends .csv extension to the filename', () => {
    exportToCsv('my_file', ['A'], [['1']]);

    expect(capturedLink.download).toBe('my_file.csv');
  });

  it('creates a Blob with text/csv MIME type', () => {
    exportToCsv('report', ['Col1', 'Col2'], [['a', 'b']]);

    expect(capturedBlobOptions).toEqual({ type: 'text/csv;charset=utf-8;' });
  });

  it('cleans up DOM and revokes object URL after click', () => {
    exportToCsv('cleanup', ['A'], [['1']]);

    expect(appendChildSpy).toHaveBeenCalledBefore(clickSpy as any);
    expect(removeChildSpy).toHaveBeenCalledWith(capturedLink);
    expect(revokeObjectURLSpy).toHaveBeenCalledWith('blob:http://localhost/fake-url');
  });

  // --- BOM ---
  it('prepends UTF-8 BOM for Excel compatibility', () => {
    exportToCsv('bom', ['A'], [['1']]);

    expect(capturedBlobContent.charCodeAt(0)).toBe(0xFEFF);
  });

  // --- CSV formatting ---
  describe('CSV content formatting', () => {
    it('joins headers and rows with commas and newlines', () => {
      exportToCsv('verify', ['A', 'B'], [['1', '2'], ['3', '4']]);

      // Strip leading BOM for content assertions
      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('A,B\n1,2\n3,4');
    });

    it('handles empty rows array (headers only)', () => {
      exportToCsv('headers_only', ['A', 'B', 'C'], []);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('A,B,C');
    });

    it('handles empty headers array', () => {
      exportToCsv('no_headers', [], [['val1', 'val2']]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('\nval1,val2');
    });

    it('handles multiple rows', () => {
      exportToCsv(
        'multi',
        ['Name', 'Score'],
        [
          ['Alice', 100],
          ['Bob', 200],
          ['Charlie', 300],
        ],
      );

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Name,Score\nAlice,100\nBob,200\nCharlie,300');
    });
  });

  // --- Escape logic ---
  describe('value escaping', () => {
    it('wraps values containing commas in double quotes', () => {
      exportToCsv('esc', ['Name'], [['Last, First']]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Name\n"Last, First"');
    });

    it('wraps values containing double quotes and doubles them', () => {
      exportToCsv('esc', ['Phrase'], [['She said "hi"']]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Phrase\n"She said ""hi"""');
    });

    it('wraps values containing newlines in double quotes', () => {
      exportToCsv('esc', ['Note'], [['A\nB']]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Note\n"A\nB"');
    });

    it('handles value with comma, quote, and newline combined', () => {
      exportToCsv('esc', ['Complex'], [['He said, "hi"\nthen left']]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Complex\n"He said, ""hi""\nthen left"');
    });

    it('does not wrap plain values without special characters', () => {
      exportToCsv('esc', ['Plain'], [['hello']]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Plain\nhello');
    });

    it('escapes header values the same way as row values', () => {
      exportToCsv('esc', ['Name, Full', 'Age'], [['Alice', 30]]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('"Name, Full",Age\nAlice,30');
    });

    it('does not wrap empty strings', () => {
      exportToCsv('empty_str', ['Val'], [['']]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Val\n');
    });
  });

  // --- Null / undefined / type coercion ---
  describe('type coercion', () => {
    it('converts null to empty string', () => {
      exportToCsv('nulls', ['X'], [[null]]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('X\n');
    });

    it('converts undefined to empty string', () => {
      exportToCsv('undefs', ['X'], [[undefined]]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('X\n');
    });

    it('converts numbers to their string representation', () => {
      exportToCsv('nums', ['Num'], [[42]]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Num\n42');
    });

    it('converts zero to "0"', () => {
      exportToCsv('zero', ['Val'], [[0]]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Val\n0');
    });

    it('handles mixed types in a single row', () => {
      exportToCsv(
        'mixed',
        ['Name', 'Score', 'Extra', 'Missing'],
        [['Alice', 100, null, undefined]],
      );

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Name,Score,Extra,Missing\nAlice,100,,');
    });

    it('converts negative numbers correctly', () => {
      exportToCsv('neg', ['Val'], [[-5]]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Val\n-5');
    });

    it('converts decimal numbers correctly', () => {
      exportToCsv('dec', ['Val'], [[3.14]]);

      const csv = capturedBlobContent.slice(1);
      expect(csv).toBe('Val\n3.14');
    });
  });
});
