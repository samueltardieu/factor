/* relocation base of currently loaded image's data heap */
CELL data_relocation_base;

INLINE void data_fixup(CELL* cell)
{
	if(TAG(*cell) != FIXNUM_TYPE && *cell != F)
		*cell += (active.base - data_relocation_base);
}

typedef enum {
	/* arg is a primitive number */
	F_RELATIVE_PRIMITIVE,
	F_ABSOLUTE_PRIMITIVE,
	/* arg is an pointer in the literal table holding a tagged string */
	F_RELATIVE_DLSYM_SELF,
	F_ABSOLUTE_DLSYM_SELF,
	/* relocate an address to start of code heap */
	F_ABSOLUTE
} F_RELTYPE;

/* code relocation consists of a table of entries for each fixup */
typedef struct {
	F_RELTYPE type;
	CELL offset;
	CELL argument;
} F_REL;

CELL code_relocation_base;

INLINE void code_fixup(CELL* cell)
{
	*cell += (compiling.base - code_relocation_base);
}

void relocate_data();
void relocate_code();
