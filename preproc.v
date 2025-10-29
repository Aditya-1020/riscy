
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
 |                                                                            |
 |  Permission to use, copy, modify, and/or distribute this software for any  |
 |  purpose with or without fee is hereby granted, provided that the above    |
 |  copyright notice and this permission notice appear in all copies.         |
 |                                                                            |
 |  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES  |
 |  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF          |
 |  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR   |
 |  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    |
 |  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN     |
 |  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF   |
 |  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.            |
 |                                                                            |
 \----------------------------------------------------------------------------/

 Yosys 0.33 (git sha1 2584903a060)


-- Running command `read_verilog -E -sv rtl/instruction_mem.v' --

Syntax error in command `read_verilog -E -sv rtl/instruction_mem.v':

    read_verilog [options] [filename]

Load modules from a Verilog file to the current design. A large subset of
Verilog-2005 is supported.

    -sv
        enable support for SystemVerilog features. (only a small subset
        of SystemVerilog is supported)

    -formal
        enable support for SystemVerilog assertions and some Yosys extensions
        replace the implicit -D SYNTHESIS with -D FORMAL

    -nosynthesis
        don't add implicit -D SYNTHESIS

    -noassert
        ignore assert() statements

    -noassume
        ignore assume() statements

    -norestrict
        ignore restrict() statements

    -assume-asserts
        treat all assert() statements like assume() statements

    -assert-assumes
        treat all assume() statements like assert() statements

    -debug
        alias for -dump_ast1 -dump_ast2 -dump_vlog1 -dump_vlog2 -yydebug

    -dump_ast1
        dump abstract syntax tree (before simplification)

    -dump_ast2
        dump abstract syntax tree (after simplification)

    -no_dump_ptr
        do not include hex memory addresses in dump (easier to diff dumps)

    -dump_vlog1
        dump ast as Verilog code (before simplification)

    -dump_vlog2
        dump ast as Verilog code (after simplification)

    -dump_rtlil
        dump generated RTLIL netlist

    -yydebug
        enable parser debug output

    -nolatches
        usually latches are synthesized into logic loops
        this option prohibits this and sets the output to 'x'
        in what would be the latches hold condition

        this behavior can also be achieved by setting the
        'nolatches' attribute on the respective module or
        always block.

    -nomem2reg
        under certain conditions memories are converted to registers
        early during simplification to ensure correct handling of
        complex corner cases. this option disables this behavior.

        this can also be achieved by setting the 'nomem2reg'
        attribute on the respective module or register.

        This is potentially dangerous. Usually the front-end has good
        reasons for converting an array to a list of registers.
        Prohibiting this step will likely result in incorrect synthesis
        results.

    -mem2reg
        always convert memories to registers. this can also be
        achieved by setting the 'mem2reg' attribute on the respective
     