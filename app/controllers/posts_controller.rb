class PostsController < ApplicationController
  def create
    post = current_user.posts.create(post_params)

    if post.persisted?
      render json: { status: 200, message: 'Success'}
    else
      render json: { status: 400, message: 'Not Successful Missing Params'}
    end
  end

  def index
    serialized_data = PostSerializer.new(current_user.posts).serializable_hash[:data]

    render json: {
      data: PostSerializer.new(current_user.posts).serializable_hash[:data]
    }
  end





  protected

  def post_params
    params.permit([:post])
  end
end
