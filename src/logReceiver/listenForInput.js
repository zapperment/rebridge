const easymidi = require("easymidi");

const debugSysexHeader = "F0 00 20 29 02 0A 02";
const repeatSignal = ".";
let start = true;
const colour= {
  codes: [
    31, 32, 33, 34, 35, 36,
  ],
  registry: {},
  pointer: 0,
}

module.exports = (portName) => {
  const input = new easymidi.Input(portName);
  input.on("sysex", ({ bytes }) => {
    const hexString = bytes
      .map((byte) => ("0" + (byte & 0xff).toString(16)).slice(-2).toUpperCase())
      .join(" ");
    if (!hexString.startsWith(debugSysexHeader)) {
      return;
    }
    let message = String.fromCharCode(...bytes.slice(7, -1));
    const isRepetition = message === repeatSignal;
    const addLinebreak = !isRepetition && !start
    start = false;
    let logger = null;
    if (!isRepetition) {
      const matches = message.match(/^(\[.+\]) (.+)$/);
      if (matches) {
        ([, logger, message] = matches);
      }
    }
    if (logger) {
      const dotIndex = logger.lastIndexOf(".");
      const loggerGroup = logger.substring(1, dotIndex > 0 ? dotIndex : logger.length - 1);
      let colourCode = colour.registry[loggerGroup];
      if (!colourCode) {
        colourCode = colour.codes[colour.pointer];
        colour.registry[loggerGroup] = colourCode;
        colour.pointer = 
          colour.pointer === colour.codes.length - 1 ? 0 : colour.pointer + 1;
      }
      message = `\u001b[${colourCode}m${logger}\u001b[0m ${message}`
    }
    if (addLinebreak) {
      message = `\n${message}`;
    }
    process.stdout.write(message);
  });
};