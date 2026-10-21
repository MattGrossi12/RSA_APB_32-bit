/* Static documentation: every metric and log excerpt comes from build.py. */
(() => {
  "use strict";
  const data = window.PROJECT_DATA;
  const $ = (id) => document.getElementById(id);
  const percent = (metric) => metric.percent === null ? "—" : metric.percent.toLocaleString("pt-BR", { minimumFractionDigits: 1, maximumFractionDigits: 1 });
  const element = (tag, text, className) => {
    const node = document.createElement(tag);
    if (text !== undefined) node.textContent = text;
    if (className) node.className = className;
    return node;
  };
  const normalize = (text) => text.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
  const moduleDocuments = [...data.modules, ...(data.supplementalDiagrams || [])];
  let selectedExcerpt = "reset";
  let sortKind = null;
  let sortDirection = -1;

  const mermaidReady = import("https://cdn.jsdelivr.net/npm/mermaid@12.2.0/dist/mermaid.esm.min.mjs")
    .then(({ default: mermaid }) => {
      mermaid.initialize({ startOnLoad: false, securityLevel: "strict", theme: "base", fontFamily: "system-ui, sans-serif",
        themeVariables: { background: "#050d1b", primaryColor: "#142b48", primaryTextColor: "#e9edf2", primaryBorderColor: "#728fb5", lineColor: "#a4b6cc", secondaryColor: "#10243e", tertiaryColor: "#102c30", edgeLabelBackground: "#050d1b", fontSize: "12px" },
        flowchart: { htmlLabels: false, curve: "basis", padding: 16, nodeSpacing: 25, rankSpacing: 34 } });
      return mermaid;
    }).catch(() => null);

  function createDiagrams(module) {
    return module.diagrams.map((source, index) => {
      const title = module.diagrams.length > 1 ? `${module.label} · diagrama ${index + 1}` : module.label;
      const article = element("article", undefined, "module-diagram");
      const header = element("div", undefined, "diagram-header");
      const heading = element("h4", module.diagrams.length > 1 ? `Diagrama ${index + 1}` : "Diagrama");
      const expand = element("button", "Ampliar ↗", "text-button expand-diagram");
      expand.type = "button";
      expand.disabled = true;
      expand.setAttribute("aria-label", `Ampliar ${title}`);
      const canvas = element("div", undefined, "diagram-canvas");
      canvas.setAttribute("aria-live", "polite");
      canvas.replaceChildren(element("p", "Carregando diagrama…"));
      const details = element("details", undefined, "diagram-source");
      const code = element("code", source);
      const pre = element("pre");
      pre.append(code);
      details.append(element("summary", "Código Mermaid"), pre);
      header.append(heading, expand);
      article.append(header, canvas, details);
      expand.addEventListener("click", () => {
        const svg = canvas.querySelector("svg");
        if (svg) openViewer(title, svg.cloneNode(true), expand);
      });
      return { article, canvas, expand, details, source, title };
    });
  }

  async function renderDocumentation() {
    const diagrams = [];
    $("module-diagrams").replaceChildren(...moduleDocuments.map((module) => {
      const article = element("article", undefined, "module-detail module-card");
      article.id = `module-${module.id}`;
      article.setAttribute("aria-labelledby", `${article.id}-title`);
      const meta = element("div", undefined, "module-meta");
      meta.append(element("span", module.group || "Visão geral", "pill"));
      const readme = element("a", "README ↗", "subtle-link");
      readme.href = module.documentation;
      meta.append(readme);
      const heading = element("h3", module.label);
      heading.id = `${article.id}-title`;
      article.append(meta, heading);
      if (module.name) article.append(element("code", module.name, "module-code"));
      if (module.summary) article.append(element("p", module.summary));
      if (module.highlights?.length) {
        const highlights = element("ul", undefined, "highlights");
        highlights.append(...module.highlights.map((text) => element("li", text)));
        article.append(highlights);
      }
      const moduleDiagrams = createDiagrams(module);
      const diagramList = element("div", undefined, "module-diagram-list");
      diagramList.append(...moduleDiagrams.map(({ article: diagram }) => diagram));
      diagrams.push(...moduleDiagrams);
      article.append(diagramList);
      if (module.source) {
        const source = element("a", "Arquivo SystemVerilog ↗", "subtle-link source-link");
        source.href = `${data.meta.repository}/blob/${data.meta.commit}/${module.source}`;
        article.append(source);
      }
      return article;
    }));
    const mermaid = await mermaidReady;
    if (!mermaid) {
      diagrams.forEach(({ canvas, details }) => {
        canvas.replaceChildren(element("p", "Não foi possível carregar a biblioteca de diagramas. A definição Mermaid está disponível abaixo e no README do módulo."));
        details.open = true;
      });
      return;
    }
    for (const [index, diagram] of diagrams.entries()) {
      try {
        const { svg } = await mermaid.render(`architecture-${index}`, diagram.source);
        // Mermaid renders checked project definitions under securityLevel=strict.
        diagram.canvas.innerHTML = svg;
        const rendered = diagram.canvas.querySelector("svg");
        rendered.setAttribute("role", "img");
        rendered.setAttribute("aria-label", `Diagrama de ${diagram.title}`);
        diagram.expand.disabled = false;
      } catch {
        diagram.canvas.replaceChildren(element("p", "Não foi possível renderizar o diagrama. A definição Mermaid está disponível abaixo."));
        diagram.details.open = true;
      }
    }
  }

  function renderModules() {
    const query = normalize($("module-search").value);
    const visible = moduleDocuments.filter((module) => normalize([module.name, module.label, module.group, module.summary, ...(module.highlights || [])].filter(Boolean).join(" ")).includes(query));
    moduleDocuments.forEach((module) => {
      const article = $(`module-${module.id}`);
      if (article) article.hidden = !visible.includes(module);
    });
    $("module-list").replaceChildren(...visible.map((module) => {
      const link = element("a", undefined, "module-item");
      link.href = `#module-${module.id}`;
      link.append(element("span", String(moduleDocuments.indexOf(module) + 1).padStart(2, "0"), "module-index"), element("span", module.label));
      return link;
    }));
    if (!visible.length) $("module-list").append(element("p", "Nenhum módulo encontrado.", "no-results"));
    $("module-count").textContent = `${visible.length} de ${moduleDocuments.length} blocos e visões gerais`;
  }

  function renderLogs() {
    const simulator = $("simulator").value;
    const simulation = data.simulations[simulator];
    const excerpt = simulation.excerpts.find((item) => item.id === selectedExcerpt) || simulation.excerpts[0];
    $("log-tabs").replaceChildren(...simulation.excerpts.map((item) => {
      const button = element("button", item.label);
      button.type = "button";
      button.id = `log-tab-${item.id}`;
      button.setAttribute("role", "tab");
      button.setAttribute("aria-controls", "log-panel");
      button.setAttribute("aria-selected", String(item.id === excerpt.id));
      button.tabIndex = item.id === excerpt.id ? 0 : -1;
      button.addEventListener("click", () => { selectedExcerpt = item.id; renderLogs(); $(button.id).focus({ preventScroll: true }); });
      return button;
    }));
    $("log-panel").setAttribute("aria-labelledby", `log-tab-${excerpt.id}`);
    const fragments = excerpt.text.split(/\b(PASS|FAIL)\b/g).map((text) => {
      if (text === "PASS" || text === "FAIL") return element("span", text, `log-${text.toLowerCase()}`);
      return document.createTextNode(text);
    });
    $("log-content").replaceChildren(...fragments);
    $("log-result").textContent = `${simulation.status} · ${simulation.checks} comparações · ${simulation.errors} erros`;
    $("download-log").href = `artifacts/${simulator}.log`;
    $("copy-status").textContent = "";
  }

  function progress(metric) {
    const bar = element("div", undefined, "progress");
    const fill = element("span");
    fill.style.width = `${metric.percent || 0}%`;
    bar.append(fill);
    bar.setAttribute("aria-hidden", "true");
    return bar;
  }

  function renderCoverage() {
    $("coverage-metrics").replaceChildren(...[["lines", "Linhas · LCOV"], ["branches", "Branches · LCOV"]].map(([key, label]) => {
      const metric = data.lcov[key];
      const card = element("article", undefined, "coverage-metric");
      const heading = element("div");
      const value = element("strong", percent(metric));
      value.append(element("small", "%"));
      heading.append(element("h3", label), value);
      card.append(heading, progress(metric), element("p", `${metric.covered.toLocaleString("pt-BR")} de ${metric.total.toLocaleString("pt-BR")} cobertos · ${data.lcov.files.length} arquivos RTL`));
      return card;
    }));
    const files = [...data.lcov.files];
    if (sortKind) files.sort((a, b) => sortDirection * ((a[sortKind].percent || 0) - (b[sortKind].percent || 0)));
    $("coverage-rows").replaceChildren(...files.map((file) => {
      const row = element("tr");
      const source = element("td");
      const link = element("a", file.name + " ↗");
      link.href = file.report;
      source.append(link, element("span", file.source.split("/").slice(0, -1).join("/")));
      row.append(source);
      for (const key of ["lines", "branches"]) {
        const metric = file[key];
        const cell = element("td");
        const value = element("div", undefined, "table-value" + (metric.percent < 90 ? " medium" : ""));
        value.append(element("span", percent(metric) + "%"), progress(metric));
        cell.append(value);
        row.append(cell);
      }
      row.append(element("td", `${file.lines.covered}/${file.lines.total} linhas · ${file.branches.covered}/${file.branches.total} branches`));
      return row;
    }));
    const labels = { line: "Linhas/blocos", toggle: "Toggle", branch: "Branches", expr: "Expressões", fsm_state: "Estados FSM" };
    $("native-metrics").replaceChildren(...Object.entries(data.native).map(([key, metric]) => {
      const item = element("div");
      item.append(element("strong", percent(metric) + "%"), element("span", `${labels[key] || key} · ${metric.covered}/${metric.total}`));
      return item;
    }));
  }

  const passed = Object.values(data.simulations).every((simulation) => simulation.status === "PASS" && !simulation.errors);
  $("simulation-status").textContent = passed ? "PASS · ICARUS E VERILATOR" : "FALHA NA SIMULAÇÃO";
  $("simulation-status").classList.toggle("failure", !passed);
  $("test-status").textContent = passed ? "PASS em Icarus e Verilator" : "Confira os logs de simulação";
  const date = new Intl.DateTimeFormat("pt-BR", { dateStyle: "short", timeStyle: "short", timeZone: "America/Sao_Paulo" }).format(new Date(data.meta.simulatedAt));
  $("provenance").textContent = `Simulação: ${date} (Brasília). Commit ${data.meta.commit.slice(0, 7)}${data.meta.dirty ? " (com alterações locais)" : ""}.`;
  $("module-search").addEventListener("input", renderModules);
  $("simulator").addEventListener("change", renderLogs);
  $("log-tabs").addEventListener("keydown", (event) => {
    if (!["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) return;
    event.preventDefault();
    const buttons = [...$("log-tabs").querySelectorAll("button")];
    let index = buttons.indexOf(document.activeElement);
    if (event.key === "Home") index = 0;
    else if (event.key === "End") index = buttons.length - 1;
    else index = (index + (event.key === "ArrowRight" ? 1 : -1) + buttons.length) % buttons.length;
    buttons[index].click();
  });
  $("copy-log").addEventListener("click", async () => {
    try { await navigator.clipboard.writeText($("log-content").textContent); $("copy-status").textContent = "Trecho copiado."; }
    catch { $("copy-status").textContent = "Selecione o trecho no terminal e copie, ou baixe o log completo."; }
  });
  document.querySelectorAll("[data-sort]").forEach((button) => button.addEventListener("click", () => {
    sortDirection = sortKind === button.dataset.sort ? -sortDirection : -1;
    sortKind = button.dataset.sort;
    document.querySelectorAll("[data-sort]").forEach((item) => item.closest("th").removeAttribute("aria-sort"));
    button.closest("th").setAttribute("aria-sort", sortDirection === -1 ? "descending" : "ascending");
    renderCoverage();
  }));
  let viewerTrigger = null;
  function openViewer(title, content, trigger, image = false) {
    viewerTrigger = trigger || document.activeElement;
    $("dialog-title").textContent = title;
    $("dialog-diagram").replaceChildren(content);
    $("diagram-dialog").classList.toggle("image-viewer", image);
    $("diagram-dialog").showModal();
    $("close-dialog").focus({ preventScroll: true });
  }
  document.addEventListener("click", (event) => {
    const link = event.target.closest("a.project-image-link");
    if (!link || event.button !== 0 || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
    if (typeof $("diagram-dialog").showModal !== "function") return;
    event.preventDefault();
    const thumbnail = link.querySelector("img");
    const title = link.dataset.imageTitle || thumbnail?.alt || "Imagem do projeto";
    const content = element("div", undefined, "dialog-image-content");
    const image = element("img", undefined, "dialog-image");
    image.src = link.href;
    image.alt = thumbnail?.alt || title;
    image.decoding = "async";
    const original = element("a", "Abrir imagem original ↗", "dialog-original-link");
    original.href = link.href;
    original.target = "_blank";
    original.rel = "noopener noreferrer";
    content.append(image, original);
    openViewer(title, content, link, true);
  });
  $("close-dialog").addEventListener("click", () => $("diagram-dialog").close());
  $("diagram-dialog").addEventListener("click", (event) => { if (event.target === $("diagram-dialog")) $("diagram-dialog").close(); });
  $("diagram-dialog").addEventListener("close", () => {
    if (viewerTrigger?.isConnected) viewerTrigger.focus({ preventScroll: true });
    viewerTrigger = null;
  });
  const sectionObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => { if (entry.isIntersecting) document.querySelectorAll(".side-nav a").forEach((link) => link.classList.toggle("active", link.hash === `#${entry.target.id}`)); });
  }, { rootMargin: "-10% 0px -65% 0px" });
  document.querySelectorAll(".section-anchor").forEach((section) => sectionObserver.observe(section));
  $("module-docs").replaceChildren(...data.modules.map((module) => {
    const link = element("a", module.name + " ↗");
    link.href = module.documentation;
    return link;
  }));
  $("scripts-folder").href = `${data.meta.repository}/tree/${data.meta.commit}/scripts`;
  renderDocumentation();
  renderModules();
  renderLogs();
  renderCoverage();
})();
