-- Gensokyo Scarlet - Vampire's Illusion
-- ID: 777700020
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c
local CARD_FLANDRE_FUSION  = 777700016 -- Gensokyo Scarlet - Flandre the Destruction

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}
s.listed_names={CARD_FLANDRE_FUSION}

function s.initial_effect(c)
	-- Hiệu ứng 1: Khi đối thủ target bài bạn điều khiển -> Lộ 1 Spell & 1 Monster "Gensokyo Scarlet" từ Deck, đối thủ chọn ngẫu nhiên 1 lá
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Trong Main Phase dưới Mộ): Trục xuất lá này & trả 1 Fusion Monster bạn điều khiển về Extra Deck
	-- -> Triệu hồi Đặc biệt 1 quái thú có tên từng làm nguyên liệu Dung hợp của quái đó từ Deck/Mộ/Trục xuất và hồi LP bằng ATK quái đã trả
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.gycost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC PHẢN HỒI KHI BỊ TARGET & LỘ 2 LÁ CHO ĐỐI THỦ CHỌN NGẪU NHIÊN
--------------------------------------------------------------------------------
function s.tgcheck(c,tp)
	return c:IsControler(tp) and c:IsOnField()
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tgcheck,1,nil,tp)
end

function s.spfilter_deck(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.setfilter_deck(c,ft_szone)
	return c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsType(TYPE_SPELL)
		and (c:IsType(TYPE_FIELD) or ft_szone>0) and c:IsSSetable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft_szone=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft_szone=ft_szone-1 end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.setfilter_deck,tp,LOCATION_DECK,0,1,nil,ft_szone)
			and Duel.IsExistingMatchingCard(s.spfilter_deck,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(s.tgcheck,nil,tp)
	Duel.SetTargetCard(tg)
	local mg=tg:Filter(Card.IsType,nil,TYPE_MONSTER)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,mg,#mg,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- Nếu điều khiển Flandre Fusion, đối thủ không thể kích hoạt hiệu ứng quái thú để phản hồi
	if e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_FLANDRE_FUSION),tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(s.chainlm)
	end
end

function s.chainlm(e,rp,tp)
	return tp==rp or not e:IsActiveType(TYPE_MONSTER)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft_szone=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter_deck,tp,LOCATION_DECK,0,1,nil,ft_szone)
		and Duel.IsExistingMatchingCard(s.spfilter_deck,tp,LOCATION_DECK,0,1,nil,e,tp)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.SelectMatchingCard(tp,s.setfilter_deck,tp,LOCATION_DECK,0,1,1,nil,ft_szone)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g2=Duel.SelectMatchingCard(tp,s.spfilter_deck,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	g1:Merge(g2)
	Duel.ConfirmCards(1-tp,g1)
	local tc=g1:RandomSelect(1-tp,1):GetFirst()
	if not tc then return end
	if tc:IsType(TYPE_SPELL) then
		if Duel.SSet(tp,tc)>0 and tc:IsType(TYPE_QUICKPLAY) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		Duel.ShuffleDeck(tp)
	elseif tc:IsType(TYPE_MONSTER) then
		local tg=Duel.GetTargetCards(e):Filter(Card.IsType,nil,TYPE_MONSTER)
		if #tg>0 then
			Duel.Destroy(tg,REASON_EFFECT)
		end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.ShuffleDeck(tp)
		end
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRẢ FUSION VỀ EXTRA DECK -> GỌI LẠI NGUYÊN LIỆU & HỒI LP BẰNG ATK
--------------------------------------------------------------------------------
function s.matspfilter(c,e,tp,codes)
	return c:IsType(TYPE_MONSTER) and c:IsCode(table.unpack(codes))
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.fusretfilter(c,e,tp)
	if not (c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsAbleToExtraAsCost()) then return false end
	if Duel.GetMZoneCount(tp,c)<=0 then return false end
	local mg=c:GetMaterial()
	if not mg or #mg==0 then return false end
	local codes={}
	for mc in aux.Next(mg) do
		table.insert(codes,mc:GetCode())
	end
	return Duel.IsExistingMatchingCard(s.matspfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,codes)
end

function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.fusretfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local fc=Duel.SelectMatchingCard(tp,s.fusretfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	local codes={}
	for mc in aux.Next(fc:GetMaterial()) do
		table.insert(codes,mc:GetCode())
	end
	local atk=fc:GetAttack()
	e:SetLabelObject({codes=codes,atk=atk})
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.SendtoDeck(fc,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local data=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
	if data and data.atk>0 then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,data.atk)
	end
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local data=e:GetLabelObject()
	if not data or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.matspfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,data.codes)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and data.atk>0 then
		Duel.Recover(tp,data.atk,REASON_EFFECT)
	end
end