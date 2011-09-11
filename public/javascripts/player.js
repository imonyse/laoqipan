/* DO NOT MODIFY. This file was compiled Sun, 11 Sep 2011 05:36:35 GMT from
 * /Users/wei/code/html5-weiqi/app/assets/javascripts/player.coffee
 */

(function() {
  var Player, clock_timer, poll_timer;
  poll_timer = 0;
  window.clock_status = 0;
  clock_timer = null;
  jQuery.ajaxSetup({
    timeout: 30000
  });
  window.notify_message = function(current_player) {
    var alert_msg, alert_name, black_player, white_player;
    black_player = $('#game').attr('black_player');
    white_player = $('#game').attr('white_player');
    if (current_player === black_player) {
      alert_name = $('#black_player a').html();
    } else {
      alert_name = $('#white_player a').html();
    }
    if (window.get_locale() === 'zh') {
      alert_msg = ", 该你了!看看红名的对局";
    } else {
      alert_msg = ", your turn! See your red games";
    }
    return $.titleAlert(alert_name + alert_msg, {
      requireBlur: true,
      stopOnFocus: true,
      duration: 12000,
      interval: 1000
    });
  };
  window.show_clock = function() {
    $("#clock").show();
    $("#pass").show();
    $('#resign').show();
    return $('#score').show();
  };
  window.hide_clock = function() {
    $("#clock").hide();
    $("#pass").hide();
    $('#resign').hide();
    return $('#score').hide();
  };
  window.stop_clock = function() {
    clearTimeout(clock_timer);
    clock_timer = null;
    return window.clock_status = 0;
  };
  window.rattle_clock = function() {
    window.clock_status = 1;
    return effects();
  };
  window.effects = function() {
    $("#clock").effect("highlight", {
      "color": "#0F0"
    }, 500);
    if (clock_timer != null) {
      clearTimeout(clock_timer);
    }
    return clock_timer = setTimeout(effects, 1000);
  };
  Player = (function() {
    function Player(parser, target_board_id, flag) {
      var br, dt, first_move, first_turn, handicap, mode, pb, pw, status, wr;
      this.parser = parser;
      this.target_board_id = target_board_id;
      this.flag = flag;
      this.sgf_json = this.parser.parse_game();
      this.step = 1;
      this.poller = null;
      this.master = null;
      this.linear = this.sgf_json;
      this.branch_head_nodes = [];
      this.track = [this.sgf_json];
      this.basic_info = this.sgf_json.property[0];
      pb = this.basic_info.PB || '';
      br = this.basic_info.BR || '';
      pw = this.basic_info.PW || '';
      wr = this.basic_info.WR || '';
      dt = this.basic_info.DT || '';
      if ($('#game').attr('mode') === 0) {
        $('#black_player').html(pb + ' ' + br);
        $('#white_player').html(pw + ' ' + wr);
        $('#dt').html(dt);
      }
      first_move = 'b';
      handicap = this.basic_info.HA;
      if (typeof handicap !== 'undefined') {
        if (handicap > "1") {
          first_turn = 'w';
        } else {
          first_turn = 'b';
        }
      } else {
        first_move = this.sgf_json.property[1];
        if (typeof first_move !== 'undefined') {
          if (typeof first_move.B !== 'undefined') {
            first_turn = 'b';
          } else if (typeof first_move.W !== 'undefined') {
            first_turn = 'w';
          }
        } else {
          first_turn = 'b';
        }
      }
      this.board = new Board(19, first_turn, this.target_board_id);
      mode = $('#game').attr('mode');
      status = $('#game').attr('status');
      if (mode !== 0 && status !== 0) {
        if (this.flag) {
          this.board.click(bind_review(this.board));
        } else {
          this.board.click(bind_click(this.board));
        }
      }
    }
    Player.prototype.pre_stones = function() {
      var ab, aw, c;
      ab = this.basic_info.AB;
      aw = this.basic_info.AW;
      if (typeof ab !== 'undefined') {
        this.set_pre_stones(ab, 'b');
      }
      if (typeof aw !== 'undefined') {
        this.set_pre_stones(aw, 'w');
      }
      c = this.basic_info.C;
      if (typeof c !== 'undefined') {
        this.show_comments(c);
      }
      this.board.color_in_turn = this.board.first_color;
      return this.board.step_count = 0;
    };
    Player.prototype.set_pre_stones = function(pos_list, color) {
      var pos, _i, _len;
      this.board.block_last_mark();
      for (_i = 0, _len = pos_list.length; _i < _len; _i++) {
        pos = pos_list[_i];
        this.board.click_via_name(pos, color);
        this.board.find_stone_by_name(pos).step = -1;
      }
      return this.board.dredge_last_mark();
    };
    Player.prototype.update = function(game_obj) {
      var current_player, current_user, last_move_name_before;
      if (game_obj.attr('sgf').length === this.parser.data.length) {} else {
        if (this.board.last_move != null) {
          last_move_name_before = this.board.last_move.name;
        } else {
          last_move_name_before = null;
        }
        this.parser = new SGF(game_obj);
        this.sgf_json = this.parser.parse_game();
        this.master = this.sgf_json;
        this.track = [this.sgf_json];
        this.start();
        this.end();
        current_user = $("#game").attr("current_user");
        current_player = $("#game").attr("current_player");
        if (current_user === current_player) {
          show_clock();
          notify_message(current_player);
        } else {
          hide_clock();
        }
        return show_player_turn();
      }
    };
    Player.prototype.branch_start_with = function(key, value) {
      var e, _i, _len, _ref;
      if (this.branch_head_nodes.length > 0) {
        _ref = this.branch_head_nodes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          e = _ref[_i];
          if (e[0][key] === value) {
            return e[1];
          }
        }
      }
      return null;
    };
    Player.prototype.fork_branches = function(new_branch) {
      var branch_from_origin, i;
      if (typeof this.master.property[this.step] !== 'undefined') {
        branch_from_origin = {
          property: [],
          branches: []
        };
        i = this.master.property.length - 1;
        while (i >= 0) {
          if (this.master.property[i] === this.master.property[this.step - 1]) {
            branch_from_origin.property = branch_from_origin.property.reverse();
            break;
          } else {
            branch_from_origin.property.push(this.master.property[i]);
            this.master.property.pop();
          }
          i--;
        }
        branch_from_origin.branches = this.master.branches;
        this.master.branches = [branch_from_origin];
        return this.master.branches.push(new_branch);
      } else {
        return this.track[this.track.length - 1].branches.push(new_branch);
      }
    };
    Player.prototype.next = function() {
      var branch, count, cur, head_node, mark, rc, vt, _i, _j, _len, _len2, _ref, _ref2;
      rc = 0;
      this.branch_head_nodes = [];
      if (this.master === null) {
        this.master = this.sgf_json;
      }
      if (typeof this.master !== 'undefined') {
        cur = this.master.property[this.step];
        if (typeof cur !== 'undefined') {
          if (typeof cur.B !== 'undefined') {
            this.board.click_via_name(cur.B);
            show_player_turn();
            if (cur.B === '') {
              rc = 1;
            } else {
              rc = 2;
            }
          } else if (typeof cur.W !== 'undefined') {
            this.board.click_via_name(cur.W);
            show_player_turn();
            if (cur.W === '') {
              rc = 1;
            } else {
              rc = 2;
            }
          }
          if (typeof cur.C !== 'undefined') {
            this.show_comments(cur.C);
          }
          if (typeof cur.LB !== 'undefined') {
            _ref = cur.LB;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              vt = _ref[_i];
              mark = vt.split(':');
              this.board.set_text(mark[0], mark[1]);
            }
          }
          if (this.flag) {
            $('#review_swap').html(this.step);
          } else {
            $('#swap').html(this.step);
          }
          this.step++;
        }
      }
      if (!this.master.property[this.step] && this.master.branches.length > 0) {
        count = 1;
        _ref2 = this.master.branches;
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          branch = _ref2[_j];
          head_node = branch.property[0];
          if (typeof head_node !== 'undefined') {
            if (typeof head_node.B !== 'undefined') {
              this.board.set_text(head_node.B, count);
            } else if (typeof head_node.W !== 'undefined') {
              this.board.set_text(head_node.W, count);
            }
            this.branch_head_nodes.push([head_node, branch]);
          }
          count++;
        }
      }
      return rc;
    };
    Player.prototype.prev = function() {
      var current_path, current_steps, path, _i, _len, _ref;
      current_path = this.master;
      current_steps = this.step;
      if (current_steps === 1) {
        this.track.pop();
      }
      window.refresh = false;
      this.board.reset();
      this.pre_stones();
      _ref = this.track;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        path = _ref[_i];
        this.master = path;
        this.step = 0;
        while (this.master.property[this.step]) {
          if (this.master === current_path && this.step === current_steps - 2) {
            break;
          }
          this.next();
        }
      }
      this.board.refresh();
      window.refresh = true;
      return this.next();
    };
    Player.prototype.start = function() {
      this.step = 1;
      this.board.reset();
      if (this.flag) {
        $('#review_swap').html('0');
      } else {
        $('#swap').html('0');
      }
      $('#post_out').html('');
      return this.pre_stones();
    };
    Player.prototype.end = function() {
      var branch, count, cur, head_node, path, re, step, _i, _j, _len, _len2, _ref, _ref2;
      _ref = this.track;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        path = _ref[_i];
        cur = path.property;
        step = 0;
        if (typeof cur !== 'undefined') {
          window.refresh = false;
          while (typeof cur[step] !== 'undefined') {
            this.next();
            step++;
          }
          this.board.refresh();
          if (path.branches.length > 0) {
            count = 1;
            _ref2 = path.branches;
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              branch = _ref2[_j];
              head_node = branch.property[0];
              if (typeof head_node !== 'undefined') {
                if (typeof head_node.B !== 'undefined') {
                  this.board.set_text(head_node.B, count);
                } else if (typeof head_node.W !== 'undefined') {
                  this.board.set_text(head_node.W, count);
                }
              }
              count++;
            }
          }
        }
      }
      if (this.step > 1) {
        this.board.draw_last_mark(this.board.last_move);
      }
      window.refresh = true;
      re = this.basic_info.RE;
      if (typeof re !== 'undefined') {
        return result_notify(re);
      }
    };
    Player.prototype.hide_steps = function() {
      this.board.show_step = false;
      this.board.refresh();
      return this.board.draw_last_mark(this.board.last_move);
    };
    Player.prototype.show_steps = function() {
      this.board.show_step = true;
      this.board.refresh();
      return this.board.draw_last_mark(this.board.last_move);
    };
    Player.prototype.show_comments = function(comment) {
      var c;
      c = comment.replace(/\n/g, '</p><p>');
      return $('#post_out').html('<p>' + c + '</p>');
    };
    Player.prototype.pass = function() {
      var current_player, current_user, move, pb, pw;
      current_user = $('#game').attr('current_user');
      current_player = $('#game').attr('current_player');
      pb = $('#game').attr('black_player');
      pw = $('#game').attr('white_player');
      move = {};
      if (current_user === current_player) {
        if (pb === current_user) {
          move['B'] = '';
        } else if (pw === current_user) {
          move['W'] = '';
        }
        this.parser.update_game(move);
        return $.post('http://' + window.location.host + '/games/' + window.board_game_id + '/moves', {
          "sgf": $("#game").attr("sgf"),
          "moves": "PASS",
          "player_id": $("#game").attr("current_user")
        });
      }
    };
    Player.prototype.resign = function() {
      var current_user, move, pb, pw, winner;
      current_user = $('#game').attr('current_user');
      pb = $('#game').attr('black_player');
      pw = $('#game').attr('white_player');
      if (pb === current_user) {
        winner = 'W';
        move = 'BRESIGN';
      } else if (pw === current_user) {
        winner = 'B';
        move = 'WRESIGN';
      }
      this.parser.add_winner(winner);
      return $.post('http://' + window.location.host + '/games/' + window.board_game_id + '/moves', {
        "sgf": $("#game").attr("sgf"),
        "moves": move
      });
    };
    return Player;
  })();
  window.Player = Player;
  window.show_player_turn = function() {
    if (player.board.color_in_turn === 'b') {
      $('.black_turn').attr("src", "/assets/turn.png");
      return $('.white_turn').attr('src', '/assets/stop.png');
    } else if (player.board.color_in_turn === 'w') {
      $('.black_turn').attr('src', '/assets/stop.png');
      return $('.white_turn').attr('src', '/assets/turn.png');
    }
  };
}).call(this);
