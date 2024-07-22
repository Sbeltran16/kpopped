class PostSerializer
  include JSONAPI::Serializer

  attributes :id, :post, :user_id, :created_at

  has_many :likes, serializer: LikeSerializer

  attribute :like_count do |post|
    post.likes.count
  end
end