# Notes in implementation

This page is a more in depth look into how some concepts were implemetes in the package. Although most of it is relatively straight forward for anyone with some familiarity with Julia, some parts may own a deeper explanation.

## Struct Methods

### Personal ramblings before content

Julia is not a OO language in the same way that Ruby, Python, or even C++ is. Although some form of concepts such as polymorphism or inheritance are integrated in the language, they do not behave in the same way an obejct oriented language would.

Another great example is how Julia opted in for multiple dispatch where methods are global and don't belong to a single class (or, in this case, a struct), contrary to languages like Python where a class methods exists and you can implement a method of class A in class B.

Those are different paradigms and that is fine.

However, as programmers, we have preferences, and I prefer to keep my option to what method to use just a dot away. In this section I will explain how it was done for anyone interested in an explanation (even though is a relatively simple one).

### "Struct-method"

Throught this package there are instances of sructs with methods directly associated with them. The functions they are correlated to were declared directly inside the struct. Doing so two things happen: 1) functions declared in this manner are accessible outside of the struct, you can call the method while referencing an instance of the struct, but never the method on it's own because the method is not defined in the global scope an `UndefVarError` will be thrown at runtime; 2) the "struct-method", as I will call it henceforth, will have access to all arguments of the struct as if they were local variables. Both of this topics will be explored, but first lets look at how a struct with methods is created

```julia
julia> import Base.@kwdef

julia> @kwdef struct St_with_anon_func
           ... #Any number of properties can be put here
           f = x -> x + 1
       end
```

There's a lot to unpack here, so lets go line by line.

In the first line we call `import Base.@kwdef`, that allow us to use the `@kwdef` macro. The docstring for this macro is as follows:

> This is a helper macro that automatically defines a keyword-based constructor for the type declared in the expression typedef, which must be a struct or mutable struct expression. The default argument is supplied by declaring fields of the form field::T = default or field = default. If no default is provided then the keyword argument becomes a required keyword argument in the resulting type constructor.

Meaning, we can have deafult value in structs when this macro is used. The importance of default values is that it allows us to apply to one of our properties of the struct a default value of a function as we will see next.

!!! note "Unexpected behaviour"
    The current version of `BrazilCentralBank` doesn't implement an inner-constructor for its structs. If you are planning on using `@kwdef` it on your projects know that some unexpected behavious may occur as well as some other not well defined behaviour when using this macro. For a more complete version check `@with_kw` from Parameters.jl

In the second line we call the `@kwdef` macro to our struct, and in the third line we see its effect. There we define the property such that `St().f` exists, but not only that, because of the keyword def macro we may assign to it a value, in this case a function, an anonynmous function. We can see its use in the following:

```julia
julia> st = St(...) #Any number of arguments can be passed here

julia> st.f(1)
2
```

The function `f` is a member of the struct `St` and it's instances, and because of that it is not accessible from outside of it. For example the first example works, but the second returns an error:

```julia
julia> st.f(1)
2

julia> f(1)
# ERROR: UndefVarError: `f` not defined
```

This behaviour can be quite useful in handling which method to be used. This approach is different from Julia's standard multiple dispatch approach (a system that, I must say, is excellent), and is probably a bit frowned upon in the Julia community. Regardless, I think is the best way for an end user to know what tools are avaliable to them, by listing every single one with just the touch of a dot.

However, in respect to Julia's core philosophy of multiple dispatch, both option are avaliable. You can call a method directly from a struct or as a function imported from the module directly as so:

```julia
julia> using BrazilCentralBank

julia> USD = getCurrency("USD")

julia> USD.getforexseries("EUR")
# OUTPUT

julia> gettimeseries(["USD", "EUR"]) # As of version 0.2.0 the gettimeseries function will be renamed to getforexseries
# OUTPUT
```

Throught this explanation I've used anonymous functions for when binding the struct value to a function, however is also possible to use a named function written outside of the declaration of the struct.

```julia
julia> import Base.@kwdef
julia> _f(x) = x + 1
julia> @kwdef struct St_with_out_func
           ... #Any number of properties can be put here
           f = x -> _f(x)
       end
```

Note that you still need to call it as a anonymous function. If it's not done, Julia will thrown an error because it will treat the declaration inside the struct `f = _f(x)` as f being equal to the result of `x` being applied to function `_f`, and because `x` is not defined an `UndefVarError` will be thrown.

An alternative to escape the anonymous functions declaration is declaring the function inside the body of the struct as such:

```julia
julia> import Base.@kwdef

julia> _f(x) = x + 1

julia> @kwdef struct St_with_inner_func
           ... #Any number of properties can be put here
           f = function f(x)
                   return x + 1
               end
       end
```

The above implementation is the one chosen for the BrazilCentralBank package.

### Performance tests

W.I.P.
