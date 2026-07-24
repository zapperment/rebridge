const getPortNameFromArgs = require("./getPortNameFromArgs");
const listenForInput = require("./listenForInput");

const portName = getPortNameFromArgs();
listenForInput(portName);
