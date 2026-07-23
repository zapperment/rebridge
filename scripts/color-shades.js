#!/usr/bin/env node

function hexToRgb(hex) {
  const num = parseInt(hex, 16);
  return {
    r: (num >> 16) & 0xff,
    g: (num >> 8) & 0xff,
    b: num & 0xff,
  };
}

function rgbToHsb({ r, g, b }) {
  r /= 255;
  g /= 255;
  b /= 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const delta = max - min;

  let h = 0;
  if (delta !== 0) {
    if (max === r) h = 60 * (((g - b) / delta) % 6);
    else if (max === g) h = 60 * ((b - r) / delta + 2);
    else h = 60 * ((r - g) / delta + 4);
  }
  if (h < 0) h += 360;

  const s = max === 0 ? 0 : delta / max;
  const brightness = max;

  return { h, s, b: brightness };
}

function hsbToRgb({ h, s, b }) {
  const c = b * s;
  const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
  const m = b - c;

  let r1, g1, b1;
  if (h < 60) [r1, g1, b1] = [c, x, 0];
  else if (h < 120) [r1, g1, b1] = [x, c, 0];
  else if (h < 180) [r1, g1, b1] = [0, c, x];
  else if (h < 240) [r1, g1, b1] = [0, x, c];
  else if (h < 300) [r1, g1, b1] = [x, 0, c];
  else [r1, g1, b1] = [c, 0, x];

  return {
    r: Math.round((r1 + m) * 255),
    g: Math.round((g1 + m) * 255),
    b: Math.round((b1 + m) * 255),
  };
}

function rgbToHex({ r, g, b }) {
  return [r, g, b].map((v) => v.toString(16).padStart(2, '0')).join('');
}

// MIDI sysex data bytes only carry 7 bits, so 8-bit (0-255) channel
// values need rescaling to the 0-127 range before they're sent.
function to7Bit({ r, g, b }) {
  const scale = (v) => Math.round((v * 127) / 255);
  return { r: scale(r), g: scale(g), b: scale(b) };
}

function main() {
  const input = process.argv[2];
  if (!input || !/^[0-9a-fA-F]{6}$/.test(input)) {
    console.error('Usage: node color-shades.js <RRGGBB>');
    console.error('Provide a 6-character hex color code (0-9, a-f).');
    process.exit(1);
  }

  const highHsb = rgbToHsb(hexToRgb(input));

  const shades = {
    high: highHsb,
    off: { ...highHsb, b: highHsb.b * 0.05 },
    low: { ...highHsb, b: highHsb.b * 0.2 },
    mid: { ...highHsb, b: highHsb.b * 0.5 },
    max: { ...highHsb, s: highHsb.s * 0.7 },
  };

  let lua = []
  for (const [name, hsb] of Object.entries(shades)) {
    const rgb = hsbToRgb(hsb);
    const sysex = to7Bit(rgb);
    const sysexHex = [sysex.r, sysex.g, sysex.b]
      .map((v) => v.toString(16).padStart(2, '0'))
      .join(' ');
    console.log(`${name}: ${rgbToHex(rgb)} (sysex: ${sysexHex})`);
    lua.push(`${name} = "${sysexHex}"`)
  }
  console.log(`{ ${lua.join(", ")} }`);
}

main();
