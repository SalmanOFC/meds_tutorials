module sequential_multiply_controller (
    input logic CLK,
    input logic RESET,
    input logic start,
    input logic b_val,
    input logic stop,
    output logic en_A,en_B,
    output logic sign_sel,
    output logic a_sel,
    output logic count_en,
    output logic clear,
    output logic prod_clear,
    output logic READY
);

parameter S0 = 1'b0;
parameter S1 = 1'b1;
logic n_state, c_state;

always_ff @(posedge CLK or negedge RESET)
begin
    if (!RESET)
        c_state <= #1 S0;
    else
        c_state <= #1 n_state;
end

always_comb 
begin
    case(c_state)
    S0: begin
            if (start)
                n_state = S1;
            else
                n_state = S0;
        end
    S1: begin
            if (stop)
                n_state = S0;
            else
                n_state = S1;
        end
    endcase
end
    
always_comb
begin
    case(c_state)
    S0: begin
            if (start)                          // store A and B
                begin
                    en_A      = 1;
                    en_B      = 1;
                    sign_sel  = 0;
                    a_sel     = 0;
                    count_en  = 0;
                    clear     = 0;
                    prod_clear = 1;
                    READY     = 0;
                end
            else                                // stay idle
                begin
                    en_A      = 0;
                    en_B      = 0;
                    sign_sel  = 0;
                    a_sel     = 0;
                    count_en  = 0;
                    clear     = 0;
                    prod_clear = 0;
                    READY     = 0;
                end
        end
    S1: begin
            if ( (b_val) & (stop) )         // product is ready
                begin
                    en_A      = 0;
                    en_B      = 0;
                    sign_sel  = 1;
                    a_sel     = 1;
                    count_en  = 0;
                    clear     = 1;
                    prod_clear = 0;
                    READY     = 1;
                end
            else if ( (!b_val) & (stop) )    // product is ready
                begin
                    en_A      = 0;
                    en_B      = 0;
                    sign_sel  = 1;
                    a_sel     = 0;
                    count_en  = 0;
                    clear     = 1;
                    prod_clear = 0;
                    READY     = 1;
                end
            else if ( (!b_val) & (!stop) )   // product is not ready
                begin
                    en_A      = 0;
                    en_B      = 0;
                    sign_sel  = 0;
                    a_sel     = 0;
                    count_en  = 1;
                    clear     = 0;
                    prod_clear = 0;
                    READY     = 0;
                end
            else if ( (b_val) & (!stop) )    // product is not ready
                begin
                    en_A      = 0;
                    en_B      = 0;
                    sign_sel  = 0;
                    a_sel     = 1;
                    count_en  = 1;
                    clear     = 0;
                    prod_clear = 0;
                    READY     = 0;
                end
        end
    endcase
end
endmodule