
#property copyright "Sciurus 2015"

#property indicator_separate_window
#property indicator_buffers 17


#import "user32.dll"
   int GetDC(int hwnd);
   int ReleaseDC(int hwnd,int hdc);
#import "gdi32.dll"
   color GetPixel(int hdc,int x,int y);
#import


extern bool    showCumulative = true;
extern bool    recordTicks = true;
extern bool    printHistory = true;
extern color   dnColor = Crimson;
extern color   upColor = Green;
extern bool    showCorr = false;
extern int     corrPeriod = 20;


double closed[],opened[],highed[],lowed[];

static double Up_Body_Green[];
static double Dn_Body_Red[];
static double EqBodyBuffer[];
static double Bg_Body_Black[];
static double Up_Wick_Green[];
static double Dn_Wick_Red[];
static double EqShadowBuffer[];
static double Bg_Wick_Black[];
static double Dn_Body_Green[];
static double Up_Body_Red[];
static double Dn_Wick_Green[];
static double Up_Wick_Red[];
static double correlation[];

double Curr_Bid;
double Prev_Bid;
double Curr_Ask;
double Prev_Ask;
double Curr_Vol;
double Prev_Vol;
datetime timestamp;
color bkg_color;
int handle=0;
bool firstTick=true;

int init() {

  IndicatorBuffers(17); 
  SetIndexBuffer(0,closed);             SetIndexEmptyValue(0,0);  SetIndexStyle(0,DRAW_NONE);
  SetIndexBuffer(1,opened);             SetIndexEmptyValue(1,0);  SetIndexStyle(1,DRAW_NONE);
  SetIndexBuffer(2,highed);             SetIndexEmptyValue(2,0);  SetIndexStyle(2,DRAW_NONE);
  SetIndexBuffer(3,lowed);              SetIndexEmptyValue(3,0);  SetIndexStyle(3,DRAW_NONE); 
  SetIndexBuffer(4,Up_Body_Green);      SetIndexEmptyValue(4,0);  SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,3,upColor);
  SetIndexBuffer(5,Dn_Body_Red);        SetIndexEmptyValue(5,0);  SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,3,dnColor);
  SetIndexBuffer(6,EqBodyBuffer);       SetIndexEmptyValue(6,0);  SetIndexStyle(6,DRAW_HISTOGRAM,STYLE_SOLID,3,White); 
  SetIndexBuffer(7,Bg_Body_Black);      SetIndexEmptyValue(7,0);  SetIndexStyle(7,DRAW_HISTOGRAM,STYLE_SOLID,3,bkg_color);
  SetIndexBuffer(8,Up_Wick_Green);      SetIndexEmptyValue(8,0);  SetIndexStyle(8,DRAW_HISTOGRAM,STYLE_SOLID,1,upColor);
  SetIndexBuffer(9,Dn_Wick_Red);        SetIndexEmptyValue(9,0);  SetIndexStyle(9,DRAW_HISTOGRAM,STYLE_SOLID,1,dnColor);
  SetIndexBuffer(10,EqShadowBuffer);    SetIndexEmptyValue(10,0); SetIndexStyle(10,DRAW_HISTOGRAM,STYLE_SOLID,1,White);
  SetIndexBuffer(11,Bg_Wick_Black);     SetIndexEmptyValue(11,0); SetIndexStyle(11,DRAW_HISTOGRAM,STYLE_SOLID,1,bkg_color);
  SetIndexBuffer(12,Dn_Body_Green);     SetIndexEmptyValue(12,0); SetIndexStyle(12,DRAW_HISTOGRAM,STYLE_SOLID,3,upColor);
  SetIndexBuffer(13,Up_Body_Red);       SetIndexEmptyValue(13,0); SetIndexStyle(13,DRAW_HISTOGRAM,STYLE_SOLID,3,dnColor);
  SetIndexBuffer(14,Dn_Wick_Green);     SetIndexEmptyValue(14,0); SetIndexStyle(14,DRAW_HISTOGRAM,STYLE_SOLID,1,upColor);
  SetIndexBuffer(15,Up_Wick_Red);       SetIndexEmptyValue(15,0); SetIndexStyle(15,DRAW_HISTOGRAM,STYLE_SOLID,1,dnColor);
  SetIndexBuffer(16,correlation);       SetIndexEmptyValue(16,0); SetIndexStyle(16,DRAW_LINE, STYLE_SOLID, 2, Yellow);
   
   int load = iBars(Symbol(),0); // force load bars in history
   
   closed[1]=0;
   opened[1]=0;
   highed[1]=0;
   lowed[1]=0;
   closed[0]=0;
   opened[0]=0;
   highed[0]=0;
   lowed[0]=0;
  
   return (0);
}

/////////////////////////////////////////////////////////////////////////////
//            DEINITIALIZATION FUNCTION                                    //
/////////////////////////////////////////////////////////////////////////////


int deinit() {

   if (handle==1){
      FileClose(handle);
   }
   return (0);
}


/////////////////////////////////////////////////////////////////////////////
//           START FUNCTION: PERFORM ON EVERY TICK                         //
/////////////////////////////////////////////////////////////////////////////

int start(){


         //Handle the background color. This function will set the background color to the pixel at location 1,2    
         int hwnd=WindowHandle(Symbol(),Period());
         int hdc=GetDC(hwnd);
         bkg_color=GetPixel(hdc,1,2);
         ReleaseDC(hwnd,hdc);
         if (bkg_color!=4294967295)//4294967295 is the code for NONE, and hence I don't want to be showing that color if the edge of the window is off screen or if there is another window on top of mt4
         { 
            SetIndexStyle(7,DRAW_HISTOGRAM,STYLE_SOLID,3,bkg_color);
            SetIndexStyle(11,DRAW_HISTOGRAM,STYLE_SOLID,3,bkg_color);
         }
       
   
         Prev_Bid = Curr_Bid;
         Curr_Bid = Bid;
         Prev_Ask = Curr_Ask;
         Curr_Ask = Ask;
         Prev_Vol = Curr_Vol;
         Curr_Vol = iVolume(NULL,0,0);
      
         if (Time[0]!=timestamp &&  firstTick==false && showCumulative==true) 
         {
              closed[0]=closed[1];
              opened[0]=closed[1];
              highed[0]=closed[1];
              lowed[0]=closed[1];
              Prev_Vol=iVolume(NULL,0,0);
              timestamp=Time[0];     
         }
         
         if (Time[0]!=timestamp &&  firstTick==false && showCumulative==false) 
         {
              closed[0]=0;
              opened[0]=0;
              highed[0]=0;
              lowed[0]=0;
              Prev_Vol=iVolume(NULL,0,0);
              timestamp=Time[0];     
         }
         
           
      

         if (firstTick==true) initialize(); //function that will open appropriate files, read from them, and set basic global tick values to initial values
                      
         // write Bid/Ask tick data to file                                       
         if (recordTicks==true && (Curr_Vol-Prev_Vol > 0 && (Prev_Ask!=Curr_Ask || Prev_Bid!=Curr_Bid)))
         {
            FileSeek(handle, 0, SEEK_END);
            FileWrite(handle,TimeToStr( TimeCurrent(), TIME_DATE | TIME_SECONDS ),Bid, Ask, Curr_Vol-Prev_Vol);  
         }
      
         updateTickValues(); // Function to update values based upon incoming tick and volume values           
                       
         printBar(0);  // function to print our a bar using the histogram function for the current global tick values
                 
         if (showCorr==true) calcCorr(); // function to calculate Pearson's correlation coefficient
                        
         return (0);
}




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Function that will open appropriate files, read from them, and set basic global tick values to initial values  //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void initialize(){

         if (printHistory==true){
                  handle=FileOpen("Ticks_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,',');
                if (handle<0){
                  Print("Could Not Create/Open File "+GetLastError());
                  FileClose(handle);
                }
                if (handle==1){ 
                  Print("File Opened Successfully");        
                  FileSeek(handle,0,SEEK_SET);
                  if (!FileIsEnding(handle)) readData(); //Function to Read data line by line from file starting from the earliest record
                }
              }
              
             if (recordTicks==true && handle==0){
                handle=FileOpen("Ticks_"+Symbol()+".csv", FILE_CSV|FILE_READ|FILE_WRITE,',');
                if (handle<0){
                  Print("Could Not Create/Open File "+GetLastError());
                  FileClose(handle);
                }
                if (handle==1) Print("File Opened Successfully");
                FileSeek(handle, 0, SEEK_END);
              }
              
             if (recordTicks==true && handle==1){
                  FileSeek(handle, 0, SEEK_END);
              }
              
               Prev_Vol=iVolume(NULL,0,0);
               Curr_Vol=iVolume(NULL,0,0);
               firstTick=false;
      } 





//////////////////////////////////////////////////////////////////////////////////////
//  Function to Read data line by line from file starting from the earliest record  //
//////////////////////////////////////////////////////////////////////////////////////
void readData(){
   datetime time1 = StrToTime(FileReadString(handle));
   double bid1 = StrToDouble(FileReadString(handle)); 
   double ask1 = StrToDouble(FileReadString(handle));
   double volume1 = StrToDouble(FileReadString(handle));
    
   int i=0;
   while (time1<=Time[i]){
      i++;
   }
   
   opened[i]=0;   
   closed[i]=0;
   highed[i]=0;
   lowed[i]=0;
   
   datetime time2=time1;

     for (i; i>-1; i--){
            if (i>0){                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                  while ((time2<Time[i-1]) && !FileIsEnding(handle)){
                        time2 = StrToTime(FileReadString(handle));
                        double bid2 = StrToDouble(FileReadString(handle)); 
                        double ask2 = StrToDouble(FileReadString(handle));
                        double volume2 = StrToDouble(FileReadString(handle));
                        if (ask2>ask1){
                           closed[i]=closed[i]+volume2;
                        }
                        if (bid2<bid1){
                           closed[i]=closed[i]-volume2;
                        }
                        if (closed[i]>highed[i]){
                           highed[i]=closed[i];
                        }
                        if (closed[i]<lowed[i]){
                           lowed[i]=closed[i];
                        }  
                                     
                        if (showCumulative==false){
                           closed[i]=closed[i]-opened[i];
                           highed[i]=highed[i]-opened[i];
                           lowed[i]=lowed[i]-opened[i];
                           opened[i]=0;
                        } 
                                    
                        printBar(i);
                        time1=time2;
                        bid1=bid2;
                        ask1=ask2;
                        volume1=volume2;     
                  }
            }
            
            if (i==0){
                   while (!FileIsEnding(handle)){
                        time2 = StrToTime(FileReadString(handle));
                        bid2 = StrToDouble(FileReadString(handle)); 
                        ask2 = StrToDouble(FileReadString(handle));
                        volume2 = StrToDouble(FileReadString(handle));
                        if (ask2>ask1){
                           closed[i]=closed[i]+volume2;
                        }
                        if (bid2<bid1){
                           closed[i]=closed[i]-volume2;
                        }
                        if (closed[i]>highed[i]){
                           highed[i]=closed[i];
                        }
                        if (closed[i]<lowed[i]){
                           lowed[i]=closed[i];
                        }  
                                     printBar(i);
                        time1=time2;
                        bid1=bid2;
                        ask1=ask2;
                        volume1=volume2;     
                  }
            }
            opened[i-1]=closed[i];
            highed[i-1]=closed[i];
            lowed[i-1]=closed[i];
            closed[i-1]=closed[i];
    }        
      
      
}



/////////////////////////////////////////////
//  Create a OHLC bar from the tick data   //
/////////////////////////////////////////////

void printBar(int pos){

         if (closed[pos]>0 && opened[pos]>=0 && lowed [pos]>=0 && highed[pos]>0){
         
               if (closed[pos]>opened[pos]){
                    Up_Body_Green[pos] = closed[pos];
                    Bg_Body_Black[pos] = opened[pos];
                    Up_Wick_Green[pos] = highed[pos];
                    Bg_Wick_Black[pos] = lowed[pos];
                    
                    Up_Wick_Red[pos]=0;
                    Up_Body_Red[pos]=0;
                    Dn_Wick_Red[pos]=0;
                    Dn_Body_Red[pos]=0;
                   
                    
                    
               }
               if (closed[pos]<opened[pos]){
                    Dn_Body_Red[pos] = opened[pos];
                    Bg_Body_Black[pos] = closed[pos];
                    Dn_Wick_Red[pos] = highed[pos];
                    Bg_Wick_Black[pos] = lowed[pos];
                    
                    Up_Wick_Green[pos]=0;
                    Up_Body_Green[pos]=0;
                    Dn_Wick_Green[pos]=0;
                    Dn_Body_Green[pos]=0;
                    
               }  
                 
          }
          if (closed[pos]>=0 && opened[pos]>=0 && lowed [pos]<0 && highed[pos]>0){
         
               if (closed[pos]>opened[pos]){
                    Up_Body_Green[pos] = closed[pos];
                    Bg_Body_Black[pos] = opened[pos];
                    Up_Wick_Green[pos] = highed[pos];
                    Dn_Wick_Green[pos] = lowed[pos];
                    
                    Up_Wick_Red[pos]=0;
                    Up_Body_Red[pos]=0;
                    Dn_Wick_Red[pos]=0;
                    Dn_Body_Red[pos]=0;
   
               }
               if (closed[pos]<opened[pos]){
                    Up_Body_Red[pos] = opened[pos];
                    Bg_Body_Black[pos] = closed[pos];
                    Up_Wick_Red[pos] = highed[pos];
                    Dn_Wick_Red[pos] = lowed[pos];
                    
                    Up_Wick_Green[pos]=0;
                    Up_Body_Green[pos]=0;
                    Dn_Wick_Green[pos]=0;
                    Dn_Body_Green[pos]=0;
                    
               }    
          }      
          if (closed[pos]>0 && opened[pos]<0){
         
               if (closed[pos]>opened[pos]){
                    Up_Body_Green[pos] = closed[pos];
                    Up_Wick_Green[pos] = highed[pos];
                    Dn_Body_Green[pos] = opened[pos];
                    Dn_Wick_Green[pos]= lowed[pos];
                    
                    Up_Wick_Red[pos]=0;
                    Up_Body_Red[pos]=0;
                    Dn_Wick_Red[pos]=0;
                    Dn_Body_Red[pos]=0;
                    Bg_Body_Black[pos]=0;
                    Bg_Wick_Black[pos]=0;
                               
               }    
          }          
          
          if (closed[pos]<0 && opened[pos]<=0 && lowed [pos]<0 && highed[pos]<=0){
               if (closed[pos]>opened[pos]){
                    Up_Body_Green[pos] = opened[pos];
                    Bg_Body_Black[pos] = closed[pos];
                    Up_Wick_Green[pos] = lowed[pos];
                    Bg_Wick_Black[pos] = highed[pos];
                    
                    Up_Wick_Red[pos]=0;
                    Up_Body_Red[pos]=0;
                    Dn_Wick_Red[pos]=0;
                    Dn_Body_Red[pos]=0;
               }
               if (closed[pos]<opened[pos]){
                    Dn_Body_Red[pos] = closed[pos];
                    Bg_Body_Black[pos] = opened[pos];
                    Dn_Wick_Red[pos] = lowed[pos];
                    Bg_Wick_Black[pos] = highed[pos];
                    
                    Up_Wick_Green[pos]=0;
                    Up_Body_Green[pos]=0;
                    Dn_Wick_Green[pos]=0;
                    Dn_Body_Green[pos]=0;
               }    
          }
          
          if (closed[pos]<=0 && opened[pos]<=0 && lowed[pos]<0 && highed[pos]>0){
         
               if (closed[pos]>opened[pos]){                 
                    Up_Body_Green[pos] = opened[pos];
                    Bg_Body_Black[pos] = closed[pos]; 
                    Up_Wick_Green[pos] = highed[pos];
                    Dn_Wick_Green[pos] = lowed[pos]; 
                                                    
                    Up_Wick_Red[pos]=0;
                    Up_Body_Red[pos]=0;
                    Dn_Wick_Red[pos]=0;
                    Dn_Body_Red[pos]=0;
               }
               if (closed[pos]<opened[pos]){     
                    Dn_Body_Red[pos] = closed[pos];
                    Bg_Body_Black[pos] = opened[pos];
                    Up_Wick_Red[pos] = highed[pos];
                    Dn_Wick_Red[pos] = lowed[pos];
                      
                    Up_Wick_Green[pos]=0;
                    Up_Body_Green[pos]=0;
                    Dn_Wick_Green[pos]=0;
                    Dn_Body_Green[pos]=0;             
                    
               }    
          }
   
           if (closed[pos]<0 && opened[pos]>0){
         
                    Dn_Body_Red[pos] = closed[pos];
                    Up_Wick_Red[pos] = highed[pos];            
                    Up_Body_Red[pos] = opened[pos];
                    Dn_Wick_Red[pos] = lowed[pos];
                     
                    Up_Wick_Green[pos]=0;
                    Up_Body_Green[pos]=0;
                    Dn_Wick_Green[pos]=0;
                    Dn_Body_Green[pos]=0; 
                    Bg_Body_Black[pos]=0;
                    Bg_Wick_Black[pos]=0;                 
                   
          }
}


////////////////////////////////////////////////////////////////////////
//  Function to Update Variables for Bar Creation (done every tick)   //
////////////////////////////////////////////////////////////////////////


void updateTickValues(){

            if (Curr_Ask > Prev_Ask){
               closed[0]=closed[0]+(Curr_Vol-Prev_Vol);
               if(closed[0]>highed[0]){
                  highed[0]=closed[0];
               }
               if(closed[0]<lowed[0]){
                  lowed[0]=closed[0];
               }
               
            }   
            if (Curr_Bid < Prev_Bid){ 
               closed[0]=closed[0]-(Curr_Vol-Prev_Vol);
                if(closed[0]>highed[0]){
                  highed[0]=closed[0];
               }
               if(closed[0]<lowed[0]){
                  lowed[0]=closed[0];
               }                     
            }  
      }      



////////////////////////////////////////////////////////////////////////
//  Function to Calculate Pearson's Corellation Coefficient           //
////////////////////////////////////////////////////////////////////////


void calcCorr(){
   
   for (int i=Bars-1-corrPeriod; i>=0; i--){
         double A=0;
         double B=0;
         double C=0;
         double sumY, meanY;
         
         for (int p = i+corrPeriod; p>=i; p--)
         {
             sumY = sumY+ (Close[p]-Open[p]);
         } meanY=sumY/corrPeriod;
         double sumX, meanX;
         
         for (int r = i+corrPeriod; r>=i; r--)
         {
             sumX = sumX+ (closed[r]-opened[r]);
         } meanX=sumX/corrPeriod;
         
         for (int q = i+corrPeriod; q>=i; q--){
           A=A + (closed[q]-opened[q]-meanX)*(Close[q]-Open[q]-meanY);
           B=B + MathPow((closed[q]-opened[q]-meanX),2);
           C=C + MathPow(Close[q]-Open[q]- meanY,2);
         } 
       if (A!=0 && B!=0 && C!=0){
       correlation [i] = 100*A/(MathSqrt(B)*MathSqrt(C));  
  }
   
      }
   



}


