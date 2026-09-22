%let folder=C:\Users\fuaad\STA 402\STA402_final;
/* 
Name: Fuaad Maricar 
Date: November 4th, 2024 
Final Project for STA 402

Purpose:
This SAS program defines a macro, `%FG_analysis`, which analyzes basketball play-by-play data for the seasons 2015?2019. 
The macro generates a graphical summary of the Field Goal Percentage (FG%) for a specific player in a specified season. 
It also provides breakdowns of FG% by month and by opposing team. All output, including charts and tables, is saved to an RTF file.

Usage:
Make sure to change the file pathing to match with your machine up at the top before running the following macro.
To run the macro, specify the season (e.g., `2018-19`) and the player's name (e.g., `'LeBron James'`) as arguments:
Example: `%FG_Analysis(season=2018-19, player='LeBron James');`
*/

/* File paths for datasets by season */
%let pbp_15 = &folder\2015-16_pbp.csv;
%let pbp_17 = &folder\2016-17_pbp.csv;
%let pbp_18 = &folder\2017-18_pbp.csv;
%let pbp_19 = &folder\2018-19_pbp.csv;
%let game_15 = &folder\gamedates_2015-16.csv;
%let game_17 = &folder\gamedates_2016-17.csv;
%let game_18 = &folder\gamedates_2017-18.csv;
%let game_19 = &folder\gamedates_2018-19.csv;
%let player_data = &folder\playerlist.csv;
%let play_by_play = &folder\README-basketball-play-by-play.txt;

%macro FG_analysis(season=, player=);
	
	/* Setting the proper file path based on the season */
	%if &season = 2018-19 %then %do; %let datefile = "&game_19"; %let datafile = "&pbp_19"; %end;
	%else %if &season = 2017-18 %then %do; %let datefile="&game_18"; %let datafile = "&pbp_18"; %end;
	%else %if &season = 2016-17 %then %do; %let datefile="game_17"; %let datafile = "&pbp_17"; %end;
	%else %if &season = 2015-16 %then %do; %let datefile="game_15"; %let datafile = "&pbp_15"; %end;
	%else %do;
		%put ERROR: We do not support that season.;
		%return;
	%end;

	/* Load play-by-play data for the selected season */
	data WORK.PBP_DATA    ;
		infile &datafile delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
		length v1-v17 $1 HOMEDESCRIPTION $77 PLAYER1_NAME $24 PLAYER1_TEAM_ABBREVIATION $3  PLAYER1_TEAM_CITY $13 PLAYER2_NAME $24 
			PLAYER2_TEAM_ABBREVIATION $3 PLAYER2_TEAM_CITY $13 PLAYER3_NAME $24 PLAYER3_TEAM_ABBREVIATION $3 PLAYER3_TEAM_ABBREVIATION $3 PLAYER3_TEAM_CITY $13
			SCORE $9 SCOREMARGIN $3 VISITORDESCRIPTION $79 NEUTRALDESCRIPTION $1;
		input v1 EVENTMSGACTIONTYPE EVENTMSGTYPE v2 GAME_ID HOMEDESCRIPTION NEUTRALDESCRIPTION v3 v4 v5 v6 v7 v8 PLAYER1_NAME PLAYER1_TEAM_ABBREVIATION PLAYER1_TEAM_CITY v9 v10 v11 PLAYER2_NAME PLAYER2_TEAM_ABBREVIATION PLAYER2_TEAM_CITY v12 v13 v14 PLAYER3_NAME PLAYER3_TEAM_ABBREVIATION PLAYER3_TEAM_CITY v15 v16 SCORE SCOREMARGIN VISITORDESCRIPTION v17;
		run;
	
	/* Load game dates for the selected season */	
	data WORK.GAME_DATA;
		infile &datefile dsd firstobs=2;
		informat Date yymmdd.;
		input Game_ID Date;
	run;

	/* Filter data for the specified player and calculate FG attempts and makes */
	data player_shot;
		set pbp_data;
		/* Define FG attempt and FG's made */
		if EVENTMSGTYPE = 1 then FGA = 1; else FGA = 0;
		if EVENTMSGTYPE = 1 and EVENTMSGACTIONTYPE in (1, 2, 3) then FGM = 1; else FGM = 0;
	run;

	/* Calculate FG% by Month */
	proc sql;
		create table fg_month as
			select month(Date) as month,
				sum(FGM) as FGM,
				sum(FGA) as FGA,
				calculated FGM / calculated FGA as FG_percent format=percent8.2
			from player_shot join game_data on player_shot.Game_ID = game_data.Game_ID
			group by month;
	quit;


	/* Calculate FG% by Opposing team. */
	proc sql;
		create table fg_team as 
		select PLAYER2_TEAM_ABBREVIATION as Opposing_Team,
			sum(FGM) as FGM,
			sum(FGA) as FGA,
			calculated FGM / calculated FGA as FG_percent format=percent8.2
		from player_shot
		group by PLAYER2_TEAM_ABBREVIATION;
	quit;

ods rtf bodytitle file = "&folder\Final_project.rtf";

/* FG% by Month - Bar Chart */
proc sgplot data=fg_month;
    vbar month / response=FG_percent datalabel
        fillattrs=(color=blue) stat=mean;
    yaxis label="Field Goal Percentage (FG%)" grid;
    xaxis label="Month" discreteorder=data values=(10 11 12 1 2 3 4);
    title "Field Goal Percentage by Month for &player";
run;

/* FG% by Opposing Team - Bar Chart */
proc sgplot data=fg_team;
    vbar Opposing_Team / response=FG_percent datalabel
        fillattrs=(color=red) stat=mean categoryorder=RESPDESC;
    yaxis label="Field Goal Percentage (FG%)" grid;
    xaxis label="Opposing Team" discreteorder=data;
    title "Field Goal Percentage by Opposing Team for &player";
run;

/* Ordering the months based on the season. */
proc format;
    value month_order
        10 = "October"
        11 = "November"
        12 = "December"
        1  = "January"
        2  = "February"
        3  = "March"
        4  = "April";
run;

/* Sorting months by the season */
data fg_month;
	set fg_month;
	if month < 10 then month_order = month + 20;
	else month_order = month;
run;

/* Assign the custom format and order by month */
proc sort data=fg_month;
    by month_order;
run;

/* Clean Summary Statistics Table for FG% by Month */
proc print data=fg_month label;
	id month;
    var FG_percent;
	 format month month_order.;
    label FG_percent = "Field Goal Percentage (FG%)";
    title "Summary Statistics for FG% by Month for &player";
run;
ods rtf close;
%mend FG_analysis;
