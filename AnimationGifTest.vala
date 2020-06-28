public class AnimationGifTest : Gtk.Application {
    private Gtk.ApplicationWindow window;

    public AnimationGifTest () {
        Object (
            application_id: "com.github.ryonakano.animation-gif-test",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    public override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        Gtk.Image image = null;

        try {
            var gif = new Gdk.PixbufAnimation.from_file ("test.gif");
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
        return new AnimationGifTest ().run ();
    }
}
