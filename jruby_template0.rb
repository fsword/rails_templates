require "thor/shell"
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

say "setting up the Gemfile...", :yellow

run 'del public/javascripts/rails.js'
run 'copy config/database.yml config/default.database.yml'
run 'del public/index.html'
run 'del public/favicon.ico'
run 'del public/images/rails.png'
run 'del README'

say("replacing Prototype with jQuery", :yellow)
say("setting up Gemfile for jQuery...", :yellow)
gem 'jquery-rails'

say("setting up Gemfile for devise...", :yellow)
gem 'devise'

gem 'jruby-openssl'
gem 'activerecord-jdbcsqlite3-adapter'

database_configs = File.readlines 'config/database.yml'
File.open('config/database.yml','w'){|f|
  database_configs.each{|line|
    f.write(line.sub /adapter:\ sqlite3/, 'adapter: jdbcsqlite3')
  }
}

gem_configs = File.readlines 'Gemfile'
File.open('Gemfile','w'){|f|
  gem_configs.each{|line|
    f.write(line.sub /gem\ 'sqlite3'/, "gem 'jdbc-sqlite3'")
  }
}

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
    config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
    config.after_initialize do
      config.active_record.default_timezone = :local
    end
  "
end

run 'jruby -S rails generate jquery:install --ui'

get "https://github.com/svenfuchs/rails-i18n/raw/master/rails/locale/zh-CN.yml", "config/locales/zh-CN.yml"

url_pre="https://github.com/fsword/rails_templates/raw/master/resource/locale"

get "#{url_pre}/devise.zh-CN.yml", "config/locales/devise.zh-CN.yml"

get "#{url_pre}/responders.zh-CN.yml", "config/locales/responders.zh-CN.yml"

get "#{url_pre}/simple_form.zh-CN.yml", "config/locales/simple_form.zh-CN.yml"

get "#{url_pre}/model.zh-CN.yml", "config/locales/model.zh-CN.yml"


generate(:controller, "home index")
route "root :to => 'home#index'"


say("Done setting up your Rails app.", :yellow)
