// schem.mjs - esquematico RTL a partir da netlist JSON do Yosys (uma folha SVG por modulo)
//
// Etapas:
//   1. le a netlist (write_json do Yosys) e, para cada modulo, monta o grafo do desenho:
//      um simbolo por celula, uma porta por pino; para cada pino de entrada descobre de onde
//      vem cada bit (net inteira, fatia, concatenacao ou constante);
//   2. da nome as constantes a partir do proprio codigo (atributo src de cada celula e enums);
//   3. posiciona e roteia com o ELK (elkjs, algoritmo layered); com --busca testa 40
//      combinacoes de opcoes por folha e fica com a de menos cruzamentos;
//   4. desenha cada folha em SVG (simbolos, fios, rotulos, carimbo) e confere o desenho
//      contra a netlist, bit a bit.
//
// Uso:
//   node schem.mjs <netlist.json> <pasta_saida> [--busca] [--modulo <regex>] [--base <pasta>]
//     --busca     procura o melhor layout de cada folha (alguns minutos) e guarda em <saida>/cfg
//     --modulo    gera so os modulos cujo nome casa com a expressao
//     --base      pasta de onde o Yosys foi rodado (para achar os .sv); padrao: pasta atual
//
// Requer Node.js 18+ e o pacote elkjs (npm install). Comentarios sem acento, como no RTL.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import ELKmod from 'elkjs/lib/elk.bundled.js';

const ELK = ELKmod.default || ELKmod;
const elk = new ELK();

// ---------------------------------------------------------------- argumentos
const args = process.argv.slice(2);
const flag = (f) => { const i = args.indexOf(f); if (i < 0) return null; const v = args[i + 1]; args.splice(i, 2); return v; };
const busca = args.includes('--busca');
if (busca) args.splice(args.indexOf('--busca'), 1);
const only = flag('--modulo');
const baseDir = path.resolve(flag('--base') || '.');
const [jsonPath, outDir] = args;
if (!jsonPath || !outDir) {
  console.error('uso: node schem.mjs <netlist.json> <pasta_saida> [--busca] [--modulo <regex>] [--base <pasta>]');
  process.exit(1);
}
const design = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
fs.mkdirSync(outDir, { recursive: true });
const here = path.dirname(fileURLToPath(import.meta.url));
const CSS = fs.readFileSync(path.join(here, 'style.css'), 'utf8');
const YOSYS = (design.creator || 'Yosys').split(' (')[0];
const HOJE = new Date().toLocaleDateString('pt-BR');

// ---------------------------------------------------------------- utilidades
const CH = 6.02; // largura de um caractere (fonte mono de 10 px)
const textW = (s, k = 1) => Math.ceil(s.length * CH * k) + 2;
const isNum = (b) => typeof b === 'number';
const keyOf = (bits) => bits.join(',');
const rng = (w) => (w > 1 ? `[${w - 1}:0]` : '');
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const r1 = (v) => Math.round(v * 10) / 10;
const isConstBits = (bits) => bits.every((b) => !isNum(b));

// nome do modulo sem o prefixo $paramod do Yosys
function baseName(m) {
  if (m.startsWith('$paramod')) return m.split('\\')[1];
  return m.replace(/^\\/, '');
}
// valores dos parametros usados na elaboracao (parameter_default_values do JSON)
function paramValues(mname) {
  const pv = design.modules[mname].parameter_default_values || {};
  const out = {};
  for (const [k, v] of Object.entries(pv)) out[k] = /^[01]+$/.test(v) && v.length <= 53 ? parseInt(v, 2) : v;
  return out;
}
// na ordem em que os parametros sao declarados no modulo
function paramText(mname) {
  const pv = paramValues(mname);
  const loc = parseSrc(design.modules[mname].attributes?.src);
  const head = loc ? srcFileLines(loc.file).slice(loc.l1 - 1, loc.l1 + 40).join('\n').split(')(')[0].split(');')[0] : '';
  const order = [...head.matchAll(/parameter\s+[^=;]*?\b([A-Za-z_]\w*)\s*=/g)].map((x) => x[1]);
  const keys = Object.keys(pv).sort((a, b) => (order.indexOf(a) + 1 || 999) - (order.indexOf(b) + 1 || 999));
  return keys.map((k) => `${k} = ${pv[k]}`).join(', ');
}

function constBigInt(bits) {
  let v = 0n;
  for (let i = bits.length - 1; i >= 0; i--) v = (v << 1n) | (bits[i] === '1' ? 1n : 0n);
  return v;
}
// constante no estilo do SystemVerilog: ate 4 bits em binario, acima disso em hexa
function fmtConst(bits) {
  const w = bits.length;
  if (bits.some((b) => b !== '0' && b !== '1')) {
    if (bits.every((b) => b === bits[0])) return `${w}'b${bits[0]}`;
    return `${w}'b` + bits.slice().reverse().join('');
  }
  if (w <= 4) return `${w}'b` + bits.slice().reverse().join('');
  let hex = constBigInt(bits).toString(16).toUpperCase();
  hex = hex.replace(/\B(?=(.{4})+$)/g, '_');
  return `${w}'h${hex}`;
}

// ---------------------------------------------------------------- codigo-fonte
// O Yosys guarda em cada celula o trecho do codigo que a gerou (atributo src).
const srcCache = new Map();
function srcFileLines(file) {
  if (!srcCache.has(file)) {
    let p = path.resolve(baseDir, file);
    if (!fs.existsSync(p)) p = path.join(baseDir, path.basename(file));
    const txt = fs.existsSync(p) ? fs.readFileSync(p, 'utf8').replace(/\r/g, '') : '';
    srcCache.set(file, txt.split('\n'));
  }
  return srcCache.get(file);
}
function parseSrc(s) {
  if (!s) return null;
  const first = s.split('|')[0];
  const m = first.match(/^(.*):(\d+)\.(\d+)-(\d+)\.(\d+)$/);
  if (!m) return null;
  return { file: m[1], l1: +m[2], c1: +m[3], l2: +m[4], c2: +m[5], short: `${path.basename(m[1])}:${m[2]}` };
}
function srcText(loc) {
  const L = srcFileLines(loc.file);
  if (loc.l1 === loc.l2) return (L[loc.l1 - 1] || '').slice(loc.c1 - 1, loc.c2 - 1);
  let t = (L[loc.l1 - 1] || '').slice(loc.c1 - 1);
  for (let l = loc.l1 + 1; l < loc.l2; l++) t += '\n' + (L[l - 1] || '');
  return t + '\n' + (L[loc.l2 - 1] || '').slice(0, loc.c2 - 1);
}
function trimParens(t) {
  t = t.trim();
  const bal = (x) => [...x].reduce((a, ch) => a + (ch === '(') - (ch === ')'), 0);
  while (t.startsWith('(') && bal(t) > 0) t = t.slice(1).trim();
  while (t.endsWith(')') && bal(t) < 0) t = t.slice(0, -1).trim();
  return t;
}
// rotulo do item de case logo depois da posicao (o src dos comparadores _CMP do proc_mux
// aponta para o fim do item anterior)
function caseLabelAfter(loc) {
  const L = srcFileLines(loc.file);
  let text = (L[loc.l1 - 1] || '').slice(loc.c1 - 1);
  for (let l = loc.l1 + 1; l <= Math.min(L.length, loc.l1 + 12); l++) text += '\n' + L[l - 1];
  text = text.replace(/\/\/[^\n]*/g, '');
  const m = text.match(/(?:^|[;\s])([A-Za-z_][A-Za-z0-9_]*|\d+'[sS]?[bdhoBDHO][0-9a-fA-F_]+)\s*:(?!:)/);
  if (!m || m[1] === 'default' || m[1] === 'begin') return null;
  return m[1];
}
// localparams do modulo: (largura, valor) -> nome, para rotular constantes largas
function moduleLocalparams(mname) {
  const mod = design.modules[mname];
  const loc = parseSrc(mod.attributes?.src);
  if (!loc) return [];
  const pv = paramValues(mname);
  const L = srcFileLines(loc.file).slice(loc.l1 - 1, loc.l2);
  const out = [];
  const re = /localparam\s+(?:logic\s*)?(?:\[([^\]]*)\]\s*)?([A-Za-z_]\w*)\s*=\s*([^;]+);/;
  for (const line of L) {
    const m = line.match(re);
    if (!m) continue;
    let width = null;
    if (m[1]) {
      let hi = m[1].split(':')[0];
      for (const [k, v] of Object.entries(pv)) hi = hi.replace(new RegExp(`\\b${k}\\b`, 'g'), String(v));
      if (/^[\d\s+\-*()]+$/.test(hi)) width = Function(`return (${hi})`)() + 1;
    }
    const v = m[3].trim();
    const mm = v.match(/^(\d+)'[sS]?([bdhBDH])([0-9a-fA-F_]+)$/);
    let value = null;
    if (mm) {
      width = width ?? +mm[1];
      const radix = { b: 2, d: 10, h: 16 }[mm[2].toLowerCase()];
      value = BigInt(parseInt(mm[3].replace(/_/g, ''), radix));
    } else if (/^\d+$/.test(v)) value = BigInt(v);
    if (width != null && value != null) out.push({ name: m[2], width, value });
  }
  return out;
}

// ---------------------------------------------------------------- simbolos
// Cada simbolo: largura, altura e portas {nome: {lado, x, y, sentido}}.
function cellSymbol(cell, annots) {
  const t = cell.type;
  const P = (side, x, y, dir) => ({ side, x, y, dir });
  const cw = (n) => (cell.parameters[n] ? parseInt(cell.parameters[n], 2) : 0);
  if (['$and', '$or', '$xor', '$xnor', '$logic_and', '$logic_or'].includes(t))
    return { kind: 'gate', w: 42, h: 30, ports: { A: P('W', 0, 8, 'in'), B: P('W', 0, 22, 'in'), Y: P('E', 42, 15, 'out') } };
  if (t === '$not' || (t === '$logic_not' && cw('A_WIDTH') === 1))
    return { kind: 'not', w: 36, h: 22, ports: { A: P('W', 0, 11, 'in'), Y: P('E', 36, 11, 'out') } };
  if (['$logic_not', '$reduce_bool', '$reduce_or', '$reduce_and', '$reduce_xor'].includes(t))
    return { kind: 'op1', w: 40, h: 30, ports: { A: P('W', 0, 15, 'in'), Y: P('E', 40, 15, 'out') } };
  if (['$eq', '$ne', '$lt', '$le', '$gt', '$ge', '$add', '$sub', '$mul', '$shl', '$shr'].includes(t))
    return { kind: 'op2', w: 40, h: 40, ports: { A: P('W', 0, 11, 'in'), B: P('W', 0, 29, 'in'), Y: P('E', 40, 20, 'out') } };
  if (t === '$mux')
    return { kind: 'mux', w: 32, h: 52, ports: { A: P('W', 0, 15, 'in'), B: P('W', 0, 37, 'in'), S: P('S', 16, 52, 'in'), Y: P('E', 32, 26, 'out') } };
  if (t === '$pmux') {
    // mux de case: dflt, depois um par (d_i, s_i) por item, todos do lado esquerdo
    const n = cw('S_WIDTH');
    const h = 18 + (1 + 2 * n) * 12 + 6;
    const ports = { A: P('W', 0, 18, 'in') };
    for (let i = 0; i < n; i++) {
      ports['B' + i] = P('W', 0, 18 + 12 * (1 + 2 * i), 'in');
      ports['S' + i] = P('W', 0, 18 + 12 * (2 + 2 * i), 'in');
    }
    const maxA = Math.max(0, ...(annots || []).map((a) => (a ? a.length : 0)));
    const w = Math.max(54, Math.ceil(24 + (4 + maxA) * 5.15 + 10));
    ports.Y = P('E', w, Math.round(h / 2), 'out');
    return { kind: 'pmux', w, h, ports, n, annots };
  }
  if (t === '$dff' || t === '$adff')
    return {
      kind: t === '$adff' ? 'adff' : 'dff', w: 60, h: 56,
      ports: { D: P('W', 0, 16, 'in'), CLK: P('W', 0, 40, 'in'), Q: P('E', 60, 16, 'out'), ...(t === '$adff' ? { ARST: P('S', 30, 56, 'in') } : {}) },
    };
  // instancia de submodulo
  const sub = design.modules[t];
  if (sub) {
    const ins = Object.entries(sub.ports).filter(([, p]) => p.direction === 'input');
    const outs = Object.entries(sub.ports).filter(([, p]) => p.direction === 'output');
    const pl = ([n, p]) => n + rng(p.bits.length);
    const maxIn = Math.max(0, ...ins.map((x) => pl(x).length));
    const maxOut = Math.max(0, ...outs.map((x) => pl(x).length));
    const w = Math.max(150, Math.ceil((maxIn + maxOut) * CH) + 40, textW(baseName(t), 1.15) + 30);
    const top = 38, step = 18;
    const h = top + Math.max(ins.length, outs.length) * step + 6;
    const ports = {};
    ins.forEach(([n], i) => (ports[n] = P('W', 0, top + i * step + 6, 'in')));
    outs.forEach(([n], i) => (ports[n] = P('E', w, top + i * step + 6, 'out')));
    return { kind: 'inst', w, h, ports, ins, outs };
  }
  // qualquer outra celula: caixa generica
  const conns = Object.keys(cell.connections);
  const ins = conns.filter((p) => cell.port_directions[p] !== 'output');
  const outs = conns.filter((p) => cell.port_directions[p] === 'output');
  const h = 24 + Math.max(ins.length, outs.length) * 16;
  const ports = {};
  ins.forEach((n, i) => (ports[n] = P('W', 0, 24 + i * 16, 'in')));
  outs.forEach((n, i) => (ports[n] = P('E', 70, 24 + i * 16, 'out')));
  return { kind: 'box', w: 70, h, ports };
}

const OPTXT = {
  $eq: '==', $ne: '!=', $lt: '<', $le: '≤', $gt: '>', $ge: '≥', $add: '+', $sub: '−', $mul: '×',
  $logic_not: '== 0', $reduce_bool: '!= 0', $reduce_or: '|', $reduce_and: '&', $reduce_xor: '^', $shl: '<<', $shr: '>>',
};
const GATENAME = { $and: 'and', $or: 'or', $xor: 'xor', $xnor: 'xnor', $logic_and: 'and', $logic_or: 'or' };
const clkLike = (n) => /^(pclk(?:_[iow])?|.*_clk(?:_[iow])?|clk(?:_[iow])?)$/i.test(n);
const rstLike = (n) => /^(presetn(?:_[iow])?|.*_rst(?:_[iow])?|s?rst.*)$/i.test(n);

// ---------------------------------------------------------------- folha (grafo do desenho)
function buildSheet(mname) {
  const m = design.modules[mname];
  const nodes = [];
  const edges = [];
  const nets = [];             // {names, width, driver, sinks, cls, expr, src}
  const drvOfBit = new Map();  // bit -> {dkey, idx}
  const drv = new Map();       // dkey -> {portId, bits, netIdx, name, cell, isInput}
  const sinks = [];            // {portId, bits, cellInfo, pname, desc}

  // nomes publicos (nets com nome no RTL)
  const exact = new Map();
  const bitNames = new Map();
  for (const [nn, n] of Object.entries(m.netnames)) {
    if (n.hide_name) continue;
    const k = keyOf(n.bits);
    if (!exact.has(k)) exact.set(k, []);
    exact.get(k).push(nn);
    n.bits.forEach((b, i) => {
      if (!isNum(b)) return;
      if (!bitNames.has(b)) bitNames.set(b, []);
      bitNames.get(b).push({ name: nn, idx: i, width: n.bits.length });
    });
  }
  const portNames = new Set(Object.keys(m.ports));
  const lp = moduleLocalparams(mname);

  // internos antes de portas, mais curtos antes
  const orderNames = (arr) => arr.slice().sort((a, b) => (portNames.has(a) - portNames.has(b)) || a.length - b.length || a.localeCompare(b));
  function nameOfBits(bits) {
    const k = keyOf(bits);
    if (exact.has(k)) {
      const names = orderNames(exact.get(k));
      return { names, text: names[0] + rng(bits.length), exact: true };
    }
    // fatia contigua de um nome publico
    if (!isNum(bits[0])) return null;
    const cands = (bitNames.get(bits[0]) || []).filter((c) =>
      bits.every((b, i) => (bitNames.get(b) || []).some((x) => x.name === c.name && x.idx === c.idx + i)));
    if (!cands.length) return null;
    cands.sort((a, b) => (portNames.has(a.name) - portNames.has(b.name)) || a.name.length - b.name.length);
    const c = cands[0];
    const lo = c.idx, hi = c.idx + bits.length - 1;
    const text = c.width === 1 ? c.name : hi === lo ? `${c.name}[${lo}]` : `${c.name}[${hi}:${lo}]`;
    return { names: [text], text, exact: false };
  }

  let nid = 0;
  const addNode = (n) => { n.id = n.id || `n${nid++}`; nodes.push(n); return n; };
  function newNet(names, width, driverDesc, cls) {
    nets.push({ id: nets.length, names: names || [], width, driver: driverDesc, sinks: [], cls: cls || '' });
    return nets.length - 1;
  }

  // ----- enums: a constante que entra num mux de estado ou num comparador de estado
  //       ganha o nome do estado
  const enumOfKey = new Map();
  const enumOfPort = new Map();
  for (const n of Object.values(m.netnames)) {
    const ev = Object.entries(n.attributes || {}).filter(([k]) => k.startsWith('enum_value_'));
    if (!ev.length) continue;
    const map = {};
    for (const [k, v] of ev) map[k.slice('enum_value_'.length)] = v.replace(/^\\/, '');
    enumOfKey.set(keyOf(n.bits), map);
  }
  const setEnum = (cn, pn, bits, map) => {
    if (isConstBits(bits)) { if (!enumOfPort.has(`${cn}|${pn}`)) { enumOfPort.set(`${cn}|${pn}`, map); return true; } return false; }
    if (bits.every(isNum) && !enumOfKey.has(keyOf(bits))) { enumOfKey.set(keyOf(bits), map); return true; }
    return false;
  };
  for (let it = 0, changed = true; changed && it < 50; it++) {
    changed = false;
    for (const [cn, c] of Object.entries(m.cells)) {
      const C = c.connections;
      if (c.type === '$mux' || c.type === '$pmux') {
        const map = enumOfKey.get(keyOf(C.Y));
        if (!map) continue;
        changed = setEnum(cn, 'A', C.A, map) || changed;
        if (c.type === '$mux') changed = setEnum(cn, 'B', C.B, map) || changed;
        else {
          const W = parseInt(c.parameters.WIDTH, 2);
          const n = parseInt(c.parameters.S_WIDTH, 2);
          for (let i = 0; i < n; i++) changed = setEnum(cn, 'B' + i, C.B.slice(i * W, (i + 1) * W), map) || changed;
        }
      } else if (c.type === '$dff' || c.type === '$adff') {
        const map = enumOfKey.get(keyOf(C.Q));
        if (map) changed = setEnum(cn, 'D', C.D, map) || changed;
      } else if (c.type === '$eq' || c.type === '$ne') {
        const ma = enumOfKey.get(keyOf(C.A)), mb = enumOfKey.get(keyOf(C.B));
        if (ma) changed = setEnum(cn, 'B', C.B, ma) || changed;
        if (mb) changed = setEnum(cn, 'A', C.A, mb) || changed;
      }
    }
  }

  // nome simbolico da constante que entra na porta pname da celula (estado, parametro
  // escrito no codigo, item de case ou localparam)
  function constSymbol(si, bits) {
    if (!si.cellInfo) return null;
    const { cn, c } = si.cellInfo;
    const map = enumOfPort.get(`${cn}|${si.pname}`);
    if (map) {
      const v = bits.slice().reverse().join('');
      if (map[v]) return { sym: map[v] };
    }
    const loc = parseSrc(c.attributes?.src);
    if (loc && ['$eq', '$ne', '$lt', '$le', '$gt', '$ge'].includes(c.type)) {
      if (/_CMP\d*$/.test(cn)) {
        const lab = caseLabelAfter(loc);
        if (lab && /^[A-Za-z_]/.test(lab)) return { sym: lab };
      } else {
        const mm = trimParens(srcText(loc)).match(/^(.*?)\s*(==|!=|>=|<=|<|>)\s*(.*)$/s);
        if (mm) {
          const s = (si.pname === 'A' ? mm[1] : mm[3]).trim();
          if (/^[A-Za-z_]/.test(s)) return { sym: s };
        }
      }
    }
    if (bits.every((b) => b === '0' || b === '1') && bits.length >= 8) {
      const v = constBigInt(bits);
      const hits = lp.filter((x) => x.width === bits.length && x.value === v);
      if (hits.length === 1) return { sym: hits[0].name };
    }
    return null;
  }

  // anotacao de cada seletor s_i de um pmux: a constante do comparador que o aciona
  const bitDriverCell = new Map();
  for (const [cn, c] of Object.entries(m.cells))
    for (const [pn, bits] of Object.entries(c.connections))
      if (c.port_directions[pn] === 'output') bits.forEach((b, i) => isNum(b) && bitDriverCell.set(b, { cn, pn, i }));
  function selAnnot(bit) {
    const d = bitDriverCell.get(bit);
    if (!d) return null;
    const c = m.cells[d.cn];
    if (!['$eq', '$ne'].includes(c.type)) return null;
    const A = c.connections.A, B = c.connections.B;
    let cp, cbits;
    if (isConstBits(B)) { cp = 'B'; cbits = B; } else if (isConstBits(A)) { cp = 'A'; cbits = A; } else return null;
    const sy = constSymbol({ cellInfo: { cn: d.cn, c }, pname: cp }, cbits);
    return (c.type === '$ne' ? '≠' : '') + (sy ? sy.sym : fmtConst(cbits));
  }

  // ----- portas do modulo
  for (const [pn, p] of Object.entries(m.ports)) {
    // Aliases ligados diretamente a entradas (core_clk = pclk_i, por exemplo)
    // tambem precisam aparecer no desenho e no inventario de nets.
    const names = [pn, ...(exact.get(keyOf(p.bits)) || []).filter((n) => n !== pn)];
    const label = (p.direction === 'input' ? names : [pn]).map((n) => n + rng(p.bits.length)).join(' / ');
    const w = textW(label) + 18;
    if (p.direction === 'input') {
      const n = addNode({ id: `in:${pn}`, kind: 'in', w, h: 20, label, pname: pn, layer: 'FIRST', ports: [{ id: `in:${pn}.o`, side: 'E', x: w, y: 10 }] });
      const ni = newNet(names, p.bits.length, `porta de entrada ${pn}`, clkLike(pn) ? 'clk' : rstLike(pn) ? 'rst' : '');
      drv.set(`P:${pn}`, { portId: n.ports[0].id, bits: p.bits, netIdx: ni, isInput: true });
      p.bits.forEach((b, i) => isNum(b) && drvOfBit.set(b, { dkey: `P:${pn}`, idx: i }));
    } else if (p.direction === 'output') {
      const n = addNode({ id: `out:${pn}`, kind: 'out', w, h: 20, label, pname: pn, layer: 'LAST', ports: [{ id: `out:${pn}.i`, side: 'W', x: 0, y: 10 }] });
      sinks.push({ portId: n.ports[0].id, bits: p.bits, cellInfo: null, pname: pn, desc: `porta de saida ${pn}` });
    }
  }

  // ----- celulas
  for (const [cn, c] of Object.entries(m.cells)) {
    const annots = c.type === '$pmux' ? c.connections.S.map((b) => selAnnot(b)) : null;
    const sym = cellSymbol(c, annots);
    const loc = parseSrc(c.attributes?.src);
    const node = addNode({ kind: sym.kind, w: sym.w, h: sym.h, cell: cn, type: c.type, sym, params: c.parameters, src: loc?.short, ports: [] });
    // conexoes por pino desenhado (no pmux, B e S sao fatiados por item de case)
    const conn = {};
    if (c.type === '$pmux') {
      const W = parseInt(c.parameters.WIDTH, 2);
      conn.A = c.connections.A;
      conn.Y = c.connections.Y;
      for (let i = 0; i < sym.n; i++) {
        conn['B' + i] = c.connections.B.slice(i * W, (i + 1) * W);
        conn['S' + i] = [c.connections.S[i]];
      }
    } else Object.assign(conn, c.connections);
    for (const [pn, ps] of Object.entries(sym.ports)) {
      const pid = `${node.id}.${pn}`;
      const port = { id: pid, pname: pn, side: ps.side, x: ps.x, y: ps.y };
      node.ports.push(port);
      const bits = conn[pn];
      if (!bits) continue;
      const desc = `${node.kind === 'inst' ? cn : baseName(c.type).replace(/^\$/, '')}.${pn}`;
      if (ps.dir === 'out') {
        const nm = nameOfBits(bits);
        const dkey = `C:${cn}:${pn}`;
        const ncls = nm && nm.names.some(clkLike) ? 'clk' : nm && nm.names.some(rstLike) ? 'rst' : '';
        const ni = newNet(nm ? nm.names : [], bits.length, desc, ncls);
        drv.set(dkey, { portId: pid, bits, netIdx: ni, name: nm, cell: cn });
        bits.forEach((b, i) => isNum(b) && drvOfBit.set(b, { dkey, idx: i }));
        if (nm) port.label = nm.text;
      } else {
        sinks.push({ portId: pid, bits, cellInfo: { cn, c, node }, pname: pn, desc });
      }
    }
  }

  // ----- ligacoes: cada pino de entrada recebe trechos (runs) de bits
  function splitRuns(bits) {
    const runs = [];
    for (let i = 0; i < bits.length; i++) {
      const b = bits[i];
      const last = runs[runs.length - 1];
      if (!isNum(b)) {
        if (last && last.const) { last.bits.push(b); last.hi = i; continue; }
        runs.push({ const: true, bits: [b], lo: i, hi: i });
        continue;
      }
      const d = drvOfBit.get(b);
      if (!d) { // bit sem driver
        if (last && last.undriven) { last.bits.push(b); last.hi = i; continue; }
        runs.push({ undriven: true, bits: [b], lo: i, hi: i });
        continue;
      }
      if (last && !last.const && !last.undriven && last.dkey === d.dkey && d.idx === last.shi + 1) {
        last.bits.push(b); last.hi = i; last.shi = d.idx; continue;
      }
      runs.push({ dkey: d.dkey, bits: [b], lo: i, hi: i, slo: d.idx, shi: d.idx });
    }
    return runs;
  }
  let kid = 0;
  function constNode(bits, si) {
    const sym = constSymbol(si, bits);
    const val = fmtConst(bits);
    const label = sym ? `${sym.sym} = ${val}` : val;
    const w = textW(label) + 10;
    const id = `k${kid++}`;
    const n = addNode({ id, kind: 'const', w, h: 18, label, ports: [{ id: `${id}.o`, side: 'E', x: w, y: 9 }] });
    return { portId: n.ports[0].id, netIdx: newNet([label], bits.length, `constante ${label}`, 'cst') };
  }
  let eid = 0;
  const addEdge = (src, dst, net, width, bits) => edges.push({ id: `e${eid++}`, src, dst, net, width, bits });
  const portById = new Map();
  for (const n of nodes) for (const p of n.ports) portById.set(p.id, p);

  function sliceText(run) {
    const d = drv.get(run.dkey);
    const nm = nameOfBits(d.bits.slice(run.slo, run.shi + 1));
    if (nm) return nm.text;
    const base = d.name ? d.name.names[0] : '';
    const r = run.shi === run.slo ? `[${run.slo}]` : `[${run.shi}:${run.slo}]`;
    return base + r;
  }
  let jid = 0;
  const joinByKey = new Map();
  for (const si of sinks) {
    const runs = splitRuns(si.bits);
    const connectRun = (run, dstPortId, dstPort) => {
      if (run.const || run.undriven) {
        const k = constNode(run.const ? run.bits : run.bits.map(() => 'z'), si);
        addEdge(k.portId, dstPortId, k.netIdx, run.bits.length, run.bits);
        nets[k.netIdx].sinks.push(si.desc);
        return;
      }
      const d = drv.get(run.dkey);
      const full = run.slo === 0 && run.shi === d.bits.length - 1;
      addEdge(d.portId, dstPortId, d.netIdx, run.bits.length, d.bits.slice(run.slo, run.shi + 1));
      nets[d.netIdx].sinks.push(si.desc + (full ? '' : ` (${sliceText(run)})`));
      // rotulo no pino de destino: a fatia, ou o nome da net (menos clock e reset)
      if (!full) dstPort.label = sliceText(run);
      else {
        const nm = nets[d.netIdx];
        const txt = d.name ? d.name.text : d.isInput ? nm.names[0] + rng(nm.width) : null;
        if (txt && !nm.cls) dstPort.label = txt;
      }
    };
    if (runs.length === 1) {
      connectRun(runs[0], si.portId, portById.get(si.portId));
      continue;
    }
    // concatenacao: barra de juncao, MSB em cima; juncoes identicas sao compartilhadas
    const jkey = keyOf(si.bits);
    if (joinByKey.has(jkey)) {
      const J = joinByKey.get(jkey);
      addEdge(J.out, si.portId, J.net, si.bits.length, si.bits);
      nets[J.net].sinks.push(si.desc);
      continue;
    }
    const ordered = runs.slice().reverse();
    const h = ordered.length * 16 + 8;
    const id = `j${jid++}`;
    const jn = addNode({ id, kind: 'join', w: 8, h, ports: [{ id: `${id}.o`, side: 'E', x: 8, y: Math.round(h / 2) }] });
    portById.set(`${id}.o`, jn.ports[0]);
    const jNet = newNet([], si.bits.length, `concatenacao {${ordered.map((r) => (r.const ? fmtConst(r.bits) : sliceText(r))).join(', ')}}`, '');
    nets[jNet].sinks.push(si.desc);
    addEdge(`${id}.o`, si.portId, jNet, si.bits.length, si.bits);
    joinByKey.set(jkey, { out: `${id}.o`, net: jNet });
    ordered.forEach((r, i) => {
      const p = { id: `${id}.i${i}`, side: 'W', x: 0, y: 12 + i * 16 };
      jn.ports.push(p);
      portById.set(p.id, p);
      connectRun(r, p.id, p);
      if (!r.const && !p.label) p.label = sliceText(r);
    });
  }
  // sem rotulo repetido: pino de instancia ou porta de saida com o mesmo nome da net
  for (const n of nodes) {
    if (n.kind === 'inst') {
      for (const p of n.ports) if (p.label && p.label.replace(/\[.*$/, '') === p.pname) delete p.label;
    } else if (n.kind === 'out') {
      for (const p of n.ports) if (p.label && p.label.replace(/\[.*$/, '') === n.pname) delete p.label;
    }
  }
  // saidas de celula sem carga
  const used = new Set(edges.map((e) => e.src));
  const drvPorts = new Set([...drv.values()].map((d) => d.portId));
  for (const n of nodes) for (const p of n.ports) if (drvPorts.has(p.id) && !used.has(p.id) && n.kind !== 'in') p.open = true;

  // ----- expressao de cada net acionada por celula (vai para o sheets.json)
  const OPS = { $and: '&', $or: '|', $xor: '^', $xnor: '~^', $logic_and: '&&', $logic_or: '||', $eq: '==', $ne: '!=',
    $lt: '<', $le: '<=', $gt: '>', $ge: '>=', $add: '+', $sub: '-', $mul: '*' };
  function describeBits(bits, cn, c, pn, depth) {
    if (isConstBits(bits)) {
      const sy = constSymbol({ cellInfo: { cn, c }, pname: pn }, bits);
      return sy ? sy.sym : fmtConst(bits);
    }
    const parts = splitRuns(bits).slice().reverse().map((r) => {
      if (r.const) return fmtConst(r.bits);
      if (r.undriven) return '?';
      const d = drv.get(r.dkey);
      const full = r.slo === 0 && r.shi === d.bits.length - 1;
      if (d.name || d.isInput) {
        if (full) return d.name ? d.name.names[0] : nets[d.netIdx].names[0];
        const nb = nameOfBits(d.bits.slice(r.slo, r.shi + 1));
        return nb && nb.exact ? nb.names[0] : sliceText(r);
      }
      const e = depth < 2 ? exprOfCell(d.cell, depth + 1) : '…';
      return full ? `(${e})` : `(${e})[${r.shi}:${r.slo}]`;
    });
    return parts.length > 1 ? `{${parts.join(', ')}}` : parts[0];
  }
  function exprOfCell(cn, depth = 0) {
    const c = m.cells[cn];
    const a = (pn) => describeBits(c.connections[pn], cn, c, pn, depth);
    if (OPS[c.type]) return `${a('A')} ${OPS[c.type]} ${a('B')}`;
    if (c.type === '$not') return `~${a('A')}`;
    if (c.type === '$logic_not') return `!${a('A')}`;
    if (c.type === '$reduce_bool') return `|${a('A')}`;
    if (c.type === '$mux') return `${a('S')} ? ${a('B')} : ${a('A')}`;
    return baseName(c.type);
  }
  for (const d of drv.values()) {
    if (!d.cell) continue;
    const c = m.cells[d.cell];
    const loc = parseSrc(c.attributes?.src);
    if (loc) nets[d.netIdx].src = loc.short;
    if (!['$pmux', '$dff', '$adff'].includes(c.type) && !design.modules[c.type]) nets[d.netIdx].expr = exprOfCell(d.cell);
  }

  // ----- dados extras da folha
  const meta = { insts: [], instPortNet: {}, portNet: {}, enums: [], stats: {} };
  for (const n of nodes) {
    if (n.kind === 'inst') meta.insts.push({ inst: n.cell, sub: baseName(n.type) });
    for (const p of n.ports) {
      const e = edges.find((x) => x.src === p.id) || edges.find((x) => x.dst === p.id);
      if (!e) continue;
      if (n.kind === 'inst') meta.instPortNet[`${n.cell}.${p.pname}`] = e.net;
      if (n.kind === 'in' || n.kind === 'out') meta.portNet[n.pname] = e.net;
    }
  }
  for (const [nn, n] of Object.entries(m.netnames)) {
    const ev = Object.entries(n.attributes || {}).filter(([k]) => k.startsWith('enum_value_'));
    if (ev.length) meta.enums.push({ wire: nn, values: ev.map(([k, v]) => [k.slice('enum_value_'.length), v.replace(/^\\/, '')]) });
  }
  const cellsJ = Object.values(m.cells);
  const ffs = cellsJ.filter((c) => c.type === '$dff' || c.type === '$adff');
  meta.stats = {
    cells: cellsJ.filter((c) => !design.modules[c.type]).length,
    insts: cellsJ.filter((c) => design.modules[c.type]).length,
    regs: ffs.length,
    flops: ffs.reduce((a, c) => a + parseInt(c.parameters.WIDTH, 2), 0),
  };
  const msrc = parseSrc(m.attributes?.src);
  meta.file = msrc ? path.basename(msrc.file) : '';
  return { mname, nodes, edges, nets, meta, sinks, drv };
}

// ---------------------------------------------------------------- conferencia
// Refaz, a partir do grafo desenhado, os bits que chegam em cada pino e compara com a netlist.
function selfCheck(sh) {
  const m = design.modules[sh.mname];
  const err = [];
  const nodeCells = new Set(sh.nodes.filter((n) => n.cell).map((n) => n.cell));
  for (const cn of Object.keys(m.cells)) if (!nodeCells.has(cn)) err.push(`celula sem desenho: ${cn}`);
  const inEdges = new Map();
  for (const e of sh.edges) {
    if (!inEdges.has(e.dst)) inEdges.set(e.dst, []);
    inEdges.get(e.dst).push(e);
  }
  const joinOut = new Map();
  for (const n of sh.nodes) if (n.kind === 'join') joinOut.set(n.ports[0].id, n);
  function arriving(portId) {
    const es = inEdges.get(portId) || [];
    if (es.length !== 1) return null;
    const jn = joinOut.get(es[0].src);
    if (jn) {
      const parts = jn.ports.slice(1).map((p) => arriving(p.id));
      if (parts.some((x) => !x)) return null;
      return parts.reverse().flat();
    }
    return es[0].bits;
  }
  let ports = 0, bits = 0;
  for (const si of sh.sinks) {
    const got = arriving(si.portId);
    if (!got) { err.push(`pino sem uma unica ligacao: ${si.desc}`); continue; }
    if (keyOf(got) !== keyOf(si.bits)) err.push(`bits diferentes em ${si.desc}`);
    ports++;
    bits += si.bits.length;
  }
  const drvByPort = new Map([...sh.drv.values()].map((d) => [d.portId, d]));
  for (const e of sh.edges) {
    const d = drvByPort.get(e.src);
    if (d && !(',' + keyOf(d.bits) + ',').includes(',' + keyOf(e.bits) + ',')) err.push(`aresta ${e.id} com bits fora do driver`);
  }
  const texts = new Set();
  const addText = (text) => {
    texts.add(text);
    // Remove apenas a fatia final: g_stage[3][63:0] pertence a g_stage[3].
    // Indices de arrays fazem parte do proprio nome publico no JSON do Yosys.
    texts.add(text.replace(/\[[^\]]+\]$/, ''));
  };
  for (const n of sh.nodes) {
    if (n.pname) addText(n.pname);
    for (const p of n.ports) if (p.label) addText(p.label);
  }
  for (const n of sh.nets) for (const nm of n.names) addText(nm);
  for (const [nn, v] of Object.entries(m.netnames)) if (!v.hide_name && !texts.has(nn)) err.push(`net com nome sem rotulo: ${nn}`);
  const publicNets = Object.values(m.netnames).filter((v) => !v.hide_name).length;
  return { cells: Object.keys(m.cells).length, ports, bits, publicNets, errors: err };
}

// ---------------------------------------------------------------- layout (ELK)
const SIDE = { W: 'WEST', E: 'EAST', S: 'SOUTH', N: 'NORTH' };
async function layoutSheet(sh, opt = {}) {
  const g = {
    id: 'root',
    layoutOptions: {
      'elk.algorithm': 'layered',
      'elk.direction': 'RIGHT',
      'elk.edgeRouting': 'ORTHOGONAL',
      'elk.layered.spacing.nodeNodeBetweenLayers': '36',
      'elk.layered.spacing.edgeNodeBetweenLayers': '14',
      'elk.layered.spacing.edgeEdgeBetweenLayers': '7',
      'elk.spacing.nodeNode': '20',
      'elk.spacing.edgeEdge': '7',
      'elk.spacing.edgeNode': '12',
      'elk.spacing.portPort': '4',
      'elk.spacing.labelPortHorizontal': '3',
      'elk.spacing.labelPortVertical': '1',
      'elk.layered.mergeEdges': 'true',
      'elk.layered.nodePlacement.strategy': opt.np || 'NETWORK_SIMPLEX',
      'elk.layered.layering.strategy': opt.lay || 'NETWORK_SIMPLEX',
      'elk.layered.cycleBreaking.strategy': opt.cb || 'GREEDY',
      'elk.layered.crossingMinimization.strategy': 'LAYER_SWEEP',
      'elk.layered.thoroughness': String(opt.th || 30),
      'elk.randomSeed': String(opt.seed || 1),
      'elk.separateConnectedComponents': 'false',
      'elk.portLabels.placement': 'OUTSIDE',
    },
    children: sh.nodes.map((n) => ({
      id: n.id,
      width: n.w,
      height: n.h,
      layoutOptions: {
        'elk.portConstraints': 'FIXED_POS',
        ...(n.layer ? { 'elk.layered.layering.layerConstraint': n.layer } : {}),
      },
      ports: n.ports.map((p) => ({
        id: p.id, x: p.x, y: p.y, width: 0, height: 0,
        layoutOptions: { 'elk.port.side': SIDE[p.side] },
        labels: p.label ? [{ id: p.id + '#l', text: p.label, width: textW(p.label), height: 11 }] : [],
      })),
    })),
    edges: sh.edges.map((e) => ({ id: e.id, sources: [e.src], targets: [e.dst] })),
  };
  return elk.layout(g);
}
// cruzamentos entre segmentos horizontais e verticais de nets diferentes, e comprimento total
function scoreLayout(laid, sh) {
  const H = [], V = [];
  let len = 0;
  const netOf = new Map(sh.edges.map((e) => [e.id, e.net]));
  for (const e of laid.edges) {
    const n = netOf.get(e.id);
    for (const s of e.sections || []) {
      const pts = [s.startPoint, ...(s.bendPoints || []), s.endPoint];
      for (let i = 1; i < pts.length; i++) {
        const a = pts[i - 1], b = pts[i];
        len += Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
        if (Math.abs(a.y - b.y) < 0.01) H.push({ n, y: a.y, x1: Math.min(a.x, b.x), x2: Math.max(a.x, b.x) });
        else if (Math.abs(a.x - b.x) < 0.01) V.push({ n, x: a.x, y1: Math.min(a.y, b.y), y2: Math.max(a.y, b.y) });
      }
    }
  }
  let cross = 0;
  for (const h of H) for (const v of V) {
    if (h.n !== v.n && v.x > h.x1 + 0.5 && v.x < h.x2 - 0.5 && h.y > v.y1 + 0.5 && h.y < v.y2 - 0.5) cross++;
  }
  return { cross, len: Math.round(len), w: Math.round(laid.width), h: Math.round(laid.height) };
}

// ---------------------------------------------------------------- desenho (SVG)
function drawNode(n, ln) {
  const w = n.w, h = n.h;
  const o = [];
  const T = (tx, ty, s, cls = '', anchor = 'middle') => o.push(`<text class="${cls}" x="${r1(tx)}" y="${r1(ty)}" text-anchor="${anchor}">${esc(s)}</text>`);
  const attrs = n.cell ? ` data-cell="${esc(n.cell)}" data-type="${esc(n.type)}"${n.src ? ` data-src="${esc(n.src)}"` : ''}` : '';
  const inst = n.kind === 'inst' ? ` data-sub="${esc(baseName(n.type))}" data-inst="${esc(n.cell)}"` : '';
  o.push(`<g class="node k-${n.kind}" transform="translate(${r1(ln.x)},${r1(ln.y)})"${attrs}${inst}>`);
  switch (n.kind) {
    case 'in':
      o.push(`<path class="pin" d="M0,0H${w - 9}L${w},10L${w - 9},20H0Z"/>`);
      T(7, 14, n.label, 'plbl', 'start');
      break;
    case 'out':
      o.push(`<path class="pout" d="M0,0H${w - 9}L${w},10L${w - 9},20H0Z"/>`);
      T(10, 14, n.label, 'plbl', 'start');
      break;
    case 'const':
      o.push(`<rect class="const" x="0" y="0" width="${w}" height="${h}" rx="3"/>`);
      T(w / 2, 12.5, n.label, 'ctxt');
      break;
    case 'join':
      o.push(`<rect class="join" x="0" y="0" width="${w}" height="${h}" rx="1.5"/>`);
      break;
    case 'gate': {
      const g = GATENAME[n.type];
      if (g === 'and') o.push(`<path class="sym" d="M4,1H22A14,14 0 0 1 22,29H4Z"/>`);
      else {
        const back = g.startsWith('x') ? `<path class="sym nofill" d="M1,1Q9,15 1,29"/>` : '';
        o.push(`${back}<path class="sym" d="M5,1Q13,15 5,29Q28,29 38,15Q28,1 5,1Z"/>`);
      }
      if (g === 'xnor') o.push(`<circle class="sym" cx="39" cy="15" r="2.6"/>`);
      o.push(`<path class="leg" d="M0,8H${g === 'and' ? 4 : 8}M0,22H${g === 'and' ? 4 : 8}${g === 'and' ? 'M36,15H42' : 'M38,15H42'}"/>`);
      if (n.type.startsWith('$logic')) T(17, 18.5, n.type === '$logic_and' ? '&&' : '||', 'optxt');
      break;
    }
    case 'not':
      o.push(`<path class="sym" d="M3,2L25,11L3,20Z"/><circle class="sym" cx="28.5" cy="11" r="3.2"/><path class="leg" d="M0,11H3M31.7,11H36"/>`);
      break;
    case 'op1':
    case 'op2': {
      o.push(`<rect class="sym" x="2" y="1" width="${w - 4}" height="${h - 2}" rx="8"/>`);
      const t = OPTXT[n.type] || n.type.replace('$', '');
      T(w / 2, h / 2 + 4, t, t.length > 2 ? 'optxt sm' : 'optxt');
      if (n.kind === 'op2') {
        if (['$sub', '$lt', '$le', '$gt', '$ge', '$shl', '$shr'].includes(n.type)) {
          T(7, 14.5, 'a', 'pintxt', 'start');
          T(7, 32.5, 'b', 'pintxt', 'start');
        }
        o.push(`<path class="leg" d="M0,11H2M0,29H2M${w - 2},20H${w}"/>`);
      } else o.push(`<path class="leg" d="M0,15H2M${w - 2},15H${w}"/>`);
      break;
    }
    case 'mux':
      o.push(`<path class="sym" d="M2,2L30,10V42L2,50Z"/>`);
      T(8, 18.5, '0', 'pintxt', 'start');
      T(8, 40.5, '1', 'pintxt', 'start');
      o.push(`<path class="leg" d="M0,15H2M0,37H2M16,46V52M30,26H32"/>`);
      break;
    case 'pmux': {
      const sl = 8;
      o.push(`<path class="sym" d="M2,2L${w - 2},${2 + sl}V${h - 2 - sl}L2,${h - 2}Z"/>`);
      T(w / 2 + 1, 13, 'pmux', 'pintxt b', 'middle');
      for (const p of n.ports) {
        if (p.side !== 'W') continue;
        const lab = p.pname === 'A' ? 'dflt' : p.pname.startsWith('B') ? 'd' + p.pname.slice(1) : 's' + p.pname.slice(1);
        const an = p.pname.startsWith('S') ? n.sym.annots?.[+p.pname.slice(1)] : null;
        T(6, p.y + 3, lab, p.pname.startsWith('S') ? 'pintxt sel' : 'pintxt', 'start');
        if (an) T(6 + (lab.length + 1) * 5.15, p.y + 3, an, 'pintxt ann', 'start');
        o.push(`<path class="leg" d="M0,${p.y}H2"/>`);
      }
      o.push(`<path class="leg" d="M${w - 2},${Math.round(h / 2)}H${w}"/>`);
      break;
    }
    case 'dff':
    case 'adff': {
      o.push(`<rect class="sym ff" x="2" y="2" width="${w - 4}" height="${h - 4}" rx="2"/>`);
      T(7, 19.5, 'D', 'pintxt', 'start');
      T(w - 7, 19.5, 'Q', 'pintxt', 'end');
      o.push(`<path class="sym nofill" d="M2,35L8,40L2,45"/>`);
      o.push(`<path class="leg" d="M0,16H2M0,40H2M${w - 2},16H${w}"/>`);
      if (n.kind === 'adff') {
        const pol = parseInt(n.params.ARST_POLARITY, 2);
        const rv = fmtConst([...n.params.ARST_VALUE].reverse());
        o.push(pol ? `<path class="leg" d="M30,54V56"/>` : `<circle class="sym" cx="30" cy="51" r="3"/>`);
        T(30, 46, 'R', 'pintxt', 'middle');
        T(w / 2, 31, `rst=${rv}`, 'pintxt sm', 'middle');
      }
      break;
    }
    case 'inst': {
      const s = n.sym;
      o.push(`<rect class="inst" x="0" y="0" width="${w}" height="${h}" rx="4"/>`);
      o.push(`<path class="insthdr" d="M0,4A4,4 0 0 1 4,0H${w - 4}A4,4 0 0 1 ${w},4V30H0Z"/>`);
      T(w / 2, 13, n.cell, 'insttitle');
      T(w / 2, 25, baseName(n.type), 'instsub');
      for (const [pn, p] of s.ins) T(6, s.ports[pn].y + 3.5, pn + rng(p.bits.length), 'iptxt', 'start');
      for (const [pn, p] of s.outs) T(w - 6, s.ports[pn].y + 3.5, pn + rng(p.bits.length), 'iptxt', 'end');
      break;
    }
    default:
      o.push(`<rect class="sym" x="0" y="0" width="${w}" height="${h}"/>`);
      T(w / 2, 14, n.type, 'pintxt');
  }
  o.push('</g>');
  return o.join('');
}

const TBW = 560, TBH = 100;
function titleBlock(info, x0, y0) {
  // carimbo no canto inferior direito da folha
  const o = [];
  const T = (x, y, t, cls) => o.push(`<text class="${cls}" x="${x}" y="${y}">${esc(t)}</text>`);
  o.push(`<g class="tblock" transform="translate(${r1(x0)},${r1(y0)})">`);
  o.push(`<rect class="tb" x="0" y="0" width="${TBW}" height="${TBH}"/>`);
  o.push(`<path class="tbl" d="M0,28H${TBW}M0,46H${TBW}M0,64H${TBW}M0,82H${TBW}M470,0V28M260,28V46M330,82V${TBH}"/>`);
  T(10, 20, info.project, 'tb-proj');
  T(10 + textW(info.project, 1.75) + 10, 20, 'esquemático RTL elaborado', 'tb-sub');
  T(478, 11, 'folha', 'tb-k');
  T(478, 24, `${info.num} de ${info.total}`, 'tb-num');
  T(10, 41, 'módulo', 'tb-k'); T(84, 41, info.module, 'tb-v');
  T(268, 41, 'arquivo', 'tb-k'); T(318, 41, info.file, 'tb-v');
  T(10, 59, 'instância', 'tb-k'); T(84, 59, info.path, 'tb-v');
  T(10, 77, 'parâmetros', 'tb-k'); T(84, 77, info.params || 'nenhum', 'tb-v');
  const st = info.stats;
  const cont = st.insts ? `${st.insts} instâncias de submódulo`
    : st.regs ? `${st.cells} células, ${st.regs} registradores (${st.flops} bits)` : `${st.cells} células, sem registradores`;
  T(10, 95, `netlist do ${YOSYS} (proc -noopt), ${HOJE}`, 'tb-k');
  T(338, 95, cont, 'tb-k');
  o.push('</g>');
  return o.join('');
}

function renderSheet(sh, laid, info) {
  const lnodes = new Map(laid.children.map((c) => [c.id, c]));
  const meByID = new Map(sh.edges.map((e) => [e.id, e]));
  const pad = 24;
  const W = Math.max(laid.width, TBW), H = laid.height + TBH + 18;
  const ox = -pad, oy = -pad, VW = W + 2 * pad, VH = H + 2 * pad;
  const o = [];
  o.push(`<svg xmlns="http://www.w3.org/2000/svg" class="sheet" viewBox="${ox} ${oy} ${r1(VW)} ${r1(VH)}" width="${r1(VW)}" height="${r1(VH)}">`);
  o.push(`<style>${CSS}\ntext { font-family: 'IBM Plex Mono', Consolas, Menlo, 'DejaVu Sans Mono', monospace; }\n.tblock text { font-family: 'Barlow Semi Condensed', 'Arial Narrow', 'DejaVu Sans Condensed', sans-serif; }</style>`);
  o.push(`<rect class="paper" x="${ox}" y="${oy}" width="${r1(VW)}" height="${r1(VH)}"/>`);
  o.push(`<rect class="frame" x="${ox + 8}" y="${oy + 8}" width="${r1(VW - 16)}" height="${r1(VH - 16)}"/>`);
  o.push(titleBlock(info, ox + VW - 8 - TBW, oy + VH - 8 - TBH));
  // fios: classe pela largura do proprio trecho (fatia de 1 bit fica fina)
  o.push('<g class="wires">');
  for (const e of laid.edges) {
    const me = meByID.get(e.id);
    const net = sh.nets[me.net];
    const cls = ['w', me.width > 1 ? 'bus' : '', net.cls].filter(Boolean).join(' ');
    for (const s of e.sections || []) {
      const pts = [s.startPoint, ...(s.bendPoints || []), s.endPoint];
      o.push(`<path class="${cls}" data-n="${me.net}" d="M${pts.map((p) => `${r1(p.x)},${r1(p.y)}`).join('L')}"/>`);
    }
    for (const j of e.junctionPoints || []) o.push(`<circle class="jn${me.width > 1 ? ' bus' : ''}" data-n="${me.net}" cx="${r1(j.x)}" cy="${r1(j.y)}" r="${me.width > 1 ? 3 : 2.4}"/>`);
  }
  o.push('</g>');
  o.push('<g class="nodes">');
  for (const n of sh.nodes) o.push(drawNode(n, lnodes.get(n.id)));
  o.push('</g>');
  // rotulos de net, saidas abertas e largura de barramento sem nome
  o.push('<g class="labels">');
  for (const n of sh.nodes) {
    const ln = lnodes.get(n.id);
    for (const lp of ln.ports || []) {
      const p = n.ports.find((q) => q.id === lp.id);
      const X = ln.x + lp.x, Y = ln.y + lp.y;
      for (const lb of lp.labels || []) {
        const netIdx = sh.edges.find((e) => e.src === p.id || e.dst === p.id)?.net;
        o.push(`<text class="nlbl" data-n="${netIdx ?? ''}" x="${r1(X + lb.x + 1)}" y="${r1(Y + lb.y + 9)}">${esc(lb.text)}</text>`);
      }
      if (p?.open) {
        o.push(`<path class="ncx" d="M${r1(X)},${r1(Y)}H${r1(X + 9)}M${r1(X + 6)},${r1(Y - 3)}L${r1(X + 12)},${r1(Y + 3)}M${r1(X + 6)},${r1(Y + 3)}L${r1(X + 12)},${r1(Y - 3)}"/><text class="nc" x="${r1(X + 15)}" y="${r1(Y + 3)}">aberta (sem carga)</text>`);
      }
      const se = sh.edges.find((e) => e.src === lp.id);
      if (se && !(lp.labels || []).length && se.width > 1 && n.kind !== 'in' && n.kind !== 'const') {
        o.push(`<path class="wmark" d="M${r1(X + 6)},${r1(Y + 4)}L${r1(X + 11)},${r1(Y - 4)}"/><text class="wtxt" x="${r1(X + 12)}" y="${r1(Y - 4)}">${se.width}</text>`);
      }
    }
  }
  o.push('</g></svg>');
  return { svg: o.join('\n'), width: VW, height: VH, ox, oy };
}

// ---------------------------------------------------------------- principal
const cfgDir = path.join(outDir, 'cfg');
fs.mkdirSync(cfgDir, { recursive: true });
const DEFAULT_CFG = { np: 'NETWORK_SIMPLEX', lay: 'NETWORK_SIMPLEX', cb: 'DEPTH_FIRST', seed: 7, th: 40 };
// assinatura do grafo: o layout guardado so vale se o grafo for o mesmo
function signature(sh) {
  const o = sh.nodes.map((n) => [n.id, n.w, n.h, n.ports.map((p) => [p.id, p.x, p.y, p.label || ''])]);
  return crypto.createHash('sha1').update(JSON.stringify([o, sh.edges.map((e) => [e.src, e.dst])])).digest('hex').slice(0, 16);
}
async function searchBest(sh) {
  let best = null;
  for (const np of ['NETWORK_SIMPLEX', 'BRANDES_KOEPF'])
    for (const lay of ['NETWORK_SIMPLEX', 'LONGEST_PATH'])
      for (const cb of ['GREEDY', 'DEPTH_FIRST'])
        for (const seed of [1, 3, 7, 11, 19]) {
          const c = { np, lay, cb, seed, th: 40 };
          const sc = scoreLayout(await layoutSheet(sh, c), sh);
          const v = sc.cross + sc.len / 500;
          if (!best || v < best.v) best = { c, sc, v };
        }
  return best;
}

// folhas na ordem do RTL: o topo, depois cada instancia na ordem em que aparece no codigo
const TOP = Object.keys(design.modules).find((k) => design.modules[k].attributes?.top) || Object.keys(design.modules)[0];
const sheetOrder = [];
const instPath = {};
const visited = new Set();
(function walk(mn, p) {
  // Uma folha por modulo elaborado, mesmo quando ha varias instancias dele.
  if (visited.has(mn)) return;
  visited.add(mn);
  sheetOrder.push(mn);
  instPath[mn] = p;
  const kids = Object.entries(design.modules[mn].cells)
    .filter(([, c]) => design.modules[c.type])
    .map(([cn, c]) => ({ cn, t: c.type, line: parseSrc(c.attributes?.src)?.l1 ?? 0 }))
    .sort((a, b) => a.line - b.line);
  for (const k of kids) walk(k.t, `${p}/${k.cn}`);
})(TOP, baseName(TOP));

// Variantes parametrizadas podem ter o mesmo nome RTL (ex.: somadores de 32/64 bits).
// Cada variante precisa de um arquivo e de um cache de layout exclusivos.
const moduleIds = new Map(sheetOrder.map((mn) => {
  const id = baseName(mn);
  const repeated = sheetOrder.some((other) => other !== mn && baseName(other) === id);
  return [mn, repeated ? `${id}__${crypto.createHash('sha1').update(mn).digest('hex').slice(0, 8)}` : id];
}));
const selected = sheetOrder.filter((mn) => !only || new RegExp(only).test(mn));
if (!selected.length) {
  console.error(`nenhum modulo encontrado para --modulo ${only}`);
  process.exit(1);
}

const sheets = [];
let totalErr = 0;
for (const mname of selected) {
  const id = baseName(mname);
  const fileId = moduleIds.get(mname);
  const sh = buildSheet(mname);
  const sig = signature(sh);
  const cfgFile = path.join(cfgDir, `${fileId}.json`);
  let cfg = DEFAULT_CFG;
  if (busca) {
    const b = await searchBest(sh);
    cfg = b.c;
    fs.writeFileSync(cfgFile, JSON.stringify({ sig, cfg, score: b.sc }));
  } else if (fs.existsSync(cfgFile)) {
    const saved = JSON.parse(fs.readFileSync(cfgFile, 'utf8'));
    if (saved.sig === sig) cfg = saved.cfg;
    else console.log(`  ${id}: layout guardado e de outro grafo; usando o padrao (rode com --busca)`);
  }
  const laid = await layoutSheet(sh, cfg);
  const score = scoreLayout(laid, sh);
  const chk = selfCheck(sh);
  totalErr += chk.errors.length;
  const num = selected.indexOf(mname) + 1;
  const r = renderSheet(sh, laid, {
    project: baseName(TOP).toUpperCase(), num, total: selected.length, path: instPath[mname],
    module: id, file: sh.meta.file, params: paramText(mname), stats: sh.meta.stats,
  });
  const file = `${String(num).padStart(2, '0')}_${fileId}.svg`;
  fs.writeFileSync(path.join(outDir, file), r.svg);
  sheets.push({ id, mname, num, file, path: instPath[mname], params: paramText(mname), width: r.width, height: r.height, ox: r.ox, oy: r.oy,
    nets: sh.nets, cfg, score, meta: sh.meta, check: chk });
  console.log(`${file}: ${chk.cells} celulas, ${chk.ports} pinos e ${chk.bits} bits conferidos, ${score.cross} cruzamentos; erros: ${chk.errors.length}`);
  for (const e of chk.errors) console.log('    ' + e);
}
fs.writeFileSync(path.join(outDir, 'sheets.json'), JSON.stringify(sheets, null, 1));
console.log(totalErr ? `${totalErr} erro(s) na conferencia` : 'conferencia: desenho igual a netlist em todas as folhas');
if (totalErr) process.exitCode = 1;
