require "polipus/storage"
require "polipus/page"
require "polipus/storage/mysql_store/version"
require "mysql2"
module Polipus
  module Storage
    class MysqlStore < Base

      def initialize(options = {})
        @tbl = options.delete :table_name
        @my  = Mysql2::Client.new(options)
        setup
      end

      def add page
        @my.query(page_to_sql(page))
        uuid(page)
      end

      def exists?(page)
        @my.query("SELECT
          EXISTS (SELECT 1 FROM #{@tbl} 
            WHERE uuid = '#{@my.escape(uuid(page))}') AS CNT")
        .first['CNT'] == 1 ? true : false
      end

      def get page
        nil
      end

      def remove page
        @my.query("DELETE FROM #{@tbl} WHERE uuid = '#{@my.escape(uuid(page))}'")
      end

      def count
        @my.query("SELECT COUNT(*) AS CNT FROM #{@tbl}").first['CNT']
      end

      def each
        yield nil
      end

      def clear
      end
      private
        def setup
          # 'url'           => @url.to_s,
          #        'headers'       => Marshal.dump(@headers),
          #        'body'          => @body,
          #        'links'         => links.map(&:to_s), 
          #        'code'          => @code,
          #        'depth'         => @depth,
          #        'referer'       => @referer.to_s,
          #        'redirect_to'   => @redirect_to.to_s,
          #        'response_time' => @response_time,
          #        'fetched'       => @fetched,
          #        'user_data'     => @user_data.nil? ? {} : @user_data.marshal_dump,
          #        'fetched_at'    => @fetched_at,
          #        'error'         => @error
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

        def page_to_sql (page)
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
    end
  end
end
