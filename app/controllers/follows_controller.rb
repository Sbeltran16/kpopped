class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    followee = User.find(params[:followee_id])
    current_user.followees << followee
    render json: {status: 'success', message: "Followed #{followee.username}"}
  end

  def destroy
    followee = User.find(params[:id])
    current_user.followees.destroy(followee)
    render json: {status: 'success', message: "Unfollowed #{followee.username}"}
  end

  def status
    user = User.find_by(username: params[:username])
    if user
      is_following = current_user.following?(user)
      render json: {isFollowing: is_following}
    else
      render json: { status: 404, error: "User Not Found"}, status: :not_found
    end
  end

  def followed_posts
    followed_users = current_user.followees.pluck(:id)
    posts = Post.where(user_id: followed_users).order(created_at: :desc).includes(:user)

    serialized_posts = posts.map do |post|
      {
        id: post.id,
        post: post.post,
        user_id: post.user_id,
        username: post.user.username, # Include username here
        created_at: post.created_at,
        updated_at: post.updated_at
      }
    end

    render json: serialized_posts
  end

end
