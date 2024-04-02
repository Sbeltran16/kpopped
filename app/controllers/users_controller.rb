class UsersController < ApplicationController
  def me
    render json: {
      status: 200,
      data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
    }
  end
end
