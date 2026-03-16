# HON — Habits Over Numbers

An ultra-minimalist focus tracker for macOS, designed for premium simplicity and mental wellbeing.

## 🌿 Product Vision
In a world of complex productivity tools, HON returns to the essentials. We believe that **Habits** are more important than **Numbers**. HON is designed to be invisible, fast, and protective of your mental energy. It doesn't just track your time; it reminds you to stay human.

## 🚀 Key Features

### 1. Ultra-Minimalist UI
- **Grayscale Design**: No distractions, no shadows, no icons. Just your focus.
- **Native macOS Performance**: Built with Swift and SwiftUI for zero latency and low system impact.
- **260px Panel**: A quiet, fixed-width panel that drops directly from your menu bar.

### 2. Active Recall (Intelligent Recovery)
- Never worry about forgetting to start your timer. 
- HON monitors system idle time. If you return to your Mac after being idle for 5+ minutes, it automatically detects the activity and offers to reclaim that time.

### 3. Burnout Prevention (Wellness)
- **20-Minute Interruptions**: Every 20 minutes of active focus, HON gently interrupts with a vibrant yellow reminder.
- **Micro-Breaks**: Encourages you to stand up, breathe, drink water, and move to maintain long-term productivity.
- **Forced Pause**: The wellness break pauses your timer, forcing a moment of relaxation before you can resume.

### 4. Effortless Organization
- **Smart Categories**: Organize work into `Work`, `Side-hustle`, or `Personal`.
- **Custom Categories**: Create and persist your own categories on the fly.
- **Precise Tracking**: Captures every second of your focus with `H:MM:SS` precision.

### 5. Offline First & Privacy
- **Local Storage**: All data is stored locally in `~/Library/Application Support/HON/`.
- **Markdown Export**: Export your entire focus history to a clean Markdown table for your own logs or reports.

---

## 🛠 Project Structure (Monorepo)

This project is managed as a **Turborepo** monorepo:

- `apps/mac`: The native Swift/SwiftUI macOS application.
- `apps/web`: Next.js 14 web application (Landing page & future Cloud Sync).
- `packages/`: Shared configurations and components.

---

## 📦 Installation (macOS)

1. Download the latest `.dmg` from the [Releases](https://github.com/your-username/hon/releases) page.
2. Drag `HON.app` to your `Applications` folder.
3. Launch HON from your Applications.
4. *Note: If Gatekeeper blocks the app, run `xattr -cr /Applications/HON.app` in your terminal.*

---

## 👨‍💻 Development

### Prerequisites
- macOS Ventura 13.0+
- Swift 5.9+
- Node.js & pnpm (for web and monorepo management)

### Build the Mac App
```bash
pnpm --filter mac-app build
```

### Run the Web App
```bash
pnpm --filter web-app dev
```

---

## 📄 License
Offline First · Premium Simplicity · Habits Over Numbers
