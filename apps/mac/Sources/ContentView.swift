import SwiftUI

struct ContentView: View {
    @ObservedObject var manager: SessionManager
    @State private var showLog = false
    @State private var isAddingCategory = false
    @State private var newCategoryName = ""
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isNewCategoryFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if manager.isWellnessBreak {
                wellnessView
            } else if manager.isIdleConfirmation {
                idleConfirmationView
            } else if manager.isPaused {
                pausedView
            } else if manager.isCompleted {
                completedState
            } else if manager.isNaming {
                namingState
            } else if manager.isRunning {
                activeState
            } else {
                idleState
            }
            
            if !manager.isWellnessBreak && !manager.isIdleConfirmation && !manager.isPaused {
                if showLog {
                    Divider().padding(.vertical, 12).foregroundColor(Color(hexString: "#d0d0d0"))
                    miniLogView
                }
                
                Button(action: {
                    withAnimation {
                        showLog.toggle()
                    }
                }) {
                    Text(showLog ? "Hide Log" : "View Log")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Color(hexString: "#aaaaaa"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit HON")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(Color(hexString: "#aaaaaa"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(width: 260)
        .background(manager.isWellnessBreak ? Color(hexString: "#FFCC00") : Color.white)
        .animation(.easeInOut, value: manager.isWellnessBreak)
    }
    
    var idleState: some View {
        VStack(spacing: 12) {
            Text("0:00:00")
                .font(.system(size: 36, weight: .medium, design: .monospaced))
                .foregroundColor(Color(hexString: "#aaaaaa"))
                .frame(maxWidth: .infinity, alignment: .center)
            
            if let detectedTime = manager.detectedStartTime {
                VStack(spacing: 4) {
                    Text("Activity detected \(formatRelativeTime(detectedTime))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hexString: "#A07840"))
                    
                    Button(action: {
                        manager.initiateStart()
                    }) {
                        Text("Start Focus Session")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(hexString: "#111111"))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Button(action: {
                    manager.initiateStart()
                }) {
                    Text("Start Focus Session")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(hexString: "#111111"))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    var namingState: some View {
        VStack(spacing: 12) {
            Text("What are you working on?")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            TextField("", text: $manager.taskLabel, prompt: Text("Project name...").foregroundColor(Color(hexString: "#999999")))
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
                .padding(.bottom, 6)
                .overlay(Rectangle().frame(height: 1).foregroundColor(Color(hexString: "#d0d0d0")), alignment: .bottom)
                .focused($isTextFieldFocused)
                .onAppear {
                    isTextFieldFocused = true
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hexString: "#aaaaaa"))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(manager.categories, id: \.self) { category in
                            CategoryChip(name: category, isSelected: manager.selectedCategory == category) {
                                manager.selectedCategory = category
                            }
                        }
                        
                        Button(action: {
                            isAddingCategory = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hexString: "#aaaaaa"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hexString: "#f5f5f5"))
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            if isAddingCategory {
                HStack {
                    TextField("New category...", text: $newCategoryName)
                        .font(.system(size: 12))
                        .textFieldStyle(.plain)
                        .focused($isNewCategoryFocused)
                        .onSubmit {
                            manager.addCategory(newCategoryName)
                            newCategoryName = ""
                            isAddingCategory = false
                        }
                    
                    Button("Add") {
                        manager.addCategory(newCategoryName)
                        newCategoryName = ""
                        isAddingCategory = false
                    }
                    .font(.system(size: 10))
                    .buttonStyle(.plain)
                }
                .padding(8)
                .background(Color(hexString: "#f5f5f5"))
                .cornerRadius(8)
                .onAppear { isNewCategoryFocused = true }
            }
            
            VStack(spacing: 8) {
                Button(action: {
                    manager.start(fromDetected: false)
                }) {
                    Text("Start Now")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(hexString: "#111111"))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                if let detectedTime = manager.detectedStartTime {
                    Button(action: {
                        manager.start(fromDetected: true)
                    }) {
                        Text("Start from \(formatClockTime(detectedTime))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(hexString: "#f5f5f5"))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Button(action: {
                manager.cancelNaming()
            }) {
                Text("Cancel")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(hexString: "#aaaaaa"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
    
    var activeState: some View {
        VStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(manager.taskLabel.isEmpty ? "Unlabeled" : manager.taskLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.black)
                    .lineLimit(1)
                
                Text(manager.selectedCategory)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(hexString: "#aaaaaa"))
            }
            
            Text(manager.formatTimer())
                .font(.system(size: 36, weight: .medium, design: .monospaced))
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button(action: {
                manager.stop()
            }) {
                Text("Stop")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(hexString: "#111111"))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
    }
    
    var completedState: some View {
        VStack(spacing: 12) {
            Text(manager.formatCompletedDuration())
                .font(.system(size: 36, weight: .medium, design: .monospaced))
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Saved locally")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(hexString: "#aaaaaa"))
            
            Button(action: {
                manager.saveSession()
            }) {
                Text("Done")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(hexString: "#111111"))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                manager.discardSession()
            }) {
                Text("Discard")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(hexString: "#aaaaaa"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
    
    var wellnessView: some View {
        VStack(spacing: 20) {
            Text("Wellness Break")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Text("Stand up, relax, breathe, drink, and walk to unwind.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            
            Button(action: {
                manager.pauseForWellness()
            }) {
                Text("Pause & Relax")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 20)
    }
    
    var idleConfirmationView: some View {
        VStack(spacing: 20) {
            Text("Are you still there?")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Text("Inactivity detected. The timer has been paused.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hexString: "#666666"))
                .multilineTextAlignment(.center)
            
            Button(action: {
                manager.resumeSession()
            }) {
                Text("Continue Focus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 20)
    }
    
    var pausedView: some View {
        VStack(spacing: 20) {
            Text("Session Paused")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hexString: "#aaaaaa"))
            
            Text(manager.formatTimer())
                .font(.system(size: 36, weight: .medium, design: .monospaced))
                .foregroundColor(Color(hexString: "#aaaaaa"))
            
            Button(action: {
                manager.resumeSession()
            }) {
                Text("Continue Focus Session")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hexString: "#111111"))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                manager.stop()
            }) {
                Text("Finish Session")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hexString: "#aaaaaa"))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 20)
    }
    
    var miniLogView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(manager.sessions.suffix(5).reversed()) { session in
                HStack(alignment: .top) {
                    Text(manager.formatDuration(session.duration))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.black)
                        .frame(width: 50, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(session.label ?? "Unlabeled") · \(session.category)")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color.black)
                            .lineLimit(1)
                        
                        Text(formatDate(session.startedAt))
                            .font(.system(size: 9, weight: .regular))
                            .foregroundColor(Color(hexString: "#aaaaaa"))
                    }
                }
            }
            
            if manager.sessions.isEmpty {
                Text("No history yet.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(hexString: "#aaaaaa"))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Button(action: {
                manager.exportToMarkdown()
            }) {
                Text("Export to Markdown...")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(hexString: "#aaaaaa"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func formatClockTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CategoryChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(hexString: "#aaaaaa"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? Color.black : Color(hexString: "#f5f5f5"))
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

extension Color {
    init(hexString: String) {
        let scanner = Scanner(string: hexString.replacingOccurrences(of: "#", with: ""))
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
