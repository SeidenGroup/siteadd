typedef struct Qwc_Rsval_Sys_Value_Table {
	char System_Value[10];
	char Type_Data;
	char Information_Status;
	int  Length_Data;
	char Data[];
} Qwc_Rsval_Sys_Value_Table_t;

typedef struct Qwc_Rsval_Data_Rtnd {
	int  Number_Sys_Vals_Rtnd;
	int  Offset_Sys_Val_Table[];
} Qwc_Rsval_Data_Rtnd_t;
