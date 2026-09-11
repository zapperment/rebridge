# Linux and Mac compatibility

Shell scripts need to work on both Linux systems (i.e. in dev container) and on MacOS (host machine).

# Command line tools

You are running in a dev container. You don't have permission to install any command line tools yourself. When you try to use a tool and discover that it is not installed in the dev container, Pause your work and ask the user to install it for you instead of trying workarounds. 

# Tests

After implementing a change, make sure the new functionality is covered by unit tests.

Always run the tests before claiming work is done.