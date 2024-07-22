class PostsController < ApplicationController
  def create
    post = current_user.posts.create(post_params)

    if post.persisted?
      render json: { status: 200, message: 'Success' }
    else
      render json: { status: 400, message: 'Not Successful Missing Params' }
    end
  end

  def index
    serialized_data = PostSerializer.new(current_user.posts).serializable_hash[:data]

    render json: {
      data: PostSerializer.new(current_user.posts.reverse_chrono).serializable_hash[:data]
    }
  end


  def destroy
    current_user.posts.find_by(id: params[:id]).destroy

    render json: {status: 200, message: "successful deletion"}
  end


  protected

  def post_params
    params.require(:post).permit(:post)
  end
end
