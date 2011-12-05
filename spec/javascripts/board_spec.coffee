#= require board

describe 'Board', ->
  board = null

  beforeEach ->
    loadFixtures("canvas.html")
    board = new Board 19, "b", "board"
  
  it 'Board init should success', ->
    expect(board.dots.length).toEqual 361
    expect(board.board_size).toEqual 19
    expect(board.color_in_turn).toEqual 'b'
    expect(board.status).toEqual 1
    
  it 'find_stone_by_name should work', ->
    expect(board.find_stone_by_name('aa').name).toEqual 'aa'
    expect(board.find_stone_by_name('tt')).toEqual null

  it "get_sibling should work", ->
    dot = board.find_stone_by_name('ab')
    expect(dot.get_dot_from "left").toEqual null
    expect((dot.get_dot_from "right").name).toEqual 'bb'
    expect((dot.get_dot_from "top").name).toEqual 'aa'
    expect((dot.get_dot_from "bottom").name).toEqual 'ac'
    
  it "find_stone_by_coordinates should work", ->
    expect(board.find_stone_by_coordinates('q16').name).toEqual 'pd'
    expect(board.find_stone_by_coordinates('d4').name).toEqual 'dp'
    
  it 'should simulate click via coordinates', ->
    board.click_via_coordinates 'd16'
    expect((board.find_stone_by_coordinates 'd16').owner).toEqual 'b'
    
  it 'should simulate click via coordinates with specified color', ->
    board.click_via_coordinates 'd16', 'w'
    expect(board.find_stone_by_coordinates('d16').owner).toEqual 'w'
    board.click_via_coordinates 'q15', 'w'
    expect(board.find_stone_by_name('pe').owner).toEqual 'w'
    board.click_via_coordinates 'q16'
    expect(board.find_stone_by_coordinates('q16').owner).toEqual 'b'
    board.click_via_coordinates 'k16', 'b'
    expect(board.find_stone_by_coordinates('k16').owner).toEqual 'b'
    
  it 'should simulate click via sgf move name', ->
    board.click_via_name 'dd'
    expect(board.find_stone_by_name('dd').owner).toEqual 'b'
    
  it 'should simulate click via sgf move name with specified color', ->
    board.click_via_name 'dd', 'w'
    expect(board.find_stone_by_name('dd').owner).toEqual 'w'
    board.click_via_name 'pe', 'w'
    expect(board.find_stone_by_name('pe').owner).toEqual 'w'
    board.click_via_name 'pd'
    expect(board.find_stone_by_name('pd').owner).toEqual 'b'
    
  it 'should draw last move mark', ->
    expect(board.last_move).toEqual null
    
    board.click_via_name 'dd'
    expect(board.last_move.name).toEqual 'dd'
    board.click_via_name 'dc'
    expect(board.last_move.name).toEqual 'dc'
    
  describe 'stone live and dead check', ->
    it 'stone with liberties should live', ->
      board.click_via_coordinates 'd16'
      dot = board.find_stone_by_coordinates 'd16'
      expect(board.is_alive dot).toEqual true
      
    it 'united stones with liberties should live', ->
      for pos in ['q16', 'q15', 'r16', 'r15', 's16', 's15']
        board.click_via_coordinates pos
      
      expect(board.is_alive(board.find_stone_by_name 'pd')).toEqual true
      expect(board.is_alive(board.find_stone_by_name 'rd')).toEqual true
      
    it 'stone withou liberties should die', ->
      board.click_via_coordinates 'd16', 'b'
      for pos in ['d17', 'c16', 'd15', 'e16']
        board.click_via_coordinates pos, 'w'
      expect(board.is_alive board.find_stone_by_coordinates('d16')).toEqual false
      
  describe 'stone captures', ->
    it 'should remove three stones without liberties', ->
      for pos in ['c17', 'd17', 'c16']
        board.click_via_coordinates pos, 'b'
      
      for pos in ['b17', 'b16', 'c15', 'c18', 'd18', 'e17', 'd16']
        board.click_via_coordinates pos, 'w'

      for pos in ['c17', 'd17', 'c16']
        expect(board.find_stone_by_coordinates(pos).owner).toEqual 'e'
      
    it 'a bunch of stones without liberties should die', ->
      pos_list = [
        'o12', 'n12', 'o11', 'n11', 'o10', 'n10', 'o9', 'n9', 'o8', 'n8'
        'o7', 'n7', 'p7', 'm7', 'n6', 'o6', 'm6', 'p6', 'l7', 'q7', 'm8'
        'p8', 'm9', 'p9', 'm10', 'p10', 'm11', 'p11', 'm12', 'p12', 'n13'
      ]
      for pos in pos_list
        board.click_via_coordinates pos
        
      for name in ['mh', 'mi', 'mj', 'mk', 'ml', 'mm', 'lm']
        expect(board.find_stone_by_name(name).owner).toEqual 'e'
      
    it 'special line of stones without liberties should die', ->
      for pos in ['a1', 'b1', 'c1', 'd1', 'e1', 'f1']
        board.click_via_coordinates pos, 'b'
      for pos in ['a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g1']
        board.click_via_coordinates pos, 'w'

      for name in ['as', 'bs', 'cs', 'ds', 'es', 'fs']
        expect(board.find_stone_by_name(name).owner).toEqual 'e'
      
    it 'should remove suicide stone', ->
      for pos in ['c17', 'c16', 'd16', 'c19', 'd18', 'b17', 'e17', 'd17']
        board.click_via_coordinates pos
      expect(board.find_stone_by_name('dc').owner).toEqual('e')
      expect(board.last_move.name).toEqual 'dc'
      
    it 'a special case', ->
      for pos in ['a13', 'a12', 'a11', 'b11', 'b10', 'c11', 'd11', 'c12', 'b12']
        board.click_via_coordinates pos
      expect(board.find_stone_by_name("ah").owner).toEqual("e")
      
    it 'should remove a bunch of stones', ->
      for pos in ['r19','q19', 'r18', 'q18', 's18', 'r17', 't19', 's17', 's16', 't18', 'r16', 's19']
        board.click_via_coordinates pos
      
      expect(board.find_stone_by_coordinates("s19").owner).toEqual("w")
      
    it 'every added stone should reset dots_checked list', ->
      for pos in ['g16', 'g15', 'h16', 'h15', 'j15', 'j16', 'h14', 'h17', 'g14', 'g17', 'f15']
        board.click_via_coordinates pos
      
      expect(board.find_stone_by_coordinates("g15").owner).toEqual("e")
      expect(board.find_stone_by_coordinates("h15").owner).toEqual("e")
      
      board.click_via_coordinates("g15")
      expect(board.find_stone_by_coordinates("g15").owner).toEqual("w")
      
    it 'should remove opponent stone without liberties even if it has no liberties when place', ->
      for pos in ['o16', 'p16', 'n15', 'q15', 'o14', 'p14', 'r14', 'm14', 'q13', 'n13', 'p15', 'o15']
        board.click_via_coordinates pos
        
      expect(board.find_stone_by_name("oe").owner).toEqual("e")
      expect(board.find_stone_by_name("ne").owner).toEqual("w")
      
    it "normally you wouldn't placed positions", ->
      for pos in ['t18', 's18', 'r19']
        board.click_via_coordinates pos, 'w'
        
      for pos in ['t17', 's17', 'r18', 's19']
        board.click_via_coordinates pos, 'b'
        
      board.click_via_coordinates 't19', 'w'  
      expect(board.find_stone_by_coordinates("s19").owner).toEqual("e")
      expect(board.find_stone_by_coordinates("t19").owner).toEqual("w");
      expect(board.find_stone_by_coordinates("t18").owner).toEqual("w");
      expect(board.find_stone_by_coordinates("s18").owner).toEqual("w");

      board.click_via_coordinates("s19", "b");
      expect(board.find_stone_by_coordinates("t19").owner).toEqual("e");
      expect(board.find_stone_by_coordinates("t18").owner).toEqual("e");
      expect(board.find_stone_by_coordinates("s18").owner).toEqual("e");
      
    it 'dragon eat without liberties case', ->
      for pos in ['a16','b16','b17','b18','b19','c19','c17']
        board.click_via_coordinates pos, 'b'
      
      for pos in ['a18','a17','a15','b15','c16','d17','d18','c18','d19']
        board.click_via_coordinates pos, 'w'
        
      board.click_via_coordinates 'a19', 'b'
      expect(board.find_stone_by_coordinates('a18').owner).toEqual 'e'
      expect(board.find_stone_by_coordinates('a17').owner).toEqual 'e'
      expect(board.find_stone_by_coordinates('b19').owner).toEqual 'b'
      
  describe 'KO handler', ->
    it 'ko create', ->
      for pos in ['c17', 'd17', 'b16', 'e16', 'c15', 'd15', 'd16', 'c16']
        board.click_via_coordinates pos
        
      # create KO
      expect(board.ko_dot).toEqual 'dd'
      board.click_via_coordinates 'd16'
      expect(board.find_stone_by_coordinates('d16').owner).toEqual('e')
      expect(board.color_in_turn).toEqual 'b'
      
      # release KO
      board.click_via_coordinates 'b15'
      expect(board.ko_dot).toEqual null
      board.click_via_coordinates 'b17'
      # create second
      board.click_via_coordinates 'd16'
      expect(board.find_stone_by_coordinates('d16').owner).toEqual 'b'
      expect(board.find_stone_by_coordinates('c16').owner).toEqual 'e'
      expect(board.ko_dot).toEqual 'cd'
      board.click_via_coordinates 'c16'
      expect(board.find_stone_by_coordinates('c16').owner).toEqual 'e'
      expect(board.color_in_turn).toEqual('w')
      # release second
      board.click_via_coordinates 'e17'
      expect(board.ko_dot).toEqual null
      board.click_via_coordinates 'e15'
      # create third
      board.click_via_coordinates 'c16'
      expect(board.find_stone_by_coordinates('c16').owner).toEqual 'w'
      expect(board.find_stone_by_coordinates('d16').owner).toEqual 'e'
      expect(board.ko_dot).toEqual 'dd'
      
  describe 'stone counting', ->
    it 'should update board stones count', ->
      expect(board.step_count).toEqual 0
      board.click_via_coordinates 'c16'
      expect(board.step_count).toEqual 1
      board.click_via_coordinates 'd11'
      expect(board.step_count).toEqual 2
      

