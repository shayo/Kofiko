#include "param.h"

typedef struct entry_t {
	int t;
	char *name;
	void *addr;
	struct entry_t *next;
} entry;


entry *top, *bottom;
int argc;
char **argv;
extern char HelpString[];

char help = 0;

/* returns 1 if the parameter was found and changed, else zero. */
int change_param(char *name, char *value)
{
	entry *e;
	int changed = 0;

	for(e=bottom; e; e = e->next) if (!strcmp(name, e->name)) {
		switch (e->t) {
		case FLOAT:
			*((float *) e->addr) = atof(value); break;
		case INT: 
			*((int *) e->addr) = atoi(value); break;
		case BOOLEAN: 
			if (*value == '0')
				*((char *) e->addr) = 0;
			else
				*((char *) e->addr) = 1;
			break;
		case STRING: 
			strncpy((char *)e->addr, value, STRLEN); break;
		}
		changed = 1;
		break;
	}
	return changed;
}

void init_params(int ac, char **av)
{
	argc = ac;
	argv = av;
}

void search_command_line(char *name)
{
	int i;

	for(i=0; i<argc-1; i++)
		if (argv[i][0] == '-' && !strcmp(argv[i]+1, name))
			change_param(argv[i] + 1, argv[i+1]);
	if (argv[argc-1][0] == '-' && !strcmp(argv[argc-1]+1, name))
		change_param(argv[argc-1] + 1, "");
}

void add_param(int t, char *name, void *addr)
{
	entry *e;
	if (top == NULL) {
		bottom = top = e = (entry *) malloc(sizeof(entry));
	} else {
		e = (entry *) malloc(sizeof(entry));
		top->next = e;
		top = e;
	}
	if (e == NULL) {printf("parameter manager out of memory!\n"); exit(1);}
	top->t = t;
	top->name = name;
	top->addr = addr;
	top->next = NULL;
	search_command_line(name);
}

void print_params(FILE *fp)
{
	entry *e;
	int changed = 0;

	add_param(BOOLEAN, "help", &help);
	if (help) {
		fprintf(fp, HelpString);
	}
	
	for(e=bottom; e; e = e->next) {
		fprintf(fp, "%s\t", e->name);
		switch (e->t) {
		case FLOAT:
			fprintf(fp, "%f\n", *(float *)(e->addr)); break;
		case INT:
			fprintf(fp, "%d\n", *(int *)(e->addr)); break;
		case BOOLEAN:
			fprintf(fp, "%d\n", *(char *)(e->addr)); break;
		case STRING:
			fprintf(fp, "%s\n", (char *)(e->addr)); break;
		}
	}
	if (help) exit(0);
}
