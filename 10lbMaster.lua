-- Set up rail communication and enable rail
ExtDevSetUDPComParam("192.168.57.88", 2021, 2)
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
col = 0 --Collumn counter for loop (INDEX AT 1)
row = 0 --Row counter for loop (INDEX AT 1)
layer = 0 -- Which layer you're building (FIRST LAYER IS 0)

-- IMPORANT!!!!!
-- Set BIC to be at height of first box on top of pallet
-- END OF IMPORTANT!!!!

-- REAL VALUES:
-- max_layer_low = 5 -- At this layer, move rail to mid
-- max_layer_mid = 10 -- At this layer, move rail to high
-- max_layers = 16 -- Max layers in the pallet (minus 1 for the first layer)

-- TEST VALUES:
max_layer_low = 2 -- At this layer, move rail to mid
max_layer_mid = 4 -- At this layer, move rail to high
max_layers = 5 -- Max layers in the pallet (minus 1 for the first layer)



pause_layer = 3
-- Side 1 = Left side, Side 2 = Right side
LEFT = 1
RIGHT = 2
--ESTABLISH CONNECTION WITH OTHER ROBOT HERE:
    -- TODO: Set up communication with slave robot here
    
EXT_AXIS_PTP(0,RailHigh,100)
EXT_AXIS_PTP(0,RailLow,100)

side = RIGHT
rail_pos = 0
pattern = 1
-- Forever do...
while(1) do
    box_num = 0
    while(side == LEFT) do
        WaitMs(500)
        -- if (get_pallet_reset_di == 1) then 
            -- SetAuxDO(0,1,0,0) -- Green channel
            -- SetAuxDO(1,0,0,0) -- YellowChannel
            -- SetAuxDO(2,0,0,0) -- Red channel
        -- Wait for go signal (either sensor or GoSignal from Master)
        if(GetDI(5, 0) == 1 or GetDI(5,0) == 0) then -- This needs to be "if(box detected and other robot is ready)"
            if (pattern == 1) then
                -- call pattern 1 LEFT
                SetSysVarValue(s_var_1, layer)
                SetSysVarValue(s_var_2, rail_pos)
                NewDofile("/fruser/left_pattern_1_10lb.lua", 1, 1)
				DofileEnd()
				if(layer >= pause_layer - 1) then
				    pattern = 2
				end
                
            elseif (pattern == 2) then
                -- call pattern 2 LEFT
                SetSysVarValue(s_var_1, layer)        
                SetSysVarValue(s_var_2, rail_pos)
                NewDofile("/fruser/left_pattern_2_10lb.lua",1,2)
    			DofileEnd()
    			if(layer >= pause_layer - 1) then
    			    pattern = 1
    			end
            end
            if(layer == pause_layer - 1) then
                SetAuxDO(0,0,0,0) -- Green channel
                SetAuxDO(1,1,0,0) -- YellowChannel
                SetAuxDO(2,0,0,0) -- Red channel
                while(GetDI(1, 0) == 0) do
                    WaitMs(500)
                end
                SetAuxDO(0,1,0,0) -- Green channel
                SetAuxDO(1,0,0,0) -- YellowChannel
                SetAuxDO(2,0,0,0) -- Red channel
            end
            layer = layer + 1
            if(layer == max_layer_low)then
                rail_pos = 50 -- Most likely 100 in the field
                EXT_AXIS_PTP(0,RailMid,100)
            elseif (layer == max_layer_mid) then
                rail_pos = 100 -- Most likely 200 in the field
                EXT_AXIS_PTP(0,RailHigh,100)
            elseif (layer == max_layers - 1) then
                side = RIGHT
                -- Reset offsets for RIGHT side
                z_offset = h * layer - rail_pos
                PTP(LeftPrep,100,0,1,0,0, z_offset, 0,0,0)
                EXT_AXIS_PTP(0,RailLow,100)
                rail_pos = 0 -- Reset rail pos
                layer = 0
                SetAuxDO(0,0,0,0) -- Green channel
                SetAuxDO(1,1,0,0) -- YellowChannel
                SetAuxDO(2,0,0,0) -- Red channel
            end
            SetSysVarValue(s_var_1, layer)
            SetSysVarValue(s_var_2, rail_pos)
            -- TO DO HERE: Read GO sensor from either sensor or Master
            -- If GO sensor is high: go straight to pickup W veLeftical offset
            -- PTP(LeftBaseGrab,100,-1,1,0,0,(2 * h),0,0,0) -- GO to grab prep
            -- else: Go to prep pos and check GO sensor at arrival
            --PTP(LeftPrepPt,100,-1,1, (-1 * rail_x_offset), 0, (-1 * rail_z_offset), 0, 0, 0) -- Go to prep position to wait for GO signal
        end
    end
    
    layer = 0 -- Which layer you're building (FIRST LAYER IS 0)
    while(side == RIGHT) do
        -- Wait for go signal (either sensor or DO from Master)
        if(GetDI(5, 0) == 1 or GetDI(5,0) == 0) then -- This needs to be "if(box detected and other robot is ready)"
            if (pattern == 1) then
                -- call pattern 1 LEFT
                SetSysVarValue(s_var_1, layer)
                SetSysVarValue(s_var_2, rail_pos)
                NewDofile("/fruser/right_pattern_1_10lb.lua", 1, 3)
				DofileEnd()
				if(layer >= pause_layer) then
				    pattern = 2
                end
            elseif (pattern == 2) then
                -- call pattern 2 LEFT
                SetSysVarValue(s_var_1, layer)        
                SetSysVarValue(s_var_2, rail_pos)
                NewDofile("/fruser/right_pattern_2_10lb.lua",1,4)
    			DofileEnd()
    			if(layer >= pause_layer) then
    			    pattern = 1
    			end
            end
            if(layer == pause_layer) then
                SetAuxDO(0,0,0,0) -- Green channel
                SetAuxDO(1,1,0,0) -- YellowChannel
                SetAuxDO(2,0,0,0) -- Red channel
                while(GetDI(2, 0) == 0) do
                    WaitMs(500)
                end
                SetAuxDO(0,1,0,0) -- Green channel
                SetAuxDO(1,0,0,0) -- YellowChannel
                SetAuxDO(2,0,0,0) -- Red channel
            end
            layer = layer + 1
            if(layer == max_layer_low)then
                rail_pos = 50 -- Most likely 100 in the field
                EXT_AXIS_PTP(0,RailMid,100)
            elseif (layer == max_layer_mid) then
                rail_pos = 100 -- Most likely 200 in the field
                EXT_AXIS_PTP(0,RailHigh,100)
            elseif (layer == max_layers - 1) then
                side = LEFT
                -- Reset offsets for RIGHT side
                z_offset = h * layer - rail_pos
                PTP(RtPrep,100,0,1,0,0, z_offset, 0,0,0)
                EXT_AXIS_PTP(0,RailLow,100)
                rail_pos = 0 -- Reset rail pos
                layer = 0
                SetAuxDO(0,0,0,0) -- Green channel
                SetAuxDO(1,1,0,0) -- YellowChannel
                SetAuxDO(2,0,0,0) -- Red channel
            end
        end
    end
end