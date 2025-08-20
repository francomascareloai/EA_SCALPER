    //+------------------------------------------------------------------+
    //|                                                       SupDem.mq4 |
    //|                      Copyright © 2008, MetaQuotes Software Corp. |
    //|                                        http://www.metaquotes.net |
    //+------------------------------------------------------------------+
    #property copyright "Copyright © 2008, MetaQuotes Software Corp."
   

    #property indicator_chart_window
    #property indicator_buffers 2
    extern int forced_tf = 0;
    extern bool use_narrow_bands = false;
    extern bool kill_retouch = true;
    extern color TopColor = Yellow;
    extern color BotColor = Aqua;
    extern color Price_mark = Black;
    extern int Price_Width = 1;

    double BuferUp[];
    double BuferDn[];
    double iPeriod=13;
    int Dev=8;
    int Step=5;
    datetime t1,t2;
    double p1,p2;
    string pair;
    double point;
    int digits;
    int tf;
    string TAG;

    double up_cur,dn_cur;

    int init()
    {
       SetIndexBuffer(1,BuferUp);
       SetIndexEmptyValue(1,0.0);
       SetIndexStyle(1,DRAW_NONE);
       SetIndexBuffer(0,BuferDn);
       SetIndexEmptyValue(0,0.0);
       SetIndexStyle(0,DRAW_NONE);
       if(forced_tf != 0) tf = forced_tf;
          else tf = Period();
       point = Point;
       digits = Digits;
       if(digits == 3 || digits == 5) point*=10;
       TAG = "II_SupDem"+tf;
       return(0);
    }

    int deinit()
    {
       ObDeleteObjectsByPrefix(TAG);
       Comment("");
       return(0);
    }

    int start()
    {
       if(NewBar()==true)
       {
          CountZZ(BuferUp,BuferDn,iPeriod,Dev,Step);
          GetValid();
          Draw();
       }
       return(0);
    }

    void Draw()
    {
       int i;
       string s;
       ObDeleteObjectsByPrefix(TAG);
       for(i=0;i<iBars(pair,tf);i++)
       {
          if(BuferDn[i] > 0.0)
          {
             t1 = iTime(pair,tf,i);
             t2 = Time[0];
             if(use_narrow_bands) p2 = MathMax(iClose(pair,tf,i),iOpen(pair,tf,i));
                else p2 = MathMin(iClose(pair,tf,i),iOpen(pair,tf,i));
             p2 = MathMax(p2,MathMax(iLow(pair,tf,i-1),iLow(pair,tf,i+1)));


             s = TAG+"UPAR"+tf+i;
             ObjectCreate(s,OBJ_ARROW,0,0,0);
             ObjectSet(s,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
             ObjectSet(s, OBJPROP_TIME1, t2);
             ObjectSet(s, OBJPROP_PRICE1, p2);
             ObjectSet(s,OBJPROP_COLOR,Price_mark);
             ObjectSet(s,OBJPROP_WIDTH,Price_Width);     
         
             s = TAG+"UPFILL"+tf+i;
             ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
             ObjectSet(s,OBJPROP_TIME1,t1);
             ObjectSet(s,OBJPROP_PRICE1,BuferDn[i]);
             ObjectSet(s,OBJPROP_TIME2,t2);
             ObjectSet(s,OBJPROP_PRICE2,p2);
             ObjectSet(s,OBJPROP_COLOR,TopColor);
          }

          if(BuferUp[i] > 0.0)
          {
             t1 = iTime(pair,tf,i);
             t2 = Time[0];
             if(use_narrow_bands) p2 = MathMin(iClose(pair,tf,i),iOpen(pair,tf,i));
                else p2 = MathMax(iClose(pair,tf,i),iOpen(pair,tf,i));
             if(i>0) p2 = MathMin(p2,MathMin(iHigh(pair,tf,i+1),iHigh(pair,tf,i-1)));
             s = TAG+"DNAR"+tf+i;
             ObjectCreate(s,OBJ_ARROW,0,0,0);
             ObjectSet(s,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);
             ObjectSet(s, OBJPROP_TIME1, t2);
             ObjectSet(s, OBJPROP_PRICE1, p2);
             ObjectSet(s,OBJPROP_COLOR,Price_mark);
             ObjectSet(s,OBJPROP_WIDTH,Price_Width); 

             s = TAG+"DNFILL"+tf+i;
             ObjectCreate(s,OBJ_RECTANGLE,0,0,0,0,0);
             ObjectSet(s,OBJPROP_TIME1,t1);
             ObjectSet(s,OBJPROP_PRICE1,p2);
             ObjectSet(s,OBJPROP_TIME2,t2);
             ObjectSet(s,OBJPROP_PRICE2,BuferUp[i]);
             ObjectSet(s,OBJPROP_COLOR,BotColor);
          }
       }
    }

    bool NewBar() {

       static datetime LastTime = 0;

       if (iTime(pair,tf,0) != LastTime) {
          LastTime = iTime(pair,tf,0);      
          return (true);
       } else
          return (false);
    }

    void ObDeleteObjectsByPrefix(string Prefix)
    {
       int L = StringLen(Prefix);
       int i = 0;
       while(i < ObjectsTotal())
       {
          string ObjName = ObjectName(i);
          if(StringSubstr(ObjName, 0, L) != Prefix)
          {
             i++;
             continue;
          }
          ObjectDelete(ObjName);
       }
    }

    int CountZZ( double& ExtMapBuffer[], double& ExtMapBuffer2[], int ExtDepth, int ExtDeviation, int ExtBackstep )
    {
       int    shift, back,lasthighpos,lastlowpos;
       double val,res;
       double curlow,curhigh,lasthigh,lastlow;
       int count = iBars(pair,tf)-ExtDepth;

       for(shift=count; shift>=0; shift--)
         {
          val = iLow(pair,tf,iLowest(pair,tf,MODE_LOW,ExtDepth,shift));
          if(val==lastlow) val=0.0;
          else
            {
             lastlow=val;
             if((iLow(pair,tf,shift)-val)>(ExtDeviation*Point)) val=0.0;
             else
               {
                for(back=1; back<=ExtBackstep; back++)
                  {
                   res=ExtMapBuffer[shift+back];
                   if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0;
                  }
               }
            }
           
              ExtMapBuffer[shift]=val;
          //--- high
          val=iHigh(pair,tf,iHighest(pair,tf,MODE_HIGH,ExtDepth,shift));
         
          if(val==lasthigh) val=0.0;
          else
            {
             lasthigh=val;
             if((val-iHigh(pair,tf,shift))>(ExtDeviation*Point)) val=0.0;
             else
               {
                for(back=1; back<=ExtBackstep; back++)
                  {
                   res=ExtMapBuffer2[shift+back];
                   if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0;
                  }
               }
            }
          ExtMapBuffer2[shift]=val;
         }
       // final cutting
       lasthigh=-1; lasthighpos=-1;
       lastlow=-1;  lastlowpos=-1;

       for(shift=count; shift>=0; shift--)
         {
          curlow=ExtMapBuffer[shift];
          curhigh=ExtMapBuffer2[shift];
          if((curlow==0)&&(curhigh==0)) continue;
          //---
          if(curhigh!=0)
            {
             if(lasthigh>0)
               {
                if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
                else ExtMapBuffer2[shift]=0;
               }
             //---
             if(lasthigh<curhigh || lasthigh<0)
               {
                lasthigh=curhigh;
                lasthighpos=shift;
               }
             lastlow=-1;
            }
          //----
          if(curlow!=0)
            {
             if(lastlow>0)
               {
                if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
                else ExtMapBuffer[shift]=0;
               }
             //---
             if((curlow<lastlow)||(lastlow<0))
               {
                lastlow=curlow;
                lastlowpos=shift;
               }
             lasthigh=-1;
            }
         }
     
       for(shift=iBars(pair,tf)-1; shift>=0; shift--)
       {
          if(shift>=count) ExtMapBuffer[shift]=0.0;
             else
             {
                res=ExtMapBuffer2[shift];
                if(res!=0.0) ExtMapBuffer2[shift]=res;
             }
       }
    return(0);   
    }

    void GetValid()
    {
       up_cur = 0;
       int upbar = 0;
       dn_cur = 0;
       int dnbar = 0;
       double cur_hi = 0;
       double cur_lo = 0;
       double last_up = 0;
       double last_dn = 0;
       double low_dn = 0;
       double hi_up = 0;
       int i;
       for(i=0;i<iBars(pair,tf);i++)
       {
          if(BuferUp[i] > 0)
          {
             up_cur = BuferUp[i];
             cur_lo = BuferUp[i];
             last_up = cur_lo;
             break;
          }
       }
       for(i=0;i<iBars(pair,tf);i++)
       {
          if(BuferDn[i] > 0)
          {
             dn_cur = BuferDn[i];
             cur_hi = BuferDn[i];
             last_dn = cur_hi;
             break;
          }
       }

       for(i=0;i<iBars(pair,tf);i++) // remove higher lows and lower highs
       {
          if(BuferDn[i] >= last_dn)
          {
             last_dn = BuferDn[i];
             dnbar = i;
          }
             else BuferDn[i] = 0.0;
         
          if(BuferDn[i] <= dn_cur && BuferUp[i] > 0.0) BuferDn[i] = 0.0;

          if(BuferUp[i] <= last_up && BuferUp[i] > 0)
          {
             last_up = BuferUp[i];
             upbar = i;
          }
             else BuferUp[i] = 0.0;
         
          if(BuferUp[i] > up_cur) BuferUp[i] = 0.0;

       }

       if(kill_retouch)
       {
          if(use_narrow_bands)
          {
             low_dn = MathMax(iOpen(pair,tf,dnbar),iClose(pair,tf,dnbar));
             hi_up = MathMin(iOpen(pair,tf,upbar),iClose(pair,tf,upbar));
          }
             else
             {
                low_dn = MathMin(iOpen(pair,tf,dnbar),iClose(pair,tf,dnbar));
                hi_up = MathMax(iOpen(pair,tf,upbar),iClose(pair,tf,upbar));         
             }

          for(i=MathMax(upbar,dnbar);i>=0;i--) // work back to zero and remove reentries into s/d
          {
             if(BuferDn[i] > low_dn && BuferDn[i] != last_dn) BuferDn[i] = 0.0;
                else if(use_narrow_bands && BuferDn[i] > 0)
                {
                   low_dn = MathMax(iOpen(pair,tf,i),iClose(pair,tf,i));
                   last_dn = BuferDn[i];
                }
                   else if(BuferDn[i] > 0)
                   {
                      low_dn = MathMin(iOpen(pair,tf,i),iClose(pair,tf,i));
                      last_dn = BuferDn[i];
                   }

             if(BuferUp[i] <= hi_up && BuferUp[i] > 0 && BuferUp[i] != last_up) BuferUp[i] = 0.0;
                else if(use_narrow_bands && BuferUp[i] > 0)
                {
                   hi_up = MathMin(iOpen(pair,tf,i),iClose(pair,tf,i));
                   last_up = BuferUp[i];
                }
                   else if(BuferUp[i] > 0)
                   {
                      hi_up = MathMax(iOpen(pair,tf,i),iClose(pair,tf,i));
                      last_up = BuferUp[i];
                   }
          }
       }
    } 
