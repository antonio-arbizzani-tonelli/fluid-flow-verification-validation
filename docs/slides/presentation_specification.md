# Specifiche della presentazione PowerPoint

## 1. Struttura generale

La presentazione definitiva deve avere **18 slide complessive**:

- **14 slide principali**, da utilizzare durante l'esposizione;
- **4 slide di appendice**, da mostrare soltanto in risposta a domande tecniche.

La parte principale è progettata per una durata di **13–15 minuti**. Il tempo medio è di circa un minuto per slide, con maggiore spazio dedicato ai risultati e meno tempo alle slide introduttive.

La presentazione non deve riprodurre l'ordine delle attività di laboratorio. Deve presentare un progetto di ricerca costruito attorno a una sequenza di verifica e validazione:

1. controllo della risoluzione numerica;
2. verifica CFD mediante una soluzione analitica;
3. validazione dei modelli turbolenti mediante dati sperimentali;
4. calibrazione della catena di misura;
5. caratterizzazione della scia mediante campi di velocità e forze;
6. confronto tra risultati indipendenti e discussione dell'incertezza.

Il messaggio generale è che un risultato fluidodinamico diventa attendibile solo quando sono documentati il riferimento, l'errore, la sensibilità numerica o sperimentale e la procedura usata per ottenerlo.

## 2. Impostazione grafica

### Formato

- Rapporto: **16:9 widescreen**.
- Sfondo: bianco o grigio molto chiaro.
- Colore principale: blu scuro, coerente con il report.
- Colore secondario: rosso mattone, usato solo per evidenziare riferimenti, errori o frequenze dominanti.
- Testo: nero o grigio molto scuro.
- Font: Aptos, Arial o un carattere sans serif equivalente.

### Dimensioni indicative

- Titolo della presentazione: 38–44 pt.
- Titolo delle slide: 28–32 pt.
- Corpo del testo: 18–22 pt.
- Didascalie e fonti: almeno 14–16 pt.
- Valori numerici principali: 24–30 pt.

### Regole di composizione

- Una slide deve comunicare un solo risultato principale.
- I grafici devono occupare almeno metà della superficie utile.
- Non utilizzare screenshot del report o tabelle CSV.
- Utilizzare direttamente le figure esportate dagli script MATLAB.
- Evitare pannelli grafici decorativi, icone generiche e blocchi di testo lunghi.
- Le tabelle devono avere al massimo quattro righe di risultati nella parte principale.
- Le informazioni metodologiche devono essere rappresentate mediante schemi semplici o formule essenziali.
- Ogni grafico deve mantenere assi, unità e legenda leggibili durante la proiezione.
- Il nome dello script sorgente può essere riportato nel piè di pagina in corpo ridotto.

## 3. Sequenza narrativa

La presentazione segue quattro passaggi:

1. **Problema**: definire come valutare l'affidabilità di risultati numerici e sperimentali.
2. **Controllo del metodo**: verificare griglia, soluzione laminare e catena di misura.
3. **Risultati fisici**: confrontare i modelli turbolenti e caratterizzare la scia del cilindro.
4. **Sintesi**: stabilire quali risultati sono supportati dai dati e quali limiti rimangono.

La transizione tra CFD ed esperimenti deve essere esplicita. I due casi non costituiscono una validazione diretta tra la simulazione del tubo e l'esperimento sul cilindro. Il collegamento risiede nella metodologia di verifica, validazione e quantificazione dell'incertezza.

## 4. Quadro sintetico delle slide principali

| N. | Titolo | Funzione | Tempo indicativo |
|---:|---|---|---:|
| 1 | Verification and Validation of Canonical Fluid Flows | Titolo e campo del progetto | 20 s |
| 2 | Research question | Definizione del problema | 45 s |
| 3 | Verification and validation framework | Struttura logica del lavoro | 55 s |
| 4 | CFD configurations and grid sensitivity | Attendibilità numerica | 70 s |
| 5 | Laminar pipe verification | Confronto analitico | 75 s |
| 6 | Turbulent flow development | Sviluppo e struttura turbolenta | 65 s |
| 7 | Turbulence-model validation | Confronto RANS–esperimento | 80 s |
| 8 | Experimental configurations | Setup PSV e forze | 55 s |
| 9 | Load-cell calibration | Attendibilità della misura | 70 s |
| 10 | Mean cylinder wake | Struttura media della scia | 65 s |
| 11 | Wake unsteadiness from PSV | Frequenza e vorticità | 75 s |
| 12 | Cylinder forces | Coefficienti e spettro | 75 s |
| 13 | Uncertainty and independent frequency estimates | Interpretazione congiunta | 70 s |
| 14 | Conclusions and reproducibility | Risultati finali e repository | 60 s |

Durata prevista: circa **14 minuti**.

## 5. Contenuto dettagliato delle slide

### Slide 1 — Verification and Validation of Canonical Fluid Flows

**Obiettivo**

Presentare immediatamente il progetto come lavoro di verifica e validazione, non come raccolta di esercitazioni.

**Contenuto visibile**

- Titolo completo.
- Sottotitolo: *Numerical analysis of internal flows and experimental characterisation of a circular-cylinder wake*.
- Nome, corso di laurea e anno accademico.

**Elemento grafico**

Utilizzare una porzione del campo medio della scia `wake_mean_velocity_field.png` come fascia orizzontale nella metà inferiore. Il grafico deve rimanere riconoscibile ma non deve competere con il titolo.

**Messaggio orale**

Il progetto combina CFD ed esperimenti attraverso una metodologia comune. Ogni risultato viene associato a un riferimento, a una misura dell'errore e a una procedura riproducibile.

**Da evitare**

- elenco dei risultati già nella copertina;
- loghi non necessari;
- formule o tabelle.

### Slide 2 — Research question

**Obiettivo**

Definire la domanda di ricerca che tiene insieme tutte le attività.

**Titolo suggerito**

`Research question`

**Contenuto visibile**

Domanda centrale, scritta in una sola frase:

> How can numerical and experimental evidence be organised into a defensible fluid-flow result?

Sotto la domanda, riportare due casi:

- internal flow: laminar and turbulent pipe CFD;
- separated flow: circular-cylinder wake measurements.

**Composizione**

Testo nella metà sinistra. Nella metà destra, due immagini piccole e separate:

- profilo laminare;
- campo medio della scia.

Non aggiungere risultati numerici. La slide deve soltanto stabilire il problema.

**Messaggio orale**

Il tubo fornisce riferimenti analitici e sperimentali controllati. Il cilindro introduce separazione, instazionarietà e incertezza di misura. I casi sono diversi, ma richiedono lo stesso controllo dell'evidenza.

### Slide 3 — Verification and validation framework

**Obiettivo**

Mostrare la sequenza logica del progetto.

**Contenuto visibile**

Schema lineare con cinque passaggi:

1. grid sensitivity;
2. analytical verification;
3. model validation;
4. measurement calibration;
5. wake characterisation and uncertainty.

Sotto ogni passaggio riportare una sola quantità:

- relative profile difference;
- Poiseuille profile and pressure gradient;
- velocity RMSE and friction factor;
- force residual;
- Strouhal number and force coefficients.

**Composizione**

Usare una linea orizzontale unica con cinque stazioni, senza riquadri tridimensionali o icone decorative. Evidenziare in blu la parte numerica e in rosso mattone la parte sperimentale.

**Messaggio orale**

La griglia viene controllata prima del modello. La catena di misura viene calibrata prima di interpretare le forze. La sequenza evita di attribuire significato fisico a risultati non ancora verificati.

### Slide 4 — CFD configurations and grid sensitivity

**Obiettivo**

Dimostrare che il confronto successivo non dipende da una scelta arbitraria della griglia.

**Contenuto visibile**

Parte sinistra:

- laminar case: (Re_b=192.9), (D=0.15\,\mathrm{m});
- turbulent case: (Re_b=75{,}000), (D=0.10\,\mathrm{m});
- refinements: radial, axial, combined.

Parte destra:

- utilizzare `laminar_grid_independence.png` oppure una versione ritagliata che mantenga i tre pannelli;
- riportare in evidenza il massimo cambiamento medium–fine: **0.925% laminar**, **0.366% turbulent**.

**Tabella ridotta**

| Regime | Radial | Axial | Combined |
|---|---:|---:|---:|
| Laminar | 0.521% | 0.225% | 0.925% |
| Turbulent | 0.242% | 0.132% | 0.366% |

La tabella riporta soltanto il confronto medium–fine.

**Messaggio orale**

Le variazioni diminuiscono lungo tutte le direzioni di raffinamento. Il confronto è una misura di sensibilità tra griglie successive e non un Grid Convergence Index formale.

### Slide 5 — Laminar pipe verification

**Obiettivo**

Presentare la verifica più solida del progetto attraverso due riferimenti analitici indipendenti.

**Elemento grafico**

Disporre affiancati:

- `laminar_pipe_verification.png`;
- `laminar_pressure_gradient.png`.

**Valori da evidenziare**

- profile (L_\infty) error: **3.18%**;
- analytical pressure gradient: **−203.84 Pa/m**;
- CFD pressure gradient: **−201.32 Pa/m**;
- pressure-gradient error: **1.24%**.

**Testo visibile**

Una sola conclusione:

> The developed velocity field and the integral pressure loss agree with the analytical solution.

**Messaggio orale**

Il profilo verifica la distribuzione locale della velocità. Il gradiente di pressione verifica il bilancio integrale e lo sforzo a parete. L'accordo simultaneo è più significativo del confronto con un solo valore scalare.

### Slide 6 — Turbulent flow development

**Obiettivo**

Spiegare perché lo sviluppo turbolento e il trattamento di parete sono rilevanti prima del confronto tra modelli.

**Elemento grafico**

Utilizzare `turbulent_flow_development.png` nella parte superiore e un ritaglio di `turbulent_wall_scaling.png` nella parte inferiore.

**Valori da riportare**

- correlation entry length: **2.249 m**;
- full-profile 0.1% criterion: **9.85 m**;
- friction velocity: **0.0365 m/s**.

**Messaggio principale**

Il centroline velocity si stabilizza prima dell'intero profilo. La lunghezza di ingresso dipende quindi dalla quantità e dalla soglia utilizzate per definirla.

**Nota orale**

Il massimo (y^+) mostrato corrisponde alla distanza dal muro fino all'asse e non al primo punto di griglia. La valutazione near-wall rimane limitata dai dati esportati.

### Slide 7 — Turbulence-model validation

**Obiettivo**

Mostrare il risultato principale della validazione turbolenta.

**Elemento grafico**

Utilizzare `turbulent_pipe_validation.png` come figura dominante. A destra o sotto, inserire una tabella con quattro righe:

| Model | (f) | Error | Profile RMSE |
|---|---:|---:|---:|
| Standard (k\)-(\varepsilon) | 0.018984 | 0.082% | 0.01584 |
| RNG (k\)-(\varepsilon) | 0.018403 | 3.143% | 0.01659 |
| Realisable (k\)-(\varepsilon) | 0.017853 | 6.035% | 0.01948 |
| Low-Re (k\)-(\varepsilon) | 0.021688 | 14.148% | 0.02144 |

Evidenziare soltanto la prima riga.

**Messaggio visibile**

> The standard (k\)-(\varepsilon) configuration gives the best combined agreement for the present mesh and wall treatment.

**Messaggio orale**

Il risultato riguarda questa configurazione numerica. Non dimostra una superiorità generale del modello standard. Il confronto utilizza sia la forma del profilo sia l'attrito a parete.

### Slide 8 — Experimental configurations

**Obiettivo**

Separare chiaramente le due acquisizioni sul cilindro e impedire un confronto improprio tra condizioni operative differenti.

**Contenuto visibile**

Tabella centrale:

| Quantity | PSV | Forces |
|---|---:|---:|
| Flow rate | 35 L/s | 75 L/s |
| Water depth | 0.42 m | 0.45 m |
| Bulk velocity | 0.1667 m/s | 0.3333 m/s |
| Sampling rate | 50 Hz | 200 Hz |
| Primary output | velocity field | (C_D, C_L) |

Accanto alla tabella, mostrare un semplice schema del canale con cilindro, piano PSV e direzioni delle forze. Lo schema deve essere vettoriale e modificabile.

**Messaggio orale**

Le misure PSV e di forza descrivono lo stesso tipo di dinamica ma non lo stesso punto operativo. Il confronto finale riguarda il regime di shedding, non la coincidenza delle frequenze dimensionali.

### Slide 9 — Load-cell calibration

**Obiettivo**

Dimostrare che i coefficienti di forza derivano da una catena di misura controllata.

**Elemento grafico**

Utilizzare `load_cell_calibration.png` a sinistra e `load_cell_residuals.png` a destra.

**Valori da evidenziare**

- sensitivity: **−4.078 × 10⁻⁴ V/N**;
- (R^2=) **0.9999988**;
- force RMSE: **0.00572 N**;
- maximum residual: **0.01398 N**.

**Messaggio visibile**

> The response is linear over the investigated range; near-zero loads remain sensitive to settling and offset estimation.

**Nota orale**

La tensione stazionaria viene calcolata sull'ultimo 30% del segnale. Il tempo massimo di stabilizzazione ottenuto dal criterio operativo è 25.99 s.

### Slide 10 — Mean cylinder wake

**Obiettivo**

Mostrare la struttura media della scia e il recupero della velocità.

**Elemento grafico**

Disporre:

- `wake_mean_velocity_field.png` nella parte sinistra, più ampia;
- `wake_velocity_profiles.png` nella parte destra.

**Contenuto visibile**

- (Re_D=9980);
- profili a (x/D=0, 0.5, 1.5, 2.5);
- indicazione grafica della regione di deficit.

**Messaggio orale**

La scia presenta un forte deficit immediatamente a valle del cilindro. I profili diventano progressivamente più regolari, indicando il recupero di quantità di moto. Il campo disponibile non è sufficientemente lungo per discutere un regime di far wake autosimilare.

### Slide 11 — Wake unsteadiness from PSV

**Obiettivo**

Collegare la periodicità temporale alla struttura spaziale della scia.

**Elemento grafico**

Metà sinistra:

- `wake_probe_spectrum.png`, ritagliato in modo da mantenere sia il segnale sia lo spettro.

Metà destra:

- `wake_vorticity_phases.png`.

**Valori da evidenziare**

- probe: ((x/D,y/D)=(0.288,-0.057));
- dominant frequency: **0.567 Hz**;
- Strouhal number: **0.204**.

**Messaggio orale**

Il picco spettrale corrisponde a una sequenza alternata di strutture vorticose. Le quattro fasi derivano da una sequenza filtrata e non da una media condizionata su più cicli; vengono quindi usate per descrivere la topologia e non l'ampiezza della vorticità.

### Slide 12 — Cylinder forces

**Obiettivo**

Presentare le quantità integrali e l'identificazione indipendente della frequenza di shedding.

**Elemento grafico**

Utilizzare:

- `cylinder_forces.png` nella metà superiore;
- `cylinder_lift_spectrum.png` nella metà inferiore.

**Valori da evidenziare**

- mean drag: **0.9223 N**;
- mean lift after buoyancy correction: **−0.0172 N**;
- 
  \(\overline{C_D}=1.4987\);
- 
  \(\overline{C_L}=-0.0280\);
- shedding frequency: **1.006 Hz**;
- force-based (St=) **0.181**.

**Messaggio orale**

Il drag mantiene un valore medio positivo. Il lift oscilla attorno a un valore prossimo allo zero e presenta un picco spettrale netto. La forza trasversale fornisce una misura integrale della dinamica alternata della scia.

### Slide 13 — Uncertainty and independent frequency estimates

**Obiettivo**

Interpretare i risultati senza nascondere le differenze tra le due acquisizioni.

**Composizione**

Parte sinistra:

- `cylinder_force_uncertainty.png`.

Parte destra:

| Result | PSV | Forces |
|---|---:|---:|
| (U_b) | 0.1667 m/s | 0.3333 m/s |
| (f_s) | 0.567 Hz | 1.006 Hz |
| (St) | 0.204 | 0.181 |

Sotto la tabella:

- (u(C_D)=0.0756);
- (u(C_L)=0.0574);
- 2 mm water-level mismatch: Δ(C_L\approx0.0229).

**Messaggio visibile**

> Both measurements identify periodic cylinder shedding, while the different operating conditions prevent a point-by-point comparison.

**Messaggio orale**

La differenza assoluta tra i due Strouhal è 0.023. Il valore medio di lift è inferiore alla sua incertezza standard e dello stesso ordine dell'errore prodotto da un piccolo disallineamento del livello. Il risultato supporta quindi un mean lift compatibile con zero.

### Slide 14 — Conclusions and reproducibility

**Obiettivo**

Chiudere con risultati quantitativi e mostrare che il progetto è riproducibile.

**Contenuto visibile**

Quattro conclusioni:

1. Laminar CFD: profile error **3.18%**, pressure-gradient error **1.24%**.
2. Turbulent validation: standard (k\)-(\varepsilon) gives the lowest combined error.
3. Cylinder wake: coherent shedding with (St=0.181–0.204).
4. Force interpretation: (\overline{C_D}=1.499\pm0.076), mean lift compatible with zero.

Nella parte inferiore, inserire la struttura minima della repository:

```text
data/ -> src/matlab/ -> results/ -> docs/
                 scripts/run_all.m
```

**Chiusura orale**

Il risultato principale è la tracciabilità del processo: dati, algoritmi, figure, tabelle e report appartengono alla stessa pipeline e possono essere rigenerati con un singolo comando.

**Ultima schermata**

Lasciare visibili titolo della repository e collegamento GitHub quando sarà disponibile. Non utilizzare una slide separata con la sola scritta “Thank you”.

## 6. Slide di appendice

Le appendici rimangono nel file dopo la slide conclusiva. Non vengono incluse nel tempo ordinario.

### Slide 15 — Complete grid-sensitivity metrics

Riportare la tabella completa dei dodici confronti presenti in `grid_independence_metrics.csv`. La slide risponde a domande sulla scelta della griglia e sulla definizione dell'errore.

### Slide 16 — Turbulent structure profiles

Mostrare `turbulent_structure_profiles.png` e `turbulent_wall_scaling.png`. Riportare la definizione di (u_\tau), (y^+) e (W^+). La slide serve per discutere wall treatment, eddy viscosity, (k) ed (\varepsilon).

### Slide 17 — Calibration stability

Mostrare `load_cell_stability.png`, il criterio del 2% e i tempi di stabilizzazione. Utilizzare questa slide per spiegare la scelta dell'ultimo 30% delle acquisizioni.

### Slide 18 — Uncertainty assumptions and limitations

Riportare gli input del modello di incertezza:

- force uncertainty: 0.045 N for drag and 0.025 N for each vertical contribution;
- depth and channel width: 1 mm;
- cylinder diameter: 0.05 mm;
- span: 1 mm;
- flow-rate contribution: 0.5% plus meter-head uncertainty.

Concludere con i limiti non compresi nella propagazione: blockage, deformazione della superficie libera, end effects, allineamento e non simultaneità delle acquisizioni.

## 7. Transizioni orali

Le transizioni devono essere brevi e tecniche.

### Tra slide 3 e slide 4

“The first requirement is numerical resolution. Before comparing models, I assessed how the selected observables changed under radial and axial refinement.”

### Tra slide 7 e slide 8

“The pipe-flow study establishes the numerical validation procedure. The experimental part follows the same logic, starting from the measurement chain before interpreting the cylinder response.”

### Tra slide 9 e slide 10

“Once the transducer response is quantified, the cylinder wake can be analysed through local velocity fields and integral forces.”

### Tra slide 12 e slide 13

“The two measurement techniques identify the same class of unsteady mechanism under different operating conditions. Their agreement must therefore be assessed through nondimensional quantities and uncertainty.”

### Chiusura

“The repository retains the complete path from data to reported quantities. This makes the work inspectable, reproducible, and suitable for extension to additional flow configurations.”

## 8. Materiale da non inserire nella parte principale

- elenco completo dei file MATLAB;
- formule complete della propagazione dell'incertezza;
- tutti i sedici punti della calibrazione in forma tabellare;
- dettagli delle configurazioni PHOENICS;
- tabelle complete delle griglie;
- descrizione riga per riga degli script;
- riferimenti bibliografici estesi.

Questi contenuti possono comparire nelle note del relatore o nelle slide di appendice.

## 9. Controllo finale della presentazione

Prima dell'esportazione definitiva occorre verificare:

- 18 slide totali, di cui 14 principali e 4 di appendice;
- durata della sequenza principale non superiore a 15 minuti;
- nessun testo inferiore a 14 pt;
- risultati numerici coerenti con i CSV della repository;
- unità presenti in ogni asse e tabella;
- immagini ad alta risoluzione e senza deformazioni;
- una sola conclusione chiaramente leggibile per slide;
- distinzione esplicita tra verifica, validazione e confronto qualitativo;
- differenza tra le condizioni PSV e force sempre visibile;
- collegamento GitHub inserito soltanto quando la repository sarà pubblicata.
