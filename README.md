# docker コンテナ内で nginx の roglotate を行う

## 起動方法

- `sh kicker.sh [logをマウントする絶対パス]`

## logrotate が動作しているか確認する

- `rsyslog`を有効にする
- `50-default.conf`の設定で、nginx の logrotate が起動した時にログを出力するようにする

## nginx コンテナ内で roglotate を実行させる時のポイント

### nginx の logrotate 以外の cron ジョブを削除する

- nginx の logrotate が動くより前に cron で起動したジョブが止まっていた場合は nginx logrotate ジョブは動かない

```
RUN rm /etc/cron.daily/passwd
RUN rm /etc/cron.daily/dpkg
RUN rm /etc/cron.daily/apt-compat
RUN rm /etc/cron.daily/exim4-base
```

### コンテナ内で logrotate を起動する場合は crontab への touch が必要

- [Cron and Crontab files not executed in Docker](https://stackoverflow.com/questions/34962020/cron-and-crontab-files-not-executed-in-docker)

  ```
  Cron は (少なくとも Debian では) 1 つ以上のハードリンクを持つ crontab を実行しません (bug 647193 参照)。
  Dockerはオーバーレイを使用しているため、ファイルへのリンクが複数になってしまいます。
  そのため、スタートアップスクリプトでタッチして、リンクを切断する必要があります。
  ```

  - `touch /etc/crontab /etc/cron.*/*`

### 初回起動できるように古い日時の status を仕込む

cron を起動した直後に作成された status では起動した日で登録されるため、daily で logrotate が設定されている場合翌日から rotate されるようになってしまう。
コンテナが再起動されることも想定すると、起動した日から logrotate を動作させるようにする必要があると考える。
よって、古い日付で作成された status をコンテナの中に格納する

- `COPY ./conf/logrotate/status /var/lib/logrotate`
