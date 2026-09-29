// The messages the surface store and the Launchpad Pro [MK3] codec exchange,
// as sysex: the manufacturer ID for non-commercial use (7d), "RB", a command
// and, but for hello, the names of the song and the LaunchEon, each as its
// length followed by each of its UTF-8 bytes as two nibbles; a colours message
// then has the colour of each pattern, device by device

const header = [0xf0, 0x7d, 0x52, 0x42];

const commands = {
  hello: 1,
  request: 2,
  colours: 3,
  unknown: 4,
};

const maxNameLength = 127;

function encodeName(name) {
  const bytes = [...Buffer.from(name, "utf8")].slice(0, maxNameLength);
  return [bytes.length, ...bytes.flatMap((byte) => [byte >> 4, byte & 0x0f])];
}

// reads a name from the given position, returning it and the position after
// it, or null if the message ends too soon
function decodeName(bytes, position) {
  const length = bytes[position];
  if (length === undefined || position + 2 * length >= bytes.length - 1) {
    return null;
  }
  const nameBytes = [];
  for (let i = 0; i < length; i++) {
    nameBytes.push(bytes[position + 1 + 2 * i] * 16 + bytes[position + 2 + 2 * i]);
  }
  return [Buffer.from(nameBytes).toString("utf8"), position + 1 + 2 * length];
}

function encode({ command, documentName, deviceName, colours }) {
  const bytes = [...header, command];
  if (command !== commands.hello) {
    bytes.push(...encodeName(documentName), ...encodeName(deviceName));
  }
  if (command === commands.colours) {
    bytes.push(...colours);
  }
  bytes.push(0xf7);
  return bytes;
}

// the message in the given sysex bytes, or null if they are not one
function decode(bytes) {
  if (bytes.length < header.length + 2 || header.some((byte, i) => bytes[i] !== byte)) {
    return null;
  }
  const command = bytes[header.length];
  if (command === commands.hello) {
    return { command };
  }
  const document = decodeName(bytes, header.length + 1);
  if (!document) {
    return null;
  }
  const device = decodeName(bytes, document[1]);
  if (!device) {
    return null;
  }
  const message = { command, documentName: document[0], deviceName: device[0] };
  if (command === commands.colours) {
    message.colours = bytes.slice(device[1], -1);
  }
  return message;
}

module.exports = { commands, encode, decode };
