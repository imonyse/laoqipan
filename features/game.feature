Feature: Game
	In order to play go
	As signed in user
	I want to have the full function available of a game

	@javascript
	Scenario: user resign
		Given a user name "foo", email "foo@example.com" with password "foobar"
		And a user name "cas", email "cas@example.com" with password "foobar"
		And a game created by white_player "foo" and black_player "cas" and current_player "cas" with sgf:
		"""
		(;FF[4]GM[1]SZ[19]RU[Japanese]KM[6.5]PB[cas]PW[foo];B[pd];W[dp];B[pp];W[dc];B[de];W[cg];B[be];W[fd];B[fe];W[ge];B[ff];W[ed];B[cb];W[cc];B[bc];W[db];B[bb];W[di];B[ie];W[gf];B[cf];W[dg];B[df];W[nc];B[gg];W[hg];B[hf];W[hd];B[id];W[ic];B[jc];W[jb];B[ig];W[kc];B[jd];W[lb];B[hh];W[cm];B[bg];W[bi];B[fp];W[fq];B[gq];W[eq];B[hn];W[nq];B[np];W[mp];B[mo];W[op];B[no];W[pq];B[oo];W[oq];B[lp];W[qp];B[po];W[qo];B[pm];W[qf];B[pf];W[pg];B[qg];W[qh];B[rg];W[ph];B[qe];W[of];B[pe];W[rh];B[rf];W[mi];B[lj];W[mj];B[mk];W[nk];B[nl];W[ml];B[lk];W[ol];B[nm];W[pl];B[qm];W[ql];B[mq];W[gr];B[hq];W[hr];B[iq];W[em];B[fl];W[li];B[ki];W[kh];B[jh];W[kg];B[el];W[dl];B[fm];W[pb];B[qc];W[kj];B[ji];W[om];B[on];W[rm];B[en];W[dm];B[ir];W[qb];B[da];W[ea];B[ca];W[fb];B[ch];W[dh];B[ci];W[bh];B[cj];W[bj];B[ck];W[dj];B[bk];W[bl];B[aj];W[dk];B[ah];W[gj];B[fj];W[fi];B[gi];W[hi];B[fh];W[mm];B[nn];W[mr];B[lr];W[nr];B[do];W[co];B[ep];W[cq];B[ei];W[rc];B[rd];W[pc];B[rb];W[sc];B[sd];W[qd];B[fr];W[er];B[qc];W[kk];B[ll];W[qd];B[rn];W[qn];B[pn];W[rl];B[qc];W[lm];B[kl];W[qd];B[qq];W[qr];B[qc];W[jl];B[km];W[qd];B[rq];W[ro];B[qc];W[kn];B[jm];W[qd];B[rr];W[pr];B[qc];W[im];B[jn];W[qd];B[qs];W[ps];B[qc];W[jo];B[in];W[qd];B[nj];W[ok];B[qc];W[rs];B[ms];W[rp];B[sb];W[od];B[kf];W[lf];B[le];W[mf];B[kd];W[jf];B[lc];W[kb];B[ke];W[jg];B[mc];W[mb];B[oe];W[ne];B[cd];W[dn];B[eo];W[ek];B[fk];W[ns];B[ls];W[sg];B[sf];W[sh];B[hs];W[fs];B[me];W[md];B[ld];W[nd];B[qa];W[pa];B[ra];W[al];B[eg];W[ee];B[ef];W[if];B[he];W[gd];B[ai];W[cl];B[hg];W[lg];B[is];W[gs];B[eh];W[dd])
		"""
		When I am on the home page
		When I login as "cas" with password "foobar"
		And I click_game_item
		And I wait until game finished loading
		When I click_li "#resign"
		Then I should see "确定认输吗"
		And "#board_info" should be visible
		When I click_div "#confirm_cancel"
		Then "#board_info" should be invisible

		When I click_li "#resign"
		Then I should see "确定认输吗"
		When I click_div "#confirm_ok"
		Then I should see "中盘胜"
		And "#board_info" should be visible
		When I click_div "#info_ok"
		Then "#board_info" should be invisible

		When I logout
		And I login as "foo" with password "foobar"
		And I click_div "#games_widget div.collapse"
		And I wait until ".game_thumbnail" is visible
		And I click_game_item
		And I wait until ended game finished loading
		Then I should see "中盘胜"
		And "#board_info" should be visible
		When I click_div "#info_ok"
		Then "#board_info" should be invisible
		
		And user "cas" should have record wins "0" and loses "1"
		And user "foo" should have record wins "1" and loses "0"


	@javascript
	Scenario: user pass
		Given a user name "foo", email "foo@example.com" with password "foobar"
		And a user name "cas", email "cas@example.com" with password "foobar"
		And a game created by white_player "foo" and black_player "cas" and current_player "cas" with sgf:
		"""
		(;FF[4]GM[1]SZ[19]RU[Japanese]KM[6.5]PB[cas]PW[foo];B[pd];W[dp])
		"""
		And I am on the home page
		When I login as "cas" with password "foobar"
		And I click_game_item
		And I wait until game finished loading
		Then "#clock" should be visible
		And "#pass" should be visible
		When I click_li "#pass"
		Then "#board_info" should be visible
		When I click_div "#confirm_cancel"
		Then "#board_info" should be invisible
		When I click_li "#pass"
		Then "#board_info" should be visible
		When I click_div "#confirm_ok"
		Then "#pass" should be invisible
		When I logout
		And I login as "foo" with password "foobar"
		And I click_game_item
		And I wait until game finished loading
		Then "#clock" should be visible
		And "#pass" should be visible
		
	@javascript
	Scenario: game score
		Given a user name "foo", email "foo@example.com" with password "foobar"
		And a user name "cas", email "cas@example.com" with password "foobar"
		And a game created by white_player "foo" and black_player "cas" and current_player "foo" with sgf:
		"""
		(;FF[4]GM[1]SZ[19]RU[Japanese]KM[6.5]PB[cas]PW[foo];B[pd];W[dp];B[pp];W[dc];B[de];W[cg];B[be];W[fd];B[fe];W[ge];B[ff];W[ed];B[cb];W[cc];B[bc];W[db];B[bb];W[di];B[ie];W[gf];B[cf];W[dg];B[df];W[nc];B[gg];W[hg];B[hf];W[hd];B[id];W[ic];B[jc];W[jb];B[ig];W[kc];B[jd];W[lb];B[hh];W[cm];B[bg];W[bi];B[fp];W[fq];B[gq];W[eq];B[hn];W[nq];B[np];W[mp];B[mo];W[op];B[no];W[pq];B[oo];W[oq];B[lp];W[qp];B[po];W[qo];B[pm];W[qf];B[pf];W[pg];B[qg];W[qh];B[rg];W[ph];B[qe];W[of];B[pe];W[rh];B[rf];W[mi];B[lj];W[mj];B[mk];W[nk];B[nl];W[ml];B[lk];W[ol];B[nm];W[pl];B[qm];W[ql];B[mq];W[gr];B[hq];W[hr];B[iq];W[em];B[fl];W[li];B[ki];W[kh];B[jh];W[kg];B[el];W[dl];B[fm];W[pb];B[qc];W[kj];B[ji];W[om];B[on];W[rm];B[en];W[dm];B[ir];W[qb];B[da];W[ea];B[ca];W[fb];B[ch];W[dh];B[ci];W[bh];B[cj];W[bj];B[ck];W[dj];B[bk];W[bl];B[aj];W[dk];B[ah];W[gj];B[fj];W[fi];B[gi];W[hi];B[fh];W[mm];B[nn];W[mr];B[lr];W[nr];B[do];W[co];B[ep];W[cq];B[ei];W[rc];B[rd];W[pc];B[rb];W[sc];B[sd];W[qd];B[fr];W[er];B[qc];W[kk];B[ll];W[qd];B[rn];W[qn];B[pn];W[rl];B[qc];W[lm];B[kl];W[qd];B[qq];W[qr];B[qc];W[jl];B[km];W[qd];B[rq];W[ro];B[qc];W[kn];B[jm];W[qd];B[rr];W[pr];B[qc];W[im];B[jn];W[qd];B[qs];W[ps];B[qc];W[jo];B[in];W[qd];B[nj];W[ok];B[qc];W[rs];B[ms];W[rp];B[sb];W[od];B[kf];W[lf];B[le];W[mf];B[kd];W[jf];B[lc];W[kb];B[ke];W[jg];B[mc];W[mb];B[oe];W[ne];B[cd];W[dn];B[eo];W[ek];B[fk];W[ns];B[ls];W[sg];B[sf];W[sh];B[hs];W[fs];B[me];W[md];B[ld];W[nd];B[qa];W[pa];B[ra];W[al];B[eg];W[ee];B[ef];W[if];B[he];W[gd];B[ai];W[cl];B[hg];W[lg];B[is];W[gs];B[eh];W[dd];B[ej])
		"""
		And I am on the home page
		When I login as "foo" with password "foobar"
		And I click_game_item
		And I wait until game finished loading
		When I click_li "#score"
		And I click_div "#confirm_ok"
		Then I should see "请等待"
		When I logout
		And I login as "cas" with password "foobar"
		And I click_game_item
		And I wait until game finished loading
		Then I should see "对手请求数子计算胜负"
		When I click_div "#confirm_ok"
		Then I should see "请等待"
		And I should see "胜"

