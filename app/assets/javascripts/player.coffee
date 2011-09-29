poll_timer = 0
window.clock_status = 0
clock_timer = null

jQuery.ajaxSetup({timeout: 30000})

window.notify_message = (current_player) ->
  black_player = $('#game').attr('black_player')
  white_player = $('#game').attr('white_player')
  if current_player is black_player
    alert_name = $('#black_player a').html()
  else
    alert_name = $('#white_player a').html()
  if window.get_locale() is 'zh'
    alert_msg = ", 该你了!"
  else
    alert_msg = ", your turn!"
  $.titleAlert(alert_name+alert_msg, {requireBlur:true, stopOnFocus:true, duration:12000, interval:1000})

window.show_clock = ->
  $("#clock").show()
  $("#pass").show()
  $('#resign').show()
  $('#score').show()

window.hide_clock = ->
  $("#clock").hide()
  $("#pass").hide()
  $('#resign').hide()
  $('#score').hide()

window.stop_clock = ->
  clearTimeout(clock_timer)
  clock_timer = null
  window.clock_status = 0

window.rattle_clock = ->
  window.clock_status = 1
  effects()

window.effects = ->
  $("#clock").effect("highlight", {"color":"#0F0"}, 500)
  if clock_timer?
    clearTimeout(clock_timer)

  clock_timer = setTimeout(effects, 1000)

class Player
  # @flag: false => confirm click mode, true => review click mode
  constructor: (@parser, @target_board_id, @flag) ->
    @sgf_json  = @parser.parse_game()
    @step      = 1
    @poller    = null
    @master    = null
    @linear    = @sgf_json
    @branch_head_nodes = []
    # property line and start step count
    @track     = [@sgf_json]
    @basic_info = @sgf_json.property[0]
    ev = @basic_info.EV || ''
    pb = @basic_info.PB || ''
    br = @basic_info.BR || ''
    pw = @basic_info.PW || ''
    wr = @basic_info.WR || ''
    dt = @basic_info.DT || ''
    re = @basic_info.RE || ''
    if $('#game_review').length and $('#game_review').attr('mode') is "0"
      $('#progame_ev').html(ev)
      $('#progame_black').html(pb+' '+br)
      $('#progame_white').html(pw+' '+wr)
      $('#progame_date').html dt
      $('#progame_result').html re

    handicap = @basic_info.HA
    first_move = @sgf_json.property[1]
    if typeof first_move isnt 'undefined'
      if typeof first_move.B isnt 'undefined'
        first_turn = 'b'
      else if typeof first_move.W isnt 'undefined'
        first_turn = 'w'
    else if typeof handicap isnt 'undefined'
      if handicap > "1"
        first_turn = 'w'
      else
        first_turn = 'b'
    else
      first_turn = 'b'

    @board = new Board 19, first_turn, @target_board_id
    if $('#game')
      mode = $('#game').attr('mode')
      status = $('#game').attr('status')
      if mode isnt 0 and status isnt 0
        if @flag
          @board.click(bind_review())
        else
          @board.click(bind_click())

  pre_stones : ->
    ab = @basic_info.AB
    aw = @basic_info.AW
    if typeof ab isnt 'undefined' then @set_pre_stones(ab, 'b')
    if typeof aw isnt 'undefined' then @set_pre_stones(aw, 'w')
    c = @basic_info.C
    if typeof c isnt 'undefined'
      @show_comments(c)
    @board.color_in_turn = @board.first_color
    @board.step_count = 0

  set_pre_stones : (pos_list, color) ->
    @board.block_last_mark()
    for pos in pos_list
      @board.click_via_name(pos, color)
      @board.find_stone_by_name(pos).step = -1
    @board.dredge_last_mark()

  update : (game_obj) ->
    if game_obj.attr('sgf').length is @parser.data.length
      return
    else
      if @board.last_move?
        last_move_name_before = @board.last_move.name
      else
        last_move_name_before = null
      @parser = new SGF game_obj
      @sgf_json = @parser.parse_game()
      @master = @sgf_json
      @track = [@sgf_json]
      @start()
      @end()

      current_user = $("#game").attr("current_user")
      current_player = $("#game").attr("current_player")
      if current_user is current_player
        show_clock()
        notify_message(current_player)
      else
        hide_clock()

      @show_player_turn()
      
  # This function should be called before fork_branches
  # @key : 'B' or 'W', @value : 'xx'
  # return the branch object on match, else return null
  branch_start_with : (key, value) ->
    if @branch_head_nodes.length > 0
      for e in @branch_head_nodes
        if e[0][key] is value
          return e[1]
          
    return null
      
  # fork branches from current_node position, or 
  # append a new node if at the end of master without branches
  fork_branches : (new_branch) ->
    if typeof @master.property[@step] isnt 'undefined'
      branch_from_origin = {property:[], branches:[]}
      i = @master.property.length - 1
      while i >= 0
        # fetch nodes after current node
        # make these nodes and branches a brand new branch
        if @master.property[i] is @master.property[@step-1]
          branch_from_origin.property = branch_from_origin.property.reverse()
          break
        else
          branch_from_origin.property.push(@master.property[i])
          @master.property.pop()
        i--
      branch_from_origin.branches = @master.branches
      @master.branches = [branch_from_origin]
      @master.branches.push(new_branch)
    else
      # this is the last master node, branch append to branches property
      @track[@track.length-1].branches.push(new_branch)
      
  next : (flag)->
    @master = @sgf_json if @master is null
    if typeof @master isnt 'undefined'
      cur = @master.property[@step]
      if typeof cur isnt 'undefined'
        if typeof cur.B isnt 'undefined'
          if flag
            @board.click_via_name cur.B
          else
            @board.click_via_name cur.B
            @show_player_turn()
        else if typeof cur.W isnt 'undefined'
          if flag
            @board.click_via_name cur.W
          else
            @board.click_via_name cur.W
            @show_player_turn()
        if typeof cur.C isnt 'undefined'
          @show_comments cur.C
        if typeof cur.LB isnt 'undefined'
          for vt in cur.LB
            mark = vt.split ':'
            @board.set_text(mark[0], mark[1])
        $('#swap').html(@step)
        $('#review_steps').html(@step)
        @step++
    
    # this will mark all branches' first node on the board
    if !@master.property[@step] and @master.branches.length > 0
      count = 1
      for branch in @master.branches
        head_node = branch.property[0]
        if typeof head_node isnt 'undefined'
          if typeof head_node.B isnt 'undefined'
            @board.set_text(head_node.B, count)
          else if typeof head_node.W isnt 'undefined'
            @board.set_text(head_node.W, count)
            
          @branch_head_nodes.push([head_node, branch])
        count++    

    return

  prev : ->
    current_path = @master
    current_steps = @step
    if current_steps is 1
      @track.pop()
    window.refresh = false
    @board.reset()
    @pre_stones()
    
    for path in @track
      @master = path
      @step = 0
      while @master.property[@step]
        if @master is current_path and @step is current_steps - 2
          break
        @next(true)
      
    window.refresh = true
    @next()

  start : ->
    @step = 1
    @board.reset()
    if !@flag
      $('#swap').html('0')
    $('#post_out').html('')

    @pre_stones()

  end : ->
    for path in @track
      cur = path.property
      step = 0
      if typeof cur isnt 'undefined'
        window.refresh = false
        while typeof cur[step] isnt 'undefined'
          @next(true)
          step++
      
        # end stops when master branch meets child branch
        # and show them on the board as numbers
        if path.branches.length > 0
          count = 1
          for branch in path.branches
            head_node = branch.property[0]
            if typeof head_node isnt 'undefined'
              if typeof head_node.B isnt 'undefined'
                @board.set_text(head_node.B, count)
              else if typeof head_node.W isnt 'undefined'
                @board.set_text(head_node.W, count)
            count++
          
    window.refresh = true
    if @step > 1
      @board.draw_last_mark @board.last_move
    
    $('#loader').hide()
    re = @basic_info.RE
    result_notify re if typeof re isnt 'undefined'

  hide_steps : ->
    @board.show_step = false
    @board.refresh()
    @board.draw_last_mark @board.last_move

  show_steps : ->
    @board.show_step = true
    @board.refresh()
    @board.draw_last_mark @board.last_move

  show_comments : (comment) ->
    c = comment.replace /\n/g, '</p><p>'
    $('#sgf_comments').html('<p>'+c+'</p>')

  pass : ->
    current_user = $('#game').attr('current_user')
    current_player = $('#game').attr('current_player')
    pb = $('#game').attr('black_player')
    pw = $('#game').attr('white_player')
    move = {}
    if current_user is current_player
      if pb is current_user
        move['B'] = ''
      else if pw is current_user
        move['W'] = ''
      @parser.update_game(move)

      $.post(window.location.pathname + '/moves', {"sgf":$("#game").attr("sgf"), "moves":"PASS", "player_id":$("#game").attr("current_user")})

  resign : ->
    current_user = $('#game').attr('current_user')
    pb = $('#game').attr('black_player')
    pw = $('#game').attr('white_player')
    if pb is current_user
      winner = 'W'
      move = 'BRESIGN'
    else if pw is current_user
      winner = 'B'
      move = 'WRESIGN'

    @parser.add_winner winner
    $.post(window.location.pathname + '/moves', {"sgf":$("#game").attr("sgf"), "moves":move})

  show_player_turn : ->
    if !@flag
      $('#swap').html(@step)
      if @board.color_in_turn is 'b'
        $('.black_turn').attr("src", "/assets/turn.png")
        $('.white_turn').attr('src', '/assets/stop.png')
      else if @board.color_in_turn is 'w'
        $('.black_turn').attr('src', '/assets/stop.png')
        $('.white_turn').attr('src', '/assets/turn.png')

window.Player = Player




