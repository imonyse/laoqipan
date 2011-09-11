require 'crypto'

class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  
  before_filter :set_i18n_locale_from_params
  before_filter :mark_user_request, :if => :user_signed_in?
  
  protected
  
    def set_i18n_locale_from_params
      if params[:locale] and I18n.available_locales.include?(params[:locale].to_sym)
        I18n.locale = params[:locale]
      else
        I18n.locale = I18n.default_locale
      end
    end
    
    def default_url_options
      { :locale => I18n.locale }
    end
    
    def mark_user_request
      current_user.update_attribute(:last_request_at, Time.now)
    end
end
