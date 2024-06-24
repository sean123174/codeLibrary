libname mydata remote '/home/ls36374/sas/data/' server=mynode;

 
proc contents data=sasdata.mods;
run;

data sasdata.mods;
set mydata.ham_mod_population;
run;

proc freq data=sasdata.mods;
tables mod_program*Target_delq_30DPD ;
run;

options symbolgen;
%macro plot(var=,target=,dset=);

title "Variable: &var Target: &target";

proc univariate data=&dset;
var &var;
output out=temp n=n_&var min=min_&var q1=q1_&var median=m_&var q3=q3_&var max=max_&var;
run;

proc print data=temp;
run;

data _null_;
set temp;
call symput("n_&var",n_&var);
call symput("min_&var",min_&var);
call symput("q1_&var",q1_&var);
call symput("m_&var",m_&var);
call symput("q3_&var",q3_&var);
call symput("max_&var",max_&var);
run;
%put &&n_&var &&min_&var &&q1_&var &&m_&var &&q3_&var &&max_&var;

data &var;
set &dset;

length cat_&var $2.;
if missing(&var) then cat_&var='MS';
else if &var<=&&q1_&var then cat_&var='Q1';
else if &var<=&&m_&var then cat_&var='Q2';
else if &var<=&&q3_&var then cat_&var='Q3';
else if &var<=&&max_&var then cat_&var='Q4';

variable_name="&var";
keep account_nbr variable_name cat_&var &var &target;
run;

proc freq data=&var;
tables cat_&var*&target / missing;
run;

proc sql;
create table sumtemp as
select
variable_name as variable_name,
cat_&var as cat,
min(&var) as min_value,
max(&var) as max_value,
count(*) as acounts_num,
sum(&target) as target_num

from &var

group by 1,2
;
quit;

data sumtemp;
set sumtemp;
format target_rate percent10.2;
target_rate=target_num/acounts_num;
run;

proc print data=sumtemp;
run;

%mend;

* HAM Variables;
data ham;
set sasdata.mods;
if mod_program='HAM';
run;

%plot(var=paymentsmade,target=Target_delq_30DPD,dset=ham);
%plot(var=HTI_MOD,target=Target_delq_30DPD,dset=ham);
%plot(var=APPRAISAL_VALUE,target=Target_delq_30DPD,dset=ham);


%plot(var=DTI_MOD,target=Target_delq_30DPD,dset=ham);
%plot(var=ESC_PYMT,target=Target_delq_30DPD,dset=ham);
%plot(var=Forbearance_pct,target=Target_delq_30DPD,dset=ham);
%plot(var=MONTHLY_INCOME,target=Target_delq_30DPD,dset=ham);
%plot(var=NOTE_RATE,target=Target_delq_30DPD,dset=ham);
%plot(var=ORIGINAL_LOAN_TO_VALUE,target=Target_delq_30DPD,dset=ham);
%plot(var=ORIG_AMT,target=Target_delq_30DPD,dset=ham);
%plot(var=PAYMENT_CALC_MOD_BENEFIT,target=Target_delq_30DPD,dset=ham);
%plot(var=curr_fico,target=Target_delq_30DPD,dset=ham);

%plot(var=ltv_pct_mod,target=Target_delq_30DPD,dset=ham);
%plot(var=ltv_pct,target=Target_delq_30DPD,dset=ham);


%plot(var=ORIGINAL_LOAN_TO_VALUE,target=Target_delq_30DPD,dset=ham);
%plot(var=ORIGINAL_LOAN_TO_VALUE,target=Target_delq_30DPD,dset=ham);



