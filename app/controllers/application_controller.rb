class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: extra_params)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_params)
  end

  def extra_params
    %i[username email password]
  end
end
