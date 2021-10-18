// From https://github.com/sgpthomas/Pantheon-Tweaks
public class PantheonTweaks.App : Gtk.Application {
    private Gtk.ApplicationWindow window;

    private static GLib.Settings wm_settings;
    private static GLib.Settings gala_settings;

    // top
    private Gtk.Separator sep1;
    private Gtk.ToggleButton close_button;
    private Gtk.Separator sep2;
    private Gtk.ToggleButton minimize_button;
    private Gtk.Separator sep3;
    private Gtk.ToggleButton maximize_button;
    private Gtk.Separator sep4;

    // bottom
    private Gtk.Button left;
    private Gtk.Button right;

    public App () {
        Object (
            application_id: "com.github.sgpthomas.Pantheon-Tweaks",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        wm_settings = new GLib.Settings ("org.gnome.desktop.wm.preferences");
        gala_settings = new GLib.Settings ("org.pantheon.desktop.gala.appearance");
    }

    public override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        window = new Gtk.ApplicationWindow (this) {
            title = "App",
            border_width = 12
        };

        build_ui ();
        connect_signals ();

        window.show_all ();
    }

    private void build_ui () {
        var top = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            halign = Gtk.Align.CENTER
        };

        sep1 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            margin_start = 6,
            margin_end = 6
        };
        sep1.no_show_all = true;

        close_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            can_focus = false
        };
        close_button.image = new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        sep2 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            margin_start = 6,
            margin_end = 6
        };
        sep2.no_show_all = true;

        minimize_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            can_focus = false
        };
        minimize_button.image = new Gtk.Image.from_icon_name ("window-minimize-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        sep3 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            margin_start = 6,
            margin_end = 6
        };
        sep3.no_show_all = true;

        maximize_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            can_focus = false
        };
        maximize_button.image = new Gtk.Image.from_icon_name ("window-maximize-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        sep4 = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            margin_start = 6,
            margin_end = 6
        };
        sep4.no_show_all = true;

        top.pack_start (sep1, false, false);
        top.pack_start (close_button, false, false);
        top.pack_start (sep2, false, false);
        top.pack_start (minimize_button, false, false);
        top.pack_start (sep3, false, false);
        top.pack_start (maximize_button, false, false);
        top.pack_start (sep4, false, false);

        var bot = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            halign = Gtk.Align.CENTER
        };

        left = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.SMALL_TOOLBAR) {
            focus_on_click = false,
            can_focus = false
        };
        left.relief = Gtk.ReliefStyle.NONE;

        right = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.SMALL_TOOLBAR) {
            focus_on_click = false,
            can_focus = false
        };
        right.relief = Gtk.ReliefStyle.NONE;

        bot.pack_start (left, false, false);
        bot.pack_start (right, false, false);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            halign = Gtk.Align.CENTER
        };
        box.add (top);
        box.add (bot);

        window.add (box);
    }

    private void connect_signals () {
        update ();

        right.clicked.connect (() => {
            var str = wm_settings.get_string ("button-layout");
            if (!str.has_suffix (":")) {
                var pos = str.index_of (",", str.index_of (":"));
                str = str.replace (":", ",");
                if (pos == -1) {
                    str += ":";
                } else {
                    str = str.splice (pos, pos+1, ":");
                }
            }

            right.sensitive = !str.has_suffix (":");
            left.sensitive = !str.has_prefix (":");
            str = fix_string (str);
            wm_settings.set_string ("button-layout", str);
            gala_settings.set_string ("button-layout", str);
            update ();
        });

        left.clicked.connect (() => {
            var str = wm_settings.get_string ("button-layout").reverse ();

            if (!str.has_suffix (":")) {
                var pos = str.index_of (",", str.index_of (":"));
                str = str.replace (":", ",");
                if (pos == -1) {
                    str += ":";
                } else {
                    str = str.splice (pos, pos+1, ":");
                }
            }

            right.sensitive = !str.has_prefix (":");
            left.sensitive = !str.has_suffix (":");
            str = fix_string (str.reverse ());
            wm_settings.set_string ("button-layout", str);
            gala_settings.set_string ("button-layout", str);
            update ();
        });

        close_button.toggled.connect (() => {
            var str = wm_settings.get_string ("button-layout");

            if (!close_button.active) {
                str = str.replace ("close", "");
            } else {
                // close,minimize:maximize
                if (str.split (":")[0] == "") {
                    str = "close" + str;
                } else {
                    str = "close," + str;
                }
            }

            str = fix_string (str);
            wm_settings.set_string ("button-layout", str);
            gala_settings.set_string ("button-layout", str);
            update ();
        });

        minimize_button.toggled.connect (() => {
            var str = wm_settings.get_string ("button-layout");

            if (!minimize_button.active) {
                str = str.replace ("minimize", "");
            } else {
                if ("close," in str) {
                    str = str.replace ("close,", "close,minimize,");
                } else if ("close:" in str) {
                    str = str.replace ("close:", "close:minimize,");
                } else {
                    str = str.replace (":", ":minimize,");
                }
            }

            str = fix_string (str);
            wm_settings.set_string ("button-layout", str);
            gala_settings.set_string ("button-layout", str);
            update ();
        });

        maximize_button.toggled.connect (() => {
            var str = wm_settings.get_string ("button-layout");

            if (!maximize_button.active) {
                str = str.replace ("maximize", "");
            } else {
                // close,minimize:maximize
                if (str.split (":")[1] == "") {
                    str += "maximize";
                } else {
                    str += ",maximize";
                }
            }

            str = fix_string (str);
            wm_settings.set_string ("button-layout", str);
            gala_settings.set_string ("button-layout", str);
            update ();
        });
    }

    private string fix_string (string str) {
        var ret = str;
        if (ret.has_prefix (",")) ret = ret.splice (0, 1);
        if (ret.has_suffix (",")) ret = ret.splice (ret.last_index_of (","), ret.last_index_of (",")+1);

        if (",," in ret) {
            ret = ret.replace (",,", ",");
        }

        if (":," in ret) {
            ret = ret.replace (":,", ":");
        }

        if (",:" in ret) {
            ret = ret.replace (",:", ":");
        }

        return ret;
    }

    private void update () {
        var layout_string = wm_settings.get_string ("button-layout");
        // activate buttons
        close_button.active = ("close" in layout_string) ? true : false;
        minimize_button.active = ("minimize" in layout_string) ? true : false;
        maximize_button.active = ("maximize" in layout_string) ? true : false;

        // setup layout
        string[] layout = layout_string.split (":");

        switch (layout[0].split(",").length) {
            case 0:
                sep1.show ();
                sep2.hide ();
                sep3.hide ();
                sep4.hide ();
                return;
            case 1:
                sep1.hide ();
                sep2.show ();
                sep3.hide ();
                sep4.hide ();
                return;
            case 2:
                sep1.hide ();
                sep2.hide ();
                sep3.show ();
                sep4.hide ();
                return;
            case 3:
                sep1.hide ();
                sep2.hide ();
                sep3.hide ();
                sep4.show ();
                return;
        }


    }

    public static int main (string[] args) {
        return new App ().run ();
    }
}
