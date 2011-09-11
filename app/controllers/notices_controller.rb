class NoticesController < ApplicationController
  def new
    @notice = Notice.new
    
    respond_to do |format|
      if !user_signed_in? or !current_user.admin?
        format.js { render :text => 'admin required', :status => 401 }
      else
        format.js
      end
    end
  end
end
