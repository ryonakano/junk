/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : GLib.Application {
    private Xdp.Portal? portal = null;

    public Application () {
        Object (
            flags: ApplicationFlags.FLAGS_NONE,
            application_id: "com.github.ryonakano.portal-location-demo"
        );
    }

    protected override void activate () {
        if (portal == null) {
            portal = new Xdp.Portal ();
            portal.location_updated.connect ((lat, lng, alt, acc, sp, hd, desc, sec, msec) => {
                stdout.printf ("%lf, %lf\n", lat, lng);
                portal.location_monitor_stop ();
            });
        }

        portal.location_monitor_start.begin (null, 0, 0, Xdp.LocationAccuracy.EXACT, Xdp.LocationMonitorFlags.NONE,
                                             null, (obj, res) => {
            try {
                portal.location_monitor_start.end (res);
            } catch (Error e) {
                warning (e.message);
            }
        });

        hold ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
