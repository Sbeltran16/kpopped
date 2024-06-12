class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :username

  attribute :posts do |user|
    user.posts.map do |post|
      {
        id: post.id,
        content: post.post,
        created_at: post.created_at
      }
    end
  end


end
