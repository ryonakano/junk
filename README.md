# Daizu

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.txt)

Daizu is a tool that lets you inform IP address of your server to ieServer/MyDNS.JP.

## Features

* Works with 2 Japanese common DDNS services: [ieServer](http://www.ieserver.net/) & [MyDNS.JP](https://www.mydns.jp/)
* Works without root privilege
* Works confirmed with Ubuntu 18.04 LTS, CentOS 7, Debian 9

## Installation

Just clone this repository to where you like:

    git clone https://github.com/ryonakano/daizu.git
    cd daizu
    chmod 700 ./daizu.sh # If not executable

## Usage

Execute the script and follow the instruction:

    ./daizu.sh

If you would like to inform IP address regularly, use `crontab`:

    crontab -e

Add at the last line, for example:

    10,40 1-23/3 * * * <Directory of cloned Daizu>/<Service Name>_<Account Name>_update.sh

**Avoid too much executing. This causes too much burden for the DDNS servers and too much quantity of Daizu's log.**

### Checking the log

The log of Daizu is saved at `<Directory of cloned Daizu>/log/daizu.log`.

    =================================
    Wed Mar 21 09:50:01 JST 2018 Daizu was started with cron.
    Wed Mar 21 09:50:09 JST 2018 Succeeded: Informing to mydnsXXXXXX (MyDNS.JP)
    =================================
    Wed Mar 21 09:55:01 JST 2018 Daizu was started with cron.
    Wed Mar 21 09:55:09 JST 2018 Failed: Informing to XXXXXX.dip.jp (ieServer)

In each block in `===`, `Succeeded` means that the informing was finished correctly. `Failed` means that there were some problems and could't inform; check whether you set your userID, account name, domain name, password, or your network settings correctly.

### Ceasing the informing to a DDNS service

First specificate the service and account name. Then delete correspond file:

    rm <Directory of cloned Daizu>/<Service Name>_<Account Name>_update.sh

Next execute `crontab` and delete the line that you added to inform regularly:

    crontab -e

### Uninstallation

First delete the folder where Daizu was contained:

    rm -r <Directory of cloned Daizu>

Next execute `crontab` and delete the line that you added to inform regularly:

    crontab -e

## Contributing

Pull Requests, Issues are welcome.

## References

https://qiita.com/mizuki_takahashi/items/89699f87fb10d812748a  
http://ieserver.net/ddns-update.txt
