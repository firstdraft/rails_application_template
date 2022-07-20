base_url = "https://raw.githubusercontent.com/firstdraft/rails_application_template/main"

gem_group :production do
  gem "rack-timeout"
end

gem_group :development, :test do
  gem "awesome_print"
  gem "better_errors"
  gem "binding_of_caller"
  gem "dotenv-rails"
  gem "pry-rails"
  gem "rspec-rails"
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "standard", require: false
end

gem_group :development do
  gem "annotate"
  gem "bullet"
  gem "rails-erd"
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

  # README

  get "#{base_url}/TEMPLATE_README.md",
    "README.md"

  git add: "-A"
  git commit: "-m 'Update README'"

  # dotenv
  # https://github.com/bkeepers/dotenv

  get "#{base_url}/template_env",
    ".env"

  append_to_file ".gitignore", "# Ignore dotenv files"
  append_to_file ".gitignore", ".env*\n\n"

  git add: "-A"
  git commit: "-m 'Stub .env'"

  # Heroku changes

  get "#{base_url}/Procfile",
    "Procfile"

  uncomment_lines "config/environments/production.rb",
    /config.force_ssl = true/

  # get "#{base_url}/puma.rb",
  #   "config/puma.rb"

  git add: "-A"
  git commit: "-m 'Heroku setup'"

  # AnnotateModels
  # https://github.com/ctran/annotate_models

  generate("annotate:install")

  git add: "-A"
  git commit: "-m 'Configure AnnotateModels'"

  # Rails ERD
  # https://github.com/voormedia/rails-erd

  generate("erd:install")

  get "#{base_url}/.erdconfig",
    ".erdconfig"

  git add: "-A"
  git commit: "-m 'Configure Rails ERD'"

  # Bullet

  bullet_config = <<-HEREDOC.gsub(/^                /, "")
                    Bullet.enable = true
                    Bullet.console = true
                    Bullet.rails_logger = true
                    Bullet.add_footer = true
  HEREDOC

  insert_into_file "config/environments/development.rb",
    bullet_config,
    after: "Rails.application.configure do\n"

  git add: "-A"
  git commit: "-m 'Configure Bullet'"

  # StandardRB / RuboCop

  gsub_file "bin/bundle",
    /return gemfile if gemfile && !gemfile.empty\?/,
    "return gemfile if gemfile && !gemfile.empty? # rubocop:disable Rails/Present"

  get "#{base_url}/.rubocop.yml",
    ".rubocop.yml"

  git add: "-A"
  git commit: "-m 'Configure RuboCop / StandardRB'"

  run "bundle exec rubocop -A"

  git add: "-A"
  git commit: "-m 'rubocop -A'"
end
