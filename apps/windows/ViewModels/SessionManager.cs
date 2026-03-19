using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Timers;
using Newtonsoft.Json;

namespace HON.Windows.ViewModels
{
    public class Session : INotifyPropertyChanged
    {
        public Guid Id { get; set; }
        public DateTime StartedAt { get; set; }
        public DateTime EndedAt { get; set; }
        public double Duration { get; set; }
        public string? Label { get; set; }
        public string Category { get; set; } = "Personal";

        public event PropertyChangedEventHandler? PropertyChanged;
    }

    public class SessionManager : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler? PropertyChanged;

        private bool _isRunning;
        public bool IsRunning { get => _isRunning; set { _isRunning = value; OnPropertyChanged(); } }

        private bool _isPaused;
        public bool IsPaused { get => _isPaused; set { _isPaused = value; OnPropertyChanged(); } }

        private bool _isCompleted;
        public bool IsCompleted { get => _isCompleted; set { _isCompleted = value; OnPropertyChanged(); } }

        private bool _isNaming;
        public bool IsNaming { get => _isNaming; set { _isNaming = value; OnPropertyChanged(); } }

        private bool _isWellnessBreak;
        public bool IsWellnessBreak { get => _isWellnessBreak; set { _isWellnessBreak = value; OnPropertyChanged(); } }

        private bool _isIdleConfirmation;
        public bool IsIdleConfirmation { get => _isIdleConfirmation; set { _isIdleConfirmation = value; OnPropertyChanged(); } }

        private bool _isAreYouWorkingPrompt;
        public bool IsAreYouWorkingPrompt { get => _isAreYouWorkingPrompt; set { _isAreYouWorkingPrompt = value; OnPropertyChanged(); } }

        private int _elapsedSeconds;
        public int ElapsedSeconds { get => _elapsedSeconds; set { _elapsedSeconds = value; OnPropertyChanged(); OnPropertyChanged(nameof(TimerDisplay)); } }

        private int _wellnessSeconds;
        public int WellnessSeconds { get => _wellnessSeconds; set { _wellnessSeconds = value; OnPropertyChanged(); } }

        private string _taskLabel = "";
        public string TaskLabel { get => _taskLabel; set { _taskLabel = value; OnPropertyChanged(); } }

        private string _selectedCategory = "Personal";
        public string SelectedCategory { get => _selectedCategory; set { _selectedCategory = value; OnPropertyChanged(); } }

        public ObservableCollection<string> Categories { get; set; } = new() { "Work", "Side-hustle", "Personal" };
        public ObservableCollection<Session> Sessions { get; set; } = new();

        public DateTime? DetectedStartTime { get; set; }
        private int _activeSecondsSinceLastSession = 0;
        private bool _wasIdle = false;
        private const double IdleThreshold = 300.0; // 5 mins

        private Timer? _timer;
        private Timer? _backgroundTimer;
        private readonly string _sessionsPath;

        public SessionManager()
        {
            var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            var honDir = Path.Combine(appData, "HON");
            Directory.CreateDirectory(honDir);
            _sessionsPath = Path.Combine(honDir, "sessions.json");

            LoadSessions();
            StartBackgroundMonitoring();
        }

        private void StartBackgroundMonitoring()
        {
            _backgroundTimer = new Timer(5000); // 5s check
            _backgroundTimer.Elapsed += (s, e) => CheckSystemState();
            _backgroundTimer.Start();
        }

        [StructLayout(LayoutKind.Sequential)]
        struct LASTINPUTINFO
        {
            public uint cbSize;
            public uint dwTime;
        }

        [DllImport("user32.dll")]
        static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        private double GetSystemIdleTime()
        {
            LASTINPUTINFO lastInputInfo = new LASTINPUTINFO();
            lastInputInfo.cbSize = (uint)Marshal.SizeOf(lastInputInfo);
            if (!GetLastInputInfo(ref lastInputInfo)) return 0;

            uint elapsedTicks = (uint)Environment.TickCount - lastInputInfo.dwTime;
            return elapsedTicks / 1000.0;
        }

        private void CheckSystemState()
        {
            double idleSeconds = GetSystemIdleTime();

            if (IsRunning && !IsPaused)
            {
                if (idleSeconds > IdleThreshold && !IsIdleConfirmation)
                {
                    App.Current.Dispatcher.Invoke(TriggerIdleConfirmation);
                }
            }
            else if (!IsRunning && !IsAreYouWorkingPrompt && !IsNaming)
            {
                if (idleSeconds > IdleThreshold)
                {
                    _wasIdle = true;
                    DetectedStartTime = null;
                    _activeSecondsSinceLastSession = 0;
                }
                else if (_wasIdle && idleSeconds < 5)
                {
                    DetectedStartTime = DateTime.Now.AddSeconds(-idleSeconds);
                    _wasIdle = false;
                    OnPropertyChanged(nameof(DetectedStartTime));
                }

                if (idleSeconds < 5)
                {
                    _activeSecondsSinceLastSession += 5;
                    if (_activeSecondsSinceLastSession >= 120)
                    {
                        App.Current.Dispatcher.Invoke(TriggerAreYouWorkingPrompt);
                    }
                }
                else
                {
                    _activeSecondsSinceLastSession = 0;
                }
            }
        }

        public void InitiateStart()
        {
            IsNaming = true;
            IsCompleted = false;
            IsRunning = false;
            IsWellnessBreak = false;
            IsPaused = false;
            IsIdleConfirmation = false;
            IsAreYouWorkingPrompt = false;
            _activeSecondsSinceLastSession = 0;
        }

        public void Start(bool fromDetected = false)
        {
            DateTime actualStart = (fromDetected && DetectedStartTime != null) ? DetectedStartTime.Value : DateTime.Now;

            IsNaming = false;
            IsRunning = true;
            IsPaused = false;
            IsCompleted = false;
            IsWellnessBreak = false;
            IsIdleConfirmation = false;
            IsAreYouWorkingPrompt = false;
            _activeSecondsSinceLastSession = 0;

            ElapsedSeconds = (int)(DateTime.Now - actualStart).TotalSeconds;
            WellnessSeconds = ElapsedSeconds;

            DetectedStartTime = null;
            _wasIdle = false;

            _timer?.Stop();
            _timer = new Timer(1000);
            _timer.Elapsed += (s, e) => {
                if (IsRunning && !IsPaused) {
                    ElapsedSeconds++;
                    WellnessSeconds++;
                    if (WellnessSeconds >= 1200) App.Current.Dispatcher.Invoke(TriggerWellnessBreak);
                }
            };
            _timer.Start();
        }

        public void PauseForWellness() { IsPaused = true; IsWellnessBreak = false; WellnessSeconds = 0; }
        public void ContinueWorking() { IsWellnessBreak = false; WellnessSeconds = 0; }
        public void StartManualBreak() { IsPaused = true; IsWellnessBreak = false; WellnessSeconds = 0; }
        public void TriggerWellnessBreak() { IsWellnessBreak = true; }
        public void TriggerIdleConfirmation() { IsIdleConfirmation = true; IsPaused = true; }
        public void TriggerAreYouWorkingPrompt() { IsAreYouWorkingPrompt = true; }
        public void DismissAreYouWorking() { IsAreYouWorkingPrompt = false; _activeSecondsSinceLastSession = 0; }
        public void ResumeSession() { IsPaused = false; IsWellnessBreak = false; IsIdleConfirmation = false; }
        
        public void Stop() { IsRunning = false; IsPaused = false; IsCompleted = true; IsWellnessBreak = false; IsIdleConfirmation = false; _timer?.Stop(); }

        public void SaveSession()
        {
            var session = new Session {
                Id = Guid.NewGuid(),
                StartedAt = DateTime.Now.AddSeconds(-ElapsedSeconds),
                EndedAt = DateTime.Now,
                Duration = ElapsedSeconds,
                Label = string.IsNullOrWhiteSpace(TaskLabel) ? null : TaskLabel,
                Category = SelectedCategory
            };
            Sessions.Add(session);
            SaveSessions();
            IsCompleted = false;
            TaskLabel = "";
            ElapsedSeconds = 0;
            IsRunning = false;
        }

        public void DiscardSession() { IsCompleted = false; IsRunning = false; ElapsedSeconds = 0; TaskLabel = ""; }

        public string TimerDisplay
        {
            get {
                var t = TimeSpan.FromSeconds(ElapsedSeconds);
                return string.Format("{0:D1}:{1:D2}:{2:D2}", t.Hours, t.Minutes, t.Seconds);
            }
        }

        private void LoadSessions()
        {
            if (File.Exists(_sessionsPath))
            {
                var json = File.ReadAllText(_sessionsPath);
                var loaded = JsonConvert.DeserializeObject<ObservableCollection<Session>>(json);
                if (loaded != null) Sessions = loaded;
            }
        }

        private void SaveSessions()
        {
            var json = JsonConvert.SerializeObject(Sessions);
            File.WriteAllText(_sessionsPath, json);
        }

        protected void OnPropertyChanged([CallerMemberName] string? name = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }
    }
}
