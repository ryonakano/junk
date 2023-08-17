public class MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        width_request = 600;
        height_request = 400;

        var installer = Installer.get_default ();

        var button = new Gtk.Button.with_label ("Install") {
            halign = Gtk.Align.CENTER
        };

        var progress_bar = new Gtk.ProgressBar () {
            fraction = 0.0,
            hexpand = true,
            margin_start = 24,
            margin_end = 24
        };

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            hexpand = true,
            vexpand = true,
            valign = Gtk.Align.CENTER
        };
        box.append (button);
        box.append (progress_bar);

        child = box;

        button.clicked.connect (() => {
            installer.install ();
        });

        installer.progress_changed.connect ((percentage) => {
            progress_bar.fraction = percentage;
        });
    }
}
