class Post < ApplicationRecord
  belongs_to :user

  validates :post, presence: true

  scope :reverse_chrono, -> { order(created_at: :desc)}
end
