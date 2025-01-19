# LCD Driver Module

## Overview

The `lcd_driver` module is a Verilog-based implementation of a driver for controlling an LCD display. It manages initialization, state transitions, and pixel data display, enabling smooth communication and control of an LCD panel.

## Features

- **Initialization Tasks**: Handles LCD reset and initialization sequences.
- **State Machine**: Implements a finite state machine (FSM) with the following states:
  - `IDLE`
  - `LCD_RST`
  - `LCD_INIT`
  - `DISP_RGB`
  - `DISP_PIC`
  - `DONE`
- **Pixel Rendering**: Supports rendering RGB colors and predefined image data.
- **Modular Design**: Uses tasks for organized handling of LCD operations.
- **Parameterized Constants**: Easily configurable for various LCD configurations.

## Input/Output Ports

### Inputs
- `clk`: Clock signal.
- `rst_n`: Active-low reset signal.
- `done_i [1:0]`: Signals indicating the completion of tasks.

### Outputs
- `en_o [1:0]`: Enable signals for controlling the LCD.
- `data_o [8:0]`: Data bus for pixel data and commands.

## Parameters

The module defines several constants for convenience:
- RGB color definitions: `RED`, `GREEN`, `BLUE`, `BLACK`, and `WHITE`.
- Timing constants: `TIME_120MS` and `TIME_3S`.
- Image dimensions: `PIC_X`, `PIC_Y`, `PIC_W`, and `PIC_H`.

## Finite State Machine (FSM)

The FSM manages the following states:
1. `IDLE`: Default state, initializes internal registers.
2. `LCD_RST`: Executes the LCD reset sequence.
3. `LCD_INIT`: Configures the LCD with initial settings.
4. `DISP_RGB`: Displays RGB patterns on the LCD.
5. `DISP_PIC`: Displays an image using preloaded data.
6. `DONE`: Terminal state for completing all tasks.

## Image Data Management

- **Image Array**: The `pic_data_array` stores pixel data for rendering images. Data is loaded from an external file using `$readmemh()`.
- **Image Dimensions**: The module is set to display images of width `128` and height `35` pixels.

## Tasks

The module uses Verilog tasks for modular implementation:
- `idle_task`: Resets and initializes variables.
- `lcd_rst_task`: Manages the LCD reset sequence.
- `lcd_init_task`: Handles LCD initialization commands.
- `disp_rgb_task`: Displays RGB patterns.
- `disp_pic_task`: Renders image data.

## Usage

1. **Include the Module**: Integrate the `lcd_driver` module into your Verilog project.
2. **Configure Parameters**: Modify constants as needed for your LCD specifications.
3. **Provide Input Data**: Load image data into `pic_data_array` using a memory initialization file (`$readmemh`).
4. **Simulate or Synthesize**: Test the module in simulation or synthesize it for FPGA deployment.

## Example Simulation

Here’s a basic simulation setup:

```verilog
module lcd_driver_tb;
    reg clk;
    reg rst_n;
    wire [1:0] en_o;
    wire [8:0] data_o;
    reg [1:0] done_i;

    lcd_driver uut (
        .clk(clk),
        .rst_n(rst_n),
        .en_o(en_o),
        .data_o(data_o),
        .done_i(done_i)
    );

    initial begin
        clk = 0;
        rst_n = 0;
        done_i = 2'b0;

        #10 rst_n = 1; // Release reset
        #100 $stop; // End simulation
    end

    always #5 clk = ~clk; // Clock generator
endmodule
