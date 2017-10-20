%macro SchCompare(A, B, Result, I_St);
	/* This macro compares the schemas of two datasets A and B.
	   It tests the hypothesis that ALL variables in B
	   are preset in A with the same data type. The result of the
	   comparison is stored in the dataset Result, which contains
	   one row per variable of the dataset B.
	   
	   The I_ST contains the status of the comparison, such that
	   	1 = all variables in B are in A,
	   	0 = come variables in B are not in A.
	   
	   In the result dataset, we call B the "Sample", and A the "Base".	*/
	proc sql noprint;
		create table TA as 
			select name, type from dictionary.columns
			where memname = "%upcase(&A)"
			order by name;
			
		create table TB as
			select name, type from dictionary.columns
			where memname = "%upcase(&B)"
			order by name;
		select count(*) into:N from TB;
	run;
	quit;
	
	data _Null_;
		set TB;
		call symput('V_'||left(_n_),name);
		call symput('T_'||left(_n_),Type);
	run;
	
	proc sql noprint;
		create table &Result (VarName char(32),
							  VarType char(8),
							  ExistInBase num,
							  Comment char(80));
			%do i=1 %to &N;
				select count(*) into: Ni from TA where name="&&V_&i";
				%if &Ni eq 0 %then %do;
					%let Value=0;
					%let Comment=Variable does not exist in Base Dataset.;
					%goto NextVar;
				%end;
				select count(*) into: Ti from TA
					where name="&&V_&i" and type="&&T_&i";
				%if &Ti gt 0 %then %do;
					%let Value=1;
					%let Comment=Variable exist in Base Dataset with same data type.;
				%end;
				%else %do;
					%let Value=0;
					%let Comment=Variable exists in Base Dataset but with different data type.;
				%end;
				%NextVar:;
					insert into &Result values("&&V_&i",	  
											  "&&T_&i",
											  &Value,
											  "&Comment");
			%end;
		select min(ExistInBase) into: I from &Result;
	run;
	quit;
	%let &I_St=&I;
%mend;

%macro CatCompare(Base, Sample, Var, V_Result, I_St);
	/*
		Base: Base Dataset
		Sample: Sample Dataset
		Var: The variable for which the categories in the Base
			 dataset are compared to the categories in the 
			 Sample dataset
		V_Result: A dataset containing the comparison summary
		I_St: A status indicator set as follows:
			  0: all categories of Var in Base exist in Sample
			  1: Not all categories of Var in Base exist in Sample
	*/
	proc sql noprint;
		create table CatB as select distinct &Var from &Base;
		select count(*) into:NB from CatB;
		create table CatS as select distinct &Var from &Sample;
		select count(*) into:NS from CatS;
		create table &V_Result (Category char(32),
								ExistsInSample num,
								Comment char(80));
	run;
	quit;
	
	data _Null_;
		set CatB;
		call symput('C_'||left(_n_),&Var);
	run;
	
	proc sql noprint;
		%do i=1 %to &NB;
			select count(*) into:Nx
			from CatS where &Var="%trim(&&C_&i)";
			%if &Nx=0 %then %do;
				insert into &V_Result
				values("%trim(&&C_&i)",0,'Category does not exist in sample.');
			%end;
			%if &Nx>0 %then %do;
				insert into &V_Result
				values("%trim(&&C_&i)",1,'Category exists in sample.');
			%end;
		%end;
		select min(ExistsInSample) into:Status from &V_Result;
	quit;
	%let &I_St=&Status;

	proc datasets nodetails library=work;
		delete CatB CatC;
	quit;
	
%mend;

%macro ChiSample(DS1, DS2, VarC, p, M_Result);
	data Temp_1;
		set &DS1;
		keep &VarC DSId;
		DSId=1;
	run;
	data Temp_2;
		set &DS2;
		keep &VarC DSId;
		DSId=2;
	run;
	data Temp_Both;
		set Temp_1 Temp_2;
	run;
	
	%ContnAna(Temp_Both, DSId, &VarC, Temp_Res);
	
	data _null_;
		set temp_res;
		if SAS_Name="P_PCHI" then
			call symput("P_actual", Value);
	run;
	%if %sysevalf(&P_Actual>=&P) %then %let &M_Result=Yes;
	%else %let &M_Result=No;
	
	/* clean workspace */
	proc datasets library=work nolist;
		delete Temp_1 Temp_2 Temp_both Temp_Res;
	quit;
%mend;