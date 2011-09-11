class Mailer < ActionMailer::Base
  default :from => "noreply@laoqipan.com"
  
  def recovery(options)
    @key = options[:key]
    @domain = options[:domain]
    mail :to => options[:email], :subject => I18n.t(:account_recovery) do |format|
      format.html
    end
  end
  
  def confirm(options)
    @key = options[:key]
    @domain = options[:domain]
    mail :to => options[:email], :subject => I18n.t(:email_confirmation) do |format|
      format.html
    end
  end
  
  def notify(options)
    @name = options[:name]
    @game_id = options[:game]
    @key = options[:key]
    @domain = options[:domain]
    mail :to => options[:email], :subject => I18n.t(:move_notification) do |format|
      format.html
    end
  end
end
