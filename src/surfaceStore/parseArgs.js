const os = require("os");
const path = require("path");

// the port and file to use, from the command line (see index.js), given the
// MIDI ports available; like the log receiver, it takes the name of a single
// port, which the store both listens and answers on, and lists the ports if
// none is given or the one given is not there
//
// Returns { portName, file }, or { exitCode, output, error } to print and exit
// with instead.
module.exports = (args, available) => {
  const file = path.join(os.homedir(), ".rebridge", "surfaceStore.json");
  const options = { file };
  const ports = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--file") {
      options.file = args[++i];
    } else {
      ports.push(args[i]);
    }
  }
  const usable = available.inputs.filter((port) => available.outputs.includes(port));
  const list = ["Available ports:", ...usable.map((port) => `- ${port}`)];

  if (ports.length === 0) {
    return { exitCode: 0, output: ["Please specify which MIDI port to use!", ...list] };
  }

  if (ports.length > 1) {
    return {
      exitCode: 1,
      error: [
        "You specified more than one argument – please specify only one argument, i.e. the MIDI port to use!",
      ],
      output: ["Hint: if the MIDI port name contains spaces, put it in quotes"],
    };
  }

  const [portName] = ports;

  if (!usable.includes(portName)) {
    return {
      exitCode: 1,
      error: [`The port name “${portName}” you specified was not found!`],
      output: list,
    };
  }

  return { ...options, portName };
};
