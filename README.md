# Polipus::Storage::Mysql

MySQL Storage driver for [Polipus::Crawler](https://github.com/taganaka/polipus)

## Installation

Add this line to your application's Gemfile:

    gem 'polipus-storage-mysql'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polipus-storage-mysql

## Usage

```ruby
require 'polipus'
require 'polipus/storage/mysql_store'
mysql_storage = Polipus::Storage::mysql_store(mysql_options, table_name)
Polipus.crawler('rubygems','http://rubygems.org/', storage: mysql_store) do |crawler|
  # In-place page processing
  crawler.on_page_downloaded do |page|
    # A nokogiri object
    puts "Page title: '#{page.doc.css('title').text}' Page url: #{page.url}"
  end
end
```

## MySQL options

MySQL options are passed directly to the mysql2 driver: (https://github.com/brianmario/mysql2)

## Contributing

1. Fork it ( http://github.com/taganaka/polipus-storage-mysql/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
