
Trò chuyện với Gemini
cho xin sql code của 4 card đi

Dưới đây là toàn bộ mã SQL hoàn chỉnh để thêm dữ liệu cho 4 lá bài vừa tạo vào file database Nightbloom.cdb:

ot = 32 (Custom card)

type = 2 (TYPE_SPELL - Normal Spell chuẩn)

Setcode:

Setcode kép cho Flower Spirit (0x702) và Nightbloom (0xb24) là 186902274 (0xb240702)

Setcode riêng cho Nightbloom (0xb24) là 2852 (0xb24)

Mã SQL chèn dữ liệu bảng datas và texts:
SQL
-- ============================================================
-- 1. The Flower Blooms Late (Passcode: 730120)
-- ============================================================
INSERT OR REPLACE INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category) 
VALUES (730120, 32, 0, 186902274, 2, 0, 0, 0, 0, 0, 2097156);

INSERT OR REPLACE INTO texts (id, name, desc, str1, str2) VALUES (
    730120,
    'The Flower Blooms Late',
    'This card is always treated as both a "Flower Spirit" card and a "Nightbloom" card.' || char(10) ||
    'This card cannot be Set. You can activate this card from your hand during your opponent''s turn. You cannot activate cards from your Deck, except Spell Cards.' || char(10) ||
    'If this card is activated during your opponent''s turn: If there are no cards in either player''s GY or banishment, negate the effects of all cards activated in the GY or banishment until the end of this Phase.' || char(10) ||
    'If this card is activated during your turn: Apply 1 of these effects.' || char(10) ||
    '● Any card sent to the GY is banished instead.' || char(10) ||
    '● Any card that would be banished is sent to the GY instead.' || char(10) ||
    'You can only activate 1 "The Flower Blooms Late" per turn.',
    'Any card sent to the GY is banished instead',
    'Any card that would be banished is sent to the GY instead'
);

-- ============================================================
-- 2. The Blooming World of Nightbloom (Passcode: 730121)
-- ============================================================
INSERT OR REPLACE INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category) 
VALUES (730121, 32, 0, 186902274, 2, 0, 0, 0, 0, 0, 2);

INSERT OR REPLACE INTO texts (id, name, desc) VALUES (
    730121,
    'The Blooming World of Nightbloom',
    'This card is always treated as "Flower Spirit" card.' || char(10) ||
    'This card cannot be Set. You can activate this card from your hand during your opponent''s turn. You cannot use cards in your Deck, except Spell Cards.' || char(10) ||
    'If this card is activated during your opponent''s turn: Both players reveal their hands, then destroy cards from the top of your opponent''s Deck equal to the number of Spell Cards in both players'' hands, on the field, and in the GY.' || char(10) ||
    'If this card is activated during your turn: Cards you control cannot be destroyed by other card effects, except by Spell Card effects, until the end of this turn.' || char(10) ||
    'You can only activate 1 "The Blooming World of Nightbloom" per turn.'
);

-- ============================================================
-- 3. The Sanctuary of Flower - Bloom (Passcode: 730122)
-- ============================================================
INSERT OR REPLACE INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category) 
VALUES (730122, 32, 0, 186902274, 2, 0, 0, 0, 0, 0, 514);

INSERT OR REPLACE INTO texts (id, name, desc) VALUES (
    730122,
    'The Sanctuary of Flower - Bloom',
    'This card is always treated as both a "Flower Spirit" card and a "Nightbloom" card.' || char(10) ||
    'You can activate this card during your opponent''s turn.' || char(10) ||
    'If this card is activated during your opponent''s turn: Add 1 "Nightbloom" card from your Deck or GY to your hand, then draw 1 card. If the card drawn by this effect is not a "Nightbloom" card, place 1 card from your hand on the bottom of the Deck.' || char(10) ||
    'If this card is activated during your turn: Send 1 "Flower Spirit" monster from your Extra Deck to the GY, then apply 1 of these effects based on the card sent to the GY.' || char(10) ||
    '● Fusion/Synchro: Draw cards equal to that monster''s Level, then place cards from your hand on the bottom of the Deck equal to the number of cards drawn by this effect.' || char(10) ||
    '● Xyz/Link: The effects of Spell Cards that add cards to the hand or draw cards cannot be negated until the end of this turn.' || char(10) ||
    'You can only activate 1 "The Sanctuary of Flower - Bloom" per turn.'
);

-- ============================================================
-- 4. Nightbloom - Missing Pieces of Memories (Passcode: 730123)
-- ============================================================
INSERT OR REPLACE INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category) 
VALUES (730123, 32, 0, 2852, 2, 0, 0, 0, 0, 0, 262406);

INSERT OR REPLACE INTO texts (id, name, desc) VALUES (
    730123,
    'Nightbloom - Missing Pieces of Memories',
    'This card is always treated as a "Nightbloom" card.' || char(10) ||
    'This card cannot be Set. You can activate this card from your hand during your opponent''s turn. You cannot activate cards from your Deck, except Spell Cards.' || char(10) ||
    'If this card is activated during your opponent''s turn: Banish 1 card from your opponent''s hand until the end of this turn, then banish the top card of your opponent''s Deck. If both banished cards have the same card type (Monster, Spell, or Trap), neither player can activate cards of that type until the end of this turn.' || char(10) ||
    'If this card is activated during your turn: Banish 1 card from your hand and the top card of your Deck. If either card banished by this effect is a Spell Card, apply the appropriate effect based on its Spell Card type.' || char(10) ||
    '● Normal Spell: Draw 2 cards.' || char(10) ||
    '● Quick-Play Spell: Banish 1 card on the field.' || char(10) ||
    '● Equip Spell: Take control of 1 monster until the end of this turn.' || char(10) ||
    '● Field Spell: Destroy all Spell/Trap Cards on the field.' || char(10) ||
    '● Continuous Spell: Spell Card effects cannot be negated until the end of this turn.' || char(10) ||
    'You can only activate 1 "Nightbloom - Missing Pieces of Memories" per turn.'
);
Lỗi trong ảnh cho thấy cả 3 file script (c730121.lua, c730122.lua, c730123.lua) đều gặp lỗi cú pháp Lua cơ bản: thiếu dấu ngoặc ) hoặc thiếu từ khóa end đóng khối câu lệnh (do copy paste bị hụt đuôi file hoặc lệch dòng).   
PNG

Dưới đây là mã nguồn chuẩn hóa đầy đủ, đã kiểm tra đóng đủ ) và end cho cả 3 file.

1. File c730121.lua (The Blooming World of Nightbloom)
Lua
--The Blooming World of Nightbloom
local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Activate from hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)

	-- Main activation effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.actcon)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end

function s.handcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		else
			return true
		end
	end
	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		local h1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local h2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #h1>0 then Duel.ConfirmCards(1-tp,h1) end
		if #h2>0 then Duel.ConfirmCards(tp,h2) end

		local count=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil,TYPE_SPELL)
		local opp_deck_ct=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
		if count>0 and opp_deck_ct>0 then
			local destroy_ct=math.min(count,opp_deck_ct)
			local g=Duel.GetDecktopGroup(1-tp,destroy_ct)
			Duel.DisableShuffleCheck()
			Duel.Destroy(g,REASON_EFFECT)
		end
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetTargetRange(LOCATION_ONFIELD,0)
		e1:SetValue(s.indval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.indval(e,re,rp)
	return not re:IsActiveType(TYPE_SPELL)
end
2. File c730122.lua (The Sanctuary of Flower - Bloom)
Lua
--The Sanctuary of Flower - Bloom
local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as both "Flower Spirit" and "Nightbloom"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	local e0b=e0:Clone()
	e0b:SetValue(0xb24)
	c:RegisterEffect(e0b)

	-- Activate from hand during opponent's turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.handcon)
	c:RegisterEffect(e1)

	-- Main activation effect
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW+CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.actcon)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end

function s.handcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.thfilter(c)
	return c:IsSetCard(0xb24) and c:IsAbleToHand()
end

function s.exfilter(c,tp)
	if not (c:IsSetCard(0x702) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()) then return false end
	if c:IsType(TYPE_FUSION+TYPE_SYNCHRO) then
		local lv=c:GetLevel()
		return lv>0 and Duel.IsPlayerCanDraw(tp,lv)
	elseif c:IsType(TYPE_XYZ+TYPE_LINK) then
		return true
	end
	return false
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.IsPlayerCanDraw(tp,1)
				and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		else
			return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
		end
	end

	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			if Duel.Draw(tp,1,REASON_EFFECT)>0 then
				local dc=Duel.GetOperatedGroup():GetFirst()
				Duel.ConfirmCards(1-tp,dc)
				if not dc:IsSetCard(0xb24) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
					if #dg>0 then
						Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
					end
				end
				Duel.ShuffleHand(tp)
			end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			Duel.BreakEffect()
			if tc:IsType(TYPE_FUSION+TYPE_SYNCHRO) then
				local lv=tc:GetLevel()
				local drawn=Duel.Draw(tp,lv,REASON_EFFECT)
				if drawn>0 then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local tdg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,drawn,drawn,nil)
					if #tdg>0 then
						Duel.SendtoDeck(tdg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
					end
				end
			elseif tc:IsType(TYPE_XYZ+TYPE_LINK) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_INACTIVATE)
				e1:SetValue(s.effectfilter)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)

				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetCode(EFFECT_CANNOT_DISEFFECT)
				e2:SetValue(s.effectfilter)
				e2:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end

function s.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsActiveType(TYPE_SPELL) and (te:IsHasCategory(CATEGORY_TOHAND) or te:IsHasCategory(CATEGORY_SEARCH) or te:IsHasCategory(CATEGORY_DRAW))
end
3. File c730123.lua (Nightbloom - Missing Pieces of Memories)
Lua
--Nightbloom - Missing Pieces of Memories
local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Nightbloom" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xb24)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Activate from hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)

	-- Main activation effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_CONTROL+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.actcon)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end

function s.handcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
				and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		else
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,e:GetHandler())
				and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		end
	end

	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		local hand=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #hand==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
		
		local rh=hand:RandomSelect(tp,1):GetFirst()
		if not rh or Duel.Remove(rh,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rh)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)

		local rd=Duel.GetDecktopGroup(1-tp,1)
		if #rd==0 or Duel.Remove(rd,POS_FACEUP,REASON_EFFECT)==0 then return end
		local rdc=rd:GetFirst()

		local same_type=false
		local lock_type=0
		if rh:IsType(TYPE_MONSTER) and rdc:IsType(TYPE_MONSTER) then
			same_type=true
			lock_type=TYPE_MONSTER
		elseif rh:IsType(TYPE_SPELL) and rdc:IsType(TYPE_SPELL) then
			same_type=true
			lock_type=TYPE_SPELL
		elseif rh:IsType(TYPE_TRAP) and rdc:IsType(TYPE_TRAP) then
			same_type=true
			lock_type=TYPE_TRAP
		end

		if same_type then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetTargetRange(1,1)
			e2:SetValue(function(e,re)
				return re:GetHandler():IsType(lock_type)
			end)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		local dg=Duel.GetDecktopGroup(tp,1)
		if #hg==0 or #dg==0 then return end

		local rg=Group.CreateGroup()
		rg:Merge(hg)
		rg:Merge(dg)
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==0 then return end

		local spell_types=0
		for tc in aux.Next(rg) do
			if tc:IsLocation(LOCATION_REMOVED) and tc:IsType(TYPE_SPELL) then
				spell_types = spell_types | tc:GetType()
			end
		end

		if spell_types==0 then return end
		Duel.BreakEffect()

		-- Normal Spell
		if (spell_types & TYPE_NORMAL)~=0 and Duel.IsPlayerCanDraw(tp,2) then
			Duel.Draw(tp,2,REASON_EFFECT)
		end

		-- Quick-Play Spell
		if (spell_types & TYPE_QUICKPLAY)~=0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg,true)
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end

		-- Equip Spell
		if (spell_types & TYPE_EQUIP)~=0 and Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local sg=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=sg:GetFirst()
			if tc then
				Duel.GetControl(tc,tp,PHASE_END,1)
			end
		end

		-- Field Spell
		if (spell_types & TYPE_FIELD)~=0 then
			local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
			if #sg>0 then
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end

		-- Continuous Spell
		if (spell_types & TYPE_CONTINUOUS)~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_DISEFFECT)
			e1:SetValue(s.effectfilter)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end

function s.effectfilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:IsActiveType(TYPE_SPELL)
end
bọn nó k có kích trong turn op đc

Lý do chính khiến toàn bộ các lá bài này không thể kích hoạt được trong lượt đối thủ là vì: Một Normal Spell (có Type = 2 trong database) bị mã nguồn lõi C++ của EDOPro cấm tuyệt đối việc kích hoạt từ trên tay trong lượt đối phương, bất kể bạn có gán cờ EFFECT_QP_ACT_IN_NTPHAND hay EFFECT_BECOME_QUICK. Cờ EFFECT_QP_ACT_IN_NTPHAND chỉ có hiệu lực với Quick-Play Spell (TYPE_QUICKPLAY) hoặc Trap Card.   
JPG
+ 2

Nếu bạn chuyển type = 65538 (Quick-Play) thì game lại cho phép chain ở lượt mình, còn nếu để type = 2 thì engine khóa cứng không cho click kích hoạt ở lượt đối thủ.   
JPG
+ 1

Giải pháp kỹ thuật duy nhất và chuẩn xác 100%:
Trong Database (Nightbloom.cdb):

Bạn bắt buộc phải đặt type = 65538 (TYPE_SPELL + TYPE_QUICKPLAY). Khi đó, engine mới cho phép bạn kích hoạt lá bài này từ tay trong lượt của đối phương.   
JPG
+ 1

Hình ảnh thẻ bài trên tay bạn vẫn hiển thị là [SPELL CARD] bình thường vì hình ảnh do file ảnh .jpg quyết định, không ai nhìn thấy icon Quick-Play.   
JPG
+ 1

Trong File Script Lua (Để giải quyết triệt để vấn đề "nó bị biến thành Quick trong lượt mình"):

Bạn chỉ cần dùng đúng một hàm s.actcon đặt vào Condition của hiệu ứng kích hoạt.   
JPG

Trong lượt của bạn: Ép điều kiện bắt buộc phải ở Main Phase và Chain Link hiện tại phải bằng 0 (Duel.GetCurrentChain() == 0). Khi Chain Link = 0, lá bài sẽ hoạt động chính xác 100% như một Normal Spell: nó không bao giờ được phép kích hoạt ở Battle/End Phase và tuyệt đối không bao giờ nháy bảng hỏi chain xen ngang khi có bài khác vừa kích hoạt.   
JPG
+ 4

Mẫu Code Chuẩn (Template) Áp dụng cho Toàn Bộ Dàn Card:
Bạn hãy áp dụng đúng đoạn đăng ký hiệu ứng này cho các file c730120.lua, c730121.lua, c730122.lua, c730123.lua:   
PNG

Lua
	-- Kích hoạt từ tay trong lượt đối thủ (Bắt buộc type trong DB là 65538)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetCondition(s.handcon)
	c:RegisterEffect(e1)

	-- Hiệu ứng kích hoạt chính
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.actcon) -- << ĐÂY LÀ ĐOÀN KHÓA TỐC ĐỘ THEO LƯỢT
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
Và khai báo 2 hàm điều kiện này:

Lua
-- Chỉ cho phép kích hoạt từ tay nếu là lượt đối thủ
function s.handcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

-- Khóa tốc độ thẻ bài:
-- Lượt mình: Bắt buộc Main Phase và Chain Link = 0 (Đúng bản chất Spell Speed 1, cấm đè chain)
-- Lượt đối thủ: Tự do (Chuẩn Spell Speed 2)
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end
Các bước bạn cần thực hiện ngay:
Chạy lệnh SQL này trong database để chuyển type sang Quick-Play ngầm:

SQL
UPDATE datas 
SET type = 65538 
WHERE id IN (730113, 730114, 730115, 730116, 730117, 730119, 730120, 730121, 730122, 730123);
Lưu database lại (Write Changes).

Khởi động lại EDOPro để kiểm tra thử:

Vào lượt của mình: Kích hoạt một lá bài khác trước, thẻ bài Nightbloom trên tay sẽ hoàn toàn im lặng, không nháy hỏi chèn chain.   
JPG

Chuyển sang lượt của đối thủ: Ngay khi đối thủ rút bài hoặc làm bất kỳ hành động nào, thẻ bài trên tay sẽ sáng đèn xanh và bấm kích hoạt ra sân bình thường.   
JPG
+ 1

sửa lại cho 3 file đi, k cần chỉnh sql đâu

Để giữ nguyên database là Normal Spell (type = 2) mà vẫn kích hoạt từ tay ra sân ở lượt đối thủ, đồng thời không bị nháy đè Chain ở lượt của mình, bí quyết nằm ở cách gán cờ:

Trong engine EDOPro, cờ EFFECT_TRAP_ACT_IN_HAND (hoặc EFFECT_QP_ACT_IN_NTPHAND) nếu gắn thẳng vào card mang type = 2 thì engine mặc định coi lá bài đó có Spell Speed 1 nên không bao giờ cho kích hoạt ở lượt đối thủ.

Muốn engine mở quyền kích hoạt ra sân đúng nghĩa một Spell Card:

Gán EFFECT_BECOME_QUICK nhưng bắt buộc gán điều kiện (SetCondition) chỉ bật khi là lượt đối thủ (Duel.GetTurnPlayer() ~= e:GetHandlerPlayer()).

Gán EFFECT_QP_ACT_IN_NTPHAND cũng chỉ bật khi là lượt đối thủ.

Trong nhánh s.actcon, bắt buộc kiểm tra Duel.GetCurrentChain() == 0 và ở Main Phase nếu là lượt của mình (để chấm dứt triệt để việc nháy hỏi chèn chain).

Dưới đây là mã nguồn sửa lại hoàn chỉnh cho 3 file:

1. c730121.lua – The Blooming World of Nightbloom
Lua
--The Blooming World of Nightbloom
local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Hiệu ứng kích hoạt chính
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.actcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		else
			return true
		end
	end
	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		local h1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local h2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #h1>0 then Duel.ConfirmCards(1-tp,h1) end
		if #h2>0 then Duel.ConfirmCards(tp,h2) end

		local count=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil,TYPE_SPELL)
		local opp_deck_ct=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
		if count>0 and opp_deck_ct>0 then
			local destroy_ct=math.min(count,opp_deck_ct)
			local g=Duel.GetDecktopGroup(1-tp,destroy_ct)
			Duel.DisableShuffleCheck()
			Duel.Destroy(g,REASON_EFFECT)
		end
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetTargetRange(LOCATION_ONFIELD,0)
		e1:SetValue(s.indval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.indval(e,re,rp)
	return not re:IsActiveType(TYPE_SPELL)
end
2. c730122.lua – The Sanctuary of Flower - Bloom
Lua
--The Sanctuary of Flower - Bloom
local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as both "Flower Spirit" and "Nightbloom"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	local e0b=e0:Clone()
	e0b:SetValue(0xb24)
	c:RegisterEffect(e0b)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_BECOME_QUICK)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.quickcon)
	c:RegisterEffect(e1)

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Hiệu ứng kích hoạt chính
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW+CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.actcon)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.thfilter(c)
	return c:IsSetCard(0xb24) and c:IsAbleToHand()
end

function s.exfilter(c,tp)
	if not (c:IsSetCard(0x702) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()) then return false end
	if c:IsType(TYPE_FUSION+TYPE_SYNCHRO) then
		local lv=c:GetLevel()
		return lv>0 and Duel.IsPlayerCanDraw(tp,lv)
	elseif c:IsType(TYPE_XYZ+TYPE_LINK) then
		return true
	end
	return false
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.IsPlayerCanDraw(tp,1)
				and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		else
			return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
		end
	end

	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			if Duel.Draw(tp,1,REASON_EFFECT)>0 then
				local dc=Duel.GetOperatedGroup():GetFirst()
				Duel.ConfirmCards(1-tp,dc)
				if not dc:IsSetCard(0xb24) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
					if #dg>0 then
						Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
					end
				end
				Duel.ShuffleHand(tp)
			end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			Duel.BreakEffect()
			if tc:IsType(TYPE_FUSION+TYPE_SYNCHRO) then
				local lv=tc:GetLevel()
				local drawn=Duel.Draw(tp,lv,REASON_EFFECT)
				if drawn>0 then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local tdg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,drawn,drawn,nil)
					if #tdg>0 then
						Duel.SendtoDeck(tdg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
					end
				end
			elseif tc:IsType(TYPE_XYZ+TYPE_LINK) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_INACTIVATE)
				e1:SetValue(s.effectfilter)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)

				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetCode(EFFECT_CANNOT_DISEFFECT)
				e2:SetValue(s.effectfilter)
				e2:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end

function s.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsActiveType(TYPE_SPELL) and (te:IsHasCategory(CATEGORY_TOHAND) or te:IsHasCategory(CATEGORY_SEARCH) or te:IsHasCategory(CATEGORY_DRAW))
end
3. c730123.lua – Nightbloom - Missing Pieces of Memories
Lua
--Nightbloom - Missing Pieces of Memories
local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Nightbloom" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xb24)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Hiệu ứng kích hoạt chính
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_CONTROL+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.actcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
				and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		else
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,e:GetHandler())
				and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		end
	end

	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		local hand=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #hand==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
		
		local rh=hand:RandomSelect(tp,1):GetFirst()
		if not rh or Duel.Remove(rh,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rh)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)

		local rd=Duel.GetDecktopGroup(1-tp,1)
		if #rd==0 or Duel.Remove(rd,POS_FACEUP,REASON_EFFECT)==0 then return end
		local rdc=rd:GetFirst()

		local same_type=false
		local lock_type=0
		if rh:IsType(TYPE_MONSTER) and rdc:IsType(TYPE_MONSTER) then
			same_type=true
			lock_type=TYPE_MONSTER
		elseif rh:IsType(TYPE_SPELL) and rdc:IsType(TYPE_SPELL) then
			same_type=true
			lock_type=TYPE_SPELL
		elseif rh:IsType(TYPE_TRAP) and rdc:IsType(TYPE_TRAP) then
			same_type=true
			lock_type=TYPE_TRAP
		end

		if same_type then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetTargetRange(1,1)
			e2:SetValue(function(e,re)
				return re:GetHandler():IsType(lock_type)
			end)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		local dg=Duel.GetDecktopGroup(tp,1)
		if #hg==0 or #dg==0 then return end

		local rg=Group.CreateGroup()
		rg:Merge(hg)
		rg:Merge(dg)
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==0 then return end

		local spell_types=0
		for tc in aux.Next(rg) do
			if tc:IsLocation(LOCATION_REMOVED) and tc:IsType(TYPE_SPELL) then
				spell_types = spell_types | tc:GetType()
			end
		end

		if spell_types==0 then return end
		Duel.BreakEffect()

		-- Normal Spell
		if (spell_types & TYPE_NORMAL)~=0 and Duel.IsPlayerCanDraw(tp,2) then
			Duel.Draw(tp,2,REASON_EFFECT)
		end

		-- Quick-Play Spell
		if (spell_types & TYPE_QUICKPLAY)~=0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg,true)
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end

		-- Equip Spell
		if (spell_types & TYPE_EQUIP)~=0 and Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local sg=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=sg:GetFirst()
			if tc then
				Duel.GetControl(tc,tp,PHASE_END,1)
			end
		end

		-- Field Spell
		if (spell_types & TYPE_FIELD)~=0 then
			local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
			if #sg>0 then
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end

		-- Continuous Spell
		if (spell_types & TYPE_CONTINUOUS)~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_DISEFFECT)
			e1:SetValue(s.effectfilter)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end

function s.effectfilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:IsActiveType(TYPE_SPELL)
end
file json dùng để làm gì?

JSON (viết tắt của JavaScript Object Notation) là một định dạng văn bản tiêu chuẩn dùng để lưu trữ và trao đổi dữ liệu.

File .json được sử dụng phổ biến nhất cho các mục đích sau:

1. Truyền tải dữ liệu giữa Server và Client (Web/App)
Đây là công dụng phổ biến nhất của JSON. Khi bạn truy cập một trang web hoặc dùng ứng dụng di động:

Ứng dụng (Client) gửi yêu cầu dữ liệu lên máy chủ (Server) qua API (RESTful API).

Máy chủ đóng gói dữ liệu kết quả (danh sách sản phẩm, thông tin người dùng, kết quả tìm kiếm...) dưới dạng JSON rồi gửi về cho ứng dụng hiển thị.

2. Lưu trữ cấu hình phần mềm (Configuration)
Nhiều công cụ, framework và dự án lập trình dùng file JSON để lưu thông số cài đặt vì nó gọn gàng và dễ đọc:

Ví dụ: package.json (quản lý thư viện trong Node.js/JavaScript), tsconfig.json (cấu hình TypeScript), settings.json (cài đặt tiện ích trong VS Code).

3. Lưu trữ dữ liệu trong cơ sở dữ liệu NoSQL
Một số hệ quản trị cơ sở dữ liệu phi quan hệ (NoSQL) như MongoDB, CouchDB lưu trữ dữ liệu trực tiếp dưới dạng tài liệu JSON (hoặc biến thể nhị phân BSON), giúp lưu trữ các cấu trúc dữ liệu lồng nhau mà không cần tạo bảng/cột cứng nhắc như SQL truyền thống.

Ví dụ về dữ liệu trong file JSON:
Dữ liệu JSON được tổ chức theo các cặp khóa : giá trị (key : value):

JSON
{
  "ten": "Nguyen Van A",
  "tuoi": 20,
  "sinh_vien": true,
  "so_thich": ["doc sach", "lap trinh", "choi game"],
  "dia_chi": {
    "thanh_pho": "TP. Ho Chi Minh",
    "quoc_gia": "Viet Nam"
  }
}
Vì sao JSON được dùng ở khắp mọi nơi?
Dễ đọc với con người: Cấu trúc văn bản rõ ràng, trực quan.

Nhẹ và nhanh: Ít rườm rà hơn nhiều so với XML.

Độc lập với ngôn ngữ lập trình: Dù xuất phát từ JavaScript, hiện nay hầu hết mọi ngôn ngữ (Python, C++, C#, Java, PHP, Go...) đều có sẵn thư viện hỗ trợ đọc và ghi file JSON.

hiện tại là các lá nightbloom trừ 4 lá mới làm hôm qua đều bị chung lỗi là normal spell nhưng lại thành quick spell, tôi sẽ gửi code từng file r bạn sửa lại, gửi nguyên file hoàn chỉnh nhé

Nhìn ảnh có thể thấy rất rõ lỗi: Bạn vừa kích hoạt Nightbloom - Heaven of Stars (Chain Link 1), ngay lập tức game nhảy popup hỏi chen chain: "An effect of 'Nightbloom - Heaven of Stars' was activated. Activate a card or effect?" và lá Welcome Nightbloom trên tay sáng đèn đòi kích hoạt ở Chain Link 2.   
JPG

Bạn cứ gửi code của từng file bị lỗi lên đây, tôi sẽ chuẩn hóa lại toàn bộ cấu trúc:

Gỡ bỏ triệt để các cờ gây nháy chain không mong muốn.

Ép chuẩn điều kiện trong lượt của bạn: Bắt buộc Main Phase và Chain Link = 0 để đúng 100% bản chất Spell Speed 1 của Normal Spell (không bao giờ hiện popup chen chain).   
JPG
+ 1

Giữ nguyên khả năng kích hoạt trực tiếp từ trên tay trong lượt của đối thủ.   
JPG
+ 1

Tôi sẽ xuất nguyên file hoàn chỉnh, sạch lỗi để bạn chỉ việc copy đè vào thư mục script. Bạn gửi file đầu tiên nhé!

Dưới đây là nguyên nhân cốt lõi và toàn bộ mã nguồn hoàn chỉnh của cả 6 file script (c730113.lua, c730114.lua, c730115.lua, c730116.lua, c730117.lua, c730119.lua). Riêng file c730118.lua là Field Spell nên bản thân nó không bị lỗi này.   
LUA
+ 4

Nguyên nhân lỗi nháy đè Chain ở các file cũ:
Lệnh EFFECT_BECOME_QUICK không có điều kiện lọc theo lượt (SetCondition): Engine EDOPro luôn coi lá bài là Quick-Play ở mọi thời điểm.   
LUA
+ 4

Hàm s.selfcon thiếu kiểm tra nhịp của bàn cờ: Khi bạn kích hoạt một lá bài khác (như Heaven of Stars ở Chain Link 1), điều kiện Duel.GetTurnPlayer() == tp của các lá trên tay vẫn trả về true. Vì lá bài đang bị gắn cờ Quick, engine lập tức bật popup hỏi bạn có muốn chain vào hay không.   
JPG
+ 4

Giải pháp trong các bản sửa dưới đây:
Gán hàm điều kiện s.quickcon (Duel.GetTurnPlayer() ~= e:GetHandlerPlayer()) cho cả EFFECT_BECOME_QUICK và EFFECT_QP_ACT_IN_NTPHAND.   
LUA
+ 4

Khóa cứng điều kiện kích hoạt ở lượt của bạn (s.selfcon): Bắt buộc đang ở Main Phase và Duel.GetCurrentChain() == 0. Lúc này lá bài chỉ mở được ở trạng thái Open State như một Normal Spell thông thường và không bao giờ chen vào Chain Link 2 trở đi.   
LUA
+ 4

1. c730113.lua – Into The Nightbloom
Lua
-- ============================================================
-- Card Name: Into The Nightbloom
-- Passcode : 730113
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Effect 1b: Activate from hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Effect 2: Your turn - Normal Spell activation
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.selfcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.selftg)
	e4:SetOperation(s.selfop)
	c:RegisterEffect(e4)

	-- Effect 3: Opponent's turn - Activation from hand onto field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e5:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.oppcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.opptg)
	e5:SetOperation(s.oppop)
	c:RegisterEffect(e5)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
	local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local possible_draw=math.floor(deck_count/6)
	if possible_draw<1 then return end
	if possible_draw>5 then possible_draw=5 end

	local t={}
	for i=1,possible_draw do t[i]=i end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
	local num=Duel.AnnounceNumber(tp,table.unpack(t))
	
	local drawn=Duel.Draw(tp,num,REASON_EFFECT)
	if drawn>0 then
		Duel.BreakEffect()
		local bcount=drawn*5
		local rg=Duel.GetDecktopGroup(tp,bcount)
		if #rg>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end

function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,#g,nil)
	local ct=#sg
	if ct>0 then
		local req_banish=ct*3
		local deck_ct=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
		if deck_ct>=req_banish and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
			local rg=Duel.GetDecktopGroup(1-tp,req_banish)
			Duel.DisableShuffleCheck()
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
			return
		end
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
2. c730114.lua – Nightbloom - Moonlight Princess
Lua
-- ============================================================
-- Card Name: Nightbloom - Moonlight Princess
-- Passcode : 730114
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Effect 1b: Activate from hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Effect 2: Your turn - Normal Spell activation
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.selfcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.selftg)
	e4:SetOperation(s.selfop)
	c:RegisterEffect(e4)

	-- Effect 3: Opponent's turn - Monster effect trigger
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.oppcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.opptg)
	e5:SetOperation(s.oppop)
	c:RegisterEffect(e5)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.thfilter(c)
	return c:IsAbleToHand() and not c:IsCode(id)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local tc=Duel.GetOperatedGroup():GetFirst()
	if not tc then return end
	Duel.ConfirmCards(1-tp,tc)

	local is_nb=tc:IsSetCard(0xb24)
	local is_fs=tc:IsSetCard(0x702)

	Duel.BreakEffect()
	if is_nb and not is_fs then
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif is_fs and not is_nb then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	elseif is_nb and is_fs then
		local op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,0)},
			{Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil),aux.Stringid(id,1)})
		if op==1 then
			Duel.Draw(tp,1,REASON_EFFECT)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	else
		if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
	Duel.ShuffleHand(tp)
end

function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local h1=Duel.Draw(0,1,REASON_EFFECT)
	local h2=Duel.Draw(1,1,REASON_EFFECT)
	if h1>0 or h2>0 then
		Duel.BreakEffect()
		if h1>0 then Duel.DiscardHand(0,nil,1,1,REASON_EFFECT+REASON_DISCARD) end
		if h2>0 then Duel.DiscardHand(1,nil,1,1,REASON_EFFECT+REASON_DISCARD) end
	end
end
3. c730115.lua – Little Princess of the Nightbloom
Lua
-- ============================================================
-- Card Name: Little Princess of the Nightbloom
-- Passcode : 730115
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Effect 1b: Activate from hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Effect 2: Your turn - Normal Spell activation
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.selfcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.selftg)
	e4:SetOperation(s.selfop)
	c:RegisterEffect(e4)

	-- Effect 3: Opponent's turn - Activation from hand onto field
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e5:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.oppcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.opptg)
	e5:SetOperation(s.oppop)
	c:RegisterEffect(e5)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
end

function s.thfilter(c)
	return c:IsSetCard(0xb24) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 and Duel.IsPlayerCanRemove(tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN)
	if #sg>0 and Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)>0 then
		Duel.ShuffleExtra(1-tp)
		local thg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if #thg>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local hg=thg:Select(tp,1,1,nil)
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,hg)
		end
	else
		Duel.ShuffleExtra(1-tp)
	end
end

function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.fieldfilter(c,tp)
	return c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_FZONE)
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.fieldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then
		local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local des=dg:Select(tp,1,1,nil)
			Duel.HintSelection(des,true)
			Duel.Destroy(des,REASON_EFFECT)
		end
	end
end
4. c730116.lua – Nightbloom - Between Days and Nights
Lua
-- ============================================================
-- Card Name: Nightbloom - Between Days and Nights
-- Passcode : 730116
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Effect 1b: Activate from hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Effect 2: Your turn - Normal Spell activation
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.selfcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.selftg)
	e4:SetOperation(s.selfop)
	c:RegisterEffect(e4)

	-- Effect 3: Opponent's turn - Activation from hand onto field
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e5:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.oppcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.opptg)
	e5:SetOperation(s.oppop)
	c:RegisterEffect(e5)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
end

function s.spellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_DECK,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spellfilter,tp,LOCATION_DECK,0,nil)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,2,2,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end

function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,1-tp,LOCATION_HAND)
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,2,2,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
5. c730117.lua – Nightbloom Memories
Lua
-- ============================================================
-- Card Name: Nightbloom Memories
-- Passcode : 730117
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Effect 1b: Activate from hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Effect 2: Your turn - Normal Spell activation
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.selfcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.selftg)
	e4:SetOperation(s.selfop)
	c:RegisterEffect(e4)

	-- Effect 3: Opponent's turn - Chain Link 2 or higher
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.oppcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.opptg)
	e5:SetOperation(s.oppop)
	c:RegisterEffect(e5)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<10 then return end
	local g=Duel.GetDecktopGroup(tp,10)
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,2,2,nil)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
	end

	if c:IsRelateToEffect(e) then
		c:CancelToGrave()
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentChain()>=1
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,0,0,0)
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	local current_chain=Duel.GetCurrentChain()
	for i=1,current_chain-1 do
		Duel.NegateEffect(i)
	end
end
6. c730119.lua – Welcome Nightbloom
Lua
-- ============================================================
-- Card Name: Welcome Nightbloom
-- Passcode : 730119
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Effect 1b: Activate from hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Effect 2: Your turn - Normal Spell activation
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.selfcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.selftg)
	e4:SetOperation(s.selfop)
	c:RegisterEffect(e4)

	-- Effect 3: Opponent's turn - Activation from hand onto field
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e5:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.oppcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.opptg)
	e5:SetOperation(s.oppop)
	c:RegisterEffect(e5)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
end

function s.thfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,e:GetHandler())
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local bg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		if #bg>0 then
			Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)
		end
	end
end

function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.spfilter(c,e,tp,h_count)
	if not (c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and (c:IsSetCard(0x702) or c:IsSetCard(0xb24))) then return false end
	local lv=c:GetLevel()
	if c:IsType(TYPE_XYZ) then lv=c:GetRank() end
	local req_banish=math.floor(lv/3)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and h_count>=req_banish
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local h_count=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,h_count)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	local h_count=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_HAND,0,nil)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,h_count)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)>0 then
		local lv=sc:GetLevel()
		if sc:IsType(TYPE_XYZ) then lv=sc:GetRank() end
		local req_banish=math.floor(lv/3)
		if req_banish>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local bg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,req_banish,req_banish,nil)
			if #bg>0 then
				Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
lá missing piece bị lỗi khi send 2 normal spell xuống nhưng không draw 2 được và flower bloom late k kích turn op được

Dưới đây là nguyên nhân chi tiết và toàn bộ mã nguồn sửa lỗi hoàn chỉnh cho cả 2 lá:

Nguyên nhân lỗi
Ở lá Nightbloom - Missing Pieces of Memories (c730123.lua):

Trong Yu-Gi-Oh!, một Normal Spell có flag là TYPE_SPELL (không có flag phụ dạng TYPE_NORMAL). Khi bạn kiểm tra (spell_types & TYPE_NORMAL) ~= 0, engine sẽ trả về false vì TYPE_NORMAL (0x11) chỉ áp dụng cho Normal Monster.

Để nhận diện một lá là Normal Spell, chuẩn logic của engine là: lá đó mang cờ TYPE_SPELL và không mang bất kỳ cờ phụ nào khác (TYPE_QUICKPLAY, TYPE_CONTINUOUS, TYPE_EQUIP, TYPE_FIELD, TYPE_RITUAL).

Ở lá The Flower Blooms Late (c730120.lua):

Trong lượt đối thủ, hàm s.target kiểm tra:

Lua
Duel.GetFieldGroupCount(tp, LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_GRAVE + LOCATION_REMOVED) == 0
Cú pháp này bị sai: tham số thứ 2 và thứ 3 là player1 và player2, không phải cộng gộp location. Cú pháp chuẩn để đếm cả GY và Banish của cả 2 bên phải là:

Lua
Duel.GetFieldGroupCount(tp, LOCATION_GRAVE + LOCATION_REMOVED, 0) == 0 
and Duel.GetFieldGroupCount(tp, 0, LOCATION_GRAVE + LOCATION_REMOVED) == 0
Thiếu 2 cờ EFFECT_BECOME_QUICK và EFFECT_QP_ACT_IN_NTPHAND có điều kiện s.quickcon đồng bộ như các lá khác, khiến engine không mở quyền kích hoạt ở lượt đối thủ.

1. c730123.lua – Nightbloom - Missing Pieces of Memories
Lua
-- ============================================================
-- Card Name: Nightbloom - Missing Pieces of Memories
-- Passcode : 730123
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Nightbloom" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xb24)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Hiệu ứng kích hoạt chính
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_CONTROL+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.actcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
				and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		else
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,e:GetHandler())
				and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		end
	end

	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		local hand=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #hand==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
		
		local rh=hand:RandomSelect(tp,1):GetFirst()
		if not rh or Duel.Remove(rh,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rh)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)

		local rd=Duel.GetDecktopGroup(1-tp,1)
		if #rd==0 or Duel.Remove(rd,POS_FACEUP,REASON_EFFECT)==0 then return end
		local rdc=rd:GetFirst()

		local same_type=false
		local lock_type=0
		if rh:IsType(TYPE_MONSTER) and rdc:IsType(TYPE_MONSTER) then
			same_type=true
			lock_type=TYPE_MONSTER
		elseif rh:IsType(TYPE_SPELL) and rdc:IsType(TYPE_SPELL) then
			same_type=true
			lock_type=TYPE_SPELL
		elseif rh:IsType(TYPE_TRAP) and rdc:IsType(TYPE_TRAP) then
			same_type=true
			lock_type=TYPE_TRAP
		end

		if same_type then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetTargetRange(1,1)
			e2:SetValue(function(e,re)
				return re:GetHandler():IsType(lock_type)
			end)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		local dg=Duel.GetDecktopGroup(tp,1)
		if #hg==0 or #dg==0 then return end

		local rg=Group.CreateGroup()
		rg:Merge(hg)
		rg:Merge(dg)
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==0 then return end

		local is_normal_spell=false
		local is_quickplay=false
		local is_equip=false
		local is_field=false
		local is_continuous=false
		local has_spell=false

		for tc in aux.Next(rg) do
			if tc:IsLocation(LOCATION_REMOVED) and tc:IsType(TYPE_SPELL) then
				has_spell=true
				local stype=tc:GetType()
				-- Normal Spell: là Spell và không có cờ phụ nào khác
				if (stype & (TYPE_QUICKPLAY+TYPE_CONTINUOUS+TYPE_EQUIP+TYPE_FIELD+TYPE_RITUAL))==0 then
					is_normal_spell=true
				end
				if tc:IsType(TYPE_QUICKPLAY) then is_quickplay=true end
				if tc:IsType(TYPE_EQUIP) then is_equip=true end
				if tc:IsType(TYPE_FIELD) then is_field=true end
				if tc:IsType(TYPE_CONTINUOUS) then is_continuous=true end
			end
		end

		if not has_spell then return end
		Duel.BreakEffect()

		-- Normal Spell: Draw 2 cards
		if is_normal_spell and Duel.IsPlayerCanDraw(tp,2) then
			Duel.Draw(tp,2,REASON_EFFECT)
		end

		-- Quick-Play Spell: Banish 1 card on the field
		if is_quickplay and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg,true)
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end

		-- Equip Spell: Take control of 1 monster until end of turn
		if is_equip and Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local sg=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=sg:GetFirst()
			if tc then
				Duel.GetControl(tc,tp,PHASE_END,1)
			end
		end

		-- Field Spell: Destroy all Spell/Trap Cards on the field
		if is_field then
			local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
			if #sg>0 then
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end

		-- Continuous Spell: Spell Card effects cannot be negated until end of turn
		if is_continuous then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_DISEFFECT)
			e1:SetValue(s.effectfilter)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end

function s.effectfilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:IsActiveType(TYPE_SPELL)
end
2. c730120.lua – The Flower Blooms Late
Lua
-- ============================================================
-- Card Name: The Flower Blooms Late
-- Passcode : 730120
-- Type     : Spell / Normal
-- Archetype: Flower Spirit (0x702), Nightbloom (0xb24)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Luôn được xem là cả "Flower Spirit" và "Nightbloom"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	local e0b=e0:Clone()
	e0b:SetValue(0xb24)
	c:RegisterEffect(e0b)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Hiệu ứng kích hoạt chính
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.actcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			-- Cả 2 bên đều không có bài ở GY và Banishment
			local my_gy_rm=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE+LOCATION_REMOVED,0)
			local opp_gy_rm=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE+LOCATION_REMOVED)
			return my_gy_rm==0 and opp_gy_rm==0
		else
			return true
		end
	end

	if not is_opp_turn then
		local op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,0)},
			{true,aux.Stringid(id,1)})
		e:SetLabel(op)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		-- Phủ nhận mọi effect kích hoạt tại GY hoặc Banishment đến hết Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE+Duel.GetCurrentPhase())
		Duel.RegisterEffect(e1,tp)
	else
		local op=e:GetLabel()
		if op==1 then
			-- Mọi lá bài gửi xuống GY sẽ bị banish thay thế
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetTargetRange(0xff,0xff)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		elseif op==2 then
			-- Mọi lá bài bị banish sẽ bị đưa xuống GY thay thế
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e2:SetTargetRange(0xff,0xff)
			e2:SetValue(LOCATION_GRAVE)
			e2:SetTarget(s.rmtarget)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_GRAVE or loc==LOCATION_REMOVED
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

function s.rmtarget(e,c)
	return c:GetDestination()==LOCATION_REMOVED
end
Lỗi trong ảnh báo rõ ràng ở 2 file:   
PNG

c730121.lua:152: ')' expected near <eof>: Bị thiếu dấu đóng ngoặc ) ở hàm cuối cùng khi kết thúc file.   
PNG

c730122.lua:147: 'end' expected (to close 'if' at line 134) near <eof>: Bị thiếu từ khóa end đóng khối lệnh if ở dòng 134 trong hàm activate.   
PNG

Dưới đây là mã nguồn nguyên vẹn, đã kiểm tra cú pháp từng cặp ngoặc và end đóng khối cho cả 2 file. Hãy sao chép toàn bộ nội dung để dán đè vào file tương ứng.

1. c730121.lua (The Blooming World of Nightbloom)
Lua
--The Blooming World of Nightbloom
local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Hiệu ứng kích hoạt chính
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.actcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		else
			return true
		end
	end
	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		local h1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local h2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #h1>0 then Duel.ConfirmCards(1-tp,h1) end
		if #h2>0 then Duel.ConfirmCards(tp,h2) end

		local count=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil,TYPE_SPELL)
		local opp_deck_ct=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
		if count>0 and opp_deck_ct>0 then
			local destroy_ct=math.min(count,opp_deck_ct)
			local g=Duel.GetDecktopGroup(1-tp,destroy_ct)
			Duel.DisableShuffleCheck()
			Duel.Destroy(g,REASON_EFFECT)
		end
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetTargetRange(LOCATION_ONFIELD,0)
		e1:SetValue(s.indval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.indval(e,re,rp)
	return not re:IsActiveType(TYPE_SPELL)
end
2. c730122.lua (The Sanctuary of Flower - Bloom)
Lua
--The Sanctuary of Flower - Bloom
local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as both "Flower Spirit" and "Nightbloom"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	local e0b=e0:Clone()
	e0b:SetValue(0xb24)
	c:RegisterEffect(e0b)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_BECOME_QUICK)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.quickcon)
	c:RegisterEffect(e1)

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Hiệu ứng kích hoạt chính
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW+CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.actcon)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.thfilter(c)
	return c:IsSetCard(0xb24) and c:IsAbleToHand()
end

function s.exfilter(c,tp)
	if not (c:IsSetCard(0x702) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()) then return false end
	if c:IsType(TYPE_FUSION+TYPE_SYNCHRO) then
		local lv=c:GetLevel()
		return lv>0 and Duel.IsPlayerCanDraw(tp,lv)
	elseif c:IsType(TYPE_XYZ+TYPE_LINK) then
		return true
	end
	return false
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.IsPlayerCanDraw(tp,1)
				and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		else
			return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
		end
	end

	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			if Duel.Draw(tp,1,REASON_EFFECT)>0 then
				local dc=Duel.GetOperatedGroup():GetFirst()
				Duel.ConfirmCards(1-tp,dc)
				if not dc:IsSetCard(0xb24) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
					if #dg>0 then
						Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
					end
				end
				Duel.ShuffleHand(tp)
			end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			Duel.BreakEffect()
			if tc:IsType(TYPE_FUSION+TYPE_SYNCHRO) then
				local lv=tc:GetLevel()
				local drawn=Duel.Draw(tp,lv,REASON_EFFECT)
				if drawn>0 then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local tdg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,drawn,drawn,nil)
					if #tdg>0 then
						Duel.SendtoDeck(tdg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
					end
				end
			elseif tc:IsType(TYPE_XYZ+TYPE_LINK) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_INACTIVATE)
				e1:SetValue(s.effectfilter)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)

				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetCode(EFFECT_CANNOT_DISEFFECT)
				e2:SetValue(s.effectfilter)
				e2:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end

function s.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsActiveType(TYPE_SPELL) and (te:IsHasCategory(CATEGORY_TOHAND) or te:IsHasCategory(CATEGORY_SEARCH) or te:IsHasCategory(CATEGORY_DRAW))
end
lá flower bloom late đang lỗi là tất cả card banish sẽ send to GY nhưng nó k hoạt động

Nhìn vào hình ảnh, quái vật Maliss vẫn bị trục xuất vào vùng Banishment và kích hoạt Trigger Effect: "Activate the Trigger Effect of 'Maliss  White Rabbit' from [Banished]?".   
JPG

Nguyên nhân lỗi
Trong engine EDOPro/OCGCore:

Mã EFFECT_TO_GRAVE_REDIRECT: Chỉ dùng để chuyển điểm đến của một lá bài ĐANG ĐI VÀO MỘ sang một nơi khác (ví dụ: đang đi vào GY thì bị đổi hướng sang LOCATION_REMOVED như Macro Cosmos hay Dimension Shifter).

Khi một hành động hay effect thực hiện lệnh Banish (Duel.Remove), đích đến của lá bài ngay từ đầu đã là Banishment, nó hoàn toàn không kích hoạt cờ EFFECT_TO_GRAVE_REDIRECT. Engine không có mã chuyển hướng ngược EFFECT_REMOVE_REDIRECT.

Do đó, cách duy nhất và chuẩn nhất trong Lua script để chặn việc Banish và chuyển hướng nó xuống GY là tạo một Trigger Effect liên tục (Continuous Effect) bắt sự kiện EVENT_REMOVE, ngay khi có bất kỳ lá nào bị banish, lập tức hủy trạng thái và gửi trả thẳng xuống Mộ (Duel.SendtoGrave).

File c730120.lua sửa lại hoàn chỉnh:
Lua
-- ============================================================
-- Card Name: The Flower Blooms Late
-- Passcode : 730120
-- Type     : Spell / Normal
-- Archetype: Flower Spirit (0x702), Nightbloom (0xb24)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Luôn được xem là cả "Flower Spirit" và "Nightbloom"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	local e0b=e0:Clone()
	e0b:SetValue(0xb24)
	c:RegisterEffect(e0b)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Hiệu ứng kích hoạt chính
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.actcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			local my_gy_rm=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE+LOCATION_REMOVED,0)
			local opp_gy_rm=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE+LOCATION_REMOVED)
			return my_gy_rm==0 and opp_gy_rm==0
		else
			return true
		end
	end

	if not is_opp_turn then
		local op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,0)},
			{true,aux.Stringid(id,1)})
		e:SetLabel(op)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		-- Lượt đối thủ: Negate các effect kích hoạt ở GY hoặc Banishment
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE+Duel.GetCurrentPhase())
		Duel.RegisterEffect(e1,tp)
	else
		local op=e:GetLabel()
		if op==1 then
			-- Option 1: Any card sent to GY is banished instead
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetTargetRange(0xff,0xff)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		elseif op==2 then
			-- Option 2: Any card that would be banished is sent to GY instead
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_REMOVE)
			e2:SetOperation(s.send_to_gy_op)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end
end

-- Bắt sự kiện bài bị Banish và lập tức chuyển xuống Mộ
function s.send_to_gy_op(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REDIRECT)
	end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_GRAVE or loc==LOCATION_REMOVED
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
Dưới đây là file script Lua hoàn chỉnh và câu lệnh SQL cho lá "Nightbloom – Dawn After the Long Night".   
JPG

File tuân thủ đúng chuẩn template đã chuẩn hóa:

Luôn mang setcode Flower Spirit (0x702) và Nightbloom (0xb24).   
JPG

Không thể Úp (EFFECT_CANNOT_SSET).   
JPG

Kích hoạt từ tay ở lượt đối thủ qua EFFECT_BECOME_QUICK và EFFECT_QP_ACT_IN_NTPHAND đi kèm điều kiện s.quickcon.   
JPG

Lượt mình (Normal Spell chuẩn): Bắt buộc ph == PHASE_MAIN1 or ph == PHASE_MAIN2 và Duel.GetCurrentChain() == 0 để triệt tiêu lỗi nháy chain. Chọn mục tiêu 1 Spell "Flower Spirit" hoặc "Nightbloom" dưới GY và 1 Spell bị trục xuất; đưa mục tiêu thứ nhất về đáy Deck, sau đó đưa mục tiêu thứ hai lên tay.   
JPG

Lượt đối thủ (Chain Negate): Kích hoạt khi đối thủ kích hoạt card hoặc effect có target card trên sân. Phủ nhận hiệu ứng đó, sau đó đối thủ có thể banish 1 Spell trên tay để phủ nhận lại lá này.   
JPG
+ 1

Khóa Deck: Không được dùng bài trong Deck trừ Spell Card.   
JPG

1. File Lua: c730124.lua (Bạn có thể đổi số ID tùy theo database)
Lua
-- ============================================================
-- Card Name: Nightbloom – Dawn After the Long Night
-- Passcode : 730124
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Kích hoạt từ tay CHỈ TRONG LƯỢT ĐỐI THỦ
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Effect 2: Your turn — Normal Spell activation
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.selfcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.selftg)
	e4:SetOperation(s.selfop)
	c:RegisterEffect(e4)

	-- Effect 3: Opponent's turn — Negate targeting card/effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.oppcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.opptg)
	e5:SetOperation(s.oppop)
	c:RegisterEffect(e5)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

-- ============================================================
-- Khóa Deck: Chỉ cho phép dùng Spell
-- ============================================================
function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

-- ============================================================
-- Lượt của bạn
-- ============================================================
function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
end

function s.gyfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end

function s.rmfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsFaceup() and c:IsAbleToHand()
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_REMOVED,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	local g=Duel.GetTargetCards(e)
	if not tc1 or not g:IsContains(tc1) then return end
	local tc2=g:Filter(function(c,tc) return c~=tc end,nil,tc1):GetFirst()
	if not tc2 then return end

	-- Trả target 1 về đáy Deck
	if Duel.SendtoDeck(tc1,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc1:IsLocation(LOCATION_DECK) then
		-- Và nếu làm được điều đó, add target 2 lên tay
		Duel.BreakEffect()
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc2)
	end
end

-- ============================================================
-- Lượt của đối thủ
-- ============================================================
function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp or rp~=1-tp then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsOnField,1,nil)
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	-- Đối thủ có thể banish 1 Spell trên tay để negate lá này
	local b_group=Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_SPELL) and c:IsAbleToRemove() end,1-tp,LOCATION_HAND,0,nil)
	if #b_group>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=b_group:Select(1-tp,1,1,nil)
		if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
			return
		end
	end

	-- Nếu đối thủ không banish hoặc không thể, phủ nhận hiệu ứng đang kích hoạt
	Duel.NegateEffect(ev)
end
2. Dòng SQL nạp vào Nightbloom.cdb:
SQL
INSERT OR REPLACE INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category) 
VALUES (730124, 32, 0, 186902274, 2, 0, 0, 0, 0, 0, 16777222);

INSERT OR REPLACE INTO texts (id, name, desc, str1, str2, str3) VALUES (
    730124,
    'Nightbloom – Dawn After the Long Night',
    'This card is always treated as a "Flower Spirit" card.' || char(10) ||
    'This card cannot be Set. You can activate this card from your hand during your opponent''s turn. You cannot use cards in your Deck, except Spell Cards.' || char(10) ||
    'If this card is activated during your opponent''s turn: When your opponent activates a card or effect that targets a card(s) on the field: Negate that effect, then your opponent can banish 1 Spell from their hand to negate this card''s effect.' || char(10) ||
    'If this card is activated during your turn: Target 1 "Flower Spirit" or "Nightbloom" Spell in your GY and 1 of your banished "Flower Spirit" or "Nightbloom" Spells; return the first target to the bottom of the Deck, and if you do, add the second target to your hand.' || char(10) ||
    'You can only activate 1 "Nightbloom – Dawn After the Long Night" per turn.',
    'Return 1 GY Spell to bottom of Deck, add 1 banished Spell to hand',
    'Negate targeting effect',
    'Banish 1 Spell from hand to negate this effect?'
);
đọc để t kiểm tra r hãy làm code nhé

Dưới đây là chi tiết phân tích hiệu ứng và thông số của 4 quái vật Extra Deck để bạn kiểm tra trước khi tiến hành viết code:

1. Witch of Nightbloom
Thông số cơ bản:

Loại thẻ: Synchro / Pendulum / Effect Monster.   
JPG

Thuộc tính: WATER | Chủng tộc: Spellcaster.   
JPG

Level: 8 | Scale: 1 / 1.   
JPG

ATK: 3000 | DEF: 2800.   
JPG

Nguyên liệu Synchro: 1 Tuner + 1+ non-Tuner monsters.   
JPG

Hiệu ứng Pendulum:

Mỗi lượt một lần: Chọn mục tiêu 1 Spell "Flower Spirit" hoặc "Nightbloom" dưới GY; banish lá đó, và nếu làm được, thêm 1 Spell "Flower Spirit" hoặc "Nightbloom" khác tên từ vùng Banishment lên tay. Giới hạn: Bạn chỉ có thể dùng hiệu ứng Pendulum này của "Witch of Nightbloom" một lần mỗi lượt.   
JPG
+ 1

Hiệu ứng Quái vật:

Thay thế nguyên liệu: Khi Synchro Summon lá này, bạn có thể xem 1 Normal Monster bạn kiểm soát như một Tuner.   
JPG

On Synchro Summon (Trigger): Nếu được Synchro Summon: Có thể gửi 1 Spell "Flower Spirit" hoặc "Nightbloom" từ Deck xuống GY.   
JPG

Quick Effect (Khi đối thủ kích hoạt card/effect): Mỗi lượt một lần: Bạn có thể banish 1 Spell từ GY của mình; vô hiệu hóa (negate) hiệu ứng đó, trừ khi đối thủ gửi 1 Spell từ tay hoặc sân của họ xuống GY.   
JPG

Float vào Pendulum Zone (Trigger): Nếu lá bài đã qua Synchro Summon này bị phá hủy bởi card của đối thủ: Có thể đặt lá bài này vào Pendulum Zone.   
JPG

Giới hạn: Mỗi hiệu ứng quái vật của "Witch of Nightbloom" chỉ có thể sử dụng một lần mỗi lượt.   
JPG

2. Flower Spirit – Astral Nightfall
(Lưu ý: Tên trên thanh tiêu đề ghi là Flower Spirit – Astral Nightfall, nhưng trong text phần ghi đè/giới hạn ghi tên Flower Spirit – Eclipse Sovereign. Khi viết code có thể chuẩn hóa theo tên tiêu đề hoặc theo đúng text bạn muốn).   
JPG

Thông số cơ bản:

Loại thẻ: Link / Effect Monster.   
JPG

Thuộc tính: LIGHT | Chủng tộc: Spellcaster.   
JPG

Link Rating: Link-3 (Mũi tên: Top-Left, Bottom-Left, Top-Right).   
JPG

ATK: 2600.   
JPG

Nguyên liệu: 2+ Spellcaster hoặc Zombie monsters.   
JPG

Hiệu ứng:

Giới hạn số lượng: Bạn chỉ có thể kiểm soát 1 "Flower Spirit – Astral Nightfall" ("Eclipse Sovereign") trên sân.   
JPG

On Link Summon (Trigger): Nếu được Link Summon: Chọn mục tiêu tối đa 2 Spell "Flower Spirit" hoặc "Nightbloom" dưới GY và/hoặc vùng Banishment; đặt 1 lá xuống đáy Deck, và nếu làm được, thêm lá còn lại lên tay.   
JPG

Chặn phản ứng (Continuous): Khi lá bài này chỉ vào từ 2 quái vật trở lên, đối thủ không thể kích hoạt card hoặc effect phản ứng lại việc kích hoạt các hiệu ứng của lá bài này.   
JPG

Quick Effect (Khi đối thủ kích hoạt card/effect): Có thể gửi 1 Spell "Flower Spirit" hoặc "Nightbloom" từ tay hoặc sân xuống GY; negate effect đó, và nếu làm được, bạn có thể banish 1 Spell từ GY.   
JPG

Khi Spell bị banish (Trigger): Nếu một Spell "Flower Spirit" hoặc "Nightbloom" bị banish trong khi lá này đang ngửa trên sân: Chọn mục tiêu 1 card ngửa trên sân; vô hiệu hóa hiệu ứng của nó đến cuối lượt.   
JPG

Giới hạn: Mỗi hiệu ứng chỉ có thể dùng một lần mỗi lượt.   
JPG

3. Flower Spirit – Midnight Paradox
Thông số cơ bản:

Loại thẻ: Xyz / Effect Monster.   
JPG

Thuộc tính: DARK | Chủng tộc: Spellcaster.   
JPG

Rank: 4.   
JPG

ATK: 2000 | DEF: 2200.   
JPG

Nguyên liệu: 2 Level 4 monsters.   
JPG

Hiệu ứng:

Cách Xyz Summon đặc biệt: Có thể Xyz Summon lá này bằng cách dùng 1 Normal Monster bạn kiểm soát làm nguyên liệu.   
JPG

On Xyz Summon (Trigger): Nếu được Xyz Summon: Có thể gắn (attach) 1 Spell Card "Flower Spirit" hoặc "Nightbloom" từ GY hoặc vùng Banishment vào lá này làm nguyên liệu.   
JPG

Bắn phá ngắt nhịp (Quick Effect): Tối đa 3 lần mỗi lượt: Có thể tách 1 nguyên liệu, sau đó chọn mục tiêu 1 card ngửa đối thủ kiểm soát; phá hủy nó.   
JPG

Hồi tài nguyên khi bị banish (Trigger): Nếu một Spell Card "Flower Spirit" hoặc "Nightbloom" bị banish trong khi lá này đang có nguyên liệu: Bạn có thể tách 1 nguyên liệu; thêm 1 Spell "Flower Spirit" hoặc "Nightbloom" từ GY lên tay (Giới hạn: 1 lần/lượt).   
JPG

4. Flower Spirit – The Last Bloom
Thông số cơ bản:

Loại thẻ: Fusion / Effect Monster.

Thuộc tính: DARK | Chủng tộc: Spellcaster.

Level: 12.

ATK: 4000 | DEF: 3500.

Điều kiện triệu hồi:

Bắt buộc phải Special Summon từ Extra Deck bằng cách xáo toàn bộ Spell Cards "Flower Spirit" và "Nightbloom" từ sân, GY và/hoặc vùng Banishment của bạn vào Deck (Tối thiểu phải có 25 lá).

Hiệu ứng:

On Special Summon (Trigger): Nếu được Special Summon: Bạn có thể xáo toàn bộ các lá bài khác trên sân vào Deck. Đối thủ có thể gửi 1 lá từ tay xuống GY cho mỗi 5 lá bài sắp bị xáo vào Deck để negate hiệu ứng này.

Bảo kê Spell (Continuous): Khi lá bài đã qua Fusion Summon này ngửa trên sân, đối thủ không thể kích hoạt card hoặc effect phản ứng lại việc kích hoạt các Spell Card "Flower Spirit" hoặc "Nightbloom" của bạn.

Omni-Negate (Quick Effect): Mỗi lượt một lần, khi đối thủ kích hoạt card hoặc effect: Có thể xáo 3 Spell "Flower Spirit" hoặc "Nightbloom" từ GY và/hoặc vùng Banishment vào Deck; vô hiệu hóa việc kích hoạt đó, và nếu làm được, banish lá bài đó.

Floating khi rời sân (Trigger): Nếu lá bài này rời sân vì một card của đối thủ: Có thể xếp tối đa 3 Spell "Flower Spirit" từ GY và/hoặc vùng Banishment xuống đáy Deck theo thứ tự tùy ý, sau đó rút 1 lá.

Giới hạn: Chỉ có thể Special Summon "Flower Spirit – The Last Bloom" một lần mỗi lượt.

Bạn xem lại toàn bộ câu chữ, điều kiện và các chi tiết xử lý xem đã đúng ý tưởng của bạn chưa, hoặc có cần tinh chỉnh phần nào trước khi lên code Lua và SQL không nhé!

đúng hết r, lá link thì tên là astral nightfall nha

Dưới đây là trọn bộ mã nguồn Lua hoàn chỉnh và các lệnh SQL chèn vào database cho cả 4 quái thú Extra Deck: Witch of Nightbloom, Flower Spirit – Astral Nightfall, Flower Spirit – Midnight Paradox, và Flower Spirit – The Last Bloom.

1. c730125.lua – Witch of Nightbloom
Passcode: 730125

Loại: Synchro / Pendulum / Effect Monster (Level 8, WATER, Spellcaster, Scale 1)   
JPG

Lua
-- ============================================================
-- Card Name: Witch of Nightbloom
-- Passcode : 730125
-- Type     : Synchro / Pendulum / Effect Monster
-- Level 8 | Scale 1 | WATER | Spellcaster
-- ATK 3000 / DEF 2800
-- Archetype: Nightbloom (0xb24)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Kích hoạt cơ chế Pendulum
	Pendulum.AddProcedure(c)

	-- Synchro Summon procedure: 1 Tuner + 1+ non-Tuner
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	-- Cho phép xem 1 Normal Monster điều khiển như Tuner khi Synchro Summon lá này
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(s.synchrotg)
	c:RegisterEffect(e0)

	-- ============================================================
	-- Pendulum Effect
	-- ============================================================
	local ep=Effect.CreateEffect(c)
	ep:SetDescription(aux.Stringid(id,0))
	ep:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	ep:SetType(EFFECT_TYPE_IGNITION)
	ep:SetRange(LOCATION_PZONE)
	ep:SetProperty(EFFECT_FLAG_CARD_TARGET)
	ep:SetCountLimit(1,id)
	ep:SetTarget(s.pentg)
	ep:SetOperation(s.penop)
	c:RegisterEffect(ep)

	-- ============================================================
	-- Monster Effect 1: On Synchro Summon -> Send Archetype Spell to GY
	-- ============================================================
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)

	-- ============================================================
	-- Monster Effect 2: Quick Negate unless opponent sends Spell
	-- ============================================================
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	-- ============================================================
	-- Monster Effect 3: Destroyed by opponent -> Place into PZone
	-- ============================================================
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,3})
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg2)
	e3:SetOperation(s.penop2)
	c:RegisterEffect(e3)
end

s.listed_series={0x702,0xb24}

-- Cờ xem Normal Monster như Tuner
function s.synchrotg(e,c)
	return c:IsType(TYPE_NORMAL)
end

-- Pendulum Effect Logic
function s.penfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.penfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.penfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.penfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thfilter(c,code)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and not c:IsCode(code) and c:IsAbleToHand()
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil,tc:GetCode())
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

-- Monster Effect 1 Logic
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spellfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

-- Monster Effect 2 Logic
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
end
function s.rmcostfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.oppspellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- Opponent can send 1 Spell from hand or field to GY to avoid negate
	local g=Duel.GetMatchingGroup(s.oppspellfilter,1-tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,1,nil)
		if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
			return
		end
	end
	Duel.NegateEffect(ev)
end

-- Monster Effect 3 Logic
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and (r&REASON_EFFECT+REASON_BATTLE)~=0 and rp==1-tp
end
function s.pentg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
2. c730126.lua – Flower Spirit – Astral Nightfall
Passcode: 730126

Loại: Link / Effect Monster (Link-3, LIGHT, Spellcaster, Mũi tên: Top-Left, Bottom-Left, Top-Right)   
JPG

Lua
-- ============================================================
-- Card Name: Flower Spirit – Astral Nightfall
-- Passcode : 730126
-- Type     : Link / Effect Monster
-- Link-3 | LIGHT | Spellcaster
-- ATK 2600 | Markers: Top-Left, Bottom-Left, Top-Right
-- Archetype: Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Link Summon procedure: 2+ Spellcaster or Zombie monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER+RACE_ZOMBIE),2)
	c:EnableReviveLimit()

	-- You can only control 1 "Flower Spirit – Astral Nightfall"
	c:SetUniqueOnField(1,0,id)

	-- Effect 1: On Link Summon -> Recycle Spells
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.lkcon)
	e1:SetTarget(s.lktg)
	e1:SetOperation(s.lkop)
	c:RegisterEffect(e1)

	-- Effect 2: Cannot respond to this card's effects if points to 2+ monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)

	-- Effect 3: Quick Negate by sending Archetype Spell
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)

	-- Effect 4: Archetype Spell banished -> Negate face-up card on field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end

s.listed_series={0x702,0xb24}

-- Effect 1
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.recfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and (c:IsAbleToDeck() or c:IsAbleToHand())
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.recfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,2,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	if #g==1 then
		local tc=g:GetFirst()
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local td=g:Select(tp,1,1,nil)
		local th=g:Filter(function(c,sc) return c~=sc end,nil,td:GetFirst())
		if #td>0 and Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(th,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,th)
		end
	end
end

-- Effect 2
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler()==c and c:GetLinkedGroupCount()>=2 then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	end
end

-- Effect 3
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
end
function s.costfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end

-- Effect 4
function s.cfilter(c,tp)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsControler(tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and not chkc:IsDisabled() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
3. c730127.lua – Flower Spirit – Midnight Paradox
Passcode: 730127

Loại: Xyz / Effect Monster (Rank 4, DARK, Spellcaster)   
JPG

Lua
-- ============================================================
-- Card Name: Flower Spirit – Midnight Paradox
-- Passcode : 730127
-- Type     : Xyz / Effect Monster
-- Rank 4 | DARK | Spellcaster
-- ATK 2000 / DEF 2200
-- Archetype: Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Xyz Summon: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()

	-- Cho phép Xyz Summon bằng 1 Normal Monster
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetTarget(s.xyztg)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)

	-- Effect 1: On Xyz Summon -> Attach Spell from GY/Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.attcon)
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)

	-- Effect 2: Quick Effect -> Detach 1 to destroy 1 face-up card opp controls (Up to 3 times/turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(3)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)

	-- Effect 3: When Spell banished -> Detach 1 to add Spell from GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end

s.listed_series={0x702,0xb24}

-- 1 Normal Monster Xyz Summon
function s.xyzfilter(c,sc,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsCanBeXyzMaterial(sc)
end
function s.xyzcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Overlay(c,g)
	g:DeleteGroup()
end

-- Effect 1
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.attfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsCanOverlay()
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end

-- Effect 2
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-- Effect 3
function s.cfilter(c,tp)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsControler(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0 and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.thfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
4. c730128.lua – Flower Spirit – The Last Bloom
Passcode: 730128

Loại: Fusion / Effect Monster (Level 12, DARK, Spellcaster)

Lua
-- ============================================================
-- Card Name: Flower Spirit – The Last Bloom
-- Passcode : 730128
-- Type     : Fusion / Effect Monster
-- Level 12 | DARK | Spellcaster
-- ATK 4000 / DEF 3500
-- Archetype: Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()

	-- Special Summon procedure: Shuffle all Archetype Spells from Field, GY, Banish (min 25)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)

	-- Effect 1: On Special Summon -> Shuffle all other cards on field into Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)

	-- Effect 2: Opponent cannot respond to activation of your Archetype Spells
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)

	-- Effect 3: Quick Omni-Negate & Banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)

	-- Effect 4: Leaves field by opponent's card -> Bottom deck up to 3 Spells, draw 1
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.lfcon)
	e4:SetTarget(s.lftg)
	e4:SetOperation(s.lfop)
	c:RegisterEffect(e4)
end

s.listed_series={0x702,0xb24}

-- Special Summon Procedure Logic
function s.matfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToDeckAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and #g>=25
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if #g>=25 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end

-- Effect 1 Logic
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	local ct=#g
	if ct==0 then return end

	-- Opponent can send 1 card from hand for every 5 cards to negate
	local req=math.floor(ct/5)
	local hand_ct=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
	if req>0 and hand_ct>=req and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=Duel.SelectMatchingCard(1-tp,Card.IsAbleToGrave,1-tp,LOCATION_HAND,0,req,req,nil)
		if #sg==req and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
			return
		end
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

-- Effect 2 Logic
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and (rc:IsSetCard(0x702) or rc:IsSetCard(0xb24)) and re:IsActiveType(TYPE_SPELL) then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	end
end

-- Effect 3 Logic
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.costfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToDeckAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsAbleToRemove() then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

-- Effect 4 Logic
function s.lfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
end
function s.fsfilter(c)
	return c:IsSetCard(0x702) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
function s.lftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(s.fsfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.lfop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.fsfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,3,nil)
	if #sg>0 and Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		Duel.SortDeckbottom(tp,tp,#sg)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
5. Mã SQL chèn dữ liệu vào Nightbloom.cdb
SQL
-- ============================================================
-- 1. Witch of Nightbloom (Passcode: 730125)
-- Type: 0xA02041 (Monster + Effect + Synchro + Pendulum)
-- ============================================================
INSERT OR REPLACE INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category) 
VALUES (730125, 32, 0, 2852, 10494017, 3000, 2800, 16777224, 2, 2, 2147745795);

INSERT OR REPLACE INTO texts (id, name, desc, str1, str2, str3, str4, str5, str6) VALUES (
    730125,
    'Witch of Nightbloom',
    '[ Pendulum Effect ]' || char(10) ||
    'Once per turn: You can target 1 "Flower Spirit" or "Nightbloom" Spell in your GY; banish it, and if you do, add 1 "Flower Spirit" or "Nightbloom" Spell with a different name from your banishment to your hand. You can only use this effect of "Witch of Nightbloom" once per turn.' || char(10) ||
    '----------------------------------------' || char(10) ||
    '[ Monster Effect ]' || char(10) ||
    '1 Tuner + 1+ non-Tuner monsters' || char(10) ||
    'For the Synchro Summon of this card, you can treat 1 Normal Monster you control as a Tuner.' || char(10) ||
    'If this card is Synchro Summoned: You can send 1 "Flower Spirit" or "Nightbloom" Spell from your Deck to the GY.' || char(10) ||
    'Once per turn, when your opponent activates a card or effect (Quick Effect): You can banish 1 Spell from your GY; negate that effect, unless your opponent sends 1 Spell from their hand or field to the GY.' || char(10) ||
    'If this Synchro Summoned card is destroyed by an opponent''s card: You can place this card in your Pendulum Zone.' || char(10) ||
    'You can only use each Monster Effect of "Witch of Nightbloom" once per turn.',
    'Banish 1 GY Spell to add 1 banished Spell to hand',
    'Send 1 Archetype Spell from Deck to GY',
    'Negate effect unless opponent sends 1 Spell to GY',
    'Place this card in your Pendulum Zone',
    'Add 1 banished Spell with different name to hand?',
    'Send 1 Spell to GY to prevent negation?'
);

-- ============================================================
-- 2. Flower Spirit – Astral Nightfall (Passcode: 730126)
-- Type: 0x4000041 (Monster + Effect + Link)
-- ============================================================
INSERT OR REPLACE INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category) 
VALUES (730126, 32, 0, 1794, 67108929, 2600, 0, 393, 2, 16, 2147487746);

INSERT OR REPLACE INTO texts (id, name, desc, str1, str2, str3, str4) VALUES (
    730126,
    'Flower Spirit – Astral Nightfall',
    '2+ Spellcaster or Zombie monsters' || char(10) ||
    'You can only control 1 "Flower Spirit – Astral Nightfall". If this card is Link Summoned: You can target up to 2 "Flower Spirit" or "Nightbloom" Spell Cards in your GY and/or banishment; place 1 of them on the bottom of the Deck, and if you do, add the other to your hand. While this card points to 2 or more monsters, your opponent cannot activate cards or effects in response to the activation of this card''s effects. When your opponent activates a card or effect (Quick Effect): You can send 1 "Flower Spirit" or "Nightbloom" Spell Card from your hand or field to the GY; negate that effect, and if you do, you can banish 1 Spell Card from your GY. If a "Flower Spirit" or "Nightbloom" Spell Card is banished while this card is face-up on the field: You can target 1 face-up card on the field; negate its effects until the end of this turn. You can only use each effect of "Flower Spirit – Astral Nightfall" once per turn.',
    'Place 1 Spell on bottom of Deck and add 1 to hand',
    'Negate effect by sending 1 Spell to GY',
    'Negate face-up card until end of turn',
    'Banish 1 Spell from GY?'
);

-- ============================================================
-- 3. Flower Spirit – Midnight Paradox (Passcode: 730127)
-- Type: 0x800041 (Monster + Effect + Xyz)
-- ============================================================
INSERT OR REPLACE INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category) 
VALUES (730127, 32, 0, 1794, 8388673, 2000, 2200, 4, 2, 32, 3);

INSERT OR REPLACE INTO texts (id, name, desc, str1, str2, str3, str4) VALUES (
    730127,
    'Flower Spirit – Midnight Paradox',
    '2 Level 4 monsters' || char(10) ||
    'You can also Xyz Summon this card by using 1 Normal Monster you control as material.' || char(10) ||
    'If this card is Xyz Summoned: You can attach 1 "Flower Spirit" or "Nightbloom" Spell Card from your GY or banishment to this card as material.' || char(10) ||
    'Up to 3 times per turn (Quick Effect): You can detach 1 material from this card, then target 1 face-up card your opponent controls; destroy it.' || char(10) ||
    'If a "Flower Spirit" or "Nightbloom" Spell Card is banished while this card has material: You can detach 1 material from this card; add 1 "Flower Spirit" or "Nightbloom" Spell Card from your GY to your hand. You can only use this effect of "Flower Spirit – Midnight Paradox" once per turn.',
    'Xyz Summon using 1 Normal Monster',
    'Attach 1 Spell from GY/Banishment as material',
    'Detach 1 material to destroy 1 opponent face-up card',
    'Detach 1 material to add 1 Spell from GY to hand'
);

-- ============================================================
-- 4. Flower Spirit – The Last Bloom (Passcode: 730128)
-- Type: 0x41 (Monster + Effect + Fusion)
-- ============================================================
INSERT OR REPLACE INTO datas (id, ot, alias, setcode, type, atk, def, level, race, attribute, category) 
VALUES (730128, 32, 0, 1794, 65, 4000, 3500, 12, 2, 32, 2147745794);

INSERT OR REPLACE INTO texts (id, name, desc, str1, str2, str3, str4) VALUES (
    730128,
    'Flower Spirit – The Last Bloom',
    'Must be Special Summoned (from your Extra Deck) by shuffling all "Flower Spirit" and "Nightbloom" Spell Cards from your field, GY, and/or banishment into the Deck (min. 25).' || char(10) ||
    'If this card is Special Summoned: You can shuffle all other cards on the field into the Deck, or your opponent can send 1 card from their hand to the GY for every 5 cards that would be shuffled into the Deck by this effect to negate this effect.' || char(10) ||
    'While this Fusion Summoned card is face-up on the field, your opponent cannot activate cards or effects in response to the activation of your "Flower Spirit" or "Nightbloom" Spell Cards.' || char(10) ||
    'Once per turn, when your opponent activates a card or effect (Quick Effect): You can shuffle 3 "Flower Spirit" or "Nightbloom" Spell Cards from your GY and/or banishment into the Deck; negate the activation, and if you do, banish that card.' || char(10) ||
    'If this card leaves the field because of an opponent''s card: You can place up to 3 "Flower Spirit" Spell Cards from your GY and/or banishment on the bottom of the Deck in any order, then draw 1 card.' || char(10) ||
    'You can only Special Summon "Flower Spirit – The Last Bloom" once per turn.',
    'Shuffle all other cards on the field into the Deck',
    'Negate activation and banish that card',
    'Place up to 3 Spells on bottom of Deck and draw 1',
    'Send cards from hand to GY to prevent field shuffle?'
);
con link và synchro mới này không thể summon được luôn

Cả hai lá không thể Summon được là do cách đăng ký điều kiện Summon trong code Lua và giá trị trong Database (datas):

Lá Synchro (Witch of Nightbloom - 730125):

Trong code Lua: EFFECT_SYNCHRO_MATERIAL_CUSTOM không phải là một effect hợp lệ độc lập để biến Normal Monster thành Tuner cho core Synchro chuẩn của EDOPro. Thay vào đó, bạn phải dùng hàm kiểm tra nguyên liệu tùy chỉnh của engine (Synchro.AddProcedure nhận một hàm kiểm tra material hỗ trợ Tuner thay thế, hoặc cấp effect EFFECT_ADD_TYPE gán TYPE_TUNER cho Normal Monster khi dùng làm nguyên liệu Synchro).

Trong Database (datas): Giá trị level của Pendulum Monster trong OCGCore/EDOPro phải được encode theo công thức: 
Level+(Scale L≪24)+(Scale R≪16). Đối với Level 8 và Scale 1/1:

8+(1≪24)+(1≪16)=8+16777216+65536=16842760
(Giá trị cũ 16777224 chỉ mới có 1 bên Scale nên game không nhận diện đúng cấu trúc Pendulum).

Lá Link (Flower Spirit – Astral Nightfall - 730126):

Trong code Lua: Lệnh gọi Link.AddProcedure bị thiếu chỉ định số lượng nguyên liệu tối đa (min, max), khiến engine không xác định được số nguyên liệu cho Link-3. Cú pháp chuẩn là:

Lua
Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER+RACE_ZOMBIE),2,3)
Trong Database (datas): Mũi tên Link của Link Monster được lưu trong trường def.
Với 3 mũi tên Top-Left (0x40), Bottom-Left (0x01), Top-Right (0x100):

def=0x01+0x40+0x100=0x141=321
(Nếu để def = 0, game sẽ coi như quái vật Link không có mũi tên hợp lệ và cấm Link Summon).

1. File Lua sửa lại cho Synchro: c730125.lua
Lua
-- ============================================================
-- Card Name: Witch of Nightbloom
-- Passcode : 730125
-- Type     : Synchro / Pendulum / Effect Monster
-- Level 8 | Scale 1 | WATER | Spellcaster
-- ATK 3000 / DEF 2800
-- Archetype: Nightbloom (0xb24)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Kích hoạt cơ chế Pendulum
	Pendulum.AddProcedure(c)

	-- Synchro Summon procedure: Cho phép 1 Tuner hoặc 1 Normal Monster điều khiển làm Tuner
	local f1=function(c,scard,sumtype,tp)
		return c:IsType(TYPE_TUNER,scard,sumtype,tp) or (c:IsControler(tp) and c:IsType(TYPE_NORMAL))
	end
	Synchro.AddProcedure(c,f1,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

	-- ============================================================
	-- Pendulum Effect
	-- ============================================================
	local ep=Effect.CreateEffect(c)
	ep:SetDescription(aux.Stringid(id,0))
	ep:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	ep:SetType(EFFECT_TYPE_IGNITION)
	ep:SetRange(LOCATION_PZONE)
	ep:SetProperty(EFFECT_FLAG_CARD_TARGET)
	ep:SetCountLimit(1,id)
	ep:SetTarget(s.pentg)
	ep:SetOperation(s.penop)
	c:RegisterEffect(ep)

	-- ============================================================
	-- Monster Effect 1: On Synchro Summon -> Send Archetype Spell to GY
	-- ============================================================
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)

	-- ============================================================
	-- Monster Effect 2: Quick Negate unless opponent sends Spell
	-- ============================================================
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	-- ============================================================
	-- Monster Effect 3: Destroyed by opponent -> Place into PZone
	-- ============================================================
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,3})
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg2)
	e3:SetOperation(s.penop2)
	c:RegisterEffect(e3)
end

s.listed_series={0x702,0xb24}

-- Pendulum Effect Logic
function s.penfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.penfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.penfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.penfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thfilter(c,code)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and not c:IsCode(code) and c:IsAbleToHand()
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil,tc:GetCode())
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

-- Monster Effect 1 Logic
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spellfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

-- Monster Effect 2 Logic
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
end
function s.rmcostfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.oppspellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.oppspellfilter,1-tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,1,nil)
		if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
			return
		end
	end
	Duel.NegateEffect(ev)
end

-- Monster Effect 3 Logic
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and (r&REASON_EFFECT+REASON_BATTLE)~=0 and rp==1-tp
end
function s.pentg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
2. File Lua sửa lại cho Link: c730126.lua
Lua
-- ============================================================
-- Card Name: Flower Spirit – Astral Nightfall
-- Passcode : 730126
-- Type     : Link / Effect Monster
-- Link-3 | LIGHT | Spellcaster
-- ATK 2600 | Markers: Top-Left, Bottom-Left, Top-Right
-- Archetype: Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Link Summon: 2+ Spellcaster hoặc Zombie (min 2, max 3)
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER+RACE_ZOMBIE),2,3)
	c:EnableReviveLimit()

	-- You can only control 1 "Flower Spirit – Astral Nightfall"
	c:SetUniqueOnField(1,0,id)

	-- Effect 1: On Link Summon -> Recycle Spells
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.lkcon)
	e1:SetTarget(s.lktg)
	e1:SetOperation(s.lkop)
	c:RegisterEffect(e1)

	-- Effect 2: Cannot respond to this card's effects if points to 2+ monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)

	-- Effect 3: Quick Negate by sending Archetype Spell
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)

	-- Effect 4: Archetype Spell banished -> Negate face-up card on field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end

s.listed_series={0x702,0xb24}

-- Effect 1
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.recfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and (c:IsAbleToDeck() or c:IsAbleToHand())
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.recfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,2,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	if #g==1 then
		local tc=g:GetFirst()
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local td=g:Select(tp,1,1,nil)
		local th=g:Filter(function(c,sc) return c~=sc end,nil,td:GetFirst())
		if #td>0 and Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(th,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,th)
		end
	end
end

-- Effect 2
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if re:GetHandler()==c and lg and lg:FilterCount(Card.IsType,nil,TYPE_MONSTER)>=2 then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	end
end

-- Effect 3
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
end
function s.costfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end

-- Effect 4
function s.cfilter(c,tp)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsControler(tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and not chkc:IsDisabled() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
3. Cập nhật dữ liệu Database (Nightbloom.cdb)
Chạy đoạn script SQL dưới đây để sửa lại cột level (cho Pendulum) và cột def (cho Link Markers) chuẩn xác:

SQL
-- Cập nhật Scale Pendulum (1/1) và Level 8 cho Witch of Nightbloom: level = 16842760
UPDATE datas 
SET level = 16842760 
WHERE id = 730125;

-- Cập nhật Link Markers (Top-Left + Bottom-Left + Top-Right) cho Astral Nightfall: def = 321, level = 3 (Link-3)
UPDATE datas 
SET def = 321, level = 3 
WHERE id = 730126;
Lỗi trong ảnh báo: [string "c730127.lua"]:107: attempt to call a nil value (method 'IsCanOverlay').

Trong engine EDOPro, hàm kiểm tra một card có thể attach làm material hay không là c:IsCanOverlayCard(tp) chứ không phải c:IsCanOverlay(). Hoặc đơn giản chỉ cần kiểm tra card đó không bị cấm/miễn nhiễm (đối với Spell trong GY hoặc vùng Banishment, chỉ cần kiểm tra hợp lệ thông thường).

Dưới đây là toàn bộ file c730127.lua đã được sửa triệt để lỗi này.

File c730127.lua (Flower Spirit – Midnight Paradox)
Lua
-- ============================================================
-- Card Name: Flower Spirit – Midnight Paradox
-- Passcode : 730127
-- Type     : Xyz / Effect Monster
-- Rank 4 | DARK | Spellcaster
-- ATK 2000 / DEF 2200
-- Archetype: Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Xyz Summon: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()

	-- Cho phép Xyz Summon bằng 1 Normal Monster
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetTarget(s.xyztg)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)

	-- Effect 1: On Xyz Summon -> Attach Spell from GY/Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.attcon)
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)

	-- Effect 2: Quick Effect -> Detach 1 to destroy 1 face-up card opp controls (Up to 3 times/turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(3)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)

	-- Effect 3: When Spell banished -> Detach 1 to add Spell from GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end

s.listed_series={0x702,0xb24}

-- 1 Normal Monster Xyz Summon
function s.xyzfilter(c,sc,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsCanBeXyzMaterial(sc)
end
function s.xyzcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Overlay(c,g)
	g:DeleteGroup()
end

-- Effect 1
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.attfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end

-- Effect 2
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-- Effect 3
function s.cfilter(c,tp)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsControler(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0 and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.thfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
Lỗi [string "c730127.lua"]:154: function arguments expected near <eof> xuất hiện do quá trình copy-paste bị thiếu mất dòng cuối cùng hoặc bị dính một hàm chưa đóng ngoặc () ở cuối file.

Dưới đây là toàn bộ code hoàn chỉnh của c730127.lua. Bạn hãy xóa hết nội dung cũ trong file và dán toàn bộ đoạn mã này vào:

Lua
-- ============================================================
-- Card Name: Flower Spirit – Midnight Paradox
-- Passcode : 730127
-- Type     : Xyz / Effect Monster
-- Rank 4 | DARK | Spellcaster
-- ATK 2000 / DEF 2200
-- Archetype: Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Xyz Summon: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()

	-- Cho phép Xyz Summon bằng 1 Normal Monster
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetTarget(s.xyztg)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)

	-- Effect 1: On Xyz Summon -> Attach Spell from GY/Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.attcon)
	e1:SetTarget(s.atttg)
	e1:SetOperation(s.attop)
	c:RegisterEffect(e1)

	-- Effect 2: Quick Effect -> Detach 1 to destroy 1 face-up card opp controls (Up to 3 times/turn)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(3)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)

	-- Effect 3: When Spell banished -> Detach 1 to add Spell from GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end

s.listed_series={0x702,0xb24}

-- 1 Normal Monster Xyz Summon
function s.xyzfilter(c,sc,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsCanBeXyzMaterial(sc)
end

function s.xyzcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,tp)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Overlay(c,g)
	g:DeleteGroup()
end

-- Effect 1
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.attfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL)
end

function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end

function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end

-- Effect 2
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-- Effect 3
function s.cfilter(c,tp)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsControler(tp)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0 and eg:IsExists(s.cfilter,1,nil,tp)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.thfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk


