class Broadcast < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'author'
  
  default_scope where(:push => true)
  
end


# == Schema Information
#
# Table name: broadcasts
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  body       :text
#  brief      :text
#  author     :integer
#  created_at :datetime
#  updated_at :datetime
#  push       :boolean
#

