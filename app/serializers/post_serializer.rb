class PostSerializer
  include JSONAPI::Serializer

  attributes :id, :post, :user_id, :created_at
end