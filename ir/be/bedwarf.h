/*
 * This file is part of libFirm.
 * Copyright (C) 2012 University of Karlsruhe.
 */

/**
 * @file
 * @brief   Dwarf debug output support.
 * @author  Matthias Braun
 */
#ifndef FIRM_BE_BEDWARF_H
#define FIRM_BE_BEDWARF_H

#include "be_types.h"

typedef struct parameter_dbg_info_t {
	const ir_entity       *entity;
	const arch_register_t *reg;
} parameter_dbg_info_t;

/** initialize and open debug handle */
void be_dwarf_open(void);

/** close a debug handler. */
void be_dwarf_close(void);

/** start a compilation unit */
void be_dwarf_unit_begin(const char *filename);

/** end compilation unit */
void be_dwarf_unit_end(void);

/** output debug info necessary right before defining a function */
void be_dwarf_function_before(const ir_entity *ent,
                              const parameter_dbg_info_t *infos);

/** output debug info right before beginning to output assembly instructions */
void be_dwarf_function_begin(void);

/** debug for a function end */
void be_dwarf_function_end(void);

/** dump a variable in the global type */
void be_dwarf_variable(const ir_entity *ent);

/** Set "location" in the sourcefile corresponding to the following
 * assembly instructions */
void be_dwarf_location(dbg_info *dbgi);

/** Set base register and offset from base register that point to the CFA. */
void be_dwarf_callframe(const arch_register_t *reg, int offset);

/** Set offset from base register that points to the CFA. */
void be_dwarf_callframe_offset(int offset);

/**
 * Indicate at which offset (relative to the CFA) a callee-saved register has
 * been saved.
 */
void be_dwarf_callframe_spilloffset(const arch_register_t *reg, int offset);

/**
 * Indicate that a callee-saved register has been reloaded.
 */
void be_dwarf_same_value(const arch_register_t *reg);

#endif
