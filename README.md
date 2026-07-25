# ReBridge

MIDI controller setup for Launch Control XL3 + Ableton Live + Reason

## Getting started

### Prerequisites

Installation requires Node.js, at least version 24, to be installed.

Currently, the installer only works on Macs.

The Reason remote files and the Max for Live files will also work on Windows machines, but you'll have to copy them to the appropriate locations yourself.

### Installation

1. Make a copy of `.env.example` and rename it to `.env`.
1. Adjust the paths in your `.env` to match those on your machine
1. Run `yarn` to install dependencies (you may need to run `corepack enable` first if you haven't used Yarn yet)
1. Run `yarn setup` to generate files from the source code and copy them to the target locations of your Reason installation
1. In Reason, go to “Settings” -> “MIDI” 
1. Under “Remote keyboards and controllers”, click the button “Add manually”
1. Select Vendor “Novation” and model “Launch Control XL3”
1. On the dropdown menu “Input (DAW)”, select the MIDI port “LCXL3 DAW Out”
1. On the dropdown menu “Output (DAW)”, select the MIDI port “LCXL3 DAW In”

Enjoy your Launch Control!

## Development

### Documentation

The [manuals](/manuals) directory contains PDFs of the developer guides from Novation and Reason Studios, along with some example code. You (or your AI tool) can refer to these to learn all about how sending and receiving MIDI commands from the Launch Control XL3 works, and how to process these messages using a Reason Remote codec and mapping file.

### Lua

Reason remote codecs are [Lua](https://www.lua.org) scripts. 

You don't necessarily need to install Lua, but it helps if you are working with an AI tool like Claude Code — Claude can then try out code snippets to make sure the code it is generating actually works. The model “Sonnet 5” is surprisingly good at this, and it is comparatively inexpensive.

The Lua version Reason 14 uses is 5.1, so it makes sense not to use a more recent one.

The dev container config for this project includes Lua already ([see below](#dev-container)).

### Updating the Codec in Reason

After making changes, to build the codec and copy the files over to Reason, run `yarn setup` (or `yarn setup:dev`, [see below](#debugging-logging)).

You do not have to restart Reason every time! It is sufficient to tick the Controller's “active” checkbox off and on again in the MIDI settings.

### Debugging / logging

To find out what's going on as the codec is running, you can send log messages through an extra MIDI port and print them using the utility script `logReceiver`.

To do this, install a special version of the codec using this command:
```
yarn setup:dev 
```

It replaces the normal remote surface in the Reason settings. If you've previously installed the normal remote surface, delete it. Then install the dev version (vendor “Novation”, model “Launch Control XL3 (developer version)”).

Set input and output ports as before to the “DAW Out” / “DAW In” ports.

For “Output (log)” select an extra MIDI port of your choosing. It makes sense to create a dedicated port for this, using the macOS “Audio MIDI Setup” app's IAC device. For example, let's call it “LCXL3 Logger”.

Start the logger using the Yarn command, specifying your logger port, e.g.:

```
yarn log "IAC LCXL3 Logger"
```

You are now ready to add log statements to the Lua code!

At the top of the Lua model you want to log from, add this statement to import the logging module:

```
local debug = require("src.lib.debug._")
```

In the code, add a log statement like so:

```
debug.log("hello world")
```

To log a remote MIDI message:

```
debug.log(debug.midiEventToString(event))
```

To log a boolean value:

```
debug.log(my_bool and "true" or "false")
```

To log a number value:

```
debug.log(tostring(my_num))
```

Concatenating strings:

```
debug.log("value: " .. my_value)
```

### Dev container

When using AI tools like [Claude Code](https://code.claude.com/), it is recommended to use a dev container, so that the AI cannot do dangerous stuff like deleting your personal files.

How this works is out of the scope of this document, so do some googling or ask Claude :-) 

This code repository comes with a dev container config that sets up a container with everything that you and the AI need for working on the codec. 

If you use the IDE VS Code with the Dev Container extension, the dev container will be built automatically when you open the your local copy of this code repository.

**One caveat:** The `yarn setup` command will not work when run inside the dev container — this is intentional, because you do not want the AI to have access to your Reason installation.

You will have to run the command in a terminal outside the dev container (i.e. not in your IDE).

If you are working on the build and installation scripts, you can use the `.env.devcontainer` file to simlulate a Reason installation on the dev container system, but this is only to see if the files are deployed to the proper file system locations.
