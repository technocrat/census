.PHONY: all test docs clean

all: test docs

test:
	julia --project -e 'using Pkg; Pkg.test()'

docs:
	julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
	julia --project=docs/ docs/make.jl

format:
	julia --project -e 'using JuliaFormatter; format(".")'

clean:
	rm -rf docs/build/
	rm -rf docs/site/
	rm -rf .coverage/
	find . -name "*.cov" -type f -delete 