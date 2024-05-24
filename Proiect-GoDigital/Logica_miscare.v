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
			   
	directie_driverA -> iesire pentru stabilirea sensurilor motoarelor aferente driverului A, semnal de 2 biti
	directie_driverB -> iesire pentru stabilirea sensurilor motoarelor aferente driverului B, semnal de 2 biti
	semnal_dreapta -> semnal pentru semnalizarea spre dreapta
	semnal_stanga -> semnla pentru semnalizarea spre stanga
	stop -> semnal de semnalizare a franii
	count_ture -> semnal pe 8 biti pentru a afisarea numarului de ture parcurse
	factor_dc_driverA -> numar pe 12 biti pentru compararea in comparator pentru stabilirea factorului de umplere pentru driverul A
	factor_dc_driverA -> numar pe 12 biti pentru compararea in comparator pentru stabilirea factorului de umplere pentru driverul B
	
	########### variabile locale #############
	
	dreapta / stanga -> sunt registrii de 1 bit care memoreaza ultima activare a senzorului de dreapta sau de stanga 
						in cazul in care senzor_3 este pe traseu
	
	
	*/
    input senzor_1, 
    input senzor_2,
    input senzor_3,
    input senzor_4,
    input senzor_5, 
    input [1:0] circuit,
    input [3:0] count_ture, 
    
    output reg [1:0] directie_driverA,
    output reg [1:0] directie_driverB,
    
    output reg semnal_dreapta,
    output reg semnal_stanga,
    output reg stop, 
    output reg tact_count
);
//variabile locale
//pentru memorarea temporara a curbei in cazul in care senzor_3 iese de pe circuit
reg dreapta;
reg stanga;
reg run;

initial begin 
	dreapta = 1'b0;
	stanga = 1'b0;
	semnal_dreapta = 1'b0;
	semnal_stanga = 1'b0;
	stop = 1'b0;
	run = 1'b0;
	//initializare cu starea initiala a senalelor de sens ale motoarelor
	directie_driverA = 2'b00; // 10 - mers in fata | 01 - mers in spate
	directie_driverB = 2'b00;
	
end 
	
//logica directiei
always @* begin
	//conditie ca senzorul se afla pe traseul corect
	if(run == 1'b1) begin 
		if(senzor_3 == 1'b1) begin
			if(({senzor_2, senzor_4} != 2'b11) || ({senzor_2, senzor_1} != 2'b11) || ({senzor_4, senzor_5} != 2'b11 )) begin
				directie_driverA = (senzor_2 == 1'b1) ? 2'b00 : 2'b10;
				directie_driverB = (senzor_4 == 1'b1) ? 2'b00 : 2'b10;
				
				dreapta = (senzor_2 == 1'b1) ? 1'b1 : 1'b0;
				stanga = (senzor_4 == 1'b1) ? 1'b1: 1'b0;
			end else begin
				directie_driverA = 2'b10;
				directie_driverB = 2'b10;
			end
		end
		else begin
			if(dreapta == 1'b1 | stanga == 1'b1) begin
				directie_driverA = (dreapta == 1'b1) ? 2'b01 : 2'b10;
				directie_driverB = (stanga == 1'b1) ? 2'b01 : 2'b10;
			end else begin
				if(({senzor_2, senzor_4} != 2'b11) || ({senzor_2, senzor_1} != 2'b11) || ({senzor_4, senzor_5} != 2'b11 )) begin 
					directie_driverA = (senzor_2 == 1'b1) ? 2'b01 : 2'b10;
					directie_driverB = (senzor_4 == 1'b1) ? 2'b01 : 2'b10;
					
					dreapta = (senzor_2 == 1'b1) ? 1'b1 : 1'b0;
					stanga = (senzor_4 == 1'b1) ? 1'b1: 1'b0;
				end else begin 
					directie_driverA = 2'b10;
					directie_driverB = 2'b10;
				end
			end
		end
	end
	
	//LOGICA COMPORTAMENTALA PE DIFERITE CIRCUTE
	
	// Conditii de oprire a masinutei in fucntie de numarul de ture executate
    // Conditie pentru circuitul 1
    if ((circuit == 2'b01) && (count_ture == 4'b0001)) begin 
        directie_driverA = 2'b00;
        directie_driverB = 2'b00;
        run = 1'b0;
    end else
		// Conditie pentru circuitul 2 (proba curbe)
		if ((circuit == 2'b10) && (count_ture == 4'b1010)) begin 
			directie_driverA = 2'b00;
			directie_driverB = 2'b00;
			run = 1'b0;
		end else
			// ANDURANTA NU NECESITA CONDITIE DE STOP
			// Conditie de resetare  a semnalului run
			if (circuit == 2'b00) begin
				run = 1'b1;
			end
    
    // CREARE TACT DE INCREMENTARE PENTRU COUNTERUL DE TURE
	if ({senzor_1, senzor_2, senzor_4, senzor_5} == 4'b1111)
		tact_count = 1'b1;
	else
		tact_count = 1'b0;
	
	//OUTPUT SEMNALA DE INFORMARE
	//scoaterea numarului de ture realizate de masina
	//acesta va fi modificat si scos la iesire pe parcursul parcurgerii logicii de mai sus
	//numarul turelor de circuit contorizate se iau din output count_ture
	//care este un sir de 8 biti, capabil pentru numere pana in 255
	
	//scoaterea unor semnale destinate semnalizarii exterioare
	semnal_dreapta = senzor_1;
	semnal_stanga = senzor_5;
	
	//semnalul de stop
	//cand masina nu mai este centrata pe linia neagra => adica cand senzor_3 nu mai este pe traseu
	// AR TREBUI SA SE TRIMITA SEMNAL DE STOP MEREU CAND MASINA SE REPOZITIONEAZA ??? 
	stop = ~senzor_3;
end

endmodule	