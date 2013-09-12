namespace Drives
{
    [DBus (name = "org.freedesktop.UDisks")]
    interface UDisk_if : GLib.Object {
        public signal void DeviceAdded (ObjectPath device);
        public signal void DeviceRemoved (ObjectPath device);
        public signal void DeviceChanged (ObjectPath device);
        public abstract ObjectPath[] EnumerateDevices() throws IOError;
    }

    [DBus (name = "org.freedesktop.UDisks.Device")]
    interface Device_if : GLib.Object {
        public abstract string IdLabel { owned get; }
        public abstract string DriveVendor { owned get; }
        public abstract string DriveSerial { owned get; }
        public abstract string DeviceFile { owned get; }
        public abstract string DriveModel { owned get; }
        public abstract uint64 DeviceSize { owned get; }
        public abstract uint64 PartitionSize { owned get; }
        public abstract string DevicePresentationIconName { owned get; }
        public abstract string IdType { owned get; }
        public abstract string IdUsage { owned get; }
        public abstract string PartitionType { owned get; }
        public abstract string DriveAtaSmartStatus { owned get; }
        public abstract string PartitionTableScheme { owned get; }
        public abstract string[] DeviceMountPaths { owned get; }
        public abstract string[] DriveMediaCompatibility { owned get; }
        public abstract bool DeviceIsPartition { owned get; }
        public abstract bool DeviceIsOpticalDisc { owned get; }
        public abstract bool DeviceIsMediaAvailable { owned get; }
        public abstract bool DeviceIsRemovable { owned get; }
        public abstract bool DeviceIsMounted { owned get; }
        public abstract bool DriveIsMediaEjectable { owned get; }
        public abstract bool DriveCanDetach { owned get; }
        public abstract bool DeviceIsSystemInternal {owned get; }
        public abstract bool DeviceIsDrive {owned get; }
        public abstract bool DeviceIsPartitionTable {owned get; }
        public abstract bool DriveAtaSmartIsAvailable {owned get; }

        public abstract void FilesystemUnmount(string[] options) throws IOError;
        public abstract void FilesystemCreate(string type, string[] options) throws IOError;
        public abstract void PartitionModify (string type, string label, string[] options) throws IOError;
        public abstract void FilesystemMount(string type, string[] options, out string mount_path) throws IOError;
    }

    class DrivesPlug : Pantheon.Switchboard.Plug
    {
        private DrivesList source_list;
        private DriveDetails content_area;

        public DrivesPlug () {
            // Create views
            source_list = new DrivesList ();
            source_list.width_request = 100;
            content_area = new DriveDetails ();
            content_area.expand = false;
            var pane = new Granite.Widgets.ThinPaned ();
            pane.pack1 (source_list, true, false);
            pane.pack2 (content_area, true, false);
            this.add (pane);

            // Handle events
            source_list.item_selected.connect ((item) => {
                var d = item as ListDriveItem;
                loadItemView (d);
                source_list.driveSelectedClean ();
                d.is_selected = true;
            });

            source_list.refresh_selected.connect ((item) => {
                var d = item as ListDriveItem;
                loadItemView (d);
            });
        }

        public void loadItemView (ListDriveItem item) {
            var device = Bus.get_proxy_sync<Device_if> (BusType.SYSTEM, "org.freedesktop.UDisks", item.dbus_path);
            if (device.DeviceIsPartition) {
                content_area.loadPartitionInformation (item);
            } else {
                content_area.loadDriveInformation (item);
            }
        }
    }

    /**
     * DrivesList. List of drives
     */
    class DrivesList : Granite.Widgets.SourceList
    {
        public signal void refresh_selected (ListDriveItem item);
        private UDisk_if udisk;

        public DrivesList () {
            // Get devices
            udisk = Bus.get_proxy_sync<UDisk_if> (BusType.SYSTEM, "org.freedesktop.UDisks","/org/freedesktop/UDisks");
            udisk.DeviceAdded.connect ((o) => {
                driveAdd (o);
            });
            udisk.DeviceRemoved.connect ((o) => {
                driveRemove (o);
            });
            udisk.DeviceChanged.connect ((o) => {
                foreach (var child_item in this.root.children) {
                    var child = child_item as ListDriveItem;
                    if (child.dbus_path == o) {
                        // Refresh contents if selected
                        if (o == driveGetSelected ()) {
                            refresh_selected (child);
                        }
                        // Refresh 'umount' button
                        child.reloadEjectButton ();
                        break;
                    }
                }
            });

            loadDrives ();
        }

        public ListDriveItem driveAdd (string o) {
            var drive_item = new ListDriveItem (o);
            this.root.add (drive_item);
            return drive_item;
        }

        public void driveRemove (string o) {
            var selected = driveGetSelected ();
            loadDrives ();
            driveSelectPath (selected);
        }

        public string driveGetSelected () {
            foreach (var child_item in this.root.children) {
                var child = child_item as ListDriveItem;
                if (child.is_selected) {
                    return child.dbus_path;
                    break;
                }
            }
            return "";
        }

        public void driveSelectedClean () {
            foreach (var child_item in this.root.children) {
                var child = child_item as ListDriveItem;
                if (child.is_selected) {
                    child.is_selected = false;
                    break;
                }
            }
        }

        public void driveSelectPath (string path) {
            driveSelectedClean ();
            foreach (var child_item in this.root.children) {
                var child = child_item as ListDriveItem;
                if (child.dbus_path == path) {
                    child.is_selected = true;
                    this.selected = child_item;
                    break;
                }
                else if (child.is_file_system && path == "") {
                    child.is_selected = true;
                    this.selected = child_item;
                    break;
                }
            }
        }

        public void loadDrives () {
            this.root.clear ();

            // Internal devices
            loadDrivesBucle (true);

            // External devices (and mounted SD cards)
            loadDrivesBucle (false);

            // TODO : Disks (!device.DeviceIsPartitionTable)
            // ...
        }

        public void loadDrivesBucle (bool system_internal) {
            var devices = udisk.EnumerateDevices();

            // Internal devices
            foreach (ObjectPath o in devices) {
                var device = Bus.get_proxy_sync<Device_if> (BusType.SYSTEM, "org.freedesktop.UDisks",o);
                if (device.DeviceIsPartitionTable && (device.DeviceIsSystemInternal == system_internal)) {
                    var device_ref = driveAdd (o);

                    // Device partitions
                    var serial = device.DriveSerial;
                    foreach (ObjectPath xo in devices) {
                        var inner_device = Bus.get_proxy_sync<Device_if> (BusType.SYSTEM, "org.freedesktop.UDisks",xo);
                        if (serial == inner_device.DriveSerial && inner_device.DeviceIsPartition) {
                            var inner_device_ref = driveAdd (xo);
                            if (inner_device_ref.is_file_system) device_ref.is_file_system = true;
                        }
                    }
                }
            }
        }
    }

    /**
     * SourceList item. It stores the information of a list item.
     */
    class ListDriveItem : Granite.Widgets.SourceList.Item {
        public string dbus_path { get; set; default = ""; }
        public bool is_selected { get; set; default = false; }
        public bool is_file_system { get; set; default = false; }
        public string show_label { get; set; default = ""; }
        public string icon_name { get; set; default = ""; }

        public ListDriveItem (string o) {
            base ("");
            loadFromPath (o);
        }

        public void loadFromPath (string o) {
            dbus_path = o;
            var device = Bus.get_proxy_sync<Device_if> (BusType.SYSTEM, "org.freedesktop.UDisks", o);

            show_label = "Drive";
            icon_name = "drive-harddisk";
            if (!device.DeviceIsSystemInternal) icon_name = "drive-removable-media-usb";
            foreach (var media_compatibility in device.DriveMediaCompatibility) {
                if ("flash" in media_compatibility) {
                    icon_name = "media-flash";
                    break;
                } else if ("optical" in media_compatibility) {
                    icon_name = "drive-optical";
                    break;
                }
            }

            if (device.DeviceIsPartitionTable) {
                show_label = device.DriveModel;
                this.icon = new ThemedIcon.with_default_fallbacks (icon_name);
                this.name = show_label;

            } else {
                show_label = device.IdLabel;
                if (show_label=="")     show_label = device.IdType;
                if (show_label=="swap") show_label = _("Linux Swap");
                if (show_label=="")     show_label = _("Unkown");

                foreach (var path in device.DeviceMountPaths) {
                    if (path == "/" ) {
                        is_file_system = true;
                        show_label = _("File System");
                    }
                }
                this.name = "        "+show_label;
            }

            reloadEjectButton ();
        }

        public void reloadEjectButton () {
            var device = Bus.get_proxy_sync<Device_if> (BusType.SYSTEM, "org.freedesktop.UDisks", dbus_path);

            if (device.DeviceIsPartition && !is_file_system) {
                if (device.DeviceIsMounted && this.activatable == null) {
                    this.activatable = new ThemedIcon.with_default_fallbacks ("media-eject");
                    this.action_activated.connect (buttonUnmountEvent);
                } else {
                    this.activatable = null;
                    this.action_activated.disconnect (buttonUnmountEvent);
                }
            }
        }

        public void buttonUnmountEvent (Granite.Widgets.SourceList.Item o) {
            var item = o as ListDriveItem;
            var device = Bus.get_proxy_sync<Device_if> (BusType.SYSTEM, "org.freedesktop.UDisks", item.dbus_path);
            device.FilesystemUnmount (null);
        }
    }

    /**
     * This class is for showing the details of one drive
     *
     */
    class DriveDetails : Gtk.EventBox
    {
        protected Gtk.Notebook view_switcher;
        protected Gtk.Box view_welcome;
        protected Gtk.Box view_drive;
        protected Gtk.Box view_partition;
        protected int page_welcome;
        protected int page_drive;
        protected int page_partition;

        protected Gtk.Image? drive_icon;
        protected Gtk.Label drive_name_label;
        protected Gtk.Label drive_kind_label;
        protected Gtk.Label drive_serial_label;
        protected Gtk.Label drive_device_label;
        protected Gtk.Label drive_smart_label;
        protected Gtk.Label drive_partitioning_label;
        protected Gtk.Label drive_capacity_label;
        protected Gtk.Button drive_format_button;
        protected ulong drive_format_handler;
        protected Gtk.Button drive_restore_button;
        protected ulong drive_restore_handler;

        protected Gtk.Image? partition_icon;
        protected Gtk.Label partition_name_label;
        protected Gtk.Label partition_kind_label;
        protected Gtk.Label partition_type_label;
        protected Gtk.Label partition_usage_label;
        protected Gtk.Label partition_device_label;
        protected Gtk.Label partition_mount_label;
        protected Gtk.Label partition_capacity_label;
        protected Gtk.Box partition_resume_box;
        protected Gtk.Label partition_resume_label;
        protected Gtk.DrawingArea details_usage_graphic_contents;
        protected int partition_percentage_used;
        protected int partition_percentage_user;
        protected Gtk.Button partition_mount_button;
        protected ulong partition_mount_handler;
        protected Gtk.Button partition_files_button;
        protected ulong partition_files_handler;
        protected Gtk.Button partition_erase_button;
        protected ulong partition_erase_handler;

        public DriveDetails () {
            get_style_context().add_class (Granite.StyleClass.CONTENT_VIEW);

            view_switcher = new Gtk.Notebook ();
            view_switcher.show_tabs = false;
            view_switcher.show_border = false;
            view_switcher.expand = true;

            constructViewWelcome ();
            constructViewDrive ();
            constructViewPartition ();

            page_welcome = view_switcher.append_page (view_welcome, null);
            page_drive = view_switcher.append_page (view_drive, null);
            page_partition = view_switcher.append_page (view_partition, null);

            this.add (view_switcher);
        }

        public void loadDriveInformation (ListDriveItem item) {
            var device = Bus.get_proxy_sync<Device_if> (BusType.SYSTEM, "org.freedesktop.UDisks", item.dbus_path);

            drive_icon.clear ();
            drive_icon.set_from_icon_name (item.icon_name, Gtk.IconSize.DIALOG);
            if (drive_icon == null) {
                drive_icon = new Gtk.Image.from_icon_name ("drive-harddisk", Gtk.IconSize.DIALOG);
            }

            drive_name_label.label = item.show_label;
            drive_kind_label.label = _("Drive");

            drive_serial_label.label = device.DriveSerial;
            drive_device_label.label = device.DeviceFile;
            if (device.DriveAtaSmartIsAvailable) {
                drive_smart_label.label = _("Disk is healthy");

                var smart = device.DriveAtaSmartStatus;
                if (smart == "AD_ATTRIBUTES_IN_THE_PAST") drive_smart_label.label = _("Disk exceeded its threshold");
                else if (smart == "BAD_SECTOR") drive_smart_label.label = _("At least one bad sector");
                else if (smart == "BAD_ATTRIBUTE_NOW") drive_smart_label.label = _("Disk exceeding its threshold");
                else if (smart == "BAD_SECTOR_MANY") drive_smart_label.label = _("Many bad sectors");
                else if (smart == "BAD_STATUS") drive_smart_label.label = _("Self assessment negative");
            } else {
                drive_smart_label.label = _("Not Supported");
            }

            drive_partitioning_label.label = _("Unknown");

            var partitioning = device.PartitionTableScheme;
            if (partitioning == "none") drive_partitioning_label.label = _("None");
            else if (partitioning == "mbr") drive_partitioning_label.label = _("Master Boot Record");
            else if (partitioning == "gpt") drive_partitioning_label.label = _("GUID Partition Table");
            else if (partitioning == "apm") drive_partitioning_label.label = _("Apple Partition Map");

            drive_capacity_label.label = bytesToHuman ((long) device.DeviceSize);

            drive_format_button.visible = true;
            drive_restore_button.visible = true;
            if (item.is_file_system) {
                drive_format_button.visible = false;
                drive_restore_button.visible = false;
            }

            view_switcher.set_current_page (page_drive);
        }

        public void loadPartitionInformation (ListDriveItem item) {
            var device = Bus.get_proxy_sync<Device_if> (BusType.SYSTEM, "org.freedesktop.UDisks", item.dbus_path);

            partition_icon.clear ();
            partition_icon.set_from_icon_name (item.icon_name, Gtk.IconSize.DIALOG);
            if (partition_icon == null) {
                partition_icon = new Gtk.Image.from_icon_name ("drive-harddisk", Gtk.IconSize.DIALOG);
            }

            partition_name_label.label = device.DriveModel;
            partition_kind_label.label = _("Partition")+", "+item.show_label;

            var partition_type = device.IdType;
            var partition_usage = device.IdUsage;
            var partition_mount = device.DeviceMountPaths[0];

            if (partition_type == "") partition_type = _("Unknown");
            if (partition_usage == "") partition_usage = _("Unknown");
            if (!device.DeviceIsMounted) {
                partition_mount = _("Not mounted");
            }

            partition_type_label.label = partition_type;
            partition_usage_label.label = partition_usage;
            partition_device_label.label = device.DeviceFile;
            partition_mount_label.label = partition_mount;
            partition_capacity_label.label = bytesToHuman ((long) device.PartitionSize);

            if (device.DeviceIsMounted) {
                partition_mount_button.visible = false;
                partition_files_button.visible = true;
                partition_resume_box.visible = true;
                details_usage_graphic_contents.visible = true;
            } else if (device.IdType == "Unknown"
                || device.IdType == "swap"
                || device.IdType == "") {
                partition_mount_button.visible = false;
                partition_files_button.visible = false;
                partition_resume_box.visible = false;
                details_usage_graphic_contents.visible = false;
            } else {
                partition_mount_button.visible = true;
                partition_files_button.visible = false;
                partition_resume_box.visible = false;
                details_usage_graphic_contents.visible = false;
            }

            if (partition_mount_handler != 0) partition_mount_button.disconnect (partition_mount_handler);
            partition_mount_handler = partition_mount_button.clicked.connect (() => {
                string path = "";
                device.FilesystemMount (device.IdType, null, out path);
            });

            var mount_point = partition_mount;
            if (!device.DeviceIsMounted) mount_point = "/";

            if (device.DeviceIsMounted) {
                GLib.File file = File.new_for_path (mount_point);
                GLib.FileInfo info = file.query_filesystem_info ("filesystem::size,filesystem::free");
                long partition_disk_space = long.parse (info.get_attribute_as_string ("filesystem::size"));
                long partition_disk_free = long.parse (info.get_attribute_as_string ("filesystem::free"));
                long partition_disk_user = 0;
                if (item.is_file_system) {
                    GLib.File file_user = File.new_for_path (GLib.Environment.get_home_dir ());
                    // Mida d'un directori http://gezeiten.org/post/2009/04/Writing-Your-Own-GIO-Jobs
                    // Més fàcil : du -s /home/albert/
                }
                partition_resume_label.label = bytesToHuman(partition_disk_free)+_(" available");
                partition_percentage_used = (int) (100 - ((partition_disk_free * 100) / partition_disk_space));
                partition_percentage_user = 0;
                details_usage_graphic_contents.queue_draw ();
            }

            if (partition_files_handler != 0) partition_files_button.disconnect (partition_files_handler);
            partition_files_handler = partition_files_button.clicked.connect (() => {
                Granite.Services.System.execute_command ("gvfs-open "+mount_point.replace (" ", "\\ "));
            });

            view_switcher.set_current_page (page_partition);
        }

        public string bytesToHuman (long b) {
            float size_total = b/1024f/1024f/1024f;                     // Bytes to GB
            string size_total_string = "";
            if (size_total < 1) {                                       // Less than 100MB
                size_total = b/1024f/1024f;                             // Bytes to MB
                size_total = GLib.Math.floorf (size_total * 100) / 100; // max 2 decimals
                size_total_string = size_total.to_string () + " MiB";
            } else {
                size_total = GLib.Math.floorf (size_total * 100) / 100; // max 2 decimals
                size_total_string = size_total.to_string () + " GiB";
            }
            return size_total_string;
        }

        public void constructViewWelcome () {
            view_welcome = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            view_welcome.homogeneous = false;

            var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            // Top spacer
            content.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);

            // Icon
            var view_welcome_image = new Gtk.Image.from_icon_name ("drive-harddisk", Gtk.IconSize.DIALOG);
            if (view_welcome_image != null) {
                view_welcome_image.set_pixel_size (128);
                content.pack_start (view_welcome_image, false, true, 8);
            }

            // Title
            var view_welcome_title_label = new Gtk.Label (_("Drives"));
            Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H1, view_welcome_title_label);
            view_welcome_title_label.set_justify (Gtk.Justification.CENTER);
            content.pack_start (view_welcome_title_label, false, true, 0);

            // Subtitle
            var view_welcome_subtitle_label = new Gtk.Label (_("Get information and format partitions."));
            Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H2, view_welcome_subtitle_label);
            view_welcome_subtitle_label.sensitive = false;
            view_welcome_subtitle_label.set_justify (Gtk.Justification.CENTER);
            content.pack_start (view_welcome_subtitle_label, false, true, 2);

            // Options wrapper
            var options = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            var options_wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            options_wrapper.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // left padding
            options_wrapper.pack_start (options, false, false, 0); // actual options
            options_wrapper.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // right padding

            content.pack_start (options_wrapper, false, false, 20);

            // Bottom spacer
            content.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);

            view_welcome.pack_start (content, true, true, 0);
        }

        public void constructViewDrive () {
            view_drive = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            view_drive.homogeneous = false;

            var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            // Top spacer
            var top_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            top_box.valign = Gtk.Align.CENTER;
            content.pack_start (top_box, false, false, 10);

            // Title labels
            drive_name_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='11700'>%s</span>", _("Drive")));
            Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H3, drive_name_label);
            drive_name_label.use_markup = true;
            drive_name_label.halign = Gtk.Align.START;
            drive_name_label.valign = Gtk.Align.CENTER;

            drive_kind_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='11700'>%s</span>", _("Drive")));
            drive_kind_label.use_markup = true;
            drive_kind_label.halign = Gtk.Align.START;
            drive_kind_label.valign = Gtk.Align.CENTER;
            drive_kind_label.sensitive = false;

            // Title
            var title_contents = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            title_contents.homogeneous = true;
            title_contents.halign = Gtk.Align.CENTER;
            title_contents.valign = Gtk.Align.CENTER;

            // Title image
            drive_icon = new Gtk.Image.from_icon_name ("drive-harddisk", Gtk.IconSize.DIALOG);
            if (drive_icon != null) {
                drive_icon.set_pixel_size (64);
                title_contents.pack_start (drive_icon, false, true, 0);
            }

            // Title labels box
            var title_list = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            title_list.valign = Gtk.Align.CENTER;
            title_list.pack_start (drive_name_label, false, true, 0);
            title_list.pack_start (drive_kind_label, false, false, 0);
            title_contents.pack_start (title_list, false, false, 0);
            content.pack_start (title_contents, false, false, 0);

            // Spacer
            content.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), false, false, 15);

            // Details serial number
            var drive_serial_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("Serial number")));
            drive_serial_label_title.use_markup = true;
            drive_serial_label_title.halign = Gtk.Align.END;
            drive_serial_label_title.valign = Gtk.Align.CENTER;
            drive_serial_label_title.sensitive = false;

            drive_serial_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("Serial number")));
            drive_serial_label.use_markup = true;
            drive_serial_label.halign = Gtk.Align.START;
            drive_serial_label.valign = Gtk.Align.CENTER;

            var drive_serial = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            drive_serial.homogeneous = true;
            drive_serial.halign = Gtk.Align.CENTER;
            drive_serial.valign = Gtk.Align.CENTER;
            drive_serial.pack_start (drive_serial_label_title, false, true, 5);
            drive_serial.pack_start (drive_serial_label, false, true, 0);
            content.pack_start (drive_serial, false, false, 2);

            // Details device
            var drive_device_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("Device")));
            drive_device_label_title.use_markup = true;
            drive_device_label_title.halign = Gtk.Align.END;
            drive_device_label_title.valign = Gtk.Align.CENTER;
            drive_device_label_title.sensitive = false;

            drive_device_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("Device")));
            drive_device_label.use_markup = true;
            drive_device_label.halign = Gtk.Align.START;
            drive_device_label.valign = Gtk.Align.CENTER;

            var drive_device = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            drive_device.homogeneous = true;
            drive_device.halign = Gtk.Align.CENTER;
            drive_device.valign = Gtk.Align.CENTER;
            drive_device.pack_start (drive_device_label_title, false, true, 5);
            drive_device.pack_start (drive_device_label, false, true, 0);
            content.pack_start (drive_device, false, false, 2);

            // Details SMART
            var drive_smart_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("SMART Status")));
            drive_smart_label_title.use_markup = true;
            drive_smart_label_title.halign = Gtk.Align.END;
            drive_smart_label_title.valign = Gtk.Align.CENTER;
            drive_smart_label_title.sensitive = false;

            drive_smart_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("SMART Status")));
            drive_smart_label.use_markup = true;
            drive_smart_label.halign = Gtk.Align.START;
            drive_smart_label.valign = Gtk.Align.CENTER;

            var drive_smart = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            drive_smart.homogeneous = true;
            drive_smart.halign = Gtk.Align.CENTER;
            drive_smart.valign = Gtk.Align.CENTER;
            drive_smart.pack_start (drive_smart_label_title, false, true, 5);
            drive_smart.pack_start (drive_smart_label, false, true, 0);
            content.pack_start (drive_smart, false, false, 2);

            // Details partitioning
            var drive_partitioning_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("Partitioning")));
            drive_partitioning_label_title.use_markup = true;
            drive_partitioning_label_title.halign = Gtk.Align.END;
            drive_partitioning_label_title.valign = Gtk.Align.CENTER;
            drive_partitioning_label_title.sensitive = false;

            drive_partitioning_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("Partitioning")));
            drive_partitioning_label.use_markup = true;
            drive_partitioning_label.halign = Gtk.Align.START;
            drive_partitioning_label.valign = Gtk.Align.CENTER;

            var drive_partitioning = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            drive_partitioning.homogeneous = true;
            drive_partitioning.halign = Gtk.Align.CENTER;
            drive_partitioning.valign = Gtk.Align.CENTER;
            drive_partitioning.pack_start (drive_partitioning_label_title, false, true, 5);
            drive_partitioning.pack_start (drive_partitioning_label, false, true, 0);
            content.pack_start (drive_partitioning, false, false, 2);

            // Details capacity
            var drive_capacity_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("Capacity")));
            drive_capacity_label_title.use_markup = true;
            drive_capacity_label_title.halign = Gtk.Align.END;
            drive_capacity_label_title.valign = Gtk.Align.CENTER;
            drive_capacity_label_title.sensitive = false;

            drive_capacity_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("Capacity")));
            drive_capacity_label.use_markup = true;
            drive_capacity_label.halign = Gtk.Align.START;
            drive_capacity_label.valign = Gtk.Align.CENTER;

            var drive_capacity = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            drive_capacity.homogeneous = true;
            drive_capacity.halign = Gtk.Align.CENTER;
            drive_capacity.valign = Gtk.Align.CENTER;
            drive_capacity.pack_start (drive_capacity_label_title, false, true, 5);
            drive_capacity.pack_start (drive_capacity_label, false, true, 0);
            content.pack_start (drive_capacity, false, false, 2);

            // Spacer
            content.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), false, false, 15);

            // Tools buttons
            var bottom_buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            bottom_buttons_box.halign = Gtk.Align.CENTER;
            bottom_buttons_box.valign = Gtk.Align.CENTER;
            drive_format_button = new Gtk.Button.with_label (" "+_("Format Drive")+" ");
            bottom_buttons_box.pack_start (drive_format_button, false, true, 5);
            drive_format_button.clicked.connect (show_light_window);
            content.pack_end (bottom_buttons_box, false, false, 10);

            // Options wrapper
            var options = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            var options_wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            options_wrapper.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // left padding
            options_wrapper.pack_start (options, false, false, 0); // actual options
            options_wrapper.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // right padding

            content.pack_start (options_wrapper, false, false, 20);

            // Bottom spacer
            content.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);

            view_drive.pack_start (content, true, true, 0);
        }

        public void constructViewPartition () {
            view_partition = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            view_partition.homogeneous = false;

            var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            // Top spacer
            var top_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            top_box.valign = Gtk.Align.CENTER;
            content.pack_start (top_box, false, false, 10);

            // Title labels
            partition_name_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='11700'>%s</span>", _("Partition")));
            Granite.Widgets.Utils.apply_text_style_to_label (Granite.TextStyle.H3, partition_name_label);
            partition_name_label.use_markup = true;
            partition_name_label.halign = Gtk.Align.START;
            partition_name_label.valign = Gtk.Align.CENTER;

            partition_kind_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='11700'>%s</span>", _("Partition")));
            partition_kind_label.use_markup = true;
            partition_kind_label.halign = Gtk.Align.START;
            partition_kind_label.valign = Gtk.Align.CENTER;
            partition_kind_label.sensitive = false;

            // Title
            var title_contents = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            title_contents.homogeneous = true;
            title_contents.halign = Gtk.Align.CENTER;
            title_contents.valign = Gtk.Align.CENTER;

            // Title image
            partition_icon = new Gtk.Image.from_icon_name ("drive-harddisk", Gtk.IconSize.DIALOG);
            if (partition_icon != null) {
                partition_icon.set_pixel_size (64);
                title_contents.pack_start (partition_icon, false, true, 0);
            }

            // Title labels box
            var title_list = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            title_list.valign = Gtk.Align.CENTER;
            title_list.pack_start (partition_name_label, false, true, 0);
            title_list.pack_start (partition_kind_label, false, false, 0);
            title_contents.pack_start (title_list, false, false, 0);
            content.pack_start (title_contents, false, false, 0);

            // Spacer
            content.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), false, false, 15);

            // Details type
            var partition_type_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("Type")));
            partition_type_label_title.use_markup = true;
            partition_type_label_title.halign = Gtk.Align.END;
            partition_type_label_title.valign = Gtk.Align.CENTER;
            partition_type_label_title.sensitive = false;

            partition_type_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("Type")));
            partition_type_label.use_markup = true;
            partition_type_label.halign = Gtk.Align.START;
            partition_type_label.valign = Gtk.Align.CENTER;

            var partition_type = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            partition_type.homogeneous = true;
            partition_type.halign = Gtk.Align.CENTER;
            partition_type.valign = Gtk.Align.CENTER;
            partition_type.pack_start (partition_type_label_title, false, true, 5);
            partition_type.pack_start (partition_type_label, false, true, 0);
            content.pack_start (partition_type, false, false, 2);

            // Details usage
            var partition_usage_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("Usage")));
            partition_usage_label_title.use_markup = true;
            partition_usage_label_title.halign = Gtk.Align.END;
            partition_usage_label_title.valign = Gtk.Align.CENTER;
            partition_usage_label_title.sensitive = false;

            partition_usage_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("Usage")));
            partition_usage_label.use_markup = true;
            partition_usage_label.halign = Gtk.Align.START;
            partition_usage_label.valign = Gtk.Align.CENTER;

            var partition_usage = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            partition_usage.homogeneous = true;
            partition_usage.halign = Gtk.Align.CENTER;
            partition_usage.valign = Gtk.Align.CENTER;
            partition_usage.pack_start (partition_usage_label_title, false, true, 5);
            partition_usage.pack_start (partition_usage_label, false, true, 0);
            content.pack_start (partition_usage, false, false, 2);

            // Details device
            var partition_device_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("Device")));
            partition_device_label_title.use_markup = true;
            partition_device_label_title.halign = Gtk.Align.END;
            partition_device_label_title.valign = Gtk.Align.CENTER;
            partition_device_label_title.sensitive = false;

            partition_device_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("Device")));
            partition_device_label.use_markup = true;
            partition_device_label.halign = Gtk.Align.START;
            partition_device_label.valign = Gtk.Align.CENTER;

            var partition_device = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            partition_device.homogeneous = true;
            partition_device.halign = Gtk.Align.CENTER;
            partition_device.valign = Gtk.Align.CENTER;
            partition_device.pack_start (partition_device_label_title, false, true, 5);
            partition_device.pack_start (partition_device_label, false, true, 0);
            content.pack_start (partition_device, false, false, 2);

            // Details mount
            var partition_mount_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("Mount point")));
            partition_mount_label_title.use_markup = true;
            partition_mount_label_title.halign = Gtk.Align.END;
            partition_mount_label_title.valign = Gtk.Align.CENTER;
            partition_mount_label_title.sensitive = false;

            partition_mount_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("Mount point")));
            partition_mount_label.use_markup = true;
            partition_mount_label.halign = Gtk.Align.START;
            partition_mount_label.valign = Gtk.Align.CENTER;

            var partition_mount = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            partition_mount.homogeneous = true;
            partition_mount.halign = Gtk.Align.CENTER;
            partition_mount.valign = Gtk.Align.CENTER;
            partition_mount.pack_start (partition_mount_label_title, false, true, 5);
            partition_mount.pack_start (partition_mount_label, false, true, 0);
            content.pack_start (partition_mount, false, false, 2);

            // Details capacity
            var partition_capacity_label_title = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s:</span>", _("Capacity")));
            partition_capacity_label_title.use_markup = true;
            partition_capacity_label_title.halign = Gtk.Align.END;
            partition_capacity_label_title.valign = Gtk.Align.CENTER;
            partition_capacity_label_title.sensitive = false;

            partition_capacity_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'>%s</span>", _("Capacity")));
            partition_capacity_label.use_markup = true;
            partition_capacity_label.halign = Gtk.Align.START;
            partition_capacity_label.valign = Gtk.Align.CENTER;

            var partition_capacity = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            partition_capacity.homogeneous = true;
            partition_capacity.halign = Gtk.Align.CENTER;
            partition_capacity.valign = Gtk.Align.CENTER;
            partition_capacity.pack_start (partition_capacity_label_title, false, true, 5);
            partition_capacity.pack_start (partition_capacity_label, false, true, 0);
            content.pack_start (partition_capacity, false, false, 2);

            // Spacer
            content.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), false, false, 20);

            // Resume
            partition_resume_label = new Gtk.Label (Markup.printf_escaped ("<span weight='medium' size='9700'> %s</span>", _("available")));
            partition_resume_label.use_markup = true;
            partition_resume_label.halign = Gtk.Align.START;
            partition_resume_label.valign = Gtk.Align.CENTER;

            partition_resume_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            partition_resume_box.halign = Gtk.Align.CENTER;
            partition_resume_box.valign = Gtk.Align.CENTER;
            partition_resume_box.pack_start (partition_resume_label, false, true, 5);
            content.pack_start (partition_resume_box, false, false, 2);

            // Deatils usage 'graphic' box
            details_usage_graphic_contents = new Gtk.DrawingArea ();
            details_usage_graphic_contents.set_size_request (250,30);
            details_usage_graphic_contents.draw.connect (draw_usage_bar);
            content.pack_start (details_usage_graphic_contents, false, false, 2);

            // Spacer
            content.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), false, false, 15);

            // Tools buttons
            var bottom_buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            bottom_buttons_box.halign = Gtk.Align.CENTER;
            bottom_buttons_box.valign = Gtk.Align.CENTER;
            partition_files_button = new Gtk.Button.with_label (" "+_("View Files")+" ");
            bottom_buttons_box.pack_start (partition_files_button, false, true, 5);
            partition_mount_button = new Gtk.Button.with_label (" "+_("Mount")+" ");
            bottom_buttons_box.pack_start (partition_mount_button, false, true, 5);
            content.pack_end (bottom_buttons_box, false, false, 10);

            // Options wrapper
            var options = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
            var options_wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            options_wrapper.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // left padding
            options_wrapper.pack_start (options, false, false, 0); // actual options
            options_wrapper.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // right padding

            content.pack_start (options_wrapper, false, false, 20);

            // Bottom spacer
            content.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 10);

            view_partition.pack_start (content, true, true, 0);
        }

        private bool draw_usage_bar (Gtk.Widget da, Cairo.Context ctx) {
            int height = details_usage_graphic_contents.get_allocated_height ();
            int width = details_usage_graphic_contents.get_allocated_width ();
            int radius = 8;
            int x0 = (width >> 2) + radius;
            int x1 = (width - x0) - radius;
            int y0 = 1;
            int y1 = 17;
            int y2 = 30;

            // Set border width
            ctx.set_line_width (0.5);

            // Draw background
            double backR = unit(220);
            double backG = unit(217);
            double backB = unit(215);
            double borderR = unit(153);
            double borderG = unit(153);
            double borderB = unit(153);
            double shineR = unit(230);
            double shineG = unit(228);
            double shineB = unit(227);
            drawBarLeftArc (ctx, radius, x0, x1, y0, y1, y2, backR, backG, backB,
                            borderR, borderG, borderB, shineR, shineG, shineB);
            drawBarRightArc (ctx, radius, x0, x1, y0, y1, y2, backR, backG, backB,
                            borderR, borderG, borderB, shineR, shineG, shineB);
            drawBarBody (ctx, radius, x0, x1, y0, y1, y2, backR, backG, backB,
                            borderR, borderG, borderB, shineR, shineG, shineB, false);

            // Draw disk usage
            if (partition_percentage_used > 0) {
                backR = unit(62);
                backG = unit(151);
                backB = unit(232);
                borderR = unit(68);
                borderG = unit(138);
                borderB = unit(186);
                shineR = unit(114);
                shineG = unit(188);
                shineB = unit(238);
                var cutBody = true;
                drawBarLeftArc (ctx, radius, x0, x1, y0, y1, y2, backR, backG, backB,
                                borderR, borderG, borderB, shineR, shineG, shineB);
                if (partition_percentage_used > 99) {
                    cutBody = false;
                    drawBarRightArc (ctx, radius, x0, x1, y0, y1, y2, backR, backG, backB,
                                borderR, borderG, borderB, shineR, shineG, shineB);
                }
                int dx1 = x0 + (((x1 - x0) * partition_percentage_used) / 100);
                drawBarBody (ctx, radius, x0, dx1, y0, y1, y2, backR, backG, backB,
                                borderR, borderG, borderB, shineR, shineG, shineB, cutBody);
            }

            return true;
        }

        public double unit (double color) {
            return (color/256);
        }

        public void drawBarLeftArc (Cairo.Context ctx, int radius,
                                        int x0, int x1, int y0, int y1, int y2,
                                        double backR, double backG, double backB,
                                        double borderR, double borderG, double borderB,
                                        double shineR, double shineG, double shineB) {
            ctx.set_source_rgb (backR, backG, backB);
            ctx.arc (x0, y0 + radius, radius, 1.57, 4.71);
            ctx.fill ();
            ctx.set_source_rgb (borderR, borderG, borderB);
            ctx.arc (x0, y0 + radius, radius, 1.57, 4.71);
            ctx.stroke ();
            ctx.set_source_rgb (shineR, shineG, shineB); // Shining
            ctx.arc (x0, y0 + radius, radius-2, 3.95, 4.71);
            ctx.stroke ();
            // Mirror
            var pattern = new Cairo.Pattern.linear (x0, y1, x0, y2);
            pattern.add_color_stop_rgba (0, backR, backG, backB, 0.9);
            pattern.add_color_stop_rgba (1, backR, backG, backB, 0);
            ctx.set_source (pattern);
            ctx.arc (x0, y1 + radius + 1, radius, 1.57, 4.71);
            ctx.fill ();
            ctx.arc (x0, y1 + radius + 1, radius, 1.57, 4.71);
            ctx.stroke ();
        }

        public void drawBarRightArc (Cairo.Context ctx, int radius,
                                        int x0, int x1, int y0, int y1, int y2,
                                        double backR, double backG, double backB,
                                        double borderR, double borderG, double borderB,
                                        double shineR, double shineG, double shineB) {
            ctx.set_source_rgb (backR, backG, backB);
            ctx.arc (x1, y0 + radius, radius, -1.57, 1.57);
            ctx.fill ();
            ctx.set_source_rgb (borderR, borderG, borderB);
            ctx.arc (x1, y0 + radius, radius, -1.57, 1.57);
            ctx.stroke ();
            ctx.set_source_rgb (shineR, shineG, shineB); // Shining
            ctx.arc (x1, y0 + radius, radius-2, 4.71, 5.49);
            ctx.stroke ();
            // Mirror
            var pattern = new Cairo.Pattern.linear (x0, y1, x0, y2);
            pattern.add_color_stop_rgba (0, backR, backG, backB, 0.9);
            pattern.add_color_stop_rgba (1, backR, backG, backB, 0);
            ctx.set_source (pattern);
            ctx.arc (x1, y1 + radius + 1, radius, -1.57, 1.57);
            ctx.fill ();
            ctx.arc (x1, y1 + radius + 1, radius, -1.57, 1.57);
            ctx.stroke ();
            ctx.set_source_rgb (shineR, shineG, shineB); // Shining
            ctx.arc (x1 + 1, y1 + radius + 1, radius, -1.57, 1.57);
            ctx.stroke ();
        }

        public void drawBarBody (Cairo.Context ctx, int radius,
                                    int x0, int x1, int y0, int y1, int y2,
                                    double backR, double backG, double backB,
                                    double borderR, double borderG, double borderB,
                                    double shineR, double shineG, double shineB, bool cut) {
            ctx.set_source_rgb (backR, backG, backB);
            ctx.move_to (x0, y0);
            ctx.line_to (x1, y0);
            ctx.line_to (x1, y1);
            ctx.line_to (x0, y1);
            ctx.line_to (x0, y0);
            ctx.fill ();
            ctx.set_source_rgb (borderR, borderG, borderB);
            ctx.move_to (x0, y0);
            ctx.line_to (x1, y0);
            ctx.move_to (x1, y1);
            ctx.line_to (x0, y1);
            ctx.stroke ();
            ctx.set_source_rgb (shineR, shineG, shineB); // Shining
            ctx.move_to (x0, y0+2);
            ctx.line_to (x1, y0+2);
            ctx.stroke ();
            if (cut) {
                ctx.move_to (x1-1, y0+2);
                ctx.line_to (x1-1, y1);
                ctx.stroke ();
            }
            // Mirror
            var pattern = new Cairo.Pattern.linear (x0, y1, x0, y2);
            pattern.add_color_stop_rgba (0, backR, backG, backB, 0.9);
            pattern.add_color_stop_rgba (1, backR, backG, backB, 0);
            ctx.set_source (pattern);
            ctx.move_to (x0, y1+1);
            ctx.line_to (x1, y1+1);
            ctx.line_to (x1, y2);
            ctx.line_to (x0, y2);
            ctx.line_to (x0, y1+1);
            ctx.fill ();
        }

        private void show_light_window () {
            var light_window = new Granite.Widgets.LightWindow (_("Format Drive"));
            light_window.width_request = 350;

            var notebook = new Granite.Widgets.StaticNotebook ();
            notebook.append_page (new Gtk.Label (_("TODO: One click formatting")), new Gtk.Label (_("Basic")));
            notebook.append_page (new Gtk.Label (_("TODO: Allow basic partitioning")), new Gtk.Label (_("Partitioning")));
            notebook.append_page (new Gtk.Label (_("TODO: dd images to drive")), new Gtk.Label (_("Restore")));

            light_window.add (notebook);
            light_window.show_all ();
/*
        var light_window_notebook = new Granite.Widgets.StaticNotebook ();
        var entry = new Gtk.Entry ();
        var open_drop = new Gtk.ComboBoxText ();
        var open_lbl = new LLabel ("Alwas Open Mpeg Video Files with Audience");

        var grid = new Gtk.Grid ();
        grid.attach (new Gtk.Image.from_icon_name ("video-x-generic", Gtk.IconSize.DIALOG), 0, 0, 1, 2);
        grid.attach (entry, 1, 0, 1, 1);
        grid.attach (new LLabel ("1.13 GB, Mpeg Video File"), 1, 1, 1, 1);

        grid.attach (light_window_notebook, 0, 2, 2, 1);

        var general = new Gtk.Grid ();
        general.attach (new LLabel.markup ("<b>Info:</b>"), 0, 0, 2, 1);

        general.attach (new LLabel.right ("Created:"), 0, 1, 1, 1);
        general.attach (new LLabel.right ("Modified:"), 0, 2, 1, 1);
        general.attach (new LLabel.right ("Opened:"), 0, 3, 1, 1);
        general.attach (new LLabel.right ("Mimetype:"), 0, 4, 1, 1);
        general.attach (new LLabel.right ("Location:"), 0, 5, 1, 1);

        general.attach (new LLabel ("Today at 9:50 PM"), 1, 1, 1, 1);
        general.attach (new LLabel ("Today at 9:50 PM"), 1, 2, 1, 1);
        general.attach (new LLabel ("Today at 10:00 PM"), 1, 3, 1, 1);
        general.attach (new LLabel ("video/mpeg"), 1, 4, 1, 1);
        general.attach (new LLabel ("/home/daniel/Downloads"), 1, 5, 1, 1);

        general.attach (new LLabel.markup ("<b>Open with:</b>"), 0, 6, 2, 1);
        general.attach (open_drop, 0, 7, 2, 1);
        general.attach (open_lbl, 0, 8, 2, 1);

        light_window_notebook.append_page (general, new Gtk.Label ("General"));
        light_window_notebook.append_page (new Gtk.Label ("More"), new Gtk.Label ("More"));
        light_window_notebook.append_page (new Gtk.Label ("Sharing"), new Gtk.Label ("Sharing"));

        open_lbl.margin_left = 24;
        open_drop.margin_left = 12;
        open_drop.append ("audience", "Audience");
        open_drop.active = 0;
        grid.margin = 12;
        grid.margin_top = 24;
        grid.margin_bottom = 24;
        entry.text = "Cool Hand Luke";
        general.column_spacing = 6;
        general.row_spacing = 6;
*/
        }
    }
}

int main (string[] args)
{
    Gtk.init (ref args);

    var plug = new Drives.DrivesPlug ();
    plug.register ("Drives");
    plug.show_all();

    Gtk.main ();
    return 0;
}
