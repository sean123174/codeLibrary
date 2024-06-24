%put ************************* Cluster Catagorical Variables Values ************************;
%macro varclus(var=;);
proc means data=&dset noprint nway;
        class &var;
        var &target;
        output out=levels mean=prop;
run;

proc print data=levels;
run;

proc cluster data=levels method=ward outtree=fortree;
        freq _freq_;
        var prop;
        id &var;
run;

data fortree;
        set fortree;
        cut=(_rsq_>=.99);
run;

proc means data=fortree noprint;
        where cut=1;
        var _ncl_;
        output out=o min=ncl;
run;

data o;
        set o;
        call symput('ncl',ncl);
run;

proc tree data=fortree nclusters=&ncl out=clus h=rsq noprint;
id &var;
run;

proc sort data=clus;
        by clusname;
run;

proc print data=clus;
        by clusname;
        id clusname;
run; 
%mend;

%put ******************************** Variable Clustering *****************************;
%macro vareduc;

proc varclus data=&dset maxeigen=.7 outstat=formac outtree=fortree short;
var &vardata;
run;

%mend;

%put ********************* Find correlation with target variables ********************************;
%macro corr;
proc corr data=&dset nosimple spearman rank;
var &vardata;
with &target;
run;

%mend;


%put ********************* Scoring Validation Procedure ****************************************;
%macro score(dset=,model=,modelvar=,betas=);
* dset: The validation dataset;
* model: The name of the score;
* modelvar: The independent variables for the model;
* betats: The dataset containing the beta coefficents;

proc score data=&dset out=scordset score=&betas type=parms;
var &modelvar;
run;

data scordset;
set scordset;
&model=1/(1+exp(-(&target)));
%put *&model=1/(1+exp(-(&target-off)));*;
keep cl_tid &model;
run;

proc sort data=scordset;
by cl_tid;
run;

proc sort data=&dset;
by cl_tid;
run;

data &dset;
merge &dset (in=a) scordset (in=b);
by cl_tid;
if a and b;
run;
%mend;

%put ******************************* Rank Validation Dataset *******************************;
%macro rank(score=,dset=);
proc sort data=&dset out=rankdata ;
by &score;
run;

data rankdata;
set rankdata;
rknum=_n_;
rk&score=put(rknum,rankfmt.);
run;

proc sql;
create table ksdata as
select  rk&score,
        min(&score)             as minscore,
        max(&score)             as maxscore,
        count(*)                as numaccts,
        sum(actual*wt)          as target,
        sum((1-actual)*wt)      as nontarget,
        sum(wt)                 as wt

from rankdata

group by rk&score
;
quit;

%csv(ksdata,"ks&score..txt");

%mend;

%put ************************ Test Difference in means *****************;

%macro ttest(vardata=,classvar=,dset=);
proc means data=&dset;
class &classvar;
var &vardata;
run;

proc sort data=&dset;
by &classvar;
run;

proc univariate data=&dset normal plot;
var &vardata;
by &classvar;
run;

title 'Testing the Equality of Means';
proc ttest data=&dset;
class &classvar;
var &vardata;
run;

title 'Testing for Equality of Means with Proc GLM';
proc glm data=&dset;
class &classvar;
model &vardata=&classvar;
means &classvar / hovtest;
output out=check r=resid p=pred;
run;

proc univariate data=check normal plot;
var resid;
run;

goptions reset=all;
title 'Plot of Residuals';
proc gplot data=check;
plot resid*pred / haxis=axis1 vaxis=axis2 vref=0;
symbol v=star h=3pct;
axis1 w=2 major=(w=2) minor=none offset=(10pct);
axis2 w=2 major=(w=2) minor=none;
run;
%mend;

%put ************************ Test Difference in Binary target using Chi *****************;

%macro chisq(dset=,vardata=,classvar=);
proc freq data=&dset;
tables &classvar*&vardata / chisq cellchi2 expected nocol nopercent;
run;
%mend;

%put ************************ Test Difference in Ordinal variable *****************;

%macro ordinal(dset=,vardata=,classvar=);
proc freq data=&dset;
tables &classvar*&vardata /chisq measures cl;
run;
%mend;
