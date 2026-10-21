/* Read the live public Drive XML through the official diagrams.net viewer. */
(() => {
  "use strict";
  const fileId = "1pJmIWxV6VePdHCURcpEqT6SSo5kHxkri";
  const editor = "https://app.diagrams.net/#G" + fileId + '#%7B%22pageId%22%3A%22MEHrRE8WjDQsoYR0GH0S%22%7D';
  const frame = document.getElementById("live-diagram");
  const status = document.getElementById("live-diagram-status");

  function loadDiagram() {
    const source = new URL("https://drive.google.com/uc");
    source.searchParams.set("export", "download");
    source.searchParams.set("id", fileId);
    // Query the current file when the page is opened or reloaded.
    const requestedAt = Date.now();
    source.searchParams.set("_t", String(requestedAt));
    const viewer = new URL("https://viewer.diagrams.net/");
    viewer.searchParams.set("highlight", "ffa776");
    viewer.searchParams.set("layers", "1");
    viewer.searchParams.set("nav", "1");
    viewer.searchParams.set("dark", "1");
    viewer.searchParams.set("title", "RSA_APB_DIAGRAM");
    viewer.searchParams.set("edit", editor);
    viewer.hash = "U" + encodeURIComponent(source.href);
    frame.src = viewer.href;
    status.textContent = "Última consulta: " + new Intl.DateTimeFormat("pt-BR", {
      hour: "2-digit", minute: "2-digit", second: "2-digit"
    }).format(requestedAt) + ". Use os controles do diagrama para ampliar.";
  }

  loadDiagram();
})();
