-- Set up rail communication and enable rail
ExtDevSetUDPComParam("192.168.57.88", 2021, 2, 50, 10, 50, 1, 2, 5)
ExtDevLoadUDPDriver()
ExtAxisServoOn(1,1)
SetAuxDO(0,1,0,0)
SetAuxDO(1,0,0,0)
SetAuxDO(2,0,0,0)
WaitMs(1000)

SetAuxDO(5,1,0,0) -- Disengage rail break
-- Temp Vars for small boxes in office

l = 385 --Length of box
w = 325 -- Width of box
h = 320 -- Height of box
-- Loop vars
col = 1 --Collumn counter for loop (INDEX AT 1)
row = 1 --Row counter for loop (INDEX AT 1)
layer = 0 -- Which layer you're building (FIRST LAYER IS 0)
-- IMPORANT!!!!!
-- Set BIC to be at height of first box on top of pallet
-- END OF IMPORTANT!!!!
max_col = (1219 / w)
max_row = (1219 / l)
max_layers = (1930 / h) - 1
EXT_AXIS_PTP(1,LeftPrepRailLow,100)
PTP(LeftPrepRailLow,100,0,0)
while(1) do
    SetAuxDO(0,0,0,0)
    SetAuxDO(1,1,0,0) -- Use Yellow
    SetAuxDO(2,0,0,0) 
    WaitMs(1000)
    -- Wait for go signal (either sensor or DO from Master)
    if(GetDI(5, 0) == 1 or GetDI(5,0) == 0) then
        SetAuxDO(0,0,0,0)
        SetAuxDO(1,0,0,0)
        SetAuxDO(2,1,0,0) -- Use Red
        -- Move to hover pose
        if(layer < 2) then
            PTP(GrabRailLow,100,-1,1,(2 * h),0, 0,0,0,0)
            SetDO(1,1,0,0) -- Turn on vacuum
            Lin(GrabRailLow,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
            WaitMs(300) -- Wait to ensure suction
            Lin(GrabRailLow,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
            -- Either put the go signal for the slave here...
            -- SetDO(SlaveGo, 1, 0, 0)
            PTP(LeftMidPtRailLow,100,500,1,layer * h - 265, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
            -- ...or here. Depends on how much faith you have in max speed
            -- Place box in prep spot (10mm offset in all directions)
            PTP(LeftBICRailLow, 100,500,1, (h * layer) + 50, ((col-1) * l) + 20 , ((row-1) * w) + 20, 0, 0, 0)
            -- Do linear drop to pallet position to ensure minimal colisions or shifting
            Lin(LeftBICRailLow,100,500,0,1,(h * layer)-10,((col-1) * l), ((row-1) * w),0,0,0)
            SetDO(1,0,0,0) -- Release gripper
            WaitMs(300) -- Wait to ensure vacuum is released
        elseif (layer < 5) then
            PTP(LeftGrabRailMid,100,-1,1,(2 * h),0, 0,0,0,0)
            SetDO(1,1,0,0) -- Turn on vacuum
            Lin(LeftGrabRailMid,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
            WaitMs(300) -- Wait to ensure suction
            Lin(LeftGrabRailMid,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
            -- Either put the go signal for the slave here...
            -- SetDO(SlaveGo, 1, 0, 0)
            PTP(LeftMidPtRailMid,100,500,1,(layer - 2) * h - 265, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
            -- ...or here. Depends on how much faith you have in max speed
            -- Place box in prep spot (10mm offset in all directions)
            PTP(LeftBICRailMid, 100,500,1, (h * (layer - 2)) + 50, ((col-1) * l) + 20 , ((row-1) * w) + 20, 0, 0, 0)
            -- Do linear drop to pallet position to ensure minimal colisions or shifting
            Lin(LeftBICRailMid,100,500,0,1,(h * (layer - 2))-10, ((col-1) * l), ((row-1) * w),0,0,0)
            SetDO(1,0,0,0) -- Release gripper
            WaitMs(300) -- Wait to ensure vacuum is released
        else
            PTP(LeftGrabRailHigh,100,-1,1,(2 * h),0, 0,0,0,0)
            SetDO(1,1,0,0) -- Turn on vacuum
            Lin(LeftGrabRailHigh,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
            WaitMs(300) -- Wait to ensure suction
            Lin(LeftGrabRailHigh,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
            -- Either put the go signal for the slave here...
            -- SetDO(SlaveGo, 1, 0, 0)
            PTP(LeftMidPtRailHigh,100,500,1,(layer - 4) * h - 165, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
            -- ...or here. Depends on how much faith you have in max speed
            -- Place box in prep spot (10mm offset in all directions)
            PTP(LeftBICRailHigh, 100,500,1, (h * (layer - 5)) + 50, ((col-1) * l) + 20 , ((row-1) * w) + 20, 0, 0, 0)
            -- Do linear drop to pallet position to ensure minimal colisions or shifting
            Lin(LeftBICRailHigh,100,500,0,1,(h * (layer - 5))-10, ((col-1) * l), ((row-1) * w),0,0,0)
            SetDO(1,0,0,0) -- Release gripper
            WaitMs(300) -- Wait to ensure vacuum is released
        end
        -- Adjust loop values
        if(row % max_row == 0) then
            row = 1
            if(col % max_col == 0) then
                col = 1
                layer = layer + 1
                if(layer == 2)then
                    WaitMs(10)
                    EXT_AXIS_PTP(1,LeftPrepRailMid,100)
                    PTP(LeftPrepRailMid,100,0,0)
                elseif (layer == 5) then
                    EXT_AXIS_PTP(1,LeftPrepRailHigh,100)
                    PTP(LeftPrepRailHigh,100,0,0)
                end
            else
                col = col + 1
            end
        else
            row = row + 1
        end
        if (layer < 2) then
            -- TODO
            PTP(LeftPrepRailLow,100,0,0)
        elseif (layer < 5) then
            PTP(LeftPrepRailMid,100,0,0)
        elseif (layer >= 6) then
            while(1) do
                WaitMs(50)
            end
        else
            PTP(LeftPrepRailHigh,100,0,0)
        end
        -- TO DO HERE: Read GO sensor from either sensor or Master
        -- If GO sensor is high: go straight to pickup W veLeftical offset
        -- PTP(LeftBaseGrab,100,-1,1,0,0,(2 * h),0,0,0) -- GO to grab prep
        -- else: Go to prep pos and check GO sensor at arrival
        --PTP(LeftPrepPt,100,-1,1, (-1 * rail_x_offset), 0, (-1 * rail_z_offset), 0, 0, 0) -- Go to prep position to wait for GO signal
    end
end


col = 1 --Collumn counter for loop (INDEX AT 1)
row = 1 --Row counter for loop (INDEX AT 1)
layer = 0 -- Which layer you're building (FIRST LAYER IS 1)
max_col = 1
max_row = 1

while(1) do
    -- Wait for go signal (either sensor or DO from Master)
    if(GetDI(5, 0) == 1 or GetDI(5,0) == 0) then
        -- Move to hover pose
        if(layer < 3) then
            PTP(RtGrabRailLow,100,-1,1,(2 * h),0, 0,0,0,0)
            SetDO(1,1,0,0) -- Turn on vacuum
            Lin(RtGrabRailLow,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
            WaitMs(300) -- Wait to ensure suction
            Lin(RtGrabRailLow,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
            -- Either put the go signal for the slave here...
            -- SetDO(SlaveGo, 1, 0, 0)
            PTP(RtMidPtRailLow,100,500,1,layer * h - 265, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
            -- ...or here. Depends on how much faith you have in max speed
            -- Place box in prep spot (10mm offset in all directions)
            PTP(RtBICRailLow, 100,500,1, (h * layer) + 50, ((col-1) * l) + 20 , -1 * ((row-1) * w) - 20, 0, 0, 0)
            -- Do linear drop to pallet position to ensure minimal colisions or shifting
            Lin(RtBICRailLow,100,500,0,1,(h * layer)-10,((col-1) * l), -1 * ((row-1) * w),0,0,0)
            SetDO(1,0,0,0) -- Release gripper
            WaitMs(300) -- Wait to ensure vacuum is released
        
        elseif (layer < 6) then
            PTP(RtGrabRailMid,100,-1,1,(2 * h),0, 0,0,0,0)
            SetDO(1,1,0,0) -- Turn on vacuum
            Lin(RtGrabRailMid,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
            WaitMs(300) -- Wait to ensure suction
            Lin(RtGrabRailMid,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
            -- Either put the go signal for the slave here...
            -- SetDO(SlaveGo, 1, 0, 0)
            PTP(RtMidPtRailMid,100,500,1,(layer - 3) * h - 265, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
            -- ...or here. Depends on how much faith you have in max speed
            -- Place box in prep spot (10mm offset in all directions)
            PTP(RtBICRailMid, 100,500,1, (h * (layer - 3)) + 50, ((col-1) * l) + 20 , -1 * ((row-1) * w) - 20, 0, 0, 0)
            -- Do linear drop to pallet position to ensure minimal colisions or shifting
            Lin(RtBICRailMid,100,500,0,1,(h * (layer - 3))-10,((col-1) * l), -1 * ((row-1) * w),0,0,0)
            SetDO(1,0,0,0) -- Release gripper
            WaitMs(300) -- Wait to ensure vacuum is released
        
        else
            PTP(RtGrabRailHigh,100,-1,1,(2 * h),0, 0,0,0,0)
            SetDO(1,1,0,0) -- Turn on vacuum
            Lin(RtGrabRailHigh,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
            WaitMs(300) -- Wait to ensure suction
            Lin(RtGrabRailHigh,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
            -- Either put the go signal for the slave here...
            -- SetDO(SlaveGo, 1, 0, 0)
            PTP(RtMidPtRailHigh,100,500,1,(layer - 6) * h - 265, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
            -- ...or here. Depends on how much faith you have in max speed
            -- Place box in prep spot (10mm offset in all directions)
            PTP(RtBICRailHigh, 100,500,1, (h * (layer - 6)) + 50, ((col-1) * l) + 20 , -1 * ((row-1) * w) - 20, 0, 0, 0)
            -- Do linear drop to pallet position to ensure minimal colisions or shifting
            Lin(RtBICRailHigh,100,500,0,1,(h * (layer - 6))-10,((col-1) * l), -1 * ((row-1) * w),0,0,0)
            SetDO(1,0,0,0) -- Release gripper
            WaitMs(300) -- Wait to ensure vacuum is released
        end
        -- Adjust loop values
        if(row % max_row == 0) then
            row = 1
            if(col % max_col == 0) then
                col = 1
                layer = layer + 1
                if(layer == 3)then
                    WaitMs(10)
                    EXT_AXIS_PTP(1,RtPrepRailMid,100)
                    PTP(RtPrepRailMid,100,0,0)
                
                elseif (layer == 6) then
                    EXT_AXIS_PTP(1,RtPrepRailHigh,100)
                    PTP(RtPrepRailHigh,100,0,0)
                end
            else
                col = col + 1
            end
        else
            row = row + 1
        end
        if (layer < 3) then
            -- TODO
            PTP(RtPrepRailLow,100,0,0)
        elseif (layer < 6) then
            PTP(RtPrepRailMid,100,0,0)
        else
            PTP(RtPrepRailHigh,100,0,0)
        end
        -- TO DO HERE: Read GO sensor from either sensor or Master
        -- If GO sensor is high: go straight to pickup W vertical offset
        -- PTP(RtBaseGrab,100,-1,1,0,0,(2 * h),0,0,0) -- GO to grab prep
        -- else: Go to prep pos and check GO sensor at arrival
        --PTP(RtPrepPt,100,-1,1, (-1 * rail_x_offset), 0, (-1 * rail_z_offset), 0, 0, 0) -- Go to prep position to wait for GO signal
    end
end