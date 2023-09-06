class Users::SessionsController < Devise::SessionsController
  layout "application"

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
end


# class SessionsController < ApplicationController
#   skip_before_action :require_authentication

#   def new
#     @user = User.new
#   end

#   def create
#     @user = User.find_or_initialize_by user_params
#     if @user.save
#       session[:current_user] = @user.id
#       redirect_to games_path, notice: 'Logged in successfully'
#     else
#       render :new
#     end
#   end

#   private

#   def user_params
#     params.require(:user).permit(:name)
#   end
# end
