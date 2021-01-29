# Hotwire Text
## 概要

`Hotwire`を使い、Slack風のチャットアプリを作るチュートリアルになります。

## 手順
### アプリのひな型を作る

まずは、アプリの雛形を`rails new`コマンドで作成します。

```bash
rails new hotwire-text --skip-javascript
```

`Hotwire`では`Webpacker`を使わないので`--skip-javascript`をオプションとして追加しています。

### Hotwireをインストール

次に、`Hotwire`を先ほど作成したアプリにインストールします。

まずは、`Gemfile`に以下のコードを追加します。

```ruby
# Add Hotwire gem
gem 'hotwire-rails'
```

`Gemfile`に追加後、`bundle install`を実行します。

```bash
bundle install
```

`bundle install`後、`rails hotwire:install`を実行します。

```bash
rails hotwire:install
```

これで`Hotwire`がインストールされます。

### チャンネルを作成

次に`scaffold`コマンドを使ってチャンネルを作成していきます。

```bash
rails g scaffold Channel title about:text
```

`scaffold`コマンドを実行後、`db:migrate`でマイグレーションを実行します。

```bash
rails db:migrate
```

これでチャンネルが作成できました。


### メッセージを作成

次に、`rails g model`コマンドでメッセージを作成します。

```bash
rails g model Message channel:references content:text
```

コマンド実行後、`db:migrate`を実行します。

```bash
rails db:migrate
```

### TurboでSPA化

### Bootstrapを導入

### レイアウトの調整