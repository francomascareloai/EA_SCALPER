// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fluxchart

//@version=5
const bool DEBUG = false
const int maxBoxesCount = 500
const float overlapThresholdPercentage = 0
const int maxDistanceToLastBar = 1750 // Affects Running Time
const int maxOrderBlocks = 30

indicator(title = 'Volumized Order Blocks | Flux Charts', overlay = true, max_boxes_count = maxBoxesCount, max_labels_count = maxBoxesCount, max_lines_count = maxBoxesCount, max_bars_back = 5000)

showInvalidated = input.bool(true, "Show Historic Zones", group = "General Configuration", display = display.none)
OBsEnabled = true
orderBlockVolumetricInfo = input.bool(true, "Volumetric Info", group = "General Configuration", inline="EV", display = display.none)
obEndMethod = input.string("Wick", "Zone Invalidation", options = ["Wick", "Close"],  group = "General Configuration", display = display.none)
combineOBs = DEBUG ? input.bool(true, "Combine Zones", group = "General Configuration", display = display.none) : true
maxATRMult = DEBUG ? input.float(3.5,"Max Atr Multiplier", group = "General Configuration") : 3.5
swingLength = input.int(10, 'Swing Length', minval = 3, tooltip="Swing length is used when finding order block formations. Smaller values will result in finding smaller order blocks.",group = "General Configuration", display = display.none)
zoneCount = input.string("Low", 'Zone Count', options = ["High", "Medium", "Low", "One"], tooltip = "Number of Order Block Zones to be rendered. Higher options will result in older Order Blocks shown.",  group = "General Configuration", display = display.none)
bullOrderBlockColor = input(#08998180, 'Bullish', inline = 'obColor', group = 'General Configuration', display = display.none)
bearOrderBlockColor = input(#f2364680, 'Bearish', inline = 'obColor', group = 'General Configuration', display = display.none)

bullishOrderBlocks = zoneCount == "One" ? 1 : zoneCount == "Low" ? 3 : zoneCount == "Medium" ? 5 : 10
bearishOrderBlocks = zoneCount == "One" ? 1 : zoneCount == "Low" ? 3 : zoneCount == "Medium" ? 5 : 10

timeframe1Enabled = true
timeframe1 = ""

textColor = input.color(#ffffff80, "Text Color", group = "Style")
extendZonesBy = DEBUG ? input.int(15, "Extend Zones", group = "Style", minval = 1, maxval = 30, inline = "ExtendZones") : 15
extendZonesDynamic = DEBUG ? input.bool(true, "Dynamic", group = "Style", inline = "ExtendZones") : true
combinedText = DEBUG ? input.bool(false, "Combined Text", group = "Style", inline = "CombinedColor") : false
volumeBarsPlace = DEBUG ? input.string("Left", "Show Volume Bars At", options = ["Left", "Right"], group = "Style", inline = "volumebars") : "Left"
mirrorVolumeBars = DEBUG ? input.bool(true, "Mirror Volume Bars", group = "Style", inline = "volumebars") : true

volumeBarsLeftSide = (volumeBarsPlace == "Left")
extendZonesByTime = extendZonesBy * timeframe.in_seconds(timeframe.period) * 1000

atr = ta.atr(10)

type orderBlockInfo
    float top
    float bottom
    float obVolume
    string obType
    int startTime
    float bbVolume
    float obLowVolume
    float obHighVolume
    bool breaker
    int breakTime
    string timeframeStr
    bool disabled = false
    string combinedTimeframesStr = na
    bool combined = false

type orderBlock
    orderBlockInfo info
    bool isRendered = false

    box orderBox = na
    box breakerBox = na

    line orderBoxLineTop = na
    line orderBoxLineBottom = na
    line breakerBoxLineTop = na
    line breakerBoxLineBottom = na
    //
    box orderBoxText = na
    box orderBoxPositive = na
    box orderBoxNegative = na

    line orderSeperator = na
    line orderTextSeperator = na

createOrderBlock (orderBlockInfo orderBlockInfoF) =>
    orderBlock newOrderBlock = orderBlock.new(orderBlockInfoF)
    newOrderBlock

safeDeleteOrderBlock (orderBlock orderBlockF) =>
    orderBlockF.isRendered := false

    box.delete(orderBlockF.orderBox)
    box.delete(orderBlockF.breakerBox)
    box.delete(orderBlockF.orderBoxText)
    box.delete(orderBlockF.orderBoxPositive)
    box.delete(orderBlockF.orderBoxNegative)

    line.delete(orderBlockF.orderBoxLineTop)
    line.delete(orderBlockF.orderBoxLineBottom)
    line.delete(orderBlockF.breakerBoxLineTop)
    line.delete(orderBlockF.breakerBoxLineBottom)
    line.delete(orderBlockF.orderSeperator)
    line.delete(orderBlockF.orderTextSeperator)

type timeframeInfo
    int index = na
    string timeframeStr = na
    bool isEnabled = false

    orderBlockInfo[] bullishOrderBlocksList = na
    orderBlockInfo[] bearishOrderBlocksList = na

newTimeframeInfo (index, timeframeStr, isEnabled) =>
    newTFInfo = timeframeInfo.new()
    newTFInfo.index := index
    newTFInfo.isEnabled := isEnabled
    newTFInfo.timeframeStr := timeframeStr

    newTFInfo

type obSwing
    int x = na    
    float y = na
    float swingVolume = na
    bool crossed = false

// ____ TYPES END ____

var timeframeInfo[] timeframeInfos = array.from(newTimeframeInfo(1, timeframe1, timeframe1Enabled))
var bullishOrderBlocksList = array.new<orderBlockInfo>(0)
var bearishOrderBlocksList = array.new<orderBlockInfo>(0)

var allOrderBlocksList = array.new<orderBlock>(0)

moveLine(_line, _x, _y, _x2) =>
    line.set_xy1(_line, _x,  _y)
    line.set_xy2(_line, _x2, _y)

moveBox (_box, _topLeftX, _topLeftY, _bottomRightX, _bottomRightY) =>
    box.set_lefttop(_box, _topLeftX, _topLeftY)
    box.set_rightbottom(_box, _bottomRightX, _bottomRightY)

isTimeframeLower (timeframe1F, timeframe2F) =>
    timeframe.in_seconds(timeframe1F) < timeframe.in_seconds(timeframe2F)

getMinTimeframe (timeframe1F, timeframe2F) =>
    if isTimeframeLower(timeframe1F, timeframe2F)
        timeframe1F
    else
        timeframe2F

getMaxTimeframe (timeframe1F, timeframe2F) =>
    if isTimeframeLower(timeframe1F, timeframe2F)
        timeframe2F
    else
        timeframe1F

formatTimeframeString (formatTimeframe) =>
    timeframeF = formatTimeframe == "" ? timeframe.period : formatTimeframe
    
    if str.contains(timeframeF, "D") or str.contains(timeframeF, "W") or str.contains(timeframeF, "S") or str.contains(timeframeF, "M")
        timeframeF
    else
        seconds = timeframe.in_seconds(timeframeF)
        if seconds >= 3600
            hourCount = int(seconds / 3600)
            str.tostring(hourCount) + " Hour" + (hourCount > 1 ? "s" : "")
        else
            timeframeF + " Min"

betterCross(s1, s2) =>
    string ret = na
    if s1 >= s2 and s1[1] < s2
        ret := "Bull"
    if s1 < s2 and s1[1] >= s2
        ret := "Bear"
    ret

colorWithTransparency (colorF, transparencyX) =>
    color.new(colorF, color.t(colorF) * transparencyX)

createOBBox (boxColor, transparencyX = 1.0, xlocType = xloc.bar_time) =>
    box.new(na, na, na, na, text_size = size.normal, xloc = xlocType, extend = extend.none, bgcolor = colorWithTransparency(boxColor, transparencyX), text_color = textColor, text_halign = text.align_center, border_color = #00000000)

renderOrderBlock (orderBlock ob) =>
    orderBlockInfo info = ob.info
    ob.isRendered := true
    orderColor = ob.info.obType == "Bull" ? bullOrderBlockColor : bearOrderBlockColor

    if OBsEnabled and (not false or not (false and info.breaker)) and not (not showInvalidated and info.breaker)
        ob.orderBox := createOBBox(orderColor, 1.5)
        if ob.info.combined
            ob.orderBox.set_bgcolor(colorWithTransparency(orderColor, 1.1))
        ob.orderBoxText := createOBBox(color.new(color.white, 100))
        if orderBlockVolumetricInfo
            ob.orderBoxPositive := createOBBox(bullOrderBlockColor)
            ob.orderBoxNegative := createOBBox(bearOrderBlockColor)
            ob.orderSeperator := line.new(na,na,na,na,xloc.bar_time,extend.none,textColor,line.style_dashed,1)
            ob.orderTextSeperator := line.new(na,na,na,na,xloc.bar_time,extend.none,textColor,line.style_solid,1)

        zoneSize = extendZonesDynamic ? na(info.breakTime) ? extendZonesByTime : (info.breakTime - info.startTime) : extendZonesByTime
        if na(info.breakTime)
            zoneSize := (time + 1) - info.startTime

        startX = volumeBarsLeftSide ? info.startTime : info.startTime + zoneSize - zoneSize / 3
        maxEndX = volumeBarsLeftSide ? info.startTime + zoneSize / 3 : info.startTime + zoneSize

        moveBox(ob.orderBox, info.startTime, info.top, info.startTime + zoneSize, info.bottom)
        moveBox(ob.orderBoxText, volumeBarsLeftSide ? maxEndX : info.startTime, info.top, volumeBarsLeftSide ? info.startTime + zoneSize : startX, info.bottom)

        percentage = int((math.min(info.obHighVolume, info.obLowVolume) / math.max(info.obHighVolume, info.obLowVolume)) * 100.0)
        OBText = (na(ob.info.combinedTimeframesStr) ? formatTimeframeString(ob.info.timeframeStr) : ob.info.combinedTimeframesStr) + " OB"
        box.set_text(ob.orderBoxText, (orderBlockVolumetricInfo ? str.tostring(ob.info.obVolume, format.volume) + " (" + str.tostring(percentage) + "%)\n" : "") + (combinedText and ob.info.combined ? "[Combined]\n" : "") + OBText)

        if orderBlockVolumetricInfo
            showHighLowBoxText = false

            curEndXHigh = int(math.ceil((info.obHighVolume / info.obVolume) * (maxEndX - startX) + startX))
            curEndXLow = int(math.ceil((info.obLowVolume / info.obVolume) * (maxEndX - startX) + startX))

            moveBox(ob.orderBoxPositive, mirrorVolumeBars ? startX : curEndXLow, info.top, mirrorVolumeBars ? curEndXHigh : maxEndX, (info.bottom + info.top) / 2)
            box.set_text(ob.orderBoxPositive, showHighLowBoxText ? str.tostring(info.obHighVolume, format.volume) : "")

            moveBox(ob.orderBoxNegative, mirrorVolumeBars ? startX : curEndXHigh, info.bottom, mirrorVolumeBars ? curEndXLow : maxEndX, (info.bottom + info.top) / 2)
            box.set_text(ob.orderBoxNegative, showHighLowBoxText ? str.tostring(info.obLowVolume, format.volume) : "")

            moveLine(ob.orderSeperator, volumeBarsLeftSide ? startX : maxEndX, (info.bottom + info.top) / 2, volumeBarsLeftSide ? maxEndX : startX)

            line.set_xy1(ob.orderTextSeperator, volumeBarsLeftSide ? maxEndX : startX, info.top)
            line.set_xy2(ob.orderTextSeperator, volumeBarsLeftSide ? maxEndX : startX, info.bottom)

findOBSwings(len) =>
    var swingType = 0
    var obSwing top = obSwing.new(na, na)
    var obSwing bottom = obSwing.new(na, na)
    
    upper = ta.highest(len)
    lower = ta.lowest(len)

    swingType := high[len] > upper ? 0 : low[len] < lower ? 1 : swingType

    if swingType == 0 and swingType[1] != 0
        top := obSwing.new(bar_index[len], high[len], volume[len])
    
    if swingType == 1 and swingType[1] != 1
        bottom := obSwing.new(bar_index[len], low[len], volume[len])

    [top, bottom]

findOrderBlocks () =>
    if bar_index > last_bar_index - maxDistanceToLastBar
        [top, btm] = findOBSwings(swingLength)
        useBody = false
        max = useBody ? math.max(close, open) : high
        min = useBody ? math.min(close, open) : low

        // Bullish Order Block
        bullishBreaked = 0

        if bullishOrderBlocksList.size() > 0
            for i = bullishOrderBlocksList.size() - 1 to 0
                currentOB = bullishOrderBlocksList.get(i)
            
                if not currentOB.breaker 
                    if (obEndMethod == "Wick" ? low : math.min(open, close)) < currentOB.bottom
                        currentOB.breaker := true
                        currentOB.breakTime := time
                        currentOB.bbVolume := volume
                else
                    if high > currentOB.top
                        bullishOrderBlocksList.remove(i)
                    else if i < bullishOrderBlocks and top.y < currentOB.top and top.y > currentOB.bottom 
                        bullishBreaked := 1

        if close > top.y and not top.crossed
            top.crossed := true

            boxBtm = max[1]
            boxTop = min[1]
            boxLoc = time[1]

            for i = 1 to (bar_index - top.x) - 1
                boxBtm := math.min(min[i], boxBtm)
                boxTop := boxBtm == min[i] ? max[i] : boxTop
                boxLoc := boxBtm == min[i] ? time[i] : boxLoc

            newOrderBlockInfo = orderBlockInfo.new(boxTop, boxBtm, volume + volume[1] + volume[2], "Bull", boxLoc)
            newOrderBlockInfo.obLowVolume := volume[2]
            newOrderBlockInfo.obHighVolume := volume + volume[1]
            
            obSize = math.abs(newOrderBlockInfo.top - newOrderBlockInfo.bottom)
            if obSize <= atr * maxATRMult
                bullishOrderBlocksList.unshift(newOrderBlockInfo)
                if bullishOrderBlocksList.size() > maxOrderBlocks
                    bullishOrderBlocksList.pop()

        // Bearish Order Block
        
        bearishBreaked = 0

        if bearishOrderBlocksList.size() > 0
            for i = bearishOrderBlocksList.size() - 1 to 0
                currentOB = bearishOrderBlocksList.get(i)

                if not currentOB.breaker 
                    if (obEndMethod == "Wick" ? high : math.max(open, close)) > currentOB.top
                        currentOB.breaker := true
                        currentOB.breakTime := time
                        currentOB.bbVolume := volume
                else
                    if low < currentOB.bottom
                        bearishOrderBlocksList.remove(i)
                    else if i < bearishOrderBlocks and btm.y > currentOB.bottom and btm.y < currentOB.top 
                        bearishBreaked := 1

        if close < btm.y and not btm.crossed
            btm.crossed := true

            boxBtm = min[1]
            boxTop = max[1]
            boxLoc = time[1]

            for i = 1 to (bar_index - btm.x) - 1
                boxTop := math.max(max[i], boxTop)
                boxBtm := boxTop == max[i] ? min[i] : boxBtm
                boxLoc := boxTop == max[i] ? time[i] : boxLoc

            newOrderBlockInfo = orderBlockInfo.new(boxTop, boxBtm, volume + volume[1] + volume[2], "Bear", boxLoc)
            newOrderBlockInfo.obLowVolume := volume + volume[1]
            newOrderBlockInfo.obHighVolume := volume[2]

            obSize = math.abs(newOrderBlockInfo.top - newOrderBlockInfo.bottom)
            if obSize <= atr * maxATRMult
                bearishOrderBlocksList.unshift(newOrderBlockInfo)
                if bearishOrderBlocksList.size() > maxOrderBlocks
                    bearishOrderBlocksList.pop()
    true

areaOfOB (orderBlockInfo OBInfoF) =>
    float XA1 = OBInfoF.startTime
    float XA2 = na(OBInfoF.breakTime) ? time + 1 : OBInfoF.breakTime
    float YA1 = OBInfoF.top
    float YA2 = OBInfoF.bottom
    float edge1 = math.sqrt((XA2 - XA1) * (XA2 - XA1) + (YA2 - YA2) * (YA2 - YA2))
    float edge2 = math.sqrt((XA2 - XA2) * (XA2 - XA2) + (YA2 - YA1) * (YA2 - YA1))
    float totalArea = edge1 * edge2
    totalArea

doOBsTouch (orderBlockInfo OBInfo1, orderBlockInfo OBInfo2) =>
    float XA1 = OBInfo1.startTime
    float XA2 = na(OBInfo1.breakTime) ? time + 1 : OBInfo1.breakTime
    float YA1 = OBInfo1.top
    float YA2 = OBInfo1.bottom

    float XB1 = OBInfo2.startTime
    float XB2 = na(OBInfo2.breakTime) ? time + 1 : OBInfo2.breakTime
    float YB1 = OBInfo2.top
    float YB2 = OBInfo2.bottom
    float intersectionArea = math.max(0, math.min(XA2, XB2) - math.max(XA1, XB1)) * math.max(0, math.min(YA1, YB1) - math.max(YA2, YB2))
    float unionArea = areaOfOB(OBInfo1) + areaOfOB(OBInfo2) - intersectionArea
    
    float overlapPercentage = (intersectionArea / unionArea) * 100.0

    if overlapPercentage > overlapThresholdPercentage
        true
    else
        false

isOBValid (orderBlockInfo OBInfo) =>
    valid = true
    if OBInfo.disabled
        valid := false
    valid

combineOBsFunc () =>
    if allOrderBlocksList.size() > 0
        lastCombinations = 999
        while lastCombinations > 0
            lastCombinations := 0
            for i = 0 to allOrderBlocksList.size() - 1
                curOB1 = allOrderBlocksList.get(i)
                for j = 0 to allOrderBlocksList.size() - 1
                    curOB2 = allOrderBlocksList.get(j)
                    if i == j
                        continue
                    if not isOBValid(curOB1.info) or not isOBValid(curOB2.info)
                        continue
                    if curOB1.info.obType != curOB2.info.obType
                        continue
                    if doOBsTouch(curOB1.info, curOB2.info)
                        curOB1.info.disabled := true
                        curOB2.info.disabled := true
                        orderBlock newOB = createOrderBlock(orderBlockInfo.new(math.max(curOB1.info.top, curOB2.info.top), math.min(curOB1.info.bottom, curOB2.info.bottom), curOB1.info.obVolume + curOB2.info.obVolume, curOB1.info.obType))
                        newOB.info.startTime := math.min(curOB1.info.startTime, curOB2.info.startTime)
                        newOB.info.breakTime := math.max(nz(curOB1.info.breakTime), nz(curOB2.info.breakTime))
                        newOB.info.breakTime := newOB.info.breakTime == 0 ? na : newOB.info.breakTime
                        newOB.info.timeframeStr := curOB1.info.timeframeStr

                        newOB.info.obVolume := curOB1.info.obVolume + curOB2.info.obVolume
                        newOB.info.obLowVolume := curOB1.info.obLowVolume + curOB2.info.obLowVolume
                        newOB.info.obHighVolume := curOB1.info.obHighVolume + curOB2.info.obHighVolume
                        newOB.info.bbVolume := nz(curOB1.info.bbVolume, 0) + nz(curOB2.info.bbVolume, 0)
                        newOB.info.breaker := curOB1.info.breaker or curOB2.info.breaker
                        
                        newOB.info.combined := true
                        if timeframe.in_seconds(curOB1.info.timeframeStr) != timeframe.in_seconds(curOB2.info.timeframeStr)
                            newOB.info.combinedTimeframesStr := (na(curOB1.info.combinedTimeframesStr) ? formatTimeframeString(curOB1.info.timeframeStr) : curOB1.info.combinedTimeframesStr) + " & " + (na(curOB2.info.combinedTimeframesStr) ? formatTimeframeString(curOB2.info.timeframeStr) : curOB2.info.combinedTimeframesStr)
                        allOrderBlocksList.unshift(newOB)
                        lastCombinations += 1


reqSeq (timeframeStr) =>
    [bullishOrderBlocksListF, bearishOrderBlocksListF] = request.security(syminfo.tickerid, timeframeStr, [bullishOrderBlocksList, bearishOrderBlocksList])
    [bullishOrderBlocksListF, bearishOrderBlocksListF]

getTFData (timeframeInfo timeframeInfoF, timeframeStr) =>
    if not isTimeframeLower(timeframeInfoF.timeframeStr, timeframe.period) and timeframeInfoF.isEnabled
        [bullishOrderBlocksListF, bearishOrderBlocksListF] = reqSeq(timeframeStr)
        [bullishOrderBlocksListF, bearishOrderBlocksListF]
    else
        [na, na]

handleTimeframeInfo (timeframeInfo timeframeInfoF, bullishOrderBlocksListF, bearishOrderBlocksListF) =>
    if not isTimeframeLower(timeframeInfoF.timeframeStr, timeframe.period) and timeframeInfoF.isEnabled
        timeframeInfoF.bullishOrderBlocksList := bullishOrderBlocksListF
        timeframeInfoF.bearishOrderBlocksList := bearishOrderBlocksListF


handleOrderBlocksFinal () =>
    if DEBUG
        log.info("Bullish OB Count " + str.tostring(bullishOrderBlocksList.size()))
        log.info("Bearish OB Count " + str.tostring(bearishOrderBlocksList.size()))

    if allOrderBlocksList.size () > 0
        for i = 0 to allOrderBlocksList.size() - 1
            safeDeleteOrderBlock(allOrderBlocksList.get(i))
    allOrderBlocksList.clear()    

    for i = 0 to timeframeInfos.size() - 1
        curTimeframe = timeframeInfos.get(i)
        if not curTimeframe.isEnabled
            continue
        if curTimeframe.bullishOrderBlocksList.size() > 0
            for j = 0 to math.min(curTimeframe.bullishOrderBlocksList.size() - 1, bullishOrderBlocks - 1)
                orderBlockInfoF = curTimeframe.bullishOrderBlocksList.get(j)
                orderBlockInfoF.timeframeStr := curTimeframe.timeframeStr
                allOrderBlocksList.unshift(createOrderBlock(orderBlockInfo.copy(orderBlockInfoF)))

        if curTimeframe.bearishOrderBlocksList.size() > 0
            for j = 0 to math.min(curTimeframe.bearishOrderBlocksList.size() - 1, bearishOrderBlocks - 1)
                orderBlockInfoF = curTimeframe.bearishOrderBlocksList.get(j)
                orderBlockInfoF.timeframeStr := curTimeframe.timeframeStr
                allOrderBlocksList.unshift(createOrderBlock(orderBlockInfo.copy(orderBlockInfoF)))

    if combineOBs
        combineOBsFunc()    

    if allOrderBlocksList.size() > 0
        for i = 0 to allOrderBlocksList.size() - 1
            curOB = allOrderBlocksList.get(i)
            if isOBValid(curOB.info)
                renderOrderBlock(curOB)

findOrderBlocks()

[bullishOrderBlocksListTimeframe1, bearishOrderBlocksListTimeframe1] = getTFData(timeframeInfos.get(0), timeframe1)

if barstate.isconfirmed
    handleTimeframeInfo(timeframeInfos.get(0), bullishOrderBlocksListTimeframe1, bearishOrderBlocksListTimeframe1)
    handleOrderBlocksFinal()    