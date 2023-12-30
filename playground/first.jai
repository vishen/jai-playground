Basic :: #import "Basic";

My_Other_Other_Struct :: struct {
	i1: int;
}

My_Other_Struct :: struct {
	p1: *My_Other_Other_Struct;
	s1: string;
	b: [1024]u8;
}

My_Struct :: struct {
	p1: *My_Other_Struct;
	p2: *My_Other_Other_Struct;
}

main :: () {
	Basic.print("%\n", size_of(My_Other_Other_Struct));
	Basic.print("%\n", size_of(*My_Other_Other_Struct));
	Basic.print("%\n", size_of(My_Other_Struct));
	Basic.print("%\n", size_of(*My_Other_Struct));
	Basic.print("%\n", size_of(My_Struct));
}

/*
main :: () {
	x := 10;

	xs: [..] int;
	Basic.array_reserve(*xs, x);
	for 0..x  Basic.array_add(*xs, it);
	Basic.print("xs=%\n", xs);

	xsv := Basic.array_view(xs, 5);
	Basic.print("xsv=%\n", xsv);
}
*/

/*
main :: () {
	My_Struct :: struct {
		x: int;

		proc :: () {
			t := type_of(x);
			Basic.print("type_of(x) == %\n", t);
		}
	}

	s: My_Struct;
	s.proc();
}
*/

/*
main :: () {
	Basic.print("Hello, world\n");

	// There is a type called Any, which matches any other type in the language.
    // When the compiler is able, it creates an implicit conversion between the types.
    // You can see an explanation of this in 030_any.jai. For now let's just take for granted
    // that it happens.
    varargs_strings_and_ints :: (s: string = "Hello", i: int = 2, v: .. Any) {
        Basic.print("s is '%'; i is %.\n", s, i);

        // The type of v is [] Any.
        Basic.print("The type of v is %.\n", type_of(v));

        Basic.print("The values of v are:\n");
        for v {
			ti := type_info(type_of(it));
			Basic.print("    [%] % (%) (%)\n", it_index, it, type_of(it), << it.type);
		}

        Basic.print("\n");
    }

	varargs_strings_and_ints("What", 1, "is", "the", "matter", 9, 100, "dudes", 12000, "and dudettes", float);
}
*/
