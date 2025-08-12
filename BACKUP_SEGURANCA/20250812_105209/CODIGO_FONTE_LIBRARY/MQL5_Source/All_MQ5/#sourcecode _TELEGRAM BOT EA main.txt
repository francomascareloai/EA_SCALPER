//+------------------------------------------------------------------+
//|                                                     TELEGRAM.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

const string TG_API_URL = "https://api.telegram.org";
const string BOT_TOKEN = "6703501547:AAFRpZ0NfDomEIbDVzm61Ait8WahV8NXSGc";
const string CHAT_ID = "-4197279564";
const string SCREENSHOT_FILE_NAME = "My ScreenShot.jpg";
const int TIMEOUT = 10000;
const string METHOD = "POST";
string CAPTION = NULL;
string TEXT_MSG = NULL;
string URL = NULL;
string HEADERS = NULL;
char DATA[];
char RESULT[];
string RESULT_HEADERS = NULL;


// How to get chat id
//https://api.telegram.org/bot{BOT_TOKEN}/getUpdates
//https://api.telegram.org/bot6703501547:AAFRpZ0NfDomEIbDVzm61Ait8WahV8NXSGc/getUpdates


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   /*
   TEXT_MSG = "HELLO WORLD! This is a DM from MQL5/MT5";
   //https://api.telegram.org/bot{BOT_TOKEN}/sendMessage?chat_id={CHAT_ID}
   //&text={TEXT_MESSAGE}
   URL = TG_API_URL+"/bot"+BOT_TOKEN+"/sendMessage?chat_id="+
                  CHAT_ID+"&text="+TEXT_MSG;
   int send_res = WebRequest(METHOD,URL,HEADERS,TIMEOUT,DATA,RESULT,RESULT_HEADERS);
   */
   
   
   long chart_id=ChartOpen(_Symbol,_Period);
   ChartSetInteger(ChartID(),CHART_BRING_TO_TOP,true);
   // update chart
   int wait=60;
   while(--wait>0){//decrease the value of wait by 1 before loop condition check
      if(SeriesInfoInteger(_Symbol,_Period,SERIES_SYNCHRONIZED)){
         break; // if prices up to date, terminate the loop and proceed
      }
   }
   
   //if (!ChartApplyTemplate(chart_id,"\\Profiles\\Templates\\telegram.tpl")){
   //   Print("UNABLE TO APPLY THE CHART TEMPLATE");
   //}
   
   //    ++++++++++   TYPICALLY START HERE   ++++++++++
   
   ChartRedraw(chart_id);
   ChartSetInteger(chart_id,CHART_SHOW_GRID,false);
   ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);
   
   if(FileIsExist(SCREENSHOT_FILE_NAME)){
      FileDelete(SCREENSHOT_FILE_NAME);
      ChartRedraw(chart_id);
   }
      
   ChartScreenShot(chart_id,SCREENSHOT_FILE_NAME,1366,768,ALIGN_RIGHT);
   //Sleep(10000); // sleep for 10 secs to see the opened chart
   ChartClose(chart_id);
   
   // waitng 30 sec for save screenshot if not yet saved
   wait=60;
   while(!FileIsExist(SCREENSHOT_FILE_NAME) && --wait>0){
      Sleep(500);
   }
   
   if(!FileIsExist(SCREENSHOT_FILE_NAME)){
      Print("SPECIFIED SCREENSHOT DOES NOT EXIST. REVERTING NOW!");
      return (INIT_FAILED);
   }
   
   int screenshot_Handle = FileOpen(SCREENSHOT_FILE_NAME,FILE_READ|FILE_BIN);
   if(screenshot_Handle == INVALID_HANDLE){
      Print("INVALID SCREENSHOT HANDLE. REVERTING NOW!");
      return(INIT_FAILED);
   }
   
   int screenshot_Handle_Size = (int)FileSize(screenshot_Handle);
   uchar photoArr_Data[];
   ArrayResize(photoArr_Data,screenshot_Handle_Size);
   FileReadArray(screenshot_Handle,photoArr_Data,0,screenshot_Handle_Size);
   FileClose(screenshot_Handle);

   //--- create boundary: (data -> base64 -> 1024 bytes -> md5)
   //Encodes the photo data into base64 format
   //This is part of preparing the data for transmission over HTTP.
   uchar base64[];
   uchar key[];
   CryptEncode(CRYPT_BASE64,photoArr_Data,key,base64);

   //Copy the first 1024 bytes of the base64-encoded data into a temporary array
   uchar temporaryArr[1024]= {0};
   ArrayCopy(temporaryArr,base64,0,0,1024);
   
   //Create an MD5 hash of the temporary array
   //This hash will be used as part of the boundary in the multipart/form-data
   uchar md5[];
   CryptEncode(CRYPT_HASH_MD5,temporaryArr,key,md5);
   
   //Format MD5 hash as a hexadecimal string &
   //truncate it to 16 characters to create the boundary.
   string hash=NULL;//Used to store the hexadecimal representation of MD5 hash
   int total=ArraySize(md5);
   //Converts the byte (an element of the md5 array) to a 2-character hexadecimal
   //string. The %02X format specifier means that it will print at least 2 digits,
   //padding with zeros if necessary, and use uppercase letters for the
   //hexadecimal digits.
   //hash+= Appends the resulting string to the hash variable.
   //After the loop, hash will contain the hexadecimal representation of the
   //entire MD5 hash.
   for(int i=0; i<total; i++){
      hash+=StringFormat("%02X",md5[i]);
   }
   hash=StringSubstr(hash,0,16);//truncate hash string to its first 16 characters
   //done to comply with a specific length requirement for the boundary
   //in the multipart/form-data of the HTTP request.
   
   //Print("hash boundary = ",hash);
   
   //Typically, what we have done is generate a 16-character string from the
   //hexadecimal representation of an MD5 hash, which will be used as a
   //boundary marker in an HTTP request to send data (in this case, photo)
   //to a web server, in this case, the Telegram API.
   //The boundary is used to separate different parts of the
   //multipart/form-data payload.
   
   //--- WebRequest
   URL = TG_API_URL+"/bot"+BOT_TOKEN+"/sendPhoto";
   //--- add chart_id
   //Append a carriage return and newline character sequence to the DATA array.
   //In the context of HTTP, \r\n is used to denote the end of a line
   //and is often required to separate different parts of an HTTP request.
   ArrayAdd(DATA,"\r\n");
   //Append a boundary marker to the DATA array.
   //Typically, the boundary marker is composed of two hyphens (--)
   //followed by a unique hash string and then a newline sequence.
   //In multipart/form-data requests, boundaries are used to separate
   //different pieces of data.
   ArrayAdd(DATA,"--"+hash+"\r\n");
   //Add a Content-Disposition header for a form-data part named chat_id.
   //The Content-Disposition header is used to indicate that the following data
   //is a form field with the name chat_id.
   ArrayAdd(DATA,"Content-Disposition: form-data; name=\"chat_id\"\r\n");
   //Again, append a newline sequence to the DATA array to end the header section
   //before the value of the chat_id is added.
   ArrayAdd(DATA,"\r\n");
   //Append the actual chat ID value to the DATA array.
   ArrayAdd(DATA,CHAT_ID);
   //Finally, Append another newline sequence to the DATA array to signify
   //the end of the chat_id form-data part.
   ArrayAdd(DATA,"\r\n");
   // EXAMPLE OF USING CONVERSIONS
   uchar array[] = { 72, 101, 108, 108, 111, 0 }; // "Hello" in ASCII
   string output = CharArrayToString(array,0,WHOLE_ARRAY,CP_ACP);
   Print("CONVERT = ",output); // Hello
   
   //Print("CHAT ID DATA:");
   //(CharArrayToString(DATA,0,WHOLE_ARRAY,CP_UTF8));
   
   CAPTION = "ScreenShot of Symbol: "+Symbol()+
             " ("+EnumToString(ENUM_TIMEFRAMES(_Period))+
             ") @ Time: "+TimeToString(TimeCurrent());
   if(StringLen(CAPTION) > 0){
      ArrayAdd(DATA,"--"+hash+"\r\n");
      ArrayAdd(DATA,"Content-Disposition: form-data; name=\"caption\"\r\n");
      ArrayAdd(DATA,"\r\n");
      ArrayAdd(DATA,CAPTION);
      ArrayAdd(DATA,"\r\n");
   }

   ArrayAdd(DATA,"--"+hash+"\r\n");
   ArrayAdd(DATA,"Content-Disposition: form-data; name=\"photo\"; filename=\"Upload_ScreenShot.jpg\"\r\n");
   ArrayAdd(DATA,"\r\n");
   ArrayAdd(DATA,photoArr_Data);
   ArrayAdd(DATA,"\r\n");
   ArrayAdd(DATA,"--"+hash+"--\r\n");
   
   //Print("DATA BEING SENT:");
   //ArrayPrint(DATA);
   //string simple_Data = CharArrayToString(DATA,0,WHOLE_ARRAY,CP_ACP);
   //Print("SIMPLE DATA BEING SENT:",simple_Data);
   
   HEADERS = "Content-Type: multipart/form-data; boundary="+hash+"\r\n";
   
   int res_WebReq = WebRequest(METHOD,URL,HEADERS,TIMEOUT,DATA,RESULT,RESULT_HEADERS);
   
   if(res_WebReq == 200){
      //ArrayPrint(RESULT);
      string result = CharArrayToString(RESULT,0,WHOLE_ARRAY,CP_UTF8);
      Print(result);
      Print("SUCCESS SENDING THE SCREENSHOT TO TELEGRAM");
   }
   else{
      if(res_WebReq == -1){
         string result = CharArrayToString(RESULT,0,WHOLE_ARRAY,CP_UTF8);
         Print(result);
         Print("ERROR",_LastError," IN WEBREQUEST");
         if (_LastError == 4014){
            Print("API URL NOT LISTED. PLEASE ADD/ALLOW IT IN TERMINAL");
            return (INIT_FAILED);
         }
      }
      else{
         string result = CharArrayToString(RESULT,0,WHOLE_ARRAY,CP_UTF8);
         Print(result);
         Print("UNEXPECTED ERROR: ",_LastError);
         return (INIT_FAILED);
      }
   }
   
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// ArrayAdd for uchar Array
void ArrayAdd(uchar &destinationArr[],const uchar &sourceArr[]){
   int sourceArr_size=ArraySize(sourceArr);//get size of source array
   if(sourceArr_size==0){
      return;//if source array is empty, exit the function
   }
   int destinationArr_size=ArraySize(destinationArr);
   //resize destination array to fit new data
   ArrayResize(destinationArr,destinationArr_size+sourceArr_size,500);
   // Copy the source array to the end of the destination array.
   ArrayCopy(destinationArr,sourceArr,destinationArr_size,0,sourceArr_size);
}

//+------------------------------------------------------------------+
// ArrayAdd for strings
void ArrayAdd(char &destinationArr[],const string text){
   int length = StringLen(text);// get the length of the input text
   if(length > 0){
      uchar sourceArr[]; //define an array to hold the UTF-8 encoded characters
      for(int i=0; i<length; i++){
         // Get the character code of the current character
         ushort character = StringGetCharacter(text,i);
         uchar array[];//define an array to hold the UTF-8 encoded character
         //Convert the character to UTF-8 & get size of the encoded character
         int total = ShortToUtf8(character,array);
         
         //Print("text @ ",i," > "text); // @ "B", IN ASCII TABLE = 66 (CHARACTER)
         //Print("character = ",character);
         //ArrayPrint(array);
         //Print("bytes = ",total) // bytes of the character
         
         int sourceArr_size = ArraySize(sourceArr);
         //Resize the source array to accommodate the new character
         ArrayResize(sourceArr,sourceArr_size+total);
         //Copy the encoded character to the source array
         ArrayCopy(sourceArr,array,sourceArr_size,0,total);
      }
      //Append the source array to the destination array
      ArrayAdd(destinationArr,sourceArr);
   }
}

//+------------------------------------------------------------------+
// Function to convert a character into its UTF-8 encoded form and store it
int ShortToUtf8(const ushort character,uchar &output[]){
   //if the character is less than 0x80 (128 in decimal)
   //it means it’s an ASCII character and can be represented with a single byte
   //in UTF-8.
   
   //The 0x80 represents a hexadecimal number, which is a base-16 numeral system
   //In hexadecimal, each digit can be a value from 0 to 15,
   //with the letters A to F representing the values 10 to 15.
   //The prefix 0x is commonly used to indicate that the number that follows
   //is in hexadecimal format.
   
   //TO CONVERT THE HEXADECIMAL TO DECIMAL (base-10 nummber system)
   //multiply each digit in the hexadecimal number by 16 raised
   //to the power of the digit’s position, counting from right to left
   //starting at 0. (123.456) => 3=ones, 2=tens, 4=tenths...
   
   //0x80 => 0*16^0 + 8*16*1 = 128 (in decimal)
   //0x800 => 0*16^0 + 0*16^1 + 8*16^2 = 2048 (in decimal)
   
   if(character < 0x80){
      //resize the output array to 1 element, as only one byte is needed
      //to represent the character in UTF-8.
      ArrayResize(output,1);
      //assign the character to the first element of the output array,
      // and cast it to uchar type.
      output[0]=(uchar)character;
      //return 1, indicating that 1 byte was used for the UTF-8 encoding
      return(1);
   }
   if(character < 0x800){//< 2048, meaning it can be rep with 2 bytes
      ArrayResize(output,2);
      //calculate the first byte of the two-byte UTF-8 representation by
      //shifting the character right by 6 bits and OR-ing with 0xC0 (192 in dec)
      // 0xC0 => C in hexadec = 12 (dec), 0*16^0 + 12*16^1 = 192
      output[0] = (uchar)((character >> 6)|0xC0);
      //calculate the second byte by AND-ing character with 0x3F (63 in decimal)
      //and OR-ing with 0x80 (128 in dec)
      output[1] = (uchar)((character & 0x3F)|0x80);
      return(2);
   }
   if(character < 0xFFFF){// < (65535 in dec) ==> 3 or 4 bytes in UTF-8
      //if character is within the range of UTF-16 surrogate pairs,
      //which are not valid standalone characters.
      
      //IN CASE OF SURROGATE PAIRS, usually have code points higher than 0xFFFF
      //2 kinds of surrogate pairs:
      //High Surrogate: The 1st code unit of a surrogate pair(U+D800 to U+DBFF)
      //Low Surrogate: The 2nd code unit of surrogate pair(U+DC00 to U+DFFF)
      if(character >= 0xD800 && character <= 0xDFFF){ //Ill-formed
         ArrayResize(output,1);
         //replace the surrogate pair with a space character, as it cannot
         //be represented in UTF-8.
         output[0]=' ';
         return(1);
      }
      
      //if character is within the range of private use characters,
      //often used for emojis.
      else if(character >= 0xE000 && character <= 0xF8FF){ //Emoji
         //If character is an emoji, create a new integer character by OR-ing
         //character with 0x10000 to prepare for four-byte UTF-8 encoding.
         int character_int = 0x10000|character;
         ArrayResize(output,4); // resize to 4 elements for emoji character
         //calculate the 1st byte of the 4-byte UTF-8 rep for the emoji
         output[0] = (uchar)(0xF0 | (character_int >> 18));
         //calculate the 2nd byte of the 4-byte UTF-8 rep for the emoji
         output[1] = (uchar)(0x80 | ((character_int >> 12) & 0x3F));
         output[2] = (uchar)(0x80 | ((character_int >> 6) & 0x3F)); //3rd
         output[3] = (uchar)(0x80 | ((character_int & 0x3F))); //4th
         return(4);
      }
      //For characters that are not surrogate pairs or emojis but still
      //require 3-byte UTF-8 encoding
      else{
         ArrayResize(output,3);
         //calculate the 1st byte of the 3-byte UTF-8 representation
         output[0] = (uchar)((character>>12)|0xE0);
         output[1] = (uchar)(((character>>6)&0x3F)|0x80); // 2nd
         output[2] = (uchar)((character&0x3F)|0x80); // 3rd
         return(3);
      }
   }
   //resize the output array to 3 elements for characters that do not fit any
   //of the previous conditions and will use the UTF-8 replacement character
   ArrayResize(output,3);
   output[0] = 0xEF; //set the 1st byte of the UTF-8 replacement character
   output[1] = 0xBF; // 2nd
   output[2] = 0xBD; // 3rd (B=11,D=13, 13*16^0 + 11*16^1 = 189 in dec)
   //return 3, indicating 3 bytes were used for the UTF-8 replacement character
   return(3);
}
