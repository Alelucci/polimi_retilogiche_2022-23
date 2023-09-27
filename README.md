# polimi_retilogiche_2022-23
Prova finale del corso di Reti Logiche aa 2022/23 voto: 30L/30

Descrizione generale
La specifica della “Prova Finale (Progetto di Reti Logiche)” per l’Anno Accademico
2022/2023 chiede di implementare un modulo HW (descritto in VHDL) che si interfacci con
una memoria e che rispetti le indicazioni riportate nella seguente specifica.
Ad elevato livello di astrazione, il sistema riceve indicazioni circa una locazione di memoria,
il cui contenuto deve essere indirizzato verso un canale di uscita fra i quattro disponibili.
Le indicazioni circa il canale da utilizzare e l’indirizzo di memoria a cui accedere vengono
forniti mediante un ingresso seriale da un bit, mentre le uscite del sistema, ovvero i succitati
canali, forniscono tutti i bit della parola di memoria in parallelo.
Interfacce
Il modulo da implementare ha due ingressi primari da 1 bit (W e START) e 5 uscite
primarie. Le uscite sono le seguenti: quattro da 8 bit (Z0, Z1, Z2, Z3) e una da 1 bit (DONE).
Inoltre, il modulo ha un segnale di clock CLK, unico per tutto il sistema e un segnale di reset
RESET anch’esso unico.

Funzionamento
All’istante iniziale, quello relativo al reset del sistema, le uscite hanno i seguenti valori:
Z0, Z1, Z2 e Z3 sono 0000 0000, DONE è 0.

I dati in ingresso, ottenuti come sequenze sull’ingresso primario seriale W lette sul fronte
di salita del clock, sono organizzati nel seguente modo:
● 2 bit di intestazione (i primi della sequenza) seguiti da
● N bit di indirizzo della memoria.

Gli N bit permettono di costruire un indirizzo di memoria (si legga qui di seguito la specifica
per questi N bit). All’indirizzo di memoria è memorizzato il messaggio da 8 bit che deve
essere indirizzato verso un canale di uscita.
I due bit di intestazione identificano il canale d’uscita (Z0, Z1, Z2 o Z3) sul quale deve
essere indirizzato il messaggio. Il primo bit è il bit più significativo del canale di uscita, il
secondo quello meno significativo, più in dettaglio:
00 identifica Z0, 01 identifica Z1, 10 identifica Z2 e, infine, 11 identifica Z3.

Gli N bit di indirizzo possono variare da 0 fino ad un massimo di 16 bit. Gli indirizzi di
memoria sono tutti di 16 bit.

Se il numero di bit di N è inferiore a 16, l’indirizzo viene esteso con 0 sui bit più
significativi. Ad esempio:
(N = 7) 1010111 –> 0000000001010111
(N = 16) 1110000001010111 –> 1110000001010111
(N = 0) 0000000000000000 –> 0000000000000000

Tutti i bit su W devono essere letti sul fronte di salita del clock.
La sequenza di ingresso è valida quando il segnale START è alto (=1) e termina quando il
segnale START è basso (=0).

Il segnale START rimane alto per almeno di 2 cicli di clock e non più di 18 cicli di clock (2 bit
del canale e 16 bit per il massimo numero di bit per indirizzare la memoria). Si assuma
questa condizione sempre verificata (non è necessario gestire il caso in cui il segnale di
START rimanga attivo meno di 2 cicli di clock o più di 18).

Le uscite Z0, Z1, Z2 e Z3 sono inizialmente 0. I valori rimangano inalterati eccetto il canale
sul quale viene mandato il messaggio letto in memoria; i valori sono visibili solo quando il
valore di DONE è 1.

Quando il segnale DONE è 0 tutti i canali Z0, Z1, Z2 e Z3 devono essere a zero (32 bit a 0).
Contemporaneamente alla scrittura del messaggio sul canale, il segnale DONE passa da 0
passa a 1 e rimane attivo per un solo ciclo di clock (dopo 1 ciclo di clock DONE passa da 1 a
0). In pratica quando DONE=1 il canale associato al messaggio cambierà il suo valore,
mentre gli altri canali mostreranno l’ultimo valore trasmesso derivato dai messaggi ad essi
associati.

Il segnale START è garantito rimanere a 0 fino a che il segnale DONE non è tornato a 0.
Il tempo massimo per produrre il risultato (ovvero il tempo trascorso tra START=0 e
DONE=1) deve essere inferiore a 20 cicli di clock.

Il modulo deve essere progettato considerando che prima del primo START=1 (e prima di
richiedere il corretto funzionamento del modulo) verrà sempre dato il RESET (RESET=1).
Una seconda (o successiva) elaborazione con START=1 non dovrà invece attendere il reset
del modulo. Ogni qual volta viene dato il segnale di RESET (RESET=1), il modulo viene
re-inizializzato.
