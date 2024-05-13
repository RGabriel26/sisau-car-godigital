module generator_PWM_v2(
	input clock, // semnal de clock provenit de la oscilatorul placutei de FPDA -> 50 MHz
	input activ, // semnal care dicteaza starea de activ/inactiv a generatorului {1 sau 0}
	input [11:0] factor_PWM_A,
	input [11:0] factor_PWM_B,
	output [11:0] stare_num_out,
	output reg PWM_A, PWM_B, PWM_C, PWM_D
);
reg [11:0] stare_numarator;
reg [3:0] unitati; 
reg [3:0] zeci;
reg [3:0] sute;
reg PWM_temp_A;
reg PWM_temp_B;
wire PA, PB, PC, PD;

//initializarea variabilelor
initial begin 
	PWM_temp_A = 0;
	PWM_temp_B = 0;
	stare_numarator = 12'h000;
	unitati = 0;
	zeci = 0;
	sute = 0;
end

//numaratorul simulator de semnal dinte de fierastrau
always @(posedge clock) begin
	//simulare semnal dinte de fierastrau
	//numaratorul BCD de 1000 unidirectional 
	unitati = unitati + 1;
	if (unitati == 4'b1001) begin //daca unitati este egal cu 9
		unitati = 0;
		zeci = zeci + 1;
		if (zeci == 4'b1001) begin //daca zeci este egal cu 9
			zeci = 0;
			sute = sute + 1;
			if (sute == 4'b1001) begin //daca sute este egal cu 9
				sute = 0;
			end
		end
	end
	//restrangerea starilor de mai sus intr o singura variabila
	stare_numarator = {sute, zeci, unitati};
end

//generarea semnalului PWM pentru driverul A
always @(factor_PWM_A) begin 
		if (factor_PWM_A >= stare_numarator)
			PWM_temp_A <= 1; 
		else
			PWM_temp_A <= 0;
end

//generarea semnalului PWM pentru driverul B
always @(factor_PWM_B) begin 
		if (factor_PWM_B >= stare_numarator)
			PWM_temp_B <= 1; 
		else
			PWM_temp_B <= 0;
end

//implementarea comenzii de START/STOP
always @(*) begin
    if (activ) begin
        PWM_A = PWM_temp_A;
        PWM_B = PWM_temp_A;
        PWM_C = PWM_temp_B;
        PWM_D = PWM_temp_B;
    end else begin
        PWM_A = 0;
        PWM_B = 0;
        PWM_C = 0;
        PWM_D = 0;
    end
end
//doar pentru teste
assign stare_num_out = stare_numarator;

endmodule 