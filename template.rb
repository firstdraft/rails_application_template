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
say "  ✅ Rollbar - Error tracking (default choice)"
say "  ✅ Bootstrap overrides - Custom Sass variables file"
say "  ❌ Full JS/CSS linting - Prettier, ESLint, Stylelint (not needed for all apps)"
say "  ❌ UUID primary keys - Use UUIDs instead of integers (UUIDv7 default when enabled)"
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
  if db_options[:use_uuid]
    say "  UUID version:", :cyan
    say "    1. UUID v7 (default, time-ordered)"
    say "    2. UUID v4 (random)"
    uuid_choice = ask("    Enter choice (1-2):", limited_to: %w[1 2], default: "1")
    db_options[:uuid_version] = (uuid_choice == "1") ? :v7 : :v4
  else
    # Irrelevant unless UUIDs are enabled, but keeping a stable default simplifies downstream conditionals.
    db_options[:uuid_version] = :v7
  end
  db_options[:multi_database] = yes?("  Use Rails 8 multi-database setup (separate DBs for cache/queue/cable)? (y/n)")

  # Deployment configuration
  render_options = {}
  say "\nDeployment:", :yellow
  render_options[:enabled] = yes?("  Configure for Render.com deployment (build script + render.yaml)? (y/n)")
  if render_options[:enabled]
    say "\n  Render.com Plan:", :cyan
    say "    1. Free tier (512MB RAM - good for demos, small apps)"
    say "    2. Starter/Paid tier (more resources, better performance)"
    tier_choice = ask("    Select tier (1-2):", limited_to: %w[1 2], default: "1")
    render_options[:free_tier] = (tier_choice == "1")

    say "\n  Database Provider:", :cyan
    if render_options[:free_tier]
      say "    → Using Supabase (recommended for free tier - no 90-day expiration)", :green
      render_options[:database_provider] = "supabase"
    else
      say "    1. Render Postgres (integrated, simpler setup)"
      say "    2. Supabase (more features: real-time, auth, storage, generous free tier)"
      db_choice = ask("    Select option (1-2):", limited_to: %w[1 2], default: "1")
      render_options[:database_provider] = (db_choice == "1") ? "render" : "supabase"
    end

    say "\n  Background Jobs:", :cyan
    say "    1. Run in web process (simpler, shares memory - recommended for free tier)"
    say "    2. Separate worker service (isolated resources, costs more on paid tier)"
    job_choice = ask("    Select option (1-2):", limited_to: %w[1 2], default: "1")
    render_options[:separate_worker] = (job_choice == "2")

    say "\n  Custom Domain:", :cyan
    if yes?("    Do you know your production domain? (y/n)")
      render_options[:domain] = ask("    Enter domain (e.g., myapp.com):")
      render_options[:include_www] = yes?("    Also configure www.#{render_options[:domain]}? (y/n)")
    else
      render_options[:domain] = nil
      render_options[:include_www] = false
    end
  else
    render_options[:separate_worker] = false
    render_options[:free_tier] = true
    render_options[:database_provider] = "supabase"
    render_options[:domain] = nil
    render_options[:include_www] = false
  end

  # CI/CD configuration
  ci_options = {}
  say "\nCI/CD:", :yellow
  ci_options[:github_actions] = yes?("  Include GitHub Actions CI workflow? (y/n)")
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

  monitoring_options = {
    error_service: "rollbar"
  }

  frontend_options = {
    bootstrap_overrides: true,
    full_linting: false
  }

  db_options = {
    use_uuid: false,
    uuid_version: :v7,
    multi_database: false
  }

  render_options = {
    enabled: false,
    separate_worker: false,
    free_tier: true,
    database_provider: "supabase",
    domain: nil,
    include_www: false
  }

  ci_options = {
    github_actions: true
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
  # Rails uses IRB by default; `debug` is the modern Ruby debugger. `pry` is an optional enhanced REPL.
  unless File.read("Gemfile").match?(/^\s*gem\s+["']debug["']/)
    gem "debug", platforms: %i[mri mingw x64_mingw]
  end

  unless File.read("Gemfile").match?(/^\s*gem\s+["']pry["']/)
    gem "pry"
  end
  # Temporarily disabled: not Ruby 4-ready (re-enable when compatible)
  # gem "better_errors"
  # gem "binding_of_caller"
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

  # Security scanning (used in README + CI)
  unless File.read("Gemfile").match?(/^\s*gem\s+["']bundler-audit["']/)
    gem "bundler-audit", require: false
  end

  # N+1 Query Detection (always included in dev/test)
  gem "bullet"

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


end

# Keep the generated Gemfile clean and under our control.
# The default Rails Gemfile (and some generators) include lots of commentary; strip it out.
def strip_comments_from_gemfile!(path = "Gemfile")
  lines = File.read(path).each_line.map do |line|
    out = +""
    in_single = false
    in_double = false
    escaped = false

    line.each_char do |ch|
      if escaped
        out << ch
        escaped = false
        next
      end

      if (in_single || in_double) && ch == "\\"
        out << ch
        escaped = true
        next
      end

      if !in_double && ch == "'"
        in_single = !in_single
        out << ch
        next
      end

      if !in_single && ch == "\""
        in_double = !in_double
        out << ch
        next
      end

      break if ch == "#" && !in_single && !in_double

      out << ch
    end

    out = out.rstrip
    out.strip.empty? ? "" : out
  end

  # Trim leading/trailing blank lines and collapse consecutive blanks.
  lines.shift while lines.first == ""
  lines.pop while lines.last == ""

  collapsed = []
  lines.each do |line|
    next if line == "" && collapsed.last == ""
    collapsed << line
  end

  File.write(path, collapsed.join("\n") + "\n")
end

strip_comments_from_gemfile!

# === AFTER BUNDLE ACTIONS ===

after_bundle do
  # Initial database setup
  rails_command("db:create")

  git add: "-A"
  git commit: "-m 'Initial Rails app with custom template'"

  # === DATABASE CONFIGURATION ===

  unless db_options[:multi_database]
    say "Configuring single database for all environments (cache/queue/cable share primary DB)...", :cyan

    # Use traditional single-database format for database.yml
    remove_file "config/database.yml"

    create_file "config/database.yml", <<~YAML
      # PostgreSQL 18+ is required (this template assumes Postgres 18 features when UUIDs are enabled).
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

    # Remove multi-database references from Solid Cache config
    if File.exist?("config/cache.yml")
      gsub_file "config/cache.yml",
        /^\s*database: cache\n/,
        ""
    end

    # Remove multi-database references from Solid Cable config
    if File.exist?("config/cable.yml")
      gsub_file "config/cable.yml",
        /\s*connects_to:\n\s*database:\n\s*writing: cable\n/,
        "\n"
    end

    # Remove multi-database references from production environment
    gsub_file "config/environments/production.rb",
      /\s*config\.solid_queue\.connects_to = \{ database: \{ writing: :queue \} \}\n/,
      "\n"

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
    git commit: "-m 'Configure single database (cache/queue/cable share primary DB)'"
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

  # === SOLID QUEUE DEVELOPMENT CONFIGURATION ===

  # Add SolidQueue worker to Procfile.dev if it exists (for apps using bin/dev with asset compilation)
  if File.exist?("Procfile.dev")
    say "Adding SolidQueue worker to Procfile.dev...", :cyan
    append_file "Procfile.dev", "jobs: bundle exec rake solid_queue:start\n"

    # Configure development environment to use SolidQueue
    inject_into_file "config/environments/development.rb",
      before: "end\n" do
      <<-RUBY

  # Use SolidQueue for background jobs in development
  # This matches production behavior and helps catch job-related issues early
  config.active_job.queue_adapter = :solid_queue
      RUBY
    end

    git add: "-A"
    git commit: "-m 'Configure SolidQueue for development with Procfile.dev'"
  end

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
    require "yaml"

    say "Configuring for Render.com deployment...", :cyan

    # Determine settings based on tier
    web_concurrency = render_options[:free_tier] ? 0 : 2
    db_plan = render_options[:free_tier] ? "free" : "starter"
    service_plan = render_options[:free_tier] ? "free" : "starter"
    using_supabase = render_options[:database_provider] == "supabase"

    # Create bin/render-build.sh (NO db:migrate - that goes in preDeployCommand)
    create_file "bin/render-build.sh", <<~BASH
      #!/usr/bin/env bash
      # exit on error
      set -o errexit

      bundle install
      bundle exec rake assets:precompile
      bundle exec rake assets:clean
    BASH

    # Make script executable
    chmod "bin/render-build.sh", 0755

    # Build render.yaml programmatically to avoid indentation bugs
    render_config = {"services" => []}

    # Only add Render Postgres if not using Supabase
    unless using_supabase
      render_config["databases"] = [
        {
          "name" => "#{app_name}-db",
          "databaseName" => "#{app_name}_production",
          "user" => app_name,
          "plan" => db_plan
        }
      ]
    end

    # Web service configuration
    web_service = {
      "type" => "web",
      "name" => "#{app_name}-web",
      "runtime" => "ruby",
      "plan" => service_plan,
      "buildCommand" => "./bin/render-build.sh",
      "preDeployCommand" => "bundle exec rake db:migrate",
      "startCommand" => "bundle exec puma -C config/puma.rb",
      "healthCheckPath" => "/up",
      "envVars" => []
    }

    # Database URL configuration depends on provider
    if using_supabase
      # Supabase: DATABASE_URL must be entered manually in Render dashboard
      web_service["envVars"] << {"key" => "DATABASE_URL", "sync" => false}
    else
      # Render Postgres: auto-link to provisioned database
      web_service["envVars"] << {
        "key" => "DATABASE_URL",
        "fromDatabase" => {
          "name" => "#{app_name}-db",
          "property" => "connectionString"
        }
      }
    end

    # Add remaining env vars
    web_service["envVars"] << {"key" => "RAILS_MASTER_KEY", "sync" => false}
    web_service["envVars"] << {"key" => "WEB_CONCURRENCY", "value" => web_concurrency.to_s}
    web_service["envVars"] << {"key" => "NODE_ENV", "value" => "production"}

    # Add SOLID_QUEUE_IN_PUMA env var if not using separate worker
    unless render_options[:separate_worker]
      web_service["envVars"] << {"key" => "SOLID_QUEUE_IN_PUMA", "value" => "true"}
    end

    # Add custom domain if specified
    if render_options[:domain]
      domains = [render_options[:domain]]
      domains << "www.#{render_options[:domain]}" if render_options[:include_www]
      web_service["domains"] = domains
    end

    render_config["services"] << web_service

    # Add worker service if separate_worker is enabled
    if render_options[:separate_worker]
      worker_service = {
        "type" => "worker",
        "name" => "#{app_name}-worker",
        "runtime" => "ruby",
        "plan" => service_plan,
        "buildCommand" => "bundle install",
        "startCommand" => "bundle exec rake solid_queue:start",
        "envVars" => []
      }

      # Database URL for worker
      if using_supabase
        worker_service["envVars"] << {"key" => "DATABASE_URL", "sync" => false}
      else
        worker_service["envVars"] << {
          "key" => "DATABASE_URL",
          "fromDatabase" => {
            "name" => "#{app_name}-db",
            "property" => "connectionString"
          }
        }
      end

      worker_service["envVars"] << {"key" => "RAILS_MASTER_KEY", "sync" => false}
      render_config["services"] << worker_service
    end

    # Generate YAML and validate it
    render_yaml_content = render_config.to_yaml

    # Validate YAML before writing
    begin
      YAML.safe_load(render_yaml_content)
    rescue Psych::SyntaxError => e
      say "ERROR: Generated render.yaml is invalid: #{e.message}", :red
      raise "Invalid YAML generated for render.yaml"
    end

    create_file "render.yaml", render_yaml_content

    # Configure Puma plugin for Solid Queue if not using separate worker
    unless render_options[:separate_worker]
      # Check if puma.rb already has the solid_queue plugin to avoid duplication
      puma_content = File.read("config/puma.rb")
      unless puma_content.include?("plugin :solid_queue")
        append_to_file "config/puma.rb", <<~RUBY

          # Run Solid Queue in Puma process (controlled by SOLID_QUEUE_IN_PUMA env var)
          # This is used for Render.com deployments without a separate worker service
          plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]
        RUBY
      end

      # Silence polling in development
      inject_into_file "config/environments/development.rb",
        "  # Silence Solid Queue polling logs in development\n  config.solid_queue.silence_polling = true\n\n",
        after: "Rails.application.configure do\n"
    end

    # Move esbuild to dependencies (not devDependencies) for production builds
    if File.exist?("package.json")
      package_json = JSON.parse(File.read("package.json"))
      if package_json.dig("devDependencies", "esbuild")
        esbuild_version = package_json["devDependencies"].delete("esbuild")
        package_json["dependencies"] ||= {}
        package_json["dependencies"]["esbuild"] = esbuild_version
        File.write("package.json", JSON.pretty_generate(package_json) + "\n")
        say "Moved esbuild to dependencies for production builds", :green
      end
    end

    # Generate deployment checklist
    checklist_content = <<~MARKDOWN
      # Render.com Deployment Checklist for #{app_name.humanize}

      ## Before First Deploy

      - [ ] Push code to GitHub/GitLab
      - [ ] Create Render account at https://render.com
    MARKDOWN

    if using_supabase
      checklist_content += <<~MARKDOWN
        - [ ] Create Supabase account and project at https://supabase.com
        - [ ] Get your database connection string (see Supabase Setup below)
      MARKDOWN
    end

    checklist_content += <<~MARKDOWN
      - [ ] Connect your repository to Render (Render will auto-detect render.yaml)

      ## Environment Variables (set in Render Dashboard)

      The following must be set manually in the Render Dashboard:

      - [ ] `RAILS_MASTER_KEY` - Copy the contents of `config/master.key`
            (This file is gitignored for security - you must copy it manually)
    MARKDOWN

    if using_supabase
      checklist_content += <<~MARKDOWN
        - [ ] `DATABASE_URL` - Your Supabase connection string (see below)
      MARKDOWN
    end

    checklist_content += <<~MARKDOWN

      ## After Deploy

      - [ ] Verify health check passes at `/up`
      - [ ] Check service logs for any errors
      - [ ] Test your application functionality
    MARKDOWN

    if using_supabase
      checklist_content += <<~MARKDOWN

        ## Supabase Database Setup

        ### 1. Create a Supabase Project

        1. Go to https://supabase.com and sign in
        2. Click "New Project"
        3. Choose a name, password, and region (pick one close to your Render region)
        4. Wait for the project to be created (~2 minutes)

        ### 2. Get Your Connection String

        1. In your Supabase project, go to **Settings** → **Database**
        2. Scroll to **Connection string** section
        3. Select **URI** tab
        4. Copy the connection string (it looks like):
           ```
           postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres
           ```

        ### 3. Choose the Right Connection Mode

        Supabase offers two connection modes:

        | Mode | Port | Best For |
        |------|------|----------|
        | **Transaction** (recommended) | 6543 | Web apps, Rails |
        | Session | 5432 | Long-running connections |

        **Use Transaction mode (port 6543)** for Rails applications.

        ### 4. Add to Render Dashboard

        1. In Render, go to your web service → **Environment**
        2. Add `DATABASE_URL` with your Supabase connection string
        3. Replace `[YOUR-PASSWORD]` with your database password
        4. If you have a worker service, add the same `DATABASE_URL` there

        ### Important Notes

        - **Password**: Use the password you set when creating the Supabase project
        - **SSL**: Supabase requires SSL, which Rails handles automatically
        - **Free Tier**: Supabase free tier includes 500MB storage, no expiration
        - **Pooling**: Transaction pooler is already configured in the connection string
      MARKDOWN
    end

    if render_options[:domain]
      checklist_content += <<~MARKDOWN

        ## Custom Domain Setup: #{render_options[:domain]}

        Your render.yaml is pre-configured for `#{render_options[:domain]}`#{render_options[:include_www] ? " and `www.#{render_options[:domain]}`" : ""}.

        ### DNS Configuration

        Add these records at your domain registrar (e.g., Namecheap, GoDaddy, Cloudflare):

        | Type | Name | Value |
        |------|------|-------|
        | CNAME | www | #{app_name}-web.onrender.com |
        | CNAME or ALIAS | @ (root) | #{app_name}-web.onrender.com |

        **Note:** Some registrars don't support CNAME/ALIAS for root domains.
        Check Render's docs for alternative A record configuration.

        ### After DNS Configuration

        - [ ] Wait for DNS propagation (can take up to 48 hours, usually faster)
        - [ ] Verify SSL certificate is automatically provisioned by Render
        - [ ] Test both root domain and www (if configured)
      MARKDOWN
    end

    db_provider_display = using_supabase ? "Supabase (external)" : "Render Postgres (#{db_plan})"

    checklist_content += <<~MARKDOWN

      ## Configuration Summary

      | Setting | Value |
      |---------|-------|
      | Tier | #{render_options[:free_tier] ? "Free" : "Paid"} |
      | Database | #{db_provider_display} |
      | WEB_CONCURRENCY | #{web_concurrency} #{render_options[:free_tier] ? "(single process, threaded - optimized for 512MB)" : "(multiple workers)"} |
      | Background Jobs | #{render_options[:separate_worker] ? "Separate worker service" : "Puma plugin (in web process)"} |
      #{render_options[:domain] ? "| Custom Domain | #{render_options[:domain]} |" : ""}

      ## Useful Commands

      ```bash
      # View logs
      render logs --service #{app_name}-web

      # SSH into service (paid plans only)
      render ssh --service #{app_name}-web

      # Restart service
      render restart --service #{app_name}-web
      ```

      ## Troubleshooting

      ### Build Failures
      - Check that all gems install correctly
      - Verify Node.js version compatibility
      - Check asset compilation logs

      ### Migration Failures
      - Migrations run in preDeployCommand (after build, before start)
      - Check DATABASE_URL is correctly set
      - Verify database is accessible from web service

      ### Memory Issues (Free Tier)
      - Free tier has 512MB RAM limit
      - WEB_CONCURRENCY=0 uses single process with threads
      - Monitor memory usage in Render dashboard
      - Consider upgrading to paid tier for production workloads

      ## Documentation

      - [Render Rails Deployment Guide](https://render.com/docs/deploy-rails)
      - [Render Blueprint Spec](https://render.com/docs/blueprint-spec)
      - [Custom Domains on Render](https://render.com/docs/custom-domains)
    MARKDOWN

    create_file "RENDER_DEPLOYMENT.md", checklist_content

    git add: "-A"
    git commit: "-m 'Configure Render.com deployment with #{render_options[:separate_worker] ? 'separate worker service' : 'Puma plugin'}'"
  end

  # === GITHUB ACTIONS CI CONFIGURATION ===

  if ci_options[:github_actions]
    say "Configuring GitHub Actions CI...", :cyan

    create_file ".github/workflows/ci.yml", <<~YAML
      name: CI

      on:
        push:
          branches: [ "main" ]
        pull_request:
          branches: [ "main" ]

      jobs:
        test:
          runs-on: ubuntu-latest
          services:
            postgres:
              image: postgres:18
              ports:
                - 5432:5432
              env:
                POSTGRES_USER: rails
                POSTGRES_PASSWORD: password
                POSTGRES_DB: app_test
              options: >-
                --health-cmd pg_isready
                --health-interval 10s
                --health-timeout 5s
                --health-retries 5

          env:
            RAILS_ENV: test
            DATABASE_URL: postgres://rails:password@localhost:5432/app_test

          steps:
            - name: Checkout code
              uses: actions/checkout@v4

            - name: Install Ruby and gems
              uses: ruby/setup-ruby@v1
              with:
                bundler-cache: true

            - name: Set up Node
              uses: actions/setup-node@v4
              with:
                node-version-file: '.node-version'
                cache: 'yarn'

            - name: Install JavaScript dependencies
              run: yarn install

            - name: Build assets
              run: bin/rails assets:precompile

            - name: Set up database
              run: bin/rails db:test:prepare

            - name: Security Scan - Brakeman
              run: bundle exec brakeman --no-pager

            - name: Security Scan - Bundler Audit
              run: |
                if [ -x bin/bundler-audit ]; then
                  bin/bundler-audit check --update
                else
                  bundle exec bundle-audit check --update
                fi

            - name: Linting - StandardRB
              run: bundle exec standardrb

            - name: Linting - Herb
              run: bundle exec herb analyze .

            - name: Run Tests
              run: bundle exec rspec
    YAML

    git add: "-A"
    git commit: "-m 'Configure GitHub Actions CI'"
  end

  # === UUID CONFIGURATION (if selected) ===

  if db_options[:use_uuid]
    insert_into_file "config/application.rb",
      "      g.orm :active_record, primary_key_type: :uuid\n",
      after: "    config.generators do |g|\n"

    uuid_fn = (db_options[:uuid_version] == :v7) ? "uuidv7()" : "uuidv4()"
    create_file "config/initializers/uuid_primary_key_default.rb", <<~RUBY
      # frozen_string_literal: true

      # PostgreSQL 18+ has built-in UUID generators (uuidv7/uuidv4).
      # Rails defaults UUID primary keys to gen_random_uuid()/uuid_generate_v4() depending on setup;
      # this makes UUID PKs use #{uuid_fn} unless a migration explicitly sets a different default.
      ActiveSupport.on_load(:active_record) do
        next unless defined?(ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnMethods)

        module UuidPrimaryKeyDefaultFunctionForPostgres18
          def primary_key(name, type = :primary_key, **options)
            if type == :uuid && !options.key?(:default)
              options[:default] = -> { "#{uuid_fn}" }
            end
            super(name, type, **options)
          end
        end

        ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnMethods.prepend(UuidPrimaryKeyDefaultFunctionForPostgres18)
      end
    RUBY

    insert_into_file "app/models/application_record.rb",
      "\n  self.implicit_order_column = \"created_at\"\n",
      after: "  primary_abstract_class\n"

    git add: "-A"
    uuid_label = (db_options[:uuid_version] == :v7) ? "v7" : "v4"
    git commit: "-m 'Configure UUID primary keys (#{uuid_label})'"
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
      "Ahoy.api = false",
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

  # === BOOTSTRAP OVERRIDES (if selected and Bootstrap is installed) ===

  if frontend_options[:bootstrap_overrides] && File.exist?("app/assets/stylesheets/application.bootstrap.scss")
    bootstrap_overrides_content = <<~SCSS
      // Bootstrap Overrides
      // Customize Bootstrap by uncommenting and modifying variables below.
      // This file is imported BEFORE Bootstrap, so variables here override Bootstrap's defaults.
      // Full variable list: https://github.com/twbs/bootstrap/blob/main/scss/_variables.scss

      // =============================================================================
      // Colors
      // =============================================================================
      // $primary:       #0d6efd;
      // $secondary:     #6c757d;
      // $success:       #198754;
      // $info:          #0dcaf0;
      // $warning:       #ffc107;
      // $danger:        #dc3545;
      // $light:         #f8f9fa;
      // $dark:          #212529;

      // $body-bg:       #fff;
      // $body-color:    #212529;

      // =============================================================================
      // Typography
      // =============================================================================
      // $font-family-sans-serif: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", "Noto Sans", "Liberation Sans", Arial, sans-serif;
      // $font-family-monospace:  SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
      // $font-size-base:         1rem;
      // $font-size-sm:           $font-size-base * .875;
      // $font-size-lg:           $font-size-base * 1.25;
      // $font-weight-normal:     400;
      // $font-weight-bold:       700;
      // $line-height-base:       1.5;

      // $h1-font-size:           $font-size-base * 2.5;
      // $h2-font-size:           $font-size-base * 2;
      // $h3-font-size:           $font-size-base * 1.75;
      // $h4-font-size:           $font-size-base * 1.5;
      // $h5-font-size:           $font-size-base * 1.25;
      // $h6-font-size:           $font-size-base;

      // $headings-font-weight:   500;
      // $headings-line-height:   1.2;

      // =============================================================================
      // Spacing
      // =============================================================================
      // $spacer: 1rem;

      // =============================================================================
      // Borders & Rounded Corners
      // =============================================================================
      // $border-width:           1px;
      // $border-color:           #dee2e6;
      // $border-radius:          0.375rem;
      // $border-radius-sm:       0.25rem;
      // $border-radius-lg:       0.5rem;
      // $border-radius-xl:       1rem;
      // $border-radius-xxl:      2rem;
      // $border-radius-pill:     50rem;

      // =============================================================================
      // Shadows
      // =============================================================================
      // $box-shadow:             0 .5rem 1rem rgba(0, 0, 0, .15);
      // $box-shadow-sm:          0 .125rem .25rem rgba(0, 0, 0, .075);
      // $box-shadow-lg:          0 1rem 3rem rgba(0, 0, 0, .175);

      // =============================================================================
      // Buttons
      // =============================================================================
      // $btn-padding-y:          0.375rem;
      // $btn-padding-x:          0.75rem;
      // $btn-font-size:          $font-size-base;
      // $btn-border-radius:      $border-radius;

      // =============================================================================
      // Forms
      // =============================================================================
      // $input-padding-y:        0.375rem;
      // $input-padding-x:        0.75rem;
      // $input-font-size:        $font-size-base;
      // $input-border-radius:    $border-radius;
      // $input-border-color:     #ced4da;
      // $input-focus-border-color: #86b7fe;

      // =============================================================================
      // Cards
      // =============================================================================
      // $card-spacer-y:          1rem;
      // $card-spacer-x:          1rem;
      // $card-border-width:      $border-width;
      // $card-border-color:      rgba(0, 0, 0, .125);
      // $card-border-radius:     $border-radius;
      // $card-box-shadow:        null;

      // =============================================================================
      // Navbar
      // =============================================================================
      // $navbar-padding-y:       0.5rem;
      // $navbar-padding-x:       null;
      // $nav-link-padding-y:     0.5rem;
      // $nav-link-padding-x:     1rem;

      // =============================================================================
      // Modals
      // =============================================================================
      // $modal-inner-padding:    1rem;
      // $modal-content-border-radius: $border-radius-lg;

      // =============================================================================
      // Alerts
      // =============================================================================
      // $alert-padding-y:        1rem;
      // $alert-padding-x:        1rem;
      // $alert-border-radius:    $border-radius;
    SCSS

    create_file "app/assets/stylesheets/_bootstrap-overrides.scss", bootstrap_overrides_content

    gsub_file "app/assets/stylesheets/application.bootstrap.scss",
      "@import 'bootstrap/scss/bootstrap';",
      "@import 'bootstrap-overrides';\n@import 'bootstrap/scss/bootstrap';"

    git add: "-A"
    git commit: "-m 'Add Bootstrap overrides file for customization'"
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

  # Detect frontend tooling so README matches the app that was generated.
  uses_node = File.exist?("package.json")
  package_manager =
    if File.exist?("yarn.lock")
      "yarn"
    elsif File.exist?("pnpm-lock.yaml")
      "pnpm"
    elsif File.exist?("bun.lockb") || File.exist?("bun.lock")
      "bun"
    elsif File.exist?("package-lock.json")
      "npm"
    elsif uses_node
      "npm"
    end

  js_lint_cmd =
    case package_manager
    when "yarn"
      "yarn lint"
    when "pnpm"
      "pnpm lint"
    when "bun"
      "bun run lint"
    when "npm"
      "npm run lint"
    end

  js_fix_cmd =
    case package_manager
    when "yarn"
      "yarn fix:prettier"
    when "pnpm"
      "pnpm fix:prettier"
    when "bun"
      "bun run fix:prettier"
    when "npm"
      "npm run fix:prettier"
    end

  js_install_cmd =
    case package_manager
    when "yarn"
      "yarn install"
    when "pnpm"
      "pnpm install"
    when "bun"
      "bun install"
    when "npm"
      "npm install"
    end

  dev_command = File.exist?("bin/dev") ? "bin/dev" : "bin/rails server"
  package_manager_label =
    case package_manager
    when "yarn"
      "Yarn"
    when "npm"
      "npm"
    when "pnpm"
      "pnpm"
    when "bun"
      "bun"
    end

  requirements_lines = []
  requirements_lines << "- Ruby #{RUBY_VERSION} (see `.ruby-version`)"
  requirements_lines << "- PostgreSQL"
  if uses_node
    requirements_lines << "- Node.js (see `.node-version`)"
    requirements_lines << "- #{package_manager_label}" if package_manager_label
  end

  tooling_lines = []
  tooling_lines << "- RSpec + FactoryBot"
  tooling_lines << "- StandardRB"
  tooling_lines << "- Herb"
  tooling_lines << "- bundler-audit"
  tooling_lines << "- Bullet"
  tooling_lines << "- Solid Queue"
  tooling_lines << "- AnnotateRb"
  tooling_lines << "- Dotenv"
  tooling_lines << "- SimpleCov (coverage)" if testing_options[:simplecov]
  tooling_lines << "- Shoulda Matchers" if testing_options[:shoulda]
  tooling_lines << "- Faker" if testing_options[:faker]
  tooling_lines << "- WebMock" if testing_options[:webmock]
  tooling_lines << "- Goldiloader (automatic N+1 prevention)" if performance_options[:goldiloader]
  tooling_lines << "- rack-mini-profiler" if performance_options[:rack_profiler]
  tooling_lines << "- Skylight" if performance_options[:skylight]
  tooling_lines << "- Ahoy + Blazer" if analytics_options[:ahoy_blazer]
  tooling_lines << "- Rails ERD" if doc_options[:rails_erd]
  tooling_lines << "- rails_db" if doc_options[:rails_db]
  tooling_lines << "- Rollbar" if monitoring_options[:error_service] == "rollbar"
  tooling_lines << "- Honeybadger" if monitoring_options[:error_service] == "honeybadger"
  tooling_lines << "- Bootstrap overrides (`app/assets/stylesheets/_bootstrap-overrides.scss`)" if frontend_options[:bootstrap_overrides]
  tooling_lines << "- Full JS/CSS/ERB linting stack" if frontend_options[:full_linting]
  tooling_lines << "- UUID primary keys" if db_options[:use_uuid]
  tooling_lines << "- Rails multi-database (cache/queue/cable)" if db_options[:multi_database]
  tooling_lines << "- Render.com deployment files (`render.yaml`, `bin/render-build.sh`)" if render_options[:enabled]
  tooling_lines << "- GitHub Actions CI (`.github/workflows/ci.yml`)" if ci_options[:github_actions]

  dependency_install_cmds = ["bundle install"]
  dependency_install_cmds << js_install_cmd if js_install_cmd

  testing_section = if testing_options[:simplecov]
    <<~MARKDOWN

      With coverage:
      ```bash
      COVERAGE=true bundle exec rspec
      ```
    MARKDOWN
  else
    ""
  end

  linting_section = if frontend_options[:full_linting]
    <<~MARKDOWN

      JavaScript/CSS linting:
      ```bash
      #{js_lint_cmd}
      #{js_fix_cmd}
      ```

      ERB linting:
      ```bash
      bundle exec erb_lint --lint-all
      bundle exec erb_lint --lint-all --autocorrect
      ```
    MARKDOWN
  else
    ""
  end

  error_monitoring_section = case monitoring_options[:error_service]
  when "rollbar"
    <<~MARKDOWN

      ## Error Monitoring

      This app uses Rollbar for error tracking. Set your access token:
      ```bash
      ROLLBAR_ACCESS_TOKEN=your_token_here
      ```

      Visit [rollbar.com](https://rollbar.com) to sign up and get your access token.
    MARKDOWN
  when "honeybadger"
    <<~MARKDOWN

      ## Error Monitoring

      This app uses Honeybadger for error tracking. Set your API key:
      ```bash
      HONEYBADGER_API_KEY=your_key_here
      ```

      Visit [honeybadger.io](https://honeybadger.io) to sign up and get your API key.
    MARKDOWN
  else
    ""
  end

  performance_monitoring_section = if performance_options[:skylight]
    <<~MARKDOWN

      ## Performance Monitoring

      This app uses Skylight for performance monitoring. Set your authentication token:
      ```bash
      SKYLIGHT_AUTHENTICATION=your_token_here
      ```

      Visit [skylight.io](https://skylight.io) to sign up and get your authentication token.
    MARKDOWN
  else
    ""
  end

  analytics_section = if analytics_options[:ahoy_blazer]
    <<~MARKDOWN

      ## Analytics

      This app uses Ahoy for tracking and Blazer for analytics dashboards.

      - View analytics dashboard: `/analytics`
      - **Authentication:** Check `.env` file for auto-generated credentials
      - **Username:** `admin`
      - **Password:** Unique 16-character password in `.env` file
      - Track custom events in JavaScript:
        ```javascript
        ahoy.track("Event Name", {property: "value"});
        ```
      - Track events in Ruby:
        ```ruby
        ahoy.track "Event Name", property: "value"
        ```

      Sample queries are available in `db/blazer_queries.yml`.

      ### Securing Blazer in Production

      The dashboard uses basic authentication with a unique auto-generated password.
      For production, you can:
      1. Keep the strong auto-generated password
      2. Use your app's authentication (e.g., Devise) instead
      3. Create a read-only database user for Blazer
      4. Restrict access by IP or VPN
    MARKDOWN
  else
    ""
  end

  render_deployment_section = if render_options[:enabled]
    tier_info = render_options[:free_tier] ?
      "Free tier (512MB RAM, WEB_CONCURRENCY=0 for single-process threaded mode)" :
      "Paid tier (WEB_CONCURRENCY=2 for multi-process mode)"
    db_info = render_options[:database_provider] == "supabase" ?
      "Supabase (external, no 90-day expiration)" :
      "Render Postgres (integrated)"
    worker_info = render_options[:separate_worker] ?
      "Separate worker service for better resource isolation" :
      "Puma plugin (runs in web process, simpler setup)"
    domain_info = render_options[:domain] ?
      "Custom domain: `#{render_options[:domain]}`#{render_options[:include_www] ? " with www redirect" : ""}" :
      "No custom domain configured (uses .onrender.com subdomain)"

    quick_deploy_steps = if render_options[:database_provider] == "supabase"
      <<~STEPS
        1. Create a Supabase project at https://supabase.com
        2. Push your code to GitHub
        3. Connect your repository to Render
        4. Render will automatically detect the `render.yaml` blueprint
        5. Set environment variables in the Render dashboard:
           - `RAILS_MASTER_KEY` - from `config/master.key`
           - `DATABASE_URL` - from Supabase (Settings → Database → URI)
      STEPS
    else
      <<~STEPS
        1. Push your code to GitHub
        2. Connect your repository to Render
        3. Render will automatically detect the `render.yaml` blueprint
        4. Set the `RAILS_MASTER_KEY` environment variable in the Render dashboard:
           - Find your key in `config/master.key`
           - Add it as an environment variable (marked `sync: false` in blueprint)
      STEPS
    end

    database_info = if render_options[:database_provider] == "supabase"
      "**Database**: Supabase PostgreSQL (configure `DATABASE_URL` manually)"
    else
      "**Database**: Render PostgreSQL (auto-provisioned)"
    end

    <<~SECTION

    ## Deployment to Render.com

    This app is configured for easy deployment to Render.com.
    **See `RENDER_DEPLOYMENT.md` for a complete deployment checklist.**

    ### Configuration Summary

    | Setting | Value |
    |---------|-------|
    | Tier | #{tier_info} |
    | Database | #{db_info} |
    | Background Jobs | #{worker_info} |
    | Domain | #{domain_info} |

    ### Quick Deploy

    #{quick_deploy_steps.strip}
    #{render_options[:domain] ? "\n6. Configure DNS records (see `RENDER_DEPLOYMENT.md` for details)" : ""}

    ### What's Configured

    - **Build script**: `bin/render-build.sh` handles dependencies and assets
    - **Migrations**: Run via `preDeployCommand` (after build, before start)
    - #{database_info}
    - **Health checks**: Rails 8's `/up` endpoint for monitoring
    - **Environment**: `NODE_ENV=production` for optimized builds

    Learn more: [Render Rails Deployment Guide](https://render.com/docs/deploy-rails)
    SECTION
  else
    ""
  end

  doc_commands = []
  doc_commands << "- Generate ERD: `bundle exec erd`" if doc_options[:rails_erd]
  doc_commands << "- Annotate models: `bundle exec annotaterb models`"
  doc_commands << "- View database: Visit `/rails_db` in development" if doc_options[:rails_db]

  bundler_audit_command =
    if File.exist?("bin/bundler-audit")
      "bin/bundler-audit check --update"
    else
      "bundle exec bundle-audit check --update"
    end

  security_commands = [
    bundler_audit_command,
    "bundle exec brakeman --no-pager"
  ]

  ci_section = if ci_options[:github_actions]
    <<~MARKDOWN

      ## Continuous Integration

      GitHub Actions CI is configured in `.github/workflows/ci.yml`.
    MARKDOWN
  else
    ""
  end

  database_notes = []
  database_notes << "- Primary keys default to UUIDs." if db_options[:use_uuid]
  database_notes << "- Rails multi-database is enabled (separate DBs for cache/queue/cable)." if db_options[:multi_database]
  database_section = if database_notes.any?
    <<~MARKDOWN

      ## Database Notes

      #{database_notes.join("\n")}
    MARKDOWN
  else
    ""
  end

  n_plus_one_intro =
    if performance_options[:goldiloader]
      "This app is configured to both detect and prevent N+1 queries."
    else
      "This app is configured to detect N+1 queries in development and test."
    end

  bullet_unused_eager_loading_line =
    if performance_options[:goldiloader]
      "- Unused eager loading detection is disabled to work well with Goldiloader"
    else
      "- Unused eager loading detection is disabled (enable it in Bullet config if you want it)"
    end

  goldiloader_details = if performance_options[:goldiloader]
    <<~MARKDOWN
      Automatically eager loads associations when accessed.
      - Works in all environments (development, test, production)
      - Disable for specific associations: `has_many :posts, -> { auto_include(false) }`
      - Disable for code blocks: `Goldiloader.disabled { ... }`
    MARKDOWN
  else
    "Not included. Enable it in the template options if you want automatic N+1 prevention."
  end

  rack_profiler_section = if performance_options[:rack_profiler]
    <<~MARKDOWN

      ### rack-mini-profiler

      Enabled in development. You should see the profiler badge when you load pages.
    MARKDOWN
  else
    ""
  end

  solid_queue_dev_note = if File.exist?("Procfile.dev") && File.read("Procfile.dev").match?(/^\s*jobs:/)
    "\n\nIn development, `#{dev_command}` also starts a Solid Queue worker (see `Procfile.dev`)."
  else
    ""
  end

  # README (overwrite the default Rails README)
  remove_file "README.md"
  create_file "README.md", <<~MARKDOWN
    # #{app_name.humanize}

    ## Tooling

    This app was generated from a Rails application template and includes:

    #{tooling_lines.join("\n")}

    ## Requirements

    #{requirements_lines.join("\n")}

    ## Setup

    1. Clone the repository
    2. Install dependencies:
       ```bash
       #{dependency_install_cmds.join("\n")}
       ```

    3. Setup database:
       ```bash
       bin/rails db:prepare
       bin/rails db:seed
       ```

    4. Copy environment variables:
       ```bash
       cp .env.example .env
       ```
       Edit `.env` with your configuration

    ## Development

    Start the development server:
    ```bash
    #{dev_command}
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

    #{n_plus_one_intro}

    ### Bullet (Detection)
    - Detects N+1 queries and suggests fixes in development and test
    - Logs to server console and displays in HTML footer
    #{bullet_unused_eager_loading_line}
    - View N+1 warnings in:
      - Browser footer (development only)
      - Rails server log
      - Browser console

    ### Goldiloader (Prevention)
    #{goldiloader_details}#{rack_profiler_section}

    ## Background Jobs

    This app uses Solid Queue (Rails 8 default) for background job processing.#{solid_queue_dev_note}

    ## Documentation

    #{doc_commands.join("\n")}
#{database_section}#{ci_section}#{error_monitoring_section}#{performance_monitoring_section}#{analytics_section}#{render_deployment_section}
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
    uuid_line =
      if db_options[:use_uuid]
        "✅ UUID primary keys (#{db_options[:uuid_version].to_s.upcase})"
      else
        "❌ UUID primary keys"
      end
    say "  #{uuid_line}"
    say "  #{db_options[:multi_database] ? '✅' : '❌'} Rails 8 multi-database setup (separate DBs for cache/queue/cable)"

    say "\nDeployment:", :cyan
    say "  #{render_options[:enabled] ? '✅' : '❌'} Render.com configuration (build script + render.yaml)"
    if render_options[:enabled]
      say "    • Tier: #{render_options[:free_tier] ? 'Free (512MB, WEB_CONCURRENCY=0)' : 'Paid (WEB_CONCURRENCY=2)'}"
      say "    • Database: #{render_options[:database_provider] == 'supabase' ? 'Supabase (external)' : 'Render Postgres'}"
      say "    • Background jobs: #{render_options[:separate_worker] ? 'Separate worker service' : 'Puma plugin (runs in web process)'}"
      say "    • Custom domain: #{render_options[:domain] || 'Not configured'}"
      say "    • Deployment checklist: RENDER_DEPLOYMENT.md"
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
  if render_options[:enabled]
    say "\n  For Render.com deployment:", :yellow
    say "  4. Review RENDER_DEPLOYMENT.md for deployment checklist"
    if render_options[:database_provider] == "supabase"
      say "  5. Create Supabase project at https://supabase.com"
      say "  6. Push to GitHub and connect to Render"
      say "  7. Set RAILS_MASTER_KEY and DATABASE_URL in Render Dashboard"
    else
      say "  5. Push to GitHub and connect to Render"
      say "  6. Set RAILS_MASTER_KEY in Render Dashboard (from config/master.key)"
    end
  end

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
