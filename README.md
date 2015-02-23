# MotosaleUa [![Build Status](https://travis-ci.org/kongo/motosale_ua.svg?branch=master)](https://travis-ci.org/kongo/motosale_ua)

Access [motosale.ua](http://motosale.ua) motorcycle ads website from Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'motosale_ua'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motosale_ua

## Usage

All the stuff is performed by `MotosaleUa::Scraper` class.

### Getting a collection of ads

      MotosaleUa::Scraper.new.fetch_list(page_num, vehicle_type_index)

`page_num` - put `nil` to fetch the entire list, or number > 1 for a specific page. One page contains 10 ads.

`vehicle_type_index` - select one from the following list

    :classic, :neoclassic, :chopper, :sport, :sporttourist, :tourist, :enduro, :cross, :pitbike, :supermoto, :trial, :scooter, :maxiscooter, :custom, :trike, :quadracycle, :watercraft, :snowmobile, :all

Default is `:all`.

### Getting details of a specific item

      fetch_item_details(link)

### Getting all photos of a specific item

      fetch_item_photos_urls(uin)


## Contributing

1. Fork it ( https://github.com/[my-github-username]/motosale_ua/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
