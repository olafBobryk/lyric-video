---
name: lyric-video
description: Create lyric videos with user-selected typography and reveal styles, word-level timing, an unclear-transcript review and correction loop, and verified exports. Includes an optional inverted-footage typography preset.
---

# Lyric video

Turn the user's recording into a lyric video. Treat transcript accuracy, timing, and visual style as separate decisions. Preserve the original source; render revisions into separate output folders.

## Choose the style

Honor the user's selected or previously approved style. If no style is established, ask one concise question about typography, placement, and reveal behavior before committing to a look. Offer a few relevant choices, such as plain subtitles, a karaoke highlight, or oversized kinetic lettering. Do not automatically apply inversion, Impact, capitals, stretched lettering, or a 10% margin to every video.

For inverted footage inside oversized letters with progressive word reveals and alternating dominant rows, read [references/inverted-style.md](references/inverted-style.md). The included scripts implement that preset; adapt or use another rendering method for other styles rather than claiming they support every treatment.

Use a representative still and a short motion draft when requested. Carry the approved style into the full video; do not introduce repeat approval gates.

## Transcribe and review unclear lyrics

1. Inspect the source duration, frame rate, dimensions, rotation, color space/range, and audio. Transcribe the recording and obtain acoustic word timestamps. Do not use uniformly spaced words as final alignment.
2. Check uncertain recognition, conflicting transcription passes, suspicious phrases, ad-libs, and clipped endings. A second model can help, but agreement does not prove correctness. Distinguish an uncertain lyric from an uncertain timestamp.
3. If useful, ask for a song/artist or supplied lyric reference. If the recording is personal, unreleased, or has no available reference, stop searching for one and use the user's review. Never publish their media or lyrics with the skill.
4. Produce an editable timestamped transcript and a compact numbered list of unclear spans in playback order. Each item includes a stable ID, start/end, and enough surrounding words to locate it. Mark unresolved wording as `[UNCLEAR]` instead of silently choosing a guess. Include other suspected errors even if they were not originally marked. Keep this list unchanged while awaiting corrections.
5. Ask the user to supply the missing words by ID or in that order. Continue independent styling/export preparation. If authorized, provide a review cut with the placeholders and label it clearly; do not call it lyric-final.
6. Apply an ordered reply one-to-one to the numbered spans. Verify the number of corrections matches. If the count or intended span is ambiguous, ask only about that mapping before changing those words. Preserve user-supplied wording, slang, and explicit lyrics. Mention minor spelling normalization; never silently rewrite lyrics for grammar.
7. Expand multiword corrections into individually timed words and realign against the recording. Retain approved layout choices unless the phrase needs reflow. If timing can only be estimated, disclose that and keep timing review separate from wording approval. Do not squeeze a longer phrase into a tiny remaining interval and claim accurate synchronization. For a cut-off ending, explain what the recording supports; ask for the continuation or a choice before extending, freezing, or changing the edit.
8. Update both the transcript and timed render data, then render from the original source. Check all corrected spans and transitions. Search the actual final card/subtitle data for `[UNCLEAR]`, question-mark placeholders, TODOs, and unresolved IDs; verify every user correction is present exactly once in its intended location. Do not mistake uncertainty notes in a review document for on-screen leftovers.
9. When asked whether the video is ready to send, report separately: placeholder count, remaining suspected wording, timing caveats, and export verification. Zero placeholders is not proof of a fully verified transcript. Give a brief conclusion without exposing private reasoning; call it ready as a review cut when unresolved issues remain.

## Timing and exports

Local MLX Whisper with word timestamps is one transcription route on Apple silicon. Whisper.cpp DTW may require disabling flash attention if it returns `t_dtw = -1`; reject missing timestamps. Reference lyrics must be aligned to this particular performance, including pauses and ad-libs.

Render from the source rather than a compressed draft. Preserve source framing, real resolution, frame rate, color interpretation, and audio unless the user requests changes. For maximum quality, provide a lossless RGB composite master and a compatible high-quality MP4. Upscaling alone does not recover detail. Check platform/codec constraints before choosing export settings.

Verify duration/frame count, audio presence and preservation, beginning/end coverage, text fit, partially and fully revealed phrases, correction coverage, and the chosen visual effect. Provide direct artifact links and an inline preview where supported. Keep review status and encoding quality distinct.
