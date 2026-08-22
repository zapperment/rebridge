#!/usr/bin/env node

// Extracts the labels a Combinator patch gives its rotaries and buttons and
// writes them to a Lua file that is bundled into the remote codec.
//
// Reason reports nothing but "Rotary 1" ... "Button 16" for a Combinator over
// Remote, so the labels the patch author wrote on the front panel never reach
// the control surface. They are, however, stored in the patch file, and a remote
// codec can look them up by patch name as long as somebody has read the files
// beforehand — which is what this script is for.
//
// Usage:
//   node scripts/extractCombinatorLabels.js [options] [directory ...]
//
//   --out <file>   where to write the Lua file
//                  (default: src/config/combinatorLabels.lua)
//   --quiet        only report warnings and errors
//   --self-test    parse the example patch in the repository and check the
//                  labels come out as expected, without writing anything
//
// With no directory given, the directories are taken from PATH_REASON_COMBI_*
// in .env (see .env.example).

const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const defaultOutFile = path.join(repoRoot, "src", "config", "combinatorLabels.lua");
// a patch that labels enough of its slots to cover both kinds of control, the
// rotary numbers that run into two digits, and the boundary between the two
const examplePatch = path.join(__dirname, "fixtures", "combi-patch-example.cmb");

// --- the patch file format -------------------------------------------------
//
// A .cmb file is an IFF file: chunks of a four byte id, a four byte big endian
// length and that many bytes of content, padded to an even length. The outermost
// chunk is a FORM of type PTCH holding the Combinator, whose own BODY is the
// last chunk in it — the devices it contains come earlier, each in a FORM PTCH
// of its own.

const CHUNK_HEADER_SIZE = 8;
// the Combinator has 32 rotaries and 32 buttons over Remote, and stores one
// label slot for each of them, the rotaries first
const LABEL_SLOTS = 64;
const ROTARY_SLOTS = 32;
// no Combinator label is anywhere near this long; a length beyond it means the
// bytes are being read as something they are not
const MAX_LABEL_LENGTH = 256;

function readString(buf, offset) {
  const length = buf.readUInt32BE(offset);
  if (length > MAX_LABEL_LENGTH || offset + 4 + length > buf.length) {
    throw new Error(`implausible string length ${length} at offset ${offset}`);
  }
  const start = offset + 4;
  return [buf.toString("utf8", start, start + length), start + length];
}

function* chunks(buf, offset, end) {
  while (offset + CHUNK_HEADER_SIZE <= end) {
    const id = buf.toString("latin1", offset, offset + 4);
    const length = buf.readUInt32BE(offset + 4);
    const content = offset + CHUNK_HEADER_SIZE;
    if (content + length > end) {
      return;
    }
    yield { id, content, length };
    offset = content + length + (length % 2);
  }
}

// The chunks of the Combinator itself, i.e. those directly inside the outermost
// FORM PTCH.
function* topLevelChunks(buf) {
  if (buf.toString("latin1", 0, 4) !== "FORM" || buf.toString("latin1", 8, 12) !== "PTCH") {
    throw new Error("not a Reason patch: expected a FORM chunk of type PTCH");
  }
  const end = Math.min(CHUNK_HEADER_SIZE + buf.readUInt32BE(4), buf.length);
  // 12, not 8: the four bytes after the header hold the FORM's type
  yield* chunks(buf, 12, end);
}

// The name the Combinator device goes by in the rack, from the patch's DESC
// chunk. Only used as a fallback for patches Reason reports under a name other
// than their file name, so a DESC in a layout this does not know about is not
// worth failing over.
function readDeviceName(buf, desc) {
  // "bc 01" identifies the layout, the four bytes after it are of no interest
  // here; devices inside the Combinator use "bc 02", which has extra fields
  if (buf.readUInt16BE(desc.content) !== 0xbc01) {
    return null;
  }
  try {
    return readString(buf, desc.content + 6)[0].trim() || null;
  } catch {
    return null;
  }
}

// Reads the table of front panel labels at the given offset, which is expected
// to hold one entry per label slot: the slot number, a flag that is set on the
// slots the patch author renamed, and the label itself. Two more labels follow
// the table, for the pitch bend and modulation wheels.
//
// Returns null if the bytes at the offset are not such a table, as the marker it
// is found by is not unique within the Combinator's BODY.
function readLabelTable(buf, offset) {
  try {
    // the five byte marker, then the number of slots
    let position = offset + 5;
    if (buf.readUInt32BE(position) !== LABEL_SLOTS) {
      return null;
    }
    position += 4;
    const labels = new Map();
    for (let slot = 0; slot < LABEL_SLOTS; slot += 1) {
      const number = buf.readUInt32BE(position);
      // the slots come in order, so anything else means these are not the bytes
      // we are looking for
      if (number !== slot + 1) {
        return null;
      }
      // position + 4 holds the renamed flag, which the codec does not need: a
      // label that matches what Reason reports anyway is dropped below
      position += 5;
      const [label, next] = readString(buf, position);
      labels.set(number, label);
      position = next;
    }
    // the wheels are not part of the table, and are read only to confirm that
    // the table ended where it was expected to
    readString(buf, readString(buf, position)[1]);
    return labels;
  } catch {
    return null;
  }
}

// The remote parameter a label slot belongs to, as Reason names it — which is
// also the name the control surface shows while there is no label for it.
function paramName(slot) {
  return slot <= ROTARY_SLOTS ? `Rotary ${slot}` : `Button ${slot - ROTARY_SLOTS}`;
}

// The labels of a single patch file, keyed by remote parameter name. Slots the
// patch left alone are left out: their label is what Reason reports for the
// parameter anyway, so storing it would only make the Lua file bigger.
function readPatch(file) {
  const buf = fs.readFileSync(file);
  let deviceName = null;
  let body = null;
  for (const chunk of topLevelChunks(buf)) {
    if (chunk.id === "DESC") {
      deviceName = readDeviceName(buf, chunk);
    } else if (chunk.id === "BODY") {
      body = chunk;
    }
  }
  if (!body) {
    throw new Error("no BODY chunk: the file does not hold a Combinator");
  }
  const end = body.content + body.length;
  const marker = Buffer.from([0xbc, 0x02, 0x00, 0x00, 0x00]);
  let labels = null;
  for (let at = buf.indexOf(marker, body.content); at >= 0 && at < end; at = buf.indexOf(marker, at + 1)) {
    labels = readLabelTable(buf, at);
    if (labels) {
      break;
    }
  }
  if (!labels) {
    throw new Error("no label table found in the Combinator's BODY chunk");
  }
  const params = {};
  let count = 0;
  for (const [slot, label] of labels) {
    const trimmed = label.trim();
    if (trimmed && trimmed !== paramName(slot)) {
      params[paramName(slot)] = trimmed;
      count += 1;
    }
  }
  return { deviceName, params, count };
}

// --- collecting patches ----------------------------------------------------

function findPatches(dir) {
  const found = [];
  const pending = [dir];
  while (pending.length > 0) {
    const current = pending.pop();
    let entries;
    try {
      entries = fs.readdirSync(current, { withFileTypes: true });
    } catch (error) {
      warn(`cannot read ${current}: ${error.message}`);
      continue;
    }
    for (const entry of entries) {
      const full = path.join(current, entry.name);
      // isDirectory() is false for a symlink, so symlinked directories are not
      // followed and the walk cannot end up in a loop
      if (entry.isDirectory()) {
        pending.push(full);
      } else if (entry.isFile() && entry.name.toLowerCase().endsWith(".cmb")) {
        found.push(full);
      }
    }
  }
  return found.sort();
}

// The name Reason reports for a patch loaded from a file, which is the file name
// without its extension.
function patchNameOf(file) {
  return path.basename(file, path.extname(file));
}

function sameLabels(a, b) {
  const keys = Object.keys(a);
  return keys.length === Object.keys(b).length && keys.every((key) => a[key] === b[key]);
}

// Collects the patches of the given directories: their labels, keyed by the
// patch name Reason reports for them, and the device names to fall back on where
// a patch calls its device something other than the patch.
function collect(dirs, options) {
  const patches = new Map();
  const aliases = new Map();
  let patchCount = 0;
  let labelledCount = 0;

  for (const dir of dirs) {
    for (const file of findPatches(dir)) {
      patchCount += 1;
      let patch;
      try {
        patch = readPatch(file);
      } catch (error) {
        warn(`skipping ${file}: ${error.message}`);
        continue;
      }
      if (patch.count === 0) {
        options.log(`no labels: ${file}`);
        continue;
      }
      labelledCount += 1;
      options.log(`${patch.count} label(s): ${file}`);
      const name = patchNameOf(file);
      const existing = patches.get(name);
      if (existing && !sameLabels(existing.params, patch.params)) {
        warn(
          `"${name}" is the name of two patches with different labels, ` +
          `keeping the ones from ${existing.file} and ignoring those from ${file}`
        );
      } else if (!existing) {
        patches.set(name, { file, params: patch.params });
      }
      if (patch.deviceName && patch.deviceName !== name && !aliases.has(patch.deviceName)) {
        aliases.set(patch.deviceName, { name, file });
      }
    }
  }

  // an alias is only worth keeping while it still leads to the labels of the
  // patch it was taken from: a device name that is a patch name in its own right
  // has to give way, as the patch name is what Reason reports, and one whose
  // patch lost a name clash would lead to another patch's labels
  for (const [deviceName, alias] of [...aliases]) {
    const patch = patches.get(alias.name);
    if (patches.has(deviceName) || !patch || patch.file !== alias.file) {
      aliases.delete(deviceName);
    }
  }
  return { patches, aliases, patchCount, labelledCount };
}

// --- writing the Lua file --------------------------------------------------

function luaString(value) {
  const escaped = value
    .replace(/\\/g, "\\\\")
    .replace(/"/g, '\\"')
    // control characters would end the string or break the file
    .replace(/[\n\r\t]/g, (character) => ({ "\n": "\\n", "\r": "\\r", "\t": "\\t" })[character])
    .replace(/[\x00-\x1f\x7f]/g, (character) => `\\${character.charCodeAt(0)}`);
  return `"${escaped}"`;
}

// Keeps the parameters of a patch in the order the Combinator itself has them,
// rather than the order their names happen to sort in, which would put "Rotary
// 10" between "Rotary 1" and "Rotary 2".
function byParamOrder(a, b) {
  const slotOf = (param) => {
    const [, kind, number] = param.match(/^(Rotary|Button) (\d+)$/);
    return (kind === "Rotary" ? 0 : ROTARY_SLOTS) + Number(number);
  };
  return slotOf(a) - slotOf(b);
}

function renderLua(patches, aliases = new Map()) {
  const lines = [
    "-- GENERATED FILE, DO NOT EDIT",
    "--",
    "-- Written by scripts/extractCombinatorLabels.js, which reads the labels out of",
    "-- Combinator patch files; run `yarn extract:combi` to bring it up to date.",
    "--",
    "-- The labels a Combinator patch writes on its front panel, keyed by the name",
    "-- Reason reports for the patch and then by the remote parameter the label",
    "-- belongs to. Reason reports nothing but \"Rotary 1\" ... \"Button 16\" for a",
    "-- Combinator, so this is the only way the labels can reach the control surface",
    "-- (see src/lib/display/getDisplayName.lua). Slots the patch left at their",
    "-- default are left out, as those already show the right thing.",
    "local labels = {}",
    "",
  ];
  for (const name of [...patches.keys()].sort()) {
    const { params } = patches.get(name);
    lines.push(`labels[${luaString(name)}] = {`);
    for (const param of Object.keys(params).sort(byParamOrder)) {
      lines.push(`  [${luaString(param)}] = ${luaString(params[param])},`);
    }
    lines.push("}", "");
  }
  if (aliases.size > 0) {
    lines.push(
      "-- the names these patches give the Combinator in the rack, to fall back on",
      "-- when Reason reports no patch name for it"
    );
    for (const name of [...aliases.keys()].sort()) {
      lines.push(`labels[${luaString(name)}] = labels[${luaString(aliases.get(name).name)}]`);
    }
    lines.push("");
  }
  lines.push("return labels", "");
  return lines.join("\n");
}

// --- .env ------------------------------------------------------------------

// The directories to search, from the PATH_REASON_COMBI_* entries of .env, in
// the same way as build.sh and sync.sh take their target directories from it.
function dirsFromEnv() {
  const envFile = path.join(repoRoot, ".env");
  if (!fs.existsSync(envFile)) {
    return [];
  }
  const dirs = [];
  for (const line of fs.readFileSync(envFile, "utf8").split("\n")) {
    const match = line.match(/^\s*PATH_REASON_COMBI_[A-Za-z0-9_]*\s*=\s*(.*?)\s*$/);
    if (!match) {
      continue;
    }
    const value = match[1].replace(/^"(.*)"$/, "$1").replace(/^'(.*)'$/, "$1");
    if (value) {
      dirs.push(value.replace(/^~(?=\/|$)/, process.env.HOME || "~"));
    }
  }
  return dirs;
}

// --- command line ----------------------------------------------------------

let warningCount = 0;

function warn(message) {
  warningCount += 1;
  console.warn(`Warning: ${message}`);
}

function parseArgs(argv) {
  const options = { out: defaultOutFile, quiet: false, selfTest: false, dirs: [] };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--out") {
      i += 1;
      if (i >= argv.length) {
        throw new Error("--out needs a file name");
      }
      options.out = path.resolve(argv[i]);
    } else if (arg === "--quiet") {
      options.quiet = true;
    } else if (arg === "--self-test") {
      options.selfTest = true;
    } else if (arg.startsWith("-")) {
      throw new Error(`unknown option "${arg}"`);
    } else {
      options.dirs.push(arg);
    }
  }
  options.log = options.quiet ? () => {} : (message) => console.log(message);
  return options;
}

// Checks the parsing against the example patch in the repository, so that a
// change to it can be caught without a Reason installation to hand.
function selfTest() {
  const expected = {
    "Rotary 1": "Ch. 1 Vol.",
    "Rotary 2": "Ch. 2 Vol.",
    "Rotary 3": "Ch. 3 Vol.",
    "Rotary 4": "Ch. 4 Vol.",
    "Rotary 5": "Ch. 5 Vol.",
    "Rotary 6": "Ch. 6 Vol.",
    "Rotary 7": "Ch. 7 Vol.",
    "Rotary 8": "Ch. 8 Vol.",
    "Rotary 9": "Pattern",
    "Rotary 10": "Chop",
    "Rotary 11": "Delay",
    "Rotary 12": "Reverb",
    "Rotary 13": "Compressor",
    "Rotary 14": "Clean",
    "Rotary 15": "DUMMY 13",
    "Button 1": "Ch. 1 On",
    "Button 2": "Ch. 2 On",
    "Button 3": "Ch. 3 On",
    "Button 4": "Ch. 4 On",
    "Button 5": "Ch. 5 On",
    "Button 6": "Ch. 6 On",
    "Button 7": "Ch. 7 On",
    "Button 8": "Ch. 8 On",
    "Button 9": "Rev. to Comp.",
  };
  let patch;
  try {
    patch = readPatch(examplePatch);
  } catch (error) {
    console.error(`Self test: failed, cannot read ${path.relative(repoRoot, examplePatch)}`);
    console.error(`  ${error.message}`);
    return 1;
  }
  if (!sameLabels(patch.params, expected)) {
    console.error("Self test: failed");
    console.error(`  expected: ${JSON.stringify(expected, null, 2)}`);
    console.error(`  actual:   ${JSON.stringify(patch.params, null, 2)}`);
    return 1;
  }
  if (patch.deviceName !== "Bent Beat [UCLUB]") {
    console.error(`Self test: failed, device name is "${patch.deviceName}"`);
    return 1;
  }
  const lua = renderLua(new Map([[patchNameOf(examplePatch), { params: patch.params }]]));
  // the last of the rotaries and the first of the buttons, so that the order the
  // slots are rendered in is checked across the boundary between the two
  if (!lua.includes('["Rotary 15"] = "DUMMY 13",\n  ["Button 1"] = "Ch. 1 On",')) {
    console.error("Self test: failed, the rendered Lua does not hold the labels in order");
    return 1;
  }
  console.log("Self test: success");
  return 0;
}

function main(argv) {
  let options;
  try {
    options = parseArgs(argv);
  } catch (error) {
    console.error(`Error: ${error.message}`);
    return 1;
  }
  if (options.selfTest) {
    return selfTest();
  }
  const dirs = options.dirs.length > 0 ? options.dirs : dirsFromEnv();
  if (dirs.length === 0) {
    console.error(
      "Error: no directory to search. Pass one on the command line, or set " +
      "PATH_REASON_COMBI_PATCHES in .env (see .env.example)."
    );
    return 1;
  }
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      console.error(`Error: ${dir} does not exist`);
      return 1;
    }
    options.log(`Searching: ${dir}`);
  }
  const { patches, aliases, patchCount, labelledCount } = collect(dirs, options);
  fs.writeFileSync(options.out, renderLua(patches, aliases), "utf8");
  console.log(
    `Extract: ${labelledCount} of ${patchCount} patch(es) have labels, ` +
    `written to ${path.relative(repoRoot, options.out)} ` +
    `(${patches.size} patch name(s), ${aliases.size} device name(s))`
  );
  if (warningCount > 0) {
    console.log(`Extract: success, with ${warningCount} warning(s)`);
  } else {
    console.log("Extract: success");
  }
  return 0;
}

if (require.main === module) {
  process.exit(main(process.argv.slice(2)));
}

module.exports = { readPatch, renderLua, patchNameOf };
