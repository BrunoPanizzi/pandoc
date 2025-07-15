
export const fromFormats = ["html", "markdown"] as const;
export const toFormats = ["html", "markdown", "pdf"] as const;

export type From = (typeof fromFormats)[number];
export type To = (typeof toFormats)[number];

/** Note: All document types should match pandoc's values */
export type Document = From | To;

export const conversions = [
  "html-markdown",
  "markdown-html",
] satisfies `${From}-${To}`[];
export type Conversion = (typeof conversions)[number];

export type ConversionProps = {
  params: {
    conversion: Conversion;
  };
};

export const decodeConversion: Record<Conversion, { from: From; to: To }> = {
  "markdown-html": { from: "markdown", to: "html" },
/*   "markdown-pdf": { from: "markdown", to: "pdf" }, */
  "html-markdown": { from: "html", to: "markdown" },
/*   "html-pdf": { from: "html", to: "pdf" }, */
};

export const writable: Record<Document, boolean> = {
  html: true,
  markdown: true,
  pdf: false,
};

export const displayName: Record<Document, string> = {
  html: "HTML",
  markdown: "Markdown",
  pdf: "PDF",
};


const API_URL = "http://localhost:8080";

export async function convert(
  input: string,
  from: From,
  to: To,
): Promise<string> {
  const response = await fetch(API_URL + "/convert", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      text: input,
      from,
      to,
    }),
  });

  if (!response.ok) {
    throw new Error(`Conversion failed: ${response.statusText}`);
  }

  return response.text();
}