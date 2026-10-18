/* Markdown text, tables and images are rendered at build time. */
(async () => {
  "use strict";
  const blocks = [...document.querySelectorAll(".markdown-body pre > code.language-mermaid")];
  if (!blocks.length) return;
  let mermaid;
  try {
    ({ default: mermaid } = await import("https://cdn.jsdelivr.net/npm/mermaid@12.2.0/dist/mermaid.esm.min.mjs"));
    mermaid.initialize({ startOnLoad: false, securityLevel: "strict", theme: "base", fontFamily: "system-ui, sans-serif",
      themeVariables: { background: "#050d1b", primaryColor: "#142b48", primaryTextColor: "#e9edf2", primaryBorderColor: "#728fb5", lineColor: "#a4b6cc", secondaryColor: "#10243e", tertiaryColor: "#102c30", edgeLabelBackground: "#050d1b", fontSize: "12px" },
      flowchart: { htmlLabels: false, curve: "basis", padding: 16, nodeSpacing: 25, rankSpacing: 34 } });
  } catch {
    return; // Fenced Mermaid definitions remain readable without network access.
  }
  const dialog = document.getElementById("document-dialog");
  document.getElementById("close-document-dialog").addEventListener("click", () => dialog.close());
  dialog.addEventListener("click", (event) => { if (event.target === dialog) dialog.close(); });
  for (const [index, block] of blocks.entries()) {
    try {
      const { svg } = await mermaid.render(`document-diagram-${index}`, block.textContent);
      const panel = document.createElement("div");
      panel.className = "document-diagram";
      const header = document.createElement("div");
      header.className = "diagram-header";
      const label = document.createElement("span");
      label.textContent = "DIAGRAMA";
      const expand = document.createElement("button");
      expand.type = "button";
      expand.className = "text-button";
      expand.textContent = "Ampliar ↗";
      const canvas = document.createElement("div");
      canvas.className = "diagram-canvas";
      canvas.innerHTML = svg;
      canvas.querySelector("svg").setAttribute("aria-label", "Diagrama Mermaid do documento");
      expand.addEventListener("click", () => {
        document.getElementById("document-dialog-diagram").replaceChildren(canvas.querySelector("svg").cloneNode(true));
        dialog.showModal();
      });
      const details = document.createElement("details");
      const summary = document.createElement("summary");
      summary.textContent = "Código Mermaid";
      details.append(summary);
      header.append(label, expand);
      panel.append(header, canvas, details);
      const pre = block.parentElement;
      pre.replaceWith(panel);
      details.append(pre);
    } catch {
      // Keep a diagram's original code if its definition cannot be rendered.
    }
  }
  // Mermaid may change the document height after an anchor link is opened.
  if (location.hash) document.getElementById(decodeURIComponent(location.hash.slice(1)))?.scrollIntoView();
})();
