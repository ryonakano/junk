public class MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application app) {
        Object (
            application: app
        );
    }

    construct {
        Gee.List<Granite.Services.Contract> contracts = null;

        var button = new Gtk.Button () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
        };

        child = button;

        try {
            contracts = Granite.Services.ContractorProxy.get_contracts_by_mime ("application/pdf");
        } catch (Error err) {
            error ("Failed to get_contracts_by_mime(): %s", err.message);
        }

        assert (contracts.size > 0);

        button.label = contracts[0].get_display_name ();

        button.clicked.connect (() => {
            try {
                var file = File.new_for_path ("/usr/share/cups/data/default-testpage.pdf");
                contracts[0].execute_with_file (file);
            } catch (Error err) {
                error ("Failed to execute_with_file(): %s", err.message);
            }
        });
    }
}
