const test = require("node:test");
const assert = require("node:assert");
const { commands, encode, decode } = require("./protocol");

const colours = Array.from({ length: 64 }, (_, i) => (i === 0 ? 5 : 1));

test("encodes names as their length and nibbles, like the codec", () => {
  const bytes = encode({ command: commands.request, documentName: "Ab", deviceName: "ä" });
  assert.deepStrictEqual(bytes, [0xf0, 0x7d, 0x52, 0x42, 2, 2, 4, 1, 6, 2, 2, 0x0c, 3, 0x0a, 4, 0xf7]);
});

test("keeps every byte below 128", () => {
  const bytes = encode({ command: commands.colours, documentName: "Grüße", deviceName: "✓", colours });
  assert.ok(bytes.slice(1, -1).every((byte) => byte < 128));
});

test("decodes what it encodes", () => {
  const message = { command: commands.colours, documentName: "My Set", deviceName: "LaunchEon 1", colours };
  assert.deepStrictEqual(decode(encode(message)), message);
});

test("decodes hello", () => {
  assert.deepStrictEqual(decode(encode({ command: commands.hello })), { command: commands.hello });
});

test("truncates long names", () => {
  const message = decode(encode({ command: commands.request, documentName: "x".repeat(200), deviceName: "d" }));
  assert.strictEqual(message.documentName, "x".repeat(127));
});

test("ignores other sysex and truncated messages", () => {
  assert.strictEqual(decode([0xf0, 0x00, 0x20, 0x29, 0x02, 0x0a, 0x02, 0xf7]), null);
  assert.strictEqual(decode([0xf0, 0x7d, 0x52, 0x42, 2, 5, 4, 1, 0xf7]), null);
});
