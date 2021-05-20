source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 2.6.5'

#
#  Core
#

gem 'rails', '~> 5.2.1'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'pg', '>= 0.18', '< 2.0'
gem 'activerecord-postgis-adapter', '~>5'
gem 'rgeo-geojson'
gem 'geocoder'
gem 'puma', '~> 4.3'
gem 'redis', '~> 4.0'
gem 'devise'

#
# View
#

gem 'mini_racer', platforms: :ruby
gem 'bootstrap', '~> 4.5.0'
gem 'jquery-rails'
gem 'font-awesome-rails'
gem 'sass-rails', '~> 5.0'
gem 'jquery-ui-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'devise-i18n'
gem 'devise-bootstrap-views', '~> 1.0'
gem 'redcarpet'
gem 'jquery-tablesorter'

#
# Grouped
#

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'minitest-reporters'
  gem 'capybara', '>= 2.15'
  gem 'rails_best_practices'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
# gem 'capistrano-rails'
end

group :test do
  gem 'selenium-webdriver'
  gem 'webdrivers', '~> 3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
