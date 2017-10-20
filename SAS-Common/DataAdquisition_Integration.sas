%macro TBRollup(TDS, IDVar, TimeVar, TypeVar, NChars, Value, RDS);
/*
	This macro performs a rollup of transactions to produce
	a total balance rollup file on the level of the IDVar
	in the time variable TimeVar by accumulating the Value
	variable over the different categories of the TypeVar.
	The new names will include the values of the time
	variable TimeVar prefixed by the first Nchars of the
	categories of TypeVar.
	The input file is the transaction dataset TDS, and the
	output file is rollup file RDS
	
	Parameters
		TD: Input Transaction dataset
		IDVar: ID variable
		TimeVar: Time variable
		TypeVar: Quantity being rolled up
		Nchars: Number of characters to be used in rollup
		Value: Values to be accumulated
		RDS: The ouput rolled up dataset
*/

	/* First, we sort the transaction file using the ID,
	   time, and type variables */
	proc sort data=&TDS;
		by &IDVar &TimeVar &TypeVar;
	run;

	data Temp1;
		retain _TOT 0;
		set &TDS;
		by &IDVar &TimeVar &TypeVar;
		if first.&TypeVar then _TOT=0;
		_TOT = _TOT + &VAlue;
		if last.&TypeVar then output;
		drop &Value;
	run;
	
	proc sort data=Temp1;
		by &IDVar &TypeVar;
	run;
	
	proc freq data=Temp1 noprint;
		tables &TypeVar /out=Types;
	run;
	
	data _null_;
		set Types nobs=Ncount;
		if &TypeVar ne '' then
			call symput('Cat_'||left(_n_),&TypeVar);
		if _N_=Ncount then 
			call symput('N',NCount);
	run;
	
	%do i=1 %to &N;
		proc transpose data=Temp1 
					   out=_R_&i
					   prefix=%substr(&&Cat_&i,1,&NChars)_;
			by &IDVar &TypeVar;
			ID &TimeVar;
			var _TOT;
			where &TypeVar="&&Cat_&i";
		run;
	%end;
	
	data &RDS;
		merge %do i=1 %to &N; _R_&i %end ; ;
	 	by &IDVar;
	 	drop &TypeVar _Name_;
	run;
	
	proc datasets library=work nodetails;
		delete Temp1 Types %do i=1 %to &N; _R_&i %end; ;
	run;
	quit;
%mend;

%macro ABRollup(TDS, IDVar, TimeVar, 
				TypeVar, Nchars, Value, RDS);
	/* 	This macro performs a rollup of transactions to produce the
		Average Balance (AB) rollup file on the level of the IDVar
		in the time variable TimeVar by accumulating the Value
		variable over the different categories of the TypeVar.
		
		The new names will include the values of the time
		variable TimeVar prefixed by the first NChars of
		the categories of TypeVar.
		
		The input file is the transaction dataset TDS, and the 
		output file is the rollup file RDS.
	*/
	proc sort data=&TDS;
		by &IDVar &TimeVar &TypeVar;
	run;
	
	* 5.5 Step 2;
	data _Temp1;
		retain _TOT 0;
		retain _NT 0;
		set &TDS;
		by &IDVar &TimeVar &TypeVar;
		if first.&TypeVar then _TOT=0;
		_TOT = _TOT + &Value;
		if &Value ne . then _NT=_NT+1;
		if last.&TypeVar then
		do;
			_AVG=_TOT/_NT;
			output;
			_NT=0;
		end;
		drop &Value;
	run;
	
	proc sort data=_Temp1;
		by &IDVar &TypeVar;
	run;
	
	proc freq data=_Temp1 noprint;
		tables &TypeVar /out=_Types;
	run;
	
	data _null_;
		set _Types nobs=Ncount;
		if &TypeVar ne '' then call symput('Cat_'||left(_N_),&TypeVar);
		if _N_=NCount then call symput('N',NCount);
	run;
	
	%do i=1 %to &N;
		proc transpose data=_Temp1 out=_R_&i
					   prefix=%substr(&&Cat_&i,1,&Nchars)_;
			by &IDVar &TypeVar;
			ID &TimeVar;
			var _AVG;
			where &TypeVar="&&Cat_&i";
		run;
	%end;
	
	data &RDS;
		merge %do i=1 %to &N;
			  	_R_&i
			  %end; ;
		by &IDVar;
		drop &TypeVar _Name_;
	run;
	
	proc datasets library=work nodetails;
		delete _Temp1 _Types %do i=1 %to &N; _R_&i %end; ;
	run;
	quit;
	
%mend;

%macro VarMode(TransDS, XVar, IDVar, OutDS);
	proc sql noprint;
		create table &OutDS as
			select &IDVar, Min(&XVar) as mode
			from (
				select &IDVar, &Xvar
				from &TransDS p1
				group by &IDVar, &Xvar
				having count(*)=
					(select max(cnt)
					 from (select count(*) as cnt
					 	   from &TransDS p2
					 	   where p2.&IDVar=p1.&IDVar
					 	   group by p2.&Xvar
					 	   ) as p3
					 )
				) as p
			group by p.&IDVar;
	quit;
%mend;

%macro MergeDS(List, IDVar, ALL);
	/* 5.7.1 Merging */
	data &ALL;
		merge &List;
		by &IDVar;
	run;
%mend;

%macro ConcatDS(List, ALL);
	data &ALL;
		set &List;
	run;
%mend;