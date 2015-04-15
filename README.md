# lita-talk

Talk with you if given message didn't match any other handlers.

Inspired by [r7kamura/ruboty-talk](https://github.com/r7kamura/ruboty-talk).

## Installation

Add lita-talk to your Lita instance's Gemfile:

``` ruby
gem "lita-talk"
```

## Configuration

```ruby
# lita_config.rb
Lita.configure do |config|
  ...
  # required
  Lita.config.handlers.talk.docomo_api_key      = 'xxx'

  # optional (https://dev.smt.docomo.ne.jp/?p=docs.api.page&api_name=dialogue&p_name=api_1#tag01)
  #  20 : 関西弁キャラ
  #  30 : 赤ちゃんキャラ
  #  指定なし : デフォルトキャラ
  Lita.config.handlers.talk.docomo_character_id = 20
end
```

## Usage

![ss 2015-04-15 at 16 24 51](https://cloud.githubusercontent.com/assets/1041857/7153973/25f15966-e38c-11e4-9c26-3aef61e4e7fa.png)
