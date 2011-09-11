class Notice < ActiveRecord::Base
  def self.latest_zh
    notice = Notice.where("lang='zh'").order('updated_at DESC').limit(1)[0]
    return notice.body if !notice.nil?
  end
  
  def self.latest_en
    notice = Notice.where("lang='en'").order('updated_at DESC').limit(1)[0]
    return notice.body if !notice.nil?
  end
end
