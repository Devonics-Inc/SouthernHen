-- Set up rail communication and enable rail
ExtDevSetUDPComParam("192.168.57.88", 2021, 2, 50, 10, 50, 1, 2, 5)
ExtDevLoadUDPDriver()
ExtAxisServoOn(1,1)
SetAuxDO(0,1,0,0)
SetAuxDO(1,0,0,0)
SetAuxDO(2,0,0,0)
WaitMs(1000)

SetAuxDO(5,1,0,0) -- Disengage rail break

l = 445 --Length of 10lb box
w = 248 -- Width of 10lb box
h = 115 -- Height of 10lb box

-- Loop vars
col = 1 --Collumn counter for loop (INDEX AT 1)
row = 1 --Row counter for loop (INDEX AT 1)
layer = 0 -- Which layer you're building (FIRST LAYER IS 0)

-- IMPORANT!!!!!
-- Set BIC to be at height of first box on top of pallet
-- END OF IMPORTANT!!!!

max_col = 4
max_row = 5


max_layer_low = 5 -- At this layer, move rail to mid
max_layer_mid = 10 -- At this layer, move rail to high
max_layers = 16 -- Max layers in the pallet (minus 1 for the first layer)

pause_layer = 5
-- Side 1 = Left side, Side 2 = Right side
LEFT = 1
RIGHT = 2
--ESTABLISH CONNECTION WITH OTHER ROBOT HERE:
    -- TODO: Set up communication with slave robot here


-- Forever do...
while(1) do
    box_num = 0
    while(side == LEFT) do
        WaitMs(1000)
        -- if (get_pallet_reset_di == 1) then 
            -- SetAuxDO(0,1,0,0) -- Green channel
            -- SetAuxDO(1,0,0,0) -- YellowChannel
            -- SetAuxDO(2,0,0,0) -- Red channel
        -- Wait for go signal (either sensor or GoSignal from Master)
        if(GetDI(5, 0) == 1 or GetDI(5,0) == 0) then -- This needs to be "if(box detected and other robot is ready)"
            SetAuxDO(0,0,0,0)
            SetAuxDO(1,0,0,0)
            SetAuxDO(2,1,0,0) -- Use Red
            -- Move to hover pose
            if(layer < max_layer_low) then
                PTP(Grab,100,-1,1,0, 0,(2 * h),0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(Grab,100,-1,0,1,0,0,(h-13), 0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(Grab,50,-1,0,1,0,0,(h+165), 0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(LeftMidPtRail,100,500,1, ((col-3) * l)/2,0, (layer * h) - 265,0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(LeftBIC, 100,500,1, ((col-1) * l) + 20 , ((row-1) * w) + 20, (h * layer) + 50, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(LeftBIC,100,500,0,1,((col-1) * l), ((row-1) * w), (h * layer)-10, 0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            elseif (layer < max_layer_mid) then
                PTP(Grab,100,-1,1,0, 0,(2 * h),0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(Grab,100,-1,0,1, 0, 0, (h-13), 0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(Grab,50,-1,0,1,0,0, (h+165), 0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(LeftMidPtRail,100,500,1, ((col-3) * l)/2,0, (layer  * h) - 265, 0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(LeftBIC, 100,500,1, ((col-1) * l) + 20 , ((row-1) * w) + 20, (h * layer) + 50, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(LeftBIC,100,500,0,1, ((col-1) * l), ((row-1) * w), (h * layer)-10,0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            else
                PTP(Grab,100,-1,1,(2 * h),0, 0,0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(Grab,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(Grab,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(LeftMidPtRail,100,500,1, ((col-3) * l)/2,0,(layer * h - 165),0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(LeftBIC, 100,500,1, ((col-1) * l) + 20 , ((row-1) * w) + 20, (h * layer) + 50, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(LeftBIC,100,500,0,1, ((col-1) * l), ((row-1) * w),(h * layer)-10,0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            end
            -- Adjust loop values
            if(row == max_row) then
                row = 1
                if(col == max_col) then
                    col = 1
                    layer = layer + 1
                    if(layer == max_layer_low)then
                        WaitMs(10)
                        EXT_AXIS_PTP(0,LeftPrep,100)
                        PTP(LeftPrep,100,0,0)
                    elseif (layer == max_layer_mid) then
                        EXT_AXIS_PTP(0,LeftPrep,100)
                        PTP(LeftPrep,100,0,0)
                    end
                else
                    col = col + 1
                end
            else
                row = row + 1
            end
            if (layer < max_layer_low) then
                -- TODO
                PTP(LeftPrep,100,0,0)
            elseif (layer < max_layer_mid) then
                PTP(LeftPrep,100,0,0)
            elseif (layer < max_layers - 1) then
                PTP(LeftPrep,100,0,0)
            else
                box_num = 0
                side = RIGHT
                layer = 0
                col = 1
                row = 1
                EXT_AXIS_PTP(0,LeftPrep,100)
                PTP(LeftPrep,100,0,0)
                SetAuxDO(0,0,0,0) -- Green channel
                SetAuxDO(1,1,0,0) -- YellowChannel
                SetAuxDO(2,0,0,0) -- Red channel
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
        -- if(get_pallet_reset == 1) then 
            -- SetAuxDO(0,1,0,0) -- Green channel
            -- SetAuxDO(1,0,0,0) -- YellowChannel
            -- SetAuxDO(2,0,0,0) -- Red channel
        -- Wait for go signal (either sensor or DO from Master)
        if(GetDI(5, 0) == 1 or GetDI(5,0) == 0) then
            -- Move to hover pose
            if(layer < max_layer_low) then
                PTP(Grab,100,-1,1, (2 * h),0, 0,0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(Grab,100,-1,0,1, (h-13), 0,0,0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(Grab,50,-1,0,1, (h+165), 0,0,0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(RtMidPtRail,100,500,1, ((col-3) * l)/2,0, (layer * h) - 265,0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(RtBIC, 100,500,1, ((col-1) * l) + 20 , -1 * ((row-1) * w) - 20, (h * layer) + 50, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(RtBIC,100,500,0,1,((col-1) * l), -1 * ((row-1) * w), (h * layer)-10,0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            
            elseif (layer < max_layer_mid) then
                PTP(Grab,100,-1,1,(2 * h),0, 0,0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(Grab,100,-1,0,1,h-13,0,0,0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(Grab,50,-1,0,1,h+165,0,0,0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(RtMidPtRail,100,500,1, ((col-3) * l)/2,0,layer * h - 265,0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(RtBIC, 100,500,1, ((col-1) * l) + 20 , -1 * ((row-1) * w) - 20, (h * layer) + 50, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(RtBIC,100,500,0,1,((col-1) * l), -1 * ((row-1) * w), (h * layer )-10,0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            
            else
                PTP(Grab,100,-1,1,(2 * h),0, 0,0,0,0)
                SetDO(1,1,0,0) -- Turn on vacuum
                Lin(Grab,100,-1,0,1,0,0,h-13,0,0,0)-- Go to 5 mm below height of box
                WaitMs(300) -- Wait to ensure suction
                Lin(Grab,50,-1,0,1,0,0,h+165,0,0,0) -- Go straight up after grab
                -- Either put the go signal for the slave here...
                -- SetDO(SlaveGo, 1, 0, 0)
                PTP(RtMidPtRail,100,500,1, ((col-3) * l) / 2, 0, layer  * h - 265, 0,0,0)-- Go to mid pt (might need an ofset in the field)
                -- ...or here. Depends on how much faith you have in max speed
                -- Place box in prep spot (10mm offset in all directions)
                PTP(RtBIC, 100,500,1, ((col-1) * l) + 20 , -1 * ((row-1) * w) - 20, (h * layer) + 50, 0, 0, 0)
                -- Do linear drop to pallet position to ensure minimal colisions or shifting
                Lin(RtBIC,100,500,0,1,((col-1) * l), -1 * ((row-1) * w),(h * layer)-10,0,0,0)
                SetDO(1,0,0,0) -- Release gripper
                WaitMs(300) -- Wait to ensure vacuum is released
            end
            -- Adjust loop values
            if(row == max_row) then
                row = 1
                if(col == max_col) then
                    col = 1
                    layer = layer + 1
                    if(layer == max_layer_low)then
                        WaitMs(10)
                        EXT_AXIS_PTP(0,RtPrep,100)
                        PTP(RtPrep,100,0,0)
                    
                    elseif (layer == max_layer_mid) then
                        EXT_AXIS_PTP(0,RtPrep,100)
                        PTP(RtPrep,100,0,0)
                    end
                else
                    col = col + 1
                end
            else
                row = row + 1
            end
            if (layer < max_layer_low) then
                -- TODO
                PTP(RtPrep,100,0,0)
            elseif (layer < max_layer_mid) then
                PTP(RtPrep,100,0,0)
            elseif (layer < (max_layers - 1)) then
                PTP(RtPrep,100,0,0)
            else
                side = LEFT
                EXT_AXIS_PTP(0,RtPrep,100)
                PTP(RtPrep,100,0,0)
                layer = 0
                col = 1
                row = 1
                box_num = 0
                SetAuxDO(0,0,0,0) -- Green channel
                SetAuxDO(1,1,0,0) -- YellowChannel
                SetAuxDO(2,0,0,0) -- Red channel
            end
        end
    end
end