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
//   --replace      write a fresh file rather than adding to the one that is
//                  already there
//   --self-test    parse the example patch in the repository and check the
//                  labels come out as expected, without writing anything
//
// A run adds to the file rather than replacing it, so that separate runs over
// separate directories build one file between them. A patch that is extracted
// again replaces the entry it had before; entries whose patches were not in the
// directories searched are left alone. Use --replace to start over, which is the
// only way to drop the entries of patches that have since been deleted.
//
// With no directory given, the directories are taken from PATH_REASON_COMBI_*
// in .env (see .env.example).

const fs = require("fs");
const os = require("os");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const defaultOutFile = path.join(repoRoot, "src", "config", "combinatorLabels.lua");
// a patch that labels enough of its slots to cover both kinds of control, the
// rotary numbers that run into two digits, and the boundary between the two
const examplePatch = path.join(__dirname, "fixtures", "combi-patch-example.cmb");
// a patch saved in the layout Reason used before the Combinator grew to 32
// rotaries and 32 buttons
const legacyExamplePatch = path.join(__dirname, "fixtures", "combi-patch-example2.cmb");
// a patch whose panel has been rearranged, so that the slot a label sits in is
// not the number Remote gives the parameter — the case that is silently wrong
// if the panel layout is ignored
const rearrangedExamplePatch = path.join(__dirname, "fixtures", "combi-patch-example3.cmb");
// a patch whose panel layout carries the older of the two versions the block is
// found with
const olderLayoutExamplePatch = path.join(__dirname, "fixtures", "combi-patch-example4.cmb");
// a patch whose panel carries captions beside the Combinator's own Run and
// Bypass switches, which are neither rotaries nor buttons
const captionedExamplePatch = path.join(__dirname, "fixtures", "combi-patch-example5.cmb");
// two patches that name none of their controls, one keeping five arrays of
// values in front of its labels and one keeping three: nothing to extract from
// either, but they have to be read rather than reported as unreadable
const unlabelledExamplePatches = [
  path.join(__dirname, "fixtures", "combi-patch-example6.cmb"),
  path.join(__dirname, "fixtures", "combi-patch-example7.cmb"),
];
// a patch that names its controls "Rotary 1" ... "Button 4", which is what
// Reason calls them anyway: nothing is left once those are dropped, but the
// eight of them are counted, as that is what tells this apart from a patch whose
// labels are empty
const defaultNamesExamplePatch = path.join(__dirname, "fixtures", "combi-patch-example8.cmb");
// a patch that keeps no labels for the pitch bend and modulation wheels after
// its table, so the panel layout starts where those would have been
const noWheelLabelsExamplePatch = path.join(__dirname, "fixtures", "combi-patch-example9.cmb");

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
// patches saved before the Combinator grew to 32 of each store their labels
// differently, in two arrays of four (see readLegacyLabels)
const LEGACY_SLOTS = 4;
// no Combinator label is anywhere near this long; a length beyond it means the
// bytes are being read as something they are not
const MAX_LABEL_LENGTH = 256;
// the legacy layout is found by scanning rather than by a count that identifies
// it, so its labels are held to a tighter bound to keep a run of unrelated bytes
// from being read as one
const MAX_LEGACY_LABEL_LENGTH = 64;

// Blocks within a device's BODY open with this byte, a version, and three zero
// bytes.
const MARKER_BYTE = 0xbc;
const MARKER_SIZE = 5;

function isBlockMarker(buf, offset) {
  return offset >= 0 &&
    offset + MARKER_SIZE <= buf.length &&
    buf.readUInt8(offset) === MARKER_BYTE &&
    buf.readUInt8(offset + 2) === 0 &&
    buf.readUInt8(offset + 3) === 0 &&
    buf.readUInt8(offset + 4) === 0;
}

// How many four-byte arrays of current values sit in front of a legacy patch's
// labels. Three in the oldest patches — rotary positions, button states and
// ranges — and more in later ones, which keep more per control.
const MIN_LEGACY_VALUE_ARRAYS = 3;
const MAX_LEGACY_VALUE_ARRAYS = 16;

// The panel layout that follows the label table: one record per thing on the
// Combinator's front panel, in the order Reason numbers them over Remote. The
// kind of a record decides both what it is and how long it is.
const PANEL_BUTTON = 0;
const PANEL_ROTARY = 1;
const PANEL_WHEEL = 2;
// the captions beside the Combinator's own Run and Bypass switches, which carry
// their text in the record rather than in a label slot
const PANEL_CAPTION = 3;
const PANEL_SWITCH_CAPTION = 4;
// a rotary carries one field more than a button or a wheel, and a caption
// carries the text printed on the panel, so its length depends on that text
const PANEL_RECORD_SIZE = 33;
const PANEL_ROTARY_RECORD_SIZE = 37;
// the wheels take the two slots after the table's 64
const MAX_PANEL_SLOT = 66;
// a Combinator panel holds nothing like this many controls; a count beyond it
// means the bytes are being read as something they are not
const MAX_PANEL_RECORDS = 256;

// A few bytes as hex, to say in a warning what was found where something else
// was expected.
function hex(buf, offset, length) {
  return buf.subarray(offset, offset + length).toString("hex").replace(/../g, "$& ").trim();
}

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
// This is how patches are saved since the Combinator grew to 32 rotaries and 32
// buttons; see readLegacyLabels for the layout before that.
//
// Returns null if the bytes at the offset are not such a table, as the marker it
// is found by is not unique within the Combinator's BODY.
function readSlotTable(buf, offset) {
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
    // The wheels are not part of the table. Their labels follow it in some
    // versions and are left out in others, where the next block starts straight
    // away — which is what tells the two apart.
    if (!isBlockMarker(buf, position)) {
      position = readString(buf, readString(buf, position)[1])[1];
    }
    return { labels, end: position };
  } catch {
    return null;
  }
}

// Reads the panel layout that follows the label table: which of the label slots
// are actually on the Combinator's front panel, and in what order.
//
// This is what says which slot Reason means by "Rotary 1". The slot a label sits
// in is a lasting identity, given to a control when it is added to the panel and
// kept afterwards, while Remote numbers the rotaries and the buttons by the
// order they appear in this layout. Rearranging a panel therefore leaves the
// labels where they are and renumbers the remote parameters around them, which
// is why the two only agree on patches whose controls have never been moved.
//
// Slots missing from the layout belong to controls that have since been deleted.
// Their labels are still in the table, but there is no parameter left for them.
//
// The block carries a version that has moved on as the Combinator has, so the
// version itself is not checked: patches hold 2 or 3 depending on the Reason
// that saved them, with the same records inside either way. What says whether
// the block has been understood is the records, which have to be of known kinds
// and to name slots that exist.
//
// Throws with the reason rather than returning nothing, so that a patch this
// cannot read says what stopped it. Anything unaccounted for here shows up in
// the warnings of a run over a whole patch library, which is the only way of
// finding out what a format this size still has in it.
function readLayout(buf, offset, limit) {
  const isMarker = buf.readUInt8(offset) === MARKER_BYTE &&
    buf.readUInt8(offset + 2) === 0 &&
    buf.readUInt8(offset + 3) === 0 &&
    buf.readUInt8(offset + 4) === 0;
  if (!isMarker) {
    throw new Error(
      `no panel layout after the label table (found ${hex(buf, offset, 5)})`
    );
  }
  const count = buf.readUInt32BE(offset + 5);
  if (count > MAX_PANEL_RECORDS) {
    throw new Error(`the panel layout claims ${count} records`);
  }
  let position = offset + 9;
  const rotaries = [];
  const buttons = [];
  for (let record = 0; record < count; record += 1) {
    if (position + PANEL_RECORD_SIZE > limit) {
      throw new Error(`the panel layout runs past the end of the body at record ${record}`);
    }
    const kind = buf.readUInt32BE(position);
    let slot = null;
    let size;
    if (kind === PANEL_ROTARY) {
      slot = buf.readUInt32BE(position + 16);
      size = PANEL_ROTARY_RECORD_SIZE;
    } else if (kind === PANEL_BUTTON || kind === PANEL_WHEEL) {
      slot = buf.readUInt32BE(position + 12);
      size = PANEL_RECORD_SIZE;
    } else if (kind === PANEL_CAPTION || kind === PANEL_SWITCH_CAPTION) {
      // text printed on the panel rather than a control the codec can reach:
      // the captions beside the Combinator's own Run and Bypass switches, which
      // Remote addresses as parameters of their own rather than as buttons.
      // Read only so that the records after them can be found.
      const length = buf.readUInt32BE(position + 12);
      if (length > MAX_LABEL_LENGTH) {
        throw new Error(`the panel layout has a caption of ${length} characters at record ${record}`);
      }
      size = PANEL_RECORD_SIZE + length;
    } else {
      throw new Error(`the panel layout has a record of an unknown kind (${kind}) at record ${record}`);
    }
    if (slot !== null) {
      if (slot < 1 || slot > MAX_PANEL_SLOT) {
        throw new Error(`the panel layout names slot ${slot} at record ${record}`);
      }
      if (kind === PANEL_ROTARY) {
        rotaries.push(slot);
      } else if (kind === PANEL_BUTTON) {
        buttons.push(slot);
      }
    }
    position += size;
  }
  if (position > limit) {
    throw new Error("the panel layout ends past the end of the body");
  }
  return { rotaries, buttons };
}

// Reads the front panel labels of a patch saved before the Combinator grew to 32
// rotaries and 32 buttons, which keeps them in two arrays of four rather than in
// a table of numbered slots: four rotary labels, then four button labels, each
// array behind a count of its own.
//
// Nothing in those bytes identifies them as labels, so they are found by the
// block of current values that sits immediately in front of them: a marker
// followed by arrays of four bytes each — the rotary positions, the button
// states, the ranges and so on. How many of those arrays there are depends on
// the version the block carries, and later versions keep more per control, so
// they are counted rather than assumed.
//
// Anchoring on the values rather than on the labels themselves means a patch
// that labels nothing is still recognised, instead of being reported as a patch
// the format of which could not be read.
//
// Returns null if the bytes at the offset are not that block.
function readLegacyLabels(buf, offset) {
  try {
    let position = offset + 5;
    let arrays = 0;
    while (arrays < MAX_LEGACY_VALUE_ARRAYS && buf.readUInt32BE(position) === LEGACY_SLOTS) {
      position += 4 + LEGACY_SLOTS;
      arrays += 1;
    }
    if (arrays < MIN_LEGACY_VALUE_ARRAYS) {
      return null;
    }
    // the labels follow in a block of their own, behind a marker of its own
    if (!isBlockMarker(buf, position)) {
      return null;
    }
    position += 5;
    const labels = new Map();
    // the panel of a Combinator this old cannot be rearranged, so the labels are
    // already in the order Remote numbers the parameters in
    for (const kind of ["Rotary", "Button"]) {
      if (buf.readUInt32BE(position) !== LEGACY_SLOTS) {
        return null;
      }
      position += 4;
      for (let slot = 1; slot <= LEGACY_SLOTS; slot += 1) {
        if (buf.readUInt32BE(position) > MAX_LEGACY_LABEL_LENGTH) {
          return null;
        }
        const [label, next] = readString(buf, position);
        // a label with a control character in it is a run of unrelated bytes
        // that happens to have been read this far
        if (/[\x00-\x1f\x7f]/.test(label)) {
          return null;
        }
        labels.set(`${kind} ${slot}`, label);
        position = next;
      }
    }
    return labels;
  } catch {
    return null;
  }
}

// Every block marker within the Combinator's BODY, so that a table can be looked
// for at each of them: a marker says nothing about what follows it, so the only
// way to tell a table from a run of unrelated bytes is to try to read one and
// see whether it holds together. The version a marker carries is not matched on,
// as the same block is found under more than one of them.
function* markerOffsets(buf, from, to) {
  for (let at = buf.indexOf(MARKER_BYTE, from); at >= 0 && at < to; at = buf.indexOf(MARKER_BYTE, at + 1)) {
    if (isBlockMarker(buf, at)) {
      yield at;
    }
  }
}

// The labels of the Combinator, keyed by the remote parameter that carries them.
//
// A patch saved in the current layout keeps its labels in a table of 64 slots
// and the panel that decides what those slots are called over Remote in a
// separate block after it; one saved before the Combinator grew past four
// rotaries and four buttons has a fixed panel, so its labels are already in
// remote order.
function findLabels(buf, from, to) {
  for (const at of markerOffsets(buf, from, to)) {
    const table = readSlotTable(buf, at);
    if (!table) {
      continue;
    }
    // the slot table is identified by its slot count and its run of slot
    // numbers, so once one has been read the patch is understood and a layout
    // that cannot be read is a real failure rather than a false start
    const panel = readLayout(buf, table.end, to);
    const labels = new Map();
    const take = (slots, kind) => slots.forEach((slot, index) => {
      // Remote stops at 32 of each, so a panel with more controls than that has
      // some the control surface can never reach
      if (index < ROTARY_SLOTS) {
        labels.set(`${kind} ${index + 1}`, table.labels.get(slot) || "");
      }
    });
    take(panel.rotaries, "Rotary");
    take(panel.buttons, "Button");
    return labels;
  }
  for (const at of markerOffsets(buf, from, to)) {
    const legacy = readLegacyLabels(buf, at);
    if (legacy) {
      return legacy;
    }
  }
  return null;
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
  const labels = findLabels(buf, body.content, body.content + body.length);
  if (!labels) {
    throw new Error("no labels found in the Combinator's BODY chunk");
  }
  const params = {};
  let count = 0;
  let defaulted = 0;
  for (const [param, label] of labels) {
    const trimmed = label.trim();
    if (!trimmed) {
      continue;
    }
    // a patch that keeps a control's default name has written "Rotary 1" on the
    // panel, which is what Reason reports for it anyway: worth telling apart
    // from one that names nothing, but not worth storing either way
    if (trimmed === param) {
      defaulted += 1;
    } else {
      params[param] = trimmed;
      count += 1;
    }
  }
  return { deviceName, params, count, defaulted };
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
  let defaultedCount = 0;

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
        // Read without trouble, but there is nothing the control surface could
        // show that Reason does not report by itself: either the patch names
        // none of its controls, or it has left them at the names Reason gives
        // them. Worth telling apart, as the second means the labels were read
        // and found to say nothing rather than not found at all.
        if (patch.defaulted > 0) {
          defaultedCount += 1;
          options.log(
            `only the default names (${patch.defaulted} control(s) still called ` +
            `"Rotary 1", "Button 1" and so on): ${file}`
          );
        } else {
          options.log(`no labels (none named in the patch): ${file}`);
        }
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
  return { patches, aliases, patchCount, labelledCount, defaultedCount };
}

// --- writing the Lua file --------------------------------------------------

function luaString(value) {
  const escaped = value
    .replace(/\\/g, "\\\\")
    .replace(/"/g, '\\"')
    // control characters would end the string or break the file. The numeric
    // ones are padded to three digits so that a control character followed by a
    // digit cannot be read back as a different character
    .replace(/[\n\r\t]/g, (character) => ({ "\n": "\\n", "\r": "\\r", "\t": "\\t" })[character])
    .replace(/[\x00-\x1f\x7f]/g, (character) => `\\${String(character.charCodeAt(0)).padStart(3, "0")}`);
  return `"${escaped}"`;
}

const NAMED_ESCAPES = { n: "\n", r: "\r", t: "\t" };

// Undoes luaString, so that a file written by an earlier run can be read back
// and added to.
function luaUnstring(quoted) {
  return quoted.slice(1, -1).replace(/\\(\d{3}|.)/g, (all, what) => {
    if (/^\d{3}$/.test(what)) {
      return String.fromCharCode(Number(what));
    }
    return NAMED_ESCAPES[what] !== undefined ? NAMED_ESCAPES[what] : what;
  });
}

// The shapes renderLua writes, so that it can be read back line by line. Only
// this script writes the file, so there is no call for a Lua parser: what there
// is call for is refusing anything that does not look exactly like what was
// written, rather than quietly dropping the patches it could not make sense of.
const LUA_STRING = '"(?:[^"\\\\]|\\\\.)*"';
const LUA_ENTRY = new RegExp(`^labels\\[(${LUA_STRING})\\] = \\{$`);
const LUA_PARAM = new RegExp(`^ {2}\\[(${LUA_STRING})\\] = (${LUA_STRING}),$`);
const LUA_ALIAS = new RegExp(`^labels\\[(${LUA_STRING})\\] = labels\\[(${LUA_STRING})\\]$`);
const LUA_IGNORED = /^(|--.*|local labels = \{\}|return labels)$/;

// Reads back a labels file written by an earlier run, so that a run over one
// directory adds to what is already there instead of replacing it.
//
// Throws on any line it does not recognise. The alternative — skipping what it
// cannot read — would quietly lose thousands of patches on the next write, and a
// hand-edited or half-written file is far better reported than merged.
function readLua(file) {
  const patches = new Map();
  const aliases = new Map();
  let current = null;
  const lines = fs.readFileSync(file, "utf8").split("\n");
  lines.forEach((line, index) => {
    const fail = (why) => {
      throw new Error(`${path.relative(repoRoot, file)}, line ${index + 1}: ${why}`);
    };
    if (current) {
      const param = line.match(LUA_PARAM);
      if (param) {
        current.params[luaUnstring(param[1])] = luaUnstring(param[2]);
        return;
      }
      if (line === "}") {
        current = null;
        return;
      }
      fail("expected a label or the end of the patch");
    }
    const entry = line.match(LUA_ENTRY);
    if (entry) {
      current = { params: {} };
      patches.set(luaUnstring(entry[1]), current);
      return;
    }
    const alias = line.match(LUA_ALIAS);
    if (alias) {
      aliases.set(luaUnstring(alias[1]), { name: luaUnstring(alias[2]) });
      return;
    }
    if (!LUA_IGNORED.test(line)) {
      fail("this is not a line written by the extraction script");
    }
  });
  if (current) {
    throw new Error(`${path.relative(repoRoot, file)} ends in the middle of a patch`);
  }
  return { patches, aliases };
}

// Adds what a run found to what the file already held. A patch that has been
// extracted again replaces the entry it had before, as the file on disk is what
// the patch says now.
function mergeLabels(existing, found) {
  const patches = new Map(existing.patches);
  const aliases = new Map(existing.aliases);
  let added = 0;
  let replaced = 0;
  for (const [name, entry] of found.patches) {
    if (patches.has(name)) {
      replaced += 1;
      // The device name that led here was read from the patch as it was then.
      // Now that the patch has been read again, only the device name this run
      // found still leads to the right labels, so any earlier one goes — else a
      // patch replaced by a different one keeps the old one's device name
      // pointing at it.
      for (const [aliasName, alias] of [...aliases]) {
        if (alias.name === name) {
          aliases.delete(aliasName);
        }
      }
    } else {
      added += 1;
    }
    patches.set(name, entry);
  }
  for (const [name, entry] of found.aliases) {
    aliases.set(name, entry);
  }
  // the same rule as within a single run: a device name that is also a patch
  // name gives way, and one whose patch is no longer there leads nowhere
  for (const [name, alias] of [...aliases]) {
    if (patches.has(name) || !patches.has(alias.name)) {
      aliases.delete(name);
    }
  }
  return { patches, aliases, added, replaced, kept: patches.size - added - replaced };
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
  const options = { out: defaultOutFile, quiet: false, selfTest: false, replace: false, dirs: [] };
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
    } else if (arg === "--replace") {
      options.replace = true;
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

// Checks the parsing against the example patches in the repository, so that a
// change to it can be caught without a Reason installation to hand. There is one
// patch for each of the two layouts a Combinator can have been saved in.
function selfTest() {
  const cases = [
    {
      file: examplePatch,
      deviceName: "Bent Beat [UCLUB]",
      labels: slotTableLabels(),
    },
    {
      file: legacyExamplePatch,
      deviceName: "[DRUMS] Floor Filler",
      labels: {
        "Rotary 1": "HP FILTER",
        "Rotary 2": "PATTERN 1-4",
        "Button 1": "KICK",
        "Button 2": "CLAP",
        "Button 3": "HH",
        "Button 4": "RUMBLE",
      },
    },
    {
      // the panel of this one has been rearranged: "Square Sync" sits in the
      // first label slot but Reason calls it Rotary 8, and "Sweep Echo" sits in
      // the second but is Rotary 1. Reading the slots in order would put every
      // label on the wrong control while looking perfectly plausible.
      file: rearrangedExamplePatch,
      deviceName: "80's House Funky PolyPluck",
      labels: {
        "Rotary 1": "Sweep Echo",
        "Rotary 2": "Vintage Saws",
        "Rotary 3": "Detuned Squares",
        "Rotary 4": "Formant OSC",
        "Rotary 5": "Filter Frequency",
        "Rotary 6": "AMP Attack",
        "Rotary 7": "AMP Release",
        "Rotary 8": "Square Sync",
        "Rotary 9": "Formant Sweep",
        "Rotary 10": "Filter Mod ENV",
        "Button 1": "Saw Detune",
      },
    },
    {
      file: olderLayoutExamplePatch,
      deviceName: "Analog Bliss Pad [Run]",
      labels: {
        "Rotary 1": "Bell Pad",
        "Rotary 2": "Analog Saw",
        "Rotary 3": "Sub Osc.",
        "Rotary 4": "Release",
        "Button 1": "Wave Mod.",
        "Button 2": "Xciter",
        "Button 3": "Xtra Fat",
        "Button 4": "Hp Filter",
        "Button 5": "Sequencer On/Off",
      },
    },
    {
      // "Volume" sits in slot 4 but is Rotary 7, so this one covers the panel
      // ordering as well as the captions
      file: captionedExamplePatch,
      deviceName: "Adventure Time Arp",
      labels: {
        "Rotary 1": "Decay",
        "Rotary 2": "HF Damp",
        "Rotary 3": "Dry/Wet",
        "Rotary 4": "Attack",
        "Rotary 5": "Decay",
        "Rotary 6": "Release",
        "Rotary 7": "Volume",
        "Rotary 8": "Delay",
        "Rotary 9": "Width",
        "Rotary 10": "Dry/Wet",
        "Rotary 11": "Feedback",
        "Rotary 12": "Color Drive",
        "Rotary 13": "Dry/Wet",
        "Rotary 14": "Low Cut",
        "Rotary 15": "High Cut",
        "Button 1": "Reverb",
        "Button 2": "Chorus",
        "Button 3": "Delay",
        "Button 4": "EQ",
        "Button 5": "Reverse Glitch",
        "Button 6": "Low Stutter",
        "Button 7": "Arp On",
        "Button 8": "Arp 1",
        "Button 9": "Arp 2",
        "Button 10": "Arp 3",
        "Button 11": "Activate Loop",
      },
    },
    {
      file: noWheelLabelsExamplePatch,
      deviceName: "Bright Funky Saw Stabs",
      labels: {
        "Rotary 1": "Saw Synth",
        "Rotary 2": "Saw Arp Layer",
        "Rotary 3": "Reverb Decay",
        "Rotary 4": "Master Volume",
        "Button 1": "Synth Unison",
        "Button 2": "Pitch ENV",
        "Button 3": "Bright Verb",
        "Button 4": "Reverb",
      },
    },
    { file: defaultNamesExamplePatch, deviceName: "Crack Stab", labels: {}, defaulted: 8 },
    ...unlabelledExamplePatches.map((file) => ({ file, labels: {}, defaulted: 0 })),
  ];
  for (const expected of cases) {
    const name = path.relative(repoRoot, expected.file);
    let patch;
    try {
      patch = readPatch(expected.file);
    } catch (error) {
      console.error(`Self test: failed, cannot read ${name}`);
      console.error(`  ${error.message}`);
      return 1;
    }
    if (expected.defaulted !== undefined && patch.defaulted !== expected.defaulted) {
      console.error(
        `Self test: failed on ${name}, ${patch.defaulted} control(s) still carry ` +
        `their default name rather than ${expected.defaulted}`
      );
      return 1;
    }
    if (!sameLabels(patch.params, expected.labels)) {
      console.error(`Self test: failed on ${name}`);
      console.error(`  expected: ${JSON.stringify(expected.labels, null, 2)}`);
      console.error(`  actual:   ${JSON.stringify(patch.params, null, 2)}`);
      return 1;
    }
    if (expected.deviceName && patch.deviceName !== expected.deviceName) {
      console.error(`Self test: failed on ${name}, device name is "${patch.deviceName}"`);
      return 1;
    }
  }
  const patch = readPatch(examplePatch);
  const lua = renderLua(new Map([[patchNameOf(examplePatch), { params: patch.params }]]));
  // the last of the rotaries and the first of the buttons, so that the order the
  // slots are rendered in is checked across the boundary between the two
  if (!lua.includes('["Rotary 14"] = "Clean",\n  ["Button 1"] = "Ch. 1 On",')) {
    console.error("Self test: failed, the rendered Lua does not hold the labels in order");
    return 1;
  }
  const mergeFailure = mergeSelfTest();
  if (mergeFailure) {
    console.error(`Self test: failed, ${mergeFailure}`);
    return 1;
  }
  console.log(`Self test: success (${cases.length} patches)`);
  return 0;
}

// Checks that a file written by one run can be read back and added to by the
// next, which is what lets separate runs over separate directories build one
// file between them. Returns what went wrong, or nothing if all is well.
function mergeSelfTest() {
  const first = new Map([
    // a name and a label with everything that has to survive the escaping
    ['A "quoted" \\ name', { params: { "Rotary 1": 'say "hi"\\bye', "Button 2": "keep" } }],
    ["B", { params: { "Rotary 1": "old" } }],
  ]);
  const firstAliases = new Map([["Device Of B", { name: "B" }]]);
  const written = renderLua(first, firstAliases);

  const file = path.join(os.tmpdir(), `combinator-labels-self-test-${process.pid}.lua`);
  let readBack;
  try {
    fs.writeFileSync(file, written, "utf8");
    readBack = readLua(file);
  } catch (error) {
    return `the file written could not be read back: ${error.message}`;
  } finally {
    fs.rmSync(file, { force: true });
  }
  for (const [name, entry] of first) {
    const round = readBack.patches.get(name);
    if (!round || !sameLabels(round.params, entry.params)) {
      return `"${name}" did not survive being written and read back`;
    }
  }

  // a second run replaces B and leaves A alone
  const second = {
    patches: new Map([["B", { params: { "Rotary 1": "new" } }]]),
    aliases: new Map([["Device Of B Now", { name: "B" }]]),
  };
  const merged = mergeLabels(readBack, second);
  if (merged.added !== 0 || merged.replaced !== 1 || merged.kept !== 1) {
    return `merging counted ${merged.added} added, ${merged.replaced} replaced, ${merged.kept} kept`;
  }
  if (merged.patches.get("B").params["Rotary 1"] !== "new") {
    return "the patch read again did not replace the one already in the file";
  }
  if (!merged.patches.has('A "quoted" \\ name')) {
    return "a patch that was not read again was lost";
  }
  // the device name from the earlier run led to a patch that has been replaced,
  // so it must not still point at it
  if (merged.aliases.has("Device Of B")) {
    return "a device name from the earlier run outlived the patch it led to";
  }
  if (merged.aliases.get("Device Of B Now")?.name !== "B") {
    return "the device name found by the later run was not kept";
  }
  return null;
}

// the labels of the patch saved in the current layout, kept apart from the cases
// above only because there are enough of them to bury the rest
function slotTableLabels() {
  return {
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
    // there is no Rotary 15: the table still holds a label for a control that
    // has been deleted from the panel, and the layout is what leaves it out
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
  const found = collect(dirs, options);
  // what the file already holds, so that a run over one directory adds to it
  // rather than throwing away the patches of every other directory
  let existing = { patches: new Map(), aliases: new Map() };
  if (!options.replace && fs.existsSync(options.out)) {
    try {
      existing = readLua(options.out);
      options.log(`Read ${existing.patches.size} patch name(s) already in the file`);
    } catch (error) {
      console.error(`Error: ${error.message}`);
      console.error(
        "Nothing has been written. Fix the file, or pass --replace to write a " +
        "fresh one from the directories given."
      );
      return 1;
    }
  }
  const { patches, aliases, added, replaced, kept } = mergeLabels(existing, found);
  fs.writeFileSync(options.out, renderLua(patches, aliases), "utf8");
  console.log(
    `Extract: ${found.labelledCount} of ${found.patchCount} patch(es) have labels, ` +
    `written to ${path.relative(repoRoot, options.out)} ` +
    `(${patches.size} patch name(s), ${aliases.size} device name(s))`
  );
  if (!options.replace) {
    console.log(`Extract: ${added} added, ${replaced} replaced, ${kept} left as they were`);
  }
  const { defaultedCount } = found;
  if (defaultedCount > 0) {
    console.log(
      `Extract: ${defaultedCount} patch(es) left their controls at the names ` +
      `Reason gives them, so there was nothing to store for those`
    );
  }
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
