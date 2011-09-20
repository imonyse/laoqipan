window.waiting_score = false
window.jug = null

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
  
window.showLoader = (obj) ->
  obj.css({"background":"url(/assets/current_games_loader.gif) no-repeat"})
  
window.hideLoader = (obj) ->
  obj.css({"background-image":"none"})
  
window.init_game = ->
  if $('#game').attr('sgf')
    $('#loader').show()
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
        $.getScript(window.location.pathname + '/moves')

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
    
  if $('#game').length 
    init_game()
  if $('#game_review').length
    init_review()
    
  $('#active_games div.refresh').click ->
    showLoader($('#notified_games'))
    $.getScript('http://' + window.location.host + '/current_games' + window.location.search)
    
  $('#games_widget div.refresh').click ->
    showLoader($('#games_list'))
    $.getScript('http://' + window.location.host + '/watch' + window.location.search)
      
window.subscribe_game = ->
  if $('#game').attr('status') is '1'
    $('#start_info').hide()
    return
    
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
      $.getScript(window.location.pathname + '/comments')
    else if data['type'] is 'update'
      $.getScript(window.location.pathname + '/moves')
    return

  window.jug.on "connect", ->
    $('#connection').attr("class", "success small")
    if window.get_locale() is 'zh'
      $('#connection').html("已连接")
    else
      $('#connection').html("connected")
    if window.jug_connected is false
      $.getScript(window.location.pathname + '/moves')
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
      
  if $('#game_review').attr('sgf')
    $('#game_review').show()
    parser = new SGF $('#game_review')
    window.review = new Player(parser, 'board_review' + '-' + $('#game_review').attr('channel'), true) if parser
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
      window.pendding_move()
      
  $('#analyse').click ->
    $('#game_review').dialog({
      width:535,
      height:600,
      draggable:true,
      dialogClass:"woody wood_shadow"
    })
    $('#game_review').attr('sgf', $('#game').attr('sgf'))
    parser = new SGF $('#game_review')
    window.review = new Player(parser, 'board_review'+'-'+$('#game').attr('channel'), true) if parser
    review.pre_stones()
    review.end()

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
    $.post(window.location.pathname + "/moves", {"score":"1"})
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
    $.post(window.location.pathname + "/moves", {"score":"1"})
  $("#confirm_cancel").click ->
    $.post(window.location.pathname + "/moves", {"score":"0"})
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