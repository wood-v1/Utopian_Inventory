# Inventory opening: measured resource bottlenecks

## Baseline, 2026-09-06

User-run quicksave session, native build `2026.09.05-inventory-open-profiler-1`,
Haruspex, 1920x1080 layout, 19 stacks and one equipment item. Eleven openings:
one process-cold and ten warm. This is the baseline **after** the previous
packed-layout/cache-scan cleanup, not a measurement of the original release.
Full local log preserved at `tmp/resource-open-baseline/Debug-before.log`;
session begins at byte 72070 and ends at byte 107189.

| Operation (ms) | First opening | Warm range |
| --- | ---: | ---: |
| Native XML creation | 97.215 | 16.524–17.495 |
| Open sound call | 73.229 | 128.835–202.952 |
| Background image load | 156.654 | 145.777–151.861 |
| Player doll image load | 22.584 | 16.599–16.974 |
| Money image load | 5.908 | 5.090–5.327 |
| Layout variable batch | 0.697 | 0.513–0.627 |
| Inventory snapshot | 12.608 | 5.526–7.346 |
| Elapsed to first item | 398.643 | 339.380–419.126 |
| Elapsed to population complete | 639.958 | 557.797–640.987 |

Execution order: native prepare → native XML creation → root script setup →
open sound → background → chrome → doll → money → first update → layout and
inventory snapshot → incremental slot population across updates. Script setup
and image loading happen **after** `create_window_end`, not inside `create_us`.
The roughly 220 ms from first item to completion includes inter-update gaps;
it must not be presented as one continuous frame stall. The probes measure
wall-clock call intervals, not CPU sampling or GPU frame/present timing.

## Resource-focused patch (iteration 2)

- Only the open sound switches from `stream=0` to `stream=1`; the OGG, volume,
  loop setting and playback call stay unchanged. Shared XML generation applies
  this to player, container and corpse windows. Other sounds are unchanged.
- Only the three player backgrounds and three player dolls change DDS encoding
  from DXT to RGBA8. Build-time conversion first produces the original DXT and
  decodes it, preserving its quantized pixels and alpha exactly. No dimensions,
  crops, layout coordinates, item resources or inventory state logic change.
  Six files grow from 848,640 to 5,917,068 bytes total. Runtime memory/VRAM and
  final filtering differences still need observation on the actual renderer.
- Buffered profiling steps are emitted in chunks below the logger's 4096-byte
  limit. The previous trace truncated late slot samples. Flush still occurs
  after the completion timestamp, not inside the measured resource calls.

Mechanism evidence comes from the locally available **beta engine source**,
not proof of identical implementation in the installed HD executable:
`Sound/Sound.cpp` uses `ForceLoad`/`WaitForFinished` before non-streaming playback;
`Sound/AsyncStream.cpp` queues asynchronous loading. `Renderers/D3D9/TexturePlain.cpp`
uses D3DX default dimensions/format for DDS loading; resizing a non-power-of-two
compressed texture can entail recompression. The runtime trace independently
confirms which calls are expensive, but only a new run can establish the gain.

## Validation and next measurement

- Asset regeneration and XML parsing passed for all 16 generated layouts.
- All six new textures have byte-identical decoded RGBA pixels and dimensions
  compared with the saved pre-patch assets. Small textures/loot dolls unchanged.
- Win32 Release DLL build passed. This patch does not modify Lua/DSL; the earlier
  Lua batch was compiler-validated separately.
- No after-patch game timings, visual verification, sound timing verification,
  allocation counts or GC measurements are claimed yet. Native GUI control was
  unavailable, so the baseline openings were performed by the user.

Restart the game, load the same quicksave, open once, then close/reopen ten times.
Keep the cursor off slots for the timing series. Compare matching phase deltas
and check the background/doll appearance and one-shot sound (including rapid
close/reopen). Separately check item movement, counts, equipment, page switching,
tooltips and loot. No new data cache was introduced, so no new invalidation
contract exists. Native XML cold setup, money image loading, inventory snapshot
and incremental population remain candidates after remeasurement. Keep
`[Debug] Enabled=1` for this comparison; disable verbose tracing for a final
gameplay check after investigation.

## Sound timing correction (iteration 3)

The user confirmed a large improvement in opening responsiveness with iteration
2, but reported that the open cue arrived about two seconds late. Streaming is
therefore rejected for this short UI cue. The subsequent log contains the new
native version and open/close events, but no script phase records, so there is
**no numerical after/before comparison** for that run. Its local copy is
`tmp/resource-open-baseline/Debug-streaming-after.log` (117339 bytes).

Iteration 3 restores `stream=0` in the 16 existing layouts. A new resource-only
`inv_overhaul_sound_cache.xml` is registered as a persistent `playerstat.xml`
companion using the existing OynonTools API. It starts the non-streaming sound
load before inventory use and retains the resource until the HUD station is
destroyed; it never plays, polls, receives scripted input, or draws content.
Its one-pixel form is outside the viewport. Existing per-inventory playback
instances, sound file, loop flag, volume behavior and close-time lifetime stay
unchanged. In the available beta engine source, `CreateSoundBuffer` shares
decoded buffers by filename/reference count; a live preload resource avoids
re-decoding the same OGG. New per-window sound jobs can still wait on the engine
loader, so actual HD playback latency and warm-opening cost need remeasurement.
The RGBA8 textures are retained without further changes.

Debug publication is now reasserted on every player-inventory prepare callback.
Previously its native success flag was cached at HUD creation; restored engine
variables could invalidate that assumption after a save load. Removing that
assumption costs one console-variable publication per open and is intended to
restore script probes. This possible cause of the missing probes remains to be
confirmed by the next log.

Validation: Win32 Release build and XML parsing passed; comparing all 16 layouts
against the installed iteration 2 showed only the open-sound stream flag changed.
The preload form has no script and references exactly the existing OGG filename.
No Lua source or inventory state/cache logic changed in iteration 3. Check the
first opening after quicksave, ten warm openings, rapid close/reopen, loot sounds,
and another save load. Game playback and timings still require a user-run check.
