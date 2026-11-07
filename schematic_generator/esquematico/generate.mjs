// Executa Yosys e o gerador a partir de qualquer diretorio.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
import { spawnSync } from 'node:child_process';

const here = path.dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const usage = `Uso: node generate.mjs [opcoes]
  --top <modulo>    Topo RTL, ou apb (padrao) / rsa (rsa_core)
  --out <pasta>     Saida; padrao: saida/<topo> nesta pasta
  --modulo <regex>  Desenha apenas os modulos que casam com a expressao
  --busca          Procura o melhor layout (40 tentativas por folha)
  --elab-only      Gera somente netlist.json e o log do Yosys
  --help           Mostra esta ajuda

Usa src/amba_3_apb e src/rsa32/v2. YOSYS seleciona o executavel do Yosys.
Caminhos de --out sao relativos ao diretorio de onde o comando foi chamado.`;

function fail(message) {
  console.error(`Erro: ${message}`);
  process.exit(1);
}

let top = 'apb', output, only, search = false, elabOnly = false;
for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  if (arg === '--help' || arg === '-h') {
    console.log(usage);
    process.exit(0);
  }
  if (['--top', '--out', '--modulo'].includes(arg)) {
    const value = args[++i];
    if (!value || value.startsWith('--')) fail(`falta o valor de ${arg}.`);
    if (arg === '--top') top = value;
    if (arg === '--out') output = value;
    if (arg === '--modulo') only = value;
  } else if (arg === '--busca') search = true;
  else if (arg === '--elab-only') elabOnly = true;
  else fail(`opcao desconhecida: ${arg}. Use --help.`);
}
top = ({ apb: 'amba_3_apb_rsa_apb_top', rsa: 'rsa_core' })[top] || top;
if (!/^[A-Za-z_][A-Za-z0-9_$]*$/.test(top)) fail(`nome de topo invalido: ${top}.`);
if (only) {
  try { new RegExp(only); } catch { fail(`expressao invalida em --modulo: ${only}.`); }
}
if (!elabOnly) {
  try { createRequire(import.meta.url).resolve('elkjs/lib/elk.bundled.js'); }
  catch { fail(`elkjs nao instalado. Execute npm ci em ${here}.`); }
}

const out = output ? path.resolve(output) : path.join(here, 'saida', top);
fs.mkdirSync(out, { recursive: true });
const netlist = path.join(out, 'netlist.json');
const script = path.join(out, 'elab.ys');
const quote = (s) => '"' + s.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';
fs.writeFileSync(script, `# Gerado por generate.mjs; caminhos relativos a ${here}\n` +
  `script sources.ys\nhierarchy -check -top ${top}\nscript processes.ys\nwrite_json ${quote(netlist)}\n`);

function run(command, argv) {
  const result = spawnSync(command, argv, { cwd: here, stdio: 'inherit' });
  if (result.error) fail(`nao foi possivel executar ${command}: ${result.error.message}`);
  if (result.status !== 0) process.exit(result.status || 1);
}

console.log(`Elaborando ${top}...`);
run(process.env.YOSYS || 'yosys', ['-Q', '-T', '-l', path.join(out, 'yosys.log'), script]);
if (!elabOnly) {
  const renderArgs = [path.join(here, 'schem.mjs'), netlist, out, '--base', here];
  if (search) renderArgs.push('--busca');
  if (only) renderArgs.push('--modulo', only);
  run(process.execPath, renderArgs);
}
console.log(`Saida: ${out}`);
