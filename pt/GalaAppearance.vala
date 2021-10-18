public class PantheonTweaks.Settings.GalaAppearance : Granite.Services.Settings {

    // keys
    public double alt_tab_window_opacity { get; set; }
    public bool attach_modal_dialogs { get; set; }
    public string button_layout { get; set; }
    public string workspace_switcher_background { get; set; }

    private GalaAppearance () {
        base ("org.pantheon.desktop.gala.appearance");
    }

    private static GalaAppearance? instance = null;

    public static GalaAppearance get_default () {
        if (instance == null) {
            instance = new GalaAppearance ();
        }

        return instance;
    }
}
