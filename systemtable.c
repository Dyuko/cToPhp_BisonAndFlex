symrec *putsym(char *sym_name)
{
    symrec *ptr;
    ptr = (symrec *)malloc(sizeof(symrec));
    ptr->name = (char *)malloc(strlen(sym_name) + 1);
    ptr->type = NULL;
    strcpy(ptr->name,sym_name);
    ptr->next = (struct symrec *)sym_table;
    sym_table = ptr;
    return ptr;
}

symrec *putnum(char *sym_name)
{
    symrec *ptr;
    char *dPos = strchr(sym_name, '.');
    char *ePos = strchr(sym_name, 'e');
    ptr = (symrec *)malloc(sizeof(symrec));
    ptr->name = (char *)malloc(strlen(sym_name) + 1);
    if ((dPos == NULL) && (ePos == NULL)){
        ptr->type = (char *)malloc(strlen("INTEGER") + 1);
        strcpy(ptr->type, "INTEGER");
    }
    else if ((dPos != NULL) && (ePos == NULL)) {
        ptr->type = (char *)malloc(strlen("REAL") + 1);
        strcpy(ptr->type, "REAL");
    }
    else {
        ptr->type = (char *)malloc(strlen("FLOAT") + 1);
        strcpy(ptr->type, "FLOAT");
    }
    strcpy(ptr->name,sym_name);
    ptr->next = (struct symrec *)sym_table;
    sym_table = ptr;
    return ptr;
}

void set_type(char *type)
{
    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec *)ptr->next) {
        if (ptr->type == NULL) {
            ptr->type = (char *)malloc(strlen(type) + 1);
            strcpy(ptr->type, type);
        }
    }
}

void set_proc(char *sym_name) {
    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec *)ptr->next)
        if (strcmp (ptr->name, sym_name) == 0){
            ptr->type = (char *)malloc(strlen("PROC") + 1);
            strcpy(ptr->type, "PROC");
        }
}

symrec *getsym(char *sym_name)
{
    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec *)ptr->next)
        if (strcmp (ptr->name, sym_name) == 0)
            return ptr;
    return 0;
}

void print_sym_table()
{
    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec *)ptr->next)
        printf("\n%s    %s\n", ptr->name, ptr->type);
}