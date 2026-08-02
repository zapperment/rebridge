const threshold = 0.25;

function areMessagesSimilar(msg1, msg2) {
  if (msg1 === "" && msg2 === "") {
    return true;
  }
  let startPos = 0, endPos1 = msg1.length - 1, endPos2 = msg2.length - 1;
  do {
    const msg1charStart = msg1.charAt(startPos)
    const msg1charEnd = msg1.charAt(endPos1)
    const msg2charStart = msg2.charAt(startPos)
    const msg2charEnd = msg2.charAt(endPos2)
    const startIsDifferent = msg1charStart !== msg2charStart;
    const endIsDifferent = msg1charEnd !== msg2charEnd;
    const msgFinished1 = startPos === endPos1
    const msgFinished2 = startPos === endPos2

    if (startIsDifferent && endIsDifferent || msgFinished1 && msgFinished2) {
      const addTo1 = msgFinished1 ? 0 : 1;
      const addTo2 = msgFinished2 ? 0 : 1;
      const diffNumChars1 = endPos1 - startPos + addTo1;
      const diffNumChars2 = endPos2 - startPos + addTo2;
      const diffNumChars1perc = diffNumChars1 ? diffNumChars1 / msg1.length : 0;
      const diffNumChars2perc = diffNumChars2 ? diffNumChars2 / msg2.length : 0;
      const avgDiffNumChars = (diffNumChars1 + diffNumChars2) / 2;
      const avgDiffNumCharsPerc = (diffNumChars1perc + diffNumChars2perc) / 2;
      return avgDiffNumCharsPerc <= 0.25;
    }
    if (!startIsDifferent) {
      startPos++;
    }
    if (!endIsDifferent) {
      endPos1--;
      endPos2--;
    }
  } while (true)
}

console.log(areMessagesSimilar(
//          1         2         3         4         5         6                   7 
// 12345678901234567890123456789012345678901234567890123456789012345678901234567890
  "control surface fader1 send value 89 (89) for param Schubidu",
  "control surface fader1 send value 90 (90) for param Schubidu"
),
areMessagesSimilar(
  "hans",
  "wurst"
),
areMessagesSimilar(
  "foo",
  "foo"
),
areMessagesSimilar(
  "ficken macht Spaß",
  "ficken"
),
areMessagesSimilar(
  "",
  ""
),
areMessagesSimilar(
  "",
  "fiki"
))