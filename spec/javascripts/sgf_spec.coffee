#= require sgf

describe 'SGF parse', ->
  beforeEach ->
    loadFixtures("canvas.html")
  
  it 'parse sgf data with basic information', ->
    sgf = "(;FF[4]GM[1]SZ[19]FG[257:Figure 1]PM[1]PB[Takemiya Masaki]BR[9 dan]PW[Cho Chikun]WR[9 dan]RE[W+Resign]KM[5.5]TM[28800]DT[1996-10-18,19]EV[21st Meijin]RO[2 (final)]SO[Go World #78]US[Arno Hollosi])"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    rs = parser.parse_game()
    expect(rs).not.toEqual(undefined)
    expect(rs.property[0]["FF"]).toEqual("4")
    expect(rs.property[0]["GM"]).toEqual("1")
    expect(rs.property[0]["SZ"]).toEqual("19")
    expect(rs.property[0]["FG"]).toEqual("257:Figure 1")
    expect(rs.property[0]["PM"]).toEqual("1")
    expect(rs.property[0]["PB"]).toEqual("Takemiya Masaki")
    expect(rs.property[0]["BR"]).toEqual("9 dan")
    expect(rs.property[0]["PW"]).toEqual("Cho Chikun")
    expect(rs.property[0]["WR"]).toEqual("9 dan")
    expect(rs.property[0]["RE"]).toEqual("W+Resign")
    expect(rs.property[0]["KM"]).toEqual("5.5")
    expect(rs.property[0]["TM"]).toEqual("28800")
    expect(rs.property[0]["DT"]).toEqual("1996-10-18,19")
    expect(rs.property[0]["EV"]).toEqual("21st Meijin")
    expect(rs.property[0]["RO"]).toEqual("2 (final)")
    expect(rs.property[0]["SO"]).toEqual("Go World #78")
    expect(rs.property[0]["US"]).toEqual("Arno Hollosi")
    expect(rs.branches).toEqual([])
    
  it 'parse sgf data with list of property values', ->
    sgf = "(;B[gk]LB[fk:a][dj:b][di:c][fl:d][gl:e][fj:f])";
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    rs = parser.parse_game()
    expect(rs.property[0]["B"]).toEqual("gk")
    expect(rs.property[0]["LB"]).toEqual(["fk:a", "dj:b", "di:c", "fl:d", "gl:e", "fj:f"])
    
  it 'parse a simple sgf data', ->
    sgf = "(;FF[4]GM[1]SZ[19]FG[257:Figure 1]PM[1]\nPB[Takemiya Masaki]BR[9 dan]PW[Cho Chikun]\nWR[9 dan]RE[W+Resign]KM[5.5]TM[28800]DT[1996-10-18,19]\nEV[21st Meijin]RO[2 (final)]SO[Go World #78]US[Arno Hollosi]\n;B[pd];W[dp];B[pp];W[dd];B[pj];W[nc];B[oe];W[qc];B[pc];W[qd])"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    rs = parser.parse_game()
    expect(rs.property[0]["FF"]).toEqual("4")
    expect(rs.property[1]["B"]).toEqual("pd")
    expect(rs.property[10]["W"]).toEqual("qd")
    
  it 'handle pass', -> 
    sgf = "(;W[cd];B[])";
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    rs = parser.parse_game()
    expect(rs.property[1]["B"]).toEqual("")
    
  it 'should parse sgf with branches', ->
    sgf = "(;FF[4]GM[1]SZ[19]FG[257:Figure 1]PM[1]\nPB[Takemiya Masaki]BR[9 dan]PW[Cho Chikun]\nWR[9 dan]RE[W+Resign]KM[5.5]TM[28800]DT[1996-10-18,19]\nEV[21st Meijin]RO[2 (final)]SO[Go World #78]US[Arno Hollosi]\n;B[pd];W[dp];B[pp];W[dd];B[pj];W[nc];B[oe];W[qc];B[pc];W[qd]\n(;B[qf];W[rf];B[rg];W[re];B[qg];W[pb];B[ob];W[qb])\n(;B[mp];W[fq];B[ci];W[cg];B[dl];W[cn];B[qo];W[ec];B[jp];W[jd]\n;B[ei];W[eg];B[kk]LB[qq:a][dj:b][ck:c][qp:d]N[Figure 1]))"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    rs = parser.parse_game()
    expect(rs.branches.length).toEqual(2)
    
describe "update sgf comments", ->
  beforeEach ->
    loadFixtures("canvas.html")

  it "should update last node as new comments", ->
    sgf = "(;B[pd];W[dp])"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    comments = "cas: I know you!"
    parser.update_comments(comments)
    parser = new SGF($("#game"))
    rs = parser.parse_game();
    expect(rs.property[1]["C"]).toEqual(comments)

  it "should update last node's old comments", ->
    sgf = "(;B[pd];W[dp]C[that's not funny])"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    comments = "com again?"
    parser.update_comments(comments)
    parser = new SGF($("#game"))
    rs = parser.parse_game()
    expect(rs.property[1]["C"]).toEqual("that's not funny\n"+comments)

  it "should update last node's old comments with escaping char", ->
    sgf = "(;B[pd];W[dp]C[cas[3d\\]:wow!])"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    comments = "new messages"
    parser.update_comments(comments)
    parser = new SGF($("#game"))
    rs = parser.parse_game()
    expect(rs.property[1]["C"]).toEqual("cas[3d]:wow!\n"+comments)

  it "should escape new comments properly", ->
    sgf = "(;B[pd];W[dp])"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    comments = "cas[3d]: I know you!"
    parser.update_comments(comments)
    parser = new SGF($("#game"))
    rs = parser.parse_game()
    expect(rs.property[1]["C"]).toEqual("cas[3d]: I know you!")

describe "update game results", ->
  beforeEach ->
    loadFixtures("canvas.html")

  it "should add RE W to a sgf", ->
    sgf = "(;FF[4]GM[1])"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    parser.add_winner("W")
    parser = new SGF($("#game"))
    rs = parser.parse_game()
    expect(rs.property[0]["RE"]).toEqual("W+R")
  
  it "should add RE B to a sgf", ->
    sgf = "(;FF[3]GM[1];B[pd])"
    $('#game').attr('sgf', sgf)
    parser = new SGF $('#game')
    parser.add_winner("B")
    parser = new SGF $("#game")
    rs = parser.parse_game()
    expect(rs.property[0]["RE"]).toEqual("B+R")
    
describe 'to_sgf tests', ->
  it "should generate simple sgf text", ->
    json_data = {property:[{FF:"3",GM:"1"}, {B:"pd"}], branches:[]}
    sgf_data = to_sgf(json_data)
    expect(sgf_data).toEqual("(;FF[3]GM[1];B[pd])")
    
  it "should generate complicated sgf text", ->
    json_data = {property:[{FF:"4", GM:"1"}, {B:"pd"}, {W:"dd"}], branches:[{property:[{B:"aa", C:"ooxx"}, {W:"bb"}], branches:[]}, {property:[{B:"cc"}, {W:"dd"}], branches:[]}]}
    sgf_data = to_sgf(json_data)
    expect(sgf_data).toEqual("(;FF[4]GM[1];B[pd];W[dd](;B[aa]C[ooxx];W[bb])(;B[cc];W[dd]))")
    
  it "should recover complicate sgf data", ->
    loadFixtures('canvas.html')
    src_sgf = "(;FF[4]GM[1]SZ[19]FG[257:Figure 1]PM[1]PB[Takemiya Masaki]BR[9 dan]PW[Cho Chikun]WR[9 dan]RE[W+Resign]KM[5.5]TM[28800]DT[1996-10-18,19]EV[21st Meijin]RO[2 (final)]SO[Go World #78]US[Arno Hollosi];B[pd];W[dp];B[pp];W[dd];B[pj];W[nc];B[oe];W[qc];B[pc];W[qd](;B[qf];W[rf];B[rg];W[re];B[qg];W[pb];B[ob];W[qb](;B[mp];W[fq];B[ci];W[cg];B[dl];W[cn];B[qo];W[ec];B[jp];W[jd];B[ei];W[eg];B[kk]LB[qq:a][dj:b][ck:c][qp:d]N[Figure 1];W[me]FG[257:Figure 2];B[kf];W[ke];B[lf];W[jf];B[jg](;W[mf];B[if];W[je];B[ig];W[mg];B[mj];W[mq];B[lq];W[nq](;B[lr];W[qq];B[pq];W[pr];B[rq];W[rr];B[rp];W[oq];B[mr];W[oo];B[mn](;W[nr];B[qp]LB[kd:a][kh:b]N[Figure 2];W[pk]FG[257:Figure 3];B[pm];W[oj];B[ok];W[qr];B[os];W[ol];B[nk];W[qj];B[pi];W[pl];B[qm];W[ns];B[sr];W[om];B[op];W[qi];B[oi](;W[rl];B[qh];W[rm];B[rn];W[ri];B[ql];W[qk];B[sm];W[sk];B[sh];W[og];B[oh];W[np];B[no];W[mm];B[nn];W[lp];B[kp];W[lo];B[ln];W[ko];B[mo];W[jo];B[km]N[Figure 3])(;W[ql]VW[ja:ss]FG[257:Dia. 6]MN[1];B[rm];W[ph];B[oh];W[pg];B[og];W[pf];B[qh];W[qe];B[sh];W[of];B[sj]TR[oe][pd][pc][ob]LB[pe:a][sg:b][si:c]N[Diagram 6]))(;W[no]VW[jj:ss]FG[257:Dia. 5]MN[1];B[pn]N[Diagram 5]))(;B[pr]FG[257:Dia. 4]MN[1];W[kq];B[lp];W[lr];B[jq];W[jr];B[kp];W[kr];B[ir];W[hr]LB[is:a][js:b][or:c]N[Diagram 4]))(;W[if]FG[257:Dia. 3]MN[1];B[mf];W[ig];B[jh]LB[ki:a]N[Diagram 3]))(;W[oc]VW[aa:sk]FG[257:Dia. 2]MN[1];B[md];W[mc];B[ld]N[Diagram 2]))(;B[qe]VW[aa:sj]FG[257:Dia. 1]MN[1];W[re];B[qf];W[rf];B[qg];W[pb];B[ob];W[qb]LB[rg:a]N[Diagram 1]))"
    $('#game').attr('sgf', src_sgf)
    parser = new SGF $('#game')
    json_data = parser.parse_game()
    sgf_data = to_sgf(json_data)
    expect(sgf_data).toEqual(src_sgf)
    