# Redcarpet will escape html key words, 
# and CodeRay escape it the second time ...
# So we need to protect our code text.
# Idea borrowed from ryan's railscasts source code

class CodeFormatter
  def initialize(text)
    @text = text
    md_render = Redcarpet::Render::HTML.new(:filter_html => true, :hard_wrap => true)
    extensions = {
      :no_intra_emphasis => true, 
      :autolink => true, 
      :fenced_code_blocks => true
    }
    @markdown = Redcarpet::Markdown.new(md_render, extensions)
  end
  
  def to_html
    text = @text.clone
    codes = []
    text.gsub!(/^``` ?(.*?)\r?\n(.+?)\r?\n```\r?$/m) do |match|
      code = { 
        :id => "CODE#{codes.size}ENDCODE", 
        :name => ($1.empty? ? nil : $1), 
        :content  => $2
      }
      codes << code
      "\n\n#{code[:id]}\n\n"
    end
    html = @markdown.render(text)
    codes.each do |code|
      html.sub!("<p>#{code[:id]}</p>") do
        <<-EOS
          #{CodeRay.scan(code[:content], code[:name]).div(:line_numbers => :table)}
        EOS
      end
    end
    html
  end
  
end