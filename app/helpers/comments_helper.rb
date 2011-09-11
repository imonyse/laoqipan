module CommentsHelper
  def float_via_user(user)
    if user_signed_in? and current_user == user
      "right"
    else
      "left"
    end
  end
end
