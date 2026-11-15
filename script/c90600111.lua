-- Sky Striker Ace - Sangenpai
-- ID: 90600111
local s,id=GetID()
local SET_SKY_STRIKER = 0x115
local SET_SANGEN     = 0x14e

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

	-- Luôn luôn được tính là loài Dragon (Dragon-Type)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE+LOCATION_EXTRA)
	e0:SetCode(EFFECT_ADD_RACE)
	e0:SetValue(RACE_DRAGON)
	c:RegisterEffect(e0)

	-- Cho phép dùng 1 "Sky Striker" Link Monster bạn điều khiển làm Tuner cấp 4 khi Synchro Summon
	local e0_sub=Effect.CreateEffect(c)
	e0_sub:SetType(EFFECT_TYPE_SINGLE)
	e0_sub:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0_sub:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e0_sub:SetValue(s.synval)
	c:RegisterEffect(e0_sub)

	-- Triệu hồi đặc biệt từ Extra Deck bằng cách banish 3 Spell trong GY (bao gồm 1 Quick-Play Spell) (1 lần mỗi ván đấu)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Nếu được Special Summon: Lấy 1 Spell/Trap "Sky Striker" hoặc "Sangen" từ Deck/GY lên tay, rồi có thể đổi cấp thành 4 hoặc 7
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(e2_target)
	e2:SetOperation(e2_operation)
	c:RegisterEffect(e2)

	-- Quick Effect: Thực hiện Synchro Summon ngay lập tức sau khi hiệu ứng này giải quyết xong
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.synsync_tg)
	e3:SetOperation(s.synsync_op)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SKY_STRIKER,SET_SANGEN}

--------------------------------------------------------------------------------
-- TÙY CHỈNH NGUYÊN LIỆU SYNCHRO (DÙNG 1 LINK "Sky Striker" LÀM TUNER CẤP 4)
--------------------------------------------------------------------------------
function s.synval(e,c,mg)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsType(TYPE_LINK) and c:IsFaceup()
end

--------------------------------------------------------------------------------
-- TRIỆU HỒI ĐẶC BIỆT TỪ EXTRA DECK (BANISH 3 SPELL, CÓ 1 QUICK-PLAY)
--------------------------------------------------------------------------------
function s.costfilter(c)
	return c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.qpfilter(c)
	return c:IsSpell(TYPE_QUICKPLAY) and c:IsAbleToRemoveAsCost()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GY,0,nil)
	if chk==0 then 
		return g:IsExists(s.qpfilter,1,nil) and #g>=3 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=g:FilterSelect(tp,s.qpfilter,1,1,nil)
	g:Sub(g1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=g:Select(tp,2,2,nil)
	g1:Merge(g2)
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG KHI ĐƯỢC SPECIAL SUMMON (SEARCH S/T VÀ ĐỔI LEVEL 4 HOẶC 7)
--------------------------------------------------------------------------------
function s.thfilter(c)
	return (c:IsSetCard(SET_SKY_STRIKER) or c:IsSetCard(SET_SANGEN)) and c:IsSpellTrap() and c:IsAbleToHand()
end

function e2_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function e2_operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4),aux.Stringid(id,5))
			if op~=2 then
				local lv=op==0 and 4 or 7
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e1)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- QUICK EFFECT: SYNCHRO SUMMON NGAY LẬP TỨC
--------------------------------------------------------------------------------
function s.synsync_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.synsync_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(tp) and c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SynchroSummon(tp,sg:GetFirst(),c)
		end
	end
end