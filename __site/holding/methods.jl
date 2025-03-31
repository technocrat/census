# answer: include in core.jl? and do we need additional methods?
# Define methods for common operations
Base.string(pc::PostalCode) = pc.code
Base.show(io::IO, pc::PostalCode) = print(io, pc.code)
Base.:(==)(a::PostalCode, b::PostalCode) = a.code == b.code
Base.hash(pc::PostalCode, h::UInt) = hash(pc.code, h)