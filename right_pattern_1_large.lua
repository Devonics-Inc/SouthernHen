--                  BIC
--    | []  []  []  [] | 
--    | ===  ===  ===  | 
--    | ===  ===  ===  | 

layer = GetSysVarValue(s_var_1)
rail_pos = GetSysVarValue(s_var_2)
-- REAL VALUES
w = 295-- Width of 20lb large  box
l = 399 --Length of 20lb large box
h = 240 -- Height of 20lb large box

row = 0
col = 0

x_offset = 0
y_offset = 0
rot_offset = 0
z_offset = (layer * h) - rail_pos
box_num = 1 
SetAuxDO(0,0,0,0)
SetAuxDO(1,0,0,0)
SetAuxDO(2,1,0,0) -- Use Red
while(1) do
    -- Move to hover pose
    rot_offset = 0
    PTP(Grab,100,-1,1,0, 0,(2 * h) - rail_pos,0,0,0)
    SetDO(1,1,0,0) -- Turn on vacuum
    Lin(Grab,100,-1,0,1,0,0,(h-13) - rail_pos, 0,0,0)-- Go to 5 mm below height of box
    WaitMs(300) -- Wait to ensure suction
    Lin(Grab,50,-1,0,1,0,0,(h+165) - rail_pos, 0,0,0) -- Go straight up after grab
    -- Either put the go signal for the slave here...
    -- SetDO(SlaveGo, 1, 0, 0)
    if(box_num < 5) then
        rot_offset = -90
        -- X offset should be 2 box widths plus the offset of rotating the box
        x_offset = -1 * ((l - w) / 2)
        y_offset = (w * (box_num - 1)) - ((l - w) / 2)
    else 
        rot_offset = 0
        x_offset = -1 * ((w * col) + l)
        y_offset = (l * row)
    end

    PTP(RtMidPt20lb_large,100,500,1, 0, 0, z_offset,0,0,rot_offset)-- Go to mid pt (might need an ofset in the field)
    -- ...or here. Depends on how much faith you have in max speed
    -- Place box in prep spot (10mm offset in all directions)
    PTP(RtBIC20lb_large, 100,500,1, x_offset - 30 ,y_offset + 10, z_offset + 50, 0, 0, rot_offset)
    Lin(RtBIC20lb_large,100,500,0,1,x_offset,y_offset,z_offset-10,0,0,rot_offset)
    SetDO(1,0,0,0) -- Release gripper
    WaitMs(300) -- Wait to ensure vacuum is released
    Lin(RtBIC20lb_large,100,500,0,1,x_offset,y_offset, z_offset+100,0,0,rot_offset)
    PTP(RtPrep20lb_large,100,0,1,0,0, z_offset, 0,0,0)
    box_num = box_num + 1
    if box_num > 5 then
        if(row == 2) then
            row = 0
            if(col == 1) then
                PTP(RtPrep20lb_large,100,0,1,0,0, z_offset, 0,0,0)
                break
            else
                col = col + 1
            end
        else
            row = row + 1
        end
    end
    
    if (box_num == 11) then
        PTP(RtPrep20lb_large,100,0,1,0,0, z_offset, 0,0,0)
        break
    end
end