class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
        bookings_path
    end

    private

    def user_not_authorized
        flash[:alert] = 'You are not authorized to perform this action.'
        # render action_name, status: :forbidden
        redirect_back_or_to(root_path)
    end
end
