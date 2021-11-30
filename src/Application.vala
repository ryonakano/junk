public class Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "com.github.ryonakano.file-chooser-test",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var file_chooser_dialog_button = new Gtk.Button.with_label ("Open Gtk.FileChooserDialog");

        var file_chooser_native_button = new Gtk.Button.with_label ("Open Gtk.FileChooserNative");

        var grid = new Gtk.Grid () {
            margin = 12,
            column_spacing = 12,
            row_spacing = 12,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        grid.attach (file_chooser_dialog_button, 0, 0);
        grid.attach (file_chooser_native_button, 0, 1);

        var window = new Gtk.ApplicationWindow (this);
        window.set_default_size (600, 500);
        window.add (grid);
        window.show_all ();

        file_chooser_dialog_button.clicked.connect (() => {
            var file_chooser_dialog = new Gtk.FileChooserDialog (
                "Open File", window, Gtk.FileChooserAction.OPEN,
                "Cancel", Gtk.ResponseType.CANCEL,
                "Open", Gtk.ResponseType.ACCEPT
            );
            file_chooser_dialog.run ();
            file_chooser_dialog.destroy ();
        });

        file_chooser_native_button.clicked.connect (() => {
            var file_chooser_native = new Gtk.FileChooserNative (
                "Open File", window, Gtk.FileChooserAction.OPEN, "Open", "Cancel"
            );
            file_chooser_native.run ();
            file_chooser_native.destroy ();
        });
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run ();
    }
}
