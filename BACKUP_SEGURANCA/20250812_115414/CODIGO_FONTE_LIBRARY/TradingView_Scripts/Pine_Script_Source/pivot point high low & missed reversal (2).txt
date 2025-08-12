// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator("Pivot Points High Low & Missed Reversal Levels [LuxAlgo]",overlay=true,max_labels_count=500,max_lines_count=500,max_bars_back=500)
length = input(50,'Pivot Length')

show_reg   = input.bool(true,'Regular Pivots',inline='inline1')
reg_ph_css = input.color(#ef5350,'High',inline='inline1')
reg_pl_css = input.color(#26a69a,'Low',inline='inline1')

show_miss   = input.bool(true,'Missed Pivots',inline='inline2')
miss_ph_css = input.color(#ef5350,'High',inline='inline2')
miss_pl_css = input.color(#26a69a,'Low',inline='inline2')

label_css = input.color(color.white,'Text Label Color')
//------------------------------------------------------------------------------
var line zigzag = na
var line ghost_level = na
var max = 0.,var min = 0.
var max_x1 = 0,var min_x1 = 0
var follow_max = 0.,var follow_max_x1 = 0
var follow_min = 0.,var follow_min_x1 = 0
var os = 0,var py1 = 0.,var px1 = 0
//------------------------------------------------------------------------------

n = bar_index
ph = ta.pivothigh(length,length)
pl = ta.pivotlow(length,length)

max := math.max(high[length],max)
min := math.min(low[length],min)
follow_max := math.max(high[length],follow_max)
follow_min := math.min(low[length],follow_min)

if max > max[1]
    max_x1 := n-length
    follow_min := low[length]
if min < min[1]
    min_x1 := n-length    
    follow_max := high[length]

if follow_min < follow_min[1]
    follow_min_x1 := n-length
if follow_max > follow_max[1]
    follow_max_x1 := n-length

//------------------------------------------------------------------------------
line.set_x2(ghost_level[1],n)

if ph
    if show_miss
        if os[1] == 1
            label.new(min_x1,min,'👻',color=miss_pl_css,style=label.style_label_up,size=size.small,
              tooltip=str.tostring(min,'#.####'))
            
            zigzag := line.new(px1,py1,min_x1,min,color=miss_ph_css,style=line.style_dashed)
            px1 := min_x1,py1 := min
            
            line.set_x2(ghost_level[1],px1)
            ghost_level := line.new(px1,py1,px1,py1,color=color.new(reg_pl_css,50),width=2)
        else if ph < max
            label.new(max_x1,max,'👻',color=miss_ph_css,style=label.style_label_down,size=size.small,
              tooltip=str.tostring(max,'#.####'))
            label.new(follow_min_x1,follow_min,'👻',color=miss_pl_css,style=label.style_label_up,size=size.small,
                  tooltip=str.tostring(min,'#.####'))
            
            zigzag := line.new(px1,py1,max_x1,max,color=miss_pl_css,style=line.style_dashed)
            px1 := max_x1,py1 := max
            line.set_x2(ghost_level[1],px1)
            ghost_level := line.new(px1,py1,px1,py1,color=color.new(reg_ph_css,50),width=2)
            
            zigzag := line.new(px1,py1,follow_min_x1,follow_min,color=miss_ph_css,style=line.style_dashed)
            px1 := follow_min_x1,py1 := follow_min
            line.set_x2(ghost_level,px1)
            ghost_level := line.new(px1,py1,px1,py1,color=color.new(reg_pl_css,50),width=2)

    if show_reg
        label.new(n-length,ph,'▼',textcolor=label_css,color=reg_ph_css,style=label.style_label_down,size=size.small,
          tooltip=str.tostring(ph,'#.####'))
        zigzag := line.new(px1,py1,n-length,ph,color=miss_pl_css,style=ph < max or os[1] == 1 ? line.style_dashed : line.style_solid)
    
    
    py1 := ph,px1 := n-length,os := 1,max := ph,min := ph
//------------------------------------------------------------------------------
if pl
    if show_miss  
        if os[1] == 0
            label.new(max_x1,max,'👻',color=miss_ph_css,style=label.style_label_down,size=size.small,
              tooltip=str.tostring(max,'#.####'))
            
            zigzag := line.new(px1,py1,max_x1,max,color=miss_pl_css,style=line.style_dashed)
            px1 := max_x1,py1 := max
            
            line.set_x2(ghost_level[1],px1)
            ghost_level := line.new(px1,py1,px1,py1,color=color.new(reg_ph_css,50),width=2)
        else if pl > min
            label.new(follow_max_x1,follow_max,'👻',color=miss_ph_css,style=label.style_label_down,size=size.small,
              tooltip=str.tostring(max,'#.####'))
            label.new(min_x1,min,'👻',color=miss_pl_css,style=label.style_label_up,size=size.small,
                  tooltip=str.tostring(min,'#.####'))
            
            zigzag := line.new(px1,py1,min_x1,min,color=miss_ph_css,style=line.style_dashed)
            px1 := min_x1,py1 := min
            line.set_x2(ghost_level[1],px1)
            ghost_level := line.new(px1,py1,px1,py1,color=color.new(reg_pl_css,50),width=2)
            
            zigzag := line.new(px1,py1,follow_max_x1,follow_max,color=miss_pl_css,style=line.style_dashed)
            px1 := follow_max_x1,py1 := follow_max
            line.set_x2(ghost_level,px1)
            ghost_level := line.new(px1,py1,px1,py1,color=color.new(reg_ph_css,50),width=2)

    if show_reg
        label.new(n-length,pl,'▲',textcolor=label_css,color=reg_pl_css,style=label.style_label_up,size=size.small,
          tooltip=str.tostring(pl,'#.####'))
        zigzag := line.new(px1,py1,n-length,pl,color=miss_ph_css,style=pl > min or os[1] == 0 ? line.style_dashed : line.style_solid)
    
    
    py1 := pl,px1 := n-length,os := 0,max := pl,min := pl
//------------------------------------------------------------------------------
var label lbl = na
if barstate.islast
    x = 0,y = 0.
    
    prices = array.new_float(0)
    prices_x = array.new_int(0)
    
    for i = 0 to n-px1-1
        array.push(prices,os==1?low[i]:high[i])
        array.push(prices_x,n-i)
    
    label.delete(lbl[1])
    
    if os == 1
        y := array.min(prices)
        x := array.get(prices_x,array.indexof(prices,y))
        
        if show_miss
            lbl := label.new(x,y,'👻',color=miss_pl_css,style=label.style_label_up,size=size.small,
              tooltip=str.tostring(y,'#.####'))
    else
        y := array.max(prices)
        x := array.get(prices_x,array.indexof(prices,y))
        
        if show_miss
            lbl := label.new(x,y,'👻',color=miss_ph_css,style=label.style_label_down,size=size.small,
              tooltip=str.tostring(y,'#.####'))
            
    if show_miss
        line.delete(line.new(px1,py1,x,y,color=os == 1 ? miss_ph_css : miss_pl_css,style=line.style_dashed)[1])
    
    line.delete(line.new(x,y,n,y,color = color.new(os == 1 ? miss_ph_css : miss_pl_css,50),width=2)[1])