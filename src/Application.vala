public class Application : Gtk.Application {
    private Settings settings;

    public Application () {
        Object (
            application_id: "com.github.ryonakano.tweaks",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void startup () {
        base.startup ();

        var schema = SettingsSchemaSource.get_default ().lookup ("io.elementary.files.preferences", false);
        if (schema == null) {
            warning ("Unable to find schema");
            quit ();
            return;
        }

        settings = new Settings.full (schema, null, null);
    }

    protected override void activate () {
        var label = new Gtk.Label ("Restore tabs:");
        var switch = new Gtk.Switch ();

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        box.append (label);
        box.append (switch);

        settings.bind ("restore-tabs", switch, "active", SettingsBindFlags.DEFAULT);

        var window = new Gtk.ApplicationWindow (this) {
            child = box
        };
        window.present ();
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run ();
    }
}
