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
end
