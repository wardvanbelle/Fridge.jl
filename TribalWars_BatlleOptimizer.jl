### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 476385f0-66f8-11ec-0f51-5930b44e312e
md"# Optimizing Attacks in Tribal Wars using MAP-Elites"

# ╔═╡ 66906f53-c68c-4236-b471-fc1b0d2a84dc
md"""## Introduction
Objective = lose as less population as possible

Constraints = amount of population

Axis = amount of units, percentage footsoldiers
"""

# ╔═╡ 090f2dda-fe30-4419-9430-2092a4313a41
md"## The Battle System"

# ╔═╡ 9b061489-8116-4714-8f47-c0c7a3264581


# ╔═╡ 1a888ee1-310b-4f28-b532-9f03ab4387e6
md"## MAP-Elites"

# ╔═╡ 9162a984-075c-4fab-b0f5-c58525a63aa9
md"### Generating The Archive"

# ╔═╡ 434b6b98-ef07-4953-bf74-f164d6846b87
md"### Making New Combinations"

# ╔═╡ f16ada76-41d3-40ac-b61a-4fb46df6de1c
md"### Optimizing The Army"

# ╔═╡ 104fa247-08a6-4317-8ee3-467d75455879
md"""## Function Corner
🏹 Do not touch this young warrior, or you will take an arrow to the knee! 🏹
"""

# ╔═╡ 71302c52-3c3f-4398-811d-b0dde5d166e9
begin 
	# introduce the general type
	abstract type Unit end
	
	# add the foot units
	abstract type Footunit <: Unit end
	
	struct Spear <: Footunit
		numUnits::Int64
		att::Int64
		defGeneral::Int64
		defHorse::Int64
		defArcher::Int64
		materialCost::Vector{Int64}
		populationCost::Int64
	end

	Spear(x) = Spear(x,10,15,45,20,[50,30,10],1)
	
	struct Sword <: Footunit 
		numUnits::Int64
		att::Int64
		defGeneral::Int64
		defHorse::Int64
		defArcher::Int64
		materialCost::Vector{Int64}
		populationCost::Int64		
	end
	
	Sword(x) = Sword(x,25,50,25,40,[30,30,70],1)
	
	struct Axe <: Footunit
		numUnits::Int64
		att::Int64
		defGeneral::Int64
		defHorse::Int64
		defArcher::Int64
		materialCost::Vector{Int64}
		populationCost::Int64
	end

	Axe(x) = Axe(x,40,10,5,10,[60,30,40],1)

	# add the mounted units
	abstract type Cavalry <: Unit end
	
	struct LC <: Cavalry 
		numUnits::Int64
		att::Int64
		defGeneral::Int64 
		defHorse::Int64
		defArcher::Int64
		materialCost::Vector{Int64}
		populationCost::Int64
	end
	
	LC(x) = LC(x,130,30,40,30,[125,100,250],4)
	
	struct HC <: Cavalry 
		numUnits::Int64
		att::Int64
		defGeneral::Int64
		defHorse::Int64
		defArcher::Int64
		materialCost::Vector{Int64}
		populationCost::Int64
	end

	HC(x) = HC(x,150,200,80,180,[200,150,600],6)

	# make it so that our units get displayed correctly
	Base.show(io::IO, x::Unit) = print(io, "$(x.numUnits) $(split(string(typeof(x)),".")[end]), ")
end;

# ╔═╡ 5aa06456-0a19-4e6e-842d-fbf75e83e91c
begin
	maxPopulation = 400
	DefendingVillage = [Spear(200), Sword(120)]
end

# ╔═╡ 9770d704-f364-4df7-8569-853aec3ca6e7
function Battle(Attacker::Vector{<:Unit}, Defender::Vector{<:Unit})
	
	# check if there is only cavalry and calculate attack stats
	if any([x isa Cavalry for x in Attacker]) && sum([x isa Cavalry for x in Attacker]) < length(Attacker)
		total_cavalry_att = sum([x.numUnits * x.att for x in Attacker if x isa Cavalry])
		total_foot_att = sum([x.numUnits * x.att for x in Attacker if x isa Footunit])
		total_att = total_cavalry_att + total_foot_att
		ratio_cavalry = total_cavalry_att/total_att
		ratio_foot = 1 - ratio_cavalry
	else
		if Attacker[1] isa Cavalry
			ratio_cavalry = 1
			ratio_foot = 0
		else
			ratio_cavalry = 0
			ratio_foot = 1
		end
		total_att = sum([x.numUnits * x.att for x in Attacker])
	end

	# calculate defense stats
	total_foot_def = sum([x.numUnits * x.defGeneral for x in Defender])
	total_cavalry_def = sum([x.numUnits * x.defHorse for x in Defender])
	total_def = total_foot_def * ratio_foot + total_cavalry_def * ratio_cavalry

	# check if win and return population loss
	if total_att > total_def
		win_loss_ratio = sqrt((total_def/total_att))/(total_att/total_def)
		population_lost = sum([x.populationCost * round(x.numUnits * win_loss_ratio) for x in Attacker])
		return population_lost
	else
		return Inf
	end
end

# ╔═╡ 4b5b26b4-0b43-4079-a5d4-a556593bf1fd
function CreateArmy(amountUnits::Int64, percentageFoot::Float64, maxPopulation::Int64)
	
	# calculate the amount of cavalry and footsoldiers
	amountFoot = round(amountUnits * percentageFoot)
	amountCavalry = amountUnits - amountFoot

	# calculate if this combination is possible, we multiply the amount of cavalry by 4 since this is the least amount of population needed per cavalry unit
	if (amountFoot + amountCavalry * 4) > maxPopulation
		return Inf
	end

	# create army
	if amountFoot > 0
		axemen = Axe(amountFoot)
		army = Unit[axemen]
	else
		army = Unit[]
	end
	amountHC = floor((maxPopulation - amountFoot - amountCavalry * 4) / 2)
	if amountHC >= amountCavalry
		amountHC = amountCavalry
	else
		lc = LC(amountCavalry - amountHC)	
		push!(army,lc)
	end
	
	if amountHC > 0 
		hc = HC(amountHC)
		push!(army,hc)
	end

	return army
end

# ╔═╡ b6809b85-9b9a-42e3-9135-f2b6ffbe23cc
begin
	maxUnits = maxPopulation
	minUnits = floor(Int64, maxPopulation/6)

	UnitAxis = Array(minUnits:maxUnits)
	FootPercentageAxis = Array(0:0.1:1)

	archive = fill([],(length(UnitAxis),length(FootPercentageAxis)))
	scores = fill(Inf,(length(UnitAxis),length(FootPercentageAxis)))

	for amountUnits in UnitAxis
		for percentageFoot in FootPercentageAxis
			army = CreateArmy(amountUnits, percentageFoot, maxPopulation)

			if !(army isa Float64)
				x = UnitAxis .== amountUnits
				y = FootPercentageAxis .== percentageFoot
				archive[x, y] = [army]
				scores[x, y] .= Battle(army,DefendingVillage)
			end
		end
	end
end

# ╔═╡ 2d63fa8c-bab7-475f-952f-72ed7b5d7b17
md"With $(archive[argmin(scores)])you lose $(Int64(scores[argmin(scores)])) people."

# ╔═╡ 2515b9ec-48ca-41c3-bd6d-127e180e1d90
function DetermineCharacteristics(army::Vector{<:Unit})
	amountUnits = sum([x.numUnits for x in army])
	percentageFoot = sum([x.numUnits for x in army if x isa Footunit])/amountUnits
	return amountUnits, percentageFoot
end

# ╔═╡ Cell order:
# ╟─476385f0-66f8-11ec-0f51-5930b44e312e
# ╟─66906f53-c68c-4236-b471-fc1b0d2a84dc
# ╟─090f2dda-fe30-4419-9430-2092a4313a41
# ╠═9b061489-8116-4714-8f47-c0c7a3264581
# ╟─1a888ee1-310b-4f28-b532-9f03ab4387e6
# ╠═5aa06456-0a19-4e6e-842d-fbf75e83e91c
# ╟─9162a984-075c-4fab-b0f5-c58525a63aa9
# ╠═b6809b85-9b9a-42e3-9135-f2b6ffbe23cc
# ╟─434b6b98-ef07-4953-bf74-f164d6846b87
# ╟─f16ada76-41d3-40ac-b61a-4fb46df6de1c
# ╟─2d63fa8c-bab7-475f-952f-72ed7b5d7b17
# ╟─104fa247-08a6-4317-8ee3-467d75455879
# ╠═9770d704-f364-4df7-8569-853aec3ca6e7
# ╠═4b5b26b4-0b43-4079-a5d4-a556593bf1fd
# ╠═2515b9ec-48ca-41c3-bd6d-127e180e1d90
# ╠═71302c52-3c3f-4398-811d-b0dde5d166e9
