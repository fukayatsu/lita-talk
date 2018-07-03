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
  config.handlers.talk.docomo_api_key = 'xxx'
end
```

## Usage

```
Lita > lita type
default
Lita > lita おはよう
おはありりー
Lita > lita type hakata
ok
Lita > lita おはよう
おはようだの
```
