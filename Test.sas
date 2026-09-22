/*	proc import datafile="C:\Users\fuaad\STA 402\STA402_final\2015-16_pbp.csv" out = pbp_data dbms=csv replace;*/
/*		getnames = yes;*/
/*		guessingrows=max;*/
/*	run;*/

data WORK.PBP_DATA    ;
	/* add the file path to the csv file from project folder */
infile 'STA402Final\Final-Project-Miami-University-STA-4022015-16_pbp.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
length v1-v17 $1 HOMEDESCRIPTION $77 PLAYER1_NAME $24 PLAYER1_TEAM_ABBREVIATION $3  PLAYER1_TEAM_CITY $13 PLAYER2_NAME $24 
	PLAYER2_TEAM_ABBREVIATION $3 PLAYER2_TEAM_CITY $13 PLAYER3_NAME $24 PLAYER3_TEAM_ABBREVIATION $3 PLAYER3_TEAM_ABBREVIATION $3 PLAYER3_TEAM_CITY $13
	SCORE $9 SCOREMARGIN $3 VISITORDESCRIPTION $79 NEUTRALDESCRIPTION $1;
input v1 EVENTMSGACTIONTYPE EVENTMSGTYPE v2 GAME_ID HOMEDESCRIPTION NEUTRALDESCRIPTION v3 v4 v5 v6 v7 v8 PLAYER1_NAME PLAYER1_TEAM_ABBREVIATION PLAYER1_TEAM_CITY v9 v10 v11 PLAYER2_NAME PLAYER2_TEAM_ABBREVIATION PLAYER2_TEAM_CITY v12 v13 v14 PLAYER3_NAME PLAYER3_TEAM_ABBREVIATION PLAYER3_TEAM_CITY v15 v16 SCORE SCOREMARGIN VISITORDESCRIPTION v17;
run;

data WORK.GAME_DATA;
	/* add the file path to the csv file from project folder */
infile 'STA402Final\Final-Project-Miami-University-STA-402gamedates_2016-17.csv' dsd firstobs=2;
informat Date yymmdd.;
input Game_ID Date;
run;

/*	data merged_data;*/
/*		merge player_shot game_data;*/
/*		by Game_ID;*/
/*	run;*/
