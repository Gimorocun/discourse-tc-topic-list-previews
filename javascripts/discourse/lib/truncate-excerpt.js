export default function truncateExcerpt(html, maxLength) {
  if (!html || !maxLength || maxLength <= 0) {
    return html;
  }

  const withoutTrailingEllipsis = html
    .replace(/&hellip;$/i, "")
    .replace(/…$/u, "")
    .trim();

  const container = document.createElement("div");
  container.innerHTML = withoutTrailingEllipsis;
  const text = (container.textContent || "").trim();

  if (text.length <= maxLength) {
    return withoutTrailingEllipsis || html;
  }

  return `${text.slice(0, maxLength).trimEnd()}…`;
}
