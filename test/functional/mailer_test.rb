require 'test_helper'

class MailerTest < ActionMailer::TestCase
  def test_account_recovery
    user = Factory(:user)
    email = Mailer.recovery(:key => "#{user.id}:#{user.salt}",
                            :email => user.email, :domain => "localhost/recovery_session").deliver
    assert !ActionMailer::Base.deliveries.empty?
    
    assert_equal([user.email], email.to)
    assert_equal(I18n.t(:account_recovery), email.subject)
  end
  
  def test_email_confirmation
    user = Factory(:user)
    email = Mailer.confirm(:key => "#{user.id}:#{user.salt}",
                           :email => user.email, :domain => "localhost/confirm_email").deliver
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal([user.email], email.to)
    assert_equal(I18n.t(:email_confirmation), email.subject)
  end
end
