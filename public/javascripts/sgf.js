/* DO NOT MODIFY. This file was compiled Wed, 07 Sep 2011 12:23:32 GMT from
 * /Users/wei/code/html5-weiqi/app/assets/javascripts/sgf.coffee
 */

(function() {
  var SGF;
  var __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  SGF = (function() {
    function SGF(src) {
      this.src = src;
      this.list_type = ['AB', 'AE', 'AW', 'AR', 'CR', 'DD', 'LB', 'LN', 'MA', 'SL', 'SQ', 'TR'];
      this.tree_begin = /\(/;
      this.tree_end = /\)/;
      this.next = /(;|\(|\))/;
      this.property_begin = /\[/;
      this.property_end = /\]/;
      this.escape = /\\/;
      this.index = 0;
      this.data = this.src.attr('sgf');
      this.sgf_json = null;
    }
    SGF.prototype.parse_game = function() {
      var i;
      i = this.data.search(this.tree_begin);
      if (i === -1) {
        throw 'invalid sgf data';
      } else {
        this.index += i + 1;
        this.sgf_json = this.parse_tree();
      }
      return this.sgf_json;
    };
    SGF.prototype.parse_tree = function() {
      var cur, i, m;
      m = {
        "property": [],
        "branches": []
      };
      while (this.index < this.data.length) {
        i = this.data.slice(this.index).search(this.next);
        if (i !== -1) {
          cur = this.data[this.index + i];
          while (cur === '\n' || cur === '\r' || cur === ' ' || cur === '\t') {
            this.index++;
            cur = this.data[this.index + i];
          }
          if (cur === ';') {
            this.index += i + 1;
            m.property[m.property.length] = this.parse_node();
          } else if (cur === '(') {
            this.index += i + 1;
            m.branches[m.branches.length] = this.parse_tree();
          } else if (cur === ')') {
            this.index += i + 1;
            break;
          } else {
            throw 'unexpect character';
          }
        } else {
          break;
        }
      }
      return m;
    };
    SGF.prototype.parse_node = function() {
      var i, j, key, m;
      m = {};
      while (this.index < this.data.length) {
        i = this.data.slice(this.index).search(this.property_begin);
        if (i === -1) {
          break;
        }
        j = this.data.slice(this.index).search(this.next);
        if (j < i) {
          break;
        }
        key = this.data.slice(this.index, this.index + i);
        this.index += i + 1;
        if (__indexOf.call(this.list_type, key) >= 0) {
          m[key] = this.parse_list_value();
        } else {
          m[key] = this.parse_value();
        }
      }
      return m;
    };
    SGF.prototype.parse_value = function() {
      var i, j, v;
      i = this.data.slice(this.index).search(this.property_end);
      if (i === -1) {
        throw 'missing closing property symbol';
      }
      j = this.data.slice(this.index).search(this.escape);
      if (j === -1) {
        v = this.data.slice(this.index, this.index + i);
        this.index += i + 1;
      } else {
        if (i === j + 1) {
          v = this.data.slice(this.index, this.index + j);
          v += this.data.slice(this.index + i, this.index + i + 1);
          this.index += i + 1;
          v += this.parse_value();
        } else {
          v = this.data.slice(this.index, this.index + i);
          this.index += i + 1;
        }
      }
      return v;
    };
    SGF.prototype.parse_list_value = function() {
      var i, next, v;
      v = [];
      i = this.data.slice(this.index).search(this.property_end);
      if (i === -1) {
        throw 'missing closing property symbol';
      }
      next = this.index + i + 2;
      while (next < this.data.length && this.data.slice(this.index + i, next) === '][') {
        v[v.length] = this.data.slice(this.index, this.index + i);
        this.index = next;
        i = this.data.slice(this.index).search(this.property_end);
        if (i === -1) {
          throw 'missing closing property symbol';
        }
        next = this.index + i + 2;
      }
      v[v.length] = this.data.slice(this.index, this.index + i);
      this.index += i + 1;
      return v;
    };
    SGF.prototype.update_game = function(move) {
      var new_node;
      if (move != null) {
        new_node = this.create_node(move);
      }
      return this.append_node(new_node);
    };
    SGF.prototype.add_winner = function(winner) {
      var i, j, new_sgf, result;
      if (winner === 'W') {
        result = 'RE[W+R]';
      } else if (winner === 'B') {
        result = 'RE[B+R]';
      }
      i = this.data.search(/;/);
      j = this.data.slice(i + 1).search(this.next);
      new_sgf = this.data.slice(0, i + 1 + j) + result + this.data.slice(i + 1 + j);
      return this.src.attr('sgf', new_sgf);
    };
    SGF.prototype.update_comments = function(comment) {
      var c, i, j, k, n, new_comment, new_sgf, old_comment;
      i = this.data.length;
      if (!(comment != null)) {
        return;
      }
      c = comment.search(/\]/);
      if (c !== -1) {
        comment = comment.slice(0, c) + '\\' + comment.slice(c);
      }
      while (this.data[i] !== ';') {
        i--;
      }
      j = this.data.slice(i).search(/C\[/);
      if (j === -1) {
        new_comment = 'C[' + comment + ']';
        return this.append_node(new_comment);
      } else {
        n = i + j + 2;
        k = this.data.slice(n).search(this.escape);
        while (k !== -1) {
          n = n + k + 2;
          k = this.data.slice(n).search(this.escape);
        }
        k = this.data.slice(n).search(this.property_end);
        old_comment = this.data.slice(i + j + 2, n + k);
        new_comment = old_comment + '\n' + comment;
        new_sgf = this.data.slice(0, i + j) + 'C[' + new_comment + '])';
        return this.src.attr('sgf', new_sgf);
      }
    };
    SGF.prototype.append_node = function(new_node) {
      var i, new_data;
      i = this.src.attr('sgf').length;
      while (this.src.attr('sgf').charAt(i) !== ')') {
        i--;
      }
      new_data = this.src.attr('sgf').slice(0, i) + new_node + ')';
      return this.src.attr('sgf', new_data);
    };
    SGF.prototype.create_node = function(move) {
      var rs;
      rs = ';';
      if (typeof move.B !== "undefined") {
        rs += 'B[' + move.B + ']';
      } else if (typeof move.W !== "undefined") {
        rs += 'W[' + move.W + ']';
      }
      return rs;
    };
    return SGF;
  })();
  window.to_sgf = function(json_data) {
    var branch, data, e, k, p, v, _i, _j, _k, _len, _len2, _len3, _ref, _ref2;
    data = "(";
    if (json_data != null) {
      _ref = json_data.property;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        data += ";";
        for (k in p) {
          v = p[k];
          if (v instanceof Array) {
            data += k;
            for (_j = 0, _len2 = v.length; _j < _len2; _j++) {
              e = v[_j];
              data += '[' + e + ']';
            }
          } else {
            data += k + '[' + v + ']';
          }
        }
      }
      if (json_data.branches.length > 0) {
        _ref2 = json_data.branches;
        for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
          branch = _ref2[_k];
          data += to_sgf(branch);
        }
      }
      data += ")";
      return data;
    } else {
      return "";
    }
  };
  window.create_branch = function(data) {
    var rc;
    rc = {
      property: [],
      branches: []
    };
    rc.property.push(data);
    return rc;
  };
  window.SGF = SGF;
}).call(this);
