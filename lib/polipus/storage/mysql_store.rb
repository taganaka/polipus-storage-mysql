# coding: utf-8
require 'polipus/storage'
require 'polipus/page'
require 'mysql2'
require 'thread'

module Polipus
  module Storage
    def self.mysql_store(mysql_options = {}, table_name = 'pages')
      self::MysqlStore.new(mysql_options.merge(table_name: table_name))
    end

    class MysqlStore < Base
      def initialize(options = {})
        @tbl = options.delete :table_name
        @my  = Mysql2::Client.new(options)
        @mutex = Mutex.new
        setup
      end

      def add(page)
        @mutex.synchronize do
          @my.query(page_to_sql(page))
          uuid(page)
        end
      end

      def exists?(page)
        @mutex.synchronize do
          @my.query("SELECT
            EXISTS (SELECT 1 FROM #{@tbl}
              WHERE uuid = '#{@my.escape(uuid(page))}') AS CNT")
          .first['CNT'] == 1
        end
      end

      def get(page)
        @mutex.synchronize do
          load_page(
           @my.query("SELECT * FROM #{@tbl} WHERE uuid = '#{@my.escape(uuid(page))}' LIMIT 1", cast_booleans: true)
          .first
          )
        end
      end

      def remove(page)
        @mutex.synchronize do
          @my.query("DELETE FROM #{@tbl} WHERE uuid = '#{@my.escape(uuid(page))}'")
        end
      end

      def count
        @mutex.synchronize do
          @my.query("SELECT COUNT(*) AS CNT FROM #{@tbl}").first['CNT'].to_i
        end
      end

      def each
        @my.query("SELECT * FROM #{@tbl}").each do |row|
          yield row['uuid'], load_page(row)
        end
      end

      def clear
        @mutex.synchronize do
          @my.query("DELETE FROM #{@tbl}")
        end
      end

      private

      def setup
        create_table = %Q(
          CREATE TABLE IF NOT EXISTS #{@tbl} (
            uuid          varchar(32) PRIMARY KEY,
            url           varchar(255),
            headers       blob,
            body          blob,
            links         blob,
            code          int,
            depth         int,
            referer       varchar(255),
            redirect_to   varchar(255),
            response_time int,
            fetched       boolean,
            user_data     blob,
            fetched_at    int,
            error         varchar(255)
          )
        )
        @my.query(create_table)
      end

      def page_to_sql(page)
        %Q(
          INSERT INTO #{@tbl}
            VALUES (
              '#{uuid(page)}',
              '#{@my.escape(page.url.to_s)}',
              '#{@my.escape(Marshal.dump(page.headers))}',
              '#{@my.escape(page.body)}',
              '#{@my.escape(Marshal.dump(page.links))}',
              #{page.code.to_i},
              #{page.depth.to_i},
              '#{@my.escape(page.referer.to_s)}',
              '#{@my.escape(page.redirect_to.to_s)}',
              #{page.response_time.to_i},
              #{page.fetched?},
              '#{@my.escape(Marshal.dump(page.user_data))}',
              #{page.fetched_at.to_i},
              '#{@my.escape(page.error.to_s)}'
            )
            ON DUPLICATE KEY UPDATE
              fetched_at = UNIX_TIMESTAMP()
        )
      end

      def load_page(hash)
        %w(links user_data).each do |f|
          hash[f] = Marshal.load(hash[f]) unless hash[f].nil?
        end
        Page.from_hash(hash)
      end
    end
  end
end
