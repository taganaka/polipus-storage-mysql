# coding: utf-8
require 'polipus/storage/base'
module Polipus
  module Storage
    def self.mysql_store(mysql_options = {}, table_name = 'pages')
      require 'polipus/storage/mysql_store'
      self::MysqlStore.new(mysql_options.merge(table_name: table_name))
    end
  end
end
