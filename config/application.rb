require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CourseRegistration
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Dòng này giúp Rails 7.1 tự động quản lý thư mục lib (tránh lỗi xung đột)
    config.autoload_lib(ignore: %w(assets tasks))

    # ==========================================
    # CẤU HÌNH QUAN TRỌNG (BẮT BUỘC)
    # ==========================================
    
    # 1. Tự động nạp file trong thư mục app/lib
    # Giúp Rails tìm thấy file 'custom_failure.rb' để xử lý lỗi đăng nhập
    config.autoload_paths << Rails.root.join('app/lib')

    # 2. Thiết lập múi giờ Việt Nam
    config.time_zone = "Hanoi"

    # ==========================================

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.eager_load_paths << Rails.root.join("extras")
  end
end