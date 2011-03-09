require "thor/shell"

say "setting up the Gemfile...", :yellow

gem 'activerecord-jdbcsqlite3-adapter'

say("setting up Gemfile for jQuery...", :yellow)
gem 'jquery-rails'

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

run 'rm public/javascripts/rails.js'
say("replacing Prototype with jQuery", :yellow)
# "--ui" enables optional jQuery UI
run 'rails generate jquery:install --ui'

application do
  "
    config.time_zone = 'Beijing'
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'zh-CN'
    config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
    config.after_initialize do
      config.active_record.default_timezone = :local
    end
  "
end

#FIXME bad smoke
run "sed -i -e '43d' config/application.rb"

say("Done setting up your Rails app.", :yellow)
