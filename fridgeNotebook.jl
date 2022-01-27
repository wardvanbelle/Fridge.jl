### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ ae625e40-7f56-11ec-3cd5-d1244e23a3ba
begin
using PlutoUI, HTTP, Gumbo, Cascadia, CSV, JLD2
	
md"""# Fridge.jl
by *Ward Van Belle*
"""

end

# ╔═╡ 06db3cc2-1680-49b9-a054-281a6b35205a
md"""$(LocalResource("../FridgeLogo.png", :width => 150, :align => "right"))

A package that optimizes your fridge use while reducing your waste pile!!

This package tries to find the best recipes for you based on a recipe database. In our eyes (and the eyes of the objective function), the best recipes are the ones that use as much ingredients from your fridge as possible and that don't need extra ingredients from the grocery store."""

# ╔═╡ 3ad1af72-7096-4106-a3c7-47326695e2cb
md"""
## Checking The Ingredients
If you want to optimize the fridge usage. It's best to know which ingredients are in the fridge. By checking all the ingredients and offering possible alternatives, it is easier for the algorithm to give better results.
"""

# ╔═╡ 8e58f807-1db9-495e-8679-430f953292ea
function checkIngredients(fridgeList,ingredientList)
"""
    checkIngredients(fridgeList,ingredientList)

This function checks if the foods in your fridge are also found in the ingredient overview 
of the recipe database. If they are not found in the database, regex is used to find possible alternatives.
For instance cheese may be replaced by swiss cheese.

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- ingredientList: A list containing all the different ingredients that are used in the recipe database.

## Output:
- fridgeList: The (adapted) given fridgeList

"""


    print("Checking if the food in your fridge is found in our database.\n\n")

    # check if the ingredients in the fridge are found in the database
    for food in fridgeList
        if food in ingredientList
            print("Found $food in the ingredient database.\n")
        else
            print("Did not find $food in the ingredient database.\n\n")
            if any(occursin.(food,ingredientList))
                print("Possible alternatives in database:\n")
                alternatives = ingredientList[occursin.(food,ingredientList)]
                for (indexNum, alternative) in enumerate(alternatives)
                    print("[$indexNum] $alternative\n")
                end
                print("If you want to take an alternative type its number, else type no.\n")
                answer = readline()
                if answer != "no"
                    correctInput = false
                    while !correctInput
                        try
                            answer = parse(Int64,answer)
                            correctInput = true
                        catch
                            print("Please only type the number of the alternative, eg. 1\n")
                            answer = readline()
                        end
                    end
                    fridgeList[fridgeList .== food] .= alternatives[answer]
                    print("Replaced $food with $(alternatives[answer])\n")
                end
            else
                print("Did not find any alternative in the ingredient database.\n")
            end
        end
    end
    print("Done checking ingredients.\n\n")

    return fridgeList
end

# ╔═╡ 264b1eb5-c421-4a69-a55c-8fbbbb7715d1
md"""
## Objective Functions
Of course, we want to be able to score how good our objective function will be. This objective function is based on the following formula where ``u`` is the number of ingredients used from the fridge, ``r`` is the number of ingredients remaining in the fridge and ``e`` are the extra ingredients needed. ``w_1``, ``w_2`` and ``w_3`` are a set of weights.

``score = w_1 * u + w_2 * r + w_3*e``
"""

# ╔═╡ c793a149-2cbe-462a-b69a-6ecab53320a6
md"""
``w_1``: $(@bind w_1 Slider(0:10))\
``w_2``: $(@bind w_2 Slider(0:10))\
``w_3``: $(@bind w_3 Slider(0:10))\
"""

# ╔═╡ 52c497d7-36b9-4017-934a-1ea6190cbbb5
md"``w_1``: $(w_1) ``w_2``: $(w_2) ``w_3``: $(w_3)"

# ╔═╡ 1752889a-513a-4620-add4-a9ca7fa92c8e
md"""
## The Search Algorithm
Let's now take a look at the different search algorithms that you can use in the Fridge.jl module.
"""

# ╔═╡ a65c0925-7a67-4da3-9a6d-2ade8d3529e9
md"""### Greedy Algorithm
It ranks all recipes based on the previously discussed objective function.
"""

# ╔═╡ 954fe2b3-171b-43ad-a1df-cbb3414988de
md"""
### Simulated Annealing
To improve our earlier result, we can use simulated annealing. The algorithm below is based on the one seen in class. The biggest difference is the fact that we also use a Tabu list to block recipes for a certain number of cycles.
"""

# ╔═╡ 7315f676-0d0e-43ae-8231-b6274dc5c8de
md"""
### Neighbours
There are two types of neighbours to use. One is a random combination of recipes, the other is based on the Greedy Search algorithm.
"""

# ╔═╡ b6205bd3-41da-45e0-81f1-a480a3f0e737
md"""
## Overview Function
Finally we want to bring all the functions together in one.
"""

# ╔═╡ 6af2a6dd-ba7e-470e-8915-12ae6eff8357
md"## Example Time"

# ╔═╡ 2f8fdff5-0d3f-4167-b415-e7f5f85e006b
md"""Download example recipe database: $(@bind downloadDB CheckBox())\
\
It is recommended to only use this once, otherwise you will have copies of some recipes in your database."""

# ╔═╡ c51f2b76-fe4c-4c29-87dc-c7784e5200c2
md"""
## Supporting Functions
Below you can find all the supporting functions used in this notebook. These can also be found in the src folder in the [GitHub repository](https://github.com/wardvanbelle/Fridge.jl). Please do not adapt them.
"""

# ╔═╡ 09d6393c-9b14-4401-babe-708a88ef0a16
function scrapeRecipe(scrapeBegin,scrapeEnd,csvPath)
"""
    scrapeRecipe(scrapeBegin,scrapeEnd,csvPath)

Download recipetitles and their corresponding ingredients from the recipe database of cosylab as a dictionary.
The recipes are downloaded based on their recipe number. This number can range from 2610 to 149191.
To get a recipenumber one should look at the last number of the url of a certain recipe.
For example, the recipe for 'Speculoosbavarois' is number 106585.
The recipes get automatically saved in a csv file where the first column is the recipetitle and the second column
is the list of ingredients.

## Input:
- scrapeBegin: The recipe number where the iteration should begin.
- scrapeEnd: The recipe number after which the iteration should and.
- csvPath: The path where the csv file is stored.

## Examples:

The example below downloads the recipes 2700 to 2702 and 
stores them in the csv file 'recipedb.csv' in the current folder.

```julia-repl
julia> scrapeRecipe(2700,2702,"./recipedb.csv")
```
"""
    for i = scrapeBegin:scrapeEnd
        # get the webpage
        htmlText = HTTP.request("GET","https://cosylab.iiitd.edu.in/recipedb/search_recipeInfo/$i")
        htmlBody = parsehtml(String(htmlText.body))

        # get the needed elements out of the webpage
        recipeTitle = eachmatch(Selector("h3"),htmlBody.root)[1].children[1].text
        print("recipe number $i : $recipeTitle\n")
        ingredientTab = eachmatch(Selector("#ingredient_nutri"),htmlBody.root)
        ingredientTabel = eachmatch(Selector("#myTable"),ingredientTab[1])
        ingredientLinks = eachmatch(Selector("td a"),ingredientTabel[1])
        ingredientList = []
        for ingredientLink in ingredientLinks
            try
                append!(ingredientList, [ingredientLink.children[1].text])
            catch y
            end
        end

        # write the data to the DB
        if isfile(csvPath)
            CSV.write(csvPath, Dict(recipeTitle => ingredientList), append = true) 
        else
            CSV.write(csvPath, Dict(recipeTitle => ingredientList), append = false) 
        end
         
    end
    print("done")
end

# ╔═╡ cd5458a5-2136-4559-b4e5-2d91abea870c
if downloadDB
	scrapeRecipe(106541,106641,"../data/BelgianRecipeDB.csv")
end

# ╔═╡ 87b72838-260f-4ffb-ac79-03860165afa1
function loadRecipeDBCSV(csvPath)
    # read the dictionary from the csv file
    print("Loading the recipe database.\n")
    tempDict = CSV.File(csvPath) |> Dict
    recipeDict = Dict()
    
    # parse the ingredient list to the right format
    print("Parsing ingredients to right format.\n\n")
    for recipe in keys(tempDict)
        ingredientList = tempDict[recipe]
        recipeDict[recipe] = eval(Meta.parse(ingredientList))
    end
    return recipeDict 
end

# ╔═╡ adde7105-4a4a-453b-a7a8-9c9471dc29d3
function createIngredientDatabase(recipeDict)
    # create an unique vector of all ingredients used in the recipe database
    ingredientList = []
    for ingredients in values(recipeDict)
        append!(ingredientList,ingredients)
    end
    ingredientList = unique(ingredientList)

    return ingredientList
end

# ╔═╡ 89e58385-4db9-4ae3-9495-d8a2e63f2d72
function recipeToNumVector(fridgeList,ingredientList)
"""
    recipeToNumVector(fridgeList,ingredientList)

This function changes an ingredients list of a recipe to a numeric vector. This vector has a length equal
to the number of foods in your fridge plus one. If a certain food from the fridge is used in the recipe, that position in the vector is a 1.
If not it is a 0. The last index of the vector contains the amount of extra ingredients needed.

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- ingredientList: A list containing all the ingredients used in a specific recipe.

## Output:
- numVector: This vector has a length equal to the number of foods in your fridge plus one. If a certain food from the fridge is used in the recipe, 
that position in the vector is a 1. If not it is a 0. The last index of the vector contains the amount of extra ingredients needed.

"""
    numVector = zeros(Int64,length(fridgeList)+1)
    for i in 1:length(fridgeList)
        numVector[i] = fridgeList[i] in ingredientList ? 1 : 0
    end
    numVector[end] = length(ingredientList) - sum(numVector)
    return numVector
end

# ╔═╡ 3ed830c9-e3f7-4632-9ff3-cdd48c00f315
function RandomCombo(fridgeList, recipeDict, numRecipes)
"""
    randomCombo(fridgeList, recipeDict, numRecipes)

This function gives a random combination of recipes from the provided recipe dictionary.

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- recipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- numRecipes: The max amount of recipes that a combo should contain.

## Output:
- randCombo: A dictionary containing a random combination of recipes.
"""
    randCombo = Dict()
    ingredientsArray = []
    namesArray = []

    for (name,ingredients) in recipeDict
        push!(namesArray,name)
        push!(ingredientsArray, recipeToNumVector(fridgeList, ingredients))
    end

    for i = 1:numRecipes

        randIndex = rand(1:length(namesArray))
        tempRecipeName = namesArray[randIndex]
        randCombo[tempRecipeName] = ingredientsArray[randIndex]

        if all(isone.(sum(values(randCombo))))
            break
        end

        namesArray = [name for (name, ingredientList) in zip(namesArray, ingredientsArray) if sum(ingredientList[1:end-1] .& randCombo[tempRecipeName][1:end-1] ) == 0]
        ingredientsArray = [ingredientList for ingredientList in ingredientsArray if sum(ingredientList[1:end-1] .& randCombo[tempRecipeName][1:end-1] ) == 0]

        if isempty(namesArray)
            break
        end

    end

    return randCombo
end

# ╔═╡ 7365d57b-fd33-46af-9dcd-2c07908f64a3
function removeRecipe(curSolution, fridgeList, recipeDict, numRecipes, tabuList, randRecipe)
"""
    removeRecipe(curSolution, fridgeList, recipeDict, numRecipes, tabuList, randRecipe)

This is a function that looks for a neighbour of the current solution. This function is used in the simulated annealing algorithm.
It also uses a tabulist to stimulate the use of new solutions.

## Input:
- curSolution: The current best combination of recipes, given as a dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- fridgeList: A list containing the different foods in your fridge as a string.
- recipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- numRecipes: The max amount of recipes that a combo should contain.
- tabuList: A list of recipes that should not be used in the found neighbour.
- randRecipe: A Boolean `true` or `false` value. When `true`, random recipes are used for the neighbour.

## Output:
- neighbour: A dictionary containing a combination of recipes.

"""
    toRemove = rand(curSolution)[1]
    # adapt the fridgeList so that only ingredients from the removed ingredient are available
    tempFridgeList = copy(fridgeList)
    for recipe in keys(curSolution)
        if recipe != toRemove
            tempFridgeList = [i for i in fridgeList if !in(i,recipeDict[recipe])]
        end
    end

    # adapt the recipeDict and use greedy search to find a new solution
    tempRecipeDict = copy(recipeDict)
    for recipe in keys(curSolution)
        delete!(tempRecipeDict,recipe)
    end

    for recipe in tabuList
        try delete!(tempRecipeDict,recipe)
        catch e
        end
    end

    if randRecipe
        neighbour = RandomCombo(tempFridgeList, tempRecipeDict, numRecipes)
    else
        neighbour = GreedyFindCombo(tempFridgeList, tempRecipeDict, numRecipes)
    end

    # correct recipe vectors
    for recipe in keys(neighbour)
        neighbour[recipe] = recipeToNumVector(fridgeList,recipeDict[recipe])
    end

    # here combine the two dictionaries
    tempCurSolution = copy(curSolution)
    delete!(tempCurSolution,toRemove)
    neighbour = merge(neighbour,tempCurSolution)

    return neighbour
end

# ╔═╡ a6e77624-606a-49ea-941d-8180cbd94a27
compatible(x) = !any(sum(x)[1:end-1] .>= 2) # checks if two recipes use a same ingredient

# ╔═╡ 644c2809-5b2b-4426-8deb-f952372a8438
begin
	
# objective function used to score a single recipe
fridgeObjective(x::Array{Int64}) = w_1 * sum(x[1:end-1]) + w_2 *sum(x[1:end-1] .== 0) + w_3 *x[end]

# objective function used to score a combination of recipes
fridgeObjective(x) = compatible(x) ? sum(sum(x) .== 1)*w_1 + sum(sum(x) .== 0)*w_2 + sum(x)[end]*w_3 : Inf 

end

# ╔═╡ ace6ecfa-319b-48f3-a675-51b4bc26abd0
function greedyFindCombo(fridgeList, recipeDict, numRecipes)
"""
    greedyFindCombo(fridgeList, recipeDict, numRecipes)

This function uses greedy search to find a good combination of recipes that match your fridge content.
It ranks all recipes based on the following formula

``score = (ingredients from fridge used) + 6*(ingredients in fridge remaining) + 2*(extra ingredients needed)``

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- recipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- numRecipes: The max amount of recipes that a combo should contain.

## Output:
- bestCombo: A dictionary containing the best found combination of recipes.

"""

    bestCombo = Dict()
    ingredientsArray = []
    namesArray = []

    for (name,ingredients) in recipeDict
        push!(namesArray,name)
        push!(ingredientsArray, recipeToNumVector(fridgeList, ingredients))
    end

    for i = 1:numRecipes

        bestOrder = sortperm(ingredientsArray, by=fridgeObjective)
        ingredientsArray = ingredientsArray[bestOrder]
        namesArray = namesArray[bestOrder]

        tempRecipeName = namesArray[1]
        bestCombo[tempRecipeName] = ingredientsArray[1]

        if all(isone.(sum(values(bestCombo))))
            break
        end

        namesArray = [name for (name, ingredientList) in zip(namesArray, ingredientsArray) if sum(ingredientList[1:end-1] .& bestCombo[tempRecipeName][1:end-1] ) == 0]
        ingredientsArray = [ingredientList for ingredientList in ingredientsArray if sum(ingredientList[1:end-1] .& bestCombo[tempRecipeName][1:end-1] ) == 0]

        if isempty(namesArray)
            break
        end

    end

    return bestCombo
end

# ╔═╡ 6f1d6e44-30a1-42ee-b888-4cbb105b5348
function SAFindCombo(curSolution,  fridgeList, recipeDict, numRecipes, randRecipe;
    kT=100, # repetitions per temperature
    r=0.75, # cooling rate
    Tmax=4, # maximal temperature to start
    Tmin=1, # minimal temperature to end
    tabuLength=3) # number of cycli that recipe needs to be blocked

"""
    SAFindCombo(curSolution,  fridgeList, recipeDict, numRecipes, randRecipe; kT=100, r=0.75, Tmax=4, Tmin=1, tabuLength=3)

This function uses simulated annealing to find a better combination of recipes that match your fridge content.
It starts with the current solution and tries to improve this.

## Input:
- curSolution: The current best combination of recipes, given as a dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- fridgeList: A list containing the different foods in your fridge as a string.
- recipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- numRecipes: The max amount of recipes that a combo should contain.
- tabuList: A list of recipes that should not be used in the found neighbour.
- randRecipe: A Boolean `true` or `false` value. When `true`, random recipes are used for the neighbour.

## Optional Inputs:
- kT: repetitions per temperature
- r: cooling rate 
- Tmax: maximal temperature to start
- Tmin: minimal temperature to end
- tabuLength: Number of cycli that recipe needs to be blocked

## Output:
- solution: A dictionary containing the best found combination of recipes.

"""
    
    @assert 0 < Tmin < Tmax "Temperatures should be positive"
	@assert 0 < r < 1 "cooling rate is between 0 and 1"
	solution = curSolution
	obj = fridgeObjective([i for i in values(solution)])
    tabuList = String[i for i in keys(curSolution)] 

	# current temperature
	T = Tmax
	while T > Tmin
        print("T = $T \n")
		# repeat kT times
		for i in 1:kT
			sn = removeRecipe(solution, fridgeList, recipeDict, numRecipes, tabuList, randRecipe)  # random neighbor
			obj_sn = fridgeObjective([i for i in values(sn)])
			# if the neighbor improves the solution, keep it
			# otherwise accept with a probability determined by the
			# Metropolis heuristic
			if obj_sn < obj || rand() < exp(-(obj_sn-obj)/T)
				solution = sn
				obj = obj_sn
			end

            for recipe in keys(sn)
                if !in(recipe, tabuList)
                    if length(tabuList) < tabuLength
                        pushfirst!(tabuList,recipe)
                    else
                        pop!(tabuList)
                        pushfirst!(tabuList,recipe) 
                    end
                end
            end
		end
		#track!(tracker, f, s) # not yet implemented, maybe later

		# decay temperature
		T *= r
	end

    return solution
end

# ╔═╡ 9bfc9f3d-bc05-4c15-8b4c-2cfce3507afc
function findBestRecipe(fridgeList, dataPath; numRecipes=3, randRecipe=false)
"""
    findBestRecipe(fridgeList, csvPath; numRecipes=3, randRecipe=false)

This function combines all other functions. This function checks if your ingredients are in the database, 
if not it offers possible alternatives. Next it uses simulated annealing to find a better recipe combination.

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- dataPath: A relative or absolute path to a .csv or .jld2 file containing the recipe database.

## Optional Inputs:
- numRecipes: The max amount of recipes that a combo should contain.
- randRecipe: A Boolean `true` or `false` value. When `true`, random recipes are used to find the neighbour in simulated annealing.

## Output:
- SASolution: A dictionary containing the best found combination of recipes.

"""

    # load the recipe dictionary from the db file
    recipeDict = dataPath[end-3:end] == ".csv" ? loadRecipeDBCSV(dataPath) : load(dataPath)

    # create a list of all ingredients in your database
    ingredientList = createIngredientDatabase(recipeDict)

    # check for every food in your fridge if it's in the database. If not check if their are alternatives.
    fridgeList = checkIngredients(fridgeList, ingredientList)

    # find the best greedy recipe
    greedySolution = GreedyFindCombo(fridgeList, recipeDict, numRecipes)
    print("greedySolution = $greedySolution\n")

    # find the best recipe with SA
    SASolution = SAFindCombo(greedySolution,  fridgeList, recipeDict, numRecipes, randRecipe)

    # print the solution 
    print("The best recipes to make are:\n\n")
    for recipeName in keys(SASolution)
        print("$(recipeName) : $(recipeDict[recipeName])\n")
    end

    return SASolution
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
Cascadia = "54eefc05-d75b-58de-a785-1a3403f0919f"
Gumbo = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JLD2 = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CSV = "~0.10.2"
Cascadia = "~1.0.1"
Gumbo = "~0.8.0"
HTTP = "~0.9.17"
JLD2 = "~0.4.18"
PlutoUI = "~0.7.32"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "9519274b50500b8029973d241d32cfbf0b127d97"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.2"

[[Cascadia]]
deps = ["AbstractTrees", "Gumbo"]
git-tree-sha1 = "95629728197821d21a41778d0e0a49bc2d58ab9b"
uuid = "54eefc05-d75b-58de-a785-1a3403f0919f"
version = "1.0.1"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "67551df041955cc6ee2ed098718c8fcd7fc7aebe"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.12.0"

[[FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "04d13bfa8ef11720c24e4d840c0033d145537df7"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.17"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[Gumbo]]
deps = ["AbstractTrees", "Gumbo_jll", "Libdl"]
git-tree-sha1 = "e711d08d896018037d6ff0ad4ebe675ca67119d4"
uuid = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
version = "0.8.0"

[[Gumbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "29070dee9df18d9565276d68a596854b1764aa38"
uuid = "528830af-5a63-567c-a44a-034ed33b8444"
version = "0.10.2+0"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "8d70835a3759cdd75881426fced1508bb7b7e1b6"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLD2]]
deps = ["DataStructures", "FileIO", "MacroTools", "Mmap", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "39f22411266cdd1621092c762a3f0648dbdc8433"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.18"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "22df5b96feef82434b07327e2d3c770a9b21e023"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "92f91ba9e5941fc781fecf5494ac1da87bdac775"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "ae6145ca68947569058866e443df69587acc1806"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.32"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "15dfe6b103c2a993be24404124b8791a09460983"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.11"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─ae625e40-7f56-11ec-3cd5-d1244e23a3ba
# ╟─06db3cc2-1680-49b9-a054-281a6b35205a
# ╟─3ad1af72-7096-4106-a3c7-47326695e2cb
# ╠═8e58f807-1db9-495e-8679-430f953292ea
# ╟─264b1eb5-c421-4a69-a55c-8fbbbb7715d1
# ╟─c793a149-2cbe-462a-b69a-6ecab53320a6
# ╟─52c497d7-36b9-4017-934a-1ea6190cbbb5
# ╠═644c2809-5b2b-4426-8deb-f952372a8438
# ╟─1752889a-513a-4620-add4-a9ca7fa92c8e
# ╟─a65c0925-7a67-4da3-9a6d-2ade8d3529e9
# ╠═ace6ecfa-319b-48f3-a675-51b4bc26abd0
# ╟─954fe2b3-171b-43ad-a1df-cbb3414988de
# ╠═6f1d6e44-30a1-42ee-b888-4cbb105b5348
# ╟─7315f676-0d0e-43ae-8231-b6274dc5c8de
# ╠═3ed830c9-e3f7-4632-9ff3-cdd48c00f315
# ╠═7365d57b-fd33-46af-9dcd-2c07908f64a3
# ╟─b6205bd3-41da-45e0-81f1-a480a3f0e737
# ╠═9bfc9f3d-bc05-4c15-8b4c-2cfce3507afc
# ╟─6af2a6dd-ba7e-470e-8915-12ae6eff8357
# ╟─2f8fdff5-0d3f-4167-b415-e7f5f85e006b
# ╠═cd5458a5-2136-4559-b4e5-2d91abea870c
# ╟─c51f2b76-fe4c-4c29-87dc-c7784e5200c2
# ╟─09d6393c-9b14-4401-babe-708a88ef0a16
# ╟─87b72838-260f-4ffb-ac79-03860165afa1
# ╟─adde7105-4a4a-453b-a7a8-9c9471dc29d3
# ╟─89e58385-4db9-4ae3-9495-d8a2e63f2d72
# ╟─a6e77624-606a-49ea-941d-8180cbd94a27
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
