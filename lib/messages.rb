module DirectMessages
  def self.tsina_msg(text)
    access_token = nil
    File.open(Rails.root.join('config', 'tsina_access_token').to_s, 'r') do |f|
      access_token = Marshal.load f
    end
    
    if access_token
      response = access_token.get 'http://api.t.sina.com.cn/statuses/public_timeline.json?count=1'
      p response.body
    end
  end
end