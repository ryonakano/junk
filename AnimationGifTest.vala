public class AnimationGifTest : Gtk.Application {
    private Gtk.ApplicationWindow window;
    public string file_path { get; construct; }

    public AnimationGifTest (string path) {
        Object (
            application_id: "com.github.ryonakano.animation-gif-test",
            flags: ApplicationFlags.HANDLES_OPEN,
            file_path: path
        );
    }

    public override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        Gtk.Image image = null;

        try {
            var gif = new Gdk.PixbufAnimation.from_file (file_path);
            image = new Gtk.Image.from_animation (gif);
        } catch (Error e) {
            warning (e.message);
        }

        window = new Gtk.ApplicationWindow (this);
        window.title = "AnimationGifTest";
        window.add (image);
        window.show_all ();
    }

    public static int main (string[] args) {
        if (args.length != 2) {
            return -1;
        }

        return new AnimationGifTest (args[1]).run ();
    }
}
