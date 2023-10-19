# The-Game-of-Life-ARM
The Game of Life coded in ARMv7.
Made in the CPUlator ARMv7 System Simulator. [Link](https://cpulator.01xz.net/?sys=arm-de1soc)

The grid is displayed in the VGA pixel buffer and the inputs are read from the PS/2 keyboard (IRQ 79)
|Input|Command|
|---	|---  |
|w/s/a/d|Move the cursor up/down/left/right|
|Space Bar|Change the tile's status (active->inactive, inactive->active)|
|n|Go to the next step|
