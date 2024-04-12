module Logica_miscare(
	//definirea porturilor
	//inputuri pentru senzorii masinii
    input senzor_1, 
    input senzor_2,
    input senzor_3,
    input senzor_4,
    input senzor_5, 
    //semnal ce va indica ce tip de circuit va di parcurs
    input [1:0] circuit,
    
    //outputuri destinate semnalelor de sens pentru driver
    output reg [1:0] directie_driverA, //responsabil pentru sensul motoarelor driverului A (din dreapta)
    output reg [1:0] directie_driverB, //responsabil pentru sensul motoarelor driverului B (din stanga)
    //outputuri destinate semnalizarii curbei de stanga sau de dreapta
    output reg semnal_dreapta,
    output reg semnal_stanga,
    output reg stop, 
    output reg [7:0] count_ture //indica numarul de ture pe care masina l-a realizat si care va fi folosit pentru afisare
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
	directie_driverA = 2'b01;
	directie_driverB = 2'b01;
end 

//SEMNALUL DE 1 LOGIC AL INTRARILOR APARE ATUNCI CAND SENZORUL DETECTEAZA NEGRU
//LEDUL DE CONTROL AL ACESTUIA ESTE STINS
//CRED... TREBUIE TESTAT IAR .. 

//FOLOSIREA TRIBUIRILOR NEBLOCANTE (<=) CRED CA POATE GENERA PROBLEME IN RESETAREA REGISTRILOR
	
always @* begin
	//LOGICA DE POZITIONARE PE TRASEUL CORECT
	if(senzor_3 == 1) begin		
		//conditii de schimbare
		//excluderea cazului in care senzorii sunt simultan activati
		//TREBUIE TESTAT
		if({senzor_2, senzor_4} != 2'b11) begin
			//instructiuni de pozitionare
			directie_driverA <= (senzor_2 == 1) ? 2'b01 : 2'b10;
			directie_driverB <= (senzor_4 == 1) ? 2'b01 : 2'b10;
			//resetarea registrilor unde a fost memorata unltima detectie a curbei
			dreapta <= (senzor_2 == 1) ? 1 : 0;
			stanga <= (senzor_4 == 1) ? 1 : 0;
		end
	end else begin
	//logica de cautat a traseului cand senzor_3 nu se mai afla pe linia neagra a traseului
		//cautare spre dreapta sau spre stanga in functie de ultima directie detectata si salvata in registre
		if(dreapta == 1 | stanga == 1) begin
			//instructiuni de pozitionare folosind informatiile din registre dreapta/stanga
			if(dreapta == 1) begin
				directie_driverA <= 2'b01;
				directie_driverB <= 2'b10;
			end
			if(stanga == 1) begin
				directie_driverA <= 2'b10;
				directie_driverB <= 2'b01;
			end
			//resetarea registrilor se realizeaza in conditiile de pozitionare
		end 
		else begin 
			//instructiuni de pozitionare
			//repozitionare in cazul in care registrele au fost resetate
			//pentru a asigura pozitionare pe traseul corect
			directie_driverA <= (senzor_2 == 1) ? 2'b01 : 2'b10;
			directie_driverB <= (senzor_4 == 1) ? 2'b01 : 2'b10;
			//resetarea registrilor unde a fost memorata unltima detectie a curbei
			dreapta <= (senzor_2 == 1) ? 1 : 0;
			stanga <= (senzor_4 == 1) ? 1 : 0;
		end
	end
	
	//LOGICA COMPORTAMENTALA PE DIFERITE CIRCUTE
	if (senzor_1 == 1 & senzor_5 == 1) begin 
		count_ture <= count_ture + 1;
		//conditie de circuit pentru circuitul 1 (proba linie dreapta)
		if (circuit == 2'b01 & count_ture == 1) begin 
			directie_driverA <= 2'b00;
			directie_driverB <= 2'b00;
		end
		//conditie de circuit pentru circuitul 2 (proba curbe)
		if (circuit == 2'b10 & count_ture == 10) begin 
			//in acest caz, cand masina face 10 cicluri pe circuit, se va opri
			directie_driverA <= 2'b00;
			directie_driverB <= 2'b00;
		end
		//conditie de circuit pentru circuitul 3 (proba anduranta)
		//conditia consta in numararea turelor de circuit pana la terminarea bateriilor 
		//instructiune ce se realizeaza deja mai sus 
		
		//conditie de resetare a numarului de cicluri
		if (circuit == 2'b00)
			count_ture <= 0;
	end
	
	//OUTPUT SEMNALA DE INFORMARE
	//scoaterea numarului de ture realizate de masina
	//acesta va fi modificat si scos la iesire pe parcursul parcurgerii logicii de mai sus
	//numarul turelor de circuit contorizate se iau din output count_ture
	//care este un sir de 8 biti, capabil pentru numere pana in 255
	
	//scoaterea unor semnale destinate semnalizarii exterioare
	semnal_dreapta <= senzor_1;
	semnal_stanga <= senzor_5;
	
	//semnalul de stop
	stop <= ~senzor_3;
end

endmodule	