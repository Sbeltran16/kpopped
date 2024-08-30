class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :username, :bio

  attribute :posts do |user|
    user.posts.map do |post|
      {
        id: post.id,
        content: post.post,
        created_at: post.created_at
      }
    end
  end

  attribute :profile_picture_url do |user|
    Rails.application.routes.url_helpers.rails_blob_url(user.profile_picture, only_path: true) if user.profile_picture.attached?
  end

  attribute :profile_banner_url do |user|
    Rails.application.routes.url_helpers.rails_blob_url(user.profile_banner, only_path: true) if user.profile_banner.attached?
  end


end
