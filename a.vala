[DBus (name = "org.freedesktop.hostname1")]
public interface SystemInterface : Object {
    [DBus (name = "IconName")]
    public abstract string icon_name { owned get; }

    public abstract string pretty_hostname { owned get; }
    public abstract string static_hostname { owned get; }

    public abstract async void set_pretty_hostname (string hostname, bool interactive) throws GLib.Error;
    public abstract async void set_static_hostname (string hostname, bool interactive) throws GLib.Error;
}

public class MyObject : Object {
    private SystemInterface system_interface;

    private void get_system_interface_instance () {
        if (system_interface != null) {
            return;
        }

        try {
            system_interface = Bus.get_proxy_sync (
                BusType.SYSTEM,
                "org.freedesktop.hostname1",
                "/org/freedesktop/hostname1"
            );
        } catch (GLib.Error e) {
            warning ("%s", e.message);
        }

        Bus.watch_name (
            BusType.SYSTEM,
            "org.freedesktop.hostname1",
            BusNameWatcherFlags.NONE,
            () => {
                warning ("appeared");
                warning ("pretty_hostname: %s", system_interface.pretty_hostname);
            },
            () => {
                warning ("disappeared");
            }
        );
    }

    public MyObject () {
        get_system_interface_instance ();
    }

    public static int main (string[] args) {
        var myobj = new MyObject ();
        var loop = new GLib.MainLoop ();
        loop.run ();

        return 0;
    }
}
