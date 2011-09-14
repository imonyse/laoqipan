class SGF
  
  constructor: (@src) ->
    @list_type = [
      'AB', 'AE', 'AW', 'AR', 'CR', 'DD'
      'LB', 'LN', 'MA', 'SL', 'SQ', 'TR'
      ]
    @tree_begin     = /\(/
    @tree_end       = /\)/
    @next           = /(;|\(|\))/
    @property_begin = /\[/
    @property_end   = /\]/
    @escape         = /\\/
    
    @index          = 0
    @data           = @src.attr('sgf')
    @sgf_json       = null
    
  # { 
  #   "property" : [ { "SZ":19, "PB":"someone", ... }, {"B":"pd", "C":"some comments" }, ... ],
  #   "branches" : [ {"property":[...], "branches":[...] },  
  #                  {"property":[...], "branches":[...] }, 
  #                  ... ] 
  #  }
  parse_game : ->
    i = @data.search @tree_begin
    if i is -1
      throw 'invalid sgf data'
    else
      @index += i + 1
      @sgf_json = @parse_tree()
    return @sgf_json
      
  parse_tree : ->
    m = {"property":[], "branches":[]}
    while @index < @data.length
      i = @data[@index..].search @next
      if i isnt -1
        cur = @data.charAt(@index+i)
        while cur is '\n' or cur is '\r' or cur is ' ' or cur is '\t'
          @index++
          cur = @data.charAt(@index+i)
        
        if cur is ';'
          @index += i + 1
          m.property[m.property.length] = @parse_node()
        else if cur is '('
          @index += i + 1
          m.branches[m.branches.length] = @parse_tree()
        else if cur is ')'
          @index += i + 1
          break
        else
          throw 'unexpect character'
      else
        break
    return m
    
  parse_node : ->
    m = {}
    while @index < @data.length
      i = @data[@index..].search @property_begin
      if i is -1 then break
      j = @data[@index..].search @next
      if j < i then break
      
      key = @data[@index...(@index+i)]
      @index += i + 1
      if key in @list_type
        m[key] = @parse_list_value()
      else
        m[key] = @parse_value()
    return m
    
  parse_value: ->
    i = @data[@index..].search @property_end
    if i is -1 then throw 'missing closing property symbol'
    j = @data[@index..].search @escape
    if j is -1
      v = @data[@index...(@index+i)]
      @index += i + 1
    else
      if i is j + 1
        # '\' is before ']', escaping
        v = @data[@index...(@index+j)]
        v += @data[(@index+i)...(@index+i+1)]
        @index += i + 1
        v += @parse_value()
      else
        v = @data[@index...(@index+i)]
        @index += i + 1
    return v

  parse_list_value: ->
    v = []
    i = @data[@index..].search @property_end
    if i is -1 then throw 'missing closing property symbol'
    next = @index + i + 2
    while next < @data.length and @data[(@index+i)...next] is '][' 
      v[v.length] = @data[@index...(@index+i)]
      @index = next
      i = @data[@index..].search @property_end
      if i is -1 then throw 'missing closing property symbol'
      next = @index + i + 2
    v[v.length] = @data[@index...(@index+i)]
    @index += i + 1
    return v
    
  update_game : (move) ->
    if move?
      new_node = @create_node(move)
    @append_node new_node
    
  add_winner : (winner) ->
    if winner is 'W'
      result = 'RE[W+R]'
    else if winner is 'B'
      result = 'RE[B+R]'
    i = @data.search(/;/)
    j = @data[(i+1)..].search @next
    new_sgf = @data[0...(i+1+j)] + result + @data[(i+1+j)..]
    @src.attr('sgf', new_sgf)
    
  update_comments : (comment) ->
    i = @data.length
    if not comment?
      return
      
    c = comment.search(/\]/)
    if c isnt -1
      comment = comment[0...c] + '\\' + comment[c..]
      
    while @data.charAt(i) isnt ';'
      i--

    j = @data[i..].search /C\[/
    if j is -1
      new_comment = 'C[' + comment + ']'
      @append_node new_comment
    else
      # update existing comments
      n = i + j + 2
      k = @data[n..].search @escape
      while k isnt -1
        n = n + k + 2
        k = @data[n..].search @escape
      k = @data[n..].search @property_end
      old_comment = @data[(i+j+2)...(n+k)]
      new_comment = old_comment + '\n' + comment
      new_sgf = @data[0...(i+j)] + 'C[' + new_comment + '])'
      @src.attr('sgf', new_sgf)
      
  # append new node to the end of sgf
  append_node : (new_node) ->
    i = @src.attr('sgf').length
    while @src.attr('sgf').charAt(i) != ')'
      i--
      
    new_data = @src.attr('sgf')[0...i] + new_node + ')'
    @src.attr('sgf', new_data)
    
  create_node : (move) ->
    rs = ';'
    if typeof move.B isnt "undefined"
      rs += 'B[' + move.B + ']'
    else if typeof move.W isnt "undefined"
      rs += 'W[' + move.W + ']'
    
    return rs
    
# convert tree nodes to a sgf text
window.to_sgf = (json_data)->
  data = "("
  if json_data?
    for p in json_data.property
      data += ";"
      for k of p
        v = p[k]
        if v instanceof Array
          data += k
          for e in v
            data += '[' + e + ']'
        else
          data += k + '[' + v + ']'
    if json_data.branches.length > 0
      for branch in json_data.branches
        data += to_sgf(branch)
    data += ")"
    return data
  else
    return ""
    
window.create_branch = (data) ->
  rc = {property:[], branches:[]}
  rc.property.push(data)
  return rc
      
window.SGF = SGF

