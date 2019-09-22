# Daizu

ieServer と MyDNS.JP のための、IP アドレス定期通知スクリプト作成ツール

## 概要

GitHub を使い始めたころに、[DiCE の Linux 版](http://www.hi-ho.ne.jp/yoshihiro_e/dice/linux.html)に触発されて作ったのですが、[ieServer](http://www.ieserver.net/) と [MyDNS.JP](https://www.mydns.jp/) にしか対応していないなど、比較できないほど使い物になりません。  
Git のログだと、最初の日付は2018年6月22日になっていますが、その前からあった気がします。

## 使い方（一応）

* リポジトリをクローンして、`daizu.sh` に実行権限を与えて実行するだけです。
* このツールは定期通知のためのスクリプトを作成するだけで、定期通知まではしてくれないので、`crontab` を使って自動的にスクリプトを実行するように設定してください。
* 実行結果のログは `log/daizu.log` 以下に保存されます。

## 参考

https://qiita.com/mizuki_takahashi/items/89699f87fb10d812748a  
http://ieserver.net/ddns-update.txt
