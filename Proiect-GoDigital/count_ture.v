module count_ture(
	input tact,
	input reset,
	
	output reg [3:0] cifra_unitati, cifra_zeci
);


always @(posedge tact or posedge reset) begin

	if(reset) begin 
		cifra_zeci = 4'b0000;
		cifra_unitati = 4'b0000;
	end else begin
		cifra_unitati = cifra_unitati + 1; 
		if (cifra_unitati == 10) begin 
			cifra_unitati = 0;
			if (cifra_zeci == 10) begin  
				cifra_zeci = 0;
			end else
				cifra_zeci = cifra_zeci + 1;
		end
	end
end

endmodule 