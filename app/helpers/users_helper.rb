module UsersHelper
  def uploader?(user)
    user.role.to_i == 1
  end
end
