# Solving TSP using MIP

The code for `tsp.jl` is explained in my blog article on [opensourc.es](http://opensourc.es/blog/mip-tsp)

To run it you have to download [Julia](https://julialang.org/downloads/) and install [JuMP](https://github.com/JuliaOpt/JuMP.jl), [GLPK](http://www.gnu.org/software/glpk/) and [Distances](https://github.com/JuliaStats/Distances.jl). 

You can use 
```
Pkg.add("JuMP")
Pkg.add("GLPKMathProgInterface")
Pkg.add("Distances")
```

I visualized the problem using [d3](https://d3js.org).

