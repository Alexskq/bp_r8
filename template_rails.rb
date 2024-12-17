run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
  #gem "bootstrap", "~> 5.2"
  #gem "sassc-rails"
    #gem "font-awesome-sass", "~> 6.1"
    #gem "autoprefixer-rails"
    gem "devise"
    gem "simple_form", github: "heartcombo/simple_form"
    # Added
    gem "tailwindcss-rails"
    gem "simple_form-tailwind"

  RUBY
end

# inject_into_file "Gemfile", after: "group :development, :test do" do
#   "\n  gem \"dotenv-rails\""
  
# end

gem_group :development do
  gem "rails_live_reload"
end


# Assets
########################################
#run "rm -rf app/assets/stylesheets"
#run "rm -rf vendor"
#run "curl -L https://github.com/lewagon/rails-stylesheets/archive/master.zip > stylesheets.zip"
#run "unzip stylesheets.zip -d app/assets && rm -f stylesheets.zip && rm -f app/assets/rails-stylesheets-master/README.md"
#run "mv app/assets/rails-stylesheets-master app/assets/stylesheets"

# Layout
########################################

# gsub_file(
#   "app/views/layouts/application.html.erb",
#   '<meta name="viewport" content="width=device-width,initial-scale=1">',
#   '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
# )

# Flashes
########################################
file "app/views/shared/_flashes.html.erb", <<~HTML
  <% if notice %>
   <div role="alert" class="alert alert-info">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        class="h-6 w-6 shrink-0 stroke-current">
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
      </svg>
      <span><%= notice %></span>
    </div>
  <% end %>
  <% if alert %>
    <div role="alert" class="alert alert-error">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-6 w-6 shrink-0 stroke-current"
        fill="none"
        viewBox="0 0 24 24">
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span><%= alert %></span>
    </div>
  <% end %>
HTML

#run "curl -L https://raw.githubusercontent.com/lewagon/awesome-navbars/master/templates/_navbar_wagon.html.erb > app/views/shared/_navbar.html.erb"

inject_into_file "app/views/layouts/application.html.erb", after: "<body>" do
  <<~HTML
    <%= render "shared/flashes" %>
  HTML
end

# README
########################################
# markdown_file_content = <<~MARKDOWN
#   Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.
# MARKDOWN
# file "README.md", markdown_file_content, force: true

# Generators
########################################
# generators = <<~RUBY
#   config.generators do |generate|
#     # generate.assets false
#     # generate.helper false
#     # generate.test_framework :test_unit, fixture: false
#   end
# RUBY

# environment generators

# General Config
########################################
# general_config = <<~RUBY
#   config.action_controller.raise_on_missing_callback_actions = false if Rails.version >= "7.1.0"
# RUBY

# environment general_config

########################################
# After bundle
########################################
after_bundle do

  # Generators: db + simple form + pages controller
  ########################################
  rails_command "db:reset"
  generate("simple_form:install")
  generate("simple_form:tailwind:install")
  generate(:controller, "pages", "home", "--skip-routes")
  
  # Routes
  ########################################
  route 'root to: "pages#home"'
  
  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT
  # Ignore .env file containing credentials.
  .env*
  
  # Ignore Mac and Linux file system files
  *.swp
  .DS_Store
  TXT
  
  # Devise install + user
  ########################################
  generate("devise:install")
  generate("devise", "User")
  
  # Tailwind
  ########################################
  rails_command "tailwindcss:install"
  
  # Application controller
  ########################################
  run "rm app/controllers/application_controller.rb"
  file "app/controllers/application_controller.rb", <<~RUBY
  class ApplicationController < ActionController::Base
    before_action :authenticate_user!
  end
  RUBY
  
  # migrate + devise views
  ########################################
  rails_command "db:migrate"
  generate("devise:views")

  old_link_to = <<~HTML
    <p>Unhappy? <%= link_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete %></p>
  HTML

  new_link_to = <<~HTML
    <p>Unhappy? <%= button_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete %></p>
  HTML
  gsub_file("app/views/devise/registrations/edit.html.erb", old_link_to, new_link_to)

  # Pages Controller
  ########################################
  run "rm app/controllers/pages_controller.rb"
  file "app/controllers/pages_controller.rb", <<~RUBY
    class PagesController < ApplicationController
      skip_before_action :authenticate_user!, only: [ :home ]

      def home
      end
    end
  RUBY

  # Environments
  ########################################
  # environment 'config.action_mailer.default_url_options = { host: "localhost", port:"3000" }', env: "development"
  # environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: "production"

  # Bootstrap & Popper
  ########################################
  # append_file "config/importmap.rb", <<~RUBY
  #   pin "bootstrap", to: "bootstrap.min.js", preload: true
  #   pin "@popperjs/core", to: "popper.js", preload: true
  # RUBY

  # append_file "config/initializers/assets.rb", <<~RUBY
  #   Rails.application.config.assets.precompile += %w(bootstrap.min.js popper.js)
  # RUBY

  # append_file "app/javascript/application.js", <<~JS
  #   import "@popperjs/core"
  #   import "bootstrap"
  # JS

  # append_file "app/assets/config/manifest.js", <<~JS
  #   //= link popper.js
  #   //= link bootstrap.min.js
  # JS
   
  # npm
  if system("which npm > /dev/null 2>&1")
    run "npm i -D daisyui@latest"
  
    # Insérer 'require("daisyui")' dans tailwind.config.js
    gsub_file "config/tailwind.config.js", /require\('@tailwindcss\/container-queries'\),/ do |match|
      "#{match}\n    require(\"daisyui\"),"
    end
  end

  # Heroku
  ########################################
  run "bundle lock --add-platform x86_64-linux"

  # Dotenv
  ########################################
  # run "touch '.env'"

  # Rubocop
  ########################################
  # run "curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml"

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit made by Arnaud & Alex Wagoners'"
end