const conversions = [
  ["\\*\\*", 1],
  ["__", 1],
  ["\\*", 3],
  ["_", 3],
];

function convert(message, md, ansi) {
  let nextMessage = `${message}`;
  const mdMatches = nextMessage.match(new RegExp(`${md}(.+?)${md}`, "g"));
  if (!mdMatches) {
    return nextMessage;
  }
  const ansiMatches = mdMatches.map((mdToken) =>
    mdToken.replace(new RegExp(`^${md}(.+?)${md}$`), `\u001b[${ansi}m$1\u001b[0m`),
  );
  mdMatches.forEach(
    (mdToken, index) =>
      (nextMessage = nextMessage.replace(mdToken, ansiMatches[index])),
  );
  return nextMessage;
}

module.exports = (message) => {
  let nextMessage = `${message}`;
  for ([md, ansi] of conversions) {
    nextMessage = convert(nextMessage, md, ansi);
  }
  return nextMessage;
}
