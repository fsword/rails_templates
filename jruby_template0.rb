require "thor/shell"
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

say "setting up the Gemfile...", :yellow

run 'cp config/database.yml config/default.database.yml'

gem 'arel', '2.0.9'
gem 'jdbc-sqlite3'
gem 'rspec-rails', '2.6.0.rc6', :group => ['development','test']
gem 'jruby-openssl'
gem 'warbler'
gem 'activerecord-jdbcsqlite3-adapter'
gem 'inherited_resources_views'
gem 'inherited_resources'

#change jdbc driver
gsub_file 'Gemfile', /gem\ 'sqlite3'/, ""  
gsub_file 'config/database.yml', /adapter:\ +sqlite3/, "adapter: jdbcsqlite3" 

# Install gems
say("installing gems (takes a few minutes!)...", :yellow)
run 'bundle install'

application do
  "
    require 'openssl'
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    config.time_zone = 'Beijing'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'zh-CN'
    config.after_initialize do
      config.active_record.default_timezone = :local
    end
    config.spring=true
  "
end

say("Done setting up your Rails app.", :yellow)

# monkey patch: rake 0.9.0 bugfix
gsub_file 'Rakefile', /require\ 'rake'/, %Q[require 'rake'

class Rails::Application
  include Rake::DSL if defined?(Rake::DSL)
end]

say "install inherited_resources_views", :yellow
generate "inherited_resources_views"

say "add java_side plugin", :yellow
plugin 'java_side', :git => 'https://github.com/fsword/java_side.git'
