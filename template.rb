db_pass = ask("Database Password")
db_username = ask("Database username")

gem_group :development, :test do
  gem "pry-rails"
  gem "factory_girl_rails"
  gem "faker"
  gem "figaro"
end

gem_group :test do
  gem "database_cleaner"
  gem "rspec-rails"
  gem "shoulda-matchers", git: "https://github.com/thoughtbot/shoulda-matchers.git", branch: "rails-5"
  gem "simplecov"
end

gem_group :development do
  gem "annotate"
  gem "guard", require: false
  gem "guard-bundler", require: false
  gem "rubocop", require: false
end

gem_group :development, :tddium_ignore, :darwin do
  gem "terminal-notifier-guard", require: false # OSX-specific notifications for guard
end

gem "carrierwave"
gem "devise"
gem "kaminari"
gem "mini_magick"

def generating
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: 'development'

  generate(:controller, "pages", "index")
  route "root to: \"pages#index\""

  generate("rspec:install")
  generate("annotate:install")
  run("bundle exec figaro install")
end

def injecting
  environment "
  config.generators do |g|
    g.helper false
    g.assets false
    g.view_specs false
    g.test_framework :rspec
    g.factory_girl dir: \"spec/factories\"
  end
  "

  file ".rubocop.yml", <<-CODE
  AllCops:
    Exclude:
      - 'vendor/**/*'
      - 'spec/fixtures/**/*'
      - 'tmp/**/*'
    TargetRubyVersion: 2.3.1

  Style/FrozenStringLiteralComment:
    EnforcedStyle: always

  Style/Layout/EndOfLine:
    EnforcedStyle: lf

  Style/Layout/IndentHeredoc:
    EnforcedStyle: powerpack

  Lint/AmbiguousBlockAssociation:
    Exclude:
      - 'spec/**/*.rb'

  Lint/UselessAccessModifier:
    MethodCreatingMethods:
      - 'def_matcher'
      - 'def_node_matcher'

  Metrics/BlockLength:
    Exclude:
      - 'Rakefile'
      - '**/*.rake'
      - 'spec/**/*.rb'

  Metrics/ModuleLength:
    Exclude:
      - 'spec/**/*.rb'

  Performance/Caller:
    Exclude:
      - spec/rubocop/cop/performance/caller_spec.rb

  Style/StringLiterals:
    EnforcedStyle: double_quotes
    SupportedStyles:
      - double_quotes
    # If `true`, strings which span multiple lines using `\` for continuation must
    # use the same type of quotes on each line.
    ConsistentQuotesInMultiline: false

  Style/StringLiteralsInInterpolation:
    EnforcedStyle: double_quotes
    SupportedStyles:
      - double_quotes

  Style/ClassAndModuleChildren:
    EnforcedStyle: compact

  Style/DocumentationMethod:
    RequireForNonPublicMethods: false

  Style/FrozenStringLiteralComment:
    Enabled: false

  Documentation:
    Enabled: false

  CODE
end

after_bundle do
  injecting
  generating
end

