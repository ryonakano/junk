#!/usr/bin/env bash
#
# ip_update.sh
# This is a script file executed in cron.
# Copyright (c) 2018 Ryo Nakano
# Released under MIT License, see LICENSE.txt
#
#
#
cd `dirname $0`
mkdir -p ./log
touch ./log/daizu.log
echo -e "=================================" >> ./log/daizu.log && date | tr '\n' ' ' >> ./log/daizu.log && echo -e "Started Daizu Daemon." >> ./log/daizu.log
