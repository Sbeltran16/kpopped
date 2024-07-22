class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  validates :post, presence: true

  def like_count
    likes.count
  end


  scope :reverse_chrono, -> { order(created_at: :desc)}
end
