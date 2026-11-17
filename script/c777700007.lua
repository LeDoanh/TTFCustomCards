-- Gensokyo Rule - Showdown Declaration
-- ID: 777700007
local s,id=GetID()

local SET_GENSOKYO = 0xa70

s.listed_series={SET_GENSOKYO}

function s.initial_effect(c)
	-- Hiệu ứng 1: Khóa hiệu ứng & miễn nhiễm cho 2 mục tiêu, ép giao chiến và khóa Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START)
	e1:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 2 (chỉ được xài 1 trong 2 hiệu ứng mỗi lượt)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Trục xuất lá này từ Mộ -> Úp trực tiếp 1 Spell/Trap "Gensokyo" từ Deck (không được kích hoạt lượt này)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 1
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC SHOWDOWN TRONG BATTLE PHASE & TRỪ NỬA LP SAU BATTLE PHASE
--------------------------------------------------------------------------------
function s.tgfilter1(c)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,s.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g1,2,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local tc1=e:GetLabelObject()
	local tc2=(g-tc1):GetFirst()
	local fg=g:Filter(Card.IsFaceup,nil)

	for tc in aux.Next(fg) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- Vô hiệu hóa hiệu ứng đến hết lượt
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- Miễn nhiễm với hiệu ứng bài khác đến hết lượt
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(3100)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(s.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end

	-- Ép 2 quái thú mục tiêu phải tấn công lẫn nhau trong Battle Phase lượt này
	if tc1 and tc2 and fg:IsContains(tc1) and fg:IsContains(tc2) then
		s.apply_battle_force(c,tc1,tc2)
		s.apply_battle_force(c,tc2,tc1)
	end

	-- Cấm quái thú khác tuyên bố tấn công trong Battle Phase lượt này
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(function() return Duel.IsBattlePhase() end)
	e4:SetTarget(function(_,tc) return not tc:HasFlagEffect(id) end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	-- Cấm cả 2 người chơi kích hoạt bài hoặc hiệu ứng trong Battle Phase lượt này
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetTargetRange(1,1)
	e5:SetCondition(function() return Duel.IsBattlePhase() end)
	e5:SetValue(1)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)

	-- Theo dõi việc bị tiêu diệt bởi chiến đấu để trừ nửa LP sau Battle Phase
	if tc1 or tc2 then
		local btrack=Effect.CreateEffect(c)
		btrack:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		btrack:SetCode(EVENT_BATTLE_DESTROYED)
		btrack:SetLabel(0)
		btrack:SetOperation(function(te,_,eg)
			local lbl=te:GetLabel()
			for bc in aux.Next(eg) do
				if tc1 and bc==tc1 then
					local p=bc:GetPreviousControler()
					lbl=lbl|1|(p<<2)
				elseif tc2 and bc==tc2 then
					local p=bc:GetPreviousControler()
					lbl=lbl|2|(p<<3)
				end
			end
			te:SetLabel(lbl)
		end)
		btrack:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(btrack,tp)

		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e6:SetCountLimit(1)
		e6:SetLabelObject(btrack)
		e6:SetCondition(function(te) return te:GetLabelObject():GetLabel()~=0 end)
		e6:SetOperation(function(te)
			local lbl=te:GetLabelObject():GetLabel()
			if (lbl&1)~=0 then
				local p1=(lbl>>2)&1
				Duel.SetLP(p1,(Duel.GetLP(p1)+1)//2)
			end
			if (lbl&2)~=0 then
				local p2=(lbl>>3)&1
				Duel.SetLP(p2,(Duel.GetLP(p2)+1)//2)
			end
			te:GetLabelObject():Reset()
			te:Reset()
		end)
		e6:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e6,tp)
	end
end

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

function s.apply_battle_force(c,attacker,target_mon)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetLabelObject(target_mon)
	e1:SetCondition(s.fbatkcon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	attacker:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetLabelObject(target_mon)
	e2:SetCondition(s.fbatkcon)
	e2:SetValue(s.fbatkval)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	attacker:RegisterEffect(e2)
end

function s.fbatkcon(e)
	local oc=e:GetLabelObject()
	return Duel.IsBattlePhase() and oc and oc:IsLocation(LOCATION_MZONE)
end

function s.fbatkval(e,c)
	return c==e:GetLabelObject()
end

--------------------------------------------------------------------------------
-- 2. LOGIC ÚP TRỰC TIẾP SPELL/TRAP "GENSOKYO" TỪ DECK
--------------------------------------------------------------------------------
function s.setfilter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SSet(tp,tc)>0 then
		-- Cấm kích hoạt lá bài vừa úp trong lượt này
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end