 typedef struct __attribute__((packed)) Qwc_RTMZ_Time_Zone_Info {
      char Time_Zone_Object[10];
      char Local_System_Time_Indicator;
      char Daylight_Saving_Time_Indicator;
      int Offset_From_UTC;
      char Standard_Abbreviated_Name[10];
      char Standard_Full_Name[50];
      char DST_Abbreviated_Name[10];
      char DST_Full_Name[50];
      char Standard_Message[7];
      char DST_Message[7];
      char Message_File[10];
      char Message_File_Library[10];
      char DST_Start_Month[2];
      char DST_Start_Day;
      char DST_Start_Relative_Day;
      char DST_Start_Time[6];
      char DST_End_Month[2];
      char DST_End_Day;
      char DST_End_Relative_Day;
      char DST_End_Time[6];
      char Text_Description[50];
      int DST_Shift;
      int Year_Offset;
      char Alternate_Name[128];

  } Qwc_RTMZ_Time_Zone_Info_t;

 typedef struct __attribute__((packed)) Qwc_RTMZ0100
    {
       int Bytes_Returned;
       int Bytes_Available;
       int Time_Zone_Available;
       int Time_Zone_Offset;
       int Time_Zone_Returned;
       int Time_Zone_Length;


    } Qwc_RTMZ0100_t;

 typedef struct __attribute__((packed)) Qwc_RTMZ_TZ_String {
      int Entry_Length;
      int Disp_To_String;
      int String_Length;
      char Time_Zone_Object[10];


  } Qwc_RTMZ_TZ_String_t;

 typedef struct __attribute__((packed)) Qwc_RTMZ0200
    {
       int Bytes_Returned;
       int Bytes_Available;
       int Time_Zone_Available;
       int Time_Zone_Offset;
       int Time_Zone_Returned;


    } Qwc_RTMZ0200_t;
