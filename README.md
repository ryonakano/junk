# Daizu

IP address informing tool for some Japanese common DDNS services

## Description

`Daizu` informs IP address of your server to DDNS services which are used to build home Web servers and mail servers.

## Features

 * Works with 2 Japanese common DDNS services: [MyDNS.JP](https://www.mydns.jp/) & [ieServer](http://www.ieserver.net/)
 * Works without root privilege
 * Works confirmed with Ubuntu 18.04 LTS, CentOS 7, Debian 9

## Usage

### Before installation

The following elements may not be installed in CentOS 7 by defaults.

 * Git
 * Wget

### Installation & Run

Just clone and execute.

```sh:
$ git clone https://github.com/ryonakano/daizu.git
$ cd daizu
$ chmod 700 ./daizu # If not executable
$ ./daizu.sh
```

If you would like to inform IP address regularly, use `crontab`:

```sh:
$ crontab -e
```

Add at the last line, for example:

```sh:
10,40 1-23/3 * * * <Directory of cloned Daizu>/<Service Name>_<Account Name>_update.sh
```

**Avoid too much executing. This causes too much burden for the DDNS servers and too much quantity of Daizu's log.**

### Check the log

The log of Daizu is saved at `<Directory of cloned Daizu>/log/daizu.log`.

```
=================================
Wed Mar 21 09:50:01 JST 2018 Started Daizu Daemon.
Wed Mar 21 09:50:09 JST 2018 Succeeded: Informing to mydnsXXXXXX (MyDNS.JP)
=================================
Wed Mar 21 09:55:01 JST 2018 Started Daizu Daemon.
Wed Mar 21 09:55:09 JST 2018 Failed: Informing to XXXXXX.dip.jp (ieServer)
```

In each block in `===`, `Succeeded` means that the informing was finished correctly. `Failed` means that there were some problems and could't inform; check whether you set your userID, account name, domain name, password, or your network settings correctly.

### Cease the informing to a DDNS service

First specificate the service and account name. Then delete correspond file:

```sh:
$ rm <Directory of cloned Daizu>/<Service Name>_<Account Name>_update.sh
```

Next execute `crontab` and delete the line that you added to inform regularly:

```sh:
$ crontab -e
```

### Uninstall

First delete the folder where Daizu was contained:

```sh:
$ rm -r <Directory of cloned Daizu>
```

Next execute `crontab` and delete the line that you added to inform regularly:

```sh:
$ crontab -e
```

## Development

Pull Requests、Issues are welcome.  

### License

[MIT](LICENSE.txt)

### Author

[@ryonakano](https://github.com/ryonakano)

### Principal Referer

https://qiita.com/mizuki_takahashi/items/89699f87fb10d812748a  
http://ieserver.net/ddns-update.txt
