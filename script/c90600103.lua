-- Æthel Nemesis Protocol - Distortion
-- ID: 90600103
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Kích hoạt Counter Trap: Phủ nhận tất cả kích hoạt Phép/Bẫy và Hiệu ứng Quái thú của đối thủ trước lá bài này trong Chain, sau đó Banish chúng
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Kích hoạt từ tay nếu điều khiển "Sky Striker Nemesis - Deus Ex Machina" và có từ 3 lá Phép bị banish trở lên
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end

s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER}
s.listed_names={90600087} -- ID của "Sky Striker Nemesis - Deus Ex Machina" (hoặc chỉnh lại theo ID thực tế của bạn)

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN KÍCH HOẠT TỪ TAY
--------------------------------------------------------------------------------
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	local has_deus=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,90600087),tp,LOCATION_MZONE,0,1,nil)
	local has_spells=Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_REMOVED,0,nil)>=3
	return has_deus and has_spells
end

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN VÀ TARGET CỦA HIỆU ỨNG CHÍNH
--------------------------------------------------------------------------------
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
		and (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- Phải điều khiển quái thú Link thuộc "Æthel Nemesis" hoặc "Sky Striker"
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- Kiểm tra xem trong Chain hiện tại có ít nhất 1 kích hoạt của đối thủ hay không
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local ep_i=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_PLAYER)
		if ep_i==1-tp and (te:IsActiveType(TYPE_SPELL+TYPE_TRAP) or te:IsActiveType(TYPE_MONSTER)) then
			return true
		end
	end
	return false
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	local ng=Group.CreateGroup()
	local rg=Group.CreateGroup()
	
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local ep_i=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_PLAYER)
		local tc=te:GetHandler()
		if ep_i==1-tp and (te:IsActiveType(TYPE_SPELL+TYPE_TRAP) or te:IsActiveType(TYPE_MONSTER)) then
			ng:AddCard(tc)
			if tc:IsAbleToRemove() then
				rg:AddCard(tc)
			end
		end
	end
	
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,#ng,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
end

--------------------------------------------------------------------------------
-- KÍCH HOẠT: PHỦ NHẬN VÀ BANISH TOÀN BỘ CHUỖI KÍCH HOẠT CỦA ĐỐI THỦ
--------------------------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local ep_i=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_PLAYER)
		local tc=te:GetHandler()
		if ep_i==1-tp and (te:IsActiveType(TYPE_SPELL+TYPE_TRAP) or te:IsActiveType(TYPE_MONSTER)) then
			if Duel.NegateActivation(i) and tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	
	if #dg>0 then
		Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
	end
end