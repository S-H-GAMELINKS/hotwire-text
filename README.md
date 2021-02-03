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

最後に、`app/views/channels/show.html.erb`に以下のコードを追加します。

```diff
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @channel.title %>
</p>

<p>
  <strong>About:</strong>
  <%= @channel.about %>
</p>

<%= link_to 'Edit', edit_channel_path(@channel) %> |
<%= link_to 'Back', channels_path %>
+ 
+ <div id="messages">
+   <%= render @channel.messages %>
+ </div>
+ 
+ <%= link_to "New Message", new_channel_message_path(@channel) %>
+ 
```

これで新しくメッセージを追加することができるようになります。

### TurboでSPA化(PART1)

ここからは`Turbo`を使ってSPA化を進めていきます。
まずは先ほど新しくメッセージを送るフォームへのリンクを`Turbo`を使って埋め込みます。

`app/views/channels/show.html.erb`を以下のように編集します。

```diff
  
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @channel.title %>
</p>

<p>
  <strong>About:</strong>
  <%= @channel.about %>
</p>

<%= link_to 'Edit', edit_channel_path(@channel) %> |
<%= link_to 'Back', channels_path %>

<div id="messages">
  <%= render @channel.messages %>
</div>

- <%= link_to "New Message", new_channel_message_path(@channel) %>
+ <%= turbo_frame_tag "new_message", src: new_channel_message_path(@channel), target: "_top" %>

```

`Turbo`では埋め込まれる箇所も`turbo_frame_tag`で括ることでその部分を埋め込むことができます。
これを利用して、`app/views/messages/new.html.erb`のフォームを以下のように変更します。


```diff
<h1>New Message</h1>

- <%= form_with(model: [ @message.channel, @message ]) do |form| %>
-     <div class="field">
-         <%= form.text_field :content %>
-         <%= form.submit "Send" %>
-     </div>
- <% end $>
+ <%= turbo_frame_tag "new_message", target: "_top" do %>
+     <%= form_with(model: [ @message.channel, @message ]) do |form| %>
+         <div class="field">
+             <%= form.text_field :content %>
+             <%= form.submit "Send" %>
+         </div>
+     <% end %>
+ <% end %>

<%= link_to 'Back', @message.channel %>
```

これでフォームを埋め込むことができています。

最後に、`Turbo`を使ってリアルタイムにメッセージがやり取りできるようにします。

`app/controllers/messages_controller.rb`の`create`メソッドを以下のように編集します。

```diff
    def create
      @message = @channel.messages.create!(message_params)

-      redirect_to @channel
+      respond_to do |format|
+        format.turbo_stream
+        format.html { redirect_to @channel }
+      end
    end
```

### Bootstrapを導入

ここで一旦Bootstrapを導入します。

`Gemfile`に以下のコードを追加して、`bundle install`を実行します。

```ruby
# Using Bootstrap4
gem 'bootstrap'
```

```bash
bundle install
```

次に、`app/assets/stylesheets/application.css`を`app/assets/stylesheets/application.scss`にリネームして、以下のコードを追加します。

```scss
@import "bootstrap";
```

これでBootstrapが導入されました。

### TurboでSPA化(PART2)

お次はチャンネル周りもSPA化していきます。

まずは`app/views/channels/new.html.erb`に`turbo_frame_tag`を追加します。

```diff
<h1>New Channel</h1>

- <%= render 'form', channel: @channel %>
+ <%= turbo_frame_tag "channel" do %>
+     <%= render 'form', channel: @channel %>
+ <% end %>

<%= link_to 'Back', channels_path %>

```

その後、`app/views/channels/_channel.html.erb`を以下のように作成します。

```erb
<span id="<%= dom_id channel %>">
    <%= link_to channel.title, channel, "data-turbo-frame": "channel" %>
</span>
```

先ほど作成した`app/views/channels/_channel.html.erb`を使うように`app/views/channels/index.html.erb`を以下のようにします。


```erb
<p id="notice"><%= notice %></p>

<h1>Channels</h1>

<%= turbo_stream_from :channels %>

<%= turbo_frame_tag "channels" do %>
  <%= render @channels %>
<% end %>

<%= turbo_frame_tag "channel" do %>
<% end %>

<%= link_to 'New Channel', new_channel_path, "data-turbo-frame": "channel" %>

```

あとは`pp/models/channel.rb`と`app/controllers/channels_controller.rb`の`create`メソッドを以下のように変更します。

```ruby
class Channel < ApplicationRecord
    has_many :messages
    broadcasts_to ->(channel) { 
        :channels 
    }
end
```

```ruby
  def create
    @channel = Channel.new(channel_params)

    respond_to do |format|
      if @channel.save
        format.html { redirect_to channels_url, notice: "Channel was successfully created." }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end
```

最後に`app/views/channels/show.html.erb`を以下のようにします。

```erb
<%= turbo_frame_tag "channel" do %>
<p id="notice"><%= notice %></p>

<%= turbo_stream_from @channel %>

<p>
  <strong>Title:</strong>
  <%= @channel.title %>
</p>

<p>
  <strong>About:</strong>
  <%= @channel.about %>
</p>

<%= link_to 'Edit', edit_channel_path(@channel) %> |
<%= link_to 'Back', channels_path %>

<div id="messages">
  <%= render @channel.messages %>
</div>

<%= turbo_frame_tag "new_message", src: new_channel_message_path(@channel), target: "_top" %>
<% end %>

```

これで一通りの昨日は完成です！

### レイアウトの調整

最後にヘッダーとレイアウト調整を行います。

ヘッダーは`app/views/layouts/_header.html.erb`というファイル名で以下のように作成します。


```erb
<nav class="navbar navbar-dark bg-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Hotwire Text</a>
  </div>
</nav>
```

これを`app/views/layouts/application.html.erb`内の`body`タグ内で呼び出します。

```erb
<%= render 'layouts/header' %>
```

あとは`app/views/channels/index.html.erb`と`app/views/channels/_channel.html.erb`を以下のようにします

```erb
<p id="notice"><%= notice %></p>

<h1>Channels</h1>

<%= turbo_stream_from :channels %>

<div class="row">
  <div class="col-2">
    <%= link_to 'New Channel', new_channel_path, "data-turbo-frame": "channel" %>
    <%= turbo_frame_tag "channels" do %>
      <%= render @channels %>
    <% end %>
  </div>

  <div class="col-10">
    <%= turbo_frame_tag "channel" do %>
    <% end %>
  </div>
</div>
```

```erb
<h4 id="<%= dom_id channel %>">
    <%= link_to "##{channel.title}", channel, "data-turbo-frame": "channel" %>
</h4>
```