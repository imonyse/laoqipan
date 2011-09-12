class Board

  constructor: (@board_size, @first_color, @board_id) ->
    @stone_radius     = 12
    @board_edge       = 40.5
    @board_square     = @stone_radius*2 + 1
    @board_image_size = @board_edge*2 + (@board_size - 1) * @board_square
    @star_radius      = 3
    @color_in_turn    = @first_color

    @status           = 0
    # color of stone to be captured
    @captured_color   = "e"
    # name of dot who is in ko status
    @ko_dot           = null
    @last_move        = null
    @draw_last_move   = true
    @dots_of_star     = ["dd", "dj", "dp","jd", "jj", "jp", "pd", "pj", "pp"]
    @show_step        = false
    @step_count       = 0
    @dots             = []
    @dots_checked     = []
    @to_be_captured   = []
    
    @dead_black_count = 0
    @dead_white_count = 0
    
    if $("##{@board_id}").length
      @canvas = $("##{@board_id}").get(0)
    else
      jquery_canvas = $(document.createElement('canvas')).attr("id","#{@board_id}")
      jquery_canvas.appendTo('body')
      @canvas = jquery_canvas.get(0)
      
    @canvas.width = @canvas.height = @board_image_size
    @context_2d = @canvas.getContext("2d")
    @draw_game()
    
  draw_game: ->
    # @context_2d.beginPath()
    # @context_2d.strokeStyle = '#000'
    # # vertical lines
    # for x in [@board_edge..(@board_image_size - @board_edge)] by @board_square
    #   @context_2d.moveTo x, @board_edge
    #   @context_2d.lineTo x, @board_image_size - @board_edge
    #   
    # # horizontal lines
    # for y in [@board_edge..(@board_image_size - @board_edge)] by @board_square
    #   @context_2d.moveTo @board_edge, y
    #   @context_2d.lineTo @board_image_size - @board_edge, y
    #   
    # # board coordinates
    # @context_2d.fillStyle = '#000'
    # @context_2d.font = 'bold 15px sans-serif'
    # alphabet = "ABCDEFGHJKLMNOPQRST"
    # for i in [0...alphabet.length]
    #   # top coordinates
    #   @context_2d.fillText(alphabet[i], @board_square*i+@board_edge-5.5, @board_edge/2)
    #   # bottom coordinates
    #   @context_2d.fillText(alphabet[i], @board_square*i+@board_edge-5.5, @board_image_size - @board_edge/2 + 11)
    #   
    # for i in [0...@board_size]
    #   # left coordinates
    #   if i < 9
    #     @context_2d.fillText(i+1, @board_edge/2-8, @board_image_size - @board_square*i - @board_edge + 4)
    #   else
    #     @context_2d.fillText(i+1, @board_edge/2-12, @board_image_size - @board_square*i - @board_edge + 4)
    #     
    #   # right coordinates
    #   if i < 9
    #     @context_2d.fillText(i+1, @board_image_size - @board_edge + 18, @board_image_size - @board_square*i - @board_edge + 4)
    #   else
    #     @context_2d.fillText(i+1, @board_image_size - @board_edge + 14, @board_image_size - @board_square*i - @board_edge + 4)
    #   
    # @context_2d.closePath()
    # @context_2d.stroke()
    # @context_2d.fill()
    if @status == 0
      @init_dots()
    else if @status == 1
      @draw_dots()
      
  draw_star: (x, y)->
    @context_2d.beginPath()
    @context_2d.arc x, y, @star_radius, 0, Math.PI*2, false
    @context_2d.closePath()
    @context_2d.fillStyle = '#000'
    @context_2d.fill()
    
  draw_black_stone: (x, y) ->
    @context_2d.beginPath()
    @context_2d.arc x, y, @stone_radius, 0, Math.PI*2, false
    @context_2d.closePath()
    @context_2d.fillStyle = '#000'
    @context_2d.fill()
    
  draw_white_stone: (x, y) ->
    @context_2d.beginPath()
    @context_2d.arc x, y, @stone_radius, 0, Math.PI*2, false
    @context_2d.closePath()
    @context_2d.fillStyle = '#fff'
    @context_2d.fill()
    @context_2d.strokeStyle = '#666'
    @context_2d.stroke()
    
  draw_last_mark: (dot) ->
    if not @draw_last_move then return
    if @show_step
      dot.show_dot_step '#f00'
    else
      @context_2d.beginPath()
      @context_2d.arc dot.x, dot.y, @stone_radius/2, 0, Math.PI*2, false
      @context_2d.closePath()
      
      if dot.owner is "b"
        @context_2d.strokeStyle = '#fff'
      else
        @context_2d.strokeStyle = '#000'
      @context_2d.stroke()
      
    @last_move = dot
    
  block_last_mark: -> @draw_last_move = false
  
  dredge_last_mark: -> @draw_last_move = true
  
  pass: -> @color_in_turn = if @color_in_turn is "b" then "w" else "b"
      
  init_dots: ->
    alphabet = "abcdefghijklmnopqrs".split ""
    for i in [0...alphabet.length]
      for j in [0...alphabet.length]
        dot = new BoardDot alphabet[i]+alphabet[j], @board_edge + @board_square*i, @board_edge + @board_square*j, @
        if dot.is_star
          @draw_star dot.x, dot.y
          
        @dots[@dots.length] = dot
        
    @status = 1
    
  draw_dots: ->
    for dot in @dots
      if dot.is_star
        @draw_star dot.x, dot.y
      if dot.owner == "b"
        @draw_black_stone dot.x, dot.y
      else if dot.owner == "w"
        @draw_white_stone dot.x, dot.y
      if @show_step and dot.owner isnt 'e'
        dot.show_dot_step()
    return
        
  get_cursor_position: (e) ->
    closest = null
    if typeof e.pageX isnt 'undefined' and typeof epageY isnt 'undefined'
      x = e.pageX
      y = e.pageY
    else
      x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
      y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
    
    x -= $("##{@board_id}").offset().left
    y -= $("##{@board_id}").offset().top
    
    for dot in @dots
      dx = Math.abs(dot.x - x)
      dy = Math.abs(dot.y - y)
      cur = Math.sqrt(dx*dx + dy*dy)
      if cur > @stone_radius
        continue
      
      unless min? or min <= cur
        closest = dot
        min = cur
        
    return closest
    
  draw_fake_stone: (dot) ->
    @refresh()
    if @last_move? then @draw_last_mark @last_move
    
    @context_2d.beginPath()
    @context_2d.arc dot.x, dot.y, @stone_radius, 0, Math.PI*2, false
    @context_2d.closePath()
    
    if @color_in_turn is "b"
      @context_2d.fillStyle = 'rgba(0, 0, 0, 0.6)'
    else if @color_in_turn is "w"
      @context_2d.fillStyle = 'rgba(255, 255, 255, 0.6)'
    @context_2d.fill()
    
  on_dot_click: (dot) ->
    if dot?
      if @ko_dot?
        if dot.name is @ko_dot
          return false
        else
          @ko_dot = null
      # add stone, then check liberties
      if dot.occupy @color_in_turn
        @dots_checked = []
        if @is_alive dot
          dot.check_nearby_dots true
        else
          dot.check_nearby_dots false
          if @captured_color is dot.owner or @captured_color is 'e'
            @to_be_captured[@to_be_captured.length] = dot
            
        @capture_stones()
        @captured_color = 'e'
        
        if dot.step != -1
          @step_count++
          dot.step = @step_count
        if window.refresh
          @refresh()
          
        @draw_last_mark dot

      return true
    
    return false
  
  find_stone_by_name: (name) ->
    for dot in @dots
      if name is dot.name
        return dot
    return null
    
  find_stone_by_coordinates: (co) ->
    if co.length > 3 or co.length < 2
      throw "invalid coordinates"
      
    name_set = "abcdefghijklmnopqrs"
    x = "ABCDEFGHJKLMNOPQRST".indexOf co[0].toUpperCase()
    y = @board_size - parseInt co[1]+co[2], 10
    
    @find_stone_by_name name_set[x] + name_set[y]
    
  add_examined: (name) ->
    for e in @dots_checked
      if e is name
        return false
        
    @dots_checked[@dots_checked.length] = name
    return true
  
  # add stone to the capture list
  # return true on success, false if dot is already in the list
  add_captured: (dot) ->
    rc = true
    if @captured_color isnt "e"
      if @captured_color isnt dot.owner
        @captured_color = "e"
        @to_be_captured = []
    else
      for dead in @to_be_captured
        if dead.name is dot.name
          rc = false 
          break
    
    if rc
      @to_be_captured[@to_be_captured.length] = dot
      @captured_color = dot.owner
      
    return rc
  
  capture_stones: ->
    for dot in @to_be_captured
      if dot.owner is 'b'
        @dead_black_count++
      else if dot.owner is 'w'
        @dead_white_count++
      dot.owner = "e"
      dot.step = 0
    
    # update stone capture status
    $('#black_captured').text(@dead_black_count)
    $('#white_captured').text(@dead_white_count)
    @to_be_captured = []
    
  # @flag: true => same color survive, false => same color has no liberties, too
  check_with_capture: (examinee, examiner, flag) ->
    @add_examined examiner.name
    
    if typeof examinee isnt "undefined"
      if examinee.owner is "e" then return
      
      if flag
        if examinee.owner isnt examiner.owner and examinee.owner isnt "e"
          if not @is_alive examinee
            @add_captured examinee
      else
        # check opponent stone without liberties
        if examinee.owner isnt examiner.owner
          if not @is_alive examinee
            @add_captured examinee
        # if stones to be captured has same color of examiner
        if examinee.owner is examiner.owner
          # if we have same color stone in capture list
          if @captured_color is examinee.owner
            @add_captured examinee

    if flag
      if @captured_color isnt examiner.owner
        @capture_stones()
    else
      if examinee.owner isnt examiner.owner
        @capture_stones()
    
  is_alive: (dot) ->
    rc = false
    if dot.owner is "e" then return false
    @add_examined dot.name
    dots_nearby = dot.get_nearby_dots()
    
    for e in dots_nearby
      if e.owner is "e"
        # at least one liberty
        if e.name not in @dots_checked
          rc = true
          break
    
    # dot has no liberties, check nearby stones
    if rc isnt true
      for e in dots_nearby
        if e.owner is dot.owner
          if e.name not in @dots_checked
            # found an ally, recursive check this ally
            rc = @is_alive e
            if rc is true
              @to_be_captured = []
              break
            else
              # ally has no liberty too, time to die...
              @add_captured e
              
    if rc is true
      @dots_checked = []
    return rc
    
  refresh : ->
    @context_2d.clearRect(0, 0, @board_image_size, @board_image_size)
    @draw_game()
    
  reset : ->
    @step_count = 0
    for dot in @dots
      dot.reset()
    @color_in_turn = @first_color
    @dead_black_count = 0
    @dead_white_count = 0
    @refresh()
    
  click_via_coordinates: (coordinates, color) ->
    if color?
      @color_in_turn = color
    if coordinates.length > 3 or coordinates.length < 2
      throw 'invalid coordinates'
    
    dot = @find_stone_by_coordinates coordinates
    @on_dot_click dot
    
  click_via_name: (name, color) ->
    if color?
      @color_in_turn = color
      
    if name.length != 2
      if name.length != 0
        throw 'invalid sgf move name'
        
    if name is ''
      if @color_in_turn is "b"
        @color_in_turn = 'w'
      else if @color_in_turn is 'w'
        @color_in_turn = 'b'
    else
      dot = @find_stone_by_name name.toLowerCase()
      @on_dot_click dot
      
  set_text : (dot_name, text) ->
    if dot_name.length != 2 then throw 'invalid sgf move name'
    dot = @find_stone_by_name dot_name.toLowerCase()
    dot.set_text text
    
  click : (click_fn) ->
    @canvas.addEventListener('click', click_fn, false)
    
  remove_click_fn : (click_fn) ->
    @canvas.removeEventListener('click', click_fn, false)
      
class BoardDot

  constructor: (@name, @x, @y, @parent) ->
    @step = 0
    @is_star = false
    for v in @parent.dots_of_star
      if v == @name
        @is_star = true
        break
    @owner = "e"
  
  occupy: (color) ->
    if @owner isnt "e" 
      return false
      
    if @parent.color_in_turn is "b"
      @parent.draw_black_stone @x, @y
      @parent.color_in_turn = "w"
    else if @parent.color_in_turn is "w"
      @parent.draw_white_stone @x, @y
      @parent.color_in_turn = "b"
      
    @owner = color
    return true
  
  reset: ->
    @owner = "e"
    @step = 0
    
  set_text: (text) ->
    @parent.context_2d.clearRect(@x-6, @y-5, 12, 12);
    @parent.context_2d.fillStyle = "#E9C2A6";
    @parent.context_2d.fillRect(@x-6, @y-5, 12, 12);
    @parent.context_2d.fillStyle = "#000";
    @parent.context_2d.font = "bold 18px Monospace";
    @parent.context_2d.fillText(text, @x-5, @y+5);
    
  show_dot_step: (color) ->
    return if @step is -1
    if @step is 0
      @step = @parent.step_count + 1
    
    if color?
      @parent.context_2d.fillStyle = color
    else
      if @owner is "b"
        @parent.context_2d.fillStyle = '#fff'
      else
        @parent.context_2d.fillStyle = '#000'
    
    @parent.context_2d.font = '14px sans serif'
    y = @y + 4
    if @step < 10
      x = @x - 3;
    else if @step < 100
      x = @x - 6
    else
      x = @x - 10
    @parent.context_2d.fillText(@step, x, y)
    
  get_dot_from: (pos) ->
    alphabet = 'abcdefghijklmnopqrs'
    my_x_index = alphabet.indexOf @name[0]
    my_y_index = alphabet.indexOf @name[1]
    if pos is "left"
      if my_x_index > 0
        x = my_x_index - 1
        y = my_y_index
    else if pos is "right"
      if my_x_index < 18
        x = my_x_index + 1
        y = my_y_index
    else if pos is "top"
      if my_y_index > 0
        x = my_x_index
        y = my_y_index - 1
    else if pos is "bottom"
      if my_y_index < 18
        x = my_x_index
        y = my_y_index + 1
        
    if typeof x isnt 'undefined' and typeof y isnt 'undefined'
      return @parent.find_stone_by_name(alphabet[x] + alphabet[y])
    else
      return null
  
  get_nearby_dots: ->
    dots = []
    for w in ["left", "right", "top", "bottom"]
      dot = @get_dot_from w
      if dot?
        dots[dots.length] = dot
      else
        continue
        
    return dots
     
  # @flag: true => sibling dots of same color live
  #        false => sibling dots of same color die
  check_nearby_dots: (flag) ->
    dots = @get_nearby_dots()
    
    if not flag
      # this dot has no liberties, check ko status first
      if not @has_ally()
        # and it has no allies
        for dot in dots
          if not dot.has_ally()
            if @parent.ko_dot?
              # there are more than one stones nearby surrounded by opponents
              # so it's not in ko status
              @parent.ko_dot = null
              break
            else
              @parent.ko_dot = dot.name
              
    for dot in dots
      @parent.check_with_capture dot, @, flag
    @parent.capture_stones()
          
  has_ally: ->
    dots = @get_nearby_dots()
    
    for dot in dots
      if dot.owner is @owner or dot.owner is 'e'
        return true
    
    return false
    
window.bind_review = ->
  on_review_click

window.on_review_click = (e) ->
  move = {}
  dot = review.board.get_cursor_position e
  if dot?
    if dot.owner isnt 'e' then return
    if review.board.on_dot_click(dot) is true
      key = dot.owner.toUpperCase()
      value = dot.name
      
      branch = review.branch_start_with(key, value)
      if !review.master.property[review.step+1] 
        # at the end of master node
        if branch? 
          # and clicked dot included in branches
          # track node path
          if review.track[review.track.length-1] isnt branch
            review.track.push(branch)
          # assign branch property to @master
          review.master = branch
          review.step   = 1
        else if review.master.branches.length > 0
          # clicked dot not included in current branches
          # so, create a new branch
          data = {}
          data[key] = value
          new_branch = create_branch(data)
          review.fork_branches(new_branch)
          if review.track[review.track.length-1] isnt branch
            review.track.push(new_branch)
          review.master = new_branch
          review.step   = 1
        else
          # at the end of master node, have no branches
          data = {}
          data[key] = value
          review.master.property.push(data)
          review.step++
      else
        # not at the end of master branch
        next_node = review.master.property[review.step+1]
        if next_node[key] is value
          # click node is the next node
          return
        else
          data = {}
          data[key] = value
          new_branch = create_branch(data)
          review.fork_branches(new_branch)
          if review.track[review.track.length-1] isnt branch
            review.track.push(new_branch)
          review.master = new_branch
          review.step   = 1
        
      review.sgf_json = review.track[0]
      $('#game_review').attr('sgf', to_sgf(review.sgf_json))

window.bind_click = ->
  on_player_click
window.on_player_click = (e) ->
  move           = {}
  game_mode      = $('#game').attr('mode')
  game_status    = $('#game').attr('status')
  black_player   = $('#game').attr('black_player')
  white_player   = $('#game').attr('white_player')
  current_player = $('#game').attr('current_player')
  current_user   = $('#game').attr('current_user')
  if game_mode isnt 0
    if current_player isnt current_user or game_status is '1'
      return
  
  dot = player.board.get_cursor_position e
  if dot?
    if dot.owner isnt 'e' then return
    player.board.draw_fake_stone dot
    if clock_status is 0
      rattle_clock()
    window.pendding_move = ->
      if player.board.on_dot_click(dot) is true
        move[dot.owner.toUpperCase()] = dot.name
        player.parser.update_game move
        if black_player is current_player
          $('#game').attr('current_player', white_player)
        else
          $('#game').attr('current_player', black_player)
        # for better user experience
        $('#pass').hide()
        $('#score').hide()
        $('#resign').hide()
        $('#clock').hide()
        if window.board_game_id?
          $.post('http://' + window.location.host + '/games/' + window.board_game_id  + '/moves', {"sgf":$("#game").attr("sgf"), "player_id":$("#game").attr("current_user")})

window.post_comments = ->
  (e) ->
    if e.keyCode is 13
      if e.ctrlKey
        $('#post_button').trigger('click')
        
window.bind_key_fn = ->
  (e) ->
    charCode = e.which
    charStr = String.fromCharCode charCode
    switch charStr
      when "n" then $("#next").trigger("click")
      when "p" then $("#prev").trigger("click")
      when "a" then $("#start").trigger("click")
      when "e" then $("#end").trigger("click")
      when "s" then $("#show_steps").trigger("click")

      
window.play_sound = (name, volume) ->
  if sound_enabled and $.inArray(name, loaded_sounds) isnt -1
    try
      sound = $('#'+name+'_sound').get(0)
      sound.volume = volume
      sound.currentTime = 0
      sound.play()
    catch err
      alert('sound error: '+err)
      loaded_sounds.splice($.inArray(name, loaded_sounds), 1)
      
window.create_thumbnail = ->
  size = 80
  canvas = document.getElementById('board')
  dataURL = canvas.toDataURL('image/png')
  copy = document.createElement('canvas')
  copy.width = size
  copy.height = size
  
  source_image = new Image()
  source_image.src = dataURL
  ctx = copy.getContext('2d')
  source_image.onload = ->
    copy_bg = new Image()
    copy_bg.src = '/assets/default_board.jpg'
    copy_bg.onload = ->
      ctx.drawImage(copy_bg, 0, 0, size, size)
      ctx.drawImage(source_image, 0, 0, size, size)
      data = copy.toDataURL('image/png').replace(/^data:image\/(png);base64,/, "")
      $.post('http://' + window.location.host + '/games/' + window.board_game_id + '/thumbnails', {'image_data':data})
    
window.Board = Board
window.BoardDot = BoardDot
window.refresh = true
window.sound_enabled = true
window.loaded_sounds = new Array()
window.pendding_move = null
    

    