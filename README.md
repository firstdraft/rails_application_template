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
- **goldiloader** - Automatic N+1 prevention (optional, default: enabled)
- **rack-mini-profiler** - Performance profiling (optional, default: enabled)

### Testing Suite
- **RSpec Rails** with proper configuration
- **Capybara + Selenium** for system testing
- **Factory Bot** for test factories
- **Shoulda Matchers** for one-liner tests (optional, default: enabled)
- **Faker** for test data generation (optional, default: enabled)
- **SimpleCov** for code coverage reporting (optional, default: enabled)
- **WebMock** for HTTP request stubbing (optional, default: disabled)
- **action_dispatch-testing-integration-capybara** - Enhanced Capybara integration

### Code Quality & Linting
- **StandardRB + Standard-Rails** for Ruby
- **Prettier** for JavaScript/CSS formatting (optional, default: disabled)
- **ESLint** with Thoughtbot configuration (optional, default: disabled)
- **Stylelint** with Thoughtbot configuration (optional, default: disabled)
- **erb_lint + better_html** for ERB template linting

### Documentation & Visualization
- **AnnotateRb** - Automatic model schema annotations (replaces deprecated annotate gem)
- **Rails ERD** - Entity relationship diagram generation (optional, default: enabled)
- **rails_db** - Web UI for database browsing (optional, default: disabled)

### Security & Safety
- **Brakeman** - Security vulnerability scanning
- **bundler-audit** - Check for vulnerable gem dependencies (optional, default: enabled)

### Monitoring & Analytics
- **Error Monitoring** - Choose between Rollbar (default), Honeybadger, or None (optional)
- **Skylight** - Production performance monitoring (optional, default: enabled)
- **Ahoy + Blazer** - Analytics tracking and SQL-based dashboard (optional, default: enabled)

### Environment & Configuration
- **dotenv** - Environment variable management (replaces dotenv-rails)
- **Force SSL** in production
- **Enhanced production logging**
- **Database Options**:
  - Optional UUID primary keys
  - Optional Rails 8 multi-database setup (separate databases for cache/queue/cable) - defaults to single database for simpler deployment

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

The template offers two modes:

1. **Default Configuration** (recommended): Includes most tools with sensible defaults
2. **Custom Configuration**: Interactive prompts to choose which tools to include

If you choose custom configuration, you'll be prompted for:

- **Testing Tools**: SimpleCov, Shoulda Matchers, Faker, WebMock
- **Performance Tools**: Goldiloader, rack-mini-profiler, Skylight
- **Analytics**: Ahoy + Blazer for tracking and dashboards
- **Documentation Tools**: Rails ERD, rails_db browser
- **Security Tools**: bundler-audit for vulnerability scanning
- **Error Monitoring**: Rollbar, Honeybadger, or None
- **Frontend Tools**: Bootstrap overrides, full linting stack (Prettier, ESLint, Stylelint)
- **Database Configuration**:
  - UUID primary keys vs. standard integers
  - Rails 8 multi-database setup (separate databases for cache/queue/cable) vs. single database
- **Deployment**: Render.com-specific configuration (build script, render.yaml, worker setup)

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
- AnnotateRb configuration for model annotations
- Rails ERD with Bachman notation

### Git Workflow
- Incremental commits after each configuration step
- Clean git history showing the setup progression

## Available Commands

After creating your app, these commands are available:

### Development
```bash
bin/dev                        # Start development server (includes web, JS/CSS compilation, and SolidQueue worker)
rails console                  # Enhanced console with Pry
```

**Note:** When using `bin/dev` (apps with JavaScript/CSS compilation), the template automatically configures SolidQueue to run in development, matching production behavior and helping catch job-related issues early.

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
Visit `/rails_db` in development for web UI (if enabled)

### Analytics & Monitoring
Visit `/blazer` for analytics dashboard (if Ahoy + Blazer enabled)

## Background Jobs

The template uses Rails 8's default Solid Queue for background job processing.

### Development
- When using `bin/dev` (apps with JS/CSS compilation), SolidQueue runs automatically as a worker process
- Development environment is configured to use `:solid_queue` adapter
- This matches production behavior and helps catch job-related issues early

### Production
- SolidQueue uses database-backed job storage (same database as your app data)
- Can optionally run as separate worker service (e.g., on Render.com) or as Puma plugin
- For high-volume applications needing Redis-backed processing, see:
  - [Solid Queue vs Sidekiq Comparison](https://medium.com/@rohitmuk1985/choosing-the-right-background-job-processor-in-rails-solid-queue-vs-sidekiq-ac3195635adb)
  - [Migration Guide from Sidekiq](https://www.bigbinary.com/blog/migrating-to-solid-queue-from-sidekiq)

## Deployment

This template creates apps configured for generic production deployment, suitable for any modern hosting platform.

### Render.com (Optional)

When enabled during setup, the template generates Render.com-specific configuration:
- `bin/render-build.sh` - Automated build script for bundle, migrations, and assets
- `render.yaml` - Blueprint file with web service and database configuration
- Health check endpoint (`/up`) configuration
- Choice between Solid Queue as a Puma plugin or separate worker service
- Environment variable guidance for `RAILS_MASTER_KEY` and `WEB_CONCURRENCY`

See [Render's Rails 8 deployment guide](https://render.com/docs/deploy-rails-8) for more details.

### Other Platforms

The template works with minimal or no configuration changes on:
- Fly.io
- Railway
- Heroku
- Any platform supporting Rails 8 and PostgreSQL

## Differences from Original

This is an enhanced version of the original firstdraft template with:
- **Interactive Customization**: Choose which tools to include or use sensible defaults
- **Updated Gems**: amazing_print, annotaterb, dotenv (replacing deprecated versions)
- **Testing Tools**: SimpleCov, WebMock, Shoulda Matchers, Faker
- **Linting Stack**: Prettier, ESLint, Stylelint, erb_lint (optional)
- **Security Tools**: Brakeman, bundler-audit
- **Performance Tools**: Goldiloader, rack-mini-profiler, Skylight
- **Monitoring & Analytics**: Error monitoring (Rollbar/Honeybadger), Ahoy + Blazer
- **Database Flexibility**: Single vs. multi-database setup, UUID support
- **Deployment Options**: Render.com-specific configuration available
- **Modern Production Configuration**: Generic setup for any platform
- **Comprehensive Documentation**: Detailed README and contributing guidelines

## Contributing

Pull requests are welcome! Please ensure any new gems or configurations:
1. Are actively maintained
2. Add clear value for most Rails applications
3. Include appropriate documentation
4. Follow the incremental commit pattern

## License

MIT
