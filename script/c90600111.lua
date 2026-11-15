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
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
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