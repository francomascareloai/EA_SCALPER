



#define DEBUG_PRINT false
//------------------------------------------------------------------ enum JSONValueType
enum JSONValueType {jv_UNDEF,jv_NULL,jv_BOOL,jv_INT,jv_DBL,jv_STR,jv_ARRAY,jv_OBJ};
//------------------------------------------------------------------ class CJSONValue
class CJSONValue{
   public:
      // CONSTRUCTOR
      virtual void Clear(){
         m_parent=NULL;
         m_key="";
         m_type=jv_UNDEF;
         m_bool_val=false;
         m_int_val=0;
         m_double_val=0;
         m_string_val="";
         ArrayResize(m_elements,0);
      }
      virtual bool Copy(const CJSONValue &source){
         m_key=source.m_key;
         CopyData(source);
         return true;
      }
      virtual void CopyData(const CJSONValue &source){
         m_type=source.m_type;
         m_bool_val=source.m_bool_val;
         m_int_val=source.m_int_val;
         m_double_val=source.m_double_val;
         m_string_val=source.m_string_val;
         CopyArr(source);
      }
      virtual void CopyArr(const CJSONValue &source){
         int n=ArrayResize(m_elements,ArraySize(source.m_elements));
         for(int i=0; i<n; i++){
            m_elements[i]=source.m_elements[i];
            m_elements[i].m_parent=GetPointer(this);
         }
      }

   public:
      CJSONValue        m_elements[];
      string            m_key;
      string            m_lkey;
      CJSONValue       *m_parent;
      JSONValueType     m_type;
      bool              m_bool_val;
      long              m_int_val;
      double            m_double_val;
      string            m_string_val;
      static int        code_page;

   public:
      CJSONValue(){
         Clear();
      }
      CJSONValue(CJSONValue *parent,JSONValueType type){
         Clear();
         m_type=type;
         m_parent=parent;
      }
      CJSONValue(JSONValueType type,string value){
         Clear();
         FromStr(type,value);
      }
      CJSONValue(const int intValue){
         Clear();
         m_type=jv_INT;
         m_int_val=intValue;
         m_double_val=(double)m_int_val;
         m_string_val=IntegerToString(m_int_val);
         m_bool_val=m_int_val!=0;
      }
      CJSONValue(const long longValue){
         Clear();
         m_type=jv_INT;
         m_int_val=longValue;
         m_double_val=(double)m_int_val;
         m_string_val=IntegerToString(m_int_val);
         m_bool_val=m_int_val!=0;
      }
      CJSONValue(const double doubleValue){
         Clear();
         m_type=jv_DBL;
         m_double_val=doubleValue;
         m_int_val=(long)m_double_val;
         m_string_val=DoubleToString(m_double_val);
         m_bool_val=m_int_val!=0;
      }
      CJSONValue(const bool boolValue){
         Clear();
         m_type=jv_BOOL;
         m_bool_val=boolValue;
         m_int_val=m_bool_val;
         m_double_val=m_bool_val;
         m_string_val=IntegerToString(m_int_val);
      }
      CJSONValue(const CJSONValue &other){
         Clear();
         Copy(other);
      }
      // DECONSTRUCTOR
      ~CJSONValue(){
         Clear();
      }
   
   public:
      virtual bool IsNumeric(){
         return (m_type==jv_DBL || m_type==jv_INT);
      }
      virtual CJSONValue *FindKey(string key){
         for(int i=ArraySize(m_elements)-1; i>=0; --i){
            if(m_elements[i].m_key==key){
               return GetPointer(m_elements[i]);
            }
         }
         return NULL;
      }
      virtual CJSONValue *HasKey(string key,JSONValueType type=jv_UNDEF);
      virtual CJSONValue *operator[](string key);
      virtual CJSONValue *operator[](int i);
      void operator=(const CJSONValue &value){
         Copy(value);
      }
      void operator=(const int intVal){
         m_type=jv_INT;
         m_int_val=intVal;
         m_double_val=(double)m_int_val;
         m_bool_val=m_int_val!=0;
      }
      void operator=(const long longVal){
         m_type=jv_INT;
         m_int_val=longVal;
         m_double_val=(double)m_int_val;
         m_bool_val=m_int_val!=0;
      }
      void operator=(const double doubleVal){
         m_type=jv_DBL;
         m_double_val=doubleVal;
         m_int_val=(long)m_double_val;
         m_bool_val=m_int_val!=0;
      }
      void operator=(const bool boolVal){
         m_type=jv_BOOL;
         m_bool_val=boolVal;
         m_int_val=(long)m_bool_val;
         m_double_val=(double)m_bool_val;
      }
      void operator=(string stringVal){
         m_type=(stringVal!=NULL)?jv_STR:jv_NULL;
         m_string_val=stringVal;
         m_int_val=StringToInteger(m_string_val);
         m_double_val=StringToDouble(m_string_val);
         m_bool_val=stringVal!=NULL;
      }
   
      bool operator==(const int intVal){return m_int_val==intVal;}
      bool operator==(const long longVal){return m_int_val==longVal;}
      bool operator==(const double doubleVal){return m_double_val==doubleVal;}
      bool operator==(const bool boolVal){return m_bool_val==boolVal;}
      bool operator==(string stringVal){return m_string_val==stringVal;}
      
      bool operator!=(const int intVal){return m_int_val!=intVal;}
      bool operator!=(const long longVal){return m_int_val!=longVal;}
      bool operator!=(const double doubleVal){return m_double_val!=doubleVal;}
      bool operator!=(const bool boolVal){return m_bool_val!=boolVal;}
      bool operator!=(string stringVal){return m_string_val!=stringVal;}
   
      long ToInt() const{return m_int_val;}
      double ToDbl() const{return m_double_val;}
      bool ToBool() const{return m_bool_val;}
      string ToStr(){return m_string_val;}
   
      virtual void FromStr(JSONValueType type,string stringVal){
         m_type=type;
         switch(m_type){
         case jv_BOOL:
            m_bool_val=(StringToInteger(stringVal)!=0);
            m_int_val=(long)m_bool_val;
            m_double_val=(double)m_bool_val;
            m_string_val=stringVal;
            break;
         case jv_INT:
            m_int_val=StringToInteger(stringVal);
            m_double_val=(double)m_int_val;
            m_string_val=stringVal;
            m_bool_val=m_int_val!=0;
            break;
         case jv_DBL:
            m_double_val=StringToDouble(stringVal);
            m_int_val=(long)m_double_val;
            m_string_val=stringVal;
            m_bool_val=m_int_val!=0;
            break;
         case jv_STR:
            m_string_val=Unescape(stringVal);
            m_type=(m_string_val!=NULL)?jv_STR:jv_NULL;
            m_int_val=StringToInteger(m_string_val);
            m_double_val=StringToDouble(m_string_val);
            m_bool_val=m_string_val!=NULL;
            break;
         }
      }
      virtual string GetStr(char &jsonArray[],int startIndex,int length){
         #ifdef __MQL4__
               if(length<=0) return "";
         #endif
         char temporaryArray[];
         ArrayCopy(temporaryArray,jsonArray,0,startIndex,length);
         return CharArrayToString(temporaryArray, 0, WHOLE_ARRAY, CJSONValue::code_page);
      }

      virtual void Set(const CJSONValue &value){
         if(m_type==jv_UNDEF) {m_type=jv_OBJ;}
         CopyData(value);
      }
      virtual void Set(const CJSONValue &list[]);
      virtual CJSONValue *Add(const CJSONValue &item){
         if(m_type==jv_UNDEF){m_type=jv_ARRAY;}
         return AddBase(item);
      }
      virtual CJSONValue *Add(const int intVal){
         CJSONValue item(intVal);
         return Add(item);
      }
      virtual CJSONValue *Add(const long longVal){
         CJSONValue item(longVal);
         return Add(item);
      }
      virtual CJSONValue *Add(const double doubleVal){
         CJSONValue item(doubleVal);
         return Add(item);
      }
      virtual CJSONValue *Add(const bool boolVal){
         CJSONValue item(boolVal);
         return Add(item);
      }
      virtual CJSONValue *Add(string stringVal){
         CJSONValue item(jv_STR,stringVal);
         return Add(item);
      }
      virtual CJSONValue *AddBase(const CJSONValue &item){
         int currSize=ArraySize(m_elements);
         ArrayResize(m_elements,currSize+1);
         m_elements[currSize]=item;
         m_elements[currSize].m_parent=GetPointer(this);
         return GetPointer(m_elements[currSize]);
      }
      virtual CJSONValue *New(){
         if(m_type==jv_UNDEF) {m_type=jv_ARRAY;}
         return NewBase();
      }
      virtual CJSONValue *NewBase(){
         int currSize=ArraySize(m_elements);
         ArrayResize(m_elements,currSize+1);
         return GetPointer(m_elements[currSize]);
      }
   
      virtual string    Escape(string value);
      virtual string    Unescape(string value);
   public:
      virtual void      Serialize(string &jsonString,bool format=false,bool includeComma=false);
      virtual string    Serialize(){
         string jsonString;
         Serialize(jsonString);
         return jsonString;
      }
      virtual bool      Deserialize(char &jsonArray[],int length,int &currIndex);
      virtual bool      ExtrStr(char &jsonArray[],int length,int &currIndex);
      virtual bool      Deserialize(string jsonString,int encoding=CP_ACP){
         int currIndex=0;
         Clear();
         CJSONValue::code_page=encoding;
         char charArray[];
         int length=StringToCharArray(jsonString,charArray,0,WHOLE_ARRAY,CJSONValue::code_page);
         return Deserialize(charArray,length,currIndex);
      }
      virtual bool      Deserialize(char &jsonArray[],int encoding=CP_ACP){
         int currIndex=0;
         Clear();
         CJSONValue::code_page=encoding;
         return Deserialize(jsonArray,ArraySize(jsonArray),currIndex);
      }
};

int CJSONValue::code_page=CP_ACP;

//------------------------------------------------------------------ HasKey
CJSONValue *CJSONValue::HasKey(string key,JSONValueType type){
   for(int i=0; i<ArraySize(m_elements); i++) if(m_elements[i].m_key==key){
      if(type==jv_UNDEF || type==m_elements[i].m_type){
         return GetPointer(m_elements[i]);
      }
      break;
   }
   return NULL;
}
//------------------------------------------------------------------ operator[]
CJSONValue *CJSONValue::operator[](string key){
   if(m_type==jv_UNDEF){m_type=jv_OBJ;}
   CJSONValue *value=FindKey(key);
   if(value){return value;}
   CJSONValue newValue(GetPointer(this),jv_UNDEF);
   newValue.m_key=key;
   value=Add(newValue);
   return value;
}
//------------------------------------------------------------------ operator[]
CJSONValue *CJSONValue::operator[](int i){
   if(m_type==jv_UNDEF) m_type=jv_ARRAY;
   while(i>=ArraySize(m_elements)){
      CJSONValue newElement(GetPointer(this),jv_UNDEF);
      if(CheckPointer(Add(newElement))==POINTER_INVALID){return NULL;}
   }
   return GetPointer(m_elements[i]);
}
//------------------------------------------------------------------ Set
void CJSONValue::Set(const CJSONValue &list[]){
   if(m_type==jv_UNDEF){m_type=jv_ARRAY;}
   int elementsSize=ArrayResize(m_elements,ArraySize(list));
   for(int i=0; i<elementsSize; ++i){
      m_elements[i]=list[i];
      m_elements[i].m_parent=GetPointer(this);
   }
}
//------------------------------------------------------------------ Serialize
void CJSONValue::Serialize(string &jsonString,bool key,bool includeComma){
   if(m_type==jv_UNDEF){return;}
   if(includeComma){jsonString+=",";}
   if(key){jsonString+=StringFormat("\"%s\":", m_key);}
   int elementsSize=ArraySize(m_elements);
   switch(m_type){
   case jv_NULL:
      jsonString+="null";
      break;
   case jv_BOOL:
      jsonString+=(m_bool_val?"true":"false");
      break;
   case jv_INT:
      jsonString+=IntegerToString(m_int_val);
      break;
   case jv_DBL:
      jsonString+=DoubleToString(m_double_val);
      break;
   case jv_STR:
   {
      string value=Escape(m_string_val);
      if(StringLen(value)>0){jsonString+=StringFormat("\"%s\"",value);}
      else{jsonString+="null";}
   }
   break;
   case jv_ARRAY:
      jsonString+="[";
      for(int i=0; i<elementsSize; i++){m_elements[i].Serialize(jsonString,false,i>0);}
      jsonString+="]";
      break;
   case jv_OBJ:
      jsonString+="{";
      for(int i=0; i<elementsSize; i++){m_elements[i].Serialize(jsonString,true,i>0);}
      jsonString+="}";
      break;
   }
}
//------------------------------------------------------------------ Deserialize
bool CJSONValue::Deserialize(char &jsonArray[],int length,int &currIndex){
   string validNumberChars="0123456789+-.eE";
   int startIndex=currIndex;
   for(; currIndex<length; currIndex++){
      char currChar=jsonArray[currIndex];
      if(currChar==0){break;}
      switch(currChar){
      case '\t':
      case '\r':
      case '\n':
      case ' ': // skip
         startIndex=currIndex+1;
         break;

      case '[': // the beginning of the object. create an object and take it from js
      {
         startIndex=currIndex+1;
         if(m_type!=jv_UNDEF){
            if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));} // if the value already has a type, then this is an error
            return false;
         }
         m_type=jv_ARRAY; // set the type
         currIndex++;
         CJSONValue val(GetPointer(this),jv_UNDEF);
         while(val.Deserialize(jsonArray,length,currIndex)){
            if(val.m_type!=jv_UNDEF){Add(val);}
            if(val.m_type==jv_INT || val.m_type==jv_DBL || val.m_type==jv_ARRAY){currIndex++;}
            val.Clear();
            val.m_parent=GetPointer(this);
            if(jsonArray[currIndex]==']'){break;}
            currIndex++;
            if(currIndex>=length){
               if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}
               return false;
            }
         }
         return (jsonArray[currIndex]==']' || jsonArray[currIndex]==0);
      }
      break;
      case ']':
         if(!m_parent){return false;}
         return (m_parent.m_type==jv_ARRAY); // end of array, current value must be an array

      case ':':
      {
         if(m_lkey==""){
            if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}
            return false;
         }
         CJSONValue val(GetPointer(this),jv_UNDEF);
         CJSONValue *oc=Add(val); // object type is not defined yet
         oc.m_key=m_lkey;
         m_lkey=""; // set the key name
         currIndex++;
         if(!oc.Deserialize(jsonArray,length,currIndex)){
            if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}
            return false;
         }
         break;
      }
      case ',': // value separator // value type must already be defined
         startIndex=currIndex+1;
         if(!m_parent && m_type!=jv_OBJ){
            if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}
            return false;
         }
         else if(m_parent){
            if(m_parent.m_type!=jv_ARRAY && m_parent.m_type!=jv_OBJ){
               if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}
               return false;
            }
            if(m_parent.m_type==jv_ARRAY && m_type==jv_UNDEF){return true;}
         }
         break;

      // primitives can ONLY be in an array / or on their own
      case '{': // the beginning of the object. create an object and take it from js
         startIndex=currIndex+1;
         if(m_type!=jv_UNDEF){
            if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}   // type error
            return false;
         }
         m_type=jv_OBJ; // set type of value
         currIndex++;
         if(!Deserialize(jsonArray,length,currIndex)){
            if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}   // pull it out
            return false;
         }
         return (jsonArray[currIndex]=='}' || jsonArray[currIndex]==0);
         break;
      case '}':
         return (m_type==jv_OBJ); // end of object, current value must be object

      case 't':
      case 'T': // start true
      case 'f':
      case 'F': // start false
         if(m_type!=jv_UNDEF){
            if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}   // type error
            return false;
         }
         m_type=jv_BOOL; // set type
         if(currIndex+3<length){
            if(StringCompare(GetStr(jsonArray, currIndex, 4), "true", false)==0){
               m_bool_val=true;
               currIndex+=3;
               return true;
            }
         }
         if(currIndex+4<length){
            if(StringCompare(GetStr(jsonArray, currIndex, 5), "false", false)==0){
               m_bool_val=false;
               currIndex+=4;
               return true;
            }
         }
         if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}
         return false; //wrong type or end of line
         break;
      case 'n':
      case 'N': // start null
         if(m_type!=jv_UNDEF){
            if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}   // type error
            return false;
         }
         m_type=jv_NULL; // set type of value
         if(currIndex+3<length){
            if(StringCompare(GetStr(jsonArray,currIndex,4),"null",false)==0){
               currIndex+=3;
               return true;
            }
         }
         if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}
         return false; // not NULL or end of line
         break;

      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
      case '-':
      case '+':
      case '.': // start of number
      {
         if(m_type!=jv_UNDEF){
            if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}   // type error
            return false;
         }
         bool dbl=false;// set typo of value
         int is=currIndex;
         while(jsonArray[currIndex]!=0 && currIndex<length){
            currIndex++;
            if(StringFind(validNumberChars,GetStr(jsonArray,currIndex,1))<0){break;}
            if(!dbl){dbl=(jsonArray[currIndex]=='.' || jsonArray[currIndex]=='e' || jsonArray[currIndex]=='E');}
         }
         m_string_val=GetStr(jsonArray,is,currIndex-is);
         if(dbl){
            m_type=jv_DBL;
            m_double_val=StringToDouble(m_string_val);
            m_int_val=(long)m_double_val;
            m_bool_val=m_int_val!=0;
         }
         else{
            m_type=jv_INT;   // clarified the value type
            m_int_val=StringToInteger(m_string_val);
            m_double_val=(double)m_int_val;
            m_bool_val=m_int_val!=0;
         }
         currIndex--;
         return true; // moved back a character and exited
         break;
      }
      case '\"': // start or end of line
         if(m_type==jv_OBJ){ // if the type is still undefined and the key is not set
            currIndex++;
            int is=currIndex;
            if(!ExtrStr(jsonArray,length,currIndex)){
               if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}   // this is the key, go to the end of line
               return false;
            }
            m_lkey=GetStr(jsonArray,is,currIndex-is);
         }
         else{
            if(m_type!=jv_UNDEF){
               if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}   // type error
               return false;
            }
            m_type=jv_STR; // set type of value
            currIndex++;
            int is=currIndex;
            if(!ExtrStr(jsonArray,length,currIndex)){
               if(DEBUG_PRINT){Print(m_key+" "+string(__LINE__));}
               return false;
            }
            FromStr(jv_STR,GetStr(jsonArray,is,currIndex-is));
            return true;
         }
         break;
      }
   }
   return true;
}
//------------------------------------------------------------------ ExtrStr
bool CJSONValue::ExtrStr(char &jsonArray[],int length,int &i){
   for(; jsonArray[i]!=0 && i<length; i++){
      char currChar=jsonArray[i];
      if(currChar=='\"') break; // end if line
      if(currChar=='\\' && i+1<length){
         i++;
         currChar=jsonArray[i];
         switch(currChar){
         case '/':
         case '\\':
         case '\"':
         case 'b':
         case 'f':
         case 'r':
         case 'n':
         case 't':
            break; // allowed
         case 'u': // \uXXXX
         {
            i++;
            for(int j=0; j<4 && i<length && jsonArray[i]!=0; j++,i++){
               if(!((jsonArray[i]>='0' && jsonArray[i]<='9') || (jsonArray[i]>='A' && jsonArray[i]<='F') || (jsonArray[i]>='a' && jsonArray[i]<='f'))){
                  if(DEBUG_PRINT){Print(m_key+" "+CharToString(jsonArray[i])+" "+string(__LINE__));}   // not hex
                  return false;
               }
            }
            i--;
            break;
         }
         default:
            break; /*{ return false; } // unresolved escaped character */
         }
      }
   }
   return true;
}
//------------------------------------------------------------------ Escape
string CJSONValue::Escape(string stringValue){
   ushort inputChars[], escapedChars[];
   int inputLength=StringToShortArray(stringValue, inputChars);
   if(ArrayResize(escapedChars, 2*inputLength)!=2*inputLength){return NULL;}
   int escapedIndex=0;
   for(int i=0; i<inputLength; i++){
      switch(inputChars[i]){
      case '\\':
         escapedChars[escapedIndex]='\\';
         escapedIndex++;
         escapedChars[escapedIndex]='\\';
         escapedIndex++;
         break;
      case '"':
         escapedChars[escapedIndex]='\\';
         escapedIndex++;
         escapedChars[escapedIndex]='"';
         escapedIndex++;
         break;
      case '/':
         escapedChars[escapedIndex]='\\';
         escapedIndex++;
         escapedChars[escapedIndex]='/';
         escapedIndex++;
         break;
      case 8:
         escapedChars[escapedIndex]='\\';
         escapedIndex++;
         escapedChars[escapedIndex]='b';
         escapedIndex++;
         break;
      case 12:
         escapedChars[escapedIndex]='\\';
         escapedIndex++;
         escapedChars[escapedIndex]='f';
         escapedIndex++;
         break;
      case '\n':
         escapedChars[escapedIndex]='\\';
         escapedIndex++;
         escapedChars[escapedIndex]='n';
         escapedIndex++;
         break;
      case '\r':
         escapedChars[escapedIndex]='\\';
         escapedIndex++;
         escapedChars[escapedIndex]='r';
         escapedIndex++;
         break;
      case '\t':
         escapedChars[escapedIndex]='\\';
         escapedIndex++;
         escapedChars[escapedIndex]='t';
         escapedIndex++;
         break;
      default:
         escapedChars[escapedIndex]=inputChars[i];
         escapedIndex++;
         break;
      }
   }
   stringValue=ShortArrayToString(escapedChars,0,escapedIndex);
   return stringValue;
}
//------------------------------------------------------------------ Unescape
string CJSONValue::Unescape(string stringValue){
   ushort inputChars[], unescapedChars[];
   int inputLength=StringToShortArray(stringValue, inputChars);
   if(ArrayResize(unescapedChars, inputLength)!=inputLength){return NULL;}
   int j=0,i=0;
   while(i<inputLength){
      ushort currChar=inputChars[i];
      if(currChar=='\\' && i<inputLength-1){
         switch(inputChars[i+1]){
         case '\\':
            currChar='\\';
            i++;
            break;
         case '"':
            currChar='"';
            i++;
            break;
         case '/':
            currChar='/';
            i++;
            break;
         case 'b':
            currChar=8;
            i++;
            break;
         case 'f':
            currChar=12;
            i++;
            break;
         case 'n':
            currChar='\n';
            i++;
            break;
         case 'r':
            currChar='\r';
            i++;
            break;
         case 't':
            currChar='\t';
            i++;
            break;
         }
      }
      unescapedChars[j]=currChar;
      j++;
      i++;
   }
   stringValue=ShortArrayToString(unescapedChars,0,j);
   return stringValue;
}
//+------------------------------------------------------------------+










#define TELEGRAM_BASE_URL "https://api.telegram.org"
#define InpToken </... your url here ...\>
#define WEB_TIMEOUT 5000

#include <Arrays/List.mqh>
#include <Arrays/ArrayString.mqh>
#include <Trade/Trade.mqh>

// chat id = 6423570585
//https://api.telegram.org/bot7343408437:AAGszCjLfzEJbnuABlsrcDLt_MeZd98DAAw/getUpdates

int PostRequest(string &response,const string url,const string params,
                const int timeout=5000){
   char data[];
   int data_size = StringLen(params);
   StringToCharArray(params,data,0,data_size);
   
   uchar result[];
   string result_headers;
   
   int response_code = WebRequest("POST",url,NULL,NULL,timeout,data,data_size,result,result_headers);
   
   if (response_code==200){
      // delete the BOM = BYTE ORDER MARK
      int start_index = 0;
      int size = ArraySize(result);
      for (int i=0; i<fmin(size, 8); i++){
         if (result[i]==0xef || result[i]==0xbb || result[i]==0xbf){
            start_index=i+1;
         }
         else {break;}
      }
      response=CharArrayToString(result,start_index,WHOLE_ARRAY,CP_UTF8);
      //Print("SUCCESS RESPONSE RESULT = ",response); //"ok": true,"result": [{
      return (0);
   }
   else {
      if (response_code==-1){return (_LastError);}
      else {
         // it then could be an http error
         if (response_code>=100 && response_code<=511){
            response=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
            Print("ERROR RESPONSE RESULT = ",response);
            return(-1);
         }
         return (response_code);
      }
   }
   return (0);
}

string StringDecode (string text){
   // \n with its ASCII equivalent (the hexadecimal 0x0A)
   StringReplace(text,"\n",ShortToString(0x0A));
   
   //--- replace \u0000
   int highSurrogate = 0;
   int pos = StringFind(text,"\\u");
   while (pos!=-1){
      string strhex = StringSubstr(text,pos+2,4);
      StringToUpper(strhex);
      
      int total=StringLen(strhex);
      int result = 0;
      for (int i=0,k=total-1; i<total; i++,k--){
         int coeff = (int)pow(2,4*k);
         ushort character = StringGetCharacter(strhex,i);
         if (character>='0' && character<= '9'){result+=(character-'0')*coeff;}
         if (character>='A' && character<= 'F'){result+=(character-'A'+10)*coeff;}
      }
      
      if (highSurrogate!=0){
         if (result >=0xDC00 && result <= 0xDFFF){// result is a low surrogate pair
            int dec=((highSurrogate-0xD800)<<10)+(result-0xDC00); // +0x10000
            // replace the ex string
            StringReplaceEx(text,pos,6,ShortToString((ushort)dec));
            highSurrogate = 0;
         }
         else {
            highSurrogate = 0;
         }
      }
      else { // if the result is a high surrogate
         if (result >= 0xD800 && result <= 0xDBFF){
            highSurrogate = result;
            StringReplaceEx(text,pos,6,"");
         }
         else {
            StringReplaceEx(text,pos,6,ShortToString((ushort)result));
         }
      }
      pos = StringFind(text,"\\u",pos);
   }
   
   return (text);
}

int StringReplaceEx(string &string_var,const int start_pos,const int length,
                    const string replacement){
   string temporaryString = (start_pos==0) ? "" : StringSubstr(string_var,0,start_pos);
   temporaryString+=replacement;
   temporaryString+=StringSubstr(string_var,start_pos+length);
   string_var=temporaryString;
   return (StringLen(replacement));
}

string Token_Trimmed(const string bot_token){
   string token = StringTrim(bot_token);
   if (token==""){
      Print("ERROR: TOKEN IS EMPTY");
      return ("NULL");
   }
   return (token);
}

string StringTrim(string text){
   StringTrimLeft(text);
   StringTrimRight(text);
   return (text);
}

int SendMessage(const long chat_id,const string text,
                const string reply_markup=NULL){
   string output;
   string url = TELEGRAM_BASE_URL+"/bot"+Token_Trimmed(InpToken)+"/sendMessage";
   string params = "chat_id="+IntegerToString(chat_id)+"&text="+urlEncode(text);
   if (reply_markup!=NULL){
      params+="&reply_markup="+reply_markup;
   }
   params+="&parse_mode=HTML";
   params+="&disable_web_page_preview=true";
   int res = PostRequest(output,url,params,WEB_TIMEOUT);
   return (res);
}

string urlEncode(const string text){
   string result=NULL;
   int length=StringLen(text);
   for (int i=0; i<length; i++){
      ushort character = StringGetCharacter(text,i);
      if ((character>=48 && character <= 57) || // 0-9
         (character>=65 && character<=90) || // A-Z
         (character>=97 && character<=122) || // a-z
         (character=='!') || (character=='\'') || (character=='(') ||
         (character==')') || (character=='*') || (character=='-') ||
         (character=='.') || (character=='_') || (character=='~')
      ){
         result+=ShortToString(character);
      }
      else {
         if (character==' '){
            result+=ShortToString('+');
         }
         else {
            uchar array[];
            int total = ShortToUtf8(character,array);
            for (int k=0; k<total; k++){
               result+=StringFormat("%%%02X",array[k]);
            }
         }
      }
   }
   return (result);
}

//+------------------------------------------------------------------+
int ShortToUtf8(const ushort character,uchar &output[]){
   //---
   if(character<0x80){
      ArrayResize(output,1);
      output[0]=(uchar)character;
      return(1);
   }
   //---
   if(character<0x800){
      ArrayResize(output,2);
      output[0] = (uchar)((character >> 6)|0xC0);
      output[1] = (uchar)((character & 0x3F)|0x80);
      return(2);
   }
   //---
   if(character<0xFFFF){
      if(character>=0xD800 && character<=0xDFFF){//Ill-formed
         ArrayResize(output,1);
         output[0]=' ';
         return(1);
      }
      else if(character>=0xE000 && character<=0xF8FF){//Emoji
         int character_int=0x10000|character;
         ArrayResize(output,4);
         output[0] = (uchar)(0xF0 | (character_int >> 18));
         output[1] = (uchar)(0x80 | ((character_int >> 12) & 0x3F));
         output[2] = (uchar)(0x80 | ((character_int >> 6) & 0x3F));
         output[3] = (uchar)(0x80 | ((character_int & 0x3F)));
         return(4);
      }
      else{
         ArrayResize(output,3);
         output[0] = (uchar)((character>>12)|0xE0);
         output[1] = (uchar)(((character>>6)&0x3F)|0x80);
         output[2] = (uchar)((character&0x3F)|0x80);
         return(3);
      }
   }
   ArrayResize(output,3);
   output[0] = 0xEF;
   output[1] = 0xBF;
   output[2] = 0xBD;
   return(3);
}

string replyKeyboardMarkup(const string keyboard, const bool resize,
                           const bool one_time
){
   string result = "{\"keyboard\": "+urlEncode(keyboard)+", \"one_time_keyboard\": "+
                  BoolToString(resize)+", \"resize_keyboard\": "+
                  BoolToString(one_time)+", \"selective\": false}";
   return (result);
}

string BoolToString(const bool val){
   if (val){return("true");}
   return ("false");
}

string replyKeyboardHide(){
   return ("{\"hide_keyboard\": true}");
}

string replyKeyboardForceReply(){
   return ("{\"force_reply\": true}");
}


class CMessage : public CObject{
   public:
      CMessage();// class constructor
      ~CMessage(){};// class destructor
      bool done;
      long update_id;
      long message_id;
      
      long from_id;
      string from_first_name;
      string from_last_name;
      string from_username;
      
      long chat_id;
      string chat_first_name;
      string chat_last_name;
      string chat_username;
      string chat_type;
      
      datetime message_date;
      string message_text;
};

CMessage::CMessage(void){// :: scope operator
   done=false;
   update_id=0;
   message_id=0;
   from_id=0;
   from_first_name=NULL;
   from_last_name=NULL;
   from_username=NULL;
   chat_id=0;
   chat_first_name=NULL;
   chat_last_name=NULL;
   chat_username=NULL;
   chat_type=NULL;
   message_date=0;
   message_text=NULL;
}

class CChat : public CObject{
   public:
   CChat(){};
   ~CChat(){};
   long m_id; // m = members
   int m_state;
   datetime m_time;
   CMessage m_last;
   CMessage m_new_one;
};

class CBot_EA{ // private, protected, public
   private:
      string m_token;
      string m_name;
      long m_update_id;
      CArrayString m_users_filter;
      bool m_first_remove;
   protected:
      CList m_chats;
   public:
      void CBot_EA();
      ~CBot_EA(){};
      int getUpdates();
      void processMessages();
};

void CBot_EA::CBot_EA(void){
   m_token=NULL;
   m_token=Token_Trimmed(InpToken);
   m_name=NULL;
   m_update_id=0;
   m_users_filter.Clear();
   m_first_remove=true;
   m_chats.Clear();
}

int CBot_EA::getUpdates(void){
   if (m_token==NULL){
      Print("ERROR: TOKEN IS EMPTY");
      return (-1);
   }
   
   string out;
   
   string url = TELEGRAM_BASE_URL+"/bot"+m_token+"/getUpdates";
   string params = "offset="+IntegerToString(m_update_id);
   
   int res = PostRequest(out,url,params,WEB_TIMEOUT);
   
   if (res==0){
      //Print("OUTPUT = ",out);
      // PARSE THE RESULT
      CJSONValue obj_json(NULL,jv_UNDEF);
      bool done = obj_json.Deserialize(out);
      if (!done){
         Print("ERROR: JSON PARSING FAILED");
         return (-1);
      }
      
      bool ok = obj_json["ok"].ToBool();
      if (!ok){
         Print("ERROR: JSON NOT OK");
         return (-1);
      }
      
      CMessage obj_msg;
      
      int total = ArraySize(obj_json["result"].m_elements);
      for (int i=0; i<total; i++){
         CJSONValue obj_item = obj_json["result"].m_elements[i];
         
         obj_msg.update_id=obj_item["update_id"].ToInt();
         
         obj_msg.message_id=obj_item["message"]["message_id"].ToInt();
         obj_msg.message_date=(datetime)obj_item["message"]["date"].ToInt();
         
         obj_msg.message_text=obj_item["message"]["text"].ToStr();
         //Print(obj_msg.message_text);
         // we need to decode the text message of any html entities
         obj_msg.message_text=StringDecode(obj_msg.message_text);
         //Print(obj_msg.message_text);
         
         obj_msg.from_id=obj_item["message"]["from"]["id"].ToInt();
         
         obj_msg.from_first_name=obj_item["message"]["from"]["first_name"].ToStr();
         obj_msg.from_first_name=StringDecode(obj_msg.from_first_name);
         
         obj_msg.from_last_name=obj_item["message"]["from"]["last_name"].ToStr();
         obj_msg.from_last_name=StringDecode(obj_msg.from_last_name);
         
         obj_msg.from_username=obj_item["message"]["from"]["username"].ToStr();
         obj_msg.from_username=StringDecode(obj_msg.from_username);
         
         // we now extract chat details from the JSON object
         obj_msg.chat_id=obj_item["message"]["chat"]["id"].ToInt();
         
         obj_msg.chat_first_name=obj_item["message"]["chat"]["first_name"].ToStr();
         obj_msg.chat_first_name=StringDecode(obj_msg.chat_first_name);
         
         obj_msg.chat_last_name=obj_item["message"]["chat"]["last_name"].ToStr();
         obj_msg.chat_last_name=StringDecode(obj_msg.chat_last_name);
         
         obj_msg.chat_username=obj_item["message"]["chat"]["username"].ToStr();
         obj_msg.chat_username=StringDecode(obj_msg.chat_username);
         
         obj_msg.chat_type=obj_item["message"]["chat"]["type"].ToStr();
         
         m_update_id=obj_msg.update_id+1;
         
         
         if (m_first_remove){
            continue;
         }
         
         if (m_users_filter.Total()==0 ||
            (m_users_filter.Total()> 0 &&
            m_users_filter.SearchLinear(obj_msg.from_username) > 0)
         ){
            int index = -1;
            for (int j=0; j<m_chats.Total(); j++){
               CChat *chat=m_chats.GetNodeAtIndex(j);
               if (chat.m_id==obj_msg.chat_id){
                  index = j;
                  break;
               }
            }
            if (index == -1){
               m_chats.Add(new CChat);
               CChat *chat = m_chats.GetLastNode();
               chat.m_id=obj_msg.chat_id;
               chat.m_time=TimeLocal();
               chat.m_state=0;
               chat.m_new_one.message_text=obj_msg.message_text;
               chat.m_new_one.done=false;
            }
            else {
               CChat *chat=m_chats.GetNodeAtIndex(index);
               chat.m_time=TimeLocal();
               chat.m_new_one.message_text=obj_msg.message_text;
               chat.m_new_one.done=false;
            }
         }
      }
      m_first_remove=false;
   }
   
   return (res);
}

void CBot_EA::processMessages(void){
   
   #define EMOJI_UP "\X2B06"
   #define EMOJI_PISTOL "\xF52B"
   #define EMOJI_CANCEL "\x274C"
   #define KEYB_MAIN "[[\"Name\"],[\"Account Info\"],[\"Quotes\"],[\"More\",\""+EMOJI_CANCEL+"\"]]"
   #define KEYB_MORE "[[\""+EMOJI_UP+"\"],[\"Buy\",\"Close\",\"Next\"]]"
   #define KEYB_NEXT "[[\""+EMOJI_UP+"\",\"Contact\",\"Join\",\""+EMOJI_PISTOL+"\"]]"

   for (int i=0; i<m_chats.Total(); i++){
      CChat *chat=m_chats.GetNodeAtIndex(i);
      if (!chat.m_new_one.done){
         chat.m_new_one.done=true;
         string text = chat.m_new_one.message_text;
         
         //U+1F680 0xF680 ROCKET EMOJI
         
         if (text=="/start" || text=="Start" || text=="/help" || text=="Help"){
            // send message
            string message = "I am a Bot \xF680 and I work with your trading account.\n";
            message+="You can control me by sending these commands \xF648 \n";
            message+="\nInformation\n";
            message+="/name - get EA name\n";
            message+="/info - get account information\n";
            message+="/quotes - get quotes\n";
            message+="\nTrading Operations\n";
            message+="/buy - open a buy position\n";
            message+="/close - close a position\n";
            message+="\nMore Options\n";
            message+="/contact - contact the developer\n";
            message+="/join - join Our MQL5 Community\n";
            
            SendMessage(chat.m_id,message,replyKeyboardMarkup(KEYB_MAIN,false,false));
            continue;
         }
         
         if (text=="/name" || text=="Name"){
            string message = "The file name of the EA that I control is:\n";
            message+="\xF50B"+__FILE__+". Now you have it. Be Happy!";
            
            SendMessage(chat.m_id,message);
            continue;
         }
         
         ushort moneybag = 0xF4B0;
         string moneybagcode = ShortToString(moneybag);
         if (text=="/info" || text=="Account Info"){
            string currency = AccountInfoString(ACCOUNT_CURRENCY);
            string message = "\xF692\Account No: "+(string)AccountInfoInteger(ACCOUNT_LOGIN)+"\n";
            message+="\x23F0\Account Server: "+AccountInfoString(ACCOUNT_SERVER)+"\n";
            message+="\x2705\Balance: "+(string)AccountInfoDouble(ACCOUNT_BALANCE)+" "+currency+"\n";
            message+=moneybagcode+"Profit: "+(string)AccountInfoDouble(ACCOUNT_PROFIT)+" "+currency+"\n";
            SendMessage(chat.m_id,message);
            continue;
         }
         if (text=="/quotes" || text=="Quotes"){
            double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            string message="\xF170 Ask: "+string(Ask)+"\n";
            message+="\xF171 Bid: "+string(Bid)+"\n";
            SendMessage(chat.m_id,message);
            continue;
         }
         if (text=="/buy" || text=="Buy"){
            CTrade obj_Trade;
            double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            obj_Trade.Buy(0.01,NULL,0,Bid-300*_Point,Bid+300*_Point);
            double entry=0,sl=0,tp=0,vol=0;
            ulong ticket = obj_Trade.ResultOrder();
            if (ticket > 0){
               if (PositionSelectByTicket(ticket)){
                  entry=PositionGetDouble(POSITION_PRICE_OPEN);
                  sl=PositionGetDouble(POSITION_SL);
                  tp=PositionGetDouble(POSITION_TP);
                  vol=PositionGetDouble(POSITION_VOLUME);
               }
            }
            string message="\xF340\Opened Buy Position:\n";
            message+="Ticket: "+(string)ticket+"\n";
            message+="Open price: "+(string)entry+"\n";
            message+="Lots: "+(string)vol+"\n";
            message+="SL: "+(string)sl+"\n";
            message+="TP: "+(string)tp+"\n";
            SendMessage(chat.m_id,message);
            continue;
         }
         if (text=="/close" || text=="Close"){
            CTrade obj_Trade;
            int totalOpenBefore = PositionsTotal();
            obj_Trade.PositionClose(_Symbol);
            int totalOpenAfter = PositionsTotal();
            string message="\xF62F\Closed position:\n";
            message+="Total positions (Before): "+string(totalOpenBefore)+"\n";
            message+="Total positions (After): "+string(totalOpenAfter)+"\n";
            SendMessage(chat.m_id,message);
            continue;
         }
         if (text=="/contact" || text=="Contact"){
            string message="Contact the developer via the link below:\n";
            message+="https://t.me/Forex_Algo_Trader\n";
            SendMessage(chat.m_id,message);
            continue;
         }
         if (text=="/join" || text=="Join"){
            string message="You want to be part of our MQL5 Community?\n";
            message+="Welcome! <a href=\"https://t.me/forexalgo_trading\">Click me</a> to join.\n";
            message+="<s>Civil Engineering</s> Forex AlgoTrading\n";
            message+="<pre>This is a sample of our MQL5 code</pre>\n";
            message+="<u><i>Recall to follow community guidelines!\xF64F\</i></u>\n";
            message+="<b>Happy Trading!</b>\n";
            SendMessage(chat.m_id,message);
            continue;
         }
         if (text=="more" || text=="More"){
            chat.m_state=1;
            string message = "Choose a menu item:";
            SendMessage(chat.m_id,message,replyKeyboardMarkup(KEYB_MORE,false,true));
            continue;
         }
         if (text=="next" || text=="Next"){
            chat.m_state=2;
            string message="Choose still more options below:";
            SendMessage(chat.m_id,message,replyKeyboardMarkup(KEYB_NEXT,false,true));
            continue;
         }
         
         if (text==EMOJI_UP){
            chat.m_state=0;
            string message = "Choose a menu item:";
            SendMessage(chat.m_id,message,replyKeyboardMarkup(KEYB_MAIN,false,true));
            continue;
         }
         if (text==EMOJI_PISTOL){
            if (chat.m_state==2){
               chat.m_state=1;
               string message="Choose still more options below:";
               SendMessage(chat.m_id,message,replyKeyboardMarkup(KEYB_MORE,false,true));
            }
            else {
               chat.m_state=0;
               string message = "Choose a menu item:";
               SendMessage(chat.m_id,message,replyKeyboardMarkup(KEYB_MAIN,false,false));
            }
            continue;
         }
         
         if (text==EMOJI_CANCEL){
            chat.m_state=0;
            string message = "Choose /start or /help to begin.";
            //SendMessage(chat.m_id,message,replyKeyboardForceReply());
            SendMessage(chat.m_id,message,replyKeyboardHide());
            continue;
         }
      }
   }
}


//+------------------------------------------------------------------+
//|                                      TELEGRAM BOT TO MQL5 EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

CBot_EA obj_Bot;

int OnInit(){
   EventSetMillisecondTimer(3000);
   OnTimer();
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){
   EventKillTimer();
}
void OnTimer(){
   obj_Bot.getUpdates();
   obj_Bot.processMessages();
}
