public class ActiveSwitchSensitivityTest : Gtk.Application {
    public ActiveSwitchSensitivityTest () {
        Object (
            application_id: "com.github.ryonakano.active-switch-sensitivity-test",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var normal_label = new Gtk.Label ("Inactive / Sensitive:") {
            halign = Gtk.Align.END
        };
        var normal_switch = new Gtk.Switch () {
            halign = Gtk.Align.START
        };

        var active_label = new Gtk.Label ("Active / Sensitive:") {
            halign = Gtk.Align.END
        };
        var active_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            active = true
        };

        var insensitive_label = new Gtk.Label ("Inactive / Insensitive:") {
            halign = Gtk.Align.END
        };
        var insensitive_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            sensitive = false
        };

        var active_insensitive_label = new Gtk.Label ("Active / Insensitive:") {
            halign = Gtk.Align.END
        };
        var active_insensitive_switch = new Gtk.Switch () {
            halign = Gtk.Align.START,
            active = true,
            sensitive = false
        };

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.column_spacing = 12;
        grid.row_spacing = 12;
        grid.valign = Gtk.Align.CENTER;
        grid.halign = Gtk.Align.CENTER;
        grid.attach (normal_label, 0, 0);
        grid.attach (normal_switch, 1, 0);
        grid.attach (active_label, 0, 1);
        grid.attach (active_switch, 1, 1);
        grid.attach (insensitive_label, 0, 2);
        grid.attach (insensitive_switch, 1, 2);
        grid.attach (active_insensitive_label, 0, 3);
        grid.attach (active_insensitive_switch, 1, 3);

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;
        header.title = "ActiveSwitchSensitivityTest";

        var window = new Gtk.ApplicationWindow (this);
        window.set_default_size (600, 500);
        window.add (grid);
        window.show_all ();
    }

    public static int main (string[] args) {
        var app = new ActiveSwitchSensitivityTest ();
        return app.run ();
    }
}
