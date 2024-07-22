class LikesController < ApplicationController
  before_action :authenticate_user!

  def status
    post = Post.find(params[:post_id])
    like = post.likes.find_by(user: current_user)

    render json: {
      liked: like.present?,
      like_count: post.likes.count
    }
  end

  def create
    post = Post.find(params[:post_id])
    like = post.likes.find_or_initialize_by(user: current_user)

    if like.persisted?
      render json: { error: 'You have already liked this post.' }, status: :unprocessable_entity
    else
      like.save
      render json: { success: true, like_count: post.likes.count }
    end
  end

  def destroy
    post = Post.find(params[:post_id])
    like = post.likes.find_by(user: current_user)

    if like
      like.destroy
      render json: { success: true, like_count: post.likes.count }
    else
      render json: { error: 'You have not liked this post.' }, status: :unprocessable_entity
    end
  end

end
