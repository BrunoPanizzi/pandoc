
export const fromFormats = ["html", "md"] as const;
export const toFormats = ["html", "md", "pdf"] as const;

export type From = (typeof fromFormats)[number];
export type To = (typeof toFormats)[number];

export type Document = From | To;

export const conversions = [
  "html-md",
  "html-pdf",
  "md-html",
  "md-pdf",
] satisfies `${From}-${To}`[];
export type Conversion = (typeof conversions)[number];

export type ConversionProps = {
  params: {
    conversion: Conversion;
  };
};

export const decodeConversion: Record<Conversion, { from: From; to: To }> = {
  "md-html": { from: "md", to: "html" },
  "md-pdf": { from: "md", to: "pdf" },
  "html-md": { from: "html", to: "md" },
  "html-pdf": { from: "html", to: "pdf" },
};

export const writable: Record<Document, boolean> = {
  html: true,
  md: true,
  pdf: false,
};

export const displayName: Record<Document, string> = {
  html: "HTML",
  md: "Markdown",
  pdf: "PDF",
};

