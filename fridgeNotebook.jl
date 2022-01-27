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

# ╔═╡ 8c6e005b-eb0b-4644-aa86-f5242770e87d
begin
	using PlutoUI, Pkg
	Pkg.activate("../")
	include("../src/recipewebscraper.jl")
	using .recipeWebscraper
end

# ╔═╡ ae625e40-7f56-11ec-3cd5-d1244e23a3ba
md"""# Fridge.jl
by *Ward Van Belle*
"""

# ╔═╡ 06db3cc2-1680-49b9-a054-281a6b35205a
md"""A package that optimizes your fridge use while reducing your waste pile!!

This package tries to find the best recipes for you based on a recipe database. In our eyes (and the eyes of the objective function), the best recipes are the ones that use as much ingredients from your fridge as possible and that don't need extra ingredients from the grocery store."""

# ╔═╡ 2f8fdff5-0d3f-4167-b415-e7f5f85e006b
md"Download example recipe database: $(@bind downloadDB CheckBox())"

# ╔═╡ cd5458a5-2136-4559-b4e5-2d91abea870c
if downloadDB
	missing
end

# ╔═╡ Cell order:
# ╟─8c6e005b-eb0b-4644-aa86-f5242770e87d
# ╟─ae625e40-7f56-11ec-3cd5-d1244e23a3ba
# ╟─06db3cc2-1680-49b9-a054-281a6b35205a
# ╟─2f8fdff5-0d3f-4167-b415-e7f5f85e006b
# ╠═cd5458a5-2136-4559-b4e5-2d91abea870c
