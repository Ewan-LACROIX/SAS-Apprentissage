/* PROJET SAS */

/* LACROIX Ewan */
/* DAN BAKY Janna*/
/* ROMAIN Canelle*/

/* Il vous faut changer le chemin aux endroits necessaires avec les bases fournies*/

/* Importation de la base du CFA avec toutes ses feuilles */
libname exce xlsx ("chemin/Base_CFA.xlsx");

/* Distinction des différentes tables en fonction de leur année */
data _2017;
	set exce."2017 2018"n;
    annee = 2017;
run;
data _2018;
	set exce."2018 2019"n;
	annee = 2018;
run;
data _2019;
	set exce."2019 2020"n;
	annee = 2019;
run;
data _2020;
	set exce."2020 2021"n;
	annee = 2020;
run;
data _2021;
	set exce."2021 2022"n;
	annee = 2021;
run;
data _2022;
	set exce."2022 2023"n;
	annee = 2022;
run;
data _2023;
	set exce."2023 2024"n;
	annee = 2023;
run;

/* Regroupement de toutes les tables en une unique table pour travailler sans repetitions plus tard*/
data all; /* Uniformisation des donées et classification de celles-ci */
	set _2023 _2018 _2019 _2020 _2021 _2022 _2017;
	
	/* Je cree une variable departement et je lui attribue un 0 au debut lorsque le departement
	est un des 9 premiers de france*/
	DEPARTEMENT = substr(put(CP_ENTREPRISE, 8.),4,2);
	DEPARTEMENT = put(input(DEPARTEMENT, 8.), z2.);
	
	/* On remplace les anciens noms par les nouveaux */
	/* On remarque que les 3 premiers caractères de la variable NOM_FORMATION_APPRENANT contiennent le type de la formation */
	type = substr(NOM_FORMATION_APPRENANT,1,3);
	if type = "DUT" then type = "BUT/DUT"; /* car la formation DUT est devenue BUT à la rentrée 2021 donc on les regroupe */
	if type = "BUT" then type = "BUT/DUT";
	if type = "MAS" then type = "MASTER";
	if type = "LP " then type = "LICENCE PRO";
	if type = "DSC" then type = "DSCG";

	if type = "MASTER" then niveau = "Master - DSCG (Bac +5)";
	if type = "DCG" then niveau = "LP - DCG (Bac +3)";
	if type = "BUT/DUT" then niveau = "BUT - DUT (Bac +2/3)";
	if type = "LICENCE PRO " then niveau = "LP - DCG (Bac +3)";
	if type = "DSCG" then niveau = "Master - DSCG (Bac +5)";
	
	/* On remplace les anciens noms par les nouveaux */
	/* car les noms de certaines composantes change au fil des années */
	if ETENDU_SITE_APPRENANT = "COLLEGIUM LLSH ORLEANS" then ETENDU_SITE_APPRENANT = "UFR LLSH ORLEANS";
	if ETENDU_SITE_APPRENANT = "COLLEGIUM LLSH CHATEAUROUX" then ETENDU_SITE_APPRENANT = "UFR LLSH CHATEAUROUX";
	if ETENDU_SITE_APPRENANT = "COLLEGIUM S&T ORLEANS" then ETENDU_SITE_APPRENANT = "UFR S&T ORLEANS";
	if ETENDU_SITE_APPRENANT = "COLLEGIUM S&T BOURGES" then ETENDU_SITE_APPRENANT = "UFR S&T BOURGES";
	if ETENDU_SITE_APPRENANT = "FACULTE DEG ORLEANS" then ETENDU_SITE_APPRENANT = "UFR DEG ORLEANS";
	if ETENDU_SITE_APPRENANT = "OSUC ORLEANS" then ETENDU_SITE_APPRENANT = "UFR OSUC ORLEANS";
	if ETENDU_SITE_APPRENANT = "UFR SCIENCES & TECHNIQUES ORLEANS" then ETENDU_SITE_APPRENANT = "UFR S&T ORLEANS";
	if ETENDU_SITE_APPRENANT = "UFR SCIENCES & TECHNIQUES BOURGES" then ETENDU_SITE_APPRENANT = "UFR S&T BOURGES";
	
	/* attribution des coordonnées du lieu d'étude */
	/* on a besoin des coordonnées des lieux de formation pour la suite pour calculer les distances, on préfère les inscrire manuellement */
	if ETENDU_SITE_APPRENANT = "UFR LLSH ORLEANS" then do; laa =  47.845088; Loo = 1.930926; end;
	if ETENDU_SITE_APPRENANT = "UFR LLSH CHATEAUROUX" then do; laa =  46.810971; Loo = 1.676000; end;
	if ETENDU_SITE_APPRENANT = "UFR S&T ORLEANS" then do; laa =  47.845088; Loo = 1.930926; end;
	if ETENDU_SITE_APPRENANT = "UFR DEG ORLEANS" then do; laa =  47.845088; Loo = 1.930926; end;
	if ETENDU_SITE_APPRENANT = "UFR OSUC ORLEANS" then do; laa =  47.845088; Loo = 1.930926; end;
	if ETENDU_SITE_APPRENANT = "IUT ORLEANS" then do; laa =  47.845088; Loo = 1.930926; end;
	if ETENDU_SITE_APPRENANT = "IUT ISSOUDUN" then do; laa =  46.948958; Loo = 2.001460; end;
	if ETENDU_SITE_APPRENANT = "IUT CHATEAUROUX" then do; laa =  46.812168; Loo = 1.686220; end;
	if ETENDU_SITE_APPRENANT = "IUT CHARTRES" then do; laa =  48.442014; Loo = 1.495172; end;
	if ETENDU_SITE_APPRENANT = "IUT BOURGES" then do; laa =  47.097906; Loo = 2.417780; end;
	if ETENDU_SITE_APPRENANT = "UFR S&T BOURGES" then do; laa =  47.097906; Loo = 2.417780; end;
	
	/* Uniformisation de la base CFA afin de coller à  notre future base contenant les coordonnées des villes */
	/* Suppression des accents, des cedex et tout autre élément qui ne correspondrait pas à notre base de données */
	VILLE_ENTREPRISE = prxchange('s/(é)/e/i', -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange('s/(è)/e/i', -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange('s/(ê)/e/i', -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange('s/\s*cedex.*//i', -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange("s/-/ /i", -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange("s/\s([A-Za-z])\s([A-Za-z]+)/ \1'\2/i", -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = tranwrd(strip(VILLE_ENTREPRISE), " ","-");
	VILLE_ENTREPRISE = lowcase(VILLE_ENTREPRISE);
	/* Correction manuelle de 2 villes qui ne correspondaient toujours pas après les modifications précédentes */
	VILLE_ENTREPRISE = prxchange("s/-la-source//i", -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange("s/-sur-charonne//i", -1, VILLE_ENTREPRISE); /* ville mal orthographiée par le CFA */

run;

/* Verification de présence de valeur manquante */
data feuille_manquante;
    set all;
    if cmiss(of _all_) > 0 then output;
run;
/* La table feuille_manquante est bien vide */

/* Base Ville */

/* Importation de notre base contenant les coordonnées GPS de toutes les communes de france,
celle-ci provient du site du gouvernement français et regroupe les bases locales, de l'INSEE et de La Poste,
nous pouvons aussi la retrouver sur l'API adresse du gouvernement. La licence est gratuite et open. Nous 
y avons donc rentrré notre base du cfa afin d'être sûr que toutes les villes aient des coordonnées. A la fin 
cela nous donne la base de données france_gps*/
proc import datafile="chemin\France_GPS.csv"
    out=france_gps
    dbms=csv
    replace;
    getnames=yes;
    GUESSINGROWS=MAX;
run;

data france_gps;
	/* On ecrase l'ancien nom de la variable des villes afin qu'il corresponde à celui de la base du CFA */
	set france_gps(rename=(nom_de_la_commune = VILLE_ENTREPRISE));
	keep VILLE_ENTREPRISE latitude longitude; /* On ne garde que les éléments qui nous intéressent pour la suite */
	/* Uniformisation des données pour qu'elles correspondent à nos données principales */
	VILLE_ENTREPRISE = prxchange('s/(é)/e/i', -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange('s/(è)/e/i', -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange('s/\s*cedex.*//i', -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange("s/-/ /i", -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange("s/\s([A-Za-z])\s([A-Za-z]+)/ \1'\2/i", -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = tranwrd(strip(VILLE_ENTREPRISE), " ","-");
	VILLE_ENTREPRISE = lowcase(VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange("s/-la-source//i", -1, VILLE_ENTREPRISE);
	VILLE_ENTREPRISE = prxchange("s/-sur-charonne//i", -1, VILLE_ENTREPRISE);
run;

/* Il ne faut pas de données en plusieurs exemplaires sinon cela rendra defaillante notre future fusion */
proc sort data=france_gps nodupkey;
by VILLE_ENTREPRISE;
run;

data france_gps;
	set france_gps;
	/* mise au format numerique des coordonnées gps */
	latitudee = input(latitude, 10.);
	longitudee = input(longitude, 10.);
	drop latitude longitude;
run;

/* dep et regions */

proc import datafile="Chemin\departements-region.csv"
    out=base_dep_regions
    dbms=csv
    replace;
	getnames='yes';
run;
data base_dep_regions;
set base_dep_regions;
region_name=prxchange('s/Ã´/ô/',-1,region_name);
region_name=prxchange('s/Ã¨/è/',-1,region_name);
region_name=prxchange('s/Ã©/é/',-1,region_name);
dep_name=prxchange('s/Ã´/ô/',-1,dep_name);
dep_name=prxchange('s/Ã¨/è/',-1,dep_name);
dep_name=prxchange('s/Ã©/é/',-1,dep_name);
region_name=prxchange('s/ÃŽ/Î/',-1,region_name);
run;


/* Enrichissement de notre base principale CFA avec les coordonnées des villes*/

/* Attribution des coordonnées de ville pour chaque observation */
proc sql;
    create table "all"n as
    select m.*, v.latitudee, v.longitudee
    from "all"n as m
    left join france_gps as v
    on m.VILLE_ENTREPRISE = v.VILLE_ENTREPRISE;
run;

/* Calcul des distances en km entre le lieu d'étude et le lieu de stage pour chaque observation */
data all;
	set all;
	km = geodist(latitudee, longitudee, laa, Loo, "k");
	drop laa Loo;
run;

/* Création des tables de frequence pour les prochaines analyses */

/* Nombre d'étudiants en stage dans chaque ville */
proc freq data = all noprint;
	table VILLE_ENTREPRISE*annee / out = ville_all outpct;
run;

/* Nombre d'étudiants en stage dans chaque departement */
proc freq data= all noprint ;
	table DEPARTEMENT*annee / out= dep_all outpct;
run;

/* Attribution des latitude et longitude des villes aux frequences precedentes */
proc sql;
    create table ville_all as
    select m.VILLE_ENTREPRISE, m.annee,m.COUNT,m.PCT_COL, v.latitudee, v.longitudee
    from ville_all as m
    left join france_gps as v
    on m.VILLE_ENTREPRISE = v.VILLE_ENTREPRISE;
run;
   
/* Mêmes étapes que precedemment mais en observant les étudiants de Master */
proc freq data = all noprint;
	where type = "MASTER";
	table VILLE_ENTREPRISE*annee / out = ville_all_master outpct;
run;

proc sql;
    create table ville_all_master as
    select m.VILLE_ENTREPRISE, m.annee,m.COUNT,m.PCT_COL, v.latitudee, v.longitudee
    from ville_all_master as m
    left join france_gps as v
    on m.VILLE_ENTREPRISE = v.VILLE_ENTREPRISE;
run;

/* Simple tri pour créer des graphiques plus tard sans incohérences */
proc sort data =ville_all;
by VILLE_ENTREPRISE annee;
run;
proc sort data =dep_all;
by DEPARTEMENT annee;
run;
proc sort data =ville_all_master;
by VILLE_ENTREPRISE annee;
run;

/*
  #####   ######     ##     ######    ####     #####   ######    ####    #####   ##   ##  #######   #####
 ##   ##  # ## #    ####    # ## #     ##     ##   ##  # ## #     ##    ##   ##  ##   ##   ##   #  ##   ##
 #          ##     ##  ##     ##       ##     #          ##       ##    ##   ##  ##   ##   ## #    #
  #####     ##     ##  ##     ##       ##      #####     ##       ##    ##   ##  ##   ##   ####     #####
      ##    ##     ######     ##       ##          ##    ##       ##    ##   ##  ##   ##   ## #         ##
 ##   ##    ##     ##  ##     ##       ##     ##   ##    ##       ##    ##  ###  ##   ##   ##   #  ##   ##
  #####    ####    ##  ##    ####     ####     #####    ####     ####    #####    #####   #######   #####
                                                                            ###
*/


/* Evolution du nombre d'étudiants par type de diplome au fil du temps */
proc freq data=all noprint;
    tables type*annee / out = evo_etu_diplome outpct;
    title 'Nombre de personnes par type de diplome et par année';
run;


/* Histogramme du nombre de contrats par diplome */
ods graphics / width=600 height=700 maxlegendarea=100;/* On attribue une taille aux représentations graphiques qui sera la meilleure visuellement */
proc sgplot data=evo_etu_diplome;
	/* On modifie la couleur des differents types de diplome pr garder les mêmes couleurs plus tard */
	styleattrs datacolors=(gray green GREEN skyblue firebrick) backcolor=lightgrey wallcolor=lightgrey;
	/* On construit un histogramme avec differentes personnalisations */
    vbar annee /group=type response=COUNT dataskin=pressed datalabel seglabel;
    xaxis display=(noticks) label= "Années";
    yaxis grid label="Nbre d'étudiants";
    keylegend /location=inside position=topleft across=1 title = "Diplomes" noborder;
    title "Evolution du nombre de contrats par diplome";
run;

/*Part d'étudiants par diplome au fil des années*/
proc sgplot data=evo_etu_diplome;
	styleattrs datacolors=(gray green GREEN skyblue firebrick) backcolor=lightgrey wallcolor=lightgrey;
    hbar annee /group=type response=PCT_COL dataskin=pressed datalabel seglabel;
    yaxis display=(noticks) label= "Années";
    xaxis grid label="Part d'étudiants";
    keylegend /location=outside position=bottom across=6 title = "Diplomes" noborder;
    title "Part d'étudiants par diplome au fil des années";
run;


/* Evolution du nombre d'étudiants par composante */
proc freq data=all noprint;
    tables ETENDU_SITE_APPRENANT*annee / out=evo_etu_composante outpct; 
run;

ods graphics / width=1200 height=700 maxlegendarea=100;
proc sgplot data=evo_etu_composante;
	styleattrs backcolor=lightgrey wallcolor=lightgrey;
    vbar annee / response=count group=ETENDU_SITE_APPRENANT dataskin=pressed datalabel seglabel;
    xaxis display=(noticks) label= "Années";
    yaxis grid label="Nbre d'étudiants";
    keylegend /location=inside position=topleft across=3 title = "Composantes" noborder valueattrs=(size=10);
    title "Evolution du nombre d'étudiants par composante";
run;


/* Evolution du nombre d'étudiants ayant un stage dans un departement du Centre Val de Loire */ 
proc freq data=all noprint;
    tables DEPARTEMENT*annee / out=evo_etu_dep_CVDL nofreq norow nopercent outpct; 
run;
/* On attribue dans cette table le veritable nom des departements du CVDL */
data evo_etu_dep_CVDL;
	length DEPARTEMENT $20;
	set evo_etu_dep_CVDL;
	if DEPARTEMENT = "45" then DEPARTEMENT = "Loiret";
	if DEPARTEMENT = "41" then DEPARTEMENT = "Loir et Cher";
	if DEPARTEMENT = "37" then DEPARTEMENT = "Indre et Loire";
	if DEPARTEMENT = "36" then DEPARTEMENT = "Indre";
	if DEPARTEMENT = "28" then DEPARTEMENT = "Eure et Loire";
	if DEPARTEMENT = "18" then DEPARTEMENT = "Cher";
run;


proc sgplot data=evo_etu_dep_CVDL(where=(DEPARTEMENT in ("Loiret","Loir et Cher","Indre et Loire","Indre","Eure et Loire","Cher")));
	styleattrs backcolor=lightgrey wallcolor=lightgrey;
    vbar annee / response=PCT_COL group=DEPARTEMENT dataskin=pressed datalabel seglabel;
    xaxis display=(noticks) label= "Années";
    yaxis grid label="Part d'étudiants";
    keylegend /location=inside position=top across=6 title = "Departements" noborder;
    title "Evolution de la part d'etudiants trouvant leur stage dans les departements du Centre Val de Loire chaque annee";
run;


/* La structure suivante (freq chart plot) va être la même pour les prochains blocs nous commenterons celle-ci pour eviter les répetitions*/

/* NIVEAU DE DIPLOME Part des apprentis par niveau de diplome au fil du temps*/
proc freq data=all noprint;
	table niveau*annee / out = niv_dip outpct;
run;


proc gchart data=niv_dip;
    pie niveau / sumvar=count percent=inside slice=inside value=inside noheading ppercent=(h=2) plabel=(h=2);
    title "Proportion moyenne d'apprentis par niveau de diplome";
run;
quit;

ods graphics / width=1100 height=500 maxlegendarea=100;
proc sgplot data=niv_dip;
	styleattrs datacolors=(steel libr viypk) backcolor=lightgrey wallcolor=lightgrey;
    vbar annee / response=PCT_COL group=niveau dataskin=pressed seglabel;
    xaxis display=(noticks) label= "Années";
    yaxis grid label="Part apprentis";
    keylegend /location=outside position=top across=6 title = "Niveau de diplome" noborder;
    title "Part des apprentis par niveau de diplome au fil du temps ";
run;


/* COMPOSANTE IUT UFR */
/* observation de la dualité*/
data comp;
	set all;
	if find(ETENDU_SITE_APPRENANT,"IUT") then comp = "IUT";
	if find(ETENDU_SITE_APPRENANT,"UFR") then comp = "UFR";
run;

proc freq data=comp noprint;
	table comp*annee / out = comp2 outpct;
run;
	
proc gchart data=comp2;
	pattern1 value=psolid color=steel;
	pattern2 value=psolid color=viypk;
    pie comp / sumvar=count percent=inside slice=inside value=inside noheading ppercent=(h=4) plabel=(h=4);
    title "Répartition des apprentis par composante";
run;
quit;

ods graphics / width=1100 height=500 maxlegendarea=100;
proc sgplot data=comp2;
	styleattrs datacolors=(steel viypk) backcolor=lightgrey wallcolor=lightgrey;
    vbar annee / response=PCT_COL group=comp dataskin=pressed seglabel;
    xaxis display=(noticks) label= "Années";
    yaxis grid label="Part apprentis";
    keylegend /location=outside position=top across=6 title = "Niveau de diplome" noborder;
    title "Répartition des apprentis par composante au fil du temps";
run;


/* COMPOSANTE VILLE*/
/* On va regarder par ville d'étude et aussi plus tard on mettra en evidence les 2 régions fortes (IDL CVDL)*/

/* attribution des nouvelles modalités (villes et regions)*/
data composante;
	set all;
	if ETENDU_SITE_APPRENANT in ("UFR S&T ORLEANS","UFR DEG ORLEANS","UFR LLSH ORLEANS","IUT ORLEANS","UFR OSUC ORLEANS") then ETENDU_SITE_APPRENANT = "Orleans";
	if ETENDU_SITE_APPRENANT in ("UFR LLSH CHATEAUROUX","IUT CHATEAUROUX") then ETENDU_SITE_APPRENANT = "Chateauroux";
	if ETENDU_SITE_APPRENANT in ("UFR S&T BOURGES","IUT BOURGES") then ETENDU_SITE_APPRENANT = "Bourges";
	if ETENDU_SITE_APPRENANT in ("IUT ISSOUDUN") then ETENDU_SITE_APPRENANT = "Issoudun";
	if ETENDU_SITE_APPRENANT in ("IUT CHARTRES") then ETENDU_SITE_APPRENANT = "Chartres";
	if DEPARTEMENT not in ("75", "92", "93", "94", "77", "78", "91", "95",'45',"18","28","37","41","36") then DEPARTEMENT = "Autre";
	if DEPARTEMENT in ('45',"18","28","37","41","36") then DEPARTEMENT = "CVDL";
	if DEPARTEMENT in ("75", "92", "93", "94", "77", "78", "91", "95") then DEPARTEMENT = "IDF";
	keep ETENDU_SITE_APPRENANT DEPARTEMENT annee;
run;

proc freq data=composante noprint;
    tables ETENDU_SITE_APPRENANT*annee / out=evo_etu_compo nofreq nopercent norow outpct; 
run;

ods graphics / width=800 height=600 maxlegendarea=100;
proc sgplot data=evo_etu_compo;
	styleattrs backcolor=lightgrey wallcolor=lightgrey;
    series x=annee y=PCT_COL / group=ETENDU_SITE_APPRENANT markers datalabel  ;
    xaxis label='Années' values=(2017 to 2023 by 1) display=(noticks);
    yaxis label="Part d'apprentis en %" grid;
    title "Evolution de la part d'apprentis par ville d'étude.";
    keylegend / title = "Villes" position=bottom valueattrs=(size=10) noborder across=5;
run;

proc gchart data=evo_etu_compo;
    pie ETENDU_SITE_APPRENANT / sumvar=count percent=inside value=None slice=inside noheading ppercent=(h=2) plabel=(h=1.75);
    title "Part d'apprentis par ville d'étude";
run;
quit;

/* On va analyser la repartition entre IDF et CVDL et autre en fonction de la ville d'étude*/
proc freq data=composante ;
	where ETENDU_SITE_APPRENANT = "Orleans";
    tables DEPARTEMENT*annee / out=evo_etu_compo outpct; 
run;
proc sgplot data=evo_etu_compo;
    series x=annee y=PCT_COL / group=DEPARTEMENT markers ;
    xaxis label='Années' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Evolution de la part d'étudiant d'Orleans trouvant leur stage en Centre val de Loire, IDF ou autre chaque année.";
    keylegend / title = "Région" position=bottom valueattrs=(size=10);
run;

proc freq data=composante ;
	where ETENDU_SITE_APPRENANT = "Bourges";
    tables DEPARTEMENT*annee / out=evo_etu_compo outpct; 
run;
proc sgplot data=evo_etu_compo;
    series x=annee y=PCT_COL / group=DEPARTEMENT markers ;
    xaxis label='Années' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Evolution de la part d'étudiant de Bourges trouvant leur stage en Centre val de Loire, IDF ou autre chaque année.";
    keylegend / title = "Région" position=bottom valueattrs=(size=10);
run;

proc freq data=composante ;
	where ETENDU_SITE_APPRENANT = "Chateauroux";
    tables DEPARTEMENT*annee / out=evo_etu_compo outpct; 
run;
proc sgplot data=evo_etu_compo;
    series x=annee y=PCT_COL / group=DEPARTEMENT markers ;
    xaxis label='Années' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Evolution de la part d'étudiant de Chateauroux trouvant leur stage en Centre val de Loire, IDF ou autre chaque année.";
    keylegend / title = "Région" position=bottom valueattrs=(size=10);
run;

proc freq data=composante ;
	where ETENDU_SITE_APPRENANT = "Chartres";
    tables DEPARTEMENT*annee / out=evo_etu_compo outpct; 
run;
proc sgplot data=evo_etu_compo;
    series x=annee y=PCT_COL / group=DEPARTEMENT markers ;
    xaxis label='Années' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Evolution de la part d'étudiant de Chartres trouvant leur stage en Centre val de Loire, IDF ou autre chaque année.";
    keylegend / title = "Région" position=bottom valueattrs=(size=10);
run;

proc freq data=composante ;
	where ETENDU_SITE_APPRENANT = "Issoudun";
    tables DEPARTEMENT*annee / out=evo_etu_compo outpct; 
run;
proc sgplot data=evo_etu_compo;
    series x=annee y=PCT_COL / group=DEPARTEMENT markers ;
    xaxis label='Années' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Evolution de la part d'étudiant d'Issoudun trouvant leur stage en Centre val de Loire, IDF ou autre chaque année.";
    keylegend / title = "Région" position=bottom valueattrs=(size=10);
run;



/* PAR DOMAINE (categories)*/
proc sort data=all;
by ETENDU_FORMATION_APPRENANT;
run;

/* Ici on va attribuer du mieux que l'on peut avec le nom de la formation, le domaine principal auquel elle appartient pour cela 
il faut effectuer un certain nombre de jongle au niveau du jeu de données afin de parvenir à un resultat satisfaisant*/
data domaine;
	length domaine $15.;
	/* On supprime les differents parcours d'une même formation pour simplifier le tri d'après*/
	set all;
	ETENDU_FORMATION_APPRENANT = lowcase(ETENDU_FORMATION_APPRENANT);
	ETENDU_FORMATION_APPRENANT = prxchange('s/(é)/e/i', -1, ETENDU_FORMATION_APPRENANT);
	ETENDU_FORMATION_APPRENANT = prxchange('s/(è)/e/i', -1, ETENDU_FORMATION_APPRENANT);
	ETENDU_FORMATION_APPRENANT = prxchange('s/(ô)/o/i', -1, ETENDU_FORMATION_APPRENANT);
	ETENDU_FORMATION_APPRENANT = prxchange('s/\s*parcours.*//i', -1, ETENDU_FORMATION_APPRENANT);
	
	domaine = "Autre";/*Le domaine "Autre" à la fin concernera un nombre negligeable de formation auxquelles nous n'avons pu attribuer de domaines clairement*/
	
	if find(ETENDU_FORMATION_APPRENANT,"science") then domaine = "Science";
	if find(ETENDU_FORMATION_APPRENANT,"juridi") or find(ETENDU_FORMATION_APPRENANT,"notariat") or find(ETENDU_FORMATION_APPRENANT,"droit") then domaine = "Droit";
	if find(ETENDU_FORMATION_APPRENANT,"informatique") then domaine = "Informatique";
	if find(ETENDU_FORMATION_APPRENANT,"industrie") then domaine = "Industrie";
	if find(ETENDU_FORMATION_APPRENANT,"gestion") or find(ETENDU_FORMATION_APPRENANT,"management") or find(ETENDU_FORMATION_APPRENANT,"grh") then domaine = "Gestion/Manage.";
	if find(ETENDU_FORMATION_APPRENANT,"genie civil") then domaine = "BTP";
	
	
	if find(ETENDU_FORMATION_APPRENANT,"genie thermique") or find(ETENDU_FORMATION_APPRENANT,"genie mecanique") then domaine = "Industrie";
	if find(ETENDU_FORMATION_APPRENANT,"application") then domaine = "Informatique";
	if find(ETENDU_FORMATION_APPRENANT,"physique") or find(ETENDU_FORMATION_APPRENANT,"chimie") then domaine = "Science";
	if find(ETENDU_FORMATION_APPRENANT,"transition") and find(ETENDU_FORMATION_APPRENANT,"energ") then domaine = "Environnement";
	if find(ETENDU_FORMATION_APPRENANT,"commerc") or find(ETENDU_FORMATION_APPRENANT,"marketing") then domaine = "Marketing/Comm.";
	if find(ETENDU_FORMATION_APPRENANT,"logistique") and find(ETENDU_FORMATION_APPRENANT,"transport") then domaine = "Logistique";
	
	if find(ETENDU_FORMATION_APPRENANT,"developpement durable") or find(ETENDU_FORMATION_APPRENANT,"climat") then domaine = "Environnement";
	if find(ETENDU_FORMATION_APPRENANT,"social") then domaine = "Social";
	if type ="DCG" or type = 'DSCG' or find(ETENDU_FORMATION_APPRENANT,"audit") then domaine  = "Comptabilité";
run;



data feuille_manquante;
    set domaine;
    if cmiss(of _all_) > 0 then output;
run;


proc freq data=domaine noprint;
	table domaine*annee / out = domaine_evo outpct;
run;

proc gchart data=domaine_evo;
    pie domaine / sumvar=count percent=inside value=None slice=inside noheading ppercent=(h=2) plabel=(h=1.75);
    title "Part d'apprentis par domaine d'étude";
run;
quit;

ods graphics / width=1100 height=500 maxlegendarea=100;
proc sgplot data=domaine_evo;
	styleattrs backcolor=lightgrey wallcolor=lightgrey;
    vbar annee / response=PCT_COL group=domaine dataskin=pressed seglabel;
    xaxis display=(noticks) label= "Années";
    yaxis grid label="Part apprentis en %";
    keylegend /location=outside position=bottom across=7 title = "Domaines" noborder;
    title "Part d'apprentis par domaine d'étude au fil du temps ";
run;

proc sgplot data=domaine_evo;
	styleattrs backcolor=lightgrey wallcolor=lightgrey;
    series x=annee y=COUNT / group=domaine markers ;
    xaxis label='Années' values=(2017 to 2023 by 1);
    yaxis label="Nbre d'apprentis";
    title "Nombre d'apprentis par domaine d'étude au fil du temps ";
    keylegend /location=outside position=bottom across=7 title = "Domaines" noborder;
run;

/* Evolution du nombre d'étudiants ayant un stage dans un département du Centre Val de Loire */  
proc freq data=all noprint;
    tables DEPARTEMENT*annee / out=evo_etu_dep_CVDL outpct; 
run;

data evo_etu_dep_CVDL;
	length DEPARTEMENT $20;
	set evo_etu_dep_CVDL;
	if DEPARTEMENT = "45" then DEPARTEMENT = "Loiret";
	if DEPARTEMENT = "41" then DEPARTEMENT = "Loir et Cher";
	if DEPARTEMENT = "37" then DEPARTEMENT = "Indre et Loire";
	if DEPARTEMENT = "36" then DEPARTEMENT = "Indre";
	if DEPARTEMENT = "28" then DEPARTEMENT = "Eure et Loire";
	if DEPARTEMENT = "18" then DEPARTEMENT = "Cher";
run;

proc sgplot data=evo_etu_dep_CVDL(where=(DEPARTEMENT in ("Loiret","Loir et Cher","Indre et Loire","Indre","Eure et Loire","Cher")));
	styleattrs backcolor=lightgrey wallcolor=lightgrey;
    vbar annee / response=PCT_COL group=DEPARTEMENT stat=sum datalabel dataskin=pressed;
    keylegend / position=bottom;
    title "Évolution de la part d'étudiant trouvant leur stage dans les départements du Centre-Val de Loire chaque année";
	xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='%';
run; 

/* Evolution du nombre de personnes trouvant leur stage dans la region Centre val de loire */

data regionn;
	set all(keep= DEPARTEMENT annee type);
	if DEPARTEMENT in ('45',"18","28","37","41","36") then REGION = "Centre Val de Loire";
	if DEPARTEMENT not in ('45',"18","28","37","41","36") then REGION = "Autres";
run;
proc freq data=regionn noprint;
	tables REGION*annee / out=evo_etu_regionn outpct ;
	run;
proc sort data=evo_etu_regionn;
	by annee;
run;

ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=evo_etu_regionn;
styleattrs backcolor=lightgrey wallcolor=lightgrey;
	series x=annee y=PCT_COL / group=REGION lineattrs=(thickness=2) markers markerattrs=(symbol=squarefilled size=5) curvelabel='Région';
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Évolution de la répartition des contrats entre la région Centre-Val de Loire et les autres régions";
    keylegend / location=inside  title='' across = 2 valueattrs=(size=10);
run;
proc gchart data=evo_etu_regionn;
    pie REGION / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
					  slice=inside
					  noheading ppercent=(h=2.5) plabel=(h=2.5);
    title "Répartition moyenne des contrats entre la région Centre-Val de Loire et les autres régions";
run;
quit;

/* Ville les plus fréquentes */

data ville_all_master_bis;
	set ville_all_master;	
	/*Regroupement des paris pour plus tard*/
	VILLE_ENTREPRISE = prxchange('s/paris[\w-]*/paris/i', -1, VILLE_ENTREPRISE);
run;
proc freq data = all noprint;
	where DEPARTEMENT in ("75", "92", "93", "94", "77", "78", "91", "95");
	table VILLE_ENTREPRISE*annee / out = ville_all_IDF outpct;
run;
proc freq data = all noprint;
	where DEPARTEMENT in ('45',"18","28","37","41","36");
	table VILLE_ENTREPRISE*annee / out = ville_all_CVDL outpct;
run;
proc sort data =ville_all_IDF;
by VILLE_ENTREPRISE annee;
run;
proc sort data =ville_all_CVDL;
by VILLE_ENTREPRISE annee;
run;


/* Lieux les plus commun d'alternance*/
ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=ville_all;
	where COUNT > 15 and COUNT < 59;
	series x=annee y=COUNT / group=VILLE_ENTREPRISE markers ;
    xaxis label='Années' values=(2017 to 2023 by 1);
    yaxis label='Nombre de personnes';
    title "Villes les plus fréquentées (hors Bourges & Orleans)";
    keylegend / title = "Villes les plus fréquentées" position=bottom across = 3 valueattrs=(size=10);
run;


ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=ville_all_IDF;
	where COUNT > 3;
	series x=annee y=COUNT / group=VILLE_ENTREPRISE markers ;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='Nombre de personnes';
	title "Villes les plus fréquentées en IDF";
    keylegend / title = "Villes les plus fréquentées en IDF" position=bottom across = 3 valueattrs=(size=10);
run;

ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=ville_all_master_bis;
	where COUNT > 5 and COUNT < 50;
	series x=annee y=COUNT / group=VILLE_ENTREPRISE markers ;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='Nombre de personnes';
	title "Villes les plus fréquentées par les master";
    keylegend / title = "Villes les plus fréquentées par les Masters pour leur alternance(hors Orleans)" position=bottom across = 3 valueattrs=(size=10);
run;
ods graphics / reset;


/* Departement fréquentés */

ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=dep_all;
	where COUNT>15 and COUNT < 127;
	series x=annee y=COUNT / group=DEPARTEMENT markers ;
    xaxis label='Années' values=(2017 to 2023 by 1);
    yaxis label='Nombre de personnes';
    title "Departements les plus fréquentés chaque année hors Loiret (45) & Cher (18)";
    keylegend / title = "Departement les plus fréquentés pour stage" position=bottom across = 3 valueattrs=(size=10);
run;



/* 
  #####     ####            ##   ##    ##     ######
 ##   ##   ##  ##           ### ###   ####     ##  ##
 #        ##                #######  ##  ##    ##  ##
  #####   ##                #######  ##  ##    #####
      ##  ##  ###           ## # ##  ######    ##
 ##   ##   ##  ##           ##   ##  ##  ##    ##
  #####     #####           ##   ##  ##  ##   ####
*/


/* Analyse via departement */

/* Création de macros qui si elles sont appelées, créeront et afficheront les cartes */

/* Departements */

%macro dep;

proc mapimport datafile="Chemin\departements-20180101.shp" out=departements_france;
run;/*Chargement de la base contenant les coordonnées gps des departements français */

data departements_france;
	set departements_france(rename=(code_insee = DEPARTEMENT));
run;

	%do Annee = 2017 %to 2023;
		data dep_all2;
		set dep_all;
		where annee = &Annee;
		run;
		proc sql;
		   create table departements_fr as
		   select a.*, b.COUNT
		   from departements_france as a
		   left join dep_all2 as b
		   on a.DEPARTEMENT = b.DEPARTEMENT; /* ou utilisez le nom du département */
		quit;
		data departements_fr;
		   set departements_fr;
		   if missing(COUNT) or COUNT = . then COUNT = 0;
		run;
		pattern1 value=msolid color=lightCyan;  
		pattern2 value=msolid color=lightsteelblue;
		pattern3 value=msolid color=lightskyblue;
		pattern4 value=msolid color=steelblue;  
		pattern5 value=msolid color=VIGB;
		pattern6 value=msolid color=black;

		goptions cback=lightgrey;

		proc gmap data=departements_fr(where=(DEPARTEMENT not in ('971', '972', '973', '974', '976')))
		         map=departements_france(where=(DEPARTEMENT not in ('971', '972', '973', '974', '976')));
		   id DEPARTEMENT;
		   choro COUNT / levels=6 coutline=black midpoints= 5 10 30 50 100 300;
		   title "Concentration du nombre de contrat par departement en &Annee";
		run;
		quit;
	%end;
%mend;
%dep;





/* Analyse via les villes */

/* GÃ©neration des cartes de 2017 a 2023 des villes*/
%macro cartes_villes;
	%do Annee = 2017 %to 2023;
		proc sgmap plotdata=ville_all;
			where annee = &Annee;
			openstreetmap;
			bubble x=longitudee y=latitudee size=COUNT /
			colorresponse = COUNT
			colormodel=(yellow orange red) 
			transparency=0.5
			legendlabel = "Lieux des stages";
			title "Concentration du nombre de stage par ville en &Annee.";
		run;
	%end;
%mend;

%cartes_villes;


/* GÃ©neration des cartes de 2017 a 2023 des villes surreprÃ©sentÃ©es (>15)*/
%macro cartes_villes_freq;
	%do Annee = 2017 %to 2023;
		proc sgmap plotdata=ville_all;
			where annee = &Annee and COUNT > 15;
			openstreetmap;
			bubble x=longitudee y=latitudee size=COUNT /
			colorresponse = COUNT
			colormodel=(yellow orange red) 
			transparency=0.5
			legendlabel = "Lieux des stages"
			datalabel = VILLE_ENTREPRISE
		    datalabelattrs=(color=black size=8 weight=bold);
			title "Concentration du nombre de stage par ville populaire en &Annee.";
		run;
	%end;
%mend;

%cartes_villes_freq;


%macro cartes_villes_master;
	%do Annee = 2017 %to 2023;
		proc sgmap plotdata=ville_all_master;
			where annee = &Annee;
			openstreetmap;
			bubble x=longitudee y=latitudee size=COUNT /
			colorresponse = COUNT
			colormodel=(yellow orange red) 
			transparency=0.3
			legendlabel = "Lieux des stages";
			title "Concentration du nombre de stage par ville en &Annee chez les master.";
		run;
	%end;
%mend;

%cartes_villes_master;

%macro cartes_villes_freq_master;
	%do Annee = 2017 %to 2023;
		proc sgmap plotdata=ville_all_master;
			where annee = &Annee and COUNT > 5;
			openstreetmap;
			bubble x=longitudee y=latitudee size=COUNT /
			colorresponse = COUNT
			colormodel=(yellow orange red) 
			transparency=0.3
			legendlabel = "Lieux des stages"
			datalabel = VILLE_ENTREPRISE
		    datalabelattrs=(color=black size=8 weight=bold);
			title "Concentration du nombre de stage par ville populaire en &Annee chez les masters.";
		run;
	%end;
%mend;

%cartes_villes_freq_master;
/* 
   ####   #######   #####            #####     ####     #####   ######
  ##  ##   ##   #  ##   ##            ## ##     ##     ##   ##  # ## #
 ##        ## #    ##   ##            ##  ##    ##     #          ##
 ##        ####    ##   ##            ##  ##    ##      #####     ##
 ##  ###   ## #    ##   ##            ##  ##    ##          ##    ##
  ##  ##   ##   #  ##   ##            ## ##     ##     ##   ##    ##
   #####  #######   #####            #####     ####     #####    ####
*/

/* Distance moyenne */

/*Distance moyenne parcourue par les étudiants entre leur lieu d'étude et leur alternance*/
proc means data=all;
	var km;
	title "Distance moyenne parcourue par les étudiants entre leur lieu d'étude et leur alternance";
run;

/* En Ile de france par diplome*/
proc freq data=all noprint;
	/* je selectionne seulement les departements d'IDF */
	where DEPARTEMENT in ("75", "92", "93", "94", "77", "78", "91", "95");
    tables type*annee / out = evo_etu_diplome_IDF outpct;
    title 'Nombre de personnes par type de diplome ayant leur stage en IDF';
run;
proc sgplot data=evo_etu_diplome_IDF;
styleattrs backcolor=lightgrey wallcolor=lightgrey;
    series x=annee y=count / group=type curvelabel ;
    xaxis label='Années' values=(2017 to 2023 by 1);
    yaxis label="Nombre d'étudiants";
    title "Évolution du nombre d'etudiants ayant leur stage en IDF par type de formation";
    keylegend / title = "Formations" position=bottom across=6 valueattrs=(size=8);
run;

/* Calcul de la distance moyenne en km entre le lieu de stage situé en IDF et le lieu d'etude des étudiants en Master */
proc means data=all;
    where type = "MASTER" and DEPARTEMENT in ("75", "92", "93", "94", "77", "78", "91", "95");
    var km;
    title "Distance moyenne en km entre le lieu de stage situé en IDF et le lieu d'etude des étudiants en Master";
run;

/* Calcul de la distance moyenne en km entre le lieu de stage et le lieu d'etude des étudiants en Master */
proc means data=all;
    where type = "MASTER";
    var km;
    title "Distance moyenne en km entre le lieu de stage et le lieu d'etude des étudiants en Master";
run;

/* création d'une boucle qui va nous generer le nombre de km moyen entre stage et université 
par les master chaque année */
%macro dis_moy_master;
    /* Création d'une table finale vide pour stocker les moyennes */
    data dis_moy_master;
        length annee 8 mean_km 8; 
        stop; /* Empêche la créa de la ligne inutile au début */
    run;


    %do Annee = 2017 %to 2023;
        proc means data=all mean noprint;
            where type = "MASTER" and annee = &Annee;
            var km;
            output out=transi (keep=annee mean_km) mean=mean_km;
        run;


        data transi;
            set transi;
            annee = &Annee;
        run;


        proc append base=dis_moy_master data=transi force;
        run;
    %end;
%mend;

%macro dis_moy_lp;

    data dis_moy_lp;
        length annee 8 mean_km 8; 
        stop; 
    run;


    %do Annee = 2017 %to 2023;
        proc means data=all mean noprint;
            where type = "LICENCE PRO" and annee = &Annee;
            var km;
            output out=transi (keep=annee mean_km) mean=mean_km;
        run;


        data transi;
            set transi;
            annee = &Annee;
        run;


        proc append base=dis_moy_lp data=transi force;
        run;
    %end;
%mend;
%macro dis_moy_but;

    data dis_moy_but;
        length annee 8 mean_km 8; 
        stop; 
    run;


    %do Annee = 2017 %to 2023;
        proc means data=all mean noprint;
            where type = "BUT/DUT" and annee = &Annee;
            var km;
            output out=transi (keep=annee mean_km) mean=mean_km;
        run;


        data transi;
            set transi;
            annee = &Annee;
        run;


        proc append base=dis_moy_but data=transi force;
        run;
    %end;
%mend;
%macro dis_moy_compta;
    data dis_moy_compta;
    	type = "compta";
        length annee 8 mean_km 8; 
        stop; 
    run;


    %do Annee = 2017 %to 2023;
        proc means data=all mean noprint;
            where type in ("DCG","DSCG") and annee = &Annee;
            var km;
            output out=transi (keep=annee mean_km) mean=mean_km;
        run;


        data transi;
            set transi;
            annee = &Annee;
        run;


        proc append base=dis_moy_compta data=transi force;
        run;
    %end;
%mend;

%dis_moy_master;
%dis_moy_lp;
%dis_moy_but;
%dis_moy_compta;

data dis_moy_master;
	length type $11.;
	set dis_moy_master;
	type = "Master";
run;
data dis_moy_lp;
	length type $11.;
	set dis_moy_lp;
	type = "Licence pro";
run;
data dis_moy_but;
	length type $11.;
	set dis_moy_but;
	type = "BUT";
run;
data dis_moy_compta;
	length type $11.;
	set dis_moy_compta;
	type = "DCG/DSCG";
run;

data km;
	set dis_moy_master dis_moy_lp dis_moy_but dis_moy_compta;
run;

proc sgplot data=km;
styleattrs backcolor=lightgrey wallcolor=lightgrey;
    series x=annee y=mean_km / group=type curvelabel ;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='km';
    title "Évolution du nombre de km moyen entre le lieu de stage et le lieu d'étude.";
    keylegend / title = "Formation" position=bottom valueattrs=(size=10);
run;



proc means data=all(where=(type = "BUT/DUT"));
var km;
title "Distance moyenne en km entre le lieu d'alternance et le lieu d'etude des étudiants en BUT";
run;
proc means data=all(where=(type = "LICENCE PRO"));
var km;
title "Distance moyenne en km entre le lieu d'alternance et le lieu d'etude des étudiants en Licence pro";
run;
proc means data=all(where=(type in ("DSCG","DCG")));
var km;
title "Distance moyenne en km entre le lieu d'alternance et le lieu d'etude des étudiants en Comptabilité";
run;



/*
 ######   ######    #####   ######   ####     #######  ##   ##  #######   #####
  ##  ##   ##  ##  ##   ##   ##  ##   ##       ##   #  ### ###   ##   #  ##   ##
  ##  ##   ##  ##  ##   ##   ##  ##   ##       ##      #######   ##      #
  #####    #####   ##   ##   #####    ##       ####    #######   ####     #####
  ##       ## ##   ##   ##   ##  ##   ##   #   ##      ## # ##   ##           ##
  ##       ##  ##  ##   ##   ##  ##   ##  ##   ##   #  ##   ##   ##   #  ##   ##
 ####     #### ##   #####   ######   #######  #######  ##   ##  #######   #####
*/


/* Villes les plus fréquentées dans le CVDL (>3%)*/
proc freq data = all noprint ;
	where DEPARTEMENT in ('45',"18","28","37","41","36");
	table VILLE_ENTREPRISE*annee / out = CVDL_evo outpct;
run;
proc sql;
    create table CVDL_evo as
    select m.*, v.latitudee, v.longitudee
    from CVDL_evo as m
    left join france_gps as v
    on m.VILLE_ENTREPRISE = v.VILLE_ENTREPRISE;
run;
proc sort data=CVDL_evo;
	by VILLE_ENTREPRISE annee;
run;

ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=CVDL_evo;
	where PCT_COL > 3;
	styleattrs backcolor=lightgrey wallcolor=lightgrey ;
	series x=annee y=PCT_COL / group=VILLE_ENTREPRISE curvelabel curvelabelpos=auto;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='% parmis les étudiants ayant une alternance en CVDL';
    title "Villes d'alternance les plus populaires en CVDL";
run; 

/* Concentration du nombre de stage par ville en CVDL*/
%macro CVDL;
	%do Annee = 2017 %to 2023;
		proc sgmap plotdata=CVDL_evo;
			where annee = &Annee and latitudee < 48.95 and longitudee < 3.13;
			openstreetmap;
			bubble x=longitudee y=latitudee size=PCT_COL /
			colorresponse = COUNT
			colormodel=(yellow orange red) 
			transparency=0.5
			legendlabel = "Lieux des stages";
			title "Concentration du nombre de stage par ville en &Annee.";
		run;
	%end;
%mend;
%CVDL;

/* CVDL >X pourcent pour types de diplome*/
/* MASTER */
proc freq data = all ;
where DEPARTEMENT in ('45',"18","28","37","41","36") and type in ("MASTER");
table VILLE_ENTREPRISE*annee / out = CVDL_evo_master outpct;
run;

proc sort data=CVDL_evo_master;by VILLE_ENTREPRISE annee;run;
ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=CVDL_evo_master;
	where PCT_COL > 5;
	styleattrs backcolor=lightgrey wallcolor=lightgrey ;
	series x=annee y=PCT_COL / group=VILLE_ENTREPRISE curvelabel curvelabelpos=auto;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='% parmis les étudiants en master ayant une alternance en CVDL';
    title "Villes d'alternance les plus populaires en CVDL pour les master";
run;

/* LICENCE PRO */
proc freq data = all noprint;
where DEPARTEMENT in ('45',"18","28","37","41","36") and type in ("LICENCE PRO");
table VILLE_ENTREPRISE*annee / out = CVDL_evo_licencepro outpct;
run;

proc sort data=CVDL_evo_licencepro;by VILLE_ENTREPRISE annee;run;
ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=CVDL_evo_licencepro;
	where PCT_COL > 3;
	styleattrs backcolor=lightgrey wallcolor=lightgrey ;
	series x=annee y=PCT_COL / group=VILLE_ENTREPRISE curvelabel curvelabelpos=auto;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='% parmis les étudiants en licence pro ayant une alternance en CVDL';
    title "Villes d'alternance les plus populaires en CVDL pour les licence pro";
run;

/* BUT/DUT */
proc freq data = all noprint ;
where DEPARTEMENT in ('45',"18","28","37","41","36") and type in ("BUT/DUT");
table VILLE_ENTREPRISE*annee / out = CVDL_evo_butdut outpct;
run;

proc sort data=CVDL_evo_butdut;by VILLE_ENTREPRISE annee;run;
ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=CVDL_evo_butdut;
	where PCT_COL > 5;
	styleattrs backcolor=lightgrey wallcolor=lightgrey ;
	series x=annee y=PCT_COL / group=VILLE_ENTREPRISE curvelabel curvelabelpos=auto;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='% parmis les étudiants en but/dut ayant une alternance en CVDL';
    title "Villes d'alternance les plus populaires en CVDL pour les but/dut";
run;

/* DCG/DSCG */
proc freq data = all noprint;
where DEPARTEMENT in ('45',"18","28","37","41","36") and type in ("DCG","DSCG");
table VILLE_ENTREPRISE*annee / out = CVDL_evo_compta outpct;
run;

proc sort data=CVDL_evo_compta;by VILLE_ENTREPRISE annee;run;
ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=CVDL_evo_compta;
	where PCT_COL > 5;
	styleattrs backcolor=lightgrey wallcolor=lightgrey ;
	series x=annee y=PCT_COL / group=VILLE_ENTREPRISE curvelabel curvelabelpos=auto;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='% parmis les étudiants en compta ayant une alternance en CVDL';
    title "Villes d'alternance les plus populaires en CVDL pour les compta";
run;




/* CVDL */
proc freq data = all noprint;
where DEPARTEMENT in ('45',"18","28","37","41","36");
table VILLE_ENTREPRISE*annee / out = CVDL_evo2 outpct;
run;

proc sql;
    create table CVDL_evo2 as
    select m.*, v.latitudee, v.longitudee
    from CVDL_evo as m
    left join france_gps as v
    on m.VILLE_ENTREPRISE = v.VILLE_ENTREPRISE;
run;
proc sort data=CVDL_evo2;
	by VILLE_ENTREPRISE annee;
run;


%macro CVDL;
	%do Annee = 2017 %to 2023;
		proc sgmap plotdata=CVDL_evo2;
			where annee = &Annee and latitudee < 48.95 and longitudee < 3.13;
			openstreetmap;
			bubble x=longitudee y=latitudee size=PCT_COL /
			colorresponse = COUNT
			colormodel=(yellow orange red) 
			transparency=0.5
			legendlabel = "Lieux des stages";
			title "Concentration du nombre de stage par ville en &Annee.";
		run;
	%end;
%mend;
%CVDL;

/* Hors CVDL */
proc freq data = all noprint;
where DEPARTEMENT not in ('45',"18","28","37","41","36");
table VILLE_ENTREPRISE*annee / out = out_CVDL_evo outpct;
run;
proc sql;
    create table out_CVDL_evo as
    select m.*, v.latitudee, v.longitudee
    from out_CVDL_evo as m
    left join france_gps as v
    on m.VILLE_ENTREPRISE = v.VILLE_ENTREPRISE;
run;

%macro out_CVDL;
	%do Annee = 2017 %to 2023;
		proc sgmap plotdata=out_CVDL_evo;
			where annee = &Annee;
			openstreetmap;
			bubble x=longitudee y=latitudee size=PCT_COL /
			colorresponse = COUNT
			colormodel=(yellow orange red) 
			transparency=0.5
			legendlabel = "Lieux des stages";
			title "Concentration du nombre de stage par ville populaire en &Annee. (Hors CVDL)";
		run;
	%end;
%mend;
%out_CVDL;


data out_CVDL_bis;
set all;
VILLE_ENTREPRISE = prxchange('s/paris[\w-]*/paris/i', -1, VILLE_ENTREPRISE);
where DEPARTEMENT not in ('45',"18","28","37","41","36");
run;
proc freq data =out_CVDL_bis;
	table VILLE_ENTREPRISE*annee / out = out_CVDL_bis outpct;
run;
ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=out_CVDL_bis;
	where PCT_COL > 2.3;
	styleattrs backcolor=lightgrey wallcolor=lightgrey;
	series x=annee y=PCT_COL / group=VILLE_ENTREPRISE curvelabel;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='Part des personnes ayant un stage hors CVDL';
    title "Lieux de stages les plus populaires hors de la région";
    keylegend / title = "Villes" location=inside across = 3 valueattrs=(size=10);
run;


/* On regarde quelle formation va le + en IDF */

data idf_cvdl;
set all;
if DEPARTEMENT in ("75", "92", "93", "94", "77", "78", "91", "95") then DTT= "IDF";
if DEPARTEMENT in ('45',"18","28","37","41","36") then DTT= "CVDL";
if DEPARTEMENT not in ("75", "92", "93", "94", "77", "78", "91", "95",'45',"18","28","37","41","36") then DTT = 'Autre';
run;
proc sort data=idf_cvdl;
by type annee;run;

proc freq data = idf_cvdl noprint;
	table DTT /out = tout_idf_freq outpct;
run;
ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=tout_idf_freq;
	series x=annee y=percent markers;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Évolution de la répartition des contrats entre CVDL, IDF et Autre";
    keylegend / title = "Régions" position=bottom across = 3 valueattrs=(size=10);
run;
proc gchart data=tout_idf_freq;
    pie DTT / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
						slice = inside;
    title "Répartition moyenne des régions des alternants";
run;
quit;
/* Répartition entre CVDL, IDF et Autre pour BUT */

data but_idf;
set idf_cvdl;
where type = "BUT/DUT";
run;
proc freq data = but_idf noprint;
	table DTT /out = but_idf_freq outpct;
run;

proc gchart data=but_idf_freq;
    pie DTT / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
slice = inside;
    title "Répartition moyenne des régions des BUT";
run;
quit;

/* Répartition entre CVDL, IDF et Autre pour LICENCE PRO */

data licencepro_idf;
set idf_cvdl;
where type = "LICENCE PRO";
run;
proc freq data = licencepro_idf noprint;
	table DTT /out = licencepro_idf_freq outpct;
run;

proc gchart data=licencepro_idf_freq;
    pie DTT / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black slice = inside;
    title "Répartition moyenne des régions des LICENCE PRO";
run;
quit;

/* Répartition entre CVDL, IDF et Autre pour COMPTA */

data compta_idf;
set idf_cvdl;
if type in ("DCG","DSCG");
run;
proc freq data = compta_idf noprint;
	table DTT /out = compta_idf_freq outpct;
run;

proc gchart data=compta_idf_freq;
    pie DTT / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black slice = inside;
    title "Répartition moyenne des régions des COMPTA";
run;
quit;

/* Répartition entre CVDL, IDF et Autre pour MASTER */

data master_idf;
set idf_cvdl;
where type="MASTER";
run;
proc freq data = master_idf noprint;
	table DTT /out = master_idf_freq outpct;
run;

proc gchart data=master_idf_freq;
    pie DTT / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
					  slice=inside noheading;
    title "Répartition moyenne des régions des MASTER";
run;
quit;

/* On regarde quelle formation va le + en IDF dans le but de trouver la formation la plus similaire
a ce que pourrait ressembler le master esa en alternance*/

data similaire;
	set all;
	where ETENDU_SITE_APPRENANT in ("UFR S&T ORLEANS","UFR DEG ORLEANS","UFR LLSH ORLEANS","IUT ORLEANS","UFR OSUC ORLEANS");
	if DEPARTEMENT not in ("75", "92", "93", "94", "77", "78", "91", "95") then DEPARTEMENT = "Autre";
	if DEPARTEMENT in ("75", "92", "93", "94", "77", "78", "91", "95") then DEPARTEMENT = "IDF";
run;
proc freq data= similaire noprint;
	table ETENDU_FORMATION_APPRENANT*DEPARTEMENT*annee / out = simi outpct;
run;
data simi;
	set simi;
	where DEPARTEMENT = "IDF";
run;
proc sort data = simi;
by ETENDU_FORMATION_APPRENANT annee;
run; 

ods graphics / width=1100 height=800 maxlegendarea=100;
proc sgplot data=simi;
	where PCT_COL > 29; /*essayer avec 29 et 35 et revoir psk ya plus le drop avec 35*/
	styleattrs backcolor=lightgrey wallcolor=lightgrey;
    series x=annee y=PCT_COL / group=ETENDU_FORMATION_APPRENANT;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Part de personnes ayant leur stage en IDF par formation.";
    keylegend / title = "Formation" position=bottom across = 1 valueattrs=(size=8);
run;
 
/* on regarde quelles formations vont "loin" entre autre (>100km) */
data similairekm;
	set all;
	where ETENDU_SITE_APPRENANT in ("UFR S&T ORLEANS","UFR DEG ORLEANS","UFR LLSH ORLEANS","IUT ORLEANS","UFR OSUC ORLEANS");
	dis = "Proche";
	if km > 100 then dis = "Loin";
run;
proc freq data= similairekm;
	table ETENDU_FORMATION_APPRENANT*dis*annee / out = simikm outpct;
run;
data simikm;
	set simikm;
	where dis = "Loin";
run;
proc sort data = simikm;
by ETENDU_FORMATION_APPRENANT annee;
run; 
ods graphics / width=1100 height=800 maxlegendarea=100;
proc sgplot data=simikm;
	where PCT_COL > 0 and COUNT > 15 ;
    series x=annee y=PCT_COL / group=ETENDU_FORMATION_APPRENANT markers ;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Part de personnes ayant leur stage loin par formation.";
    keylegend / title = "Formation" position=bottom across = 1 valueattrs=(size=8);
run;

/* Frequence de personne trouvant leur alternance a moins de 15km du lieu d'étude*/

data proche;
	set all;
	dis = "loin";
	if km < 15 then dis = "Proche";
	keep dis;
run;
proc freq data=proche;
	table dis;
run;

/* pourcentage en CVDL et AUTRE par type de diplôme */
data regionnn;
	set all(keep= DEPARTEMENT annee type);
	if DEPARTEMENT in ('45',"18","28","37","41","36") then REGION = "Centre Val de Loire";
	if DEPARTEMENT not in ('45',"18","28","37","41","36") then REGION = "Autre";
run;
proc freq data=regionnn order=freq;
	tables REGION*type / out=evo_etu_regionnn nofreq norow nopercent;
	run;


/* pourcentage en CVDL et AUTRE par niveau de diplôme */
data regionnn;
	set all(keep= DEPARTEMENT annee type);
	if DEPARTEMENT in ('45',"18","28","37","41","36") then REGION = "Centre Val de Loire";
	if DEPARTEMENT not in ('45',"18","28","37","41","36") then REGION = "Autre";
run;
data regionnn2;
set regionnn;
if type in ("BUT/DUT") then niveau='bac+2/+3';
if type in ("LICENCE PRO","DCG") then niveau='bac+3';
if type in ("MASTER",'DSCG') then niveau='bac+5';
run;

proc freq data=regionnn2 order=freq; /* order pour inverser les 2 lignes(on avait autre en premier et cvdl en deuxième */
	tables REGION*niveau / out=evo_etu_regionnn2 outpct norow nocol;
	run;
proc sort data=regionnn2;by niveau;run;


ods graphics / reset;
proc sgplot data=evo_etu_regionnn2;
	styleattrs datacolors=(STEEL  VIYPK ) backcolor=lightgray wallcolor=lightgray;
    vbar niveau / response=pct_col group=REGION datalabel outlineattrs=(color=black thickness=1) dataskin=pressed;
    xaxis label="Niveau d'étude";
    yaxis label="Pourcentage" grid;
    keylegend / location=inside position=topright across=2 title='région';
    title "Répartition des régions par niveau d'étude";
run;

/* pour bac+2/+3 */
data regionnn2_bac2;
set regionnn2;
where niveau='bac+2/+3';
run;
proc freq data = regionnn2_bac2;
	table REGION /out = evo_etu_regionnn2_bac2 outpct;
run;
proc gchart data=evo_etu_regionnn2_bac2;
    pie REGION / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
					  slice=inside noheading ppercent=(h=2.5) plabel=(h=2.5);
    title "bac+2/+3";
run;
quit;

/* pour bac+3 */
data regionnn2_bac3;
set regionnn2;
where niveau='bac+3';
run;
proc freq data = regionnn2_bac3;
	table REGION /out = evo_etu_regionnn2_bac3 outpct;
run;
proc gchart data=evo_etu_regionnn2_bac3;
    pie REGION / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
					  slice=inside noheading ppercent=(h=2.5) plabel=(h=2.5);
    title "bac+3";
run;
quit;

/* pour bac+5 */
data regionnn2_bac5;
set regionnn2;
where niveau='bac+5';
run;
proc freq data = regionnn2_bac5;
	table REGION /out = evo_etu_regionnn2_bac5 outpct;
run;
proc gchart data=evo_etu_regionnn2_bac5;
    pie REGION / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
					  slice=inside noheading ppercent=(h=2.5) plabel=(h=2.5);
    title "bac+5";
run;
quit;


/* évo nombre total de contrat*/
proc freq data=all;
table annee / out=count_total (keep=annee count) ;

ods graphics / reset;
proc sgplot data=count_total;
	styleattrs backcolor=lightgray wallcolor=lightgray;
	series x=annee y=count / datalabel;
	xaxis label='Année' values=(2017 to 2023 by 1);
	yaxis label='Nombre de contrats';
	title "Évolution du nombre de contrats de 2017 à 2023";
run;



/* Avec base de données de Régions et Départements */


data tout3_num_dep;
	set all;
	num_dep=floor(CP_ENTREPRISE/1000);
run;
proc print data=tout3_num_dep;
	where num_dep=.;
run;


/* On associe le nom complet de la région dans laquelle l'alternance se fait */
proc sort data=tout3_num_dep;by num_dep;run;
proc sort data=base_dep_regions;by num_dep;run;
data tout4_dep_regions;
merge tout3_num_dep (in=a) base_dep_regions (in=b);
by num_dep;
if a;
run;

proc freq data=tout4_dep_regions;tables region_name*annee / out=freq_tout4 outpct;run;
ods graphics / width=900 height=500 maxlegendarea=100;


/* Répartition totale par région (sans CVDL) */
data tout_sans_cvdl;
set tout4_dep_regions;
where region_name not in ("Centre-Val de Loire");
run;

proc freq data=tout_sans_cvdl noprint ;tables region_name*annee / out=freq_tout_sans_cvdl outpct;run;
proc sort data=tout_sans_cvdl; by region_name;run;
ods graphics / width=900 height=500 maxlegendarea=100;
proc sgplot data=freq_tout_sans_cvdl;
styleattrs backcolor=lightgrey wallcolor=lightgrey;
	series x=annee y=PCT_COL / group=region_name  curvelabel;
    xaxis label='Année' values=(2017 to 2023 by 1);
    yaxis label='%';
    title "Évolution de la part de contrats par région (hors Centre-Val de Loire)";
    keylegend / location=inside  title='' across = 2 valueattrs=(size=10);
run;
proc gchart data=freq_tout_sans_cvdl ;
    pie region_name / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
					  slice=inside noheading ppercent=(h=1.75) plabel=(h=1.75);
    title "Répartition des contrats par région";
run;
quit;


/* Répartition par région (sans CVDL) des bac+2/+3 */
data tout_sans_cvdl_bac2;
set tout4_dep_regions;
where region_name not in ("Centre-Val de Loire") and type in ("BUT/DUT");
run;

proc freq data=tout_sans_cvdl_bac2 noprint ;
	tables region_name*annee / out=freq_tout_sans_cvdl_bac2 outpct;
run;

proc gchart data=freq_tout_sans_cvdl_bac2 ;
    pie region_name / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
					  slice=inside noheading ppercent=(h=2) plabel=(h=2);
    title "Répartition des contrats par région (Bac+2/+3)";
run;
quit;


/* Répartition par région (sans CVDL) des bac+3 */
data tout_sans_cvdl_bac3;
set tout4_dep_regions;
where region_name not in ("Centre-Val de Loire") and type in ("LICENCE PRO","DCG");
run;

proc freq data=tout_sans_cvdl_bac3 noprint ;tables region_name*annee / out=freq_tout_sans_cvdl_bac3 outpct;run;

proc gchart data=freq_tout_sans_cvdl_bac3 ;
    pie region_name / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
					  slice=inside noheading ppercent=(h=2) plabel=(h=2);
    title "Répartition des contrats par région (Bac+3)";
run;
quit;


/* Répartition par région (sans CVDL) des bac+5 */
data tout_sans_cvdl_bac5;
set tout4_dep_regions;
where region_name not in ("Centre-Val de Loire") and type in ("MASTER","DSCG");
run;

proc freq data=tout_sans_cvdl_bac5 noprint ;tables region_name*annee / out=freq_tout_sans_cvdl_bac5 outpct;run;

proc gchart data=freq_tout_sans_cvdl_bac5 ;
    pie region_name / sumvar=Percent
                      value=none
                      percent=inside
                      coutline=black
					  slice=inside noheading ppercent=(h=2) plabel=(h=2);
    title "Répartition des contrats par région (Bac+5)";
run;
quit;
