# HON Monorepo Task List

## [x] Phase 1: Native macOS UI Revamp (v2.0)
- [x] T1.1: Initialize clean `HONv2` workspace with `Makefile` and `Info.plist`.
- [x] T1.2: Implement `SessionManager.swift` to handle live timer and formatting.
- [x] T1.3: Build exact replica of HTML/CSS in `ContentView.swift` (Grayscale, 260px wide, custom fonts/buttons).
- [x] T1.4: Implement `AppDelegate.swift` with custom floating `NSPanel` under menu bar.
- [x] T1.5: Compile and package into `HON-2.0.0.dmg`.

## [x] Phase 2: Monorepo & Web Scaffolding
- [x] T2.1: Initialize Turborepo monorepo with `apps/` and `packages/`.
- [x] T2.2: Move native app to `apps/mac` and configure for monorepo.
- [x] T2.3: Scaffold Next.js app in `apps/web` with Supabase integration.
- [x] T2.4: Initialize Git repository and `changesets` for semantic versioning.
- [x] T2.5: Design minimalist grayscale landing page for `apps/web`.

## [ ] Phase 3: Subscription & Sync Integration
- [ ] T3.1: Configure Supabase Auth (Google Login) in `apps/web`.
- [ ] T3.2: Setup Stripe subscription flow in `apps/web`.
- [ ] T3.3: Implement secure API for syncing local sessions to Supabase.
- [ ] T3.4: Integrate web auth token into `apps/mac` for optional cloud sync.
