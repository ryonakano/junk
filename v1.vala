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

        var close_left_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            can_focus = false
        };
        close_left_button.add (new Gtk.Image.from_icon_name ("", Gtk.IconSize.BUTTON));
        Gtk.drag_dest_set (close_left_button, Gtk.DestDefaults.ALL, null, Gdk.DragAction.DEFAULT);
        Gtk.drag_source_set (close_left_button, Gdk.ModifierType.BUTTON1_MASK, null, Gdk.DragAction.DEFAULT);

        var maximize_left_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            can_focus = false
        };
        maximize_left_button.add (new Gtk.Image.from_icon_name ("", Gtk.IconSize.BUTTON));

        var minimize_left_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            can_focus = false
        };
        minimize_left_button.add (new Gtk.Image.from_icon_name ("", Gtk.IconSize.BUTTON));

        var left_buttons_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            margin = 3,
            margin_end = 12
        };
        left_buttons_grid.attach (close_left_button, 0, 0, 1, 1);
        left_buttons_grid.attach (maximize_left_button, 1, 0, 1, 1);
        left_buttons_grid.attach (minimize_left_button, 2, 0, 1, 1);

        var close_right_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            can_focus = false
        };
        close_right_button.add (new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON));
        Gtk.drag_dest_set (close_right_button, Gtk.DestDefaults.ALL, null, Gdk.DragAction.DEFAULT);
        Gtk.drag_source_set (close_right_button, Gdk.ModifierType.BUTTON1_MASK, null, Gdk.DragAction.DEFAULT);

        var maximize_right_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            can_focus = false
        };
        maximize_right_button.add (new Gtk.Image.from_icon_name ("view-restore-symbolic", Gtk.IconSize.BUTTON));

        var minimize_right_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            can_focus = false
        };
        minimize_right_button.add (new Gtk.Image.from_icon_name ("window-minimize-symbolic", Gtk.IconSize.BUTTON));

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
            title = "App",
            border_width = 12
        };
        window.add (grid);
        window.show_all ();

        //  close_left_button.drag_data_get.connect ((ctx, data, info, t) => {
        //      data.set_text (((Gtk.Image) close_left_button.get_child ()).icon_name, -1);
        //  });
        close_left_button.drag_end.connect ((ctx) => {
            ((Gtk.Image) close_right_button.get_child ()).icon_name = "window-close-symbolic";
            ((Gtk.Image) close_left_button.get_child ()).icon_name = "";
        });
        close_right_button.drag_end.connect ((ctx) => {
            ((Gtk.Image) close_left_button.get_child ()).icon_name = "window-close-symbolic";
            ((Gtk.Image) close_right_button.get_child ()).icon_name = "";
        });
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
            icon_name: icon_name,
            focus_on_click: false
        );
    }

    construct {
        // As a destination
        Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, null, Gdk.DragAction.DEFAULT);
        drag_drop.connect ((ctx, x, y, t) => {
            icon_name = "window-close-symbolic";
        });

        // As a source
        Gtk.drag_source_set (this, Gdk.ModifierType.BUTTON1_MASK, null, Gdk.DragAction.DEFAULT);
        drag_end.connect ((ctx) => {
            icon_name = "";
        });
    }
}
