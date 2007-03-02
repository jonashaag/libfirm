/**
 * This file implements the creation of the achitecture specific firm opcodes
 * and the coresponding node constructors for the TEMPLATE assembler irg.
 * $Id$
 */
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#ifdef _WIN32
#include <malloc.h>
#else
#include <alloca.h>
#endif

#include <stdlib.h>

#include "irprog_t.h"
#include "irgraph_t.h"
#include "irnode_t.h"
#include "irmode_t.h"
#include "ircons_t.h"
#include "iropt_t.h"
#include "irop.h"
#include "firm_common_t.h"
#include "irvrfy_t.h"
#include "irprintf.h"

#include "../bearch.h"

#include "TEMPLATE_nodes_attr.h"
#include "TEMPLATE_new_nodes.h"
#include "gen_TEMPLATE_regalloc_if.h"



/***********************************************************************************
 *      _                                   _       _             __
 *     | |                                 (_)     | |           / _|
 *   __| |_   _ _ __ ___  _ __   ___ _ __   _ _ __ | |_ ___ _ __| |_ __ _  ___ ___
 *  / _` | | | | '_ ` _ \| '_ \ / _ \ '__| | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \
 * | (_| | |_| | | | | | | |_) |  __/ |    | | | | | ||  __/ |  | || (_| | (_|  __/
 *  \__,_|\__,_|_| |_| |_| .__/ \___|_|    |_|_| |_|\__\___|_|  |_| \__,_|\___\___|
 *                       | |
 *                       |_|
 ***********************************************************************************/

/**
 * Returns a string containing the names of all registers within the limited bitset
 */
static char *get_limited_regs(const arch_register_req_t *req, char *buf, int max) {
	bitset_t *bs   = bitset_alloca(req->cls->n_regs);
	char     *p    = buf;
	int       size = 0;
	int       i, cnt;

	req->limited(NULL, bs);

	for (i = 0; i < req->cls->n_regs; i++) {
		if (bitset_is_set(bs, i)) {
			cnt = snprintf(p, max - size, " %s", req->cls->regs[i].name);
			if (cnt < 0) {
				fprintf(stderr, "dumper problem, exiting\n");
				exit(1);
			}

			p    += cnt;
			size += cnt;

			if (size >= max)
				break;
		}
	}

	return buf;
}

/**
 * Dumps the register requirements for either in or out.
 */
static void dump_reg_req(FILE *F, ir_node *n, const TEMPLATE_register_req_t **reqs, int inout) {
	char *dir = inout ? "out" : "in";
	int   max = inout ? get_TEMPLATE_n_res(n) : get_irn_arity(n);
	char *buf = alloca(1024);
	int   i;

	memset(buf, 0, 1024);

	if (reqs) {
		for (i = 0; i < max; i++) {
			fprintf(F, "%sreq #%d =", dir, i);

			if (reqs[i]->req.type == arch_register_req_type_none) {
				fprintf(F, " n/a");
			}

			if (reqs[i]->req.type & arch_register_req_type_normal) {
				fprintf(F, " %s", reqs[i]->req.cls->name);
			}

			if (reqs[i]->req.type & arch_register_req_type_limited) {
				fprintf(F, " %s", get_limited_regs(&reqs[i]->req, buf, 1024));
			}

			if (reqs[i]->req.type & arch_register_req_type_should_be_same) {
				ir_fprintf(F, " same as %+F", get_irn_n(n, reqs[i]->same_pos));
			}

			if (reqs[i]->req.type & arch_register_req_type_should_be_different) {
				ir_fprintf(F, " different from %+F", get_irn_n(n, reqs[i]->different_pos));
			}

			fprintf(F, "\n");
		}

		fprintf(F, "\n");
	}
	else {
		fprintf(F, "%sreq = N/A\n", dir);
	}
}


/**
 * Dumper interface for dumping TEMPLATE nodes in vcg.
 * @param n        the node to dump
 * @param F        the output file
 * @param reason   indicates which kind of information should be dumped
 * @return 0 on success or != 0 on failure
 */
static int TEMPLATE_dump_node(ir_node *n, FILE *F, dump_reason_t reason) {
  	ir_mode     *mode = NULL;
	int          bad  = 0;
	int          i;
	TEMPLATE_attr_t *attr;
	const TEMPLATE_register_req_t **reqs;
	const arch_register_t     **slots;

	switch (reason) {
		case dump_node_opcode_txt:
			fprintf(F, "%s", get_irn_opname(n));
			break;

		case dump_node_mode_txt:
			mode = get_irn_mode(n);

			if (mode) {
				fprintf(F, "[%s]", get_mode_name(mode));
			}
			else {
				fprintf(F, "[?NOMODE?]");
			}
			break;

		case dump_node_nodeattr_txt:

			/* TODO: dump some attributes which should show up */
			/* in node name in dump (e.g. consts or the like)  */

			break;

		case dump_node_info_txt:
			attr = get_TEMPLATE_attr(n);
			fprintf(F, "=== TEMPLATE attr begin ===\n");

			/* dump IN requirements */
			if (get_irn_arity(n) > 0) {
				reqs = get_TEMPLATE_in_req_all(n);
				dump_reg_req(F, n, reqs, 0);
			}

			/* dump OUT requirements */
			if (attr->n_res > 0) {
				reqs = get_TEMPLATE_out_req_all(n);
				dump_reg_req(F, n, reqs, 1);
			}

			/* dump assigned registers */
			slots = get_TEMPLATE_slots(n);
			if (slots && attr->n_res > 0) {
				for (i = 0; i < attr->n_res; i++) {
					if (slots[i]) {
						fprintf(F, "reg #%d = %s\n", i, slots[i]->name);
					}
					else {
						fprintf(F, "reg #%d = n/a\n", i);
					}
				}
			}
			fprintf(F, "\n");

			/* dump n_res */
			fprintf(F, "n_res = %d\n", get_TEMPLATE_n_res(n));

			/* dump flags */
			fprintf(F, "flags =");
			if (attr->flags == arch_irn_flags_none) {
				fprintf(F, " none");
			}
			else {
				if (attr->flags & arch_irn_flags_dont_spill) {
					fprintf(F, " unspillable");
				}
				if (attr->flags & arch_irn_flags_rematerializable) {
					fprintf(F, " remat");
				}
				if (attr->flags & arch_irn_flags_ignore) {
					fprintf(F, " ignore");
				}
			}
			fprintf(F, " (%d)\n", attr->flags);

			/* TODO: dump all additional attributes */

			fprintf(F, "=== TEMPLATE attr end ===\n");
			/* end of: case dump_node_info_txt */
			break;
	}


	return bad;
}



/***************************************************************************************************
 *        _   _                   _       __        _                    _   _               _
 *       | | | |                 | |     / /       | |                  | | | |             | |
 *   __ _| |_| |_ _ __   ___  ___| |_   / /_ _  ___| |_   _ __ ___   ___| |_| |__   ___   __| |___
 *  / _` | __| __| '__| / __|/ _ \ __| / / _` |/ _ \ __| | '_ ` _ \ / _ \ __| '_ \ / _ \ / _` / __|
 * | (_| | |_| |_| |    \__ \  __/ |_ / / (_| |  __/ |_  | | | | | |  __/ |_| | | | (_) | (_| \__ \
 *  \__,_|\__|\__|_|    |___/\___|\__/_/ \__, |\___|\__| |_| |_| |_|\___|\__|_| |_|\___/ \__,_|___/
 *                                        __/ |
 *                                       |___/
 ***************************************************************************************************/

/**
 * Wraps get_irn_generic_attr() as it takes no const ir_node, so we need to do a cast.
 * Firm was made by people hating const :-(
 */
TEMPLATE_attr_t *get_TEMPLATE_attr(const ir_node *node) {
	assert(is_TEMPLATE_irn(node) && "need TEMPLATE node to get attributes");
	return (TEMPLATE_attr_t *)get_irn_generic_attr((ir_node *)node);
}

/**
 * Returns the argument register requirements of a TEMPLATE node.
 */
const TEMPLATE_register_req_t **get_TEMPLATE_in_req_all(const ir_node *node) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);
	return attr->in_req;
}

/**
 * Returns the result register requirements of an TEMPLATE node.
 */
const TEMPLATE_register_req_t **get_TEMPLATE_out_req_all(const ir_node *node) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);
	return attr->out_req;
}

/**
 * Returns the argument register requirement at position pos of an TEMPLATE node.
 */
const TEMPLATE_register_req_t *get_TEMPLATE_in_req(const ir_node *node, int pos) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);
	return attr->in_req[pos];
}

/**
 * Returns the result register requirement at position pos of an TEMPLATE node.
 */
const TEMPLATE_register_req_t *get_TEMPLATE_out_req(const ir_node *node, int pos) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);
	return attr->out_req[pos];
}

/**
 * Sets the OUT register requirements at position pos.
 */
void set_TEMPLATE_req_out(ir_node *node, const TEMPLATE_register_req_t *req, int pos) {
	TEMPLATE_attr_t *attr   = get_TEMPLATE_attr(node);
	attr->out_req[pos] = req;
}

/**
 * Sets the IN register requirements at position pos.
 */
void set_TEMPLATE_req_in(ir_node *node, const TEMPLATE_register_req_t *req, int pos) {
	TEMPLATE_attr_t *attr  = get_TEMPLATE_attr(node);
	attr->in_req[pos] = req;
}

/**
 * Returns the register flag of an TEMPLATE node.
 */
arch_irn_flags_t get_TEMPLATE_flags(const ir_node *node) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);
	return attr->flags;
}

/**
 * Sets the register flag of an TEMPLATE node.
 */
void set_TEMPLATE_flags(const ir_node *node, arch_irn_flags_t flags) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);
	attr->flags      = flags;
}

/**
 * Returns the result register slots of an TEMPLATE node.
 */
const arch_register_t **get_TEMPLATE_slots(const ir_node *node) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);
	return attr->slots;
}

/**
 * Returns the name of the OUT register at position pos.
 */
const char *get_TEMPLATE_out_reg_name(const ir_node *node, int pos) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);

	assert(is_TEMPLATE_irn(node) && "Not an TEMPLATE node.");
	assert(pos < attr->n_res && "Invalid OUT position.");
	assert(attr->slots[pos]  && "No register assigned");

	return arch_register_get_name(attr->slots[pos]);
}

/**
 * Returns the index of the OUT register at position pos within its register class.
 */
int get_TEMPLATE_out_regnr(const ir_node *node, int pos) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);

	assert(is_TEMPLATE_irn(node) && "Not an TEMPLATE node.");
	assert(pos < attr->n_res && "Invalid OUT position.");
	assert(attr->slots[pos]  && "No register assigned");

	return arch_register_get_index(attr->slots[pos]);
}

/**
 * Returns the OUT register at position pos.
 */
const arch_register_t *get_TEMPLATE_out_reg(const ir_node *node, int pos) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);

	assert(is_TEMPLATE_irn(node) && "Not an TEMPLATE node.");
	assert(pos < attr->n_res && "Invalid OUT position.");
	assert(attr->slots[pos]  && "No register assigned");

	return attr->slots[pos];
}

/**
 * Sets the number of results.
 */
void set_TEMPLATE_n_res(ir_node *node, int n_res) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);
	attr->n_res      = n_res;
}

/**
 * Returns the number of results.
 */
int get_TEMPLATE_n_res(const ir_node *node) {
	TEMPLATE_attr_t *attr = get_TEMPLATE_attr(node);
	return attr->n_res;
}



/***************************************************************************************
 *                  _                            _                   _
 *                 | |                          | |                 | |
 *  _ __   ___   __| | ___    ___ ___  _ __  ___| |_ _ __ _   _  ___| |_ ___  _ __ ___
 * | '_ \ / _ \ / _` |/ _ \  / __/ _ \| '_ \/ __| __| '__| | | |/ __| __/ _ \| '__/ __|
 * | | | | (_) | (_| |  __/ | (_| (_) | | | \__ \ |_| |  | |_| | (__| || (_) | |  \__ \
 * |_| |_|\___/ \__,_|\___|  \___\___/|_| |_|___/\__|_|   \__,_|\___|\__\___/|_|  |___/
 *
 ***************************************************************************************/

/* Include the generated constructor functions */
#include "gen_TEMPLATE_new_nodes.c.inl"
