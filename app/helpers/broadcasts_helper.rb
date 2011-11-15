module BroadcastsHelper
  def markdown(text)
    options = [:hard_wrap, :filter_html, :autolink, :gh_blockcode, :fenced_code]
    syntax_on(Redcarpet.new(text, *options).to_html).html_safe
  end
  
  def syntax_on(html)
    html.gsub(/\<pre( lang="(.+?)")?\>\<code\>(.+?)\<\/code\>\<\/pre\>/m) do
          CodeRay.scan($3, $2).div(:css => :class)
    end
  end
end
