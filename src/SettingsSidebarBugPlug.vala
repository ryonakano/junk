// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2012-2014 Switchboard Developers (http://launchpad.net/switchboard)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Corentin Noël <corentin@elementaryos.org>
 */

public class SettingsSidebarBugPlug : Switchboard.Plug {
    private class CustomSettingsPage : Switchboard.SettingsPage {
        public int num { get; construct; }

        public CustomSettingsPage (int num) {
            Object (num: num);
        }

        construct {
            title = "Page %d".printf (num);
            description = "Test page %d".printf (num);
            icon = new ThemedIcon ("system-run");
            show_end_title_buttons = true;

            var label = new Gtk.Label ("This is page %d".printf (num)) {
                halign = Gtk.Align.CENTER,
                valign = Gtk.Align.CENTER
            };
            child = label;
        }
    }

    private int count;
    private Gtk.Paned content;
    private Gtk.Stack stack;
    private Switchboard.SettingsSidebar sidebar;
    private Gtk.Button remove_button;

    public SettingsSidebarBugPlug () {
        Object (category: Category.SYSTEM,
                code_name: "settings-page-bug-plug",
                display_name: "Bug in SettingsSidebar",
                description: "Reproduce a bug in Switchboard.SettingsSidebar",
                icon: "applications-development",
                supported_settings: new Gee.TreeMap<string, string?> (null, null));
    }

    public override Gtk.Widget get_widget () {
        if (content != null) {
            return content;
        }

        count = 0;

        stack = new Gtk.Stack ();

        sidebar = new Switchboard.SettingsSidebar (stack) {
            show_title_buttons = true,
            vexpand = true
        };

        var add_button = new Gtk.Button.from_icon_name ("list-add") {
            tooltip_text = "Add"
        };
        remove_button = new Gtk.Button.from_icon_name ("list-remove") {
            tooltip_text = "Remove"
        };

        var action_bar = new Gtk.ActionBar ();
        action_bar.pack_start (add_button);
        action_bar.pack_start (remove_button);

        var sidebar_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sidebar_box.append (sidebar);
        sidebar_box.append (action_bar);

        content = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            start_child = sidebar_box,
            end_child = stack,
            resize_start_child = false,
            shrink_start_child = false,
            shrink_end_child = false,
            hexpand = true
        };

        add_button.clicked.connect (add_view);
        remove_button.clicked.connect (remove_view);

        sidebar.bind_property ("visible-child-name",
            remove_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            ((binding, visible_child_name, ref sensitive) => {
                sensitive = ((string) visible_child_name) != null;
                return true;
            })
        );

        return content;
    }

    private void add_view () {
        stack.add_named (new CustomSettingsPage (count), "Page %d".printf (count));
        count++;
    }

    private void remove_view () {
        unowned string? name = sidebar.visible_child_name;
        if (name == null) {
            return;
        }

        unowned Gtk.Widget? visible_child = stack.get_child_by_name (name);
        if (visible_child == null) {
            return;
        }

        stack.remove (visible_child);
        remove_button.sensitive = false;
    }

    public override void shown () {
        // Nop
    }

    public override void hidden () {
        // Nop
    }

    public override void search_callback (string location) {
        // Nop
    }

    // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
    public override async Gee.TreeMap<string, string> search (string search) {
        return new Gee.TreeMap<string, string> (null, null);
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating SettingsSidebarBugPlug");
    var plug = new SettingsSidebarBugPlug ();
    return plug;
}
