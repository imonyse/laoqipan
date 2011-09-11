class NotificationsController < ApplicationController
  def notify
    auth = params[:auth]
    if auth == PRIVATE_CONFIG["notification_auth_token"]
      mails = Notification.all(:conditions => ["send_time < ?", Time.now])

      mails.each do |mail|
        begin
          user = User.find(mail.user_id)
          game = Game.find(mail.game_id)
        rescue ActiveRecord::RecordNotFound
          mail.destroy
          next
        end
        
        if game.status != 1 and user.email.present? and user.email_confirmed
          Mailer.notify(:email => user.email, 
                        :name => user.name, 
                        :domain => request.env['HTTP_HOST'],
                        :game => game.id,
                        :key => Crypto.encrypt("#{user.id}:#{user.salt}")).deliver
        end
    
        mail.destroy
      end
    end
    
    redirect_to root_url
  end
end
