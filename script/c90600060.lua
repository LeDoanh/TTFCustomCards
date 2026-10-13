-- Sky Striker Ace - Peaceful Day
-- ID: 90600060
local s,id=GetID()
function s.initial_effect(c)
	-- Triệu hồi Đặc biệt bằng cách Tribute 2 quái thú đối thủ điều khiển (Kaiju-style) sang sân đối thủ ở thế Phòng thủ
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Không thể thay đổi tư thế chiến đấu
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e3)

	-- Người điều khiển không thể dùng làm nguyên liệu Fusion, Synchro, Xyz, hoặc Link
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e7)

	-- Trong Standby Phase: Người điều khiển nhận 2000 sát thương
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,1))
	e8:SetCategory(CATEGORY_DAMAGE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(s.damtg)
	e8:SetOperation(s.damop)
	c:RegisterEffect(e8)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN & THAO TÁC SPECIAL SUMMON
--------------------------------------------------------------------------------
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>-2
		and #rg>=2
		and aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1-tp),0)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1-tp),1,tp,HINTMSG_RELEASE)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()

	-- Thiết lập triệu hồi sang sân đối thủ (1-tp) ở thế Phòng thủ ngửa mặt
	c:SetSpecialSummonInfo(SUMMON_TYPE_SPECIAL,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)

	-- Ràng buộc không thể Normal Summon/Set trong lượt này
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e2,tp)
end

--------------------------------------------------------------------------------
-- SÁT THƯƠNG TRONG STANDBY PHASE
--------------------------------------------------------------------------------
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=e:GetHandler():GetControler()
	Duel.SetTargetPlayer(p)
	Duel.SetTargetParam(2000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,2000)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Damage(p,2000,REASON_EFFECT)
end