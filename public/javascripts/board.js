/* DO NOT MODIFY. This file was compiled Sun, 11 Sep 2011 05:36:35 GMT from
 * /Users/wei/code/html5-weiqi/app/assets/javascripts/board.coffee
 */

(function() {
  var Board, BoardDot;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  Board = (function() {
    function Board(board_size, first_color, board_id) {
      var jquery_canvas;
      this.board_size = board_size;
      this.first_color = first_color;
      this.board_id = board_id;
      this.stone_radius = 12;
      this.board_edge = 40.5;
      this.board_square = this.stone_radius * 2 + 1;
      this.board_image_size = this.board_edge * 2 + (this.board_size - 1) * this.board_square;
      this.star_radius = 3;
      this.color_in_turn = this.first_color;
      this.status = 0;
      this.captured_color = "e";
      this.ko_dot = null;
      this.last_move = null;
      this.draw_last_move = true;
      this.dots_of_star = ["dd", "dj", "dp", "jd", "jj", "jp", "pd", "pj", "pp"];
      this.show_step = false;
      this.step_count = 0;
      this.dots = [];
      this.dots_checked = [];
      this.to_be_captured = [];
      this.dead_black_count = 0;
      this.dead_white_count = 0;
      if ($("#" + this.board_id).length) {
        this.canvas = $("#" + this.board_id).get(0);
      } else {
        jquery_canvas = $(document.createElement('canvas')).attr("id", "" + this.board_id);
        jquery_canvas.appendTo('body');
        this.canvas = jquery_canvas.get(0);
      }
      this.canvas.width = this.canvas.height = this.board_image_size;
      this.context_2d = this.canvas.getContext("2d");
      this.draw_game();
    }
    Board.prototype.draw_game = function() {
      if (this.status === 0) {
        return this.init_dots();
      } else if (this.status === 1) {
        return this.draw_dots();
      }
    };
    Board.prototype.draw_star = function(x, y) {
      this.context_2d.beginPath();
      this.context_2d.arc(x, y, this.star_radius, 0, Math.PI * 2, false);
      this.context_2d.closePath();
      this.context_2d.fillStyle = '#000';
      return this.context_2d.fill();
    };
    Board.prototype.draw_black_stone = function(x, y) {
      this.context_2d.beginPath();
      this.context_2d.arc(x, y, this.stone_radius, 0, Math.PI * 2, false);
      this.context_2d.closePath();
      this.context_2d.fillStyle = '#000';
      return this.context_2d.fill();
    };
    Board.prototype.draw_white_stone = function(x, y) {
      this.context_2d.beginPath();
      this.context_2d.arc(x, y, this.stone_radius, 0, Math.PI * 2, false);
      this.context_2d.closePath();
      this.context_2d.fillStyle = '#fff';
      this.context_2d.fill();
      this.context_2d.strokeStyle = '#666';
      return this.context_2d.stroke();
    };
    Board.prototype.draw_last_mark = function(dot) {
      if (!this.draw_last_move) {
        return;
      }
      if (this.show_step) {
        dot.show_dot_step('#f00');
      } else {
        this.context_2d.beginPath();
        this.context_2d.arc(dot.x, dot.y, this.stone_radius / 2, 0, Math.PI * 2, false);
        this.context_2d.closePath();
        if (dot.owner === "b") {
          this.context_2d.strokeStyle = '#fff';
        } else {
          this.context_2d.strokeStyle = '#000';
        }
        this.context_2d.stroke();
      }
      return this.last_move = dot;
    };
    Board.prototype.block_last_mark = function() {
      return this.draw_last_move = false;
    };
    Board.prototype.dredge_last_mark = function() {
      return this.draw_last_move = true;
    };
    Board.prototype.pass = function() {
      return this.color_in_turn = this.color_in_turn === "b" ? "w" : "b";
    };
    Board.prototype.init_dots = function() {
      var alphabet, dot, i, j, _ref, _ref2;
      alphabet = "abcdefghijklmnopqrs".split("");
      for (i = 0, _ref = alphabet.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        for (j = 0, _ref2 = alphabet.length; 0 <= _ref2 ? j < _ref2 : j > _ref2; 0 <= _ref2 ? j++ : j--) {
          dot = new BoardDot(alphabet[i] + alphabet[j], this.board_edge + this.board_square * i, this.board_edge + this.board_square * j, this);
          this.dots[this.dots.length] = dot;
        }
      }
      return this.status = 1;
    };
    Board.prototype.draw_dots = function() {
      var dot, _i, _len, _ref;
      _ref = this.dots;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dot = _ref[_i];
        if (dot.owner === "b") {
          this.draw_black_stone(dot.x, dot.y);
        } else if (dot.owner === "w") {
          this.draw_white_stone(dot.x, dot.y);
        }
        if (this.show_step && dot.owner !== 'e') {
          dot.show_dot_step();
        }
      }
    };
    Board.prototype.get_cursor_position = function(e) {
      var closest, cur, dot, dx, dy, min, x, y, _i, _len, _ref;
      closest = null;
      if (typeof e.pageX !== 'undefined' && typeof epageY !== 'undefined') {
        x = e.pageX;
        y = e.pageY;
      } else {
        x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
        y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
      }
      x -= $("#" + this.board_id).offset().left;
      y -= $("#" + this.board_id).offset().top;
      _ref = this.dots;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dot = _ref[_i];
        dx = Math.abs(dot.x - x);
        dy = Math.abs(dot.y - y);
        cur = Math.sqrt(dx * dx + dy * dy);
        if (cur > this.stone_radius) {
          continue;
        }
        if (!((typeof min !== "undefined" && min !== null) || min <= cur)) {
          closest = dot;
          min = cur;
        }
      }
      return closest;
    };
    Board.prototype.draw_fake_stone = function(dot) {
      this.refresh();
      if (this.last_move != null) {
        this.draw_last_mark(this.last_move);
      }
      this.context_2d.beginPath();
      this.context_2d.arc(dot.x, dot.y, this.stone_radius, 0, Math.PI * 2, false);
      this.context_2d.closePath();
      if (this.color_in_turn === "b") {
        this.context_2d.fillStyle = 'rgba(0, 0, 0, 0.6)';
      } else if (this.color_in_turn === "w") {
        this.context_2d.fillStyle = 'rgba(255, 255, 255, 0.6)';
      }
      return this.context_2d.fill();
    };
    Board.prototype.on_dot_click = function(dot) {
      if (dot != null) {
        if (this.ko_dot != null) {
          if (dot.name === this.ko_dot) {
            return false;
          } else {
            this.ko_dot = null;
          }
        }
        if (dot.occupy(this.color_in_turn)) {
          this.dots_checked = [];
          if (this.is_alive(dot)) {
            dot.check_nearby_dots(true);
          } else {
            dot.check_nearby_dots(false);
            if (this.captured_color === dot.owner || this.captured_color === 'e') {
              this.to_be_captured[this.to_be_captured.length] = dot;
            }
          }
          this.capture_stones();
          this.captured_color = 'e';
          if (dot.step !== -1) {
            this.step_count++;
            dot.step = this.step_count;
          }
          if (window.refresh) {
            this.refresh();
          }
          this.draw_last_mark(dot);
        }
        return true;
      }
      return false;
    };
    Board.prototype.find_stone_by_name = function(name) {
      var dot, _i, _len, _ref;
      _ref = this.dots;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dot = _ref[_i];
        if (name === dot.name) {
          return dot;
        }
      }
      return null;
    };
    Board.prototype.find_stone_by_coordinates = function(co) {
      var name_set, x, y;
      if (co.length > 3 || co.length < 2) {
        throw "invalid coordinates";
      }
      name_set = "abcdefghijklmnopqrs";
      x = "ABCDEFGHJKLMNOPQRST".indexOf(co[0].toUpperCase());
      y = this.board_size - parseInt(co[1] + co[2], 10);
      return this.find_stone_by_name(name_set[x] + name_set[y]);
    };
    Board.prototype.add_examined = function(name) {
      var e, _i, _len, _ref;
      _ref = this.dots_checked;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        e = _ref[_i];
        if (e === name) {
          return false;
        }
      }
      this.dots_checked[this.dots_checked.length] = name;
      return true;
    };
    Board.prototype.add_captured = function(dot) {
      var dead, rc, _i, _len, _ref;
      rc = true;
      if (this.captured_color !== "e") {
        if (this.captured_color !== dot.owner) {
          this.captured_color = "e";
          this.to_be_captured = [];
        }
      } else {
        _ref = this.to_be_captured;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          dead = _ref[_i];
          if (dead.name === dot.name) {
            rc = false;
            break;
          }
        }
      }
      if (rc) {
        this.to_be_captured[this.to_be_captured.length] = dot;
        this.captured_color = dot.owner;
      }
      return rc;
    };
    Board.prototype.capture_stones = function() {
      var dot, _i, _len, _ref;
      _ref = this.to_be_captured;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dot = _ref[_i];
        if (dot.owner === 'b') {
          this.dead_black_count++;
        } else if (dot.owner === 'w') {
          this.dead_white_count++;
        }
        dot.owner = "e";
        dot.step = 0;
      }
      $('#black_captured').text(this.dead_black_count);
      $('#white_captured').text(this.dead_white_count);
      return this.to_be_captured = [];
    };
    Board.prototype.check_with_capture = function(examinee, examiner, flag) {
      this.add_examined(examiner.name);
      if (typeof examinee !== "undefined") {
        if (examinee.owner === "e") {
          return;
        }
        if (flag) {
          if (examinee.owner !== examiner.owner && examinee.owner !== "e") {
            if (!this.is_alive(examinee)) {
              this.add_captured(examinee);
            }
          }
        } else {
          if (examinee.owner !== examiner.owner) {
            if (!this.is_alive(examinee)) {
              this.add_captured(examinee);
            }
          }
          if (examinee.owner === examiner.owner) {
            if (this.captured_color === examinee.owner) {
              this.add_captured(examinee);
            }
          }
        }
      }
      if (flag) {
        if (this.captured_color !== examiner.owner) {
          return this.capture_stones();
        }
      } else {
        if (examinee.owner !== examiner.owner) {
          return this.capture_stones();
        }
      }
    };
    Board.prototype.is_alive = function(dot) {
      var dots_nearby, e, rc, _i, _j, _len, _len2, _ref, _ref2;
      rc = false;
      if (dot.owner === "e") {
        return false;
      }
      this.add_examined(dot.name);
      dots_nearby = dot.get_nearby_dots();
      for (_i = 0, _len = dots_nearby.length; _i < _len; _i++) {
        e = dots_nearby[_i];
        if (e.owner === "e") {
          if (_ref = e.name, __indexOf.call(this.dots_checked, _ref) < 0) {
            rc = true;
            break;
          }
        }
      }
      if (rc !== true) {
        for (_j = 0, _len2 = dots_nearby.length; _j < _len2; _j++) {
          e = dots_nearby[_j];
          if (e.owner === dot.owner) {
            if (_ref2 = e.name, __indexOf.call(this.dots_checked, _ref2) < 0) {
              rc = this.is_alive(e);
              if (rc === true) {
                this.to_be_captured = [];
                break;
              } else {
                this.add_captured(e);
              }
            }
          }
        }
      }
      if (rc === true) {
        this.dots_checked = [];
      }
      return rc;
    };
    Board.prototype.refresh = function() {
      this.context_2d.clearRect(0, 0, this.board_image_size, this.board_image_size);
      return this.draw_game();
    };
    Board.prototype.reset = function() {
      var dot, _i, _len, _ref;
      this.step_count = 0;
      _ref = this.dots;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        dot = _ref[_i];
        dot.reset();
      }
      this.color_in_turn = this.first_color;
      this.dead_black_count = 0;
      this.dead_white_count = 0;
      return this.refresh();
    };
    Board.prototype.click_via_coordinates = function(coordinates, color) {
      var dot;
      if (color != null) {
        this.color_in_turn = color;
      }
      if (coordinates.length > 3 || coordinates.length < 2) {
        throw 'invalid coordinates';
      }
      dot = this.find_stone_by_coordinates(coordinates);
      return this.on_dot_click(dot);
    };
    Board.prototype.click_via_name = function(name, color) {
      var dot;
      if (color != null) {
        this.color_in_turn = color;
      }
      if (name.length !== 2) {
        if (name.length !== 0) {
          throw 'invalid sgf move name';
        }
      }
      if (name === '') {
        if (this.color_in_turn === "b") {
          return this.color_in_turn = 'w';
        } else if (this.color_in_turn === 'w') {
          return this.color_in_turn = 'b';
        }
      } else {
        dot = this.find_stone_by_name(name.toLowerCase());
        return this.on_dot_click(dot);
      }
    };
    Board.prototype.set_text = function(dot_name, text) {
      var dot;
      if (dot_name.length !== 2) {
        throw 'invalid sgf move name';
      }
      dot = this.find_stone_by_name(dot_name.toLowerCase());
      return dot.set_text(text);
    };
    Board.prototype.click = function(click_fn) {
      return this.canvas.addEventListener('click', click_fn, false);
    };
    Board.prototype.remove_click_fn = function(click_fn) {
      return this.canvas.removeEventListener('click', click_fn, false);
    };
    return Board;
  })();
  BoardDot = (function() {
    function BoardDot(name, x, y, parent) {
      var v, _i, _len, _ref;
      this.name = name;
      this.x = x;
      this.y = y;
      this.parent = parent;
      this.step = 0;
      this.is_star = false;
      _ref = this.parent.dots_of_star;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        if (v === this.name) {
          this.is_star = true;
          break;
        }
      }
      this.owner = "e";
    }
    BoardDot.prototype.occupy = function(color) {
      if (this.owner !== "e") {
        return false;
      }
      if (this.parent.color_in_turn === "b") {
        this.parent.draw_black_stone(this.x, this.y);
        this.parent.color_in_turn = "w";
      } else if (this.parent.color_in_turn === "w") {
        this.parent.draw_white_stone(this.x, this.y);
        this.parent.color_in_turn = "b";
      }
      this.owner = color;
      return true;
    };
    BoardDot.prototype.reset = function() {
      this.owner = "e";
      return this.step = 0;
    };
    BoardDot.prototype.set_text = function(text) {
      this.parent.context_2d.clearRect(this.x - 6, this.y - 5, 12, 12);
      this.parent.context_2d.fillStyle = "#E9C2A6";
      this.parent.context_2d.fillRect(this.x - 6, this.y - 5, 12, 12);
      this.parent.context_2d.fillStyle = "#000";
      this.parent.context_2d.font = "bold 18px Monospace";
      return this.parent.context_2d.fillText(text, this.x - 5, this.y + 5);
    };
    BoardDot.prototype.show_dot_step = function(color) {
      var x, y;
      if (this.step === -1) {
        return;
      }
      if (this.step === 0) {
        this.step = this.parent.step_count + 1;
      }
      if (color != null) {
        this.parent.context_2d.fillStyle = color;
      } else {
        if (this.owner === "b") {
          this.parent.context_2d.fillStyle = '#fff';
        } else {
          this.parent.context_2d.fillStyle = '#000';
        }
      }
      this.parent.context_2d.font = '14px sans serif';
      y = this.y + 4;
      if (this.step < 10) {
        x = this.x - 3;
      } else if (this.step < 100) {
        x = this.x - 6;
      } else {
        x = this.x - 10;
      }
      return this.parent.context_2d.fillText(this.step, x, y);
    };
    BoardDot.prototype.get_dot_from = function(pos) {
      var alphabet, my_x_index, my_y_index, x, y;
      alphabet = 'abcdefghijklmnopqrs';
      my_x_index = alphabet.indexOf(this.name[0]);
      my_y_index = alphabet.indexOf(this.name[1]);
      if (pos === "left") {
        if (my_x_index > 0) {
          x = my_x_index - 1;
          y = my_y_index;
        }
      } else if (pos === "right") {
        if (my_x_index < 18) {
          x = my_x_index + 1;
          y = my_y_index;
        }
      } else if (pos === "top") {
        if (my_y_index > 0) {
          x = my_x_index;
          y = my_y_index - 1;
        }
      } else if (pos === "bottom") {
        if (my_y_index < 18) {
          x = my_x_index;
          y = my_y_index + 1;
        }
      }
      if (typeof x !== 'undefined' && typeof y !== 'undefined') {
        return this.parent.find_stone_by_name(alphabet[x] + alphabet[y]);
      } else {
        return null;
      }
    };
    BoardDot.prototype.get_nearby_dots = function() {
      var dot, dots, w, _i, _len, _ref;
      dots = [];
      _ref = ["left", "right", "top", "bottom"];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        w = _ref[_i];
        dot = this.get_dot_from(w);
        if (dot != null) {
          dots[dots.length] = dot;
        } else {
          continue;
        }
      }
      return dots;
    };
    BoardDot.prototype.check_nearby_dots = function(flag) {
      var dot, dots, _i, _j, _len, _len2;
      dots = this.get_nearby_dots();
      if (!flag) {
        if (!this.has_ally()) {
          for (_i = 0, _len = dots.length; _i < _len; _i++) {
            dot = dots[_i];
            if (!dot.has_ally()) {
              if (this.parent.ko_dot != null) {
                this.parent.ko_dot = null;
                break;
              } else {
                this.parent.ko_dot = dot.name;
              }
            }
          }
        }
      }
      for (_j = 0, _len2 = dots.length; _j < _len2; _j++) {
        dot = dots[_j];
        this.parent.check_with_capture(dot, this, flag);
      }
      return this.parent.capture_stones();
    };
    BoardDot.prototype.has_ally = function() {
      var dot, dots, _i, _len;
      dots = this.get_nearby_dots();
      for (_i = 0, _len = dots.length; _i < _len; _i++) {
        dot = dots[_i];
        if (dot.owner === this.owner || dot.owner === 'e') {
          return true;
        }
      }
      return false;
    };
    return BoardDot;
  })();
  window.bind_review = function() {
    return on_review_click;
  };
  window.on_review_click = function(e) {
    var branch, data, dot, key, move, new_branch, next_node, value;
    move = {};
    dot = review.board.get_cursor_position(e);
    if (dot != null) {
      if (dot.owner !== 'e') {
        return;
      }
      if (review.board.on_dot_click(dot) === true) {
        key = dot.owner.toUpperCase();
        value = dot.name;
        branch = review.branch_start_with(key, value);
        if (!review.master.property[review.step + 1]) {
          if (branch != null) {
            if (review.track[review.track.length - 1] !== branch) {
              review.track.push(branch);
            }
            review.master = branch;
            review.step = 1;
          } else if (review.master.branches.length > 0) {
            data = {};
            data[key] = value;
            new_branch = create_branch(data);
            review.fork_branches(new_branch);
            if (review.track[review.track.length - 1] !== branch) {
              review.track.push(new_branch);
            }
            review.master = new_branch;
            review.step = 1;
          } else {
            data = {};
            data[key] = value;
            review.master.property.push(data);
            review.step++;
          }
        } else {
          next_node = review.master.property[review.step + 1];
          if (next_node[key] === value) {
            return;
          } else {
            data = {};
            data[key] = value;
            new_branch = create_branch(data);
            review.fork_branches(new_branch);
            if (review.track[review.track.length - 1] !== branch) {
              review.track.push(new_branch);
            }
            review.master = new_branch;
            review.step = 1;
          }
        }
        review.sgf_json = review.track[0];
        return $('#game_review').attr('sgf', to_sgf(review.sgf_json));
      }
    }
  };
  window.bind_click = function() {
    return on_player_click;
  };
  window.on_player_click = function(e) {
    var black_player, current_player, current_user, dot, game_mode, game_status, move, white_player;
    move = {};
    game_mode = $('#game').attr('mode');
    game_status = $('#game').attr('status');
    black_player = $('#game').attr('black_player');
    white_player = $('#game').attr('white_player');
    current_player = $('#game').attr('current_player');
    current_user = $('#game').attr('current_user');
    if (game_mode !== 0) {
      if (current_player !== current_user || game_status === '1') {
        return;
      }
    }
    dot = player.board.get_cursor_position(e);
    if (dot != null) {
      if (dot.owner !== 'e') {
        return;
      }
      player.board.draw_fake_stone(dot);
      if (clock_status === 0) {
        rattle_clock();
      }
      return window.pendding_move = function() {
        if (player.board.on_dot_click(dot) === true) {
          move[dot.owner.toUpperCase()] = dot.name;
          player.parser.update_game(move);
          if (black_player === current_player) {
            $('#game').attr('current_player', white_player);
          } else {
            $('#game').attr('current_player', black_player);
          }
          $('#pass').hide();
          $('#score').hide();
          $('#resign').hide();
          $('#clock').hide();
          if (window.board_game_id != null) {
            return $.post('http://' + window.location.host + '/games/' + window.board_game_id + '/moves', {
              "sgf": $("#game").attr("sgf"),
              "player_id": $("#game").attr("current_user")
            });
          }
        }
      };
    }
  };
  window.post_comments = function() {
    return function(e) {
      if (e.keyCode === 13) {
        if (e.ctrlKey) {
          return $('#post_button').trigger('click');
        }
      }
    };
  };
  window.bind_key_fn = function() {
    return function(e) {
      var charCode, charStr;
      charCode = e.which;
      charStr = String.fromCharCode(charCode);
      switch (charStr) {
        case "n":
          return $("#next").trigger("click");
        case "p":
          return $("#prev").trigger("click");
        case "a":
          return $("#start").trigger("click");
        case "e":
          return $("#end").trigger("click");
        case "s":
          return $("#show_steps").trigger("click");
      }
    };
  };
  window.play_sound = function(name, volume) {
    var sound;
    if (sound_enabled && $.inArray(name, loaded_sounds) !== -1) {
      try {
        sound = $('#' + name + '_sound').get(0);
        sound.volume = volume;
        sound.currentTime = 0;
        return sound.play();
      } catch (err) {
        alert('sound error: ' + err);
        return loaded_sounds.splice($.inArray(name, loaded_sounds), 1);
      }
    }
  };
  window.create_thumbnail = function() {
    var canvas, copy, ctx, dataURL, size, source_image;
    size = 80;
    canvas = document.getElementById('board');
    dataURL = canvas.toDataURL('image/png');
    copy = document.createElement('canvas');
    copy.width = size;
    copy.height = size;
    source_image = new Image();
    source_image.src = dataURL;
    ctx = copy.getContext('2d');
    return source_image.onload = function() {
      var copy_bg;
      copy_bg = new Image();
      copy_bg.src = '/assets/default_board.jpg';
      return copy_bg.onload = function() {
        var data;
        ctx.drawImage(copy_bg, 0, 0, size, size);
        ctx.drawImage(source_image, 0, 0, size, size);
        data = copy.toDataURL('image/png').replace(/^data:image\/(png);base64,/, "");
        return $.post('http://' + window.location.host + '/games/' + window.board_game_id + '/thumbnails', {
          'image_data': data
        });
      };
    };
  };
  window.Board = Board;
  window.BoardDot = BoardDot;
  window.refresh = true;
  window.sound_enabled = true;
  window.loaded_sounds = new Array();
  window.pendding_move = null;
}).call(this);
