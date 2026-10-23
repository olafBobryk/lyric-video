# Inverted Lyrics

Oversized kinetic typography that inverts the footage inside each letter. Words appear in time with the vocals, with alternating dominant top and bottom lines and approximately 10% safe padding.

## Install

```sh
npx skills add olafBobryk/inverted-lyrics --skill inverted-lyrics
```

Ask your agent:

> Use inverted-lyrics on my video. Start with a test frame and a 15-second draft, reveal words progressively, and alternate oversized top and bottom lines.

## Requirements

The bundled renderer runs locally on macOS with Python 3, Swift (`swiftc`), FFmpeg and FFprobe on PATH, and Impact installed. The agent instructions can be adapted to other systems; the included Swift renderer requires Apple CoreText and CoreGraphics. No Python packages or API key are required for rendering. Transcription is a separate step; a local speech model is optional.

The provided exporter targets unrotated, constant-frame-rate SDR BT.709 footage with even dimensions and MP4-compatible audio. Inspect and adapt conversion for HDR, rotation, variable frame rates, or unsupported audio before rendering.

## Render

Prepare timed phrase cards following the schema in [SKILL.md](SKILL.md), then run:

```sh
python3 scripts/render-video.py source.mov cards.json output
```

Use `--duration 15` for a draft. The output includes a lossless RGB FFV1 master (`lyrics-master.mkv`) and high-quality H.264 MP4 (`lyrics-full.mp4`). Original audio is copied. The master preserves the RGB composite losslessly; it cannot recover detail missing from the input.

The renderer writes masks and exports into the selected output folder and replaces files with those names. Use a fresh output folder for each revision.

## Synthetic example

No personal footage or song lyrics are included. Generate a three-second test pattern with a tone and render the original demonstration words:

```sh
ffmpeg -f lavfi -i 'testsrc2=size=680x454:rate=30:duration=3' -f lavfi -i 'sine=frequency=440:duration=3' -c:v libx264 -pix_fmt yuv420p -c:a aac /tmp/inverted-lyrics-demo.mp4
python3 scripts/render-video.py /tmp/inverted-lyrics-demo.mp4 examples/cards.json /tmp/inverted-lyrics-output
```

Tested with Python 3.14, Swift 6.3.3, and FFmpeg 9.0.1. No font binaries are distributed. Impact remains subject to its owner's license. FFmpeg, Swift, Python, and optional transcription models retain their own licenses.

## Terms

Use and customization for personal or commercial work are allowed; redistribution or resale of the tool is not. See [LICENSE](LICENSE). This is source-available, not an open-source license.
