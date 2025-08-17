base_url = "https://raw.githubusercontent.com/firstdraft/rails_application_template/main"

# Production gems - removed rack-timeout per user preference

gem_group :development, :test do
  # Debugging
  gem "pry-rails"
  gem "better_errors"
  gem "binding_of_caller"
  gem "amazing_print" # Updated from awesome_print - actively maintained fork
  
  # Environment
  gem "dotenv" # Updated from dotenv-rails - Rails integration now included
  
  # Testing
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails"
  gem "shoulda-matchers", "~> 6.0"
  gem "faker"
  
  # Code Quality & Linting
  gem "standard", require: false
  gem "standard-rails", require: false
  gem "better_html", require: false
  gem "erb_lint", require: false
  gem "erblint-github", require: false
  
  # Security
  gem "bundler-audit", require: false
  gem "brakeman", require: false
end

gem_group :development do
  # Performance & Debugging
  gem "bullet"
  gem "goldiloader"
  gem "rack-mini-profiler"
  
  # Documentation
  gem "annotaterb" # Updated from annotate - actively maintained fork
  gem "rails-erd"
  gem "rails_db", ">= 2.3.1"
  
  # Migration Safety
  gem "strong_migrations"
end

gem_group :test do
  # System Testing
  gem "capybara"
  gem "selenium-webdriver"
  gem "webmock"
  
  # Coverage
  gem "simplecov", require: false
  
  # Enhanced Capybara integration
  gem "action_dispatch-testing-integration-capybara",
    github: "thoughtbot/action_dispatch-testing-integration-capybara", 
    tag: "v0.1.1",
    require: "action_dispatch/testing/integration/capybara/rspec"
end

after_bundle do
  rails_command("db:create")

  git add: "-A"
  git commit: "-m 'rails new'"

  # Generators config

  gsub_file "config/application.rb",
    /# Don't generate system test files./,
    ""

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

  # UUIDs by default

  if yes?("Use UUIDs by default?")
    get "#{base_url}/enable_extension_for_uuid.rb",
      "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_enable_extension_for_uuid.rb"

    rails_command("db:migrate")

    insert_into_file "config/application.rb",
      "    g.orm :active_record, primary_key_type: :uuid\n",
      after: "  config.generators do |g|\n"

    inject_into_class "app/models/application_record.rb",
      "ApplicationRecord",
      "  self.implicit_order_column = \"created_at\"\n\n"


    git add: "-A"
    git commit: "-m 'Use UUIDs by default'"
  end

  # RSpec Setup
  generate("rspec:install")
  
  # Configure RSpec
  insert_into_file "spec/rails_helper.rb",
    "\n  config.infer_base_class_for_anonymous_controllers = false\n",
    after: "RSpec.configure do |config|\n"
  
  uncomment_lines "spec/rails_helper.rb", /Rails\.root\.glob/
  
  # Add to spec_helper.rb for WebMock, SimpleCov, and test configuration
  spec_helper_config = <<~RUBY
    
    config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
    config.order = :random
    
    # SimpleCov configuration
    if ENV['COVERAGE']
      require 'simplecov'
      SimpleCov.start 'rails'
    end
  RUBY
  
  insert_into_file "spec/spec_helper.rb",
    spec_helper_config,
    after: "RSpec.configure do |config|\n"
  
  # WebMock configuration in separate file
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
  
  # Shoulda Matchers configuration
  create_file "spec/support/shoulda_matchers.rb", <<~RUBY
    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end
  RUBY
  
  # Factory Bot configuration
  create_file "spec/support/factory_bot.rb", <<~RUBY
    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
    end
  RUBY
  
  git add: "-A"
  git commit: "-m 'Configure RSpec with testing tools'"
  
  # README with comprehensive documentation
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
    ```
    
    With coverage:
    ```bash
    COVERAGE=true bundle exec rspec
    ```
    
    ## Code Quality
    
    Ruby linting:
    ```bash
    bundle exec standardrb
    bundle exec standardrb --fix
    ```
    
    JavaScript/CSS linting:
    ```bash
    yarn lint
    yarn fix:prettier
    ```
    
    ERB linting:
    ```bash
    bundle exec erb_lint --lint-all
    bundle exec erb_lint --lint-all --autocorrect
    ```
    
    Security scanning:
    ```bash
    bundle exec brakeman
    bundle exec bundle-audit check
    ```
    
    ## Background Jobs
    
    This app uses Solid Queue (Rails 8 default) for background job processing.
    
    For high-volume applications, consider Sidekiq:
    - [Solid Queue vs Sidekiq Comparison](https://medium.com/@rohitmuk1985/choosing-the-right-background-job-processor-in-rails-solid-queue-vs-sidekiq-ac3195635adb)
    - [Migration Guide](https://www.bigbinary.com/blog/migrating-to-solid-queue-from-sidekiq)
    
    ## Deployment
    
    This app is configured for generic production deployment, suitable for:
    - Render.com ([Deployment Guide](https://render.com/docs/deploy-rails-8))
    - Fly.io
    - Railway
    - Other modern platforms
    
    ## Documentation
    
    - Generate ERD: `bundle exec erd`
    - Annotate models: `bundle exec annotaterb models`
    - View database: Visit `/rails_db` in development
  MARKDOWN

  git add: "-A"
  git commit: "-m 'Update README with comprehensive documentation'"

  # Enhanced .env.example file
  create_file ".env.example", <<~ENV
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
  
  create_file ".env"
  
  append_to_file ".gitignore", <<~TEXT
    
    # Ignore dotenv files
    .env*
    !.env.example
  TEXT

  git add: "-A"
  git commit: "-m 'Configure dotenv with comprehensive example'"

  # Production setup (generic, not Heroku-specific)
  uncomment_lines "config/environments/production.rb",
    /config.force_ssl = true/
  
  # Configure production logging
  gsub_file "config/environments/production.rb",
    /config.log_formatter = ::Logger::Formatter.new/,
    "config.log_formatter = ::Logger::Formatter.new\n  config.log_tags = [:request_id]"

  git add: "-A"
  git commit: "-m 'Configure production environment'"

  # AnnotateRb (updated gem)
  # https://github.com/drwl/annotaterb
  
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
  git commit: "-m 'Configure AnnotateRb with auto-annotation after migrations'"

  # Rails ERD
  # https://github.com/voormedia/rails-erd

  generate("erd:install")

  get "#{base_url}/.erdconfig",
    ".erdconfig"

  git add: "-A"
  git commit: "-m 'Configure Rails ERD'"

  # Bullet Configuration
  bullet_config = <<-RUBY
    # Bullet configuration for N+1 query detection
    Bullet.enable = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
    
  RUBY

  insert_into_file "config/environments/development.rb",
    bullet_config,
    after: "Rails.application.configure do\n"

  git add: "-A"
  git commit: "-m 'Configure Bullet for N+1 detection'"
  
  # Strong Migrations Configuration
  create_file "config/initializers/strong_migrations.rb", <<~RUBY
    # Mark existing migrations as safe
    StrongMigrations.start_after = Time.current.year * 10000 + Time.current.month * 100 + Time.current.day
    
    # Set timeouts for migrations
    StrongMigrations.lock_timeout = 10.seconds
    StrongMigrations.statement_timeout = 1.hour
    
    # Analyze tables after adding indexes
    StrongMigrations.auto_analyze = true
    
    # Target version for checks
    StrongMigrations.target_version = Rails.version.to_f
  RUBY
  
  git add: "-A"
  git commit: "-m 'Configure Strong Migrations'"

  # StandardRB Configuration
  # Use the current Ruby version dynamically (major.minor only)
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
  
  # JavaScript/CSS Linting Setup
  # Install dependencies
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
  
  # Project Documentation Files
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
    - JavaScript: ESLint with Thoughtbot config
    - CSS: Stylelint with Thoughtbot config
    - ERB: erb_lint
    
    ## Testing
    
    - Write tests for all new features
    - Maintain test coverage above 80%
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
  create_file ".node-version", "20.0.0\n"
  
  git add: "-A"
  git commit: "-m 'Add project documentation files'"

  # Final cleanup
  run "bundle exec standardrb --fix-unsafely"
  
  git add: "-A"
  git commit: "-m 'Apply StandardRB formatting'"
  
  # Success message
  say "\n🎉 Rails app successfully created with enhanced template!", :green
  say "\nThis template includes:", :yellow
  say "  ✅ Modern testing stack (RSpec, FactoryBot, SimpleCov, WebMock)"
  say "  ✅ Code quality tools (StandardRB, Prettier, ESLint, Stylelint)"
  say "  ✅ Security scanning (Brakeman, bundler-audit)"
  say "  ✅ Performance monitoring (Bullet, Goldiloader, rack-mini-profiler)"
  say "  ✅ Documentation tools (AnnotateRb, Rails ERD)"
  say "  ✅ Safe migrations (Strong Migrations)"
  say "\nNext steps:", :yellow
  say "  1. cd #{app_name}"
  say "  2. Review and edit .env file"
  say "  3. Run: bin/dev"
end
