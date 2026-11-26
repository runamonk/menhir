# Menhir

Started life as "WatchFace1", then "Simple Monolith". That name was taken in the store, so it became Menhir (another big standing stone). The Monolith* classes and files were renamed to Menhir* on 2026-11-26. The app ID didn't change, so settings saved on the watch carry over.

A Garmin Connect IQ watch face (Monkey C) for the user's **fēnix 8 Pro 51mm** (round AMOLED).

## Background
- Based loosely on the "Bezel Monolith" Connect IQ store face (free, by Bezel), which the user downloaded:
  https://apps.garmin.com/en-US/apps/84d8c32c-3d20-4586-aa24-c06524e82e3d
- Its store blurb: stacked numerals, warm ivory lettering and a coral accent, with 8 accent palettes, 3 configurable data slots, and font, 12/24h and date options.
- Store faces are hidden from USB/MTP, and they're compiled anyway, so the layout was copied by eye from the store preview screenshots. None of its code was used.
- The user wanted it **simple**, so the accent palettes and font options were left out. The first version had fixed fields. The 5 configurable slots, per-slot colors and the on-watch settings menu were added afterwards.

## What it draws (source/MenhirView.mc)
- Top field at 24% of the height (default: dim date, "THU 26").
- Big ivory HH:MM on one line at 44% (FONT_NUMBER_THAI_HOT, falling back to NUMBER_HOT if it's too wide).
- A coral rule at 63%, as wide as the time text, then three values with no labels. Left is left-aligned to the rule's start, right is right-aligned to the rule's end, and middle is centered in the gap between them, so a wide left value like "100%" can't run into it. If the three don't fit the rule with an 8%-of-width gap, the whole row drops from FONT_SMALL to TINY to XTINY, icons included (defaults: ivory battery %, heart rate, weather).
- Bottom field at 83% (default: steps), with a step-goal bar (dim track, coral fill) that shows only when that slot is set to Steps. The "Step bar" setting picks Curved (default: a 6px arc hugging the edge, centered on 6 o'clock from 7 to 5 o'clock (240° to 300°)) or Straight (a short line at 89%).
- On-watch settings (source/MenhirSettings.mc): a field and a color for each of the 5 slots, saved in Application.Storage. Divider and step bar fill colors are color indices 5 and 6 (keys "c5", "c6", default Coral). The bar's track stays Dim. Icons (source/Icons.mc) are drawn from shapes, so they take the slot color: bolt, footprints, heart, flame, pin, stairs, bell. Weather maps the condition to sun/moon (moon after sunset)/partly/cloud/rain/snow/storm/fog. Date and None get no icon, and an "Icons" On/Off setting turns them all off. Field options are stored by index, so add new ones at the end of Cfg.FIELDS (Weather, index 9, is the current temperature; Battery days, index 10, is SystemStats.batteryInDays shown as "5d" with the bolt icon). The menu steps through Cfg.FIELD_ORDER (None, then alphabetical), so a new field also needs a spot there. Selecting a menu item steps it to the next option. This is a menu on the watch, not phone settings: the Connect IQ phone app only shows settings for store-installed apps, and this face is sideloaded.
- AMOLED always-on (onEnterSleep + requiresBurnInProtection): a small date over HH:MM, shifted a few px each minute. Drawn in the "AOD brightness" gray: Low 0x5A5650, Medium 0x8A8478 (default, same as DIM), High 0xC8C0B0. Connect IQ can't set the real screen brightness, so this is the only control.
- Colors: IVORY 0xF2E8D5, DIM 0x8A8478, CORAL 0xFF6F5E.

## Status / next steps
- Compiles cleanly (2026-11-26) with SDK 9.3.0 and the Monkey C VS Code extension 1.1.3.
- Product ID is `fenix8pro47mm`. Garmin has no separate 51mm profile; that one covers 47mm, 51mm and MicroLED (454x454).
- Developer key: %USERPROFILE%\.garmin\developer_key.der (.pem alongside).
- Build: monkeyc -f monkey.jungle -d fenix8pro47mm -o bin\Menhir.prg -y <key> -w
- Store package: monkeyc -e -f monkey.jungle -o bin\Menhir.iq -y <key> -w (builds for every product in manifest.xml).
- Harmless warning: the 70x70 launcher icon gets scaled to 65x65.
- "Ship it" means: build bin\Menhir.prg and bin\Menhir.iq, commit and push to main, then copy Menhir.prg to the watch if it's connected. bin/ is gitignored, so the .iq stays local.
- README screenshots (docs/screenshot.png, docs/always-on.png) come from the simulator's File > Save Screen Capture (454x454), masked round. Data used: Simulation > Activity Monitoring > Set Activity Monitor Info (goal 10,000, 6,842 steps), the default simulated weather, and Activity Data playback for heart rate. docs/logo.svg is a hand-drawn standing stone on the coral rule. Store images are rendered with headless Edge (the command is in each HTML file's comment): docs/hero.png (1440x720 hero) from docs/hero.html, and docs/cover.png (500x500 cover) from docs/cover.html. The store wants images under 300 KB, and the hero PNG is ~380 KB, so upload docs/hero.jpg (quality 92, ~73 KB) instead. Re-render them if screenshot.png or logo.svg change.
- Layout percentages were guessed from a tiny thumbnail. Expect to tweak them in the simulator.
- Sideloading: the watch shows up in Windows as the MTP device "fenix 8 Pro - 51mm" (no drive letter). Copy the .prg to Internal Storage\GARMIN\Apps. It can be done from PowerShell through the Shell.Application COM object (NameSpace(17)).

## User preferences
- Keep it simple, make no unnecessary changes, and don't add needless abstractions.
- Tone: a grumpy, direct senior dev.
