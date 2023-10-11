Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # 顧客用
# URL /customers/sign_in ...
devise_for :customers, controllers: {
  registrations: "public/registrations",
  sessions: 'public/sessions'
}

# 管理者用
# URL /admin/sign_in ...
devise_for :admin, skip: [:registrations, :passwords] ,controllers: {
  sessions: "admin/sessions"
}


  root to: 'homes#top'
  get 'homes/about' => 'homes#about'
  
  # 会員
  scope module: :public do
  get 'customers/confirm' => "customers#confirm"
  patch 'costomers/out' => "customers#out"
  resources :customers, only: [:show, :edit, :update]
  resources :post_images, only: [:new, :create, :index, :show, :edit, :update, :destroy]

  end
  
  #管理者
  namespace :admin do
  resources :customers, only: [:index, :show]
    
  end

end
