/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    private const string APPLICATION_ID = "io.github.ryonakano.portal-dynamic-launcher-demo";

    private Xdp.Portal? portal = null;
    private Gtk.ApplicationWindow? main_window = null;
    private string[] desktop_entries = {};
    private ListStore list_store = new ListStore (typeof (DesktopEntry));

    private class DesktopEntry : Object {
        public string name { get; construct; }

        public DesktopEntry (string name) {
            Object (
                name: name
            );
        }
    }

    public Application () {
        Object (
            flags: ApplicationFlags.FLAGS_NONE,
            application_id: APPLICATION_ID
        );
    }

    protected override void startup () {
        if (portal == null) {
            portal = new Xdp.Portal ();
        }

        // TODO: Save and restore added entries from GSettings
        desktop_entries += APPLICATION_ID + ".example.desktop";

        base.startup ();
    }

    protected override void activate () {
        if (main_window != null) {
            main_window.present ();
            return;
        }

        var list = new Gtk.ListBox () {
            hexpand = true,
            vexpand = true
        };
        list.set_placeholder (create_list_placeholder ());

        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic");

        var action_bar = new Gtk.ActionBar ();
        action_bar.pack_start (add_button);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        box.append (list);
        box.append (action_bar);

        main_window = new Gtk.ApplicationWindow (this) {
            child = box,
            width_request = 640,
            height_request = 480
        };

        add_button.clicked.connect (() => {
            add_entry.begin ((obj, res) => {
                bool ret = add_entry.end (res);
                if (!ret) {
                    return;
                }

                load_desktop_entries (ref list_store);
            });
        });

        load_desktop_entries (ref list_store);
        list.bind_model (list_store, create_desktop_entry_widget);
        main_window.present ();
    }

    private async bool add_entry () {
        const string ENTRY_NAME = "Portal Dynamic Launcher Demo";

        Xdp.Parent? parent = null;
        if (active_window != null) {
            parent = Xdp.parent_new_gtk (active_window);
        }

        var icon_file = File.new_for_path ("/home/ryo/work/ryonakano/junk2/portal-dynamic-launcher-demo.svg");
        Bytes icon_bytes;
        try {
            icon_bytes = icon_file.load_bytes ();
        } catch (Error err) {
            warning ("Failed to load bytes from file: %s", err.message);
            return false;
        }

        var bytes_icon = new BytesIcon (icon_bytes);
        Variant icon = bytes_icon.serialize ();

        Variant result;
        try {
            result = yield portal.dynamic_launcher_prepare_install (
                parent, ENTRY_NAME, icon,
                Xdp.LauncherType.APPLICATION, null, false, false, null
            );
        } catch (Error err) {
            warning ("Failed to prepare installation of entry: %s", err.message);
            return false;
        }

        Variant? chosen_name_v = result.lookup_value ("name", VariantType.STRING);
        Variant? token_v = result.lookup_value ("token", VariantType.STRING);
        if (chosen_name_v == null || token_v == null) {
            critical ("Failed to install dynamic launcher: Xdp.dynamic_launcher_prepare_install returns invalid data");
            return false;
        }

        const string ENTRY_ID = APPLICATION_ID + ".example.desktop";
        const string ENTRY_DATA = """
[Desktop Entry]
GenericName=Demo App
Comment=Demonstrate libportal dynamic launcher module
Categories=GTK;Utility;
Exec=gnome-software
Type=Application
        """;

        try {
            portal.dynamic_launcher_install ((string) token_v, ENTRY_ID, ENTRY_DATA);
        } catch (Error err) {
            warning ("Failed to install dynamic launcher: %s", err.message);
            return false;
        }

        desktop_entries += ENTRY_ID;
        return true;
    }

    private Gtk.Widget create_list_placeholder () {
        var label = new Gtk.Label ("No Entries Found");

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        box.append (label);

        return box;
    }

    private Gtk.Widget create_desktop_entry_widget (Object item) {
        DesktopEntry entry = (DesktopEntry) item;

        var label = new Gtk.Label (entry.name) {
            halign = Gtk.Align.START
        };

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        box.append (label);

        return box;
    }

    private void load_desktop_entries (ref ListStore list_store) {
        list_store.remove_all ();

        foreach (unowned var desktop_entry in desktop_entries) {
            string desktop_file_content;
            try {
                desktop_file_content = portal.dynamic_launcher_get_desktop_entry (desktop_entry);
            } catch (Error err) {
                warning ("Failed to get desktop entry \"%s\": %s", desktop_entry, err.message);
                continue;
            }

            debug ("Desktop Entry \"%s\": %s", desktop_entry, desktop_file_content);
            list_store.append (new DesktopEntry ("test"));
        }
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
