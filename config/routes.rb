Rails.application.routes.draw do
  root "home#index"

  # Devise - đơn giản không cần controllers custom
  devise_for :users
  
  # Redirect các trang devise về trang chủ
  devise_scope :user do
    get '/users/sign_in', to: redirect('/')
    get '/users/sign_up', to: redirect('/')
    get '/users/sign_out', to: 'devise/sessions#destroy'
    get '/users/password/new', to: redirect('/')
    get '/users/password/edit', to: redirect('/')
  end

  # Để có nút "+ Thêm User" trong admin
  resources :users, only: [:new, :create, :destroy]

  # ===== SINH VIÊN =====
  get '/student/home',          to: 'courses#student_home',      as: :student_dashboard
  get '/student/course',        to: 'courses#my_courses',        as: :student_courses
  get '/student/course/lich_hoc', to: 'courses#student_schedule', as: :student_schedule
  get '/student/results',       to: 'courses#student_results',   as: :student_results
  get '/student/profile',       to: 'courses#student_profile',   as: :student_profile
  resources :profile_requests, only: [:new, :create]

  # ===== ADMIN =====
  get '/admin', to: 'users#index', as: :admin_root

  scope "/admin", as: :admin do
    resources :users, only: [:index, :new, :create, :destroy]
    resources :terms, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :profile_requests, only: [:index] do
      member do
        patch :approve
        patch :reject
        get :approve   # Hỗ trợ GET
        get :reject    # Hỗ trợ GET
      end
    end
    resources :reminders, only: [:create, :destroy]
    resources :courses, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :scores, only: [:index, :update]
  end

  # ===== CÔNG KHAI (chỉ tạo môn + đăng ký) =====
  resources :courses, only: [:new, :create] do
    resources :enrollments, only: [:create, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end