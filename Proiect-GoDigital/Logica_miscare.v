module Logica_miscare(
	    /* ########### semnalele de input ############# 
	
	 >>>> LOGICA SEMNALELOR DE LA IESIREA SENZORILOR ESTE INVERSATA <<<<
	 
	senzor_1 / senzor_5 -> folosit pentru a detecta linia de semnalizare de curba spre dreapta sau stanga
						   sau pentru a detecta un linia de finish a circuitului (cand ambii senzori sunt in 1 logic)
	
	senzor_3 -> senzorul ce ar trebui mereu sa fie pe linia neagra a circuitului
				cand acesta detecteaza culoarea neagra, a liniei circuitului, are la iesire 1 logic
				asta inseamna ca masina se afla pe directia corecta
				
	senzor_2 / senzor_4 -> pentru detectarea neregularitatilor de directie a masinii
						   daca unul din ei detecteaza linia neagra a circuitului, astfel vor scoate semnal la iesire de 1 logic
						   inseamna ca masina are o directie gresita si trebuie corectata
					
	circuit -> semnal provenit de la alt bloc logic care va determina tipul de circuit pe care urmeaza sa se deplaseze masinuta
	
	########### semnalele de output ############# 		
			   
	directie_driverA -> 
	directie_driverB -> 
	semnal_dreapta -> 
	semnal_stanga ->
	stop -> 
	count_ture -> 
	factor_dc_driverA ->
	factor_dc_driverA ->
	
	
	*/
    input senzor_1, 
    input senzor_2,
    input senzor_3,
    input senzor_4,
    input senzor_5, 
    input [1:0] circuit,
    
    output reg [1:0] directie_driverA,
    output reg [1:0] directie_driverB,
    
    output reg semnal_dreapta,
    output reg semnal_stanga,
    output reg stop, 
    output reg [7:0] count_ture,
    
    output reg [11:0] factor_dc_driverA,
    output reg [11:0] factor_dc_driverB 
);
//variabile locale
//pentru memorarea temporara a curbei in cazul in care senzor_3 iese de pe circuit
reg dreapta;
reg stanga;

initial begin 
	dreapta = 0;
	stanga = 0;
	semnal_dreapta = 0;
	semnal_stanga = 0;
	stop = 0;
	count_ture = 0;
	//initializare cu starea de mers inainte
	directie_driverA = 2'b10;
	directie_driverB = 2'b10;
	//initializarea factorului de comparatie cu numarul obtinut din numarator
	//initializare cu 999 asta inseamna starea maxima de comparat in comparator ceea ce ofera un semnal PWM aproape de 100% ca duty cycle
	factor_dc_driverA = 12'h999; // procentajul de duty cycle a semnalului PWM a driverului A
	factor_dc_driverB = 12'h999; // procentajul de duty cycle a semnalului PWM a driverului B
	
end 

//SEMNALUL DE 1 LOGIC AL INTRARILOR APARE ATUNCI CAND SENZORUL DETECTEAZA NEGRU
//LEDUL DE CONTROL AL ACESTUIA ESTE STINS
//CRED... TREBUIE TESTAT IAR .. 

//FOLOSIREA TRIBUIRILOR NEBLOCANTE (<=) CRED CA POATE GENERA PROBLEME IN RESETAREA REGISTRILOR
	
//logica directiei
always @* begin
	//conditie ca senzorul se afla pe traseul corect
	if(senzor_3 == 1) begin
		//creaza conditie de salvare in reg dreapta/stanga a ultimei activari a senzorului
		//si crearea conditie de resetare a registrilor dreapta si stanga pentru cazul in care senzorul_3 iese de pe circuit
		
		//conditie de rotire spre dreapta
		if(senzor_2 == 1) begin
			directie_driverA = 2'b01;
			dreapta = 1;
		end
		//resetarea directiei pentru driverul A
		else begin 
			directie_driverA = 2'b10;
			dreapta = 0;
		end
		
		//conditie de mers spre stanga
		if(senzor_4 == 1) begin
			directie_driverB = 2'b01;
			stanga = 1;
		end
		//resetarea directiei pentru driverul B
		else begin 
			directie_driverB = 2'b10;
			stanga = 0; 
		end
	end
	else begin
	//logica de cautat traseul
		//cautare spre dreapta in functie de ultima directie cautata
		if(dreapta == 1 | stanga == 1) begin
			//posibil ca sensutile sa trebuiasca puse invers
			if(dreapta == 1) begin 
			directie_driverA = 2'b01;
			directie_driverB = 2'b10;
			end
			if(stanga == 1) begin
				directie_driverA = 2'b10;
				directie_driverB = 2'b01;
			end
			//resetarea registrilor se realizeaza in conditia ca senzorul_1 sa fie in 1 logic
			//trebuie TESTAT
		end
		//logica de rotire pentru cautarea traseului in caul in care senor_3 iese de pe traseu
		//si nu a fost inregistrata o curba pentru ghidare
		else begin
		//masina va merge inapoi
			//directie_driverA = 2'b01;
			//directie_driverB = 2'b01;
		
		//TEST REPOZITIONARE
		//conditie de rotire spre dreapta
			if(senzor_2 == 1) begin
				directie_driverA = 2'b01;
				dreapta = 1;
			end
			//resetarea directiei pentru driverul A
			else begin 
				directie_driverA = 2'b10;
				dreapta = 0;
			end
		
			//conditie de mers spre stanga
			if(senzor_4 == 1) begin
				directie_driverB = 2'b01;
				stanga = 1;
			end
			//resetarea directiei pentru driverul B
			else begin 
				directie_driverB = 2'b10;
				stanga = 0; 
			end
		end
		
	end
	//LOGICA COMPORTAMENTALA PE DIFERITE CIRCUTE
	if (senzor_1 == 1 & senzor_5 == 1) begin 
		count_ture = count_ture + 1;
		//conditie de circuit pentru circuitul 1 (proba linie dreapta)
		if (circuit == 2'b01 & count_ture == 1) begin 
			directie_driverA = 2'b00;
			directie_driverB = 2'b00;
		end
		//conditie de circuit pentru circuitul 2 (proba curbe)
		if (circuit == 2'b10 & count_ture == 10) begin 
			//in acest caz, cand masina face 10 cicluri pe circuit, se va opri
			directie_driverA = 2'b00;
			directie_driverB = 2'b00;
		end
		//conditie de circuit pentru circuitul 3 (proba anduranta)
		//conditia consta in numararea turelor de circuit pana la terminarea bateriilor 
		//instructiune ce se realizeaza deja mai sus 
		
		//conditie de resetare a numarului de cicluri
		if (circuit == 2'b00)
			count_ture = 0;
	end
	
	//OUTPUT SEMNALA DE INFORMARE
	//scoaterea numarului de ture realizate de masina
	//acesta va fi modificat si scos la iesire pe parcursul parcurgerii logicii de mai sus
	//numarul turelor de circuit contorizate se iau din output count_ture
	//care este un sir de 8 biti, capabil pentru numere pana in 255
	
	//scoaterea unor semnale destinate semnalizarii exterioare
	semnal_dreapta = senzor_1;
	semnal_stanga = senzor_5;
	
	//semnalul de stop
	stop = ~senzor_3;
end

endmodule	