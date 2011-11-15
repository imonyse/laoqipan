require 'code_formatter'

module BroadcastsHelper
  def markdown(text)
    CodeFormatter.new(text).to_html.html_safe
    # syntax_on(content).html_safe
  end
  
  def syntax_on(html)
    html.gsub(/\<code( class="(.+?)")?\>(.+?)\<\/code\>/m) do
          CodeRay.scan($3, $2).div(:line_numbers => :table)
    end
  end
end
