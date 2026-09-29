const test = require("node:test");
const assert = require("node:assert");
const parseArgs = require("./parseArgs");

const available = {
  inputs: ["IAC ReBridge Store", "IAC LCXL3 Logger", "Only In"],
  outputs: ["IAC ReBridge Store", "IAC LCXL3 Logger"],
};

test("uses the port given, with the default file", () => {
  const options = parseArgs(["IAC ReBridge Store"], available);
  assert.strictEqual(options.portName, "IAC ReBridge Store");
  assert.match(options.file, /\.rebridge[/\\]surfaceStore\.json$/);
});

test("takes the file given", () => {
  assert.deepStrictEqual(parseArgs(["IAC ReBridge Store", "--file", "/tmp/x.json"], available), {
    portName: "IAC ReBridge Store",
    file: "/tmp/x.json",
  });
});

test("lists the ports usable in both directions when none is given", () => {
  const result = parseArgs([], available);
  assert.strictEqual(result.exitCode, 0);
  assert.deepStrictEqual(result.output.slice(1), [
    "Available ports:",
    "- IAC ReBridge Store",
    "- IAC LCXL3 Logger",
  ]);
});

test("refuses more than one port", () => {
  assert.strictEqual(parseArgs(["IAC ReBridge Store", "IAC LCXL3 Logger"], available).exitCode, 1);
});

test("refuses a port that is not there, listing the others", () => {
  const result = parseArgs(["Nope"], available);
  assert.strictEqual(result.exitCode, 1);
  assert.match(result.error[0], /“Nope”/);
  assert.ok(result.output.includes("- IAC ReBridge Store"));
});

test("refuses a port that only goes one way", () => {
  assert.strictEqual(parseArgs(["Only In"], available).exitCode, 1);
});
