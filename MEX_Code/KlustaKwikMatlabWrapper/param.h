#include <string.h>
#include <stdlib.h>
#include <stdio.h>

enum type_t {FLOAT = 'f', INT = 'd',  BOOLEAN = 'b', STRING = 's'};

#define FLOAT_PARAM(name) add_param(FLOAT, #name, &name)
#define INT_PARAM(name) add_param(INT, #name, &name)
#define BOOLEAN_PARAM(name) add_param(BOOLEAN, #name, &name)
#define STRING_PARAM(name) add_param(STRING, #name, name)

#define STRLEN 10000

void add_param(int t, char *name, void *addr);

int change_param(char *name, char *value);

void print_params(FILE *fp);
