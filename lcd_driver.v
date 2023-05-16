module lcd_driver (
    input clk,
    input rst_n,

    output reg [1:0] en_o,
    output reg [8:0] data_o,
    input [1:0] done_i
);
    
    localparam  RED = 16'hf800,
                GREEN = 16'h07e0,
                BLUE = 16'h001f,
                BLACK = 16'h0000,
                WHITE = 16'hffff;


reg state_done;

reg [7:0] reg_id;
reg [8:0] reg_init [72:0];

reg [3:0] flow_ctrl;
reg [3:0] flow_sub_ctrl;


reg [27:0] delay_cnt;
localparam  TIME_120MS = 6_000_000,
            TIME_3S = 150_000_000;


localparam PIC_X = 0,
           PIC_W = 128,
           PIC_Y = 0,
           PIC_H = 35,
           array_len = 4480;

(* ramstyle = "M9K" * ) reg [15:0] pic_data_array [array_len-1:0];
reg [15:0] pic_id;
reg [15:0]  pic_data;

initial begin
    $readmemh("", pic_data_array);
end

always @(posedge clk) begin
    pic_data <= pic_data_array[pic_id];
end

reg [5:0]  cur_state;
reg [5:0] next_state;

localparam IDLE     = 6'b00_0001,
           LCD_RST  = 6'b00_0010,
           LCD_INIT = 6'b00_0100,
           DISP_RGB = 6'b00_1000,
           DISP_PIC = 6'b01_0000,
           DONE     = 6'b10_0000;


// sequential state transition.
always @(posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
        cur_state <= IDLE;
    end else begin
        cur_state <= next_state;
    end
end



always @(*) begin
    case(cur_state)
        IDLE:
            next_state <= LCD_RST;
        LCD_RST:
            if(state_done == 1'd1)
                next_state <= LCD_INIT;
            else
                next_state <= LCD_RST;
        LCD_INIT:
            if(state_done == 1'd1)
                next_state <= DISP_RGB;
            else
                next_state <= LCD_INIT;
        DISP_RGB:
            if(state_done == 1'd1)
                next_state <= DISP_PIC;
            else
                next_state <= DISP_RGB;
        DISP_PIC:
            if(state_done == 1'd1)
                next_state <= DONE;
            else
                next_state <= DISP_PIC;
        DONE:
            next_state <= DONE;
        default:
            next_state <= IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        idle_task;
    else
        case(next_state)
            IDLE:
                idle_task;
            LCD_RST:
                lcd_rst_task;
            LCD_INIT:
                lcd_init_task;
            DISP_RGB:
                disp_rgb_task;
            DISP_PIC:
                disp_pic_task;
            DONE:
                idle_task;
            default:idle_task;
        endcase

end

task idle_task;
    begin
        state_done <= 1'b0;

        en_o <= 2'd0;
        data_o <= 9'd0;

        reg_id <= 8'd0;
        delay_cnt <= 28'd0;

        flow_ctrl <= 4'd0;
        flow_sub_ctrl <= 4'd0;

        x_cnt <= 8'd0;
        y_cnt <= 8'd0;

        pic_id <= 16'd0;
        init_reg_task;
    end
endtask

task lcd_rst_task;
    begin
        state_done <= 1'b0;
        case (flow_ctrl)
            4'd0:
            begin
                en_o[0] <= 1'b1;
                flow_ctrl <= 4'd1;
            end

            4'd1:
                begin
                    en_o[0] <= 1'b0;
                    if (done_i[0])
                        flow_ctrl <= 4'd2
                end
            
            4'd2:
                begin
                    state_done < = 1'b1;
                    flow_ctrl <= 4'd0;
                end

            default:
                flow_ctrl <= 4'd0;
        endcase
    end
endtask




endmodule
