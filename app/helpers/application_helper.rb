module ApplicationHelper
  def avatar_image_tag(user)
    image_tag user.avatar.url(:small)
  end
  
  def online_status_tag(user)
    if user.online?
      image_tag "online.png", :class => "user_#{user.id}"
    else
      image_tag "offline.png", :class => "user_#{user.id}"
    end
  end
end
