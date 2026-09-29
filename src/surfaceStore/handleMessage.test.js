const test = require("node:test");
const assert = require("node:assert");
const fs = require("fs");
const os = require("os");
const path = require("path");
const FileStore = require("./FileStore");
const handleMessage = require("./handleMessage");
const { commands } = require("./protocol");

const colours = Array.from({ length: 64 }, (_, i) => (i === 0 ? 5 : 1));

function temporaryFile() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "surface-store-"));
  return path.join(dir, "nested", "surfaceStore.json");
}

test("answers a request for unknown colours with unknown", () => {
  const store = new FileStore(temporaryFile());
  const reply = handleMessage({ command: commands.request, documentName: "My Set", deviceName: "L1" }, store);
  assert.deepStrictEqual(reply, { command: commands.unknown, documentName: "My Set", deviceName: "L1" });
});

test("stores colours and answers a request with them", () => {
  const store = new FileStore(temporaryFile());
  assert.strictEqual(
    handleMessage({ command: commands.colours, documentName: "My Set", deviceName: "L1", colours }, store),
    null,
  );
  const reply = handleMessage({ command: commands.request, documentName: "My Set", deviceName: "L1" }, store);
  assert.deepStrictEqual(reply, { command: commands.colours, documentName: "My Set", deviceName: "L1", colours });
});

test("keeps the colours of each song and LaunchEon apart", () => {
  const store = new FileStore(temporaryFile());
  handleMessage({ command: commands.colours, documentName: "My Set", deviceName: "L1", colours }, store);
  assert.strictEqual(store.getColours("My Set", "L2"), null);
  assert.strictEqual(store.getColours("Other Set", "L1"), null);
});

test("keeps the colours in the file across restarts", () => {
  const file = temporaryFile();
  handleMessage({ command: commands.colours, documentName: "Grüße", deviceName: "L1", colours }, new FileStore(file));
  assert.deepStrictEqual(new FileStore(file).getColours("Grüße", "L1"), colours);
  const data = JSON.parse(fs.readFileSync(file, "utf8"));
  assert.deepStrictEqual(data.songs["Grüße"].L1.patternColours, colours);
});

test("keeps other settings when storing colours", () => {
  const file = temporaryFile();
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, JSON.stringify({ songs: { "My Set": { L1: { other: 1 } } } }));
  new FileStore(file).setColours("My Set", "L1", colours);
  assert.deepStrictEqual(JSON.parse(fs.readFileSync(file, "utf8")).songs["My Set"].L1, { other: 1, patternColours: colours });
});

test("does not write the file again for colours it has, like its own echoed reply", () => {
  const file = temporaryFile();
  const store = new FileStore(file);
  handleMessage({ command: commands.colours, documentName: "My Set", deviceName: "L1", colours }, store);
  const written = fs.statSync(file).mtimeMs;
  fs.utimesSync(file, new Date(0), new Date(0));
  handleMessage({ command: commands.colours, documentName: "My Set", deviceName: "L1", colours: [...colours] }, store);
  assert.strictEqual(fs.statSync(file).mtimeMs, 0);
  assert.ok(written > 0);
});

test("ignores its own hello and unknown", () => {
  const store = new FileStore(temporaryFile());
  assert.strictEqual(handleMessage({ command: commands.hello }, store), null);
  assert.strictEqual(handleMessage({ command: commands.unknown, documentName: "My Set", deviceName: "L1" }, store), null);
});
