# HON — Time Tracker
### macOS App Build Spec · Time Logger · v1.0

---

## What You Are Building

A **macOS menu bar app** called **HON** (Habits Over Numbers).  
This is version 1 — time tracking only.  
The app lives entirely in the macOS menu bar (system tray).  
There is no dock icon. There is no main window on launch.  
Everything happens from the menu bar.

---

## Target Environment

- **Platform:** macOS (Intel x86_64)
- **Minimum OS:** macOS Ventura 13.0
- **Language:** Swift
- **UI Framework:** SwiftUI + AppKit (for menu bar)
- **Delivery:** A signed or ad-hoc signed `.dmg` file the user can drag-install
- **Architecture:** x86_64 (Intel). Do NOT build arm64 only.

---

## Core Concept

The user starts a focus session with one click.  
The timer runs invisibly — they work, they don't watch the clock.  
When done, they stop the session.  
A small panel appears to let them optionally label what they worked on.  
Sessions are saved locally. That's it.

**Philosophy:** No friction. No forms before you start. Start → Work → Stop → Label.

---

## Menu Bar Behavior

### Icon
- Use an SF Symbol: `timer` or `clock` (filled when running, outlined when idle)
- When a session is **running**: icon pulses or has a dot indicator, title shows elapsed time updating every minute e.g. `● 1:24`
- When **idle**: plain HON icon or clock outline, no title text

### Menu Items (idle state)
```
▶  Start Focus Session        ← primary action, bold
──────────────────────
   Sessions Today              ← shows count + total time e.g. "3 sessions · 4h 12m"
   View Log                    ← opens the log panel
──────────────────────
   Quit HON
```

### Menu Items (running state)
```
■  Stop Session   ● 1:24      ← shows live elapsed time, bold
──────────────────────
   Running since 2:34 PM
──────────────────────
   Sessions Today
   View Log
──────────────────────
   Quit HON
```

---

## Session Flow

### Starting a Session
1. User clicks **Start Focus Session**
2. Session begins immediately — timestamp recorded
3. Menu bar icon updates to show running state with elapsed time
4. No other UI appears. User goes and works.

### Stopping a Session
1. User clicks **Stop Session**
2. Session end time recorded, duration calculated
3. A **small floating panel** appears (not a full window — an NSPanel)
4. Panel shows:
   - Duration in large type e.g. `2h 04m`
   - A single text field: `What did you work on? (optional)`
   - Two buttons: **Save** and **Discard**
5. User types a label or hits Save immediately
6. Panel closes. Session is saved.

### The Log Panel
- Opens when user clicks **View Log** in menu
- A clean, scrollable list of past sessions
- Each row shows:
  - Date + start time
  - Duration
  - Label (or "Unlabeled" in muted text if none)
- Grouped by day
- No editing needed in v1 — read only is fine

---

## Data Storage

- Store sessions as JSON in `~/Library/Application Support/HON/sessions.json`
- Each session object:
```json
{
  "id": "uuid-string",
  "startedAt": "ISO8601 timestamp",
  "endedAt": "ISO8601 timestamp",
  "duration": 7440,
  "label": "Career Compass landing page"
}
```
- Load on app start. Append on save. No database needed.

---

## UI Design

Follow the HON design language throughout:

**Colors**
- Background: `#F5F0E8` (warm paper)
- Primary text: `#1C1812` (ink)
- Secondary text: `#6B6456` (soft ink)
- Accent / running state: `#A07840` (dark gold)
- Muted: `#B0A898`
- Dividers: `#DDD7CC`

**Typography**
- Use system serif where possible (New York font family on macOS)
- Labels and metadata: SF Mono or monospaced system font
- Keep it minimal — no icons except SF Symbols, no decorative elements

**Stop Panel sizing**
- Width: 320px
- Height: auto ~200px
- Rounded corners: 12px
- Appears centered on screen or near menu bar
- No traffic light window buttons — use `.borderless` or `.hudWindow` style

**Log Panel sizing**
- Width: 400px, Height: 520px
- Standard macOS panel with close button
- No minimize/maximize

---

## App Configuration

**Info.plist requirements**
- `LSUIElement = YES` — no dock icon, menu bar only
- `NSHumanReadableCopyright` = HON · Habits Over Numbers
- Bundle ID: `com.hon.timetracker`
- App name: `HON`
- Version: `1.0.0`

**Entitlements**
- No special entitlements needed for v1
- Ad-hoc signing is fine for personal use install

---

## Build & Delivery Instructions

1. Build target: **macOS** · Architecture: **x86_64**
2. Scheme: Release build
3. Export as `.app` bundle
4. Package into `.dmg` using `hdiutil`:
```bash
hdiutil create -volname "HON" \
  -srcfolder "./build/Release/HON.app" \
  -ov -format UDZO \
  ./HON-1.0.dmg
```
5. The `.dmg` should open to a window with `HON.app` and an alias to `/Applications`
6. The user drags HON.app to Applications and runs it

---

## Launch at Login (optional, implement if straightforward)

Add a toggle in the menu:
```
   Launch at Login   ✓
```
Use `SMLoginItemSetEnabled` or `LaunchAtLogin` package.  
If this adds complexity, skip for v1.

---

## What This App Does NOT Do (v1 scope)

- No money tracking
- No habit tracking  
- No energy logging
- No iCloud sync
- No notifications or reminders
- No Pomodoro or timers with goals
- No analytics or charts
- No export

All of those are future HON pillars. This is purely: **start, stop, label, log.**

---

## Summary Checklist for Gemini

- [ ] SwiftUI + AppKit menu bar app
- [ ] `LSUIElement = YES` (no dock icon)
- [ ] Menu bar icon updates live during session
- [ ] One-click start from menu
- [ ] Stop reveals small floating label panel
- [ ] Sessions saved to JSON locally
- [ ] Log panel shows history grouped by day
- [ ] Warm paper color palette throughout
- [ ] Builds as x86_64 for Intel Mac
- [ ] Delivered as installable `.dmg`
