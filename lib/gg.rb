# RAILS_ROOT = File.expand_path("../..", __FILE__)
require 'chunky_png'

class GTP
  def self.run(bot_type, &command)
    if bot_type == 'gnugo'
      new(IO.popen("gnugo --mode gtp", "r+"), &command)
    elsif bot_type == 'fuego'
      new(IO.popen("fuego --config #{RAILS_ROOT}/public/fuego.gtp", "r+"), &command)
    end
  end
  
  def initialize(io)
    @io = io
    
    if block_given?
      begin
        yield self
      ensure
        quit
      end
    end
  end
  
  def quit
    send_command(:quit)
    @io.close
  end
  
  def protocol_version
    send_command(:protocol_version)
  end
  
  def genmove(color)
    send_command(:genmove, color)
  end
  
  def loadsgf(path)
    send_command(:loadsgf, path)
  end
  
  def genmove(color)
    send_command(:genmove, color)
  end
  
  def list_stones(color)
    @io.puts [:list_stones, color].join(" ")
    result = @io.take_while { |line| line != "\n" }.join
    return result.sub(/^=\s/, "").sub(/\n/, "")
  end
  
  def send_command(command, *arguments)
    @io.puts [command, *arguments].join(" ")
    result = @io.take_while { |line| line != "\n" }.join
    
    rc = result.scan(/^=\s[a-zA-Z]*[0-9]*$/)
    if rc.first.nil?
      return rc
    else
      return rc.first.sub(/^=\s/, "").sub(/\n/, "")
    end
  end
end

def score_game(game_id, game_sgf)
  re = nil
  filepath = "#{RAILS_ROOT}/tmp/#{game_id}.sgf"
  File.open(filepath, "w") do |f|
    f.write game_sgf
  end
  
  IO.popen("gnugo --score aftermath #{filepath}") do |f|
    re = f.read
  end
  
  File.delete(filepath)
  return re
end

def generate_thumbnail(game_id, game_sgf)
  black_pos = nil
  white_pos = nil
  
  filepath = "#{RAILS_ROOT}/tmp/#{game_id}.sgf"
  File.open(filepath, "w") do |f|
    f.write game_sgf
  end
  
  GTP.run('gnugo') do |gtp|
    gtp.loadsgf filepath
    black_pos = gtp.list_stones('black').split(" ")
    white_pos = gtp.list_stones('white').split(" ")
  end
  
  File.delete(filepath)

  board = ChunkyPNG::Image.from_file(File.join(File.dirname(__FILE__), *%w[.. app assets images default_board.png]))
  black = ChunkyPNG::Image.from_file(File.join(File.dirname(__FILE__), *%w[.. app assets images black_thumb.png]))
  white = ChunkyPNG::Image.from_file(File.join(File.dirname(__FILE__), *%w[.. app assets images white_thumb.png]))
  # now we have black and white stones' position
  # convert these position to coordinates
  offset = (80.0/531.0)*25
  black_pos.each do |pos|
    x, y = pos_to_coordinates(pos)
    board.compose!(black, 4 + (x * offset).round, 4 + (y * offset).round)
  end
  white_pos.each do |pos|
    x, y = pos_to_coordinates(pos)
    board.compose!(white, 4 + (x * offset).round, 4 + (y * offset).round)
  end
  
  return board
end

def pos_to_coordinates(pos)
  pos.scan /\A([A-HJ-T])(\d{1,2})\z/i
  x = $1.getbyte(0) - "A".getbyte(0) - (pos > "I" ? 1 : 0)
  y = 19 - $2.to_i
  return [x,y]
end

# return a move coordinates, such as "c17", or "PASS", or "resign"
def ai_move(game_id, game_sgf, color)
  re = nil
  filepath = "#{RAILS_ROOT}/tmp/#{game_id}.sgf"
  File.open(filepath, "w") do |f|
    f.write game_sgf
  end
  sleep 3
  
  if color == 'black'
    # fuego looks weird
    game_bot = 'gnugo'
  elsif color == 'white'
    game_bot = 'gnugo'
  end
  GTP.run(game_bot) do |gtp|
    gtp.loadsgf filepath
    re = gtp.genmove color
  end
  
  move = convert_move(re)
  
  File.delete(filepath)
  return move
end

def convert_move(move)
  if move == "PASS"
    return 'pass'
  elsif move == "resign"
    return 'resign'
  else
    alphabet = "ABCDEFGHIJKLMNOPQRS"
    return alphabet["ABCDEFGHJKLMNOPQRST".index(move[0])].downcase + alphabet.reverse[(move[1].to_s + move[2].to_s).to_i - 1].downcase
  end
end
