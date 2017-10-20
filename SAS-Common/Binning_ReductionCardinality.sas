%macro GRedCats(DSin, IVVar, DVVar, Mmax, DSGroups, DSVarMap);
/* 
 * Reducing the categories of a categorical varaible using
 * decision tree splits with the Gini-ratio criterion.
 * 	DSin = input dataset
 * 	IVVar = independent categorical variable considered for
 * 			cardinality reduction
 * 	DVVar = dependent variable used to reduce cardinality of
 * 			IVVar
 * 	MMax = maximun number of required categories
 * 	DSGroups = dataset containing the new groups (splits)
 * 	DSVarMap = dataset with categories mapping rules
 * 
 * 	Limitations:
 * 	- Binary DV only
 *  - Categorical IV only
 *  - Final number of categories is determined using the maximun number allowed
 *  - New variable is categorical and of length 30 characters
 *  - Each category is a string value and does not contain spaces or special characters
 * 	- The sum of all the categories length does not exceed 500 characters
 *  - No missing value
 * 
 */
	/* Get the categories of the IV, and the percentage 
	   of the DV=1 and DV=0 in each one of them */
	/* Get the categories using CalcCats macro */
	%CalcCats(&DSin, &IVVar, Temp_Cats);
	
	/* Convert the categories and their frequencies to
	   macro variables using the output of macro CalcCats */
	data _null_;
		set Temp_Cats;
		call symput("C_" || left(_N_), compress(&IVVar));
		call symput("n_" || left(_N_), left(count));
		call symput("M", left(_N_));
	run;
	
	/* Calculate the count (and percentage) of DV=!
	   and DV=0 in each category using PROC SQL.
	   Store all these values in the dataset Temp_Freqs; */
	proc sql noprint;
		create table Temp_Freqs (Category char(100), DV1 num, DV0 num, Ni num, P1 num);
		
		%do i=1 %to &M;
			select count(&IVVar) into :n1
			from &DSin where &IVVar = "&&C_&i" and &DVVar=1;
			
			select count(&IVVar) into :n0
			from &DSin where &IVVar = "&&C_&i" and &DVVar=0;
			
			%let p=%sysevalf(&n1 / &&n_&i);
			
			insert into Temp_Freqs values("&&C_&i", &n1, &n0, &&n_&i, &p);
		%end;
	quit;
	
	
	
%mend;