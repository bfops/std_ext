debug:
    dmd -debug -unittest -w -H -o- std_ext/math.d std_ext/traits.d std_ext/typetuple.d

release:
    dmd -release -inline -O -w -H -o- std_ext/math.d std_ext/traits.d std_ext/typetuple.d
