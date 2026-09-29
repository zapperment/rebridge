// The surface store: remembers the pattern colours of the Launchpad Pro [MK3]
// codec per song and LaunchEon, as Reason's codecs cannot keep anything
// themselves (see src/lppmk3/docs/adr/0002).
//
// Usage: yarn store <port> [--file <path>]
//
// The port, e.g. the IAC bus "IAC ReBridge Store", is used in both directions,
// as are the codec's store ports; each side then hears its own messages too,
// which neither reacts to. The file defaults to ~/.rebridge/surfaceStore.json.

const easymidi = require("easymidi");
const FileStore = require("./FileStore");
const handleMessage = require("./handleMessage");
const parseArgs = require("./parseArgs");
const { commands, encode, decode } = require("./protocol");

function main() {
  const options = parseArgs(process.argv.slice(2), {
    inputs: easymidi.getInputs(),
    outputs: easymidi.getOutputs(),
  });
  if (options.exitCode !== undefined) {
    (options.error || []).forEach((line) => console.error(line));
    (options.output || []).forEach((line) => console.log(line));
    process.exit(options.exitCode);
  }
  console.log(`Using MIDI port: ${options.portName}`);
  const store = new FileStore(options.file);
  const input = new easymidi.Input(options.portName);
  const output = new easymidi.Output(options.portName);
  const log = (message) => console.log(`${new Date().toLocaleTimeString()} ${message}`);
  input.on("sysex", ({ bytes }) => {
    const message = decode(bytes);
    if (!message) {
      return;
    }
    const reply = handleMessage(message, store, log);
    if (reply) {
      output.send("sysex", encode(reply));
    }
  });
  output.send("sysex", encode({ command: commands.hello }));
  log(`surface store keeping ${options.file}`);
}

main();
