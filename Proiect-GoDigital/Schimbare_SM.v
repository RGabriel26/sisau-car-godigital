//modul destinat schimbarii sensului de rotatie a motoarelor prin driverele A si B
//si de modificare a registrilor care stocheaza ultima activare a senzorilor senzor_2 sau senzor_4
module Schimbare_SM( 
    input senzor_2, senzor_4, 
    
    output reg [1:0] directie_driverA,
    output reg [1:0] directie_driverB,
    output reg dreapta,
    output reg stanga
	);
	always @* begin
		directie_driverA = (senzor_2 == 1) ? 2'b01 : 2'b10;
		directie_driverB = (senzor_4 == 1) ? 2'b01 : 2'b10;
		
		dreapta = (senzor_2 == 1) ? 1 : 0;
		stanga = (senzor_4 == 1) ? 1 : 0;
    end

endmodule
