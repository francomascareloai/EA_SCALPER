//+------------------------------------------------------------------+
//|                                               JSON Code File.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, mutiiriallan.forex@gmail.com."
#property link      "Telegram: https://t.me/Forex_Algo_Trader"
#property description "Incase of anything with this Version of EA, Contact:\n"
                      "\nEMAIL: mutiiriallan.forex@gmail.com"
                      "\nWhatsApp: +254 782 526088"
                      "\nTelegram: https://t.me/Forex_Algo_Trader"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){return(INIT_SUCCEEDED);}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){}
//+------------------------------------------------------------------+







// JSON (JavaScript Object Notation)
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