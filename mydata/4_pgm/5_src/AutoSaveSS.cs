// https://qiita.com/earthdiver1/items/79fa9d86331bb72a198c
// 2019/05/19
// by earthdiver1
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

public class AutoSaveSS {
    [STAThread]
    public static void Main() {
        if (Process.GetProcessesByName(Process.GetCurrentProcess().ProcessName).Length == 1) {
            Application.Run(new ClipboardWatcherForm());
        }
    }
}

public class ClipboardWatcherForm : Form {
    [DllImport("user32.dll")]private static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);
    [DllImport("user32.dll")]private static extern bool AddClipboardFormatListener(IntPtr hWnd);
    [DllImport("user32.dll")]private static extern bool RemoveClipboardFormatListener(IntPtr hWnd);
    [DllImport("user32.dll")]private static extern bool RegisterHotKey(IntPtr hWnd, int id, int modKey, int key);
    [DllImport("user32.dll")]private static extern bool UnregisterHotKey(IntPtr hWnd, int id);
    [DllImport("user32.dll")]private static extern uint GetClipboardSequenceNumber();
    NotifyIcon _notifyIcon = new NotifyIcon();
    bool   _disposed;
    string _imageDir = Environment.GetEnvironmentVariable("IMAGEDIR");
    int    _id = (new Random()).Next(0x1000, 0xc000);
    uint   _lastSeq = 0;
    int    _minImageSize = 200;

    public ClipboardWatcherForm() {
        _disposed = false;
        SetParent(Handle, new IntPtr(-3));          // HWND_MESSAGE => message-only window
        _notifyIcon.ContextMenu = new ContextMenu(new MenuItem[] {
            new MenuItem("Auto Save as PNG"        , (s, e) => {
                ((MenuItem)s).Checked = !((MenuItem)s).Checked;
                _notifyIcon.ContextMenu.MenuItems[1].Enabled = ((MenuItem)s).Checked;
                _notifyIcon.ContextMenu.MenuItems[2].Enabled = ((MenuItem)s).Checked;
            }),
            new MenuItem("Show BalloonTip"         , (s, e) => { ((MenuItem)s).Checked = !((MenuItem)s).Checked; }),
            new MenuItem("Change Save Directory"    , (s, e) => {
                using(var f = new Form(){TopMost = true})
                using(var fbd = new FolderBrowserDialog()) {
                    fbd.ShowNewFolderButton = false;
                    fbd.Description  = "Select Save Directory";
                    fbd.SelectedPath = _imageDir;
                    if (fbd.ShowDialog(f) == DialogResult.OK) _imageDir = fbd.SelectedPath;
                }
            }),
            new MenuItem("Draw Cursor with F11 key", (s, e) => { ((MenuItem)s).Checked = !((MenuItem)s).Checked; }),
            new MenuItem("Delay 3 sec with F11 key", (s, e) => { ((MenuItem)s).Checked = !((MenuItem)s).Checked; }),
            new MenuItem("Exit"                    , (s, e) => { _notifyIcon.Visible = false; Application.Exit(); }),
        });
        _notifyIcon.ContextMenu.MenuItems[0].Checked = true;
        _notifyIcon.ContextMenu.MenuItems[1].Checked = true;
        _notifyIcon.Icon = System.Drawing.Icon.ExtractAssociatedIcon(Application.ExecutablePath);
        _notifyIcon.Text = "AutoSaveSS";
        _notifyIcon.Visible = true;
        if (_imageDir == null) _imageDir = Application.StartupPath;
        AddClipboardFormatListener(Handle);
        RegisterHotKey(Handle, _id, 0x4000, 122); // 122 => F11
    }

    protected override void Dispose(bool disposing) {
        if (_disposed) return;
        if (disposing) {
            foreach (MenuItem item in _notifyIcon.ContextMenu.MenuItems) item.Dispose();
            _notifyIcon.ContextMenu.Dispose();
            _notifyIcon.Dispose();
        }
        RemoveClipboardFormatListener(Handle);
        UnregisterHotKey(Handle, _id);
        _disposed = true;
        base.Dispose(disposing);
    }

    protected override void WndProc(ref Message m) {
        if (m.Msg == 0x312 && (int)m.WParam == _id)      OnHotKeyPressed();        // WM_HOTKEY
        if (m.Msg == 0x31D && Clipboard.ContainsImage()) OnClipboardImageUpdate(); // WM_CLIPBOARDUPDATE
        base.WndProc(ref m);
    }

    protected virtual void OnHotKeyPressed() {
        var t = new Thread(() => {
            if (_notifyIcon.ContextMenu.MenuItems[4].Checked) Thread.Sleep(3000);
            WindowScreenshot.SetClipboard(_notifyIcon.ContextMenu.MenuItems[3].Checked);
        });
        t.SetApartmentState(ApartmentState.STA);
        t.Start();
//      t.Join(); // uncomment to avoid "System.Runtime.InteropServices.ExternalException (0x800401D0)" error
    }

    protected virtual void OnClipboardImageUpdate() {
        if (!_notifyIcon.ContextMenu.MenuItems[0].Checked) return;
        uint seq = GetClipboardSequenceNumber();
        if (seq == _lastSeq) return;
        _lastSeq = seq;
        var t = new Thread(() => {
            Image img;
            if (Clipboard.ContainsData("PNG")) {
                IDataObject data  = Clipboard.GetDataObject();
                img = Image.FromStream((Stream)data.GetData("PNG"));
            } else {
                img = Clipboard.GetImage();
            }
            if (img != null && img.Height >= _minImageSize && img.Width >= _minImageSize) {
                string filename = Path.Combine(_imageDir, @"ScreenShot-" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".png");
                img.Save(filename, System.Drawing.Imaging.ImageFormat.Png);
                if (_notifyIcon.ContextMenu.MenuItems[1].Checked) {
                    _notifyIcon.ShowBalloonTip(1000,"","Screenshot saved!", ToolTipIcon.Info);
                } else {
                    Console.Beep(500,200);
                }
            }
        });
        t.SetApartmentState(ApartmentState.STA);
        t.Start();
    }
}

public static class WindowScreenshot {
    [StructLayout(LayoutKind.Sequential)]private struct RECT {
        public int    Left, Top, Right, Bottom;
    }
    [StructLayout(LayoutKind.Sequential)]private struct CURSORINFO {
        public int    cbSize;
        public int    flags;
        public IntPtr hCursor;
        public Point  ptScreenPos;
    }
    [StructLayout(LayoutKind.Sequential)]private struct ICONINFO {
        public bool   fIcon;
        public int    xHotspot;
        public int    yHotspot;
        public IntPtr hbmMask;
        public IntPtr hbmColor;
    }
    [DllImport("user32.dll")]private static extern bool   SetProcessDPIAware();
    [DllImport("user32.dll")]private static extern IntPtr GetForegroundWindow();
    [DllImport("dwmapi.dll")]private static extern int 
        DwmGetWindowAttribute(IntPtr hwnd, int dwAttribute, out RECT pvAttribute, int cbAttribute);
    [DllImport("user32.dll")]private static extern IntPtr 
        FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);
    [DllImport("user32.dll")]private static extern bool   GetCursorInfo(out CURSORINFO pci);
    [DllImport("user32.dll")]private static extern IntPtr CopyIcon(IntPtr hIcon);
    [DllImport("user32.dll")]private static extern bool   GetIconInfo(IntPtr hIcon, out ICONINFO piconinfo);
    [DllImport("user32.dll")]private static extern bool   DrawIcon(IntPtr hdc, int x, int y, IntPtr hIcon);
    const int DWMWA_EXTENDED_FRAME_BOUNDS = 9;
    const int CURSOR_SHOWING = 1;

    static WindowScreenshot() {
        SetProcessDPIAware();
    }

    public static void SetClipboard(bool drawCursor) {
        IntPtr hWnd  = GetForegroundWindow();
        RECT R;
        int status = DwmGetWindowAttribute(hWnd,
                                           DWMWA_EXTENDED_FRAME_BOUNDS,
                                           out R,
                                           Marshal.SizeOf(typeof(RECT)));
        if (status != 0) return;
        Rectangle rWindow = Rectangle.FromLTRB(R.Left, R.Top, R.Right, R.Bottom);
        var rList = new List<Rectangle>();
        rList.Add(rWindow);
        Rectangle rBmp = rWindow;
        IntPtr h = IntPtr.Zero;
        int ct = 0, maxct = 10;
        while (true && ct++ < maxct) {
            h = FindWindowEx(IntPtr.Zero, h, "#32768", null);
            if (h == IntPtr.Zero) break;
            status = DwmGetWindowAttribute(h,
                                           DWMWA_EXTENDED_FRAME_BOUNDS,
                                           out R,
                                           Marshal.SizeOf(typeof(RECT)));
            if (status != 0) continue;
            Rectangle r = Rectangle.FromLTRB(R.Left, R.Top, R.Right, R.Bottom);
            if (!rWindow.Contains(r)) {
                rBmp = Rectangle.Union(rBmp,r);
                rList.Add(r);
            }
        }
        using (var b = new Bitmap(rBmp.Width, rBmp.Height)) {
            using (Graphics g = Graphics.FromImage(b)) {
                foreach (Rectangle r in rList) {
                    g.CopyFromScreen(r.X, r.Y, r.X - rBmp.X, r.Y - rBmp.Y, r.Size);
                }
                if (drawCursor) {
                    CURSORINFO cInfo;
                    cInfo.cbSize = Marshal.SizeOf(typeof(CURSORINFO));
                    if (GetCursorInfo(out cInfo)) {
                        if (cInfo.flags == CURSOR_SHOWING) {
                            IntPtr iPtr = CopyIcon(cInfo.hCursor);
                            ICONINFO iInfo;
                            if (GetIconInfo(iPtr, out iInfo)) {
                                int posX = cInfo.ptScreenPos.X - (int)iInfo.xHotspot - rBmp.X;
                                int posY = cInfo.ptScreenPos.Y - (int)iInfo.yHotspot - rBmp.Y;
                                DrawIcon(g.GetHdc(), posX, posY, cInfo.hCursor);
                            }
                        }
                    }
                }
            }
            var d = new DataObject();
            d.SetData(b);
            using (var s = new MemoryStream()) {
                b.Save(s, System.Drawing.Imaging.ImageFormat.Png);
                d.SetData("PNG", false, s);
                Clipboard.SetDataObject(d, true);
            }
        }
        rList.Clear();
    }
}