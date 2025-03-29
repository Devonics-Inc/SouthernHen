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
max_col = math.floor(1219 / w)
max_row = math.floor(1219 / l)
max_layers = math.floor(1930 / h) - 1 -- Max layers in the pallet (minus 1 for the first layer)
-- Thresholds for rail movement
max_layer_low = math.floor(max_layers / 3) -- At this layer, move rail to mid
max_layer_mid = 2 * max_layer_low -- At this layer, move rail to high
-- Side 1 = Left side, Side 2 = Right side
LEFT = 1
RIGHT = 2
--ESTABLISH CONNECTION WITH OTHER ROBOT HERE:
    -- TODO: Set up communication with slave robot here

-- Forever do...
while(1) do
    while(side == LEFT) do
        SetAuxDO(0,0,0,0) -- Green channel
        SetAuxDO(1,1,0,0) -- YellowChannel
        SetAuxDO(2,0,0,0) -- Red channel
        WaitMs(1000)
        -- Wait for go signal (either sensor or GoSignal from Master)
        if(GetDI(5, 0) == 1 or GetDI(5,0) == 0) then -- This needs to be "if(box detected and other robot is ready)"
            SetAuxDO(0,0,0,0)
            SetAuxDO(1,0,0,0)
            SetAuxDO(2,1,0,0) -- Use Red
            -- Move to hover pose
            if(layer < max_layer_low) then
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
            elseif (layer < max_layer_mid) then
                PTP(GrabRailMid,100,-1,1,(2 * h),0, 0,0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(GrabRailMid,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(GrabRailMid,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(LeftMidPtRailMid,100,500,1,(layer - max_layer_low) * h - 265, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(LeftBICRailMid, 100,500,1, (h * (layer - max_layer_low)) + 50, ((col-1) * l) + 20 , ((row-1) * w) + 20, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(LeftBICRailMid,100,500,0,1,(h * (layer - max_layer_low))-10, ((col-1) * l), ((row-1) * w),0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            else
                PTP(GrabRailHigh,100,-1,1,(2 * h),0, 0,0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(GrabRailHigh,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(GrabRailHigh,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(LeftMidPtRailHigh,100,500,1,(layer - max_layer_mid) * h - 165, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(LeftBICRailHigh, 100,500,1, (h * (layer - max_layer_mid)) + 50, ((col-1) * l) + 20 , ((row-1) * w) + 20, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(LeftBICRailHigh,100,500,0,1,(h * (layer - max_layer_mid))-10, ((col-1) * l), ((row-1) * w),0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            end
            -- Adjust loop values
            if(row % max_row == 0) then
                row = 1
                if(col % max_col == 0) then
                    col = 1
                    layer = layer + 1
                    if(layer == max_layer_low)then
                        WaitMs(10)
                        EXT_AXIS_PTP(1,LeftPrepRailMid,100)
                        PTP(LeftPrepRailMid,100,0,0)
                    elseif (layer == max_layer_mid) then
                        EXT_AXIS_PTP(1,LeftPrepRailHigh,100)
                        PTP(LeftPrepRailHigh,100,0,0)
                    end
                else
                    col = col + 1
                end
            else
                row = row + 1
            end
            if (layer < max_layer_low) then
                -- TODO
                PTP(LeftPrepRailLow,100,0,0)
            elseif (layer < max_layer_mid) then
                PTP(LeftPrepRailMid,100,0,0)
            elseif (layer < max_layers) then
                PTP(LeftPrepRailHigh,100,0,0)
            else
                side = RIGHT
                EXT_AXIS_PTP(1,LeftPrepRailLow,100)
                PTP(LeftPrepRailLow,100,0,0)
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
    layer = 0 -- Which layer you're building (FIRST LAYER IS 0)

    while(side == RIGHT) do
        -- Wait for go signal (either sensor or DO from Master)
        if(GetDI(5, 0) == 1 or GetDI(5,0) == 0) then
            -- Move to hover pose
            if(layer < max_layer_low) then
                PTP(GrabRailLow,100,-1,1,(2 * h),0, 0,0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(GrabRailLow,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(GrabRailLow,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
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
            
            elseif (layer < max_layer_mid) then
                PTP(GrabRailMid,100,-1,1,(2 * h),0, 0,0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(GrabRailMid,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(GrabRailMid,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(RtMidPtRailMid,100,500,1,(layer - max_layer_low) * h - 265, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(RtBICRailMid, 100,500,1, (h * (layer - max_layer_low)) + 50, ((col-1) * l) + 20 , -1 * ((row-1) * w) - 20, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(RtBICRailMid,100,500,0,1,(h * (layer - max_layer_low))-10,((col-1) * l), -1 * ((row-1) * w),0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            
            else
                PTP(GrabRailHigh,100,-1,1,(2 * h),0, 0,0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(GrabRailHigh,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(GrabRailHigh,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(RtMidPtRailHigh,100,500,1,(layer - max_layer_mid) * h - 265, ((col-3) * l)/2,0,0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(RtBICRailHigh, 100,500,1, (h * (layer - max_layer_mid)) + 50, ((col-1) * l) + 20 , -1 * ((row-1) * w) - 20, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(RtBICRailHigh,100,500,0,1,(h * (layer - max_layer_mid))-10,((col-1) * l), -1 * ((row-1) * w),0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            end
            -- Adjust loop values
            if(row % max_row == 0) then
                row = 1
                if(col % max_col == 0) then
                    col = 1
                    layer = layer + 1
                    if(layer == max_layer_low)then
                        WaitMs(10)
                        EXT_AXIS_PTP(1,RtPrepRailMid,100)
                        PTP(RtPrepRailMid,100,0,0)
                    
                    elseif (layer == max_layer_mid) then
                        EXT_AXIS_PTP(1,RtPrepRailHigh,100)
                        PTP(RtPrepRailHigh,100,0,0)
                    end
                else
                    col = col + 1
                end
            else
                row = row + 1
            end
            if (layer < max_layer_low) then
                -- TODO
                PTP(RtPrepRailLow,100,0,0)
            elseif (layer < max_layer_mid) then
                PTP(RtPrepRailMid,100,0,0)
            elseif (layer < max_layers) then
                PTP(RtPrepRailHigh,100,0,0)
            else
                side = LEFT
            end
        end
    end
end