kernel_main :: () {
	// write_string("Hello, OS\n");
	add :: (n1: int, n2: int) -> int {
		return n1 + n2;
	}
	result := add(5, 6);

	// TODO:
	// mov dword [0xb8140], 0x2f4b2f4f
	// hlt
}

KERNEL_MAIN_ENTRYPOINT :: #string DONE
#program_export
kernel_main_entrypoint :: () #no_context {
	// kernel_main();
	// write_string("Hello, OS\n");
	x := 5 + 6;

	// TODO:
	// mov dword [0xb8140], 0x2f4b2f4f
	// hlt
}
DONE
	
#run {
	#import "Compiler";
	#import "Basic";

	// This metaprogram should not generate an output
	set_build_options_dc(.{do_output=false});

	{
		w := compiler_create_workspace("kernel");

		options := get_build_options(w);
		copy_commonly_propagated_fields(get_build_options(), *options);

		options.output_executable_name = "jai-kernel";
		options.backend                           = .LLVM;
		options.output_type = .OBJECT_FILE;
		// options.output_type                       = .STATIC_LIBRARY;
		options.stack_trace = false;
		options.backtrace_on_crash   = .OFF;
		// options.os_target = .LINUX;
		//options.os_target = .KRAMPOS;
		options.os_target = .NONE;
		options.cpu_target = .X64;
		options.emit_debug_info = .NONE;
		set_optimization(*options, .DEBUG);

		import_paths: [..]string;
		// Add our own modules folder first so that we can override modules with our own version, if necessary.
		array_add(*import_paths, tprint("%modules", #filepath));
		for options.import_path array_add(*import_paths, it);
		options.import_path = import_paths;

		set_build_options(options, w);

		compiler_begin_intercept(w);

        add_build_string(KERNEL_MAIN_ENTRYPOINT, w);

		// remap_import(w, "*", "Default_Allocator", "Walloc");
		Basic :: #import "Basic";
		// add_build_file("main.jai", w);
		while true {
			message := compiler_wait_for_message();
			assert(message.workspace == w);

			Basic.print("message: %\n",<< message);
			if message.kind == {
			case .COMPLETE; 
				// msg := xx (<< message);
				msg := cast(*Message_Complete) message;
				Basic.print("msg=%, (%)\n", << msg, type_of(msg));
				break;
			}
		}

		compiler_end_intercept(w);

	}
}
