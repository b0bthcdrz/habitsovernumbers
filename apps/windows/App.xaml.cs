using System.Windows;
using Hardcodet.Wpf.TaskbarNotification;
using HON.Windows.ViewModels;
using HON.Windows.Views;

namespace HON.Windows
{
    public partial class App : Application
    {
        private TaskbarIcon? _notifyIcon;
        private SessionManager? _sessionManager;
        private MainWindow? _mainWindow;

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            _sessionManager = new SessionManager();
            
            // Initialize Tray Icon
            _notifyIcon = new TaskbarIcon();
            _notifyIcon.Icon = HON.Windows.Properties.Resources.icon; // We'll need a real .ico here
            _notifyIcon.ToolTipText = "HON - Habits Over Numbers";
            
            // Handle Tray Click
            _notifyIcon.LeftClickCommand = new RelayCommand(ToggleWindow);

            // Create MainWindow but don't show yet
            _mainWindow = new MainWindow();
            _mainWindow.DataContext = _sessionManager;
            
            _sessionManager.onPanelAction = () => {
                Dispatcher.Invoke(() => {
                    ShowWindow();
                });
            };
        }

        private void ToggleWindow()
        {
            if (_mainWindow == null) return;
            if (_mainWindow.IsVisible) _mainWindow.Hide();
            else ShowWindow();
        }

        private void ShowWindow()
        {
            if (_mainWindow == null) return;
            
            // Position near tray (simplified)
            var desktopWorkingArea = SystemParameters.WorkArea;
            _mainWindow.Left = desktopWorkingArea.Right - _mainWindow.Width - 10;
            _mainWindow.Top = desktopWorkingArea.Bottom - _mainWindow.Height - 10;
            
            _mainWindow.Show();
            _mainWindow.Activate();
        }

        protected override void OnExit(ExitEventArgs e)
        {
            _notifyIcon?.Dispose();
            base.OnExit(e);
        }
    }

    // Simple Command implementation
    public class RelayCommand : System.Windows.Input.ICommand
    {
        private readonly Action _execute;
        public RelayCommand(Action execute) => _execute = execute;
        public bool CanExecute(object? parameter) => true;
        public void Execute(object? parameter) => _execute();
        public event EventHandler? CanExecuteChanged;
    }
}
