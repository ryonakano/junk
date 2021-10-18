// From https://github.com/sgpthomas/Pantheon-Tweaks
public class PantheonTweaks.App : Gtk.Application {
    private Gtk.ApplicationWindow window;

    public App () {
        Object (
            application_id: "com.github.ryonakano.app",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

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

    private string test_string;

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
        var top = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);

        sep1 = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        sep1.no_show_all = true;
        sep1.width_request = 28;

        close_button = new Gtk.ToggleButton ();
        close_button.image = new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        sep2 = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        sep2.no_show_all = true;
        sep2.width_request = 28;

        minimize_button = new Gtk.ToggleButton ();
        minimize_button.image = new Gtk.Image.from_icon_name ("window-minimize-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        sep3 = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        sep3.no_show_all = true;
        sep3.width_request = 28;

        maximize_button = new Gtk.ToggleButton ();
        maximize_button.image = new Gtk.Image.from_icon_name ("window-maximize-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        sep4 = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        sep4.no_show_all = true;
        sep4.width_request = 28;

        top.pack_start (sep1);
        top.pack_start (close_button);
        top.pack_start (sep2);
        top.pack_start (minimize_button);
        top.pack_start (sep3);
        top.pack_start (maximize_button);
        top.pack_start (sep4);

        var bot = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);

        left = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        left.relief = Gtk.ReliefStyle.NONE;

        right = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        right.relief = Gtk.ReliefStyle.NONE;

        bot.pack_start (left);
        bot.pack_start (right);

        var grid = new Gtk.Grid ();
        grid.add (top);
        grid.add (bot);

        window.add (grid);
    }

    private void connect_signals () {
        update ();
        test_string = "close:maximize";

        right.clicked.connect (() => {
            var str = Settings.WM.get_default ().button_layout;
            if (!str.has_suffix (":")) {
                var pos = str.index_of (",", str.index_of (":"));
                str = str.replace (":", ",");
                if (pos == -1) {
                    str += ":";
                } else {
                    str = str.splice (pos, pos+1, ":");
                }
            }

            str = fix_string (str);
            Settings.WM.get_default ().button_layout = str;
        });

        left.clicked.connect (() => {
            var str = Settings.WM.get_default ().button_layout.reverse ();

            if (!str.has_suffix (":")) {
                var pos = str.index_of (",", str.index_of (":"));
                str = str.replace (":", ",");
                if (pos == -1) {
                    str += ":";
                } else {
                    str = str.splice (pos, pos+1, ":");
                }
            }

            str = fix_string (str.reverse ());
            Settings.WM.get_default ().button_layout = str;
        });

        close_button.toggled.connect (() => {
            var str = Settings.WM.get_default ().button_layout;

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
            Settings.WM.get_default ().button_layout = str;
        });

        minimize_button.toggled.connect (() => {
            var str = Settings.WM.get_default ().button_layout;

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
            Settings.WM.get_default ().button_layout = str;
        });

        maximize_button.toggled.connect (() => {
            var str = Settings.WM.get_default ().button_layout;

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
            Settings.WM.get_default ().button_layout = str;
        });

        Settings.WM.get_default ().notify["button-layout"].connect (() => {
            update ();
            Settings.GalaAppearance.get_default ().button_layout = Settings.WM.get_default ().button_layout;
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
        var layout_string = Settings.WM.get_default ().button_layout;
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
