class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :post_images, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  # フォローしている関連付け
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy

  # フォローされている関連付け
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  # フォローしているユーザーを取得
  has_many :followings, through: :active_relationships, source: :followed

  # フォロワーを取得
  has_many :followers, through: :passive_relationships, source: :follower
  
  #文字制限　最小２文字、最大20字まで
  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true


  #ゲスト用メールアドレス
  GUEST_CUSTOMER_EMAIL = "guest@example.com"

  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |customer|
      customer.password = SecureRandom.urlsafe_base64
      customer.name = "ゲスト"
      # user.confirmed_at = Time.now  # Confirmable を使用している場合は必要
      # 例えば name を入力必須としているならば， user.name = "ゲスト" なども必要
    end
  end


  def guest_customer?
    email == GUEST_CUSTOMER_EMAIL
  end


  # 指定したユーザーをフォローする
  def follow(customer)
    active_relationships.create(followed_id: customer.id)
  end

  # 指定したユーザーのフォローを解除する
  def unfollow(customer)
    active_relationships.find_by(followed_id: customer.id).destroy
  end

  # 指定したユーザーをフォローしているかどうかを判定
  def following?(customer)
    followings.include?(customer)
  end


  # プロフィール画像を取得 (画像がない場合はno_imageアイコンを使用)
  has_one_attached :profile_image

 def get_profile_image(width, height)
  unless profile_image.attached?
    file_path = Rails.root.join('app/assets/images/no_image.jpg')
    profile_image.attach(io: File.open(file_path), filename: 'default-image.jpg', content_type: 'image/jpeg')
  end
  profile_image.variant(resize_to_limit: [width, height]).processed
 end


end
