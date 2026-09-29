const { commands } = require("./protocol");

// the reply to a message from the codec, if any: a request gets the colours
// stored for the song and LaunchEon, or "unknown" if there are none; colours
// are stored
module.exports = (message, store, log = () => {}) => {
  const { command, documentName, deviceName, colours } = message;
  if (command === commands.request) {
    const stored = store.getColours(documentName, deviceName);
    log(`request for “${documentName}” / “${deviceName}”: ${stored ? "sending colours" : "none stored"}`);
    return stored
      ? { command: commands.colours, documentName, deviceName, colours: stored }
      : { command: commands.unknown, documentName, deviceName };
  }
  if (command === commands.colours && store.setColours(documentName, deviceName, colours)) {
    log(`stored colours for “${documentName}” / “${deviceName}”`);
  }
  return null;
};
