class LikeSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :user_id, :post_id
end