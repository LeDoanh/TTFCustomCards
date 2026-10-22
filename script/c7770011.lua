-- c7770011: Purrfect Coven – The Grand Mystery
local s,id=GetID()
local SET_PURRFECT=0x777

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 1. Thủ tục gọi Xyz chuẩn: 3 quái Spellcaster Level 2
	-- VÀ Thủ tục Alternative Xyz Summon: Chồng lên đúng 1 quái Xyz "Purrfect" (max_mat = 1)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),2,3,s.ovfilter,aux.Stringid(id,0),1,s.ovop)

	-- 2. Kháng toàn bộ hiệu ứng cấp bởi nguyên liệu đính kèm
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.matimmval)
	c:RegisterEffect(e1)

	-- 3. Cấm làm nguyên liệu cho Fusion, Synchro, Xyz, Link
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e5)

	-- 4. Quick Effect: Tháo 1 nguyên liệu từ 1 quái Purrfect Xyz trên sân
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetTarget(s.dettg)
	e6:SetOperation(s.detop)
	c:RegisterEffect(e6)

	-- 5. Trigger: Đẩy 1 lá ngửa của đối phương về đáy Deck khi có quái đổi sân hoặc nguyên liệu bị tháo
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e7:SetCode(EVENT_CONTROL_CHANGED)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,id+100)
	e7:SetCondition(s.tdcon1)
	e7:SetTarget(s.tdtg)
	e7:SetOperation(s.tdop)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_DETACH_MATERIAL)
	e8:SetCondition(s.tdcon2)
	c:RegisterEffect(e8)
end
s.listed_series={SET_PURRFECT}

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(SET_PURRFECT) and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and not c:IsCode(id)
end

function s.ovop(e,tp,chk,mc)
	local mg=mc:GetOverlayGroup()
	if #mg~=0 then
		Duel.Overlay(e:GetHandler(),mg)
	end
end

function s.matimmval(e,te)
	return te:IsHasType(EFFECT_TYPE_XMATERIAL)
end

function s.detfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_PURRFECT) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.dettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.detfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.detfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.detfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.detop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and tc:GetOverlayCount()>0 then
		local og=tc:GetOverlayGroup()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
		local mg=og:Select(tp,1,1,nil)
		if #mg>0 then
			local opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
			if opt==0 and c:IsRelateToEffect(e) and c:IsFaceup() then
				Duel.Overlay(c,mg)
			else
				Duel.SendtoGrave(mg,REASON_EFFECT)
			end
		end
	end
end

function s.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(tc) return tc:IsType(TYPE_XYZ) and tc:GetOwner()==tp end,1,nil)
end
function s.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	return true
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
