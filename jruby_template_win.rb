require "thor/shell"
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# define a try_to method for https request
def try_to n
  if block_given?
    n.times{|i|
      begin
        return yield
      rescue
        p "failed #{i} times, I will sleep 1 second"
        sleep 1
      end
    }
    nil
  end
end

def try_get url, file=nil
  try_to(3)do get url,file end
end

say "setting up the Gemfile...", :yellow

remove_file '.gitignore'
try_get "https://github.com/fsword/rails_templates/raw/master/resource/gitignore", ".gitignore"
remove_file 'public/javascripts/rails.js'
remove_file 'public/index.html'
remove_file 'public/favicon.ico'
remove_file 'public/images/rails.png'
remove_file 'README'

say("setting up Gemfile for BDD test...", :yellow)

gem 'arel', '2.0.9'
gem 'rspec-rails', '2.6.0.rc6', :group => ['development','test']
gem 'cucumber-rails', :group => ['development','test']
gem 'capybara', :group => ['development','test']
gem 'factory_girl_rails', :group => ['development','test']
gem 'database_cleaner', :group => ['development','test']
gem "shoulda", :group => ['development','test']
gem 'spork', :group => ['development','test']
gem 'launchy', :group => ['development','test']

gem 'inherited_resources_views'
gem 'inherited_resources'

gem 'warbler'

say("replacing Prototype with jQuery", :yellow)
remove_file 'public/javascripts/rails.js' if File.exist? 'public/javascripts/rails.js'
say("setting up Gemfile for jQuery...", :yellow)
gem 'jquery-rails'

say("setting up Gemfile for devise...", :yellow)
gem 'devise'

gem 'jruby-openssl'
gem 'jdbc-sqlite3'
gem 'activerecord-jdbcsqlite3-adapter'

gsub_file 'config/database.yml', /adapter:\ sqlite3/, "adapter: jdbcsqlite3" 

gsub_file 'Gemfile', /gem\ 'sqlite3'/, "" 

gsub_file 'config/application.rb', /(config.action_view.javascript_expansions.*)/,
        "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)" 

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

say('monkey patch: rake 0.9.0 bugfix')
gsub_file 'Rakefile', /require\ 'rake'/, %Q[require 'rake'

class Rails::Application
  include Rake::DSL if defined?(Rake::DSL)
end]

try_get "https://github.com/svenfuchs/rails-i18n/raw/master/rails/locale/zh-CN.yml", "config/locales/zh-CN.yml"
url_pre="https://github.com/fsword/rails_templates/raw/master/resource/locale"
try_get "#{url_pre}/devise.zh-CN.yml", "config/locales/devise.zh-CN.yml"
try_get "#{url_pre}/responders.zh-CN.yml", "config/locales/responders.zh-CN.yml"
try_get "#{url_pre}/simple_form.zh-CN.yml", "config/locales/simple_form.zh-CN.yml"
try_get "#{url_pre}/model.zh-CN.yml", "config/locales/model.zh-CN.yml"

# Install gems
say("installing gems (takes a few minutes!)...", :yellow)
run 'bundle install'

generate(:controller, "home index")
route "root :to => 'home#index'"

say("Done setting up your Rails app.", :yellow)

say "install inherited_resources_views", :yellow
generate "inherited_resources_views"

say "install jquery", :yellow
generate "jquery:install --ui"

say "install devise", :yellow
generate "devise:install"
generate "devise:user"
generate "devise:views"

say("replacing Test::Unit with BDD", :yellow)
generate("rspec:install")
say("install cucumber", :yellow)
generate('cucumber:install')

=begin
jruby -S rails generate jquery:install --ui

jruby -S rails generate devise:install
jruby -S rails generate devise user
jruby -S rails generate devise:views

say("replacing Test::Unit with BDD", :yellow)
jruby -S rails generate rspec:install
 say("install cucumber", :yellow)
jruby -S rails generate cucumber:install

say "install inherited_resources_views", :yellow
jruby -S rails generate inherited_resources_views

jruby -S rake db:migrate
=end
say "add java_side plugin", :yellow
plugin 'java_side', :git => 'https://github.com/fsword/java_side.git'

say "add db:migrate", :yellow
rake('db:migrate')
