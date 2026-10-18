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
  let selectedModule = data.modules[0];
  let renderSequence = 0;
  let selectedExcerpt = "reset";
  let sortKind = null;
  let sortDirection = -1;
  let architectureZoom = 1;

  const mermaidReady = import("https://cdn.jsdelivr.net/npm/mermaid@12.2.0/dist/mermaid.esm.min.mjs")
    .then(({ default: mermaid }) => {
      mermaid.initialize({ startOnLoad: false, securityLevel: "strict", theme: "base", fontFamily: "system-ui, sans-serif",
        themeVariables: { background: "#050d1b", primaryColor: "#142b48", primaryTextColor: "#e9edf2", primaryBorderColor: "#728fb5", lineColor: "#a4b6cc", secondaryColor: "#10243e", tertiaryColor: "#102c30", edgeLabelBackground: "#050d1b", fontSize: "12px" },
        flowchart: { htmlLabels: false, curve: "basis", padding: 16, nodeSpacing: 25, rankSpacing: 34 } });
      return mermaid;
    }).catch(() => null);

  function zoomTopDiagram(value) {
    const svg = $("top-diagram").querySelector("svg");
    if (!svg) return;
    architectureZoom = Math.min(9, Math.max(0.1, value));
    svg.style.width = svg.viewBox.baseVal.width * architectureZoom + "px";
    svg.style.height = svg.viewBox.baseVal.height * architectureZoom + "px";
    $("top-diagram-zoom").textContent = Math.round(architectureZoom * 100) + "%";
  }

  function fitTopDiagram() {
    const frame = $("top-diagram");
    const svg = frame.querySelector("svg");
    if (!svg) return;
    const style = getComputedStyle(frame);
    zoomTopDiagram(Math.min(1, (frame.clientWidth - parseFloat(style.paddingLeft) - parseFloat(style.paddingRight)) / svg.viewBox.baseVal.width));
    frame.scrollTo(0, 0);
  }

  async function renderTopDiagram() {
    $("top-diagram-source").textContent = data.architecture.diagram;
    const mermaid = await mermaidReady;
    if (mermaid) {
      try {
        const { svg } = await mermaid.render("readme-top-architecture", data.architecture.diagram);
        $("top-diagram").innerHTML = svg;
        $("top-diagram").querySelector("svg").setAttribute("aria-label", "Arquitetura de topo do README");
        fitTopDiagram();
        zoomTopDiagram(architectureZoom * 1.8);
        for (const id of ["expand-top-diagram", "fit-top-diagram", "zoom-in-top-diagram", "zoom-out-top-diagram"]) $(id).disabled = false;
        return;
      } catch {
        // Keep the README definition available when rendering fails.
      }
    }
    $("top-diagram").replaceChildren(element("p", "Não foi possível mostrar o diagrama. Consulte o código Mermaid abaixo ou o README."));
  }

  async function renderDiagram(module) {
    const sequence = ++renderSequence;
    $("diagram").replaceChildren(element("p", "Carregando diagrama…"));
    $("expand-diagram").disabled = true;
    const mermaid = await mermaidReady;
    if (sequence !== renderSequence) return;
    if (!mermaid) {
      $("diagram").replaceChildren(element("p", "Não foi possível carregar o diagrama. O código Mermaid está abaixo e no README."));
      return;
    }
    try {
      const { svg } = await mermaid.render(`architecture-${sequence}`, module.diagrams[0]);
      if (sequence !== renderSequence) return;
      // Mermaid renders checked project definitions under securityLevel=strict.
      $("diagram").innerHTML = svg;
      $("diagram").querySelector("svg").setAttribute("aria-label", `Diagrama de ${module.name}`);
      $("expand-diagram").disabled = false;
    } catch {
      if (sequence === renderSequence) $("diagram").replaceChildren(element("p", "Não foi possível mostrar o diagrama. O código Mermaid está abaixo."));
    }
  }

  function selectModule(module) {
    selectedModule = module;
    $("module-group").textContent = module.group;
    $("module-title").textContent = module.label;
    $("module-name").textContent = module.name;
    $("module-summary").textContent = module.summary;
    $("module-highlights").replaceChildren(...module.highlights.map((text) => element("li", text)));
    $("module-readme").href = module.documentation;
    $("module-source").href = `${data.meta.repository}/blob/${data.meta.commit}/${module.source}`;
    $("diagram-source").textContent = module.diagrams[0];
    document.querySelectorAll(".module-item").forEach((button) => button.setAttribute("aria-pressed", String(button.dataset.module === module.id)));
    renderDiagram(module);
  }

  function renderModules() {
    const query = normalize($("module-search").value);
    const visible = data.modules.filter((module) => normalize(`${module.name} ${module.label} ${module.group} ${module.summary}`).includes(query));
    $("module-list").replaceChildren(...visible.map((module) => {
      const button = element("button", undefined, "module-item");
      button.type = "button";
      button.dataset.module = module.id;
      button.setAttribute("aria-pressed", String(module.id === selectedModule.id));
      button.append(element("span", String(data.modules.indexOf(module) + 1).padStart(2, "0"), "module-index"), element("span", module.label));
      button.addEventListener("click", () => selectModule(module));
      return button;
    }));
    if (!visible.length) $("module-list").append(element("p", "Nenhum módulo encontrado.", "no-results"));
    $("module-count").textContent = `${visible.length} de ${data.modules.length} módulos`;
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
  function openDiagram(container, title) {
    const svg = $(container).querySelector("svg");
    if (!svg) return;
    $("dialog-title").textContent = title;
    $("dialog-diagram").replaceChildren(svg.cloneNode(true));
    $("diagram-dialog").showModal();
  }
  $("expand-diagram").addEventListener("click", () => openDiagram("diagram", selectedModule.label));
  $("expand-top-diagram").addEventListener("click", () => openDiagram("top-diagram", "Arquitetura do RTL"));
  $("zoom-in-top-diagram").addEventListener("click", () => zoomTopDiagram(architectureZoom * 1.25));
  $("zoom-out-top-diagram").addEventListener("click", () => zoomTopDiagram(architectureZoom / 1.25));
  $("fit-top-diagram").addEventListener("click", fitTopDiagram);
  $("close-dialog").addEventListener("click", () => $("diagram-dialog").close());
  $("diagram-dialog").addEventListener("click", (event) => { if (event.target === $("diagram-dialog")) $("diagram-dialog").close(); });
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
  renderTopDiagram();
  renderModules();
  selectModule(selectedModule);
  renderLogs();
  renderCoverage();
})();
