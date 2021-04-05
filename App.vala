public class App : Gtk.Application {
    private Gtk.ApplicationWindow window;

    public App () {
        Object (
            application_id: "com.github.ryonakano.app",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    public override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        var close_left_button = new ActionButton ("");

        var maximize_left_button = new ActionButton ("");

        var minimize_left_button = new ActionButton ("");

        var left_buttons_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            margin = 3,
            margin_end = 12
        };
        left_buttons_grid.attach (close_left_button, 0, 0, 1, 1);
        left_buttons_grid.attach (maximize_left_button, 1, 0, 1, 1);
        left_buttons_grid.attach (minimize_left_button, 2, 0, 1, 1);

        var close_right_button = new ActionButton ("window-close-symbolic");

        var maximize_right_button = new ActionButton ("view-restore-symbolic");

        var minimize_right_button = new ActionButton ("window-minimize-symbolic");

        var right_buttons_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            margin = 3,
            margin_start = 12
        };
        right_buttons_grid.attach (close_right_button, 0, 0, 1, 1);
        right_buttons_grid.attach (maximize_right_button, 1, 0, 1, 1);
        right_buttons_grid.attach (minimize_right_button, 2, 0, 1, 1);

        var headerbar = new Gtk.HeaderBar () {
            title = "Demo Window"
        };
        headerbar.pack_start (left_buttons_grid);
        headerbar.pack_end (right_buttons_grid);
        headerbar.get_style_context ().add_class ("titlebar");

        var grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        grid.add (headerbar);

        window = new Gtk.ApplicationWindow (this) {
            title = "WindowHandle Demo",
            border_width = 12
        };
        window.add (grid);
        window.show_all ();
    }

    public static int main (string[] args) {
        return new App ().run ();
    }
}

public class ActionButton : Gtk.ToggleButton {
    public string icon_name {
        owned get {
            return ((Gtk.Image) this.get_child ()).icon_name;
        }
        set {
            ((Gtk.Image) this.get_child ()).icon_name = value;
        }
    }

    public ActionButton (string icon_name) {
        Object (
            focus_on_click: false,
            can_focus: false
        );

        add (new Gtk.Image.from_icon_name ("", Gtk.IconSize.BUTTON));

        this.icon_name = icon_name;
    }

    construct {
        // As a destination
        Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, null, Gdk.DragAction.DEFAULT);
        //  drag_drop.connect ((ctx, x, y, t) => {
        //      icon_name = "window-close-symbolic";
        //      return true;
        });
        //  drag_data_get.connect ((ctx, data, info, t) => {
        //      data.set_text (icon_name, -1);
        //  });

        // As a source
        Gtk.drag_source_set (this, Gdk.ModifierType.BUTTON1_MASK, null, Gdk.DragAction.DEFAULT);
        drag_end.connect ((ctx) => {
            icon_name = "";
        });
        //  drag_data_received.connect ((ctx, x, y, data, info, t) => {
        //      stdout.printf ("aaa: %s\n", data.get_text ());
        //  });
    }
}
