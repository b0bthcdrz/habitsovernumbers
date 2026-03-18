import Foundation
import Cocoa
import Combine
import UniformTypeIdentifiers
import Quartz
import IOKit

struct Session: Identifiable, Codable {
    let id: UUID
    let startedAt: Date
    let endedAt: Date
    let duration: TimeInterval
    let label: String?
    let category: String
}

class SessionManager: ObservableObject {
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var isCompleted = false
    @Published var isNaming = false
    @Published var isWellnessBreak = false
    @Published var isIdleConfirmation = false
    @Published var elapsedSeconds = 0
    @Published var wellnessSeconds = 0
    @Published var taskLabel = ""
    @Published var selectedCategory = "Personal"
    @Published var categories: [String] = ["Work", "Side-hustle", "Personal"]
    @Published var sessions: [Session] = []
    
    // Active Recall properties
    @Published var detectedStartTime: Date?
    private var idleCheckTimer: Timer?
    private var wasIdle = false
    private let idleThreshold: TimeInterval = 300 // 5 minutes
    
    private var timer: Timer?
    private let sessionsFileURL: URL
    private let categoriesFileURL: URL
    
    var onPanelAction: (() -> Void)?
    
    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let honDir = appSupport.appendingPathComponent("HON")
        
        if !FileManager.default.fileExists(atPath: honDir.path) {
            try? FileManager.default.createDirectory(at: honDir, withIntermediateDirectories: true)
        }
        
        sessionsFileURL = honDir.appendingPathComponent("sessions.json")
        categoriesFileURL = honDir.appendingPathComponent("categories.json")
        
        loadSessions()
        loadCategories()
        startBackgroundMonitoring()
    }
    
    // MARK: - Background Monitoring
    
    private func startBackgroundMonitoring() {
        idleCheckTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.checkSystemState()
        }
    }
    
    private func getSystemIdleTime() -> TimeInterval {
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iterator)
        if result != kIOReturnSuccess { return 0 }
        
        defer { IOObjectRelease(iterator) }
        let entry = IOIteratorNext(iterator)
        if entry == 0 { return 0 }
        
        defer { IOObjectRelease(entry) }
        var dict: Unmanaged<CFMutableDictionary>?
        let dictResult = IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0)
        
        if dictResult != kIOReturnSuccess { return 0 }
        let properties = dict?.takeRetainedValue() as? [String: Any]
        let idleTimeNano = properties?["HIDIdleTime"] as? Int64 ?? 0
        
        return TimeInterval(idleTimeNano) / 1_000_000_000.0
    }
    
    private func checkSystemState() {
        let secondsSinceLastEvent = getSystemIdleTime()
        
        // Debug logging enabled by default to help diagnosis
        if secondsSinceLastEvent > 10 {
            print("Idle check: secondsSinceLastEvent = \(Int(secondsSinceLastEvent))s")
        }

        // A very large value (like 2^32 or similar) usually means the system call failed or permissions are missing.
        // We ignore values that are physically impossible for a single session ( > 24 hours).
        let isReasonableValue = secondsSinceLastEvent < 86_400 
        
        if isRunning && !isPaused {
            // While running: Check for sudden idleness (5 mins)
            if isReasonableValue && secondsSinceLastEvent > idleThreshold && !isIdleConfirmation {
                print("Triggering idle confirmation: idle for \(Int(secondsSinceLastEvent))s")
                triggerIdleConfirmation()
            }
        } else if !isRunning {
            // While idle: Active Recall logic
            if isReasonableValue && secondsSinceLastEvent > idleThreshold {
                wasIdle = true
                detectedStartTime = nil
            } else if wasIdle && secondsSinceLastEvent < 5 {
                detectedStartTime = Date().addingTimeInterval(-secondsSinceLastEvent)
                wasIdle = false
            }
        }
    }
    
    // MARK: - Session Lifecycle
    
    func initiateStart() {
        isNaming = true
        isCompleted = false
        isRunning = false
        isWellnessBreak = false
        isPaused = false
        isIdleConfirmation = false
    }
    
    func start(fromDetected: Bool = false) {
        let actualStart = (fromDetected && detectedStartTime != nil) ? detectedStartTime! : Date()
        
        isNaming = false
        isRunning = true
        isPaused = false
        isCompleted = false
        isWellnessBreak = false
        isIdleConfirmation = false
        
        elapsedSeconds = Int(Date().timeIntervalSince(actualStart))
        wellnessSeconds = elapsedSeconds
        
        detectedStartTime = nil
        wasIdle = false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, self.isRunning, !self.isPaused else { return }
            self.elapsedSeconds += 1
            self.wellnessSeconds += 1
            
            if self.wellnessSeconds >= 1200 {
                self.triggerWellnessBreak()
            }
        }
    }
    
    func triggerWellnessBreak() {
        isWellnessBreak = true
        // We don't pause immediately here, we let the user press the button as per instructions
        onPanelAction?()
    }
    
    func startManualBreak() {
        isPaused = true
        isWellnessBreak = false
        wellnessSeconds = 0
    }
    
    func pauseForWellness() {
        isPaused = true
        isWellnessBreak = false
        wellnessSeconds = 0 // Reset counter for next 20 mins
    }
    
    func continueWorking() {
        isWellnessBreak = false
        wellnessSeconds = 0 // Reset counter for next 20 mins
    }
    
    func triggerIdleConfirmation() {
        isIdleConfirmation = true
        isPaused = true // Pause immediately on idle detection
        onPanelAction?()
    }
    
    func resumeSession() {
        isPaused = false
        isWellnessBreak = false
        isIdleConfirmation = false
    }
    
    func stop() {
        isRunning = false
        isPaused = false
        isCompleted = true
        isWellnessBreak = false
        isIdleConfirmation = false
        timer?.invalidate()
        timer = nil
    }
    
    func saveSession() {
        let end = Date()
        let start = end.addingTimeInterval(-Double(elapsedSeconds))
        let finalLabel = taskLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : taskLabel
        
        let newSession = Session(
            id: UUID(),
            startedAt: start,
            endedAt: end,
            duration: Double(elapsedSeconds),
            label: finalLabel,
            category: selectedCategory
        )
        
        sessions.append(newSession)
        saveSessions()
        
        isCompleted = false
        taskLabel = ""
        elapsedSeconds = 0
        wellnessSeconds = 0
        isRunning = false
    }
    
    func discardSession() {
        isCompleted = false
        isRunning = false
        isPaused = false
        taskLabel = ""
        elapsedSeconds = 0
        wellnessSeconds = 0
    }
    
    func cancelNaming() {
        isNaming = false
        taskLabel = ""
    }
    
    func addCategory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !categories.contains(trimmed) else { return }
        categories.append(trimmed)
        selectedCategory = trimmed
        saveCategories()
    }
    
    // MARK: - Formatting
    
    func formatTimer() -> String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return String(format: "%d:%02d:%02d", h, m, s)
    }
    
    func formatCompletedDuration() -> String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        
        if h > 0 {
            return String(format: "%dh %02dm %02ds", h, m, s)
        } else if m > 0 {
            return String(format: "%dm %02ds", m, s)
        } else {
            return String(format: "%ds", s)
        }
    }
    
    func formatDuration(_ seconds: Double) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 {
            return String(format: "%dh %02dm", h, m)
        } else if m > 0 {
            return String(format: "%dm %02ds", m, s)
        } else {
            return String(format: "%ds", s)
        }
    }
    
    // MARK: - Persistence
    
    private func loadSessions() {
        guard let data = try? Data(contentsOf: sessionsFileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let loaded = try? decoder.decode([Session].self, from: data) {
            sessions = loaded
        }
    }
    
    private func saveSessions() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(sessions) {
            try? data.write(to: sessionsFileURL)
        }
    }
    
    private func loadCategories() {
        guard let data = try? Data(contentsOf: categoriesFileURL) else { return }
        if let loaded = try? JSONDecoder().decode([String].self, from: data) {
            categories = loaded
        }
    }
    
    private func saveCategories() {
        if let data = try? JSONEncoder().encode(categories) {
            try? data.write(to: categoriesFileURL)
        }
    }
    
    func exportToMarkdown() {
        let savePanel = NSSavePanel()
        if let mdType = UTType(filenameExtension: "md") {
            savePanel.allowedContentTypes = [mdType]
        }
        savePanel.nameFieldStringValue = "hon_sessions.md"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                var markdown = "# HON Focus Sessions\n\n"
                markdown += "| Date | Duration | Category | Label |\n"
                markdown += "| :--- | :--- | :--- | :--- |\n"
                
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                
                for session in self.sessions.reversed() {
                    let label = session.label ?? "Unlabeled"
                    let date = formatter.string(from: session.startedAt)
                    let duration = self.formatDuration(session.duration)
                    let category = session.category
                    markdown += "| \(date) | \(duration) | \(category) | \(label) |\n"
                }
                
                try? markdown.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}
