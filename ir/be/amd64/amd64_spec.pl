$arch = "amd64";

$mode_gp    = "mode_Lu";
$mode_flags = "mode_Iu";
$mode_xmm   = "amd64_mode_xmm";
$mode_x87   = "x86_mode_E";

%reg_classes = (
	gp => [
		{ name => "rax", dwarf => 0 },
		{ name => "rcx", dwarf => 2 },
		{ name => "rdx", dwarf => 1 },
		{ name => "rsi", dwarf => 4 },
		{ name => "rdi", dwarf => 5 },
		{ name => "rbx", dwarf => 3 },
		{ name => "rbp", dwarf => 6 },
		{ name => "rsp", dwarf => 7 },
		{ name => "r8",  dwarf => 8 },
		{ name => "r9",  dwarf => 9 },
		{ name => "r10", dwarf => 10 },
		{ name => "r11", dwarf => 11 },
		{ name => "r12", dwarf => 12 },
		{ name => "r13", dwarf => 13 },
		{ name => "r14", dwarf => 14 },
		{ name => "r15", dwarf => 15 },
		{ mode => $mode_gp }
	],
	flags => [
		{ name => "eflags", dwarf => 49 },
		{ mode => $mode_flags, flags => "manual_ra" }
	],
	xmm => [
		{ name => "xmm0",  dwarf => 17 },
		{ name => "xmm1",  dwarf => 18 },
		{ name => "xmm2",  dwarf => 19 },
		{ name => "xmm3",  dwarf => 20 },
		{ name => "xmm4",  dwarf => 21 },
		{ name => "xmm5",  dwarf => 22 },
		{ name => "xmm6",  dwarf => 23 },
		{ name => "xmm7",  dwarf => 24 },
		{ name => "xmm8",  dwarf => 25 },
		{ name => "xmm9",  dwarf => 26 },
		{ name => "xmm10", dwarf => 27 },
		{ name => "xmm11", dwarf => 28 },
		{ name => "xmm12", dwarf => 29 },
		{ name => "xmm13", dwarf => 30 },
		{ name => "xmm14", dwarf => 31 },
		{ name => "xmm15", dwarf => 32 },
		{ mode => $mode_xmm }
	],
	x87 => [
		{ name => "st0", realname => "st",    encoding => 0, dwarf => 11 },
		{ name => "st1", realname => "st(1)", encoding => 1, dwarf => 12 },
		{ name => "st2", realname => "st(2)", encoding => 2, dwarf => 13 },
		{ name => "st3", realname => "st(3)", encoding => 3, dwarf => 14 },
		{ name => "st4", realname => "st(4)", encoding => 4, dwarf => 15 },
		{ name => "st5", realname => "st(5)", encoding => 5, dwarf => 16 },
		{ name => "st6", realname => "st(6)", encoding => 6, dwarf => 17 },
		{ name => "st7", realname => "st(7)", encoding => 7, dwarf => 18 },
		{ mode => $mode_x87 }
	],
);

%custom_irn_flags = (
	commutative => "(arch_irn_flags_t)amd64_arch_irn_flag_commutative_binop",
);

%init_attr = (
	amd64_attr_t =>
		"init_amd64_attributes(res, irn_flags, in_reqs, n_res, op_mode);",
	amd64_addr_attr_t =>
		"init_amd64_attributes(res, irn_flags, in_reqs, n_res, op_mode);\n"
		."\tattr->size = size;\n"
		."\tattr->addr = addr;",
	amd64_binop_addr_attr_t =>
		"be_info_init_irn(res, irn_flags, in_reqs, n_res);\n"
		."\t*attr = *attr_init;",
	amd64_switch_jmp_attr_t =>
		"init_amd64_attributes(res, irn_flags, in_reqs, n_res, op_mode);\n"
		."\tattr->base.size = INSN_SIZE_64;\n"
		."\tattr->base.addr = *addr;\n"
		."\tinit_amd64_switch_attributes(res, table, table_entity);",
	amd64_cc_attr_t =>
		"init_amd64_attributes(res, irn_flags, in_reqs, n_res, AMD64_OP_CC);\n"
		."\tinit_amd64_cc_attributes(res, cc, size);",
	amd64_movimm_attr_t =>
		"init_amd64_attributes(res, irn_flags, in_reqs, n_res, AMD64_OP_IMM64);\n"
		."\tinit_amd64_movimm_attributes(res, size, imm);",
	amd64_shift_attr_t =>
		"be_info_init_irn(res, irn_flags, in_reqs, n_res);\n"
		."\t*attr = *attr_init;\n",
	amd64_call_addr_attr_t =>
		"be_info_init_irn(res, irn_flags, in_reqs, n_res);\n"
		."\t*attr = *attr_init;",
	amd64_x87_attr_t =>
		"init_amd64_attributes(res, irn_flags, in_reqs, n_res, AMD64_OP_X87);\n",
	amd64_x87_addr_attr_t =>
		"init_amd64_attributes(res, irn_flags, in_reqs, n_res, op_mode);\n"
		."\tattr->base.size = size;\n"
		."\tattr->base.addr = addr;\n",
	amd64_x87_binop_addr_attr_t =>
		"be_info_init_irn(res, irn_flags, in_reqs, n_res);\n"
		."\tattr->base = *attr_init;\n"
		."\tassert(attr_init->base.base.op_mode == AMD64_OP_ADDR_REG);\n"
		."\tattr->base.base.base.op_mode = AMD64_OP_X87_ADDR_REG;\n",
);

my $binop = {
	irn_flags => [ "modify_flags" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "gp", "flags", "mem" ],
	outs      => [ "res", "flags", "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
};

my $binop_commutative = {
	irn_flags => [ "modify_flags", "rematerializable", "commutative" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "gp", "flags", "mem" ],
	outs      => [ "res", "flags", "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
};

my $divop = {
	irn_flags => [ "modify_flags" ],
	state     => "pinned",
	in_reqs   => "...",
	out_reqs  => [ "rax", "flags", "mem", "rdx" ],
	outs      => [ "res_div", "flags", "M", "res_mod" ],
	attr_type => "amd64_addr_attr_t",
	fixed     => "amd64_addr_t addr = { .base_input = 0, .variant = X86_ADDR_REG };\n"
	            ."amd64_op_mode_t op_mode = AMD64_OP_REG;\n",
	attr      => "amd64_insn_size_t size",
};

my $mulop = {
	# Do not rematerialize this node
	# TODO: should mark this commutative as soon as the backend code
	#       can handle this special case
	# It produces 2 results and has strict constraints
	irn_flags => [ "modify_flags" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "rax", "flags", "mem", "rdx" ],
	outs      => [ "res_low", "flags", "M", "res_high" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
};

my $shiftop = {
	irn_flags => [ "modify_flags", "rematerializable" ],
	in_reqs   => "...",
	out_reqs  => [ "gp", "flags" ],
	outs      => [ "res", "flags" ],
	attr_type => "amd64_shift_attr_t",
	attr      => "const amd64_shift_attr_t *attr_init",
};

my $unop = {
	irn_flags => [ "modify_flags", "rematerializable" ],
	in_reqs   => [ "gp" ],
	out_reqs  => [ "in_r0", "flags" ],
	ins       => [ "val" ],
	outs      => [ "res", "flags" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size",
	fixed     => "amd64_op_mode_t op_mode = AMD64_OP_REG;\n"
	            ."amd64_addr_t addr = { .base_input = 0, .variant = X86_ADDR_REG };",
};

my $unop_out = {
	irn_flags => [ "modify_flags", "rematerializable" ],
	in_reqs   => "...",
	out_reqs  => [ "gp", "flags", "mem" ],
	outs      => [ "res", "flags", "M" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
};

my $binopx = {
	irn_flags => [ "rematerializable" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "xmm", "none", "mem" ],
	outs      => [ "res", "none", "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
};

my $binopx_commutative = {
	irn_flags => [ "rematerializable", "commutative" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "xmm", "none", "mem" ],
	outs      => [ "res", "none", "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
};

my $cvtop2x = {
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "xmm", "none", "mem" ],
	outs      => [ "res", "none", "M" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
};

my $cvtopx2i = {
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "gp", "none", "mem" ],
	outs      => [ "res", "none", "M" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
};

my $movopx = {
	state     => "exc_pinned",
	in_reqs   => "...",
	outs      => [ "res", "none", "M" ],
	out_reqs  => [ "xmm", "none", "mem" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_op_mode_t op_mode, amd64_addr_t addr",
};

my $x87const = {
	op_flags  => [ "constlike" ],
	irn_flags => [ "rematerializable" ],
	out_reqs  => [ "x87" ],
	outs      => [ "res" ],
	fixed     => "amd64_op_mode_t op_mode = AMD64_OP_X87;\n",
	mode      => $mode_x87,
};

my $x87unop = {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "x87" ],
	out_reqs  => [ "x87" ],
	ins       => [ "value" ],
	attr_type => "amd64_x87_attr_t",
	mode      => $mode_x87,
};

my $x87binop = {
	# TODO: AM variants
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "x87", "x87" ],
	out_reqs  => [ "x87" ],
	ins       => [ "left", "right" ],
	attr_type => "amd64_x87_attr_t",
	mode      => $mode_x87,
};

my $x87store = {
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "mem" ],
	outs      => [ "M" ],
	attr_type => "amd64_x87_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
	mode      => "mode_M",
};

%nodes = (
push_am => {
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "rsp:I", "mem" ],
	outs      => [ "stack", "M" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_addr_t addr",
	fixed     => "amd64_op_mode_t op_mode = AMD64_OP_ADDR;\n",
	emit      => "push%M %A",
},

push_reg => {
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => [ "rsp",   "mem", "gp"  ],
	ins       => [ "stack", "mem", "val" ],
	out_reqs  => [ "rsp:I", "mem" ],
	outs      => [ "stack", "M"   ],
	fixed     => "amd64_op_mode_t op_mode = AMD64_OP_NONE;\n",
	emit      => "pushq %^S2",
},

pop_am => {
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "rsp:I", "mem" ],
	outs      => [ "stack", "M" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_addr_t addr",
	fixed     => "amd64_op_mode_t op_mode = AMD64_OP_ADDR;\n",
	emit      => "pop%M %A",
},

sub_sp => {
	irn_flags => [ "modify_flags" ],
	state     => "pinned",
	in_reqs   => "...",
	out_reqs  => [ "rsp:I", "gp", "mem" ],
	ins       => [ "stack" ],
	outs      => [ "stack", "addr", "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
	emit      => "subq %AM\n".
	             "movq %%rsp, %D1",
},

leave => {
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => [ "rbp", "mem" ],
	out_reqs  => [ "rbp:I", "mem", "rsp:I" ],
	outs      => [ "frame", "M",   "stack" ],
	fixed     => "amd64_op_mode_t op_mode = AMD64_OP_NONE;\n",
	emit      => "leave",
},

add => {
	template => $binop_commutative,
	emit     => "add%M %AM",
},

and => {
	template => $binop_commutative,
	emit     => "and%M %AM",
},

div => {
	template => $divop,
	emit     => "div%M %AM",
},

idiv => {
	template => $divop,
	emit     => "idiv%M %AM",
},

imul => {
	template => $binop_commutative,
	emit     => "imul%M %AM",
},

imul_1op => {
	template => $mulop,
	emit     => "imul%M %AM",
},

mul => {
	template => $mulop,
	emit     => "mul%M %AM",
},

or => {
	template => $binop_commutative,
	emit     => "or%M %AM",
},

shl => {
	template => $shiftop,
	emit     => "shl%MS %SO",
},

shr => {
	template => $shiftop,
	emit     => "shr%MS %SO",
},

sar => {
	template => $shiftop,
	emit     => "sar%MS %SO",
},

sub => {
	template  => $binop,
	irn_flags => [ "modify_flags", "rematerializable" ],
	emit      => "sub%M %AM",
},

sbb => {
	template => $binop,
	emit     => "sbb%M %AM",
},

neg => {
	template => $unop,
	emit     => "neg%M %AM",
},

not => {
	template => $unop,
	emit     => "not%M %AM",
},

xor => {
	template => $binop_commutative,
	emit     => "xor%M %AM",
},

xor_0 => {
	op_flags  => [ "constlike" ],
	irn_flags => [ "modify_flags", "rematerializable" ],
	out_reqs  => [ "gp", "flags" ],
	outs      => [ "res", "flags" ],
	fixed     => "amd64_op_mode_t op_mode = AMD64_OP_NONE;",
	emit      => "xorl %3D0, %3D0",
},

mov_imm => {
	op_flags  => [ "constlike" ],
	irn_flags => [ "rematerializable" ],
	out_reqs  => [ "gp" ],
	outs      => [ "res" ],
	attr_type => "amd64_movimm_attr_t",
	attr      => "amd64_insn_size_t size, const amd64_imm64_t *imm",
	emit      => 'mov%MM $%C, %D0',
},

movs => {
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "gp", "none", "mem" ],
	outs      => [ "res", "unused", "M" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
	emit      => "movs%Mq %AM, %^D0",
},

mov_gp => {
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "gp", "none", "mem" ],
	outs      => [ "res", "unused", "M" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
},

ijmp => {
	state     => "pinned",
	op_flags  => [ "cfopcode", "unknown_jump" ],
	in_reqs   => "...",
	out_reqs  => [ "exec", "none", "mem" ],
	outs      => [ "X", "unused", "M" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
	emit      => "jmp %*AM",
},

jmp => {
	state    => "pinned",
	op_flags => [ "cfopcode" ],
	out_reqs => [ "exec" ],
	fixed    => "amd64_op_mode_t op_mode = AMD64_OP_NONE;",
},

cmp => {
	irn_flags => [ "modify_flags", "rematerializable" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "none", "flags", "mem" ],
	outs      => [ "dummy", "flags", "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
	emit      => "cmp%M %AM",
},

cmpxchg => {
	irn_flags => [ "modify_flags" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "rax", "flags", "mem" ],
	outs      => [ "res", "flags", "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
	emit      => "lock cmpxchg%M %AM",
},

# TODO Setcc can also operate on memory
setcc => {
	irn_flags => [  ],
	in_reqs   => [ "eflags" ],
	out_reqs  => [ "gp" ],
	ins       => [ "eflags" ],
	outs      => [ "res" ],
	attr_type => "amd64_cc_attr_t",
	attr      => "x86_condition_code_t cc",
	fixed     => "amd64_insn_size_t size = INSN_SIZE_8;",
	emit      => "set%P0 %D0",
},

lea => {
	irn_flags => [ "rematerializable" ],
	in_reqs   => "...",
	outs      => [ "res" ],
	out_reqs  => [ "gp" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_addr_t addr",
	fixed     => "amd64_op_mode_t op_mode = AMD64_OP_ADDR;\n",
	emit      => "lea%M %A, %D0",
},

jcc => {
	state     => "pinned",
	op_flags  => [ "cfopcode", "forking" ],
	in_reqs   => [ "eflags" ],
	out_reqs  => [ "exec", "exec" ],
	ins       => [ "eflags" ],
	outs      => [ "false", "true" ],
	attr_type => "amd64_cc_attr_t",
	attr      => "x86_condition_code_t cc",
	fixed     => "amd64_insn_size_t size = INSN_SIZE_64;",
},

mov_store => {
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "mem" ],
	outs      => [ "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
	emit      => "mov%M %AM",
},

jmp_switch => {
	op_flags  => [ "cfopcode", "forking" ],
	state     => "pinned",
	in_reqs   => "...",
	out_reqs  => "...",
	attr_type => "amd64_switch_jmp_attr_t",
	attr      => "amd64_op_mode_t op_mode, const amd64_addr_t *addr, const ir_switch_table *table, ir_entity *table_entity",
},

call => {
	op_flags  => [ "uses_memory", "fragile" ],
	irn_flags => [ "modify_flags" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => "...",
	ins       => [ "mem", "stack" ],
	outs      => [ "mem", "stack", "flags", "X_regular", "X_except", "first_result" ],
	attr_type => "amd64_call_addr_attr_t",
	attr      => "const amd64_call_addr_attr_t *attr_init",
},

ret => {
	state    => "pinned",
	op_flags => [ "cfopcode" ],
	in_reqs  => "...",
	out_reqs => [ "exec" ],
	ins      => [ "mem", "stack", "first_result" ],
	fixed    => "amd64_op_mode_t op_mode = AMD64_OP_NONE;\n",
	emit     => "ret",
},

bsf => {
	template => $unop_out,
	emit => "bsf%M %AM, %D0",
},

bsr => {
	template => $unop_out,
	emit => "bsr%M %AM, %D0",
},

# SSE

adds => {
	template => $binopx_commutative,
	emit     => "adds%MX %AM",
},

divs => {
	template => $binopx,
	emit     => "divs%MX %AM",
},

movs_xmm => {
	template => $movopx,
	attr     => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
	emit     => "movs%MX %AM, %D0",
},

muls => {
	template => $binopx_commutative,
	emit     => "muls%MX %AM",
},

movs_store_xmm => {
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "mem" ],
	outs      => [ "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
	emit      => "movs%MX %^S0, %A",
},

subs => {
	template => $binopx,
	emit     => "subs%MX %AM",
},

ucomis => {
	irn_flags => [ "modify_flags", "rematerializable" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "none", "flags", "mem" ],
	outs      => [ "dummy", "flags", "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
	emit      => "ucomis%MX %AM",
},

xorpd_0 => {
	op_flags  => [ "constlike" ],
	irn_flags => [ "rematerializable" ],
	out_reqs  => [ "xmm" ],
	outs      => [ "res" ],
	fixed     => "amd64_op_mode_t op_mode = AMD64_OP_NONE;",
	emit      => "xorpd %^D0, %^D0",
},

xorp => {
	template => $binopx_commutative,
	emit     => "xorp%MX %AM",
},

movd_xmm_gp => {
	state     => "exc_pinned",
	ins       => [ "operand" ],
	outs      => [ "res" ],
	in_reqs   => [ "xmm" ],
	out_reqs  => [ "gp" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
	emit      => "movd %S0, %D0"
},

movd_gp_xmm => {
	state     => "exc_pinned",
	ins       => [ "operand" ],
	outs      => [ "res" ],
	in_reqs   => [ "gp" ],
	out_reqs  => [ "xmm" ],
	attr_type => "amd64_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
	emit      => "movd %S0, %D0"
},

# Conversion operations

cvtss2sd => {
	template => $cvtop2x,
	emit     => "cvtss2sd %AM, %^D0",
},

cvtsd2ss => {
	template => $cvtop2x,
	attr     => "amd64_op_mode_t op_mode, amd64_addr_t addr",
	fixed    => "amd64_insn_size_t size = INSN_SIZE_64;\n",
	emit     => "cvtsd2ss %AM, %^D0",
},

cvttsd2si => {
	template => $cvtopx2i,
	emit     => "cvttsd2si %AM, %D0",
},

cvttss2si => {
	template => $cvtopx2i,
	emit     => "cvttss2si %AM, %D0",
},

cvtsi2ss => {
	template => $cvtop2x,
	emit     => "cvtsi2ss %AM, %^D0",
},

cvtsi2sd => {
	template => $cvtop2x,
	emit     => "cvtsi2sd %AM, %^D0",
},

movq => {
	template => $movopx,
	fixed    => "amd64_insn_size_t size = INSN_SIZE_64;\n",
	emit     => "movq %AM, %D0",
},

movdqa => {
	template => $movopx,
	fixed    => "amd64_insn_size_t size = INSN_SIZE_128;\n",
	emit     => "movdqa %AM, %D0",
},

movdqu => {
	template => $movopx,
	fixed    => "amd64_insn_size_t size = INSN_SIZE_128;\n",
	emit     => "movdqu %AM, %D0",
},

movdqu_store => {
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "mem" ],
	outs      => [ "M" ],
	attr_type => "amd64_binop_addr_attr_t",
	attr      => "const amd64_binop_addr_attr_t *attr_init",
	emit      => "movdqu %^S0, %A",
},

l_punpckldq => {
	ins       => [ "arg0", "arg1" ],
	outs      => [ "res" ],
	attr_type => "",
	dump_func => "NULL",
	mode      => $mode_xmm,
},

l_subpd => {
	ins       => [ "arg0", "arg1" ],
	outs      => [ "res" ],
	attr_type => "",
	dump_func => "NULL",
	mode      => $mode_xmm,
},

l_haddpd => {
	ins       => [ "arg0", "arg1" ],
	outs      => [ "res" ],
	attr_type => "",
	dump_func => "NULL",
	mode      => $mode_xmm,
},

punpckldq => {
	template => $binopx,
	emit     => "punpckldq %AM",
},

subpd => {
	template => $binopx,
	emit     => "subpd %AM",
},

haddpd => {
	template => $binopx,
	emit     => "haddpd %AM",
},

fldz => {
	template => $x87const,
	emit     => "fldz",
},

fld1 => {
	template => $x87const,
	emit     => "fld1",
},

fld => {
	irn_flags => [ "rematerializable" ],
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "x87", "none", "mem" ],
	outs      => [ "res", "unused", "M" ],
	attr_type => "amd64_x87_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
	emit      => "fld%FM %AM",
},

fild => {
	irn_flags => [ "rematerializable" ],
	op_flags  => [ "uses_memory" ],
	state     => "exc_pinned",
	in_reqs   => "...",
	out_reqs  => [ "x87", "none", "mem" ],
	outs      => [ "res", "unused", "M" ],
	attr_type => "amd64_x87_addr_attr_t",
	attr      => "amd64_insn_size_t size, amd64_op_mode_t op_mode, amd64_addr_t addr",
	emit      => "fild%M %AM",
},

fisttp => {
	template => $x87store,
	emit     => "fisttp%M %AM",
},

fst => {
	template => $x87store,
	emit     => "fst%FP%FM %AM",
},

fstp => {
	template => $x87store,
	emit     => "fstp%FM %AM",
},

fadd => {
	template => $x87binop,
	emit     => "fadd%FP %AF",
},

fdiv => {
	template => $x87binop,
	emit     => "fdiv%FR%FP %AF",
},

fmul => {
	template => $x87binop,
	emit     => "fmul%FP %AF",
},

fsub => {
	template => $x87binop,
	emit     => "fsub%FR%FP %AF",
},

fchs => {
	template => $x87unop,
	emit     => "fchs",
},

fucomi => {
	irn_flags => [ "rematerializable" ],
	in_reqs   => [ "x87", "x87" ],
	out_reqs  => [ "flags" ],
	ins       => [ "left", "right" ],
	outs      => [ "flags" ],
	attr_type => "amd64_x87_attr_t",
	emit      => "fucom%FPi %F0",
},

fdup => {
	in_reqs     => [ "x87" ],
	out_reqs    => [ "x87" ],
	ins         => [ "val" ],
	attrs_equal => "attrs_equal_false",
	attr_type   => "amd64_x87_attr_t",
	attr        => "const arch_register_t *reg",
	init        => "attr->x87.reg = reg;",
	emit        => "fld %F0",
},

fxch => {
	op_flags    => [ "keep" ],
	out_reqs    => [ "none" ],
	attrs_equal => "attrs_equal_false",
	attr_type   => "amd64_x87_attr_t",
	attr        => "const arch_register_t *reg",
	init        => "attr->x87.reg = reg;",
	emit        => "fxch %F0",
},

fpop => {
	op_flags    => [ "keep" ],
	out_reqs    => [ "none" ],
	attrs_equal => "attrs_equal_false",
	attr_type   => "amd64_x87_attr_t",
	attr        => "const arch_register_t *reg",
	init        => "attr->x87.reg = reg;",
	emit        => "fstp %F0",
},

);
