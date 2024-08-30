class UsersController < ApplicationController
  def me
    render json: {
      status: 200,
      data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
    }
  end

  def show
    user = User.find_by(username: params[:username])

    if user
      render json: {
        status: 200,
        data: UserSerializer.new(user).serializable_hash[:data][:attributes]
      }
    else
      render json: {status: 404, error: "User not found"}
    end
  end

  def search
    query = params[:query]
    users = User.where("username LIKE ?", "%#{query}%").limit(5)
    render json: users.map { |user| {username: user.username}}
  end

  def update
    if current_user.update(user_params)
      render json: { status: 200, data: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
    else
      render json: { status: 422, errors: current_user.errors.full_messages }
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :bio, :profile_picture, :profile_banner)
  end
end
