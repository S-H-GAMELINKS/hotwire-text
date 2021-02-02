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

次に、メッセージ用のルーティングを追加します。

```diff
Rails.application.routes.draw do
-  resources :channels
+  resources :channels do
+    resources :messages
+  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

```

また`Channel`モデルに`Message`モデルとのリレーションを追加します。

```diff
class Channel < ApplicationRecord
+    has_many :messages
end

```

次に、メッセージ用のテンプレートとして`app/views/messages/_message.html.erb`を追加します。

```erb
<p id="<%= dom_id message %>">
  <%= message.created_at.to_s(:short) %>: <%= message.content %>
</p>

```

`app/views/messages/new.html.erb`というファイル名で、新しくメッセージを追加するためのフォームのテンプレートも作成します。


```erb
<h1>New Message</h1>

<%= form_with(model: [ @message.channel, @message ]) do |form| %>
    <div class="field">
        <%= form.text_field :content %>
        <%= form.submit "Send" %>
    </div>
<% end %>

<%= link_to 'Back', @message.channel %>

```

ここまでの段階でメッセージ用のビューは作成できています。
次に、`app/controllers/messages_controller.rb`を以下のように作成します。


```ruby
class MessagesController < ApplicationController
    before_action :set_channel, only: [:new, :create]

    def new
      @message = @channel.messages.new
    end

    def create
      @message = @channel.messages.create!(message_params)

      redirect_to @channel
    end

    private
      def set_channel
        @channel = Channel.find(params[:channel_id])
      end

      def message_params
        params.require(:message).permit(:content)
      end
end

```

### TurboでSPA化

### Bootstrapを導入

### レイアウトの調整