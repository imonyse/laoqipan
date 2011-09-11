#= require board
#= require sgf
#= require player

describe 'fork_branches', ->
  beforeEach ->
    loadFixtures('canvas.html')
  
  it "should correctly fork branches for sgf with branches", ->
    json_data = {property:[{FF:"4", GM:"1"}, {B:"pd"}, {W:"dd"}], branches:[{property:[{B:"aa", C:"ooxx"}, {W:"bb"}], branches:[]}, {property:[{B:"cc"}, {W:"dd"}], branches:[]}]}
    sgf_data = "(;FF[4]GM[1];B[pd];W[dd](;B[aa]C[ooxx];W[bb])(;B[cc];W[dd]))"
    $('#game').attr('sgf', sgf_data)
    parser = new SGF $('#game')
    window.player = new Player parser, "board"
    expect(window.player.sgf_json).toEqual(json_data)
    
    window.player.pre_stones()
    window.player.end()
    window.player.fork_branches({property:[{B:'qq'}], branches:[]})
    expect(to_sgf(window.player.sgf_json)).toEqual("(;FF[4]GM[1];B[pd];W[dd](;B[aa]C[ooxx];W[bb])(;B[cc];W[dd])(;B[qq]))")
    
  it "should create branches for sgf without branches", ->
    sgf = "(;FF[4]GM[1]SZ[19]FG[257:Figure 1]PM[1]PB[Takemiya Masaki]BR[9 dan]PW[Cho Chikun]WR[9 dan]KM[5.5]TM[28800]DT[1996-10-18,19]EV[21st Meijin]RO[2 (final)]SO[Go World #78]US[Arno Hollosi];B[pd];W[dp];B[pp];W[dd];B[pj];W[nc];B[oe];W[qc];B[pc];W[qd])"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    window.player = new Player parser, 'board'
    window.player.pre_stones()
    window.player.end()
    for i in [0..1]
      window.player.prev()
      
    window.player.fork_branches(create_branch({B:'pb'}))
    expect(to_sgf(window.player.sgf_json)).toEqual("(;FF[4]GM[1]SZ[19]FG[257:Figure 1]PM[1]PB[Takemiya Masaki]BR[9 dan]PW[Cho Chikun]WR[9 dan]KM[5.5]TM[28800]DT[1996-10-18,19]EV[21st Meijin]RO[2 (final)]SO[Go World #78]US[Arno Hollosi];B[pd];W[dp];B[pp];W[dd];B[pj];W[nc];B[oe];W[qc](;B[pc];W[qd])(;B[pb]))")
    
  it "should create branch in sub-branches", ->
    sgf = "(;FF[4]GM[1]SZ[19];B[pd];W[dd](;B[aa]C[comments];W[bb])(;B[cc];W[dd]))"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    window.player = new Player parser, 'board'
    window.player.pre_stones()
    window.player.end()
    window.player.master = window.player.sgf_json.branches[0]
    window.player.step = 0
    window.player.next()
    
    window.player.fork_branches(create_branch({W:'cc'}))
    
    expect(to_sgf(window.player.sgf_json)).toEqual('(;FF[4]GM[1]SZ[19];B[pd];W[dd](;B[aa]C[comments](;W[bb])(;W[cc]))(;B[cc];W[dd]))')
    
describe "branch_start_with", ->
  beforeEach ->
    loadFixtures('canvas.html')
    
  it "should return false", ->
    sgf = "(;FF[4]GM[1]SZ[19]FG[257:Figure 1]PM[1]PB[Takemiya Masaki]BR[9 dan]PW[Cho Chikun]WR[9 dan]KM[5.5]TM[28800]DT[1996-10-18,19]EV[21st Meijin]RO[2 (final)]SO[Go World #78]US[Arno Hollosi];B[pd];W[dp];B[pp];W[dd];B[pj];W[nc];B[oe];W[qc](;B[pc];W[qd])(;B[pb]))"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    window.player = new Player parser, 'board'
    window.player.pre_stones()
    window.player.end()
    
    expect(window.player.branch_start_with('B', 'pc').property[0].B).toEqual('pc')
    expect(window.player.branch_start_with('B', 'pb').property[0].B).toEqual('pb')
    expect(window.player.branch_start_with('W', 'pc')).toEqual(null)
    expect(window.player.branch_start_with('B', 'cc')).toEqual(null)