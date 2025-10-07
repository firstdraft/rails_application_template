# Unified Rails Application Template
# Usage:
#   rails new APP_NAME \
#     --database=postgresql \
#     --javascript=esbuild \
#     --css=bootstrap \
#     --skip-test \
#     --skip-kamal \
#     --skip-rubocop \
#     -m /path/to/this/template.rb

base_url = "https://raw.githubusercontent.com/firstdraft/rails_application_template/main"

# === CONFIGURATION OPTIONS ===

say "\n=== Rails Application Template ===", :yellow
say "\nThis template will configure your Rails app with modern best practices.", :cyan
say "\nDefault configuration includes:", :yellow

say "\nEssential Tools (always included):", :green
say "  • RSpec & FactoryBot - Testing framework"
say "  • StandardRB - Ruby code formatting"
say "  • Herb - HTML+ERB linting and analysis"
say "  • Bullet - N+1 query detection"
say "  • AnnotateRb - Auto-annotate models"
say "  • Pry, Better Errors, Amazing Print - Debugging"
say "  • Dotenv - Environment management"

say "\nDefault Optional Tools:", :green
say "  ✅ SimpleCov - Code coverage"
say "  ✅ Shoulda Matchers - One-liner tests"
say "  ✅ Faker - Test data generation"
say "  ❌ WebMock - HTTP stubbing (often not needed)"
say "  ✅ Goldiloader - Auto N+1 prevention"
say "  ✅ rack-mini-profiler - Development performance bar"
say "  ✅ Skylight - Production performance monitoring"
say "  ✅ Ahoy + Blazer - Analytics tracking and dashboard"
say "  ✅ Rails ERD - Entity diagrams"
say "  ❌ rails_db - Database web UI (security concern)"
say "  ✅ bundler-audit - Vulnerability scanning"
say "  ✅ Rollbar - Error tracking (default choice)"
say "  ✅ Bootstrap overrides - Custom Sass variables file"
say "  ❌ Full JS/CSS linting - Prettier, ESLint, Stylelint (not needed for all apps)"
say "  ❌ UUID primary keys - Use UUIDs instead of integers"
say "  ❌ Multi-database setup - Rails 8 separate databases (single DB is simpler for deployment)"
say "  ❌ Render.com deployment - Build script and render.yaml blueprint"

say "\n"
customize = yes?("Would you like to customize these options? (y/n)")

# Set up configuration based on user choice
if customize
  say "\n=== Customize Your Configuration ===", :yellow
  say "Let's go through each optional tool:\n", :cyan

  # Testing preferences
  testing_options = {}
  say "\nTesting Tools:", :yellow
  testing_options[:simplecov] = yes?("  Include SimpleCov for code coverage? (y/n)")
  testing_options[:shoulda] = yes?("  Include Shoulda Matchers for one-liner tests? (y/n)")
  testing_options[:faker] = yes?("  Include Faker for test data generation? (y/n)")
  testing_options[:webmock] = yes?("  Include WebMock for HTTP request stubbing? (y/n)")

  # Performance monitoring
  performance_options = {}
  say "\nPerformance Tools:", :yellow
  performance_options[:goldiloader] = yes?("  Include Goldiloader for automatic N+1 prevention? (y/n)")
  performance_options[:rack_profiler] = yes?("  Include rack-mini-profiler for development performance bar? (y/n)")
  performance_options[:skylight] = yes?("  Include Skylight for production performance monitoring? (y/n)")

  # Analytics
  analytics_options = {}
  say "\nAnalytics:", :yellow
  analytics_options[:ahoy_blazer] = yes?("  Include Ahoy + Blazer for analytics tracking and dashboard? (y/n)")

  # Documentation tools
  doc_options = {}
  say "\nDocumentation Tools:", :yellow
  doc_options[:rails_erd] = yes?("  Include Rails ERD for entity relationship diagrams? (y/n)")
  doc_options[:rails_db] = yes?("  Include rails_db for web-based database UI? (y/n)")

  # Security & safety
  security_options = {}
  say "\nSecurity & Safety Tools:", :yellow
  security_options[:bundler_audit] = yes?("  Include bundler-audit for vulnerability scanning? (y/n)")

  # Error monitoring
  monitoring_options = {}
  say "\nError Monitoring:", :yellow
  say "  Choose error monitoring service:"
  say "  1. Rollbar (default)"
  say "  2. Honeybadger"
  say "  3. None"
  monitoring_choice = ask("  Enter choice (1-3):", :limited_to => %w[1 2 3], :default => "1")
  monitoring_options[:error_service] = case monitoring_choice
  when "1"
    "rollbar"
  when "2"
    "honeybadger"
  when "3"
    "none"
  end

  # Frontend tools
  frontend_options = {}
  say "\nFrontend Tools:", :yellow
  frontend_options[:bootstrap_overrides] = yes?("  Include Bootstrap overrides file for easy customization? (y/n)")
  frontend_options[:full_linting] = yes?("  Include full JS/CSS linting stack (Prettier, ESLint, Stylelint)? (y/n)")

  # Database configuration
  db_options = {}
  say "\nDatabase Configuration:", :yellow
  db_options[:use_uuid] = yes?("  Use UUIDs for primary keys instead of integers? (y/n)")
  db_options[:multi_database] = yes?("  Use Rails 8 multi-database setup (separate DBs for cache/queue/cable)? (y/n)")

  # Deployment configuration
  render_options = {}
  say "\nDeployment:", :yellow
  render_options[:enabled] = yes?("  Configure for Render.com deployment (build script + render.yaml)? (y/n)")
  if render_options[:enabled]
    render_options[:separate_worker] = yes?("  Run Solid Queue as separate worker service? (y/n)")
  else
    render_options[:separate_worker] = false
  end
else
  # Use default configuration
  testing_options = {
    simplecov: true,
    shoulda: true,
    faker: true,
    webmock: false
  }

  performance_options = {
    goldiloader: true,
    rack_profiler: true,
    skylight: true
  }

  analytics_options = {
    ahoy_blazer: true
  }

  doc_options = {
    rails_erd: true,
    rails_db: false
  }

  security_options = {
    bundler_audit: true
  }

  monitoring_options = {
    error_service: "rollbar"
  }

  frontend_options = {
    bootstrap_overrides: true,
    full_linting: false
  }

  db_options = {
    use_uuid: false,
    multi_database: false
  }

  render_options = {
    enabled: false,
    separate_worker: false
  }

  say "\n✅ Using default configuration!", :green
end

# === GEMS CONFIGURATION ===

# Automatic N+1 prevention (all environments)
if performance_options[:goldiloader]
  gem "goldiloader"
end

gem_group :development, :test do
  # Essential Debugging (always included)
  gem "pry-rails"
  gem "better_errors"
  gem "binding_of_caller"
  gem "amazing_print"

  # Environment (always included)
  gem "dotenv"

  # Testing Framework (always included)
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails"

  # Optional Testing Tools
  gem "shoulda-matchers", "~> 6.0" if testing_options[:shoulda]
  gem "faker" if testing_options[:faker]

  # Code Quality (always included)
  gem "standard", require: false
  gem "standard-rails", require: false
  gem "herb", require: false

  # N+1 Query Detection (always included in dev/test)
  gem "bullet"

  # Security
  # Note: Rails 8+ includes brakeman by default, so we don't add it
  gem "bundler-audit", require: false if security_options[:bundler_audit]

  # ERB Linting (only with full linting)
  if frontend_options[:full_linting]
    gem "better_html", require: false
    gem "erb_lint", require: false
    gem "erblint-github", require: false
  end
end

gem_group :development do
  # Optional Performance Tools
  gem "rack-mini-profiler" if performance_options[:rack_profiler]

  # Documentation (annotaterb always included)
  gem "annotaterb"
  gem "rails-erd" if doc_options[:rails_erd]
  gem "rails_db", ">= 2.3.1" if doc_options[:rails_db]
end

# Production performance monitoring
if performance_options[:skylight]
  gem "skylight"
end

# Analytics
if analytics_options[:ahoy_blazer]
  gem "ahoy_matey"
  gem "blazer"
  gem "chartkick"  # For charts in Blazer
  gem "groupdate"  # For time-based grouping in Blazer
end

# Error Monitoring (outside of any group)
case monitoring_options[:error_service]
when "rollbar"
  gem "rollbar"
when "honeybadger"
  gem "honeybadger"
end

gem_group :test do
  # System Testing (always included)
  gem "capybara"
  gem "selenium-webdriver"

  # Optional Testing Tools
  gem "webmock" if testing_options[:webmock]
  gem "simplecov", require: false if testing_options[:simplecov]

  # Enhanced Capybara (always included)
  gem "action_dispatch-testing-integration-capybara",
    github: "thoughtbot/action_dispatch-testing-integration-capybara",
    tag: "v0.1.1",
    require: "action_dispatch/testing/integration/capybara/rspec"
end

# === AFTER BUNDLE ACTIONS ===

after_bundle do
  # Initial database setup
  rails_command("db:create")

  git add: "-A"
  git commit: "-m 'Initial Rails app with custom template'"

  # === DATABASE CONFIGURATION ===

  unless db_options[:multi_database]
    say "Configuring single database for all environments (disabling Rails 8 multi-database)...", :cyan

    # Completely replace database.yml with traditional single-database configuration
    remove_file "config/database.yml"

    create_file "config/database.yml", <<~YAML
      # PostgreSQL. Versions 9.3 and up are supported.
      #
      # Install the pg driver:
      #   gem install pg
      # On macOS with Homebrew:
      #   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
      # On Windows:
      #   gem install pg
      #       Choose the win32 build.
      #       Install PostgreSQL and put its /bin directory on your path.
      #
      # Configure Using Gemfile
      # gem "pg"
      #
      default: &default
        adapter: postgresql
        encoding: unicode
        # For details on connection pooling, see Rails configuration guide
        # https://guides.rubyonrails.org/configuring.html#database-pooling
        pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

      development:
        <<: *default
        database: #{app_name}_development

        # The specified database role being used to connect to PostgreSQL.
        # To create additional roles in PostgreSQL see `$ createuser --help`.
        # When left blank, PostgreSQL will use the default role. This is
        # the same name as the operating system user running Rails.
        #username: #{app_name}

        # The password associated with the PostgreSQL role (username).
        #password:

        # Connect on a TCP socket. Omitted by default since the client uses a
        # domain socket that doesn't need configuration. Windows does not have
        # domain sockets, so uncomment these lines.
        #host: localhost

        # The TCP port the server listens on. Defaults to 5432.
        # If your server runs on a different port number, change accordingly.
        #port: 5432

        # Schema search path. The server defaults to $user,public
        #schema_search_path: myapp,sharedapp,public

        # Minimum log levels, in increasing order:
        #   debug5, debug4, debug3, debug2, debug1,
        #   log, notice, warning, error, fatal, and panic
        # Defaults to warning.
        #min_messages: notice

      # Warning: The database defined as "test" will be erased and
      # re-generated from your development database when you run "rake".
      # Do not set this db to the same as development or production.
      test:
        <<: *default
        database: #{app_name}_test

      # As with config/credentials.yml, you never want to store sensitive information,
      # like your database password, in your source code. If your source code is
      # ever seen by anyone, they now have access to your database.
      #
      # Instead, provide the password or a full connection URL as an environment
      # variable when you boot the app. For example:
      #
      #   DATABASE_URL="postgres://myuser:mypass@localhost/somedatabase"
      #
      # If the connection URL is provided in the special DATABASE_URL environment
      # variable, Rails will automatically merge its configuration values on top of
      # the values provided in this file. Alternatively, you can specify a connection
      # URL environment variable explicitly:
      #
      #   production:
      #     url: <%= ENV["MY_APP_DATABASE_URL"] %>
      #
      # Read https://guides.rubyonrails.org/configuring.html#configuring-a-database
      # for a full overview on how database connection configuration can be specified.
      #
      production:
        <<: *default
        url: <%= ENV["DATABASE_URL"] %>
    YAML

    # Convert Solid schema files into regular migrations
    # This ensures all tables are created in the primary database
    timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i

    # Create migrations for cache, queue, and cable tables
    if File.exist?("db/cache_schema.rb")
      cache_schema = File.read("db/cache_schema.rb")
      # Extract the content inside the schema definition
      if cache_schema.match(/ActiveRecord::Schema.*?\.define.*?do\s*(.*)\s*end/m)
        cache_content = $1
        create_file "db/migrate/#{timestamp}_create_solid_cache_tables.rb", <<~RUBY
          class CreateSolidCacheTables < ActiveRecord::Migration[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]
            def change
          #{cache_content.split("\n").map { |line| "    " + line }.join("\n").rstrip}
            end
          end
        RUBY
        timestamp += 1
      end
    end

    if File.exist?("db/queue_schema.rb")
      queue_schema = File.read("db/queue_schema.rb")
      if queue_schema.match(/ActiveRecord::Schema.*?\.define.*?do\s*(.*)\s*end/m)
        queue_content = $1
        create_file "db/migrate/#{timestamp}_create_solid_queue_tables.rb", <<~RUBY
          class CreateSolidQueueTables < ActiveRecord::Migration[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]
            def change
          #{queue_content.split("\n").map { |line| "    " + line }.join("\n").rstrip}
            end
          end
        RUBY
        timestamp += 1
      end
    end

    if File.exist?("db/cable_schema.rb")
      cable_schema = File.read("db/cable_schema.rb")
      if cable_schema.match(/ActiveRecord::Schema.*?\.define.*?do\s*(.*)\s*end/m)
        cable_content = $1
        create_file "db/migrate/#{timestamp}_create_solid_cable_tables.rb", <<~RUBY
          class CreateSolidCableTables < ActiveRecord::Migration[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]
            def change
          #{cable_content.split("\n").map { |line| "    " + line }.join("\n").rstrip}
            end
          end
        RUBY
      end
    end

    # Remove the separate schema files and migration directories
    remove_file "db/cache_schema.rb" if File.exist?("db/cache_schema.rb")
    remove_file "db/queue_schema.rb" if File.exist?("db/queue_schema.rb")
    remove_file "db/cable_schema.rb" if File.exist?("db/cable_schema.rb")

    # Remove separate migration directories (Rails 8 multi-database feature)
    remove_dir "db/cache_migrate" if File.directory?("db/cache_migrate")
    remove_dir "db/queue_migrate" if File.directory?("db/queue_migrate")
    remove_dir "db/cable_migrate" if File.directory?("db/cable_migrate")

    # Run migrations to create all tables in the primary database
    rails_command("db:migrate")

    git add: "-A"
    git commit: "-m 'Configure single database (disable Rails 8 multi-database)'"
  else
    say "Keeping Rails 8 multi-database setup (separate databases for cache/queue/cable)...", :cyan

    # Just run migrations - Rails 8 default multi-database setup is already configured
    rails_command("db:migrate")

    git add: "-A"
    git commit: "-m 'Run initial migrations with Rails 8 multi-database setup'"
  end

  # === GENERATOR CONFIGURATION ===

  generators_config = <<-HEREDOC.gsub(/^  /, "")
    config.generators do |g|
      g.system_tests = nil
      g.scaffold_stylesheet false
    end
  HEREDOC

  gsub_file "config/application.rb",
    /config.generators.system_tests = nil/,
    generators_config

  git add: "-A"
  git commit: "-m 'Configure generators'"

  # === GOLDILOADER CONFIGURATION (if enabled) ===

  if performance_options[:goldiloader]
    create_file "config/initializers/goldiloader.rb", <<~RUBY
      # Goldiloader configuration
      # Automatic eager loading to prevent N+1 queries

      # Goldiloader is enabled globally by default
      # You can disable it for specific code blocks:
      #
      # Goldiloader.disabled do
      #   # Code here runs without automatic eager loading
      # end
      #
      # Or disable it for specific associations:
      #
      # class Post < ApplicationRecord
      #   has_many :comments, -> { auto_include(false) }
      # end
      #
      # Note: Bullet's unused eager loading detection is disabled
      # to avoid conflicts with Goldiloader's automatic loading
    RUBY

    git add: "-A"
    git commit: "-m 'Configure Goldiloader for automatic N+1 prevention'"
  end

  # === RENDER.COM DEPLOYMENT CONFIGURATION (if selected) ===

  if render_options[:enabled]
    say "Configuring for Render.com deployment...", :cyan

    # Create bin/render-build.sh
    create_file "bin/render-build.sh", <<~BASH
      #!/usr/bin/env bash
      # exit on error
      set -o errexit

      bundle install
      bundle exec rake db:migrate
      bundle exec rake assets:precompile
      bundle exec rake assets:clean
    BASH

    # Make script executable
    chmod "bin/render-build.sh", 0755

    # Create render.yaml blueprint
    render_yaml_content = <<~YAML
      databases:
        - name: #{app_name}-db
          databaseName: #{app_name}_production
          user: #{app_name}
          plan: free

      services:
        - type: web
          name: #{app_name}-web
          runtime: ruby
          plan: free
          buildCommand: "./bin/render-build.sh"
          startCommand: "bundle exec puma -C config/puma.rb"
          healthCheckPath: /up
          envVars:
            - key: DATABASE_URL
              fromDatabase:
                name: #{app_name}-db
                property: connectionString
            - key: RAILS_MASTER_KEY
              sync: false
            - key: WEB_CONCURRENCY
              value: 2
    YAML

    # Add worker service if separate_worker is enabled
    if render_options[:separate_worker]
      render_yaml_content += <<~YAML

        - type: worker
          name: #{app_name}-worker
          runtime: ruby
          plan: free
          buildCommand: "bundle install"
          startCommand: "bundle exec rake solid_queue:start"
          envVars:
            - key: DATABASE_URL
              fromDatabase:
                name: #{app_name}-db
                property: connectionString
            - key: RAILS_MASTER_KEY
              sync: false
      YAML
    end

    create_file "render.yaml", render_yaml_content

    # Configure Puma plugin for Solid Queue if not using separate worker
    unless render_options[:separate_worker]
      # Add plugin to puma.rb
      append_to_file "config/puma.rb", <<~RUBY

        # Use Solid Queue with Puma (runs background jobs in web process)
        plugin :solid_queue
      RUBY

      # Silence polling in development
      inject_into_file "config/environments/development.rb",
        "  # Silence Solid Queue polling logs in development\n  config.solid_queue.silence_polling = true\n\n",
        after: "Rails.application.configure do\n"
    end

    git add: "-A"
    git commit: "-m 'Configure Render.com deployment with #{render_options[:separate_worker] ? 'separate worker service' : 'Puma plugin'}'"
  end

  # === UUID CONFIGURATION (if selected) ===

  if db_options[:use_uuid]
    create_file "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_enable_extension_for_uuid.rb", <<~RUBY
      class EnableExtensionForUuid < ActiveRecord::Migration[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]
        def change
          enable_extension 'pgcrypto'
        end
      end
    RUBY

    rails_command("db:migrate")

    insert_into_file "config/application.rb",
      "      g.orm :active_record, primary_key_type: :uuid\n",
      after: "    config.generators do |g|\n"

    inject_into_class "app/models/application_record.rb",
      "ApplicationRecord",
      "  self.implicit_order_column = \"created_at\"\n\n"

    git add: "-A"
    git commit: "-m 'Configure UUID primary keys'"
  end

  # === RSPEC SETUP ===

  generate("rspec:install")

  # Configure RSpec
  insert_into_file "spec/rails_helper.rb",
    "\n  config.infer_base_class_for_anonymous_controllers = false\n",
    after: "RSpec.configure do |config|\n"

  uncomment_lines "spec/rails_helper.rb", /Rails\.root\.glob/

  # Build spec_helper.rb configuration
  spec_helper_additions = []
  spec_helper_additions << "config.example_status_persistence_file_path = \"tmp/rspec_examples.txt\""
  spec_helper_additions << "config.order = :random"

  if testing_options[:simplecov]
    spec_helper_additions << <<~RUBY.strip

      # SimpleCov configuration
      if ENV['COVERAGE']
        require 'simplecov'
        SimpleCov.start 'rails'
      end
    RUBY
  end

  spec_helper_config = spec_helper_additions.join("\n    ")

  insert_into_file "spec/spec_helper.rb",
    "\n    #{spec_helper_config}\n",
    after: "RSpec.configure do |config|\n"

  # WebMock configuration (if selected)
  if testing_options[:webmock]
    create_file "spec/support/webmock.rb", <<~RUBY
      require 'webmock/rspec'

      WebMock.disable_net_connect!(
        allow_localhost: true,
        allow: [
          /(chromedriver|storage).googleapis.com/,
          "googlechromelabs.github.io"
        ]
      )
    RUBY
  end

  # Shoulda Matchers configuration (if selected)
  if testing_options[:shoulda]
    create_file "spec/support/shoulda_matchers.rb", <<~RUBY
      Shoulda::Matchers.configure do |config|
        config.integrate do |with|
          with.test_framework :rspec
          with.library :rails
        end
      end
    RUBY
  end

  # Factory Bot configuration (always included)
  create_file "spec/support/factory_bot.rb", <<~RUBY
    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
    end
  RUBY

  git add: "-A"
  git commit: "-m 'Configure RSpec with testing tools'"

  # === STANDARDRB CONFIGURATION ===

  # Use the current Ruby version dynamically
  current_ruby_version = RUBY_VERSION.split('.')[0..1].join('.')

  create_file ".standard.yml", <<~YAML
    # StandardRB configuration
    # https://github.com/standardrb/standard

    ruby_version: #{current_ruby_version}

    plugins:
      - standard-rails

    ignore:
      - 'db/schema.rb'
      - 'db/migrate/**/*'
      - 'vendor/**/*'
      - 'node_modules/**/*'
      - 'bin/**/*'
      - 'public/**/*'
      - 'tmp/**/*'
      - 'log/**/*'
  YAML

  git add: "-A"
  git commit: "-m 'Configure StandardRB'"

  # === HERB CONFIGURATION ===

  # Create Herb configuration file
  create_file ".herb.yml", <<~YAML
    # Herb configuration for HTML+ERB linting and analysis
    # https://herb-tools.dev

    # Files to analyze
    include:
      - "app/views/**/*.html.erb"
      - "app/views/**/*.erb"
      - "app/components/**/*.html.erb"

    # Files to exclude
    exclude:
      - "vendor/**/*"
      - "node_modules/**/*"
      - "tmp/**/*"

    # Linter rules (customize as needed)
    # Full list: https://herb-tools.dev/projects/linter#rules
    rules:
      # Enable all default rules
      all: true
  YAML

  git add: "-A"
  git commit: "-m 'Configure Herb for HTML+ERB analysis'"

  # === ERROR MONITORING CONFIGURATION ===

  case monitoring_options[:error_service]
  when "rollbar"
    # Generate Rollbar configuration
    generate("rollbar")

    # Rollbar generator only disables in test by default, we also want to disable in development
    gsub_file "config/initializers/rollbar.rb",
      /# Here we'll disable in 'test':\n  if Rails\.env\.test\?/,
      "# Here we'll disable in 'test' and 'development':\n  if Rails.env.test? || Rails.env.development?"

    git add: "-A"
    git commit: "-m 'Configure Rollbar for error tracking'"

  when "honeybadger"
    # Generate Honeybadger configuration
    generate("honeybadger")

    # Update Honeybadger initializer to use ENV variable if needed
    if File.exist?("config/honeybadger.yml")
      gsub_file "config/honeybadger.yml",
        /api_key: .+/,
        "api_key: <%= ENV['HONEYBADGER_API_KEY'] %>"
    end

    git add: "-A"
    git commit: "-m 'Configure Honeybadger for error tracking'"
  end

  # === SKYLIGHT CONFIGURATION (if selected) ===

  if performance_options[:skylight]
    # Generate Skylight configuration
    say "Setting up Skylight for performance monitoring...", :cyan

    # Create Skylight config file
    create_file "config/skylight.yml", <<~YAML
      # Skylight Performance Monitoring Configuration
      # https://www.skylight.io/support

      authentication: <%= ENV["SKYLIGHT_AUTHENTICATION"] %>

      # Uncomment to customize settings:
      # ignored_endpoints:
      #   - HeartbeatController#ping
      #   - HealthController#check

      # Enable in additional environments:
      # staging:
      #   authentication: <%= ENV["SKYLIGHT_AUTHENTICATION"] %>
    YAML

    git add: "-A"
    git commit: "-m 'Configure Skylight for performance monitoring'"
  end

  # === ANALYTICS CONFIGURATION (AHOY + BLAZER) ===

  if analytics_options[:ahoy_blazer]
    say "Setting up Ahoy + Blazer for analytics...", :cyan

    # Generate Ahoy installation
    generate("ahoy:install")

    # Generate Blazer installation
    generate("blazer:install")

    # Add Blazer route
    route 'mount Blazer::Engine, at: "/analytics"'

    # Configure Ahoy to work with Blazer
    gsub_file "config/initializers/ahoy.rb",
      "# Ahoy.api = false",
      "Ahoy.api = true # Enable API for JavaScript tracking"

    # Add JavaScript tracking for esbuild
    if File.exist?("app/javascript/application.js")
      append_to_file "app/javascript/application.js", <<~JS

        // Ahoy analytics tracking
        import ahoy from "ahoy.js"

        // Track page views
        ahoy.trackView();

        // Example: Track custom events
        // ahoy.track("Clicked Button", {button: "signup"});
      JS

      # Add ahoy.js to package.json
      run "yarn add ahoy.js"
    end

    # Create sample Blazer queries for Ahoy data
    create_file "db/blazer_queries.yml", <<~YAML
      # Sample Blazer queries for Ahoy analytics
      # Import these in Blazer UI or via rake blazer:import

      - name: "Daily Active Users"
        statement: |
          SELECT
            DATE(started_at) as day,
            COUNT(DISTINCT user_id) as unique_users
          FROM ahoy_visits
          WHERE started_at >= CURRENT_DATE - INTERVAL '30 days'
          GROUP BY 1
          ORDER BY 1

      - name: "Top Pages (Last 7 Days)"
        statement: |
          SELECT
            properties->>'page' as page,
            COUNT(*) as views
          FROM ahoy_events
          WHERE name = '$view'
            AND time >= CURRENT_DATE - INTERVAL '7 days'
          GROUP BY 1
          ORDER BY 2 DESC
          LIMIT 20

      - name: "Browser Breakdown"
        statement: |
          SELECT
            browser,
            COUNT(*) as visits
          FROM ahoy_visits
          WHERE started_at >= CURRENT_DATE - INTERVAL '30 days'
          GROUP BY 1
          ORDER BY 2 DESC

      - name: "Traffic Sources"
        statement: |
          SELECT
            COALESCE(referring_domain, 'Direct') as source,
            COUNT(*) as visits
          FROM ahoy_visits
          WHERE started_at >= CURRENT_DATE - INTERVAL '30 days'
          GROUP BY 1
          ORDER BY 2 DESC
          LIMIT 20
    YAML

    # Run migrations for Ahoy and Blazer
    rails_command("db:migrate")

    git add: "-A"
    git commit: "-m 'Configure Ahoy + Blazer for analytics'"
  end

  # === JAVASCRIPT/CSS LINTING (if selected) ===

  if frontend_options[:full_linting]
    # Install Node dependencies
    run "yarn add --dev prettier eslint@^8.9.0 stylelint @thoughtbot/eslint-config @thoughtbot/stylelint-config npm-run-all"

    # Prettier configuration
    create_file ".prettierrc", <<~JSON
      {
        "semi": false,
        "singleQuote": true,
        "trailingComma": "es5"
      }
    JSON

    create_file ".prettierignore", <<~TEXT
      /public/
      /vendor/
      /tmp/
      /log/
      /node_modules/
      *.min.js
      *.min.css
    TEXT

    # ESLint configuration
    create_file ".eslintrc.json", <<~JSON
      {
        "extends": ["@thoughtbot/eslint-config"],
        "parserOptions": {
          "ecmaVersion": "latest",
          "sourceType": "module"
        },
        "env": {
          "browser": true,
          "es2021": true
        }
      }
    JSON

    # Stylelint configuration
    create_file ".stylelintrc.json", <<~JSON
      {
        "extends": "@thoughtbot/stylelint-config"
      }
    JSON

    # ERB Lint configuration
    create_file ".erb-lint.yml", <<~YAML
      ---
      glob: "**/*.{html,html.erb,turbo_stream.erb}"
      linters:
        Rubocop:
          enabled: true
          rubocop_config:
            inherit_from:
              - .standard.yml
            Layout/InitialIndentation:
              Enabled: false
            Layout/TrailingEmptyLines:
              Enabled: false
            Layout/TrailingWhitespace:
              Enabled: false
            Naming/FileName:
              Enabled: false
            Style/FrozenStringLiteralComment:
              Enabled: false
            Lint/UselessAssignment:
              Enabled: false
        RequireInputAutocomplete:
          enabled: true
    YAML

    # Update package.json scripts
    if File.exist?("package.json")
      content = File.read("package.json")
      json = JSON.parse(content)
      json["scripts"] ||= {}
      json["scripts"]["lint"] = "run-p lint:eslint lint:stylelint lint:prettier"
      json["scripts"]["lint:eslint"] = "eslint --max-warnings=0 --no-error-on-unmatched-pattern 'app/javascript/**/*.js'"
      json["scripts"]["lint:stylelint"] = "stylelint 'app/assets/stylesheets/**/*.css'"
      json["scripts"]["lint:prettier"] = "prettier --check 'app/**/*.{js,css,scss,json}'"
      json["scripts"]["fix:prettier"] = "prettier --write 'app/**/*.{js,css,scss,json}'"

      File.open("package.json", "w") do |f|
        f.write(JSON.pretty_generate(json))
      end
    end

    git add: "-A"
    git commit: "-m 'Configure JavaScript/CSS linting'"
  end

  # === BOOTSTRAP OVERRIDES (if selected) ===

  if frontend_options[:bootstrap_overrides]
    require 'net/http'
    require 'uri'

    # Download the latest Bootstrap variables from GitHub
    bootstrap_vars_url = "https://raw.githubusercontent.com/twbs/bootstrap/main/scss/_variables.scss"

    begin
      say "Downloading Bootstrap variables from GitHub...", :cyan
      uri = URI.parse(bootstrap_vars_url)
      response = Net::HTTP.get_response(uri)

      if response.code == "200"
        # Process the content to comment out variable declarations
        output_lines = []
        output_lines << "// Bootstrap Overrides"
        output_lines << "// Uncomment and modify any variables below to customize Bootstrap's appearance"
        output_lines << "// Source: #{bootstrap_vars_url}"
        output_lines << ""
        output_lines << "// This file is imported BEFORE Bootstrap in application.bootstrap.scss:"
        output_lines << "// @import 'bootstrap-overrides';"
        output_lines << "// @import 'bootstrap/scss/bootstrap';"
        output_lines << ""
        output_lines << "// ============================================"
        output_lines << ""

        response.body.each_line do |line|
          # Keep empty lines
          if line.strip.empty?
            output_lines << ""
          # Keep existing comments as-is
          elsif line.strip.start_with?('//')
            output_lines << line.rstrip
          # Comment out variable declarations
          elsif line.include?('$') && line.include?(':')
            # Remove !default and comment out the line
            clean_line = line.rstrip.gsub(' !default', '')
            output_lines << "// #{clean_line}"
          # Keep other lines (like scss-docs markers) as comments
          else
            output_lines << "// #{line.rstrip}" unless line.strip.empty?
          end
        end

        variables_content = output_lines.join("\n") + "\n"
        create_file "app/assets/stylesheets/_bootstrap-overrides.scss", variables_content

        # Update application.bootstrap.scss to import the overrides
        gsub_file "app/assets/stylesheets/application.bootstrap.scss",
          "@import 'bootstrap/scss/bootstrap';",
          "@import 'bootstrap-overrides';\n@import 'bootstrap/scss/bootstrap';"

        git add: "-A"
        git commit: "-m 'Add Bootstrap overrides file for customization'"
      else
        say "Warning: Could not download Bootstrap variables (HTTP #{response.code}). Skipping...", :yellow
      end
    rescue => e
      say "Warning: Error downloading Bootstrap variables: #{e.message}. Skipping...", :yellow
    end
  end

  # === DOTENV CONFIGURATION ===

  # Generate secure passwords upfront if needed
  blazer_password = nil
  if analytics_options[:ahoy_blazer]
    require 'securerandom'
    blazer_password = SecureRandom.alphanumeric(16)
  end

  # Build .env.example content with error monitoring if configured
  env_example_content = <<~ENV
    # Database
    DATABASE_URL=postgresql://localhost/#{app_name}_development

    # Redis (if needed for Action Cable, caching, etc)
    # REDIS_URL=redis://localhost:6379/1

    # AWS (if using Active Storage)
    # AWS_ACCESS_KEY_ID=
    # AWS_SECRET_ACCESS_KEY=
    # AWS_REGION=
    # AWS_BUCKET=

    # Email (if using SMTP)
    # SMTP_ADDRESS=
    # SMTP_PORT=
    # SMTP_USERNAME=
    # SMTP_PASSWORD=

    # Application
    # SECRET_KEY_BASE=
    # RAILS_MASTER_KEY=
  ENV

  # Add error monitoring configuration
  case monitoring_options[:error_service]
  when "rollbar"
    env_example_content += <<~ENV

      # Rollbar Error Tracking
      ROLLBAR_ACCESS_TOKEN=your_rollbar_post_server_item_token_here
    ENV
  when "honeybadger"
    env_example_content += <<~ENV

      # Honeybadger Error Tracking
      HONEYBADGER_API_KEY=your_honeybadger_api_key_here
    ENV
  end

  # Add Skylight configuration
  if performance_options[:skylight]
    env_example_content += <<~ENV

      # Skylight Performance Monitoring
      SKYLIGHT_AUTHENTICATION=your_skylight_authentication_token_here
    ENV
  end

  # Add Blazer configuration
  if analytics_options[:ahoy_blazer]
    env_example_content += <<~ENV

      # Blazer Analytics Dashboard
      # Use your app's database URL (read-only user recommended for production)
      BLAZER_DATABASE_URL=#{ENV.fetch('DATABASE_URL', "postgresql://localhost/#{app_name}_development")}

      # Basic authentication for Blazer dashboard
      # Auto-generated secure password - save this somewhere safe!
      BLAZER_USERNAME=admin
      BLAZER_PASSWORD=#{blazer_password}
    ENV
  end

  create_file ".env.example", env_example_content

  create_file ".env"

  append_to_file ".gitignore", <<~TEXT

    # Ignore dotenv files
    .env*
    !.env.example
  TEXT

  git add: "-A"
  git commit: "-m 'Configure dotenv'"

  # === ANNOTATERB CONFIGURATION ===

  create_file ".annotaterb.yml", <<~YAML
    ---
    :position: before
    :position_in_class: before
    :position_in_factory: before
    :position_in_fixture: before
    :position_in_test: before
    :position_in_routes: before
    :position_in_serializer: before
    :show_complete_foreign_keys: false
    :show_foreign_keys: true
    :show_indexes: true
    :simple_indexes: false
    :model_dir: app/models
    :root_dir: ''
    :include_version: false
    :require: []
    :exclude_controllers: true
    :exclude_helpers: true
    :exclude_sti_subclasses: false
    :ignore_model_sub_dir: false
    :ignore_unknown_models: false
    :hide_limit_column_types: 'integer,bigint,boolean'
    :hide_default_column_types: 'json,jsonb,hstore'
    :skip_on_db_migrate: false
    :format_bare: true
    :format_rdoc: false
    :format_yard: false
    :format_markdown: false
    :sort_columns: false
    :force: false
    :frozen: false
    :classified_sort: true
    :trace: false
    :wrapper: false
    :with_comment: true
  YAML

  # Auto-annotate models after migrations
  create_file "lib/tasks/auto_annotate_models.rake", <<~RUBY
    # Automatically run AnnotateRb after migrations in development
    # Configuration is in .annotaterb.yml

    if Rails.env.development?
      # Hook into db:migrate to auto-annotate models
      Rake::Task['db:migrate'].enhance do
        puts 'Annotating models...'
        system 'bundle exec annotaterb models'
      end

      # Hook into db:rollback to update annotations
      Rake::Task['db:rollback'].enhance do
        puts 'Annotating models...'
        system 'bundle exec annotaterb models'
      end

      # Hook into db:schema:load to annotate
      Rake::Task['db:schema:load'].enhance do
        puts 'Annotating models...'
        system 'bundle exec annotaterb models'
      end
    end
  RUBY

  git add: "-A"
  git commit: "-m 'Configure AnnotateRb with auto-annotation'"

  # === RAILS ERD CONFIGURATION (if selected) ===

  if doc_options[:rails_erd]
    generate("erd:install")

    create_file ".erdconfig", <<~YAML
      attributes:
        - content
        - foreign_key
        - inheritance
      disconnected: true
      filename: erd
      filetype: png
      indirect: true
      inheritance: false
      markup: true
      notation: bachman
      orientation: vertical
      polymorphism: false
      sort: true
      warn: false
      title: false
      exclude: ActiveRecord::InternalMetadata,ActiveRecord::SchemaMigration,ActiveStorage::Attachment,ActiveStorage::Blob,AdminUser,ActiveAdmin::Comment,primary::SchemaMigration
      only: null
      only_recursion_depth: null
      prepend_primary: false
      cluster: false
      splines: spline
    YAML

    git add: "-A"
    git commit: "-m 'Configure Rails ERD'"
  end

  # === BULLET CONFIGURATION ===

  bullet_config = <<-RUBY
    # Bullet configuration for N+1 query detection
    Bullet.enable = true
    Bullet.rails_logger = true  # Log to server log
    Bullet.add_footer = true    # Display in HTML footer
    Bullet.console = true       # Log to browser console

    # Disable unused eager loading detection to avoid conflicts with Goldiloader
    # Goldiloader automatically eager loads associations, which Bullet may see as "unused"
    Bullet.unused_eager_loading_enable = false

    # Keep N+1 detection active - this is the main benefit
    Bullet.n_plus_one_query_enable = true

    # Optional: Counter cache suggestions
    Bullet.counter_cache_enable = true

  RUBY

  # Add Bullet configuration to both development and test environments
  insert_into_file "config/environments/development.rb",
    bullet_config,
    after: "Rails.application.configure do\n"

  insert_into_file "config/environments/test.rb",
    bullet_config,
    after: "Rails.application.configure do\n"

  git add: "-A"
  git commit: "-m 'Configure Bullet for N+1 detection in dev and test'"

  # === PRODUCTION CONFIGURATION ===

  # Force SSL in production (handle both commented and uncommented states)
  production_file = "config/environments/production.rb"
  production_content = File.read(production_file)

  # Only uncomment if it's actually commented
  if production_content.match?(/^\s*#\s*config.force_ssl = true/)
    uncomment_lines production_file, /config.force_ssl = true/
  end

  # Configure production logging (check if not already configured)
  unless production_content.include?("config.log_tags")
    gsub_file production_file,
      /config.log_formatter = ::Logger::Formatter.new/,
      "config.log_formatter = ::Logger::Formatter.new\n  config.log_tags = [:request_id]"
  end

  # Only commit if there are changes
  if !`git status --porcelain`.empty?
    git add: "-A"
    git commit: "-m 'Configure production environment'"
  end

  # === PROJECT DOCUMENTATION ===

  # Build dynamic sections based on configuration
  testing_section = testing_options[:simplecov] ? "\n    With coverage:\n    ```bash\n    COVERAGE=true bundle exec rspec\n    ```" : ""

  linting_section = frontend_options[:full_linting] ? "\n    JavaScript/CSS linting:\n    ```bash\n    yarn lint\n    yarn fix:prettier\n    ```\n    \n    ERB linting:\n    ```bash\n    bundle exec erb_lint --lint-all\n    bundle exec erb_lint --lint-all --autocorrect\n    ```" : ""

  error_monitoring_section = case monitoring_options[:error_service]
  when "rollbar"
    "\n    ## Error Monitoring\n    \n    This app uses Rollbar for error tracking. Set your access token:\n    ```bash\n    ROLLBAR_ACCESS_TOKEN=your_token_here\n    ```\n    \n    Visit [rollbar.com](https://rollbar.com) to sign up and get your access token."
  when "honeybadger"
    "\n    ## Error Monitoring\n    \n    This app uses Honeybadger for error tracking. Set your API key:\n    ```bash\n    HONEYBADGER_API_KEY=your_key_here\n    ```\n    \n    Visit [honeybadger.io](https://honeybadger.io) to sign up and get your API key."
  else
    ""
  end

  performance_monitoring_section = performance_options[:skylight] ? "\n    ## Performance Monitoring\n    \n    This app uses Skylight for performance monitoring. Set your authentication token:\n    ```bash\n    SKYLIGHT_AUTHENTICATION=your_token_here\n    ```\n    \n    Visit [skylight.io](https://skylight.io) to sign up and get your authentication token." : ""

  analytics_section = analytics_options[:ahoy_blazer] ? "\n    ## Analytics\n    \n    This app uses Ahoy for tracking and Blazer for analytics dashboards.\n    \n    - View analytics dashboard: `/analytics`\n    - **Authentication:** Check `.env` file for auto-generated credentials\n    - **Username:** `admin`\n    - **Password:** Unique 16-character password in `.env` file\n    - Track custom events in JavaScript:\n      ```javascript\n      ahoy.track(\"Event Name\", {property: \"value\"});\n      ```\n    - Track events in Ruby:\n      ```ruby\n      ahoy.track \"Event Name\", property: \"value\"\n      ```\n    \n    Sample queries are available in `db/blazer_queries.yml`.\n    \n    ### Securing Blazer in Production\n    \n    The dashboard uses basic authentication with a unique auto-generated password.\n    For production, you can:\n    1. Keep the strong auto-generated password\n    2. Use your app's authentication (e.g., Devise) instead\n    3. Create a read-only database user for Blazer\n    4. Restrict access by IP or VPN" : ""

  render_deployment_section = if render_options[:enabled]
    worker_info = render_options[:separate_worker] ?
      "Background jobs run in a separate worker service for better resource isolation." :
      "Background jobs run in the web process using the Puma plugin (simpler setup, shared resources)."

    "\n    ## Deployment to Render.com\n    \n    This app is configured for easy deployment to Render.com.\n    \n    ### Quick Deploy\n    \n    1. Push your code to GitHub\n    2. Connect your repository to Render\n    3. Render will automatically detect the `render.yaml` blueprint\n    4. Set the `RAILS_MASTER_KEY` environment variable in the Render dashboard:\n       - Find your key in `config/master.key`\n       - Add it as an environment variable (not synced from the blueprint)\n    \n    ### What's Configured\n    \n    - **Build script**: `bin/render-build.sh` handles dependencies, migrations, and assets\n    - **Database**: PostgreSQL database automatically provisioned\n    - **Health checks**: Rails 8's `/up` endpoint for monitoring\n    - **Concurrency**: `WEB_CONCURRENCY=2` to prevent memory issues\n    - **Background jobs**: #{worker_info}\n    \n    ### Manual Deployment\n    \n    If you prefer manual setup instead of the blueprint:\n    \n    1. Create a new Web Service on Render\n    2. Connect your repository\n    3. Set Build Command: `./bin/render-build.sh`\n    4. Set Start Command: `bundle exec puma -C config/puma.rb`\n    5. Add PostgreSQL database\n    6. Set environment variables:\n       - `DATABASE_URL` (from database)\n       - `RAILS_MASTER_KEY` (from config/master.key)\n       - `WEB_CONCURRENCY=2`\n    #{render_options[:separate_worker] ? "\n    7. Create a Background Worker service:\n       - Build Command: `bundle install`\n       - Start Command: `bundle exec rake solid_queue:start`\n       - Add same `DATABASE_URL` and `RAILS_MASTER_KEY`" : ""}\n    \n    Learn more: [Render Rails 8 Deployment Guide](https://render.com/docs/deploy-rails-8)"
  else
    ""
  end

  doc_commands = []
  doc_commands << "- Generate ERD: `bundle exec erd`" if doc_options[:rails_erd]
  doc_commands << "- Annotate models: `bundle exec annotaterb models`"
  doc_commands << "- View database: Visit `/rails_db` in development" if doc_options[:rails_db]

  security_commands = []
  security_commands << "bundle exec bundle-audit check" if security_options[:bundler_audit]

  # Rails 8+ includes brakeman by default, so we can always use it
  security_commands.unshift("bundle exec brakeman")

  # README (overwrite the default Rails README)
  remove_file "README.md"
  create_file "README.md", <<~MARKDOWN
    # #{app_name.humanize}

    ## Requirements

    - Ruby #{RUBY_VERSION}
    - PostgreSQL
    - Node.js >= 20.0.0
    - Yarn

    ## Setup

    1. Clone the repository
    2. Install dependencies:
       ```bash
       bundle install
       yarn install
       ```

    3. Setup database:
       ```bash
       rails db:create
       rails db:migrate
       rails db:seed
       ```

    4. Copy environment variables:
       ```bash
       cp .env.example .env
       ```
       Edit `.env` with your configuration

    ## Development

    Start the development server:
    ```bash
    bin/dev
    ```

    ## Testing

    Run the test suite:
    ```bash
    bundle exec rspec
    ```#{testing_section}

    ## Code Quality

    Ruby linting:
    ```bash
    bundle exec standardrb
    bundle exec standardrb --fix
    ```

    HTML+ERB analysis:
    ```bash
    bundle exec herb analyze .
    bundle exec herb parse app/views/path/to/file.html.erb
    ```#{linting_section}

    Security scanning:
    ```bash
    #{security_commands.join("\n")}
    ```

    ## Performance & N+1 Prevention

    This app uses a two-pronged approach to prevent N+1 queries:

    ### Goldiloader (Prevention)
    #{"Automatically eager loads associations when accessed to prevent N+1 queries from occurring." if performance_options[:goldiloader]}
    #{"- Works in all environments (development, test, production)" if performance_options[:goldiloader]}
    #{"- Disable for specific associations: `has_many :posts, -> { auto_include(false) }`" if performance_options[:goldiloader]}
    #{"- Disable for code blocks: `Goldiloader.disabled { ... }`" if performance_options[:goldiloader]}
    #{"Not included - enable in template options to automatically prevent N+1 queries." unless performance_options[:goldiloader]}

    ### Bullet (Detection)
    - Detects N+1 queries and suggests fixes in development and test
    - Logs to server console and displays in HTML footer
    - Unused eager loading detection is disabled to work well with Goldiloader
    - View N+1 warnings in:
      - Browser footer (development only)
      - Rails server log
      - Browser console

    ## Background Jobs

    This app uses Solid Queue (Rails 8 default) for background job processing.

    ## Documentation

    #{doc_commands.join("\n")}
#{error_monitoring_section}#{performance_monitoring_section}#{analytics_section}#{render_deployment_section}
  MARKDOWN

  # CONTRIBUTING.md
  create_file "CONTRIBUTING.md", <<~MARKDOWN
    # Contributing

    ## Getting Started

    1. Fork the repository
    2. Create a feature branch (`git checkout -b feature/amazing-feature`)
    3. Make your changes
    4. Run tests and linters
    5. Commit your changes
    6. Push to the branch
    7. Open a Pull Request

    ## Code Style

    - Ruby: StandardRB
    - HTML+ERB: Herb
    #{"- JavaScript: ESLint with Thoughtbot config\n    - CSS: Stylelint with Thoughtbot config\n    - ERB: erb_lint" if frontend_options[:full_linting]}

    ## Testing

    - Write tests for all new features
    #{"- Maintain test coverage above 80%" if testing_options[:simplecov]}
    - Use factories instead of fixtures
    - Follow RSpec best practices

    ## Commit Messages

    - Use present tense
    - Use imperative mood
    - Limit first line to 50 characters
    - Reference issues and pull requests
  MARKDOWN

  # Create version files using current system versions
  create_file ".ruby-version", "#{RUBY_VERSION}\n"

  # Only create .node-version if Node is installed and we're using a JS bundler
  if system("which node > /dev/null 2>&1")
    node_version = `node --version`.strip.delete('v')
    create_file ".node-version", "#{node_version}\n"
  else
    # Fallback to LTS version if Node isn't installed but might be needed
    create_file ".node-version", "20.0.0\n"
  end

  git add: "-A"
  git commit: "-m 'Add project documentation files'"

  # === FINAL CLEANUP ===

  # Run StandardRB to fix formatting issues
  say "\nRunning StandardRB to fix code formatting...", :cyan

  # Run StandardRB with both safe and unsafe fixes
  system("bundle exec standardrb --fix")
  system("bundle exec standardrb --fix-unsafely")

  # Check if there are still violations
  violations_output = `bundle exec standardrb 2>&1`
  violations_remain = !$?.success?

  if violations_remain
    say "\n⚠️  Some StandardRB violations could not be auto-fixed:", :yellow
    say violations_output.lines.grep(/^\s+\w+/).take(10).join, :yellow
    say "Run 'bundle exec standardrb' after setup to see all remaining issues.", :yellow
  else
    say "✅ All StandardRB violations have been fixed!", :green
  end

  # Commit formatting changes if any
  if !`git status --porcelain`.empty?
    git add: "-A"
    git commit: "-m 'Apply StandardRB formatting'"
  end

  # === SUCCESS MESSAGE ===

  say "\n🎉 Rails app successfully created!", :green

  if customize
    say "\n=== Your Custom Configuration ===", :yellow

    say "\nTesting Tools:", :cyan
    say "  ✅ RSpec & FactoryBot (always included)"
    say "  #{testing_options[:simplecov] ? '✅' : '❌'} SimpleCov"
    say "  #{testing_options[:shoulda] ? '✅' : '❌'} Shoulda Matchers"
    say "  #{testing_options[:faker] ? '✅' : '❌'} Faker"
    say "  #{testing_options[:webmock] ? '✅' : '❌'} WebMock"

    say "\nPerformance Tools:", :cyan
    say "  ✅ Bullet - N+1 detection (always included in dev/test)"
    say "  #{performance_options[:goldiloader] ? '✅' : '❌'} Goldiloader - Automatic N+1 prevention (all environments)"
    say "  #{performance_options[:rack_profiler] ? '✅' : '❌'} rack-mini-profiler - Development performance bar"
    say "  #{performance_options[:skylight] ? '✅' : '❌'} Skylight - Production monitoring"

    say "\nAnalytics:", :cyan
    say "  #{analytics_options[:ahoy_blazer] ? '✅' : '❌'} Ahoy + Blazer"

    say "\nDocumentation Tools:", :cyan
    say "  ✅ AnnotateRb (always included)"
    say "  #{doc_options[:rails_erd] ? '✅' : '❌'} Rails ERD"
    say "  #{doc_options[:rails_db] ? '✅' : '❌'} rails_db"

    say "\nSecurity & Safety:", :cyan
    say "  #{security_options[:bundler_audit] ? '✅' : '❌'} bundler-audit"

    say "\nError Monitoring:", :cyan
    case monitoring_options[:error_service]
    when "rollbar"
      say "  ✅ Rollbar"
    when "honeybadger"
      say "  ✅ Honeybadger"
    else
      say "  ❌ None"
    end

    say "\nFrontend Tools:", :cyan
    say "  #{frontend_options[:bootstrap_overrides] ? '✅' : '❌'} Bootstrap overrides file"
    say "  #{frontend_options[:full_linting] ? '✅' : '❌'} Full JS/CSS/ERB linting stack"

    say "\nDatabase Configuration:", :cyan
    say "  #{db_options[:use_uuid] ? '✅' : '❌'} UUID primary keys"
    say "  #{db_options[:multi_database] ? '✅' : '❌'} Rails 8 multi-database setup (separate DBs for cache/queue/cable)"

    say "\nDeployment:", :cyan
    say "  #{render_options[:enabled] ? '✅' : '❌'} Render.com configuration (build script + render.yaml)"
    if render_options[:enabled]
      say "    • Background jobs: #{render_options[:separate_worker] ? 'Separate worker service' : 'Puma plugin (runs in web process)'}"
    end

    say "\nCode Quality:", :cyan
    say "  ✅ StandardRB (always included)"
    say "  ✅ Herb (always included)"
  else
    say "\n✅ Applied default configuration with sensible choices!", :green
  end

  say "\nNext steps:", :yellow
  say "  1. cd #{app_name}"
  say "  2. Review and edit .env file"
  say "  3. Run: bin/dev"

  # Display Blazer credentials if analytics was configured
  if analytics_options[:ahoy_blazer] && blazer_password
    say "\n⚠️  IMPORTANT - Blazer Analytics Credentials:", :red
    say "  Dashboard URL: /analytics", :cyan
    say "  Username: admin", :cyan
    say "  Password: #{blazer_password}", :cyan
    say "  (These credentials are also saved in your .env file)", :yellow
  end

  say "\n"
end
