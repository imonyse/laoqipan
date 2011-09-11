/* DO NOT MODIFY. This file was compiled Sun, 11 Sep 2011 05:36:35 GMT from
 * /Users/wei/code/html5-weiqi/app/assets/javascripts/game.coffee
 */

(function() {
  window.waiting_score = false;
  window.board_game_id = null;
  window.jug = null;
  window.my_jug = null;
  window.prepare_game = function() {
    var access, current_player, current_user;
    if ($("#game").length) {
      $("#game").hide();
      $("#if_no_board").hide();
      access = $('#game').attr('access');
      current_player = $('#game').attr('current_player');
      current_user = $('#game').attr('current_user');
      $('#board_info').hide();
      if (access !== '3' || current_player === current_user) {
        if (window.get_locale() === 'zh') {
          $('#start_info').html('请等待<br/>与实时服务器建立连接中 ...');
        } else {
          $('#start_info').html('Please wait<br/>connecting to realtime server ...');
        }
      }
      $("#next").removeAttr('onclick');
      $("#prev").removeAttr('onclick');
      $("#start").removeAttr('onclick');
      $("#end").removeAttr('onclick');
      $("#show_steps").removeAttr('onclick');
      $("#pass").removeAttr('onclick');
      $("#resign").removeAttr('onclick');
      $("#score").removeAttr('onclick');
      $("#clock").removeAttr('onclick');
      $('#analyse').removeAttr('onclick');
      if (typeof review !== "undefined" && review !== null) {
        review.board.remove_click_fn();
      }
      if (typeof player !== "undefined" && player !== null) {
        return player.board.remove_click_fn();
      }
    }
  };
  $(document).ready(function() {
    prepare_game();
    if ($(".notify_content").length) {
      $(".notify_content").hide();
    }
    return $('#side_bar').hide();
  });
  window.showLoader = function(obj) {
    return obj.html("<img src=\"/assets/current_games_loader.gif\" style=\"margin-left:10px\">");
  };
  window.init_game = function() {
    var current_player, current_user;
    $('#game').show();
    $('.loader').hide();
    if (Modernizr.canvas && $('#board').length && $('#game').attr('sgf') !== void 0) {
      init_board();
      player.pre_stones();
      player.end();
      if ($("#game").attr("current_player") === $("#game").attr("black_player")) {
        $(".black_turn").attr("src", "/assets/turn.png");
        $(".white_turn").attr("src", "/assets/stop.png");
      } else if ($("#game").attr("current_player") === $("#game").attr("white_player")) {
        $(".black_turn").attr("src", "/assets/stop.png");
        $(".white_turn").attr("src", "/assets/turn.png");
      }
      current_user = $("#game").attr("current_user");
      current_player = $("#game").attr("current_player");
      if (current_user === current_player) {
        show_clock();
      } else {
        hide_clock();
      }
      subscribe_game();
      if ($('#game').attr('status') === "0") {
        if ($('#game').attr('requester') !== "0") {
          return $.getScript('http://' + window.location.host + '/games/' + window.board_game_id + '/moves');
        }
      }
    }
  };
  $(window).load(function() {
    var height, pop_height, pop_width, width;
    if (!Modernizr.canvas) {
      $('#browser_check_bg').css({
        "opacity": "0.7"
      });
      width = document.documentElement.clientWidth;
      height = document.documentElement.clientHeight;
      pop_width = $('#browser_check').width();
      pop_height = $('#browser_check').height();
      $('#browser_check').css({
        "position": "absolute",
        "top": height / 2 - pop_height / 2,
        "left": width / 2 - pop_width / 2
      });
      $('#browser_check_bg').fadeIn("slow");
      $('#browser_check').fadeIn("slow");
      return;
    }
    $("#active_games").children('.collapse').click(function() {
      if ($("#notified_games").is(":visible")) {
        $("#notified_games").hide();
        $(this).css({
          'background': "url(/assets/expand_alt.png)"
        });
        return $('#active_games').children('.refresh').hide();
      } else if ($("#notified_games").is(":hidden")) {
        $("#notified_games").show();
        $(this).css({
          'background': "url(/assets/collapse_alt.png)"
        });
        $('#active_games').children('.refresh').show();
        $('#active_games').children('.refresh').click(function() {
          showLoader($("#notified_games"));
          return $.getScript('http://' + window.location.host + '/current_games' + window.location.search);
        });
        showLoader($("#notified_games"));
        return $.getScript('http://' + window.location.host + '/current_games' + window.location.search);
      }
    });
    $('#game_info').children('.collapse').click(function() {
      if ($('#comment_box').is(':visible')) {
        $('#comment_box').hide();
        return $(this).css({
          'background': "url(/assets/expand_alt.png)"
        });
      } else {
        $('#comment_box').show();
        return $(this).css({
          'background': "url(/assets/collapse_alt.png)"
        });
      }
    });
    $('#duel_list').children('.collapse').click(function() {
      if ($('#player_list').is(':visible')) {
        $('#player_list').hide();
        $(this).css({
          'background': "url(/assets/expand_alt.png)"
        });
        return $('#duel_list').children('.refresh').hide();
      } else {
        $('#player_list').show();
        $(this).css({
          'background': "url(/assets/collapse_alt.png)"
        });
        $('#duel_list').children('.refresh').show();
        $('#duel_list').children('.refresh').click(function() {
          showLoader($('#player_list'));
          return $.getScript('http://' + window.location.host + '/duel' + window.location.search);
        });
        showLoader($('#player_list'));
        return $.getScript('http://' + window.location.host + '/duel' + window.location.search);
      }
    });
    $('#help_widget').children('.collapse').click(function() {
      if ($('#help_text').is(':visible')) {
        $('#help_text').hide();
        return $(this).css({
          'background': "url(/assets/expand_alt.png)"
        });
      } else {
        $('#help_text').show();
        return $(this).css({
          'background': "url(/assets/collapse_alt.png)"
        });
      }
    });
    $('#games_widget').children('.collapse').click(function() {
      if ($('#games_list').is(':visible')) {
        $('#games_list').hide();
        $(this).css({
          'background': "url(/assets/expand_alt.png)"
        });
        return $("#games_widget").children('.refresh').hide();
      } else {
        $('#games_list').show();
        $(this).css({
          'background': "url(/assets/collapse_alt.png)"
        });
        $("#games_widget").children('.refresh').show();
        $("#games_widget").children('.refresh').click(function() {
          showLoader($('#games_list'));
          return $.getScript('http://' + window.location.host + '/watch' + window.location.search);
        });
        showLoader($('#games_list'));
        return $.getScript('http://' + window.location.host + '/watch' + window.location.search);
      }
    });
    if ($('#game').length) {
      init_game();
      $('#side_bar').show();
      $('#active_games').children('.collapse').trigger('click');
      $('#game_info').children('.collapse').trigger('click');
    }
    if ($('#account').length) {
      open_my_channel();
    }
    if ($('#intro').length) {
      return $('.game_thumbnail').click(function() {
        $('#game_nav').show();
        width = document.documentElement.clientWidth;
        height = document.documentElement.clientHeight;
        pop_width = $('#game_nav').width();
        pop_height = $('#game_nav').height();
        $('#game_nav').css({
          "position": "absolute",
          "top": height / 2 - pop_height / 2,
          "left": width / 2 - pop_width / 2
        });
        $('#close_game_nav').show();
        $('#close_game_nav').position({
          of: $('#game_nav'),
          my: 'left bottom',
          at: 'right top',
          offset: '-21 34'
        });
        $('#close_game_nav').click(function() {
          $('#game_nav').hide();
          return $('#close_game_nav').hide();
        });
        return $.getScript('http://' + window.location.host + '/games/' + $(this).attr('id') + window.location.search);
      });
    }
  });
  window.open_my_channel = function() {
    var my_channel;
    if ($('#account').length) {
      my_channel = $('#account').attr('href').match(/^\/users\/\d+/)[0].split('/')[2];
      window.my_jug = new Juggernaut;
      return window.my_jug.subscribe(my_channel, function(data) {
        if (data['type'] === 'turn') {
          if ($('#notified_games').is(':hidden')) {
            return $('#active_games div.collapse').trigger('click');
          } else {
            return $('#active_games div.refresh').trigger('click');
          }
        }
      });
    }
  };
  window.subscribe_game = function() {
    if ($('#game').attr('status') === '1') {
      $('#start_info').hide();
      return;
    }
    if (window.jug != null) {
      window.jug.unsubscribe(window.board_game_id);
    }
    window.jug = new Juggernaut;
    window.jug.subscribe($('#game').attr('channel'), function(data) {
      var re;
      if (data['type'] === 'move') {
        $('#game').attr('sgf', data['sgf']);
        $("#game").attr("current_player", data['current_player']);
        $("#game").attr("status", data['status']);
        $("#game").attr("access", data['access']);
        player.update($('#game'));
        if (data['status'] === 1) {
          re = player.sgf_json.property[0]["RE"];
          result_notify(re);
        }
        if (data['access'] === 0) {
          if ($('#start_info').is(':visible')) {
            $('#start_info').hide();
          }
        }
        if (window.waiting_score === true) {
          if (data['score_requester'] === 0) {
            window.waiting_score = false;
            pop_score_rejected();
          }
        } else {
          if ($('#account').length && data['request_receiver'] === $('#account').attr('href').match(/^\/users\/\d+/)[0].split('/')[2]) {
            pop_score_request();
          }
        }
      } else if (data['type'] === 'comment') {
        $.getScript('http://' + window.location.host + '/games/' + window.board_game_id + '/comments');
      } else if (data['type'] === 'update') {
        $.getScript('http://' + window.location.host + '/games/' + window.board_game_id + '/moves');
      }
    });
    window.jug.on("connect", function() {
      var access, current_player, current_user;
      $('#connection').attr("class", "success small");
      if (window.get_locale() === 'zh') {
        $('#connection').html("已连接");
      } else {
        $('#connection').html("connected");
      }
      if (window.jug_connected === false) {
        $.getScript('http://' + window.location.host + '/games/' + window.board_game_id + '/moves');
      }
      window.jug_connected = true;
      access = $('#game').attr('access');
      current_user = $("#game").attr("current_user");
      current_player = $("#game").attr("current_player");
      if ($('#start_info').is(':visible') && (access !== '3' || current_player === current_user)) {
        return $('#start_info').hide();
      }
    });
    window.jug.on("disconnect", function() {
      $('#connection').attr("class", "alert small");
      if (window.get_locale() === 'zh') {
        $('#connection').html("失去连接");
      } else {
        $('#connection').html("connection lost");
      }
      return window.jug_connected = false;
    });
    return window.jug.on("reconnect", function() {
      $('#connection').attr("class", "notice small");
      if (window.get_locale() === 'zh') {
        return $('#connection').html("重连中");
      } else {
        return $('#connection').html("reconnecting");
      }
    });
  };
  window.init_review = function() {
    var parser;
    if (typeof window.review === 'undefined') {
      $("#next").click(function() {
        return review.next();
      });
      $("#prev").click(function() {
        return review.prev();
      });
      $("#start").click(function() {
        return review.start();
      });
      $("#end").click(function() {
        return review.end();
      });
      $("#show_steps").click(function() {
        if (review.board.show_step) {
          return review.hide_steps();
        } else {
          return review.show_steps();
        }
      });
    }
    $('#game_review').attr('sgf', $('#game').attr('sgf'));
    parser = new SGF($('#game_review'));
    delete window.review;
    if (parser) {
      window.review = new Player(parser, 'board_review', true);
    }
    review.pre_stones();
    return review.end();
  };
  window.init_board = function() {
    var parser;
    parser = new SGF($('#game'));
    delete window.player;
    window.player = new Player(parser, 'board');
    $("#pass").click(function() {
      return pass_notify();
    });
    $("#resign").click(function() {
      return resign_handle();
    });
    $("#score").click(function() {
      return score_handle();
    });
    $("#clock").click(function() {
      if (clock_status === 1) {
        stop_clock();
        return pendding_move();
      }
    });
    return $('#analyse').click(function() {
      $('#game_review').dialog({
        width: 535,
        height: 586,
        position: "center",
        draggable: true,
        resizable: false,
        dialogClass: "woody wood_shaodw round_board"
      });
      $('#game_review').attr('sgf', $('#game').attr('sgf'));
      review.parser.data = "";
      return review.update($('#game_review'));
    });
  };
  window.get_locale = function() {
    var locale, url;
    locale = 'zh';
    url = window.location.href;
    if (url.search(/locale=en/) !== -1) {
      locale = 'en';
    }
    return locale;
  };
  window.score_handle = function() {
    if (player.step < 180) {
      if (window.get_locale() === 'zh') {
        return alert("太早下完了吧(少于180步)，我拒绝数子...");
      } else {
        return alert("I believe you're far from finishing game, I reject...");
      }
    } else {
      return pop_score_notify();
    }
  };
  window.resign_handle = function() {
    var msg;
    if (window.get_locale() === 'zh') {
      msg = "<p>确定认输吗?</p><br/>";
    } else {
      msg = "<p>Sure to resign?</p><br/>";
    }
    $("#board_info").show();
    $("#board_info").html(msg);
    $("#board_info").append("<div id=\"confirm_ok\" class=\"button round\">OK</div>");
    $("#board_info").append("<div id=\"confirm_cancel\" class=\"button round\">CANCEL</div>");
    $("#confirm_ok").click(function() {
      player.resign();
      return $("#board_info").hide();
    });
    return $("#confirm_cancel").click(function() {
      return $("#board_info").hide();
    });
  };
  window.pass_notify = function() {
    var msg;
    if (window.get_locale() === 'zh') {
      msg = "<p>确定要PASS吗?</p><br/>";
    } else {
      msg = "<p>Sure to pass?</p><br/>";
    }
    $("#board_info").show();
    $("#board_info").html(msg);
    $("#board_info").append("<div id=\"confirm_ok\" class=\"button round\">OK</div>");
    $("#board_info").append("<div id=\"confirm_cancel\" class=\"button round\">CANCEL</div>");
    $("#confirm_ok").click(function() {
      player.pass();
      return $("#board_info").hide();
    });
    return $("#confirm_cancel").click(function() {
      return $("#board_info").hide();
    });
  };
  window.result_notify = function(res) {
    var black_win, black_win_r, black_win_r_text, black_win_text, ra, result, white_win, white_win_r, white_win_r_text, white_win_text, winner;
    ra = res.split('+');
    winner = ra[0];
    result = ra[1];
    if ($("#game").attr("mode") !== 0) {
      $("#board_info").show();
    }
    if ($("#score").length) {
      $("#score").hide();
    }
    if ($("#resign").length) {
      $("#resign").hide();
    }
    if ($("#pass").length) {
      $('#pass').hide();
    }
    if ($('#clock').length) {
      $('#clock').hide();
    }
    if (window.get_locale() === 'zh') {
      white_win_r = "<p>白 中盘胜 </p>";
      white_win_r_text = "白中盘胜";
      black_win_r = "<p>黑 中盘胜 </p>";
      black_win_r_text = "黑中盘胜";
      white_win = "<p>白 胜 ";
      white_win_text = "白胜 ";
      black_win = "<p>黑 胜 ";
      black_win_text = "黑胜 ";
    } else {
      white_win_r = "<p>White Win </p>";
      white_win_r_text = "white win";
      black_win_r = "<p>Black Win </p>";
      black_win_r_text = "black win";
      white_win = "<p>White win by ";
      white_win_text = "white win by ";
      black_win = "<p>Black win by ";
      black_win_text = "black win by ";
    }
    if (result === "R") {
      if (winner === "W") {
        $("#board_info").html(white_win_r + "<div id=\"info_ok\" class=\"button round\">OK</div>");
        $("#re").html(white_win_r_text);
      } else if (winner === "B") {
        $("#board_info").html(black_win_r + "<div id=\"info_ok\" class=\"button round\">OK</div>");
        $("#re").html(black_win_r_text);
      }
    } else {
      if (winner === "W") {
        $("#board_info").html(white_win + result + "</p><div id=\"info_ok\" class=\"button round\">OK</div>");
        $("#re").html(white_win_text + result);
      } else if (winner === "B") {
        $("#board_info").html(black_win + result + "</p><div id=\"info_ok\" class=\"button round\">OK</div>");
        $("#re").html(black_win_text + result);
      } else {
        $("#board_info").html("<p>" + res + "</p><div id=\"info_ok\" class=\"button round\">OK</div>");
        $("#re").html(res);
      }
    }
    return $('#info_ok').click(function() {
      return $('#board_info').hide();
    });
  };
  window.pop_score_notify = function() {
    var msg;
    if (window.get_locale() === 'zh') {
      msg = "<p>开始数子计算胜负吗?</p><div id=\"confirm_ok\" class=\"button round\">OK</div><div id=\"confirm_cancel\" class=\"button round\">Cancel</div>";
    } else {
      msg = "<p>Sure to scoring game?</p><div id=\"confirm_ok\" class=\"button round\">OK</div><div id=\"confirm_cancel\" class=\"button round\">Cancel</div>";
    }
    $("#board_info").show();
    $("#board_info").html(msg);
    $("#confirm_ok").click(function() {
      please_wait();
      return $.post('http://' + window.location.host + '/games/' + window.board_game_id + "/moves", {
        "score": "1"
      });
    });
    return $("#confirm_cancel").click(function() {
      return $("#board_info").hide();
    });
  };
  window.pop_score_request = function() {
    var msg;
    if (window.get_locale() === 'zh') {
      msg = "<p>对手请求数子计算胜负，是否同意?</p><div id=\"confirm_ok\" class=\"button round\">OK</div><div id=\"confirm_cancel\" class=\"button round\">Cancel</div>";
    } else {
      msg = "<p>Opponent request for scoring，do you agree?</p><div id=\"confirm_ok\" class=\"button round\">OK</div><div id=\"confirm_cancel\" class=\"button round\">Cancel</div>";
    }
    $("#board_info").show();
    $("#board_info").html(msg);
    $("#confirm_ok").click(function() {
      please_wait();
      return $.post('http://' + window.location.host + '/games/' + window.board_game_id + "/moves", {
        "score": "1"
      });
    });
    return $("#confirm_cancel").click(function() {
      $.post('http://' + window.location.host + '/games/' + window.board_game_id + "/moves", {
        "score": "0"
      });
      return $("#board_info").hide();
    });
  };
  window.pop_score_rejected = function() {
    var msg;
    if (window.get_locale() === 'zh') {
      msg = "对手拒绝了你的数子请求<div id=\"info_ok\" class=\"button round\">OK</div>";
    } else {
      msg = "Opponent reject you socre request.<div id=\"info_ok\" class=\"button round\">OK</div>";
    }
    $("#board_info").show();
    $("#board_info").html(msg);
    return $("#info_ok").click(function() {
      return $("#board_info").hide();
    });
  };
  window.please_wait = function() {
    var msg;
    window.waiting_score = true;
    if (window.get_locale() === 'zh') {
      msg = "<p>请等待...</p>";
    } else {
      msg = "<p>Please wait...</p>";
    }
    return $('#board_info').html(msg);
  };
}).call(this);
