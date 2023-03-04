public class MainWindow : Gtk.ApplicationWindow {
    private const string LABEL_HEADING = "This is a Header Label";
    private const string LABEL_SECONDARY = "This is a secondary label added to provide more detailed info.";

    public MainWindow (Application app) {
        Object (application: app);
    }

    construct {
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (create_headerlabel_normal ());
        box.append (create_headerlabel_popover ());

        child = box;
    }

    private Gtk.Widget create_headerlabel_normal () {
        var label = new Granite.HeaderLabel (LABEL_HEADING) {
            secondary_text = LABEL_SECONDARY
        };

        return label;
    }

    private Gtk.Widget create_headerlabel_popover () {
        var label = new Granite.HeaderLabel (LABEL_HEADING) {
            secondary_text = LABEL_SECONDARY
        };

        var popover = new Gtk.Popover () {
            child = label
        };

        var button = new Gtk.MenuButton () {
            label = "Open Popover"
        };
        button.set_popover (popover);

        return button;
    }
}

public class Application : Gtk.Application {
    public Application () {
        Object (
            flags: ApplicationFlags.FLAGS_NONE,
            application_id: "com.github.ryonakano.headerlabel-test"
        );
    }

    protected override void activate () {
        var window = new MainWindow (this);
        window.present ();
    }
}

public static int main (string[] args) {
    return new Application ().run (args);
}
