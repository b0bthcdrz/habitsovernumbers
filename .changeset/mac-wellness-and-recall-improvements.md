---
'mac': minor
---

- Switched to IOKit hardware idle timer for significantly more reliable inactivity tracking.
- Fixed wellness break buttons to correctly transition to paused state.
- Added "Continue working" option to wellness breaks to reset the break timer.
- Added manual "Take a Break" button to the active timer view.
- Swapped "Stop" and "Take a Break" styles to prioritize breaks over stopping.
- Added "Are you working?" active recall prompt that triggers after 2 minutes of untracked activity.
