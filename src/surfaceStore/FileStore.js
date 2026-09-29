const fs = require("fs");
const path = require("path");

// Keeps the surface settings of each song and LaunchEon in a JSON file, laid
// out as { songs: { <song>: { <LaunchEon>: { patternColours: [...] } } } } so
// that more settings can join the pattern colours later
class FileStore {
  constructor(file) {
    this.file = file;
    this.data = FileStore.read(file);
  }

  static read(file) {
    if (!fs.existsSync(file)) {
      return { songs: {} };
    }
    const data = JSON.parse(fs.readFileSync(file, "utf8"));
    return { ...data, songs: data.songs || {} };
  }

  getColours(documentName, deviceName) {
    const settings = this.data.songs[documentName]?.[deviceName];
    return settings?.patternColours || null;
  }

  // stores the colours, unless they are stored already, as they are when the
  // store hears its own reply on a port used in both directions
  setColours(documentName, deviceName, colours) {
    const stored = this.getColours(documentName, deviceName);
    if (stored && stored.length === colours.length && stored.every((colour, i) => colour === colours[i])) {
      return false;
    }
    const song = (this.data.songs[documentName] ||= {});
    song[deviceName] = { ...song[deviceName], patternColours: colours };
    this.write();
    return true;
  }

  // writes to a temporary file first, so that a crash never leaves half a file
  write() {
    fs.mkdirSync(path.dirname(this.file), { recursive: true });
    const temporary = `${this.file}.tmp`;
    fs.writeFileSync(temporary, JSON.stringify(this.data, null, 2) + "\n", "utf8");
    fs.renameSync(temporary, this.file);
  }
}

module.exports = FileStore;
