# coding: utf-8
require 'spec_helper'
require 'polipus/storage/mysql_store'

describe Polipus::Storage::MysqlStore do
  let(:test_db_name) { 'polipus_mysql_store_spec' }
  let(:options) do
    {
      host: 'localhost',
      username: 'root',
      password: '',
      database: test_db_name,
      table_name: 'rspec_pages'
    }
  end

  let(:my)do
    o = options.dup
    o.delete :database
    Mysql2::Client.new o
  end
  let(:db) { Mysql2::Client.new options }

  let(:page)do
    Polipus::Page.new 'http://www.google.com/',
                      body: '<html>
                        <body>
                          <a href="/a/1">1</a>
                          <a href="/a/2">2</a>
                        </body>
                      </html>',
                      code: 201,
                      depth: 1,
                      referer: 'http://www.google.com/1',
                      response_time: 1,
                      fetched: true,
                      fetched_at: Time.now,
                      error: 'an error',
                      headers: { 'content-type' => ['text/html'] }
  end

  let(:storage) { Polipus::Storage.mysql_store(options, options[:table_name]) }

  before(:each) do
    my.query("CREATE DATABASE IF NOT EXISTS #{test_db_name}")
  end

  after(:each) do
    my.query("DROP DATABASE #{test_db_name}")
  end

  context 'CREATE' do
    it 'should store a page' do
      page.user_data.a = 1
      storage.add(page).should eq Digest::MD5.hexdigest(page.url.to_s)
      storage.count.should be 1
      storage.exists?(page).should be true
    end
  end

  context 'DELETE' do
    let(:filled_storage) do
      storage.add page
      storage
    end

    it 'should delete a page' do
      filled_storage.remove page
      filled_storage.exists?(page).should be false
      filled_storage.count.should be 0
    end

    it 'should empty the storage' do
      2.times do |i|
        p = page.to_hash
        p['url'] = "#{p['url']}/#{i}"
        storage.add Polipus::Page.from_hash(p)
      end
      filled_storage.count.should be 3
      filled_storage.clear
      filled_storage.count.should be 0
    end

  end

  context 'UPDATE' do
    let(:filled_storage) do
      storage.add page
      storage
    end

    it 'should update a page' do
      filled_storage.add page
    end
  end

  context 'SELECT' do
    let(:filled_storage) do
      storage.add page
      storage
    end

    it 'should fetch a page' do
      p = filled_storage.get page
      expect(p).to_not be nil
      expect(p).to be_a Polipus::Page
      expect(p.url.to_s).to eq 'http://www.google.com/'
      expect(p.links.count).to be 2
      expect(p.headers['content-type']).to eq ['text/html']
      expect(p.fetched_at).to be > 0
    end

  end

  context 'CURSOR' do
    it 'should iterate over pages' do
      10.times do |i|
        p = page.to_hash
        p['url'] = "#{p['url']}/#{i}"
        storage.add Polipus::Page.from_hash(p)
      end
      storage.count.should be 10
      i = 0
      storage.each { i += 1 }
      expect(i).to be 10
    end
  end

end
