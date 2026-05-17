public class Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "io.github.ryonakano.gtk4-template",
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    protected override void activate () {
        var window = new MainWindow (this);
        window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run ();
    }
}
