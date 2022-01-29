var documenterSearchIndex = {"docs":
[{"location":"man/recipeWebscraper/","page":"recipe webscraper","title":"recipe webscraper","text":"","category":"page"},{"location":"man/recipeWebscraper/#recipeWebscraper","page":"recipe webscraper","title":"recipeWebscraper","text":"","category":"section"},{"location":"man/recipeWebscraper/","page":"recipe webscraper","title":"recipe webscraper","text":"This is a supporting module that allows the user to download recipes from the cosylab recipe database based on their recipe number and exports them to a .csv file.","category":"page"},{"location":"man/recipeWebscraper/#scrapeRecipe","page":"recipe webscraper","title":"scrapeRecipe","text":"","category":"section"},{"location":"man/recipeWebscraper/","page":"recipe webscraper","title":"recipe webscraper","text":"scrapeRecipe","category":"page"},{"location":"man/recipeWebscraper/#STMOZOO.Fridge.recipeWebscraper.scrapeRecipe","page":"recipe webscraper","title":"STMOZOO.Fridge.recipeWebscraper.scrapeRecipe","text":"scrapeRecipe(scrapeBegin,scrapeEnd,csvPath)\n\nDownload recipetitles and their corresponding ingredients from the recipe database of cosylab as a dictionary. The recipes are downloaded based on their recipe number. This number can range from 2610 to 149191. To get a recipenumber one should look at the last number of the url of a certain recipe. For example, the recipe for 'Speculoosbavarois' is number 106585. The recipes get automatically saved in a csv file where the first column is the recipetitle and the second column is the list of ingredients.\n\nInput:\n\nscrapeBegin: The recipe number where the iteration should begin.\nscrapeEnd: The recipe number after which the iteration should and.\ncsvPath: The path where the csv file is stored.\n\nExamples:\n\nThe example below downloads the recipes 2700 to 2702 and  stores them in the csv file 'recipedb.csv' in the current folder.\n\njulia> scrapeRecipe(2700,2702,\"./recipedb.csv\")\n\n\n\n\n\n","category":"function"},{"location":"man/searchAlgorithms/#Search-Algorithms","page":"search algorithms","title":"Search Algorithms","text":"","category":"section"},{"location":"man/searchAlgorithms/","page":"search algorithms","title":"search algorithms","text":"This page includes some more information on the two search methods used.","category":"page"},{"location":"man/searchAlgorithms/#Greedy-Search","page":"search algorithms","title":"Greedy Search","text":"","category":"section"},{"location":"man/searchAlgorithms/","page":"search algorithms","title":"search algorithms","text":"greedyFindCombo","category":"page"},{"location":"man/searchAlgorithms/#STMOZOO.Fridge.greedyFindCombo","page":"search algorithms","title":"STMOZOO.Fridge.greedyFindCombo","text":"greedyFindCombo(fridgeList, recipeDict, numRecipes)\n\nThis function uses greedy search to find a good combination of recipes that match your fridge content. It ranks all recipes based on the following formula\n\nscore = (ingredients from fridge used) + 6*(ingredients in fridge remaining) + 2*(extra ingredients needed)\n\nInput:\n\nfridgeList: A list containing the different foods in your fridge as a string.\nrecipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.\nnumRecipes: The max amount of recipes that a combo should contain.\n\nOutput:\n\nbestCombo: A dictionary containing the best found combination of recipes.\n\n\n\n\n\n","category":"function"},{"location":"man/searchAlgorithms/#Simulated-Annealing","page":"search algorithms","title":"Simulated Annealing","text":"","category":"section"},{"location":"man/searchAlgorithms/","page":"search algorithms","title":"search algorithms","text":"SAFindCombo","category":"page"},{"location":"man/searchAlgorithms/#STMOZOO.Fridge.SAFindCombo","page":"search algorithms","title":"STMOZOO.Fridge.SAFindCombo","text":"SAFindCombo(curSolution,  fridgeList, recipeDict, numRecipes, randRecipe; kT=100, r=0.75, Tmax=4, Tmin=1, tabuLength=3)\n\nThis function uses simulated annealing to find a better combination of recipes that match your fridge content. It starts with the current solution and tries to improve this.\n\nInput:\n\ncurSolution: The current best combination of recipes, given as a dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.\nfridgeList: A list containing the different foods in your fridge as a string.\nrecipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.\nnumRecipes: The max amount of recipes that a combo should contain.\ntabuList: A list of recipes that should not be used in the found neighbour.\nrandRecipe: A Boolean true or false value. When true, random recipes are used for the neighbour.\n\nOptional Inputs:\n\nkT: repetitions per temperature\nr: cooling rate \nTmax: maximal temperature to start\nTmin: minimal temperature to end\ntabuLength: Number of cycli that recipe needs to be blocked\n\nOutput:\n\nsolution: A dictionary containing the best found combination of recipes.\n\n\n\n\n\n","category":"function"},{"location":"man/searchAlgorithms/#Neighbour-Functions","page":"search algorithms","title":"Neighbour Functions","text":"","category":"section"},{"location":"man/searchAlgorithms/","page":"search algorithms","title":"search algorithms","text":"RandomCombo\r\nremoveRecipe","category":"page"},{"location":"man/searchAlgorithms/#STMOZOO.Fridge.RandomCombo","page":"search algorithms","title":"STMOZOO.Fridge.RandomCombo","text":"randomCombo(fridgeList, recipeDict, numRecipes)\n\nThis function gives a random combination of recipes from the provided recipe dictionary.\n\nInput:\n\nfridgeList: A list containing the different foods in your fridge as a string.\nrecipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.\nnumRecipes: The max amount of recipes that a combo should contain.\n\nOutput:\n\nrandCombo: A dictionary containing a random combination of recipes.\n\n\n\n\n\n","category":"function"},{"location":"man/searchAlgorithms/#STMOZOO.Fridge.removeRecipe","page":"search algorithms","title":"STMOZOO.Fridge.removeRecipe","text":"removeRecipe(curSolution, fridgeList, recipeDict, numRecipes, tabuList, randRecipe)\n\nThis is a function that looks for a neighbour of the current solution. This function is used in the simulated annealing algorithm. It also uses a tabulist to stimulate the use of new solutions.\n\nInput:\n\ncurSolution: The current best combination of recipes, given as a dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.\nfridgeList: A list containing the different foods in your fridge as a string.\nrecipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.\nnumRecipes: The max amount of recipes that a combo should contain.\ntabuList: A list of recipes that should not be used in the found neighbour.\nrandRecipe: A Boolean true or false value. When true, random recipes are used for the neighbour.\n\nOutput:\n\nneighbour: A dictionary containing a combination of recipes.\n\n\n\n\n\n","category":"function"},{"location":"man/mainFunction/#Overview-Function","page":"main function","title":"Overview Function","text":"","category":"section"},{"location":"man/mainFunction/","page":"main function","title":"main function","text":"findBestRecipe","category":"page"},{"location":"man/mainFunction/#STMOZOO.Fridge.findBestRecipe","page":"main function","title":"STMOZOO.Fridge.findBestRecipe","text":"findBestRecipe(fridgeList, csvPath; numRecipes=3, randRecipe=false)\n\nThis function combines all other functions. This function checks if your ingredients are in the database,  if not it offers possible alternatives. Next it uses simulated annealing to find a better recipe combination.\n\nInput:\n\nfridgeList: A list containing the different foods in your fridge as a string.\ndataPath: A relative or absolute path to a .csv or .jld2 file containing the recipe database.\n\nOptional Inputs:\n\nnumRecipes: The max amount of recipes that a combo should contain.\nrandRecipe: A Boolean true or false value. When true, random recipes are used to find the neighbour in simulated annealing.\n\nOutput:\n\nSASolution: A dictionary containing the best found combination of recipes.\n\n\n\n\n\n","category":"function"},{"location":"man/mainFunction/","page":"main function","title":"main function","text":"This function checks the ingredients by using the checkIngredients function:","category":"page"},{"location":"man/mainFunction/","page":"main function","title":"main function","text":"checkIngredients","category":"page"},{"location":"man/mainFunction/#STMOZOO.Fridge.checkIngredients","page":"main function","title":"STMOZOO.Fridge.checkIngredients","text":"checkIngredients(fridgeList, ingredientList)\n\nThis function checks if the foods in your fridge are also found in the ingredient overview  of the recipe database. If they are not found in the database, regex is used to find possible alternatives. For instance cheese may be replaced by swiss cheese.\n\nInput:\n\nfridgeList: A list containing the different foods in your fridge as a string.\ningredientList: A list containing all the different ingredients that are used in the recipe database.\n\nOutput:\n\nfridgeList: The (adapted) given fridgeList\n\n\n\n\n\n","category":"function"},{"location":"#Fridge","page":"Fridge","title":"Fridge","text":"","category":"section"},{"location":"","page":"Fridge","title":"Fridge","text":"by Ward Van Belle","category":"page"},{"location":"","page":"Fridge","title":"Fridge","text":"This package tries to find the best recipes for you based on a recipe database. In our eyes (and the eyes of the objective function), the best recipes are the ones that use as much ingredients from your fridge as possible and that don't need extra ingredients from the grocery store.","category":"page"},{"location":"","page":"Fridge","title":"Fridge","text":"","category":"page"}]
}