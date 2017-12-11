#define OEOF 0
#define KSTATE 257
#define KINTERRUPTS 258
#define KINSTRUCTIONS 259
#define ID 260
#define NUMBER 261
#define CODE 262
#define STRING 263
typedef union yylval {
    struct identifier_entry	*id;
    char			*string;
} YYSTYPE;
extern YYSTYPE yylval;
