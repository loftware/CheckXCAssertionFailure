# LoftDataStructures_Bits

`Bits` projects any underlying collection of unsigned integers as a collection
of `Bool`, with each element of the `Bits` being true iff a corresponding bit in
one of the underlying collection's elements is set. A `Bits` is indexed using
`Int`s. Accessing the `n`th element of a `Bits` refers to the `n % wordSize`th
bit of the `n / wordSize`th element of the `base` collection.

The first bit of the collection corresponds to the highest order bit of the
first element of the base collection.