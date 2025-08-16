# Rails Application Template

A comprehensive Rails application template with modern best practices, testing tools, and development utilities.

## Features

### Core Stack
- PostgreSQL database
- RSpec for testing
- StandardRB for Ruby linting
- Bootstrap CSS support (with `--css=bootstrap`)
- Esbuild for JavaScript (with `--javascript=esbuild`)

### Development & Debugging Tools
- **pry-rails** - Enhanced Rails console
- **better_errors + binding_of_caller** - Better error pages with REPL
- **amazing_print** - Pretty-print Ruby objects (replaces deprecated awesome_print)
- **bullet** - N+1 query detection
- **goldiloader** - Automatic N+1 prevention
- **rack-mini-profiler** - Performance profiling

### Testing Suite
- **RSpec Rails** with proper configuration
- **Capybara + Selenium** for system testing
- **Factory Bot** for test factories
- **Shoulda Matchers** for one-liner tests
- **Faker** for test data generation
- **SimpleCov** for code coverage reporting
- **WebMock** for HTTP request stubbing
- **action_dispatch-testing-integration-capybara** - Enhanced Capybara integration

### Code Quality & Linting
- **StandardRB + Standard-Rails** for Ruby
- **Prettier** for JavaScript/CSS formatting
- **ESLint** with Thoughtbot configuration
- **Stylelint** with Thoughtbot configuration
- **erb_lint + better_html** for ERB template linting

### Documentation & Visualization
- **AnnotateRb** - Automatic model schema annotations (replaces deprecated annotate gem)
- **Rails ERD** - Entity relationship diagram generation
- **rails_db** - Web UI for database browsing

### Security & Safety
- **Brakeman** - Security vulnerability scanning
- **bundler-audit** - Check for vulnerable gem dependencies
- **strong_migrations** - Catch unsafe migrations before they run

### Environment & Configuration
- **dotenv** - Environment variable management (replaces dotenv-rails)
- **Force SSL** in production
- **Enhanced production logging**
- Optional UUID primary keys

### Project Files
- Comprehensive README template
- CONTRIBUTING.md guidelines
- .env.example with common configurations
- .node-version for Node.js version management

## Usage

### Basic Usage

```bash
rails new my_app \
  --database=postgresql \
  --javascript=esbuild \
  --css=bootstrap \
  --skip-test \
  --skip-kamal \
  --skip-rubocop \
  --template=https://raw.githubusercontent.com/firstdraft/rails_application_template/main/template.rb
```

### Recommended Flags

- `--database=postgresql` - Use PostgreSQL (required)
- `--javascript=esbuild` - Fast JavaScript bundling
- `--css=bootstrap` - Bootstrap CSS framework
- `--skip-test` - Skip Minitest (we use RSpec)
- `--skip-rubocop` - Skip default RuboCop (we use StandardRB)
- `--skip-kamal` - Skip Kamal deployment (unless you need it)

### Interactive Options

During setup, the template will prompt you for:
- **UUID Primary Keys**: Choose between standard integers or UUIDs for primary keys

## What Gets Configured

### Testing
- RSpec with random test order
- Test example persistence for re-running failed tests
- SimpleCov for coverage (run with `COVERAGE=true bundle exec rspec`)
- WebMock configured with Chrome driver whitelisting
- Factory Bot and Shoulda Matchers support files

### Linting
- StandardRB configuration for Ruby
- Prettier, ESLint, and Stylelint for frontend code
- ERB linting with better_html
- All with proper ignore patterns and configurations

### Development Tools
- Bullet enabled with console and footer output
- Strong Migrations with sensible timeouts
- AnnotateRb configuration for model annotations
- Rails ERD with Bachman notation

### Git Workflow
- Incremental commits after each configuration step
- Clean git history showing the setup progression

## Available Commands

After creating your app, these commands are available:

### Development
```bash
bin/dev                        # Start development server
rails console                  # Enhanced console with Pry
```

### Testing
```bash
bundle exec rspec              # Run test suite
COVERAGE=true bundle exec rspec # Run with coverage report
```

### Linting & Formatting
```bash
# Ruby
bundle exec standardrb         # Check Ruby code
bundle exec standardrb --fix   # Fix Ruby issues

# JavaScript/CSS
yarn lint                      # Check JS/CSS
yarn fix:prettier              # Fix JS/CSS formatting

# ERB Templates
bundle exec erb_lint --lint-all              # Check ERB
bundle exec erb_lint --lint-all --autocorrect # Fix ERB
```

### Security
```bash
bundle exec brakeman           # Security scan
bundle exec bundle-audit check # Check for vulnerable gems
```

### Documentation
```bash
bundle exec erd                # Generate ERD diagram
bundle exec annotaterb models  # Update model annotations
```

### Database
Visit `/rails_db` in development for web UI

## Background Jobs

The template uses Rails 8's default Solid Queue for background job processing. For high-volume applications that need Redis-backed processing, see:
- [Solid Queue vs Sidekiq Comparison](https://medium.com/@rohitmuk1985/choosing-the-right-background-job-processor-in-rails-solid-queue-vs-sidekiq-ac3195635adb)
- [Migration Guide from Sidekiq](https://www.bigbinary.com/blog/migrating-to-solid-queue-from-sidekiq)

## Deployment

This template creates apps configured for generic production deployment, suitable for:
- [Render.com](https://render.com/docs/deploy-rails-8)
- Fly.io
- Railway
- Heroku (with minor adjustments)
- Any modern hosting platform

## Differences from Original

This is an enhanced version of the original firstdraft template with:
- Updated gems (amazing_print instead of awesome_print, annotaterb instead of annotate, dotenv instead of dotenv-rails)
- Additional testing tools (SimpleCov, WebMock, Shoulda Matchers, Faker)
- Full linting stack (Prettier, ESLint, Stylelint, erb_lint)
- Security tools (bundler-audit, strong_migrations)
- Performance tools (goldiloader, rack-mini-profiler)
- Modern production configuration (generic instead of Heroku-specific)
- Comprehensive documentation

## Contributing

Pull requests are welcome! Please ensure any new gems or configurations:
1. Are actively maintained
2. Add clear value for most Rails applications
3. Include appropriate documentation
4. Follow the incremental commit pattern

## License

MIT