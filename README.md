## Clone元レポジトリ

本レポジトリは、[株式会社YOUTRUST](https://youtrust.co.jp/)が提供する[キャリアSNS「YOUTRUST」](https://youtrust.jp/)で利用しているRailsのサンプルコードです。

## 起動方法

```
# Railsサーバー起動
$ docker compose up

# DBスキーマファイルの適用
$ docker compose exec app bundle exec rails db:create
$ docker compose exec app bundle exec rails db:schema:apply
$ docker compose exec -e RAILS_ENV=test app bundle exec rails db:schema:apply

# テスト実行
$ docker compose exec app bundle exec rspec
```

## ディレクトリ構成

### Controller([app/controllers/](https://github.com/team-youtrust/sample-webapp/tree/main/app/controllers))
- HTTPの世界とアプリケーションの世界の境界に立つ層。
- 基本的にUseCase or Queryを呼び出すだけの薄い層。
- 各種IDの暗号化/復号はこの層で行う。

### UseCase([app/use\_cases/](https://github.com/team-youtrust/sample-webapp/tree/main/app/use_cases))
- 特定の更新系のユースケースを、各種クラスを組み合わせて呼び出すことによって実現させる層。
    - Controller等から呼ばれる。
    - 他のUseCaseを呼び出すことはしない。
- 主な処理内容
    - 更新系ロジック(Command)の呼び出し
    - 通知ジョブ(NotificationJob)のエンキュー
        - 通知ロジックはすべてNotificationに移譲
    - DBトランザクション管理（排他制御）
    - 各種ログ
    - 認可周りのバリデーション

### Command([app/commands/](https://github.com/team-youtrust/sample-webapp/tree/main/app/commands))
- 更新系ロジック。
    - Model内に様々な操作のロジックやバリデーションを記載するのではなく、操作の種類毎にCommandとして切り出す。
        - 例. FriendRequest Model内にsend\_friend\_requestやaccept\_friend\_requestのメソッドやバリデーションを書くのではなく、SendFriendRequestCommandやAcceptFriendRequestCommandを用意する。
    - 他のCommandを呼び出すことはしない。
- 主な処理内容
    - Modelを呼び出して実際のCreate/Update/Destroyなどの操作を行う。
    - 整合性周りのバリデーションを行う。

### Query([app/queries/](https://github.com/team-youtrust/sample-webapp/tree/main/app/queries))
- 参照系のドメインロジックの置き場。
- 母集団取得、フィルター、ソートの責務を負う。

### NotificationJob([app/jobs/notification\_job.rb](https://github.com/team-youtrust/sample-webapp/blob/main/app/jobs/notification_job.rb))
- 通知ロジックを非同期実行するためのインターフェース
- UseCaseから呼ばれ、指定の制御クラスを呼び出すだけ。

### Notification([app/models/notification/](https://github.com/team-youtrust/sample-webapp/tree/main/app/models/notification))
- 通知ロジックの置き場。
- 制御クラス
    - NotificationJobから直接呼び出されるクラス。
    - 配信対象の絞り込みや通知送信判定を行い、詳細クラスを呼び出す。
    - `app/models/notification/` 直下や `app/models/notification/friend_request/` などの名前空間を切ったディレクトリ直下。
- 詳細クラス
    - メール通知、Push通知、サービス内通知、Slack通知など通知処理の詳細を担うクラス。
    - ここでは配信対象の絞り込みや通知送信判定等は行わない。単に通知を送信するだけ。

## 一覧取得系APIについて
一覧系取得APIのロジックについて、YOUTRUSTではスケーラブルで一貫性のあるリスティングロジックを実現するために、「最初にフィルター＆ソート済みのIDsをすべて返して、あとは各ページごとにIDs指定でリソースを取得する」という方式を採用しています。[参考](https://tech.youtrust.co.jp/entry/thinking-about-scaleable-listing-logic)

そのため取得系APIを下記の2種類に分けて実装しています。

- 「フィルター＆ソート処理されたリソースのIDsを返すAPI」
- 「指定IDsのリソースを返すAPI」

## 参考

### 技術ブログ
* [Rails on YOUTRUST ＜ロジックどこ置く？編＞](https://tech.youtrust.co.jp/entry/rails-on-youtrust-class-division)
* [サービス成長に耐えうるリスト取得ロジックについて考える](https://tech.youtrust.co.jp/entry/thinking-about-scaleable-listing-logic)

## 注意事項
* :warning: 本レポジトリはサンプルコードです。Production環境で求められるセキュリティ要件を満たしておらず、認証周りの記述に脆弱性があります。
* :warning: Railsにおけるクラス分割の学習・参考用途に限ってご利用ください。
