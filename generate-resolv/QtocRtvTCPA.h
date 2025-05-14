typedef struct __attribute__((packed)) Qtoc_RtvTCPA_TCPA1100
{
	unsigned long Bytes_Returned;
	unsigned long Bytes_Available;
	unsigned long TCPIP6_Stack_Status;
	unsigned long Offset_To_Additional_Info;
	unsigned long Length_Of_Additional_Info;
	unsigned long TCPIP4_Stack_Status;
	char data[];
} Qtoc_RtvTCPA_TCPA1100_t;

typedef struct __attribute__((packed)) Qtoc_RtvTCPA_TCPA1400
{
	unsigned long Offset_To_List_DNS_Addr;
	unsigned long Number_Of_DNS_Addresses;
	unsigned long Entry_Len_List_DNS_Addr;
	unsigned long DNS_Protocol;
	unsigned long Retries;
	unsigned long Time_Interval;
	unsigned long Search_Order;
	unsigned long Initial_DNS_Server;
	unsigned long DNS_Listening_Port;
	char Host_Name[64];
	char Domain_Name[255];
	char Reserved_1;
	char Domain_Search_List[256];
	unsigned long DNSSEC;
} Qtoc_RtvTCPA_TCPA1400_t;

typedef struct __attribute__((packed)) Qtoc_RtvTCPA_LIA_IP4_IP6
{
	unsigned long Protocol_Version;
	char DNS_Internet_Address[45];
	char Reserved_1[3];
	char DNS_Internet_Address_Binary[16];
} Qtoc_RtvTCPA_Inet_Addr_IP4_IP6_t;
