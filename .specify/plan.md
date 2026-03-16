# HON Development Plan v1.0

## Phase 1: Project Setup & Architecture
1. Initialize Xcode project with SwiftUI.
2. Configure `Info.plist` for `LSUIElement = YES` (Menu Bar Only).
3. Set up folder structure (Models, Views, Utilities, Data).
4. Define the `Session` model and JSON storage logic.

## Phase 2: Menu Bar Infrastructure
1. Implement `StatusBarController` using AppKit to manage the `NSStatusItem`.
2. Create the SwiftUI menu content (Start/Stop, Session counts).
3. Implement the live timer display in the menu bar title.

## Phase 3: Session Lifecycle & UI
1. Implement Start/Stop logic with persistence.
2. Build the "Stop Panel" (NSPanel) for labeling sessions.
3. Design the Log Panel (History View) with grouped entries.

## Phase 4: Styling & Polishing
1. Apply the HON color palette and typography.
2. Fine-tune the floating panel behaviors (no title bar, rounded corners).
3. Implement "Launch at Login" if feasible.

## Phase 5: Build & Distribution
1. Configure Release scheme for x86_64 architecture.
2. Create DMG packaging script using `hdiutil`.
3. Final validation against the spec checklist.
