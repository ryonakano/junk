public class Application : Gtk.Application {
    public Application () {
    }

    construct {
        application_id = "com.github.ryonakano.pk-test";
        flags = ApplicationFlags.FLAGS_NONE;
    }

    protected override void activate () {
        var window = new MainWindow (this);
        window.present ();

        var quit_action = new SimpleAction ("quit", null);
        quit_action.activate.connect (() => {
            if (active_window != null) {
                active_window.destroy ();
            }
        });
        set_accels_for_action ("app.quit", { "<Control>q" });
        add_action (quit_action);
    }

    public static int main (string[] args) {
        return new Application ().run ();
    }
}
