#!/bin/bash
valac --pkg gtk+-3.0 ./v1.vala
valac --pkg gtk+-3.0 ./App.vala
valac --pkg gtk+-3.0 --pkg granite --pkg gee-0.8 ./PantheonTweaks.vala
