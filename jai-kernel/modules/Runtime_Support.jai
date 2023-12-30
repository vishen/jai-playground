#module_parameters(ENABLE_BACKTRACE_ON_CRASH: bool);

/*
// @Cleanup: __element_duplicate should lose its c_call status, and also be faster...!
__element_duplicate :: (start: *u8, num_elements: s64, size: s64) #c_call #no_aoc {
    cursor := start + size;
    for 1..num_elements-1 {
        memcpy(cursor, start, size);
        cursor += size;
    }
}
__panic_due_to_runtime_call_of_compile_time_procedure :: (line_number: s64, filename: *u8) #no_context {

}

__array_bounds_check_fail :: (index: s64, limit: s64, line_number: s64, filename: *u8) #no_context {
}
*/

Empty :: struct {

}

// @Volatile: Context_Base must match internal compiler settings in general.h
// It must exist and be relatively easy to compile (without requiring #run of
// procedures, for example). Context_Base is going to be annoying to edit because
// if you make an error of some kind, even a simple one like an undeclared identifier,
// you won't get a helpful error message. 
Context_Base :: struct {
    // context_info:  *Type_Info_Struct; // Allow libs or DLLs to see what context we are passing them.
    context_info:  *Empty; // Allow libs or DLLs to see what context we are passing them.

    thread_index   : u32;

    allocator      := default_allocator;

    logger         := runtime_support_default_logger;
    logger_data    :  *void;
    log_source_identifier: u64;      // Arbitrary identifier; settable by the main program.
    // log_level      :  Log_Level;     // Settable by the main program to inform anyone who logs.
    log_level      :  u8;     // Settable by the main program to inform anyone who logs.

    // temporary_storage: *Temporary_Storage;
    temporary_storage: *Empty;

    // Currently, for simplicity we don't #if this out right now when _STACK_TRACE is false;
    // initially an implementation detail prevented us from doing this, but now that's gone,
    // but to be conservative we aren't changing this yet (but may later). It is probably
    // convenient to let runtime code be able to check context.stack_trace to see if it is
    // null in some cases, rather than needing all that to be #iffed as well. We will see.
    // stack_trace: *Stack_Trace_Node;
    stack_trace: *Empty;

    // assertion_failed := runtime_support_assertion_failed;
    assertion_failed := false;
    handling_assertion_failure := false;  // Used to avoid assert() infinite loops. Do not mess with this value.

    program_print_plugin: *void;  // This is a dumb field that will go away when we have a better alternative.

    default_allocator :: Allocator.{runtime_support_default_allocator_proc, null};
	// default_allocator :: Empty;
}

Default_Allocator :: #import,file "./Default_Allocator.jai";

runtime_support_default_allocator_proc :: Default_Allocator.allocator_proc;

runtime_support_default_logger :: (message: string, data: *void, info: Log_Info) {
    if !message then return;
}

