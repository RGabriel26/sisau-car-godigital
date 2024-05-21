module intarziere_semnal(
	input semnal, clk, // clk de 1Hz
	output reg semnal_out

);

reg [1:0] counter;

initial begin 

	semnal_out = 1'b0; 

end

always @* begin 

	if(semnal) 
		counter <= 2'b00;
	else
		if (counter != 2'b11) // ar trebui sa opreasca timerul la 3 secunde
			counter <= counter + 2'b01;
			
	case(counter)
		2'b00 : semnal_out = 0;
		2'b01 : semnal_out = 1;
		2'b10 : semnal_out = 1;
		2'b11 : semnal_out = 0;
	endcase
end



endmodule