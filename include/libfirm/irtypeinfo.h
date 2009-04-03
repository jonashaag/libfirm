/*
 * Copyright (C) 1995-2008 University of Karlsruhe.  All right reserved.
 *
 * This file is part of libFirm.
 *
 * This file may be distributed and/or modified under the terms of the
 * GNU General Public License version 2 as published by the Free Software
 * Foundation and appearing in the file LICENSE.GPL included in the
 * packaging of this file.
 *
 * Licensees holding valid libFirm Professional Edition licenses may use
 * this file in accordance with the libFirm Commercial License.
 * Agreement provided with the Software.
 *
 * This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
 * WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE.
 */

/**
 * @file
 * @brief    Data structure to hold type information for nodes.
 * @author   Goetz Lindenmaier
 * @date     28.8.2003
 * @version  $Id$
 * @summary
 *   Data structure to hold type information for nodes.
 *
 *   This module defines a field "type" of type "type *" for each ir node.
 *   It defines a flag for irgraphs to mark whether the type info of the
 *   graph is valid.  Further it defines an auxiliary type "init_type".
 */
#ifndef FIRM_ANA_IRTYPEINFO_H
#define FIRM_ANA_IRTYPEINFO_H

#include "firm_types.h"

/* ------------ Auxiliary type. --------------------------------------- */

/** An auxiliary type used to express that a field is uninitialized.
 *
 *  This auxiliary type expresses that a field is uninitialized.  The
 *  variable is initialized by init_irtypeinfo().  The type is freed by
 *  free_irtypeinfo().
 */
extern ir_type *initial_type;



/* ------------ Initializing this module. ----------------------------- */

/** Initializes the type information module.
 *
 *  Initializes the type information module.
 *  Generates a type inititial_type and sets the type of all nodes to this type.
 *  Calling set/get_irn_typeinfo_type() is invalid before calling init. Requires memory
 *  in the order of MIN(<calls to set_irn_typeinfo_type>, #irnodes).
 */
void init_irtypeinfo(void);
void free_irtypeinfo(void);

/* ------------ Irgraph state handling. ------------------------------- */

typedef enum {
	ir_typeinfo_none,        /**< No typeinfo computed, calls to set/get_irn_typeinfo_type()
	                              are invalid. */
	ir_typeinfo_consistent,  /**< Type info valid, calls to set/get_irn_typeinfo_type() return
	                              the proper type. */
	ir_typeinfo_inconsistent /**< Type info can be accessed, but it can be invalid
	                              because of other transformations. */
} ir_typeinfo_state;

void              set_irg_typeinfo_state(ir_graph *irg, ir_typeinfo_state s);
ir_typeinfo_state get_irg_typeinfo_state(const ir_graph *irg);

/** Returns accumulated type information state information.
 *
 * Returns ir_typeinfo_consistent if the type information of all irgs is
 * consistent.  Returns ir_typeinfo_inconsistent if at least one irg has inconsistent
 * or no type information.  Returns ir_typeinfo_none if no irg contains type information.
 */
ir_typeinfo_state get_irp_typeinfo_state(void);
void              set_irp_typeinfo_state(ir_typeinfo_state s);
/** If typeinfo is consistent, sets it to inconsistent. */
void              set_irp_typeinfo_inconsistent(void);

/* ------------ Irnode type information. ------------------------------ */

/** Accessing the type information.
 *
 * These routines only work properly if the ir_graph is in state
 * ir_typeinfo_consistent or ir_typeinfo_inconsistent.  They
 * assume current_ir_graph set properly.
 */
ir_type *get_irn_typeinfo_type(const ir_node *n);
void    set_irn_typeinfo_type(ir_node *n, ir_type *tp);

#endif
