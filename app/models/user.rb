class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :posts
  has_many :likes

  #Users who follow the current user
  has_many :followers_relationships, foreign_key: :followee_id, class_name: 'Follow'
  has_many :followers, through: :followers_relationshops, source: :follower

  #Users who the current user follows
  has_many :followees_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :followees, through: :followees_relationships, source: :followee

  #User image and bio addition
  has_one_attached :profile_picture
  has_one_attached :profile_banner
  validates :bio, length: { maximum: 300 }


  def following?(other_user)
    followees.include?(other_user)
  end

end
