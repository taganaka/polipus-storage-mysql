require "spec_helper"
require "polipus/storage/mysql_store"

describe Polipus::Storage::MysqlStore do
  let(:test_db_name){'polipus_mysql_store_spec'}
  let(:options) do
    {
      host: 'localhost',
      username: 'root',
      password: '',
      database: test_db_name,
      table_name: 'rspec_pages'
    }
  end

  let(:my){
    o = options.dup
    o.delete :database
    Mysql2::Client.new o
  }
  let(:db){Mysql2::Client.new options}

  let(:page){
    Polipus::Page.new "http://www.google.com/", 
      body: '<html></html>',
      links: %w(http://www.a.com/ http://www.b.com/),
      code: 201,
      depth: 1,
      referer: "http://www.a.com/1",
      response_time: 1,
      fetched: true,
      fetched_at: Time.now,
      error: 'an error'
  }

  let(:storage){Polipus::Storage::MysqlStore.new(options)}

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
      2.times { |i|
        p = page.to_hash
        p['url'] = "#{p['url']}/#{i}"
        storage.add Polipus::Page.from_hash(p)
      }
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
      p.should_not be nil
      puts p
    end

  end
  
end