module BroadcastsHelper
  def markdown(text)
    options = [:hard_wrap, :filter_html, :autolink, :gh_blockcode, :fenced_code]
    Redcarpet.new(text, *options).to_html.html_safe
  end
end
