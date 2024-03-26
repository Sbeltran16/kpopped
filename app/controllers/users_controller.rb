class UsersController < ApplicationController
  def me
    puts current_user

    render json: {
      status: 200,
      data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
    }
  end
end
