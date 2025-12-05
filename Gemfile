source "https://rubygems.org"

# Khai báo đúng phiên bản Ruby trên máy bạn
ruby "3.4.7"

# Rails version
gem "rails", "~> 8.1.1"

# DÙNG SQLITE3 (Đơn giản, không cần cài đặt server)
gem "sqlite3", ">= 1.4"

# Các thư viện hỗ trợ
gem "propshaft"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

# QUAN TRỌNG: Thư viện múi giờ bắt buộc cho Windows
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.2"
gem "devise", "~> 4.9"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end