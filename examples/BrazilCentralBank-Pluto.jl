### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 997b29e6-0dea-439d-a39a-f3171d4e8cca
using Pkg

# ╔═╡ b3de8b8f-fb36-4062-b19e-a30012331ebb
# ╠═╡ show_logs = false
Pkg.add(["BrazilCentralBank", "Plots"])

# ╔═╡ 702dfc94-20bc-4925-9f2c-e4541df25649
using BrazilCentralBank, Plots

# ╔═╡ 96112a08-eae7-4475-b61f-08c6535340be
Pkg.status("BrazilCentralBank")

# ╔═╡ f3c8f7c1-4889-42e3-950c-10b1311637e4
getcurrency_list()

# ╔═╡ a5afa4df-d805-4eba-b1d6-a10f6b50655b
const EUR = Currency("EUR")

# ╔═╡ 2871b935-46ca-4764-8400-07895d7c02dd
EUR.getcurrencyseries("CHF", "2024-03-01", "2024-03-31")

# ╔═╡ e247c7bc-60f0-4c05-8265-9f451d583d79
df = getcurrencyseries(["USD", "EUR"], "2024-03-01", "2024-03-31")

# ╔═╡ f4dd77f2-3d19-4fa4-a5d5-ead9ef6f1884
plot(df.Date, [df.ask_USD df.ask_EUR]; label=["ask_USD" "ask_EUR"])

# ╔═╡ ecaeb7b2-c448-432e-afec-0f937def7300
gettimeseries(Dict("USDBRL" => 1), last=10)

# ╔═╡ 4216a4ef-2594-4735-83e5-55a726a9c289
df_infl = gettimeseries(Dict("Inflacao" => 433), start="2022-01-01", finish="2023-01-01")

# ╔═╡ 72c09ed4-4314-4d37-af8d-373cec9eecd7
plot(df_infl.Date, df_infl.Inflacao; label="Inflação")

# ╔═╡ Cell order:
# ╠═997b29e6-0dea-439d-a39a-f3171d4e8cca
# ╠═96112a08-eae7-4475-b61f-08c6535340be
# ╠═b3de8b8f-fb36-4062-b19e-a30012331ebb
# ╠═702dfc94-20bc-4925-9f2c-e4541df25649
# ╠═f3c8f7c1-4889-42e3-950c-10b1311637e4
# ╠═a5afa4df-d805-4eba-b1d6-a10f6b50655b
# ╠═2871b935-46ca-4764-8400-07895d7c02dd
# ╠═e247c7bc-60f0-4c05-8265-9f451d583d79
# ╠═f4dd77f2-3d19-4fa4-a5d5-ead9ef6f1884
# ╠═ecaeb7b2-c448-432e-afec-0f937def7300
# ╠═4216a4ef-2594-4735-83e5-55a726a9c289
# ╠═72c09ed4-4314-4d37-af8d-373cec9eecd7
