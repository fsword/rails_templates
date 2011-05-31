require "thor/shell"
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

say "setting up the Gemfile...", :yellow

run 'cp config/database.yml config/default.database.yml'
gem 'jruby-openssl'
gem 'warbler'
gem 'activerecord-jdbcsqlite3-adapter'
#change jdbc driver
gsub_file 'Gemfile', /gem\ 'sqlite3'/, "gem 'jdbc-sqlite3'"  
gsub_file 'config/database.yml', /adapter:\ +sqlite3/, "adapter: jdbcsqlite3" 

# Install gems
say("installing gems (takes a few minutes!)...", :yellow)
run 'bundle install'

application do
  "
    require 'openssl'
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    config.time_zone = 'Beijing'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'zh-CN'
    config.after_initialize do
      config.active_record.default_timezone = :local
    end
  "
end

say("Done setting up your Rails app.", :yellow)

plugin 'java_side', :git => 'git@github.com:fsword/java_side.git'
