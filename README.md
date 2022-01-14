

# PHIL

Pipetting Helper Imaging Lid – PHIL - 2021

Open-source personal pipetting robots with live-​cell incubation and microscopy compatibility

Overview
- personal small desktop liquid handling robot
- small, light, cheap
- fast self-​assembly from 3D printed and commercial parts
- long-​term live cell culture media exchange, immunostainings, etc
- compatible with microscope stage-​top use during time-​lapse microscopy
- user-​friendly control software

Reference

If you use PHIL please cite the following paper:

Dettinger P, Kull T, Arekatla G, Ahmed N, Zhang Y, Schneiter F, Wehling A, Schirmacher D, Kawamura S, Loeffler D and Schroeder T (2021)
Personal open-source pipetting robots with stage-top live-cell incubation and imaging capability.
bioRxiv, 2021.07.04.448641

System Requirements

Hardware requirements

PHILs GUI requires only a standard computer with enough RAM to support the in-memory operations.

Software requirements

OS Requirements

This package is supported for Windows and requires Matlab 2020. The package has been tested on the following systems:

Windows 10 - Matlab 2020

This project is covered under the MIT License.

Download Files
Current version
PHIL_Complete_Resources_210716.zip (ZIP, 47.2 MB)vertical_align_bottom
2021.07.16: Added companies with international shipping options to «Order_List.xlsx» in PHIL_Complete_Resources.zip

Previous versions
2021.07.05: PHIL_Complete_Resources - .zip (ZIP, 47.2 MB)vertical_align_bottom

ZIP file contents
PHIL operation
PHIL_Operation_Instructions.pdf: Complete instructions for using PHIL
PHIL_GUI_210602.m: Executable Matlab script for PHIL gui

PHIL production
Order_List.xlsx: Complete parts list for all required parts
PHIL_Print_Instructions.pdf: Full print settings of all parts
3D print files as described below
PHIL_Assembly_Instructions.pdf: Full instructions for PHIL assembly
PHIL_Arduino_MEGA_14Pump_210216.ino: Complete Arduino sketch for PHIL operation. Requires Accelstepper library installed
 
3D print files
Individual components are encoded by the individual STL files below. You can use these to print them individually.
All required components for a PHIL robot have been grouped into 10 sets for easy simultaneous printing of several components in one print session.

Set_1.stl
Body_VB1.stl: Main body of PHIL
Body_Top_VB1.stl: Frame for mounting Z-axis stepper motors
Elbow_Left_VB1.stl: Left actuator arm for mounting limit switches
Elbow_Right_VB1.stl: Right actuator arm for mounting limit switches
Hands_VB1.stl: Left and right actuator arm
Tube_Plug_VB1.stl: Tube holder for PHIL body

Set_2.stl
Arm_Plate_VB1.stl: Stepper motor mount for left and right arms
Body_Bottom_VB1.stl: Base for main body of PHIL
 
 
Set_3_100infill.stl
LR_Arm_100Infill.stl: Left and right arms for PHIL. To be printed at 100% infill


Set_4.stl
Chamber _VB1.stl: Incubator chamber
2 x Screw_VB1.stl: Screw drives for z-axis
 
 
Set_5.stl
Chamber_Lid_VB1.stl: Lid for incubator chamber
USB_Back_VB1.stl: USB cable mounting bracket, back
USB_Front_VB1.stl: USB cable mounting bracket, front
Handle_VB1.stl: Handle for power control box
Pin_Cup_V1.stl: Pipet holder for normal wells
(Pin_Cup_V1.stl can be replaced with Pin_Cup_Deep_Well_VB1.stl when working with deep well multiwell plates - see instructions)
 
 
Set_6.stl
Power_Box_Left_VB1.stl: Left half of power control box
 
 
Set_7.stl
Power_Box_Right_VB1.stl: Right half of power control box
 
 
Set_8.stl
Arduino_Plate_VB1.stl: Plate for mounting arduinos
 
 
Set_9.stl
Mount_1x_31.stl: 6x mounting brackets for peristaltic pump
 
 
Set_10.stl
Wheel_1x_31.stl: 6x rotors for peristaltic pump


The following files are not required for a PHIL, but help the production:

tube_bender_top_v2.stl: Tube bending press outer body
tube_bender_bot_v2.stl: Tube bending press inner frame
85mm_Tube_cutter_v2.stl: Jig for cutting 85mm segment of peristaltic pump tubing
