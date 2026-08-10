const emojis = [
  ["(/)", "✅"],
  ["(x)", "❌"],
  [":-)", "😀"],
  [":-(", "☹️"],
  ["(i)", "ℹ️️"],
  ["(!)", "️⚠️️"],
  ["(+1)", "️️👍🏻️"],
  ["(-1)", "👎🏻"],
  ["(ox)", "💀"],
  [":-|", "😐"],
]

module.exports = function (message) {
  let nextMessage = `${message}`;
  for (const [search,replace] of emojis) {
    nextMessage = nextMessage.replaceAll(search,replace);
  }
  return nextMessage;
}