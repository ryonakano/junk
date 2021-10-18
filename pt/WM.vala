public class PantheonTweaks.Settings.WM : Granite.Services.Settings {

    // keys
    public string action_double_click_titlebar { get; set; }
    public string action_middle_click_titlebar { get; set; }
    public string action_right_click_titlebar { get; set; }
    public bool auto_raise { get; set; }
    public string button_layout { get; set; }
    public string focus_mode { get; set; }
    public string mouse_button_modifier { get; set; }
    public bool resize_with_right_button { get; set; }

    private WM () {
        base ("org.gnome.desktop.wm.preferences");
    }

    private static WM? instance = null;

    private static Gee.TreeMap<string, string>? titlebar_actions = null;

    public static WM get_default () {
        if (instance == null) {
            instance = new WM ();
        }

        return instance;
    }

    public static Gee.TreeMap<string, string> get_titlebar_actions () {
        if (titlebar_actions == null) {
            titlebar_actions = new Gee.TreeMap<string, string> ();
            titlebar_actions.set ("none", "None");
            titlebar_actions.set ("lower", "Lower");
            titlebar_actions.set ("menu", "Menu");
            titlebar_actions.set ("minimize", "Minimize");
            titlebar_actions.set ("toggle-maximize", "Toggle Maximize");
            titlebar_actions.set ("toggle-maximize-horizontally", "Toggle Maximize Horizontally");
            titlebar_actions.set ("toggle-maximize-vertically", "Toggle Maximize Vertically");
            titlebar_actions.set ("toggle-shade", "Toggle Shade");
        }

        return titlebar_actions;
    }
}
