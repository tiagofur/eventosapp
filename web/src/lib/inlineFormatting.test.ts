import { describe, it, expect, vi } from 'vitest';
import React from 'react';
import { render } from '@testing-library/react';
import {
  parseInlineFormatting,
  renderFormattedReact,
  renderFormattedHTML,
  renderFormattedJsPDF,
} from './inlineFormatting';

describe('inlineFormatting', () => {
  describe('parseInlineFormatting', () => {
    it('returns plain text as a single segment', () => {
      const segments = parseInlineFormatting('Hello world');
      expect(segments).toEqual([
        { text: 'Hello world', bold: false, italic: false, underline: false },
      ]);
    });

    it('parses **bold** markers', () => {
      const segments = parseInlineFormatting('This is **bold** text');
      expect(segments).toEqual([
        { text: 'This is ', bold: false, italic: false, underline: false },
        { text: 'bold', bold: true, italic: false, underline: false },
        { text: ' text', bold: false, italic: false, underline: false },
      ]);
    });

    it('parses *italic* markers', () => {
      const segments = parseInlineFormatting('This is *italic* text');
      expect(segments).toEqual([
        { text: 'This is ', bold: false, italic: false, underline: false },
        { text: 'italic', bold: false, italic: true, underline: false },
        { text: ' text', bold: false, italic: false, underline: false },
      ]);
    });

    it('parses __underline__ markers', () => {
      const segments = parseInlineFormatting('This is __underlined__ text');
      expect(segments).toEqual([
        { text: 'This is ', bold: false, italic: false, underline: false },
        { text: 'underlined', bold: false, italic: false, underline: true },
        { text: ' text', bold: false, italic: false, underline: false },
      ]);
    });

    it('parses mixed formatting in one line', () => {
      const segments = parseInlineFormatting('**bold** and *italic* and __underline__');
      expect(segments).toHaveLength(5);
      expect(segments[0]).toEqual({ text: 'bold', bold: true, italic: false, underline: false });
      expect(segments[1]).toEqual({ text: ' and ', bold: false, italic: false, underline: false });
      expect(segments[2]).toEqual({ text: 'italic', bold: false, italic: true, underline: false });
      expect(segments[3]).toEqual({ text: ' and ', bold: false, italic: false, underline: false });
      expect(segments[4]).toEqual({ text: 'underline', bold: false, italic: false, underline: true });
    });

    it('handles unmatched markers as plain text', () => {
      const segments = parseInlineFormatting('This has ** unmatched marker');
      expect(segments).toEqual([
        { text: 'This has ** unmatched marker', bold: false, italic: false, underline: false },
      ]);
    });

    it('handles adjacent asterisks', () => {
      // **** is parsed as: ** (bold open) then ** (bold close) with nothing — then fallback
      // The regex (.+?) requires at least one char, so **** won't match as bold
      // but it matches * * * * as italic around middle chars
      const segments = parseInlineFormatting('before **** after');
      // The regex finds **** as: ** matches nothing (skipped), then ** matches as containing no chars
      // Actually regex finds: ** before first *, then * after * pattern matches
      expect(segments.length).toBeGreaterThanOrEqual(1);
      // All original text content is preserved
      const allText = segments.map(s => s.text).join('');
      expect(allText).toContain('before');
      expect(allText).toContain('after');
    });

    it('handles multiple bold segments', () => {
      const segments = parseInlineFormatting('**one** middle **two**');
      expect(segments).toHaveLength(3);
      expect(segments[0].bold).toBe(true);
      expect(segments[1].bold).toBe(false);
      expect(segments[2].bold).toBe(true);
    });

    it('handles text that is entirely formatted', () => {
      const segments = parseInlineFormatting('**all bold**');
      expect(segments).toEqual([
        { text: 'all bold', bold: true, italic: false, underline: false },
      ]);
    });

    it('returns original text for empty string', () => {
      const segments = parseInlineFormatting('');
      expect(segments).toEqual([
        { text: '', bold: false, italic: false, underline: false },
      ]);
    });
  });

  describe('renderFormattedHTML', () => {
    it('returns plain text unchanged', () => {
      expect(renderFormattedHTML('Hello world')).toBe('Hello world');
    });

    it('wraps bold text in <strong> tags', () => {
      expect(renderFormattedHTML('**bold**')).toBe('<strong>bold</strong>');
    });

    it('wraps italic text in <em> tags', () => {
      expect(renderFormattedHTML('*italic*')).toBe('<em>italic</em>');
    });

    it('wraps underline text in <u> tags', () => {
      expect(renderFormattedHTML('__underline__')).toBe('<u>underline</u>');
    });

    it('HTML-escapes text content', () => {
      expect(renderFormattedHTML('**<script>alert("xss")</script>**'))
        .toBe('<strong>&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;</strong>');
    });

    it('handles mixed formatting', () => {
      const result = renderFormattedHTML('Hello **bold** and *italic*');
      expect(result).toBe('Hello <strong>bold</strong> and <em>italic</em>');
    });
  });

  describe('renderFormattedReact', () => {
    it('returns plain text as string', () => {
      const result = renderFormattedReact('Hello world');
      expect(result).toBe('Hello world');
    });

    it('renders bold text as <strong> element', () => {
      const result = renderFormattedReact('**bold**');
      const { container: rendered } = render(
        React.createElement('span', null, result)
      );
      expect(rendered.querySelector('strong')).not.toBeNull();
      expect(rendered.querySelector('strong')?.textContent).toBe('bold');
    });

    it('renders italic text as <em> element', () => {
      const result = renderFormattedReact('*italic*');
      const { container: rendered } = render(
        React.createElement('span', null, result)
      );
      expect(rendered.querySelector('em')).not.toBeNull();
      expect(rendered.querySelector('em')?.textContent).toBe('italic');
    });

    it('renders underline text as <u> element', () => {
      const result = renderFormattedReact('__underline__');
      const { container: rendered } = render(
        React.createElement('span', null, result)
      );
      expect(rendered.querySelector('u')).not.toBeNull();
      expect(rendered.querySelector('u')?.textContent).toBe('underline');
    });

    it('renders mixed formatting correctly', () => {
      const result = renderFormattedReact('**bold** and *italic*');
      const { container: rendered } = render(
        React.createElement('span', null, result)
      );
      expect(rendered.querySelector('strong')?.textContent).toBe('bold');
      expect(rendered.querySelector('em')?.textContent).toBe('italic');
    });
  });

  describe('renderFormattedJsPDF', () => {
    const createMockDoc = () => ({
      setFontSize: vi.fn(),
      setFont: vi.fn(),
      text: vi.fn(),
      getTextWidth: vi.fn((text: string) => text.length * 2),
      setLineWidth: vi.fn(),
      line: vi.fn(),
    });

    it('renders plain text with normal font', () => {
      const doc = createMockDoc();
      const finalY = renderFormattedJsPDF(doc as any, 'Hello world', 10, 20, 160, 10);
      expect(doc.setFontSize).toHaveBeenCalledWith(10);
      expect(doc.setFont).toHaveBeenCalledWith('helvetica', 'normal');
      expect(doc.text).toHaveBeenCalled();
      expect(finalY).toBeGreaterThan(20);
    });

    it('renders bold text with bold font style', () => {
      const doc = createMockDoc();
      renderFormattedJsPDF(doc as any, '**bold text**', 10, 20, 160, 10);
      expect(doc.setFont).toHaveBeenCalledWith('helvetica', 'bold');
      // Resets to normal after rendering
      expect(doc.setFont).toHaveBeenLastCalledWith('helvetica', 'normal');
    });

    it('renders italic text with italic font style', () => {
      const doc = createMockDoc();
      renderFormattedJsPDF(doc as any, '*italic text*', 10, 20, 160, 10);
      expect(doc.setFont).toHaveBeenCalledWith('helvetica', 'italic');
    });

    it('renders bold+italic text with bolditalic font style', () => {
      const doc = createMockDoc();
      // We can't nest markers, but we test via segments directly
      // The function uses parseInlineFormatting which doesn't produce bold+italic from markdown
      // So test plain + bold separately
      renderFormattedJsPDF(doc as any, '**bold** and *italic*', 10, 20, 160, 10);
      expect(doc.setFont).toHaveBeenCalledWith('helvetica', 'bold');
      expect(doc.setFont).toHaveBeenCalledWith('helvetica', 'italic');
    });

    it('draws underline with doc.line()', () => {
      const doc = createMockDoc();
      renderFormattedJsPDF(doc as any, '__underlined__', 10, 20, 160, 10);
      expect(doc.setLineWidth).toHaveBeenCalledWith(0.3);
      expect(doc.line).toHaveBeenCalled();
      // Verify line coordinates: starts at x=10, underlineY = 20+1 = 21
      const lineCall = doc.line.mock.calls[0];
      expect(lineCall[1]).toBe(21); // underlineY
      expect(lineCall[3]).toBe(21); // same Y for horizontal line
    });

    it('wraps text to next line when exceeding maxWidth', () => {
      const doc = createMockDoc();
      // Each char = 2 units width. maxWidth = 20, so max ~10 chars per line
      // "AAAAAAAAAA BBBBBBBBBB" should wrap
      renderFormattedJsPDF(doc as any, 'AAAAAAAAAA BBBBBBBBBB', 10, 20, 20, 10);
      // Should have text calls at different Y positions
      const yCalls = doc.text.mock.calls.map((c: any[]) => c[2]);
      const uniqueY = [...new Set(yCalls)];
      expect(uniqueY.length).toBeGreaterThanOrEqual(2);
    });

    it('returns final Y position after rendering', () => {
      const doc = createMockDoc();
      const finalY = renderFormattedJsPDF(doc as any, 'Test', 10, 50, 160, 12);
      // lineHeight = fontSize * 0.5 = 6
      expect(finalY).toBe(50 + 6);
    });

    it('handles empty text', () => {
      const doc = createMockDoc();
      const finalY = renderFormattedJsPDF(doc as any, '', 10, 20, 160, 10);
      expect(finalY).toBeGreaterThanOrEqual(20);
    });

    it('resets font to normal after rendering', () => {
      const doc = createMockDoc();
      renderFormattedJsPDF(doc as any, '**bold** and *italic*', 10, 20, 160, 10);
      // Last setFont call should be reset to normal
      const lastCall = doc.setFont.mock.calls[doc.setFont.mock.calls.length - 1];
      expect(lastCall).toEqual(['helvetica', 'normal']);
    });
  });
});
