public class ButtonsSensitivityTest : Gtk.Application {
    public ButtonsSensitivityTest () {
        Object (
            application_id: "com.github.ryonakano.buttons-sensitivity-test",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var normal_button = new Gtk.Button.with_label ("Click Me");

        var suggested_action_button = new Gtk.Button.with_label ("Click Me");
        suggested_action_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var destructive_action_button = new Gtk.Button.with_label ("Click Me");
        destructive_action_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.column_spacing = 12;
        grid.row_spacing = 12;
        grid.halign = Gtk.Align.CENTER;
        grid.valign = Gtk.Align.CENTER;
        grid.attach (normal_button, 0, 0);
        grid.attach (suggested_action_button, 0, 1);
        grid.attach (destructive_action_button, 0, 2);

        var normal_header_button = new Gtk.Button.with_label ("Click Me");

        var suggested_action_header_button = new Gtk.Button.with_label ("Click Me");
        suggested_action_header_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var destructive_action_header_button = new Gtk.Button.with_label ("Click Me");
        destructive_action_header_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

        var header_grid = new Gtk.Grid ();
        header_grid.column_spacing = 6;
        header_grid.halign = Gtk.Align.CENTER;
        header_grid.valign = Gtk.Align.CENTER;
        header_grid.attach (normal_header_button, 0, 0);
        header_grid.attach (suggested_action_header_button, 1, 0);
        header_grid.attach (destructive_action_header_button, 2, 0);

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;
        header.title = "ButtonsSensitivityTest";
        header.add (header_grid);

        var window = new Gtk.ApplicationWindow (this);
        window.set_default_size (600, 500);
        window.add (grid);
        window.set_titlebar (header);
        window.show_all ();

        for (int i = 0; i < 3; i++) {
            var button = (Gtk.Button) grid.get_child_at (0, i);
            button.clicked.connect (() => {
                button.sensitive = false;
            });
        }

        for (int i = 0; i < 3; i++) {
            var button = (Gtk.Button) header_grid.get_child_at (i, 0);
            button.clicked.connect (() => {
                button.sensitive = false;
            });
        }
    }

    public static int main (string[] args) {
        var app = new ButtonsSensitivityTest ();
        return app.run ();
    }
}
