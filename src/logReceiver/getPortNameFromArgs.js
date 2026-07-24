const easymidi = require("easymidi");

module.exports = () => {
  const inputs = easymidi.getInputs();

  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log("Please specify which MIDI port to listen to!");
    console.log("Available ports:");
    for (const input of inputs) {
      console.log(`- ${input}`);
    }
    process.exit(0);
  }

  if (args.length > 1) {
    console.error(
      "You specified more than one argument – please specify only one argument, i.e. the MIDI port to listen to!",
    );
    console.log(
      "Hint: if the MIDI port name contains spaces, put it in quotes",
    );
    process.exit(1);
  }

  const portName = args[0];

  if (!inputs.includes(portName)) {
    console.error(`The port name “${portName}” you spefified was not found!`);
    console.log("Available ports:");
    for (const input of inputs) {
      console.log(`- ${input}`);
    }
    process.exit(1);
  }

  console.log(`Using MIDI input port: ${portName}`);

  return portName;
};
