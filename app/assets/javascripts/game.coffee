window.waiting_score = false
window.board_game_id = null
window.jug = null
window.my_jug = null

window.prepare_game = ->
  if $("#game").length
    access = $('#game').attr('access')
    current_player = $('#game').attr('current_player')
    current_user = $('#game').attr('current_user')
    $('#board_info').hide()
    if access isnt '3' or current_player is current_user
      if window.get_locale() is 'zh'
        $('#start_info').html('请等待<br/>与实时服务器建立连接中 ...')
      else
        $('#start_info').html('Please wait<br/>connecting to realtime server ...')
    
    $("#next").removeAttr('onclick')
    $("#prev").removeAttr('onclick')
    $("#start").removeAttr('onclick')
    $("#end").removeAttr('onclick')
    $("#show_steps").removeAttr('onclick')
    
    $("#pass").removeAttr('onclick')
    $("#resign").removeAttr('onclick')
    $("#score").removeAttr('onclick')
    $("#clock").removeAttr('onclick')
    $('#analyse').removeAttr('onclick')
    
    review.board.remove_click_fn() if review?
    player.board.remove_click_fn() if player?

$(document).ready ->
  prepare_game()
  $(".notify_content").hide() if $(".notify_content").length
  $('#side_bar').hide()
  
window.showLoader = (obj) ->
  obj.html("<img src=\"/assets/current_games_loader.gif\" style=\"margin-left:10px\">")
  
window.init_game = ->
  if $('#game').attr('sgf')
    init_board()
    player.pre_stones()
    player.end()
    if $("#game").attr("current_player") is $("#game").attr("black_player")
      $(".black_turn").attr("src", "/assets/turn.png")
      $(".white_turn").attr("src", "/assets/stop.png")
    else if $("#game").attr("current_player") is $("#game").attr("white_player")
      $(".black_turn").attr("src", "/assets/stop.png")
      $(".white_turn").attr("src", "/assets/turn.png")
    current_user = $("#game").attr("current_user")
    current_player = $("#game").attr("current_player")
    if current_user is current_player
      show_clock()
    else
      hide_clock()

    subscribe_game()
    if $('#game').attr('status') is "0"
      if $('#game').attr('requester') isnt "0"
        $.getScript('http://' + window.location.host + '/games/' + window.board_game_id + '/moves')

$(window).load ->
  if window.unsupported
    $('#browser_check_bg').css("opacity":"0.7")
    # center pop up div
    width = document.documentElement.clientWidth
    height = document.documentElement.clientHeight
    pop_width = $('#browser_check').width()
    pop_height = $('#browser_check').height()
    $('#browser_check').css({"position":"absolute", "top":height/2-pop_height/2,"left":width/2-pop_width/2})
    
    $('#browser_check_bg').fadeIn("slow")
    $('#browser_check').fadeIn("slow")
    return
    
  $("#active_games").children('.collapse').click ->
    if $("#notified_games").is(":visible")
      $("#notified_games").hide()
      $(this).css({'background':"url(/assets/expand_alt.png)"})
      $('#active_games').children('.refresh').hide()
    else if $("#notified_games").is(":hidden")
      $("#notified_games").show()
      $(this).css({'background':"url(/assets/collapse_alt.png)"})
      $('#active_games').children('.refresh').show()
      $('#active_games').children('.refresh').click ->
        showLoader($("#notified_games"))
        $.getScript('http://' + window.location.host + '/current_games' + window.location.search)
      showLoader($("#notified_games"))
      $.getScript('http://' + window.location.host + '/current_games' + window.location.search)
      
  $('#game_info').children('.collapse').click ->
    if $('#comment_box').is(':visible')
      $('#comment_box').hide()
      $(this).css({'background':"url(/assets/expand_alt.png)"})
    else
      $('#comment_box').show()
      $(this).css({'background':"url(/assets/collapse_alt.png)"})
        
  $('#duel_list').children('.collapse').click ->
    if $('#player_list').is(':visible')
      $('#player_list').hide()
      $(this).css({'background':"url(/assets/expand_alt.png)"})
      $('#duel_list').children('.refresh').hide()
    else
      $('#player_list').show()
      $(this).css({'background':"url(/assets/collapse_alt.png)"})
      $('#duel_list').children('.refresh').show()
      $('#duel_list').children('.refresh').click ->
        showLoader($('#player_list'))
        $.getScript('http://' + window.location.host + '/duel' + window.location.search)
      showLoader($('#player_list'))
      $.getScript('http://' + window.location.host + '/duel' + window.location.search)
      
  $('#help_widget').children('.collapse').click ->
    if $('#help_text').is(':visible')
      $('#help_text').hide()
      $(this).css({'background':"url(/assets/expand_alt.png)"})
    else
      $('#help_text').show()
      $(this).css({'background':"url(/assets/collapse_alt.png)"})
    
  $('#games_widget').children('.collapse').click ->
    if $('#games_list').is(':visible')
      $('#games_list').hide()
      $(this).css({'background':"url(/assets/expand_alt.png)"})
      $("#games_widget").children('.refresh').hide()
    else
      $('#games_list').show()
      $(this).css({'background':"url(/assets/collapse_alt.png)"})
      $("#games_widget").children('.refresh').show()
      $("#games_widget").children('.refresh').click ->
        showLoader($('#games_list'))
        $.getScript('http://' + window.location.host + '/watch' + window.location.search)
      showLoader($('#games_list'))
      $.getScript('http://' + window.location.host + '/watch' + window.location.search)

  if $('#game').length 
    init_game()
    $('#side_bar').show()
    $('#active_games').children('.collapse').trigger('click')
    # $('#duel_list').children('.collapse').trigger('click')
    $('#game_info').children('.collapse').trigger('click')
  
  if $('#intro').length
    $('.game_thumbnail').click ->
      $('#game_nav').show()
      $('#loader').show();
      width = document.documentElement.clientWidth
      height = document.documentElement.clientHeight
      pop_width = $('#game_nav').width()
      pop_height = $('#game_nav').height()
      $('#game_nav').css({"position":"absolute", "top":height/2-pop_height/2,"left":width/2-pop_width/2})
      $('#close_game_nav').show()
      $('#close_game_nav').position({of:$('#game_nav'), my:'left bottom', at:'right top', offset:'-21 34'})
      $('#close_game_nav').click ->
        $('#game_nav').hide()
        $('#close_game_nav').hide()
      $.getScript('http://' + window.location.host + '/games/' + $(this).attr('id') + window.location.search)
      
      
window.subscribe_game = ->
  if $('#game').attr('status') is '1'
    $('#start_info').hide()
    return
    
  window.jug.unsubscribe window.board_game_id if window.jug?
  window.jug = new Juggernaut

  window.jug.subscribe $('#game').attr('channel'), (data) ->
    if data['type'] is 'move'
      $('#game').attr('sgf', data['sgf'])
      $("#game").attr("current_player", data['current_player'])
      $("#game").attr("status", data['status'])
      $("#game").attr("access", data['access'])
      player.update($('#game'))

      if data['status'] is 1
        re = player.sgf_json.property[0]["RE"]
        result_notify(re)
      if data['access'] is 0
        if ($('#start_info').is(':visible'))
          $('#start_info').hide()

      if window.waiting_score is true
        if data['score_requester'] is 0
          window.waiting_score = false
          pop_score_rejected()
      else
        if $('#account').length and data['request_receiver'] is $('#account').attr('href').match(/^\/users\/\d+/)[0].split('/')[2]
          pop_score_request()

    else if data['type'] is 'comment'
      $.getScript('http://' + window.location.host + '/games/' + window.board_game_id + '/comments')
    else if data['type'] is 'update'
      $.getScript('http://' + window.location.host + '/games/' + window.board_game_id + '/moves')
    return

  window.jug.on "connect", ->
    $('#connection').attr("class", "success small")
    if window.get_locale() is 'zh'
      $('#connection').html("已连接")
    else
      $('#connection').html("connected")
    if window.jug_connected is false
      $.getScript('http://' + window.location.host + '/games/' + window.board_game_id + '/moves')
    window.jug_connected = true

    access = $('#game').attr('access')
    current_user = $("#game").attr("current_user")
    current_player = $("#game").attr("current_player")
    if $('#start_info').is(':visible') and (access isnt '3' or current_player is current_user)
      $('#start_info').hide()
  window.jug.on "disconnect", ->
    $('#connection').attr("class", "alert small")
    if window.get_locale() is 'zh'
      $('#connection').html("失去连接")
    else
      $('#connection').html("connection lost")
    window.jug_connected = false
  window.jug.on "reconnect", ->
    $('#connection').attr("class", "notice small")
    if window.get_locale() is 'zh'
      $('#connection').html("重连中")
    else
      $('#connection').html("reconnecting")

window.init_review = ->
  # if typeof window.review is 'undefined' or $('#game_nav').length
  $("#next").click ->
    review.next();
  $("#prev").click ->
    review.prev()
  $("#start").click ->
    review.start()
  $("#end").click ->
    review.end()
  $("#show_steps").click ->
    if review.board.show_step
      review.hide_steps()
    else
      review.show_steps()
        
  $('#game_review').attr('sgf', $('#game').attr('sgf'))
  parser = new SGF $('#game_review')
  window.review = new Player(parser, 'board_review'+'-'+$('#game').attr('channel'), true) if parser
  
  review.pre_stones()
  review.end()

window.init_board = ->
  parser = new SGF $('#game')
  window.player = new Player(parser, 'board'+'-'+$('#game').attr('channel'))
  
  $("#pass").click -> pass_notify()
  
  $("#resign").click -> resign_handle()
  $("#score").click -> score_handle()
  $("#clock").click ->
    if clock_status is 1
      stop_clock()
      pendding_move()
      
  $('#analyse').click ->
    $('#game_review').dialog({
      width:535,
      height:586,
      position:"center",
      draggable:true,
      resizable:false,
      dialogClass:"woody wood_shaodw round_board"
    })
    $('#game_review').attr('sgf', $('#game').attr('sgf'))
    # make sure 'update' works
    review.parser.data = ""
    review.update($('#game_review'))

window.get_locale = ->
  locale = 'zh'
  url = window.location.href
  if url.search(/locale=en/) isnt -1
    locale = 'en'

  return locale

window.score_handle = ->
  if player.step < 180
    if window.get_locale() is 'zh'
      alert("太早下完了吧(少于180步)，我拒绝数子...")
    else
      alert("I believe you're far from finishing game, I reject...")
  else
    pop_score_notify()

window.resign_handle = ->
  if window.get_locale() is 'zh'
    msg = "<p>确定认输吗?</p><br/>"
  else
    msg = "<p>Sure to resign?</p><br/>"
  $("#board_info").show()
  $("#board_info").html(msg)
  $("#board_info").append("<div id=\"confirm_ok\" class=\"button round\">OK</div>")
  $("#board_info").append("<div id=\"confirm_cancel\" class=\"button round\">CANCEL</div>")
  $("#confirm_ok").click ->
    player.resign()
    $("#board_info").hide()
  $("#confirm_cancel").click -> $("#board_info").hide()

window.pass_notify = ->
  if window.get_locale() is 'zh'
    msg = "<p>确定要PASS吗?</p><br/>"
  else
    msg = "<p>Sure to pass?</p><br/>"
  $("#board_info").show();
  $("#board_info").html(msg)
  $("#board_info").append("<div id=\"confirm_ok\" class=\"button round\">OK</div>")
  $("#board_info").append("<div id=\"confirm_cancel\" class=\"button round\">CANCEL</div>")
  $("#confirm_ok").click ->
    player.pass()
    $("#board_info").hide()
  $("#confirm_cancel").click -> $("#board_info").hide()

window.result_notify = (res) ->
  ra = res.split('+')
  winner = ra[0]
  result = ra[1]
  if $("#game").attr("mode") isnt 0
    $("#board_info").show()
  if $("#score").length then $("#score").hide()
  if $("#resign").length then $("#resign").hide()
  if $("#pass").length then $('#pass').hide()
  if $('#clock').length then $('#clock').hide()

  if window.get_locale() is 'zh'
    white_win_r      = "<p>白 中盘胜 </p>"
    white_win_r_text = "白中盘胜"
    black_win_r      = "<p>黑 中盘胜 </p>"
    black_win_r_text = "黑中盘胜"
    white_win        = "<p>白 胜 "
    white_win_text   = "白胜 "
    black_win        = "<p>黑 胜 "
    black_win_text   = "黑胜 "
  else
    white_win_r      = "<p>White Win </p>"
    white_win_r_text = "white win"
    black_win_r      = "<p>Black Win </p>"
    black_win_r_text = "black win"
    white_win        = "<p>White win by "
    white_win_text   = "white win by "
    black_win        = "<p>Black win by "
    black_win_text   = "black win by "

  if result is "R"
    if winner is "W"
      $("#board_info").html(white_win_r + "<div id=\"info_ok\" class=\"button round\">OK</div>")
      $("#re").html(white_win_r_text)
    else if winner is "B"
      $("#board_info").html(black_win_r + "<div id=\"info_ok\" class=\"button round\">OK</div>")
      $("#re").html(black_win_r_text)
  else
    if winner is "W"
      $("#board_info").html(white_win+result+"</p><div id=\"info_ok\" class=\"button round\">OK</div>")
      $("#re").html(white_win_text+result)
    else if winner is "B"
      $("#board_info").html(black_win+result+"</p><div id=\"info_ok\" class=\"button round\">OK</div>")
      $("#re").html(black_win_text+result)
    else
      $("#board_info").html("<p>"+res+"</p><div id=\"info_ok\" class=\"button round\">OK</div>")
      $("#re").html(res)
  $('#info_ok').click -> $('#board_info').hide()

window.pop_score_notify = ->
  if window.get_locale() is 'zh'
    msg = "<p>开始数子计算胜负吗?</p><div id=\"confirm_ok\" class=\"button round\">OK</div><div id=\"confirm_cancel\" class=\"button round\">Cancel</div>"
  else
    msg = "<p>Sure to scoring game?</p><div id=\"confirm_ok\" class=\"button round\">OK</div><div id=\"confirm_cancel\" class=\"button round\">Cancel</div>"
  $("#board_info").show()
  $("#board_info").html(msg)
  $("#confirm_ok").click ->
    please_wait()
    $.post('http://' + window.location.host + '/games/' + window.board_game_id + "/moves", {"score":"1"})
  $("#confirm_cancel").click -> $("#board_info").hide()

window.pop_score_request = ->
  if window.get_locale() is 'zh'
    msg = "<p>对手请求数子计算胜负，是否同意?</p><div id=\"confirm_ok\" class=\"button round\">OK</div><div id=\"confirm_cancel\" class=\"button round\">Cancel</div>"
  else
    msg = "<p>Opponent request for scoring，do you agree?</p><div id=\"confirm_ok\" class=\"button round\">OK</div><div id=\"confirm_cancel\" class=\"button round\">Cancel</div>"
  $("#board_info").show()
  $("#board_info").html(msg)
  $("#confirm_ok").click ->
    please_wait()
    $.post('http://' + window.location.host + '/games/' + window.board_game_id + "/moves", {"score":"1"})
  $("#confirm_cancel").click ->
    $.post('http://' + window.location.host + '/games/' + window.board_game_id + "/moves", {"score":"0"})
    $("#board_info").hide()

window.pop_score_rejected = ->
  if window.get_locale() is 'zh'
    msg = "对手拒绝了你的数子请求<div id=\"info_ok\" class=\"button round\">OK</div>"
  else
    msg = "Opponent reject you socre request.<div id=\"info_ok\" class=\"button round\">OK</div>"
  $("#board_info").show()
  $("#board_info").html(msg)
  $("#info_ok").click -> $("#board_info").hide()

window.please_wait = ->
  window.waiting_score = true
  if window.get_locale() is 'zh'
    msg = "<p>请等待...</p>"
  else
    msg = "<p>Please wait...</p>"
  $('#board_info').html msg