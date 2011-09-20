require 'net/http'

def fetch_tom_sgf(sgf_url)
  sgf = nil
  sgf_host = 'weiqi.sports.tom.com'
  sgf_path = sgf_url[(sgf_url.index(sgf_host) + sgf_host.length)..-1]


  Net::HTTP.start(sgf_host) do |http|
    response = http.get(sgf_path)
    sgf = response.body
  end

  return sgf.force_encoding('GB18030').encode('UTF-8')
end