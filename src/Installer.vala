public class Installer : GLib.Object {
    public signal void progress_changed (int percentage);

    private Installer () {
    }

    public static Installer get_default () {
        if (instance == null) {
            instance = new Installer ();
        }

        return instance;
    }
    private static Installer instance = null;

    construct {
    }

    public bool install () {
        string[] values = { "ibus-mozc" };
        Pk.Results result;
        var task = new Pk.Task ();

        // resolve the package name
        try {
            result = task.resolve_sync (Pk.Filter.NOT_INSTALLED, values, null, ((process, type) => {
            }));
        } catch (Error e) {
            warning ("Resolving of packages failed: %s", e.message);
            return false;
        }

        // get the packages returned
        var packages = result.get_package_array ();
        string[] package_ids = {};
        packages.foreach ((package) => {
            package_ids += package.get_id ();
        });

        // install the packages
        task.install_packages_async.begin (package_ids, null, progress_callback, ((obj, res) => {
            try {
                result = task.install_packages_async.end (res);
            } catch (Error e) {
                warning ("Error installing package: %s", e.message);
                return;
            }

            Pk.Error err = result.get_error_code ();
            if (err != null) {
                warning ("%s: %s, %s\n", "Error installing package(s)!", err.code.to_string (), err.details);
                return;
            }
        }));

        return true;
    }

    private void progress_callback (Pk.Progress progress, Pk.ProgressType type) {
        progress_changed (progress.percentage);
    }
}
