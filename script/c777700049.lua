-- Gensokyo Eientei - Paramesia
-- ID: 777700049
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}

function s.initial_effect(c)
	-- Hiệu ứng 1: Hiến tế 1 Link Monster bạn điều khiển -> Triệu hồi Đặc biệt các quái non-Link "Gensokyo Eientei" từ Mộ
	-- (tối đa bằng Link Rating của quái đã Hiến tế, vô hiệu hóa hiệu ứng);
	-- Nếu đã Hiến tế Link Monster "Gensokyo Eientei", có thể thay thế bằng việc Triệu hồi Đặc biệt 1 Link Monster từ Extra Deck
	-- có Link Rating thấp hơn (vô hiệu hóa hiệu ứng đến hết lượt)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--------------------------------------------------------------------------------
-- BỘ LỌC KIỂM TRA QUÁI TRIỆU HỒI TỪ MỘ & TỪ EXTRA DECK
--------------------------------------------------------------------------------
function s.gyfilter(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_LINK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.exfilter(c,e,tp,lk,mc)
	return c:IsType(TYPE_LINK) and c:GetLink()<lk
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cfilter(c,e,tp)
	if not c:IsType(TYPE_LINK) then return false end
	local lk=c:GetLink()
	if lk<=0 then return false end
	-- Kiểm tra nhánh 1: Triệu hồi từ Mộ sau khi Hiến tế c
	local can_gy=Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- Kiểm tra nhánh 2: Triệu hồi từ Extra Deck nếu c thuộc "Gensokyo Eientei"
	local can_ex=c:IsSetCard(SET_GENSOKYO_EIENTEI)
		and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lk,c)
	return can_gy or can_ex
end

--------------------------------------------------------------------------------
-- 1. LOGIC COST HIẾN TẾ 1 LINK MONSTER & LƯU THÔNG TIN LINK RATING / ARCHETYPE
--------------------------------------------------------------------------------
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,e,tp) end
	local tc=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,e,tp):GetFirst()
	local lk=tc:GetLink()
	local is_ee=tc:IsSetCard(SET_GENSOKYO_EIENTEI) and 1 or 0
	e:SetLabel((lk<<1)|is_ee)
	Duel.Release(tc,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lbl=e:GetLabel()
	local is_ee=(lbl&1)==1
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	if is_ee then
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lbl=e:GetLabel()
	local lk=lbl>>1
	local is_ee=(lbl&1)==1

	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g_gy=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	local can_gy=(ft>0 and #g_gy>0)

	local g_ex=Group.CreateGroup()
	if is_ee then
		g_ex=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_EXTRA,0,nil,e,tp,lk,nil)
	end
	local can_ex=(is_ee and #g_ex>0)

	if not can_gy and not can_ex then return end

	local op=0
	if can_gy and can_ex then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif can_ex then
		op=1
	end

	if op==0 then
		-- Nhánh 1: Triệu hồi Đặc biệt các quái non-Link "Gensokyo Eientei" từ Mộ (tối đa bằng lk, vô hiệu hóa hiệu ứng)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=math.min(ft,1) end
		local maxc=math.min(lk,ft)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g_gy:Select(tp,1,maxc,nil)
		if #sg>0 then
			for tc in aux.Next(sg) do
				if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetValue(RESET_TURN_SET)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e2)
				end
			end
			Duel.SpecialSummonComplete()
		end
	else
		-- Nhánh 2: Triệu hồi Đặc biệt 1 Link Monster có Link Rating thấp hơn từ Extra Deck (vô hiệu hóa hiệu ứng đến hết lượt)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g_ex:Select(tp,1,1,nil):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
end
