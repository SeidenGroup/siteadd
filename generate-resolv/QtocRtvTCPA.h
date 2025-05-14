typedef struct __attribute__((packed)) Qtoc_RtvTCPA_TCPA1100
{
	unsigned int Bytes_Returned;
	unsigned int Bytes_Available;
	unsigned int TCPIP6_Stack_Status;
	unsigned int Offset_To_Additional_Info;
	unsigned int Length_Of_Additional_Info;
	unsigned int TCPIP4_Stack_Status;
} Qtoc_RtvTCPA_TCPA1100_t;

typedef struct __attribute__((packed)) Qtoc_RtvTCPA_TCPA1400
{
	unsigned int Offset_To_List_DNS_Addr;
	unsigned int Number_Of_DNS_Addresses;
	unsigned int Entry_Len_List_DNS_Addr;
	unsigned int DNS_Protocol;
	unsigned int Retries;
	unsigned int Time_Interval;
	unsigned int Search_Order;
	unsigned int Initial_DNS_Server;
	unsigned int DNS_Listening_Port;
	char Host_Name[64];
	char Domain_Name[255];
	char Reserved_1;
	char Domain_Search_List[256];
	unsigned int DNSSEC;
} Qtoc_RtvTCPA_TCPA1400_t;

typedef struct __attribute__((packed)) Qtoc_RtvTCPA_LIA_IP4_IP6
{
	unsigned int Protocol_Version;
	char DNS_Internet_Address[45];
	char Reserved_1[3];
	char DNS_Internet_Address_Binary[16];
} Qtoc_RtvTCPA_Inet_Addr_IP4_IP6_t;
