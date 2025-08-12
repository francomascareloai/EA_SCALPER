//+------------------------------------------------------------------+
//|                                              TELEGRAM BOT EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

const string TG_API_URL = "https://api.telegram.org";
const string BOT_TOKEN = "6830142565:AAGXN3HmD5TMzgRBTgEE8_3hauBRV4v0Lv0";
const string CHAT_ID = "-4142250840";
const string METHOD = "POST";
const int TIMEOUT = 10000;
const string SCREENSHOT_FILE_NAME = "My Screenshot.jpg";
string HEADERS = NULL;
string URL = NULL;
string TEXT_MSG = NULL;
string CAPTION = NULL;
char DATA[];
char RESULT[];
string RESULT_HEADERS = NULL;

// How to get the chat_id
//https://api.telegram.org/bot{BOT TOKEN}/getUpdates
//https://api.telegram.org/bot6830142565:AAGXN3HmD5TMzgRBTgEE8_3hauBRV4v0Lv0/getUpdates

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   /*
   //https://api.telegram.org/bot{BOT TOKEN}/sendMessage?chat_id={CHAT ID}
   //&text={TEXT MESSAGE}
   TEXT_MSG = "HELLO WORLD!";
   URL = TG_API_URL+"/bot"+BOT_TOKEN+"/sendMessage?chat_id="+CHAT_ID+
         "&text="+TEXT_MSG;
   int res = WebRequest(METHOD,URL,HEADERS,TIMEOUT,DATA,RESULT,RESULT_HEADERS);
   
   if (res == 200){
      Print("SUCCESS SENDING THE MESSAGE TO TELEGRAM");
   }
   else{
      if (res == -1){
         Print("ERROR ",_LastError," IN WEBREQUEST");
         if (_LastError == 4014){
            Print("API URL NOT LISTED. PLEASE ALLOW/ADD IT IN THE TELEGRAM");
            return (INIT_FAILED);
         }
      }
      else {
         Print("UNEXPECTED ERROR: ",_LastError);
         return (INIT_FAILED);
      }
   }
   */
   
   /*
   long chart_id = ChartOpen(_Symbol,_Period);
   ChartSetInteger(chart_id,CHART_BRING_TO_TOP,true);
   //UPDATE THE OPENED CHART
   int wait = 60;
   while (--wait > 0){ // deacrease the value of wait by 1 before loop condition check
      if (SeriesInfoInteger(_Symbol,_Period,SERIES_SYNCHRONIZED)){
         break; // if the prices are up to date, terminate the loop and proceed
      }
   }
   
   //ChartApplyTemplate(chart_id,"\\Profiles\\Templates\\telagram.tpl");
   
   ChartSetInteger(chart_id,CHART_SHOW_GRID,false);
   ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);
   */
   
   if (FileIsExist(SCREENSHOT_FILE_NAME)){
      FileDelete(SCREENSHOT_FILE_NAME);
      ChartRedraw(0);
   }
   
   ChartScreenShot(0,SCREENSHOT_FILE_NAME,1366,768,ALIGN_RIGHT);
   //Sleep(TIMEOUT);
   //ChartClose(chart_id);
   
   int wait = 60;
   while(!FileIsExist(SCREENSHOT_FILE_NAME) && --wait > 0){
      Sleep(500);
   }
   
   if (!FileIsExist(SCREENSHOT_FILE_NAME)){
      Print("SPECIFIED SCREENSHOT DOES NOT EXIST. REVERTING NOW");
      return (INIT_FAILED);
   }
   
   int screenshot_Handle = FileOpen(SCREENSHOT_FILE_NAME,FILE_READ|FILE_BIN);
   if (screenshot_Handle == INVALID_HANDLE){
      Print("INVALID SCREENSHOT HANDLE. REVERTING NOW!");
      return (INIT_FAILED);
   }
   
   int screenshot_Handle_Size = (int)FileSize(screenshot_Handle);
   uchar photoArr_Data[];
   ArrayResize(photoArr_Data,screenshot_Handle_Size);
   FileReadArray(screenshot_Handle,photoArr_Data,0,screenshot_Handle_Size);
   FileClose(screenshot_Handle);
   //ArrayPrint(photoArr_Data);
   
   // create a boundary: (data -> base64 -> 1024bytes -> md5)
   // encode the photo into base64 format
   // This is the part we prepare the data for transmission over the HTTP
   uchar base64[];
   uchar key[];
   CryptEncode(CRYPT_BASE64,photoArr_Data,key,base64);
   //ArrayPrint(base64);
   
   // Copy the first 1024 bytes of the base64 encoded data into the temporary array
   uchar temporaryArr[1024] = {0};
   ArrayCopy(temporaryArr,base64,0,0,1024);
   //ArrayPrint(temporaryArr);
   
   // Create an MD5 hash of the temporary array
   // This hash will be used as part of the boundary in the multipart/form-data
   uchar md5[];
   CryptEncode(CRYPT_HASH_MD5,temporaryArr,key,md5);
   //ArrayPrint(md5);
   
   // Create an MD5 hash of a hexadecimal string &
   //truncate it to 16 characters to create the boundary
   string hash = NULL;
   int total = ArraySize(md5);
   // Convert the byte(an element of the md5 array) to a 2-character hexadecimal string
   // The %02X format specifier means that it will print atleast 2-digits, 
   // padding with zeros if necessary, and use uppercase letters to the hexadecimal 
   // digits
   // hash+=: Appends the resulting string to the hash variable
   for (int i=0; i<total; i++){
      hash+=StringFormat("%02X",md5[i]);
   }
   //Print(hash);
   hash = StringSubstr(hash,0,16);// truncate hash string to its first 16 characters
   // done to comply with a specific length requirement for the boundary
   // in the multipart/form-data of the HTTP request.
   
   //Print(hash);
   
   
   //https://api.telegram.org/bot{BOT TOKEN}/sendPhoto?
   
   URL = TG_API_URL+"/bot"+BOT_TOKEN+"/sendPhoto";
   
   // 
   
   // ADD THE CHART ID
   // append a carriage return and newline character sequence to the DATA array
   //In the context of HTTP, \r\n is used to denote the end of a line
   // and is often required to separate different parts of an HTTP request.
   ArrayAdd(DATA,"\r\n");
   // append a boundary marker to the DATA array
   // Typically the boundary marker consists of 2 hyphens (--);
   // followed by a unique hash string and a new line sequence
   // Typically, in multipart/form-data, boundaries are used to separate
   // different pieces of data
   ArrayAdd(DATA,"--"+hash+"\r\n");
   // add a content-disposition header for a form-data part named chat_id
   // The constent-Disposition geader is used to indicate that the following data
   // is a form field with the name chat_id
   ArrayAdd(DATA,"Content-Disposition: form-data; name=\"chat_id\"\r\n");
   // again, append a newline sequence to the data array to end the header section
   // before the value of the chat_id is added
   ArrayAdd(DATA,"\r\n");
   // append the actual value of the CHAT_ID to the DATA array
   ArrayAdd(DATA,CHAT_ID);
   // finally, append another newline sequence to the data array to signify the end 
   // of the chat_id form-data part.
   ArrayAdd(DATA,"\r\n");
   
   //ArrayPrint(DATA);
   //string output = CharArrayToString(DATA,0,WHOLE_ARRAY,CP_ACP);
   //Print(output);
   
   // ADD CAPTION
   CAPTION = "Screenshot of symbol: "+Symbol()+
             " ("+EnumToString(ENUM_TIMEFRAMES(Period()))+
             ") @ Time: "+TimeToString(TimeCurrent());
   if (StringLen(CAPTION) > 0){
      ArrayAdd(DATA,"--"+hash+"\r\n");
      ArrayAdd(DATA,"Content-Disposition: form-data; name=\"caption\"\r\n");
      ArrayAdd(DATA,"\r\n");
      ArrayAdd(DATA,CAPTION);
      ArrayAdd(DATA,"\r\n");
   }
   
   // ADD THE PHOTO/SCREENSHOT
   ArrayAdd(DATA,"--"+hash+"\r\n");
   ArrayAdd(DATA,"Content-Disposition: form-data; name=\"photo\"; filename=\"Upload_Screenshot.jpg\"\r\n");
   ArrayAdd(DATA,"\r\n");
   ArrayAdd(DATA,photoArr_Data);
   ArrayAdd(DATA,"\r\n");
   ArrayAdd(DATA,"--"+hash+"--\r\n");
   
   // AN EXAMPLE OF DOING THE CONVERSION
   //uchar array[] = {72,101,108,108,111}; // Hello
   //string output = CharArrayToString(array,0,WHOLE_ARRAY,CP_ACP);
   //ArrayPrint(array);
   //Print(output);
   
   //ArrayPrint(DATA);
   //string output = CharArrayToString(DATA,0,WHOLE_ARRAY,CP_ACP);
   //Print(output);
   
   HEADERS = "Content-Type: multipart/form-data; boundary="+hash+"\r\n";
   
   int res_WebReq = WebRequest(METHOD,URL,HEADERS,TIMEOUT,DATA,RESULT,RESULT_HEADERS);
   
   if (res_WebReq == 200){
      string result = CharArrayToString(RESULT,0,WHOLE_ARRAY,CP_UTF8);
      Print(result);
      Print("SUCCESS SENDING THE SCREENSHOT TO TELEGRAM");
   }
   else{
      if (res_WebReq == -1){
         string result = CharArrayToString(RESULT,0,WHOLE_ARRAY,CP_UTF8);
         Print(result);
         Print("ERROR ",_LastError," IN WEBREQUEST");
         if (_LastError == 4014){
            Print("API URL NOT LISTED. PLEASE ALLOW/ADD IT IN THE TELEGRAM");
            return (INIT_FAILED);
         }
      }
      else {
         string result = CharArrayToString(RESULT,0,WHOLE_ARRAY,CP_UTF8);
         Print(result);
         Print("UNEXPECTED ERROR: ",_LastError);
         return (INIT_FAILED);
      }
   }
   
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

void ArrayAdd(uchar &destinationArr[],const uchar &sourceArr[]){
   int sourceArr_Size = ArraySize(sourceArr); // get the source array
   if (sourceArr_Size == 0){
      return; // if the source array is empty, exit the function
   }
   int destinationArr_Size = ArraySize(destinationArr);
   ArrayResize(destinationArr,destinationArr_Size+sourceArr_Size,500);
   ArrayCopy(destinationArr,sourceArr,destinationArr_Size,0,sourceArr_Size);
}

// ArrayAdd function for adding strings to the array data
void ArrayAdd(char &destinationArr[],const string text){
   int length = StringLen(text); // we get the length of the input text
   if (length > 0){
      uchar sourceArr[]; // define an array to hold the UTF-8 encoded characters
      for (int i=0; i<length; i++){
         ushort character = StringGetCharacter(text,i);
         uchar array[]; // define an array to hold the UTF-8 encoded character
         // convert the character to UTF-8 & get the size of the encoded character
         int total = ShortToUTF8(character,array);
         int sourceArr_size = ArraySize(sourceArr);
         // resize the source array to accomodate the new character
         ArrayResize(sourceArr,sourceArr_size+total);
         ArrayCopy(sourceArr,array,sourceArr_size,0,total);
         // get the character code of the current character
      }
      // append the source array to the destination array
      ArrayAdd(destinationArr,sourceArr);
   }
}


// tunction to convert a character into its UTF-8 encoded form and store it
int ShortToUTF8(const ushort character,uchar &output[]){
   // if the character is less than 0x80 (128 in decimal)
   // it means it's an ASCII character and can be represented with a single byte
   // in the UTF-8
   
   // The 0x80 represents a hexadecimal number, which is a base-16 numeral system
   // In hexadecimal each degit can be a value from 0 to 15
   // The prefix 0x is commonly used to indicate that the number that follows
   // is in hexadecimal format
   
   // TO CONVERT THE HEXADECIMAL TO DECIMAL (base-10 number system)
   // multiply each didgit inthe hexadecimal number by 16 raised to the power of the
   // digit's position, counting from right to left starting from 0.
   // (123.456) => 3=ones, 2=tens, 4 = tenths...
   
   // 0x80 => 0*16^0 + 8*16^1 = (128 in decimal)
   // 0x800 => 0*16^0 + 0*16^1 + 8*16^2 = 2048 (in dec)
   if (character < 0x80){
      // resize the output array to 1 element, as only 1 byte is needed
      // to represent the character in UTF-8.
      ArrayResize(output,1);
      // assign the character to the first element of the output array
      // and cast it to the uchar type
      output[0] = (uchar)character;
      // return 1, indicating that 1 byte was used
      return (1);
   }
   // graduate to 2 bytes, (2048 in decimal)
   if (character < 0x800){// < 2048, meaning it can be represented with 2 bytes
      ArrayResize(output,2);
      // calculate the first byte of the 2-byte UTF-8 representation by
      // shifting the character right by 6 bits and OR-ing with 0xC0 (192 in dec)
      // 0xC0 => 0*16^0 + 12*16^1 = 192 in dec
      output[0] = (uchar)((character >> 6)|0xC0);
      // calculate the 2nd byte by AND-ing character with 0x3F (63 in dec)
      // and OR-ig with 0x80 (128 in dec)
      output[1] = (uchar)((character & 0x3F)|0x80);
      return (2);
   }
   if (character < 0xFFFF){// < (65535 in dec) ==> 3 or 4 bytes in UTF-8
      // if the character is within the range of the UTF-8 surrogate pairs
      // which are again typically not valid standalone characters;
      
      // IN CASE OF SURROGATE PAIRS, WE HAVE CODE POINTS HIGHER THAN 0xFFFF
      // HIGH SURROGATE: The 1st code unit of a surrogate pair (U+D800 to U+DBFF)
      // LOW SURROGATE: The 2st code unit of a surrogate pair (U+DC00 to U+DFFF)
      if (character >= 0xD800 && character <= 0XDFFF){// ILL FORMED
         ArrayResize(output,1);
         // replace the surrogate pair witha space character, as it can not be 
         // represented in the UTF-8
         output[0] = ' ';
         return (1);
      }
      // if the character is within the range of the private use characters,
      // of often used for emojis
      else if (character >= 0xE000 && character <= 0xF8FF){ // emoji
         // if the character is an emoji, create a new integer character by the OR-ing 
         // character with 0x1000 to prepare the 4-byte UTF-8 encoding.
         int character_int = 0x1000|character;
         ArrayResize(output,4);// resize the array to 4 elements for the emoji character
         // calculate the 1st byte of the 4-byte UTF-8 rep fot the emoji
         output[0] = (uchar)(0xF0 | (character_int >> 18));
         output[1] = (uchar)(0x80 | ((character_int >> 12) & 0x3F)); //2nd
         output[2] = (uchar)(0x80 | ((character_int >> 6) & 0x3F)); //3rd
         output[3] = (uchar)(0x80 | ((character_int & 0x3F))); //4th
         return (4);
      }
      // characters that are not surrogate pairs or emojis but still 
      // require this UTF-8 encoding
      else {
         ArrayResize(output,3);
         // calculate the 1st byte of the 3-UTF-8 representation
         output[0] = (uchar)((character >> 12)|0xE0);
         output[1] = (uchar)(((character >> 6)|0x3F)|0x80); // 2nd
         output[2] = (uchar)(((character)|0x3F)|0x80); // 3rd
         return (3);
      }
   }
   // resize the output array to 3 elements for characters that do not fit any 
   // of the previous conditions and will use the UTF-8 replacement character
   ArrayResize(output,3);
   output[0] = 0xEF; // set the 1st byte of the UTF-8 replacement character
   output[1] = 0xBF; // 2nd
   output[2] = 0xBD; // 3rd 
   // return 3, indicating 3 bytes were used for the UTF-8 replacement character
   return (3);
}
