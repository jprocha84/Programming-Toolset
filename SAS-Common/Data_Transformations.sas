%macro CalcCats(DSin, Var, DSCats);
/* Get the distinct values */

	proc freq data=&DSin noprint;
		tables &Var /missing out=&DSCats;
	run;

%mend;