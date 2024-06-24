/************************************************************************/
/* Title: Model data for CHAID Relook                                   */
/* Filename: J:\CAM\PROJECTS\College Acquisition\CHAID                  */
/* Programer: Sean M. Burns                                             */
/* Output:                                                              */
/************************************************************************/

libname camdata '/camsrvr/camgrps/mediumfile/sburns/fallprw';
libname sasdata '/camsrvr/camgrps/mediumfile/sburns/fallprw';

/*libname knowdata 'j:\knowseek\bad';*/
%include '/u/sburns/csv.sas';
%include '/u/sburns/models.sas';

/**************************** Declare Working Variables ***************************/
/* These are all variables in the model */

%let vardata=
AGE_AT_RESP ANNL_INCM_AMT BRT_CT COLG_VERFY_IND 
CREDT_ESTBL_MON_CT CREDT_UPDT_MON_CT DPD30_CURR_CT  
INQ_EVER_CT SATIS_TL_CT TL_6MON_CT TL_CURR_04_09_CT 
TL_EVER_04_08_CT TL_EVER_CT TL_OPEN_G1YR_CT TL_RVLV_BAL_AMT chaidtag  
;

%let charvar=
CAPS_ERR_CD CHECK_ACCT_TYP_CD COLG_FULL_TIME_CD COLG_INCM_SOURC_CD COLG_SCF_RISK_CD 
COLG_STATE_CD COLG_TIER_CD Grade MAIL_TO_CD MODEL_NUM Port SAVNG_ACCT_IND 
SBU_SEGMT_ID SCHL_CLASS_ID School appdec bureau_type cat channel cp0901 infresh mailing 
new_app portfid school_type segment vertical 
;

/* The target variable or dependant variable.*/
%let target=risktag;

%let dset =camdata.riskall;


/*************************************************************************************/
/********************************* Modify data set ***********************************/
/*************************************************************************************/
/*
data sasdata.ncm;
set sasdata.ncm;
tncm=sum(of ncm1-ncm12);
tncm24=sum(of ncm1-ncm24);
toprexp=sum(of oprexpn1-oprexpn24);
run;

proc sort data=sasdata.ncm out=temp nodupkey;
by cl_tid;
run;

data &dset;
set &dset;
drop ncm1-ncm24 oprexpn1-oprexpn24 tncm toprexp;
run;

proc sort data=&dset;
by cl_tid;
run;

data &dset;
merge &dset (in=a) temp (in=b);
by cl_tid;
if a and b;

if tncm>0 then profitag=1; else profitag=0;
if (tncm-((buckcd12 in ('3','4','5','6'))*clsbal12))>0 then profitag2=1; else profitag2=0;
if tncm24>0 then profitag3=1; else profitag3=0;
run;

proc freq data=&dset;
tables profitag*risktag profitag2*risktag profitag3*risktag;
run;

proc means data=&dset;
class profitag3;
var tncm24;
run;

proc means data=&dset;
class profitag2;
var tncm;
run;

proc means data=&dset;
var ncl1 ncl2;
run;
*/
/*
data &dset;
set &dset;
tncm2=sum(of ncm13-ncm24);
toprexp1=sum(of oprexpn1-oprexpn12);
toprexp2=sum(of oprexpn13-oprexpn24);
if ncl2=. then ncl2=0;
run;

data temp2;
set sasdata.risktbl sasdata.riskoth;
tanr1=sum(of anr1-anr12);
tanr2=sum(of anr13-anr24);
keep cl_tid anr1-anr24 tanr1 tanr2;
run;

proc sort data=&dset;
by cl_tid;
run;

proc sort data=temp2;
by cl_tid;
run;

data &dset;
merge &dset (in=a) temp2 (in=c);
by cl_tid;
if a and c;
run;



proc sort data=sasdata.train;
by cl_tid;
run;

proc sort data=sasdata.valid;
by cl_tid;
run;

data sasdata.train;
merge sasdata.train (in=a) temp (in=b) temp2 (in=c);
by cl_tid;
if a and b and c;
run;

data sasdata.valid;
merge sasdata.valid (in=a) temp (in=b) temp2 (in=c);;
by cl_tid;
if a and b and c;
run;
*/



/*************************************************************************************/
/*************************** Produce basic statistics ********************************/
/*************************************************************************************/
/************************* Statistics of Independent Variables ***********************/
/*
title 'Basic Satisitics of Dataset';

proc means data=&dset n mean min max std sum;
var &target &vardata;
run;



proc contents data=&dset;
run;
*/
/*
proc freq data=&dset;
tables &target; 
where acct_creat_dt<='31MAY2001'd;
run;

proc freq data=&dset;
tables &target; 
where acct_creat_dt>'31MAY2001'd;
run;
*/

/***************** Remove or fix variables with missing data or unary variables ******/


   
/************************* Cluster Catagorical Variables Values ************************/


/*
%varclus(var=model_num);
%varclus(var=grade);
%varclus(var=cat);
*/
/**************************************************************************************/
/************************* Add new Dummy Variables from Cluster ***********************/
%let vardata=
AGE_AT_RESP ANNL_INCM_AMT BRT_CT COLG_VERFY_IND 
CREDT_ESTBL_MON_CT CREDT_UPDT_MON_CT DPD30_CURR_CT  
INQ_EVER_CT SATIS_TL_CT TL_6MON_CT TL_CURR_04_09_CT 
TL_EVER_04_08_CT TL_EVER_CT TL_OPEN_G1YR_CT TL_RVLV_BAL_AMT chaidtag 
model_num1 model_num2 model_num3 model_num4 grade1 grade2 grade3 grade4 
cat1 cat2 cat3 cat4 cat5 cat6 cat7 cat8
;

%let charvar=
CAPS_ERR_CD CHECK_ACCT_TYP_CD COLG_FULL_TIME_CD COLG_INCM_SOURC_CD COLG_SCF_RISK_CD 
COLG_STATE_CD COLG_TIER_CD Grade MAIL_TO_CD MODEL_NUM Port SAVNG_ACCT_IND 
SBU_SEGMT_ID SCHL_CLASS_ID School appdec bureau_type cat channel cp0901 infresh mailing 
new_app portfid school_type segment vertical 
;

/************* Assign Weights & Split the population into train and validation data set **************/
/* Need to exclude the target variable from the validation dataset when scoring*/
/* pi1 equals to the true proportion of the target=1 population*/
/* rho1 equals the oversample proportion of the target=1 */

%let pi1=0.0321; 
%let rho1=0.5000;
/*
proc means data=&dset noprint;
var &target;
output out=sum mean=rho1;
run;

data sum;
set sum;
call symput('rho1',rho1);
run;
*/
%put !!!!!!!!!!!!!!!!!!!!!!! Rho1 = &rho1 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
/*
data    &dset
        sasdata.emdata (keep=cl_tid &target weight off wt train &vardata &charvar )
        sasdata.train(keep=cl_tid &target weight off wt train &vardata &charvar ) 
        sasdata.valid(drop=&target );
set &dset;

%put ****************** Define Weight Variables ********************************;
off=log(((1-&pi1)*&rho1)/(&pi1*(1-&rho1)));
weight=((1-&pi1)/(1-&rho1))*(&target=0)+(&pi1/&rho1)*(&target=1);
wt=(827971/31297)*(&target=0)+(31297/31297)*(&target=1);
actual=&target;

%put ******************* Create Varaible Cluster Dummary variables ****************;
model_num1= model_num in ('T2','T3');
model_num2= model_num in ('T1','U3','C8','U2');
model_num3= model_num in ('U3');
model_num4= model_num in ('U4');

grade1= grade in ('Junior','Sophomore');
grade2= grade in ('Freshman','Unknown');
grade3= grade in ('Graduate');
grade4= grade in ('Senior');

cat1= cat in ('9','E','B','V','P','M','Q','H');
cat2= cat in ('C','F','R','D');
cat3= cat in ('I','U');
cat4= cat in ('A','Y','O');
cat5= cat in ('W','Z');
cat6= cat in ('L','T','G','X','N');
cat7= cat in ('J','S');
cat8= cat in ('K');

%put ****************** Split datasets into train and validation *****************;

train=(ranuni(0)<0.50);
em=0;

if &target=1 and acct_creat_dt<='31MAY2001'd then 
        do;
                em=1;
                output sasdata.emdata;
                if train=1 then output sasdata.train; else output sasdata.valid;
        end;
else if &target=0 and (ranuni(0)<(31297/827971)) and acct_creat_dt<='31MAY2001'd then 
        do;
                em=1;
                output sasdata.emdata;
                if train=1 then output sasdata.train; else output sasdata.valid;
        end;

output &dset;

run;
*/


/****************************** Create Dataset for Knowseeker **********************************/

/***************************** Define Dset to training dataset ***********************/
%let dset=sasdata.train;

/***************************** Rough Primary Models *********************************/
title 'Rough Primary Models with no variable reducation';

/*
proc reg data=&dset;
stepwise: model &target = &vardata / vif selection=stepwise;
run;


proc logistic data=&dset des;
model  &target = &vardata &vardata2 / selection=stepwise lackfit;
run;
*/
/* Optional: Eliminate variables not selected in the rough model */
%let vardata=
AGE_AT_RESP ANNL_INCM_AMT BRT_CT COLG_VERFY_IND 
CREDT_ESTBL_MON_CT CREDT_UPDT_MON_CT DPD30_CURR_CT  
INQ_EVER_CT SATIS_TL_CT TL_6MON_CT TL_CURR_04_09_CT 
TL_EVER_04_08_CT TL_EVER_CT TL_OPEN_G1YR_CT TL_RVLV_BAL_AMT chaidtag 
model_num1 model_num2 model_num3 model_num4 grade1 grade2 grade3 grade4 
cat1 cat2 cat3 cat4 cat5 cat6 cat7 cat8
;

%let charvar=
CAPS_ERR_CD CHECK_ACCT_TYP_CD COLG_FULL_TIME_CD COLG_INCM_SOURC_CD COLG_SCF_RISK_CD 
COLG_STATE_CD COLG_TIER_CD Grade MAIL_TO_CD MODEL_NUM Port SAVNG_ACCT_IND 
SBU_SEGMT_ID SCHL_CLASS_ID School appdec bureau_type cat channel cp0901 infresh mailing 
new_app portfid school_type segment vertical 
;
/******************************** Variable Clustering *****************************/

/*
%vareduc;
*/

/* Selected one variable from each cluster where 1-R**2 is the lowest */


/********************* Find correlation with target variables ********************************/

/*
%corr;
*/
/* Eliminate variables with a p-value greater than 0.50.*/


/********************** Apply Knowseek Trees to table ***********************************/
%macro branch(dset=);

data &dset;
set &dset;

%put ********************* new-chaid tree score1 *****************************;
/*    x.42/0    */
IF cat = '9'
OR cat = 'A'
OR cat = 'B'
OR cat = 'D'
OR cat = 'E'
OR cat = 'H'
OR cat = 'M'
OR cat = 'O'
OR cat = 'P'
OR cat = 'Q'
OR cat = 'R'
OR cat = 'V'
OR cat = 'Y' THEN
DO;
        /*    x.42/0.37/0    */
        IF School = '2'
        OR School = 'F'
        OR School = 'G'
        OR School = 'L'
        OR School = 'M'
        OR School = 'O'
        OR School = 'V'
        OR School = 'x' THEN
        DO;
                /*    x.42/0.37/0.31/0    */
                IF bureau_type = 'FBnoFICO'
                OR bureau_type = 'InqOnly' THEN
                DO;
                        score1 = 0.100479;
                END;
                /*    x.42/0.37/0.31/1    */
                ELSE IF bureau_type = 'FBwFICO'
                     OR bureau_type = 'NoBureau' THEN
                DO;
                        score1 = 0.056922;
                END;
                /*    x.42/0.37/0    */
                ELSE 
                DO;
                        score1 = 0.087911;
                END;
        END;
        /*    x.42/0.37/1    */
        ELSE IF School = 'A'
             OR School = 'B'
             OR School = 'C'
             OR School = 'D'
             OR School = 'E'
             OR School = 'N'
             OR School = 'R'
             OR School = 'T' THEN
        DO;
                /*    x.42/0.37/1.19/0    */
                IF COLG_STATE_CD = ' '
                OR COLG_STATE_CD = 'CA'
                OR COLG_STATE_CD = 'CO'
                OR COLG_STATE_CD = 'DC'
                OR COLG_STATE_CD = 'DE'
                OR COLG_STATE_CD = 'ID'
                OR COLG_STATE_CD = 'IN'
                OR COLG_STATE_CD = 'KS'
                OR COLG_STATE_CD = 'KY'
                OR COLG_STATE_CD = 'LA'
                OR COLG_STATE_CD = 'MD'
                OR COLG_STATE_CD = 'ME'
                OR COLG_STATE_CD = 'MT'
                OR COLG_STATE_CD = 'NC'
                OR COLG_STATE_CD = 'ND'
                OR COLG_STATE_CD = 'NH'
                OR COLG_STATE_CD = 'NM'
                OR COLG_STATE_CD = 'TN'
                OR COLG_STATE_CD = 'UT'
                OR COLG_STATE_CD = 'VT'
                OR COLG_STATE_CD = 'WA'
                OR COLG_STATE_CD = 'WI'
                OR COLG_STATE_CD = 'WY' THEN
                DO;
                        score1 = 0.037298;
                END;
                /*    x.42/0.37/1.19/1    */
                ELSE IF COLG_STATE_CD = 0.000000
                     OR COLG_STATE_CD = 'AL'
                     OR COLG_STATE_CD = 'AR'
                     OR COLG_STATE_CD = 'CT'
                     OR COLG_STATE_CD = 'FL'
                     OR COLG_STATE_CD = 'MS'
                     OR COLG_STATE_CD = 'NE'
                     OR COLG_STATE_CD = 'NJ'
                     OR COLG_STATE_CD = 'OK'
                     OR COLG_STATE_CD = 'SD'
                     OR COLG_STATE_CD = 'WV' THEN
                DO;
                        score1 = 0.092944;
                END;
                /*    x.42/0.37/1.19/2    */
                ELSE IF COLG_STATE_CD = 'AZ'
                     OR COLG_STATE_CD = 'GA'
                     OR COLG_STATE_CD = 'IA'
                     OR COLG_STATE_CD = 'IL'
                     OR COLG_STATE_CD = 'MA'
                     OR COLG_STATE_CD = 'MI'
                     OR COLG_STATE_CD = 'MN'
                     OR COLG_STATE_CD = 'MO'
                     OR COLG_STATE_CD = 'NY'
                     OR COLG_STATE_CD = 'OH'
                     OR COLG_STATE_CD = 'OR'
                     OR COLG_STATE_CD = 'PA'
                     OR COLG_STATE_CD = 'RI'
                     OR COLG_STATE_CD = 'SC'
                     OR COLG_STATE_CD = 'TX'
                     OR COLG_STATE_CD = 'VA' THEN
                DO;
                        /*    x.42/0.37/1.19/2.21/0    */
                        IF SBU_SEGMT_ID = '01'
                        OR SBU_SEGMT_ID = '03'
                        OR SBU_SEGMT_ID = '04'
                        OR SBU_SEGMT_ID = '1'
                        OR SBU_SEGMT_ID = '3' THEN
                        DO;
                                score1 = 0.049244;
                        END;
                        /*    x.42/0.37/1.19/2.21/1    */
                        ELSE IF SBU_SEGMT_ID = '2'
                             OR SBU_SEGMT_ID = '4' THEN
                        DO;
                                score1 = 0.099345;
                        END;
                        /*    x.42/0.37/1.19/2    */
                        ELSE 
                        DO;
                                score1 = 0.054891;
                        END;
                END;
                /*    x.42/0.37/1    */
                ELSE 
                DO;
                        score1 = 0.041458;
                END;
        END;
        /*    x.42/0    */
        ELSE 
        DO;
                score1 = 0.047463;
        END;
END;
/*    x.42/1    */
ELSE IF cat = 'C'
     OR cat = 'F'
     OR cat = 'G'
     OR cat = 'J'
     OR cat = 'L'
     OR cat = 'N'
     OR cat = 'S'
     OR cat = 'T'
     OR cat = 'X' THEN
DO;
        score1 = 0.104689;
END;
/*    x.42/2    */
ELSE IF cat = 'I'
     OR cat = 'K'
     OR cat = 'U'
     OR cat = 'W'
     OR cat = 'Z' THEN
DO;
        /*    x.42/2.7/0    */
        IF MODEL_NUM = ' '
        OR MODEL_NUM = 'C8'
        OR MODEL_NUM = 'U1'
        OR MODEL_NUM = 'U2'
        OR MODEL_NUM = 'U3' THEN
        DO;
                /*    x.42/2.7/0.30/0    */
                IF portfid = 'AA'
                OR portfid = 'driver'
                OR portfid = 'ucs' THEN
                DO;
                        score1 = 0.013252;
                END;
                /*    x.42/2.7/0.30/1    */
                ELSE IF portfid = 'click'
                     OR portfid = 'dividend'
                     OR portfid = 'sony' THEN
                DO;
                        score1 = 0.008713;
                END;
                /*    x.42/2.7/0.30/2    */
                ELSE IF portfid = 'error'
                     OR portfid = 'platinum' THEN
                DO;
                        /*    x.42/2.7/0.30/2.28/0    */
                        IF channel = 'Interne'
                        OR channel = 'NPS'
                        OR channel = 'OBTM'
                        OR channel = 'Other'
                        OR channel = 'Take On' THEN
                        DO;
                                score1 = 0.014854;
                        END;
                        /*    x.42/2.7/0.30/2.28/1    */
                        ELSE IF channel = 'Tabling' THEN
                        DO;
                                /*    x.42/2.7/0.30/2.28/1.19/0    */
                                IF COLG_STATE_CD = ' '
                                OR COLG_STATE_CD = 0.000000
                                OR COLG_STATE_CD = 'AL'
                                OR COLG_STATE_CD = 'DC'
                                OR COLG_STATE_CD = 'IA'
                                OR COLG_STATE_CD = 'ID'
                                OR COLG_STATE_CD = 'IN'
                                OR COLG_STATE_CD = 'LA'
                                OR COLG_STATE_CD = 'MD'
                                OR COLG_STATE_CD = 'ND'
                                OR COLG_STATE_CD = 'NE'
                                OR COLG_STATE_CD = 'NM'
                                OR COLG_STATE_CD = 'OR'
                                OR COLG_STATE_CD = 'TN'
                                OR COLG_STATE_CD = 'UT'
                                OR COLG_STATE_CD = 'VT'
                                OR COLG_STATE_CD = 'WY' THEN
                                DO;
                                        score1 = 0.022297;
                                END;
                                /*    x.42/2.7/0.30/2.28/1.19/1    */
                                ELSE IF COLG_STATE_CD = 'AR'
                                     OR COLG_STATE_CD = 'AZ'
                                     OR COLG_STATE_CD = 'CT'
                                     OR COLG_STATE_CD = 'DE'
                                     OR COLG_STATE_CD = 'KS'
                                     OR COLG_STATE_CD = 'MA'
                                     OR COLG_STATE_CD = 'ME'
                                     OR COLG_STATE_CD = 'MI'
                                     OR COLG_STATE_CD = 'MO'
                                     OR COLG_STATE_CD = 'MS'
                                     OR COLG_STATE_CD = 'NJ'
                                     OR COLG_STATE_CD = 'PA'
                                     OR COLG_STATE_CD = 'RI'
                                     OR COLG_STATE_CD = 'SD'
                                     OR COLG_STATE_CD = 'TX'
                                     OR COLG_STATE_CD = 'WA'
                                     OR COLG_STATE_CD = 'WV' THEN
                                DO;
                                        score1 = 0.089925;
                                END;
                                /*    x.42/2.7/0.30/2.28/1.19/2    */
                                ELSE IF COLG_STATE_CD = 'CA'
                                     OR COLG_STATE_CD = 'CO'
                                     OR COLG_STATE_CD = 'FL'
                                     OR COLG_STATE_CD = 'GA'
                                     OR COLG_STATE_CD = 'IL'
                                     OR COLG_STATE_CD = 'KY'
                                     OR COLG_STATE_CD = 'MN'
                                     OR COLG_STATE_CD = 'MT'
                                     OR COLG_STATE_CD = 'NC'
                                     OR COLG_STATE_CD = 'NH'
                                     OR COLG_STATE_CD = 'NY'
                                     OR COLG_STATE_CD = 'OH'
                                     OR COLG_STATE_CD = 'OK'
                                     OR COLG_STATE_CD = 'SC'
                                     OR COLG_STATE_CD = 'VA'
                                     OR COLG_STATE_CD = 'WI' THEN
                                DO;
                                        /*    x.42/2.7/0.30/2.28/1.19/2.5/0    */
                                        IF CREDT_UPDT_MON_CT >= 0.000000 AND CREDT_UPDT_MON_CT < 2.000000 THEN
                                        DO;
                                                score1 = 0.045809;
                                        END;
                                        /*    x.42/2.7/0.30/2.28/1.19/2.5/1    */
                                        ELSE IF CREDT_UPDT_MON_CT >= 2.000000 AND CREDT_UPDT_MON_CT <= 113.000000 THEN
                                        DO;
                                                score1 = 0.095271;
                                        END;
                                        /*    x.42/2.7/0.30/2.28/1.19/2    */
                                        ELSE 
                                        DO;
                                                score1 = 0.056426;
                                        END;
                                END;
                                /*    x.42/2.7/0.30/2.28/1    */
                                ELSE 
                                DO;
                                        score1 = 0.033206;
                                END;
                        END;
                        /*    x.42/2.7/0.30/2    */
                        ELSE 
                        DO;
                                score1 = 0.025146;
                        END;
                END;
                /*    x.42/2.7/0    */
                ELSE 
                DO;
                        score1 = 0.017783;
                END;
        END;
        /*    x.42/2.7/1    */
        ELSE IF MODEL_NUM = 'T1'
             OR MODEL_NUM = 'T2'
             OR MODEL_NUM = 'T3'
             OR MODEL_NUM = 'U4' THEN
        DO;
                /*    x.42/2.7/1.2/0    */
                IF INQ_EVER_CT = .
                OR INQ_EVER_CT >= 0.000000 AND INQ_EVER_CT < 1.000000
                OR INQ_EVER_CT >= 1.000000 AND INQ_EVER_CT < 2.000000
                OR INQ_EVER_CT >= 2.000000 AND INQ_EVER_CT < 3.000000
                OR INQ_EVER_CT >= 3.000000 AND INQ_EVER_CT < 4.000000
                OR INQ_EVER_CT >= 4.000000 AND INQ_EVER_CT < 5.000000
                OR INQ_EVER_CT >= 5.000000 AND INQ_EVER_CT < 6.000000
                OR INQ_EVER_CT >= 6.000000 AND INQ_EVER_CT < 7.000000
                OR INQ_EVER_CT >= 7.000000 AND INQ_EVER_CT < 10.000000 THEN
                DO;
                        /*    x.42/2.7/1.2/0.10/0    */
                        IF MAIL_TO_CD = 'H' THEN
                        DO;
                                score1 = 0.033556;
                        END;
                        /*    x.42/2.7/1.2/0.10/1    */
                        ELSE IF MAIL_TO_CD = 'S' THEN
                        DO;
                                score1 = 0.057148;
                        END;
                        /*    x.42/2.7/1.2/0    */
                        ELSE 
                        DO;
                                score1 = 0.038804;
                        END;
                END;
                /*    x.42/2.7/1.2/1    */
                ELSE IF INQ_EVER_CT >= 10.000000 AND INQ_EVER_CT <= 84.000000 THEN
                DO;
                        /*    x.42/2.7/1.2/1.38/0    */
                        IF Grade = 'Freshman'
                        OR Grade = 'Junior'
                        OR Grade = 'Sophomore'
                        OR Grade = 'Unknown' THEN
                        DO;
                                score1 = 0.085829;
                        END;
                        /*    x.42/2.7/1.2/1.38/1    */
                        ELSE IF Grade = 'Graduate'
                             OR Grade = 'Senior' THEN
                        DO;
                                score1 = 0.047128;
                        END;
                        /*    x.42/2.7/1.2/1    */
                        ELSE 
                        DO;
                                score1 = 0.073931;
                        END;
                END;
                /*    x.42/2.7/1    */
                ELSE 
                DO;
                        score1 = 0.044092;
                END;
        END;
        /*    x.42/2    */
        ELSE 
        DO;
                score1 = 0.023051;
        END;
END;
/*    x    */
ELSE 
DO;
        score1 = 0.031648;
END;

%put ********************* binary *****************************;

/*    x.51/0    */
IF model_num3 = 0.000000 THEN
DO;
        /*    x.51/0.7/0    */
        IF MODEL_NUM = 'C8'
        OR MODEL_NUM = 'T1'
        OR MODEL_NUM = 'T2'
        OR MODEL_NUM = 'T3' THEN
        DO;
                /*    x.51/0.7/0.64/0    */
                IF cat8 = 0.000000 THEN
                DO;
                        /*    x.51/0.7/0.64/0.60/0    */
                        IF cat4 = 0.000000 THEN
                        DO;
                                /*    x.51/0.7/0.64/0.60/0.57/0    */
                                IF cat1 = 0.000000 THEN
                                DO;
                                        score2 = 0.144943;
                                END;
                                /*    x.51/0.7/0.64/0.60/0.57/1    */
                                ELSE IF cat1 = 1.000000 THEN
                                DO;
                                        score2 = 0.086685;
                                END;
                                /*    x.51/0.7/0.64/0.60/0    */
                                ELSE 
                                DO;
                                        score2 = 0.126708;
                                END;
                        END;
                        /*    x.51/0.7/0.64/0.60/1    */
                        ELSE IF cat4 = 1.000000 THEN
                        DO;
                                /*    x.51/0.7/0.64/0.60/1.17/0    */
                                IF COLG_FULL_TIME_CD = 'F'
                                OR COLG_FULL_TIME_CD = 'P' THEN
                                DO;
                                        score2 = 0.070176;
                                END;
                                /*    x.51/0.7/0.64/0.60/1.17/1    */
                                ELSE IF COLG_FULL_TIME_CD = . THEN
                                DO;
                                        score2 = 0.051998;
                                END;
                                /*    x.51/0.7/0.64/0.60/1    */
                                ELSE 
                                DO;
                                        score2 = 0.060461;
                                END;
                        END;
                        /*    x.51/0.7/0.64/0    */
                        ELSE 
                        DO;
                                score2 = 0.106945;
                        END;
                END;
                /*    x.51/0.7/0.64/1    */
                ELSE IF cat8 = 1.000000 THEN
                DO;
                        /*    x.51/0.7/0.64/1.49/0    */
                        IF model_num1 = 0.000000 THEN
                        DO;
                                /*    x.51/0.7/0.64/1.49/0.6/0    */
                                IF ANNL_INCM_AMT >= 0.000000 AND ANNL_INCM_AMT < 12000.000000 THEN
                                DO;
                                        score2 = 0.027941;
                                END;
                                /*    x.51/0.7/0.64/1.49/0.6/1    */
                                ELSE IF ANNL_INCM_AMT >= 12000.000000 AND ANNL_INCM_AMT <= 999999.000000 THEN
                                DO;
                                        score2 = 0.050370;
                                END;
                                /*    x.51/0.7/0.64/1.49/0    */
                                ELSE 
                                DO;
                                        score2 = 0.037254;
                                END;
                        END;
                        /*    x.51/0.7/0.64/1.49/1    */
                        ELSE IF model_num1 = 1.000000 THEN
                        DO;
                                score2 = 0.069488;
                                
                        END;
                        /*    x.51/0.7/0.64/1    */
                        ELSE 
                        DO;
                                score2 = 0.045351;
                        END;
                END;
                /*    x.51/0.7/0    */
                ELSE 
                DO;
                        score2 = 0.074449;
                END;
        END;
        /*    x.51/0.7/1    */
        ELSE IF MODEL_NUM = . THEN
        DO;
                /*    x.51/0.7/1.37/0    */
                IF School = '2'
                OR School = 'E'
                OR School = 'F'
                OR School = 'G'
                OR School = 'L'
                OR School = 'M'
                OR School = 'O'
                OR School = 'R'
                OR School = 'T'
                OR School = 'V'
                OR School = 'x' THEN
                DO;
                        score2 = 0.029621;
                END;
                /*    x.51/0.7/1.37/1    */
                ELSE IF School = 'A'
                     OR School = 'B'
                     OR School = 'C'
                     OR School = 'D' THEN
                DO;
                        /*    x.51/0.7/1.37/1.16/0    */
                        IF AGE_AT_RESP = .
                        OR AGE_AT_RESP >= 17.000000 AND AGE_AT_RESP < 28.000000 THEN
                        DO;
                                /*    x.51/0.7/1.37/1.16/0.6/0    */
                                IF ANNL_INCM_AMT >= 1.000000 AND ANNL_INCM_AMT < 6000.000000 THEN
                                DO;
                                        score2 = 0.005328;
                                END;
                                /*    x.51/0.7/1.37/1.16/0.6/1    */
                                ELSE IF ANNL_INCM_AMT >= 6000.000000 AND ANNL_INCM_AMT <= 999999.000000 THEN
                                DO;
                                        score2 = 0.008890;
                                END;
                                /*    x.51/0.7/1.37/1.16/0    */
                                ELSE 
                                DO;
                                        score2 = 0.006946;
                                END;
                        END;
                        /*    x.51/0.7/1.37/1.16/1    */
                        ELSE IF AGE_AT_RESP >= 28.000000 AND AGE_AT_RESP <= 101.000000 THEN
                        DO;
                                score2 = 0.016577;
                        END;
                        /*    x.51/0.7/1.37/1    */
                        ELSE 
                        DO;
                                score2 = 0.007478;
                        END;
                END;
                /*    x.51/0.7/1    */
                ELSE 
                DO;
                        score2 = 0.009414;
                END;
        END;
        /*    x.51/0.7/2    */
        ELSE IF MODEL_NUM = 'U1'
             OR MODEL_NUM = 'U2'
             OR MODEL_NUM = 'U4' THEN
        DO;
                /*    x.51/0.7/2.43/0    */
                IF new_app = 'Decline' THEN
                DO;
                        /*    x.51/0.7/2.43/0.62/0    */
                        IF cat6 = 0.000000 THEN
                        DO;
                                /*    x.51/0.7/2.43/0.62/0.1/0    */
                                IF CAPS_ERR_CD = . THEN
                                DO;
                                        score2 = 0.011939;
                                END;
                                /*    x.51/0.7/2.43/0.62/0.1/2    */
                                ELSE IF CAPS_ERR_CD = '1'
                                     OR CAPS_ERR_CD = '1Z' 
                                     OR CAPS_ERR_CD = '2'
                                     OR CAPS_ERR_CD = '2Z' THEN
                                DO;
                                        score2 = 0.052737;
                                END;
                                /*    x.51/0.7/2.43/0.62/0    */
                                ELSE 
                                DO;
                                        score2 = 0.051450;
                                END;
                        END;
                        /*    x.51/0.7/2.43/0.62/1    */
                        ELSE IF cat6 = 1.000000 THEN
                        DO;
                                /*    x.51/0.7/2.43/0.62/1.16/0    */
                                IF AGE_AT_RESP >= 18.000000 AND AGE_AT_RESP < 20.000000 THEN
                                DO;
                                        score2 = 0.072469;
                                END;
                                /*    x.51/0.7/2.43/0.62/1.16/1    */
                                ELSE IF AGE_AT_RESP >= 20.000000 AND AGE_AT_RESP <= 101.000000 THEN
                                DO;
                                        score2 = 0.113763;
                                END;
                                /*    x.51/0.7/2.43/0.62/1    */
                                ELSE 
                                DO;
                                        score2 = 0.093872;
                                END;
                        END;
                        /*    x.51/0.7/2.43/0    */
                        ELSE 
                        DO;
                                score2 = 0.057559;
                        END;
                END;
                /*    x.51/0.7/2.43/1    */
                ELSE IF new_app = 'Approve' THEN
                DO;
                        /*    x.51/0.7/2.43/1.27/0    */
                        IF TL_RVLV_BAL_AMT >= 0.000000 AND TL_RVLV_BAL_AMT < 548.000000 THEN
                        DO;
                                /*    x.51/0.7/2.43/1.27/0.10/0    */
                                IF MAIL_TO_CD = 'S' THEN
                                DO;
                                        score2 = 0.044979;
                                END;
                                /*    x.51/0.7/2.43/1.27/0.10/1    */
                                ELSE IF MAIL_TO_CD = 'H' THEN
                                DO;
                                        score2 = 0.023656;
                                END;
                                /*    x.51/0.7/2.43/1.27/0    */
                                ELSE 
                                DO;
                                        score2 = 0.028252;
                                END;
                        END;
                        /*    x.51/0.7/2.43/1.27/1    */
                        ELSE IF TL_RVLV_BAL_AMT >= 548.000000 AND TL_RVLV_BAL_AMT <= 24763.000000 THEN
                        DO;
                                /*    x.51/0.7/2.43/1.27/1.2/0    */
                                IF INQ_EVER_CT >= 0.000000 AND INQ_EVER_CT < 5.000000 THEN
                                DO;
                                        score2 = 0.037527;
                                END;
                                /*    x.51/0.7/2.43/1.27/1.2/1    */
                                ELSE IF INQ_EVER_CT >= 5.000000 AND INQ_EVER_CT <= 84.000000 THEN
                                DO;
                                        score2 = 0.063249;
                                END;
                                /*    x.51/0.7/2.43/1.27/1    */
                                ELSE 
                                DO;
                                        score2 = 0.050050;
                                END;
                        END;
                        /*    x.51/0.7/2.43/1    */
                        ELSE 
                        DO;
                                score2 = 0.035099;
                        END;
                END;
                /*    x.51/0.7/2    */
                ELSE 
                DO;
                        score2 = 0.043179;
                END;
        END;
        /*    x.51/0    */
        ELSE 
        DO;
                score2 = 0.041737;
        END;
END;
/*    x.51/1    */
ELSE IF model_num3 = 1.000000 THEN
DO;
        /*    x.51/1.10/0    */
        IF MAIL_TO_CD = 'S' THEN
        DO;
                /*    x.51/1.10/0.30/0    */
                IF portfid = 'click'
                OR portfid = 'dividend'
                OR portfid = 'driver'
                OR portfid = 'error'
                OR portfid = 'sony'
                OR portfid = 'ucs' THEN
                DO;
                        /*    x.51/1.10/0.30/0.64/0    */
                        IF cat8 = 0.000000 THEN
                        DO;
                                score2 = 0.044958;
                        END;
                        /*    x.51/1.10/0.30/0.64/1    */
                        ELSE IF cat8 = 1.000000 THEN
                        DO;
                                /*    x.51/1.10/0.30/0.64/1.17/0    */
                                IF COLG_FULL_TIME_CD = 'F'
                                OR COLG_FULL_TIME_CD = 'P' THEN
                                DO;
                                        score2 = 0.025288;
                                END;
                                /*    x.51/1.10/0.30/0.64/1.17/1    */
                                ELSE IF COLG_FULL_TIME_CD = . THEN
                                DO;
                                        score2 = 0.010448;
                                END;
                                /*    x.51/1.10/0.30/0.64/1    */
                                ELSE 
                                DO;
                                        score2 = 0.011911;
                                END;
                        END;
                        /*    x.51/1.10/0.30/0    */
                        ELSE 
                        DO;
                                score2 = 0.013625;
                        END;
                END;
                /*    x.51/1.10/0.30/1    */
                ELSE IF portfid = 'platinum' THEN
                DO;
                        /*    x.51/1.10/0.30/1.28/0    */
                        IF channel = 'Interne'
                        OR channel = 'NPS'
                        OR channel = 'OBTM'
                        OR channel = 'Other'
                        OR channel = 'Take On' THEN
                        DO;
                                /*    x.51/1.10/0.30/1.28/0.9/0    */
                                IF COLG_TIER_CD = '0'
                                OR COLG_TIER_CD = '1'
                                OR COLG_TIER_CD = '2'
                                OR COLG_TIER_CD = '3'
                                OR COLG_TIER_CD = '5'
                                OR COLG_TIER_CD = '6'
                                OR COLG_TIER_CD = '9'
                                OR COLG_TIER_CD = 'F'
                                OR COLG_TIER_CD = 'G'
                                OR COLG_TIER_CD = 'J' THEN
                                DO;
                                        score2 = 0.016963;
                                END;
                                /*    x.51/1.10/0.30/1.28/0.9/1    */
                                ELSE IF COLG_TIER_CD = '4' THEN
                                DO;
                                        score2 = 0.029764;
                                END;
                                /*    x.51/1.10/0.30/1.28/0    */
                                ELSE 
                                DO;
                                        score2 = 0.020801;
                                END;
                        END;
                        /*    x.51/1.10/0.30/1.28/1    */
                        ELSE IF channel = 'Tabling' THEN
                        DO;
                                /*    x.51/1.10/0.30/1.28/1.21/0    */
                                IF SBU_SEGMT_ID = '4' THEN
                                DO;
                                        score2 = 0.099508;
                                END;
                                /*    x.51/1.10/0.30/1.28/1.21/1    */
                                ELSE IF SBU_SEGMT_ID = '04' THEN
                                DO;
                                        score2 = 0.046281;
                                END;
                                /*    x.51/1.10/0.30/1.28/1    */
                                ELSE 
                                DO;
                                        score2 = 0.053139;
                                END;
                        END;
                        /*    x.51/1.10/0.30/1    */
                        ELSE 
                        DO;
                                score2 = 0.040285;
                        END;
                END;
                /*    x.51/1.10/0    */
                ELSE 
                DO;
                        score2 = 0.027870;
                END;
        END;
        /*    x.51/1.10/1    */
        ELSE IF MAIL_TO_CD = 'H' THEN
        DO;
                /*    x.51/1.10/1.62/0    */
                IF cat6 = 0.000000 THEN
                DO;
                        /*    x.51/1.10/1.62/0.30/0    */
                        IF portfid = 'AA'
                        OR portfid = 'click'
                        OR portfid = 'dividend'
                        OR portfid = 'driver'
                        OR portfid = 'error'
                        OR portfid = 'sony'
                        OR portfid = 'ucs' THEN
                        DO;
                                /*    x.51/1.10/1.62/0.30/0.28/0    */
                                IF channel = 'Interne'
                                OR channel = 'NPS'
                                OR channel = 'OBTM'
                                OR channel = 'Other'
                                OR channel = 'Take On' THEN
                                DO;
                                        score2 = 0.014095;
                                END;
                                /*    x.51/1.10/1.62/0.30/0.28/1    */
                                ELSE IF channel = 'Tabling' THEN
                                DO;
                                        score2 = 0.006769;
                                END;
                                /*    x.51/1.10/1.62/0.30/0    */
                                ELSE 
                                DO;
                                        score2 = 0.007921;
                                END;
                        END;
                        /*    x.51/1.10/1.62/0.30/1    */
                        ELSE IF portfid = 'platinum' THEN
                        DO;
                                /*    x.51/1.10/1.62/0.30/1.28/0    */
                                IF channel = 'Interne'
                                OR channel = 'NPS'
                                OR channel = 'OBTM'
                                OR channel = 'Other'
                                OR channel = 'Take On' THEN
                                DO;
                                        score2 = 0.009759;
                                END;
                                /*    x.51/1.10/1.62/0.30/1.28/1    */
                                ELSE IF channel = 'Tabling' THEN
                                DO;
                                        score2 = 0.018881;
                                END;
                                /*    x.51/1.10/1.62/0.30/1    */
                                ELSE 
                                DO;
                                        score2 = 0.014827;
                                END;
                        END;
                        /*    x.51/1.10/1.62/0    */
                        ELSE 
                        DO;
                                score2 = 0.011811;
                        END;
                END;
                /*    x.51/1.10/1.62/1    */
                ELSE IF cat6 = 1.000000 THEN
                DO;
                        /*    x.51/1.10/1.62/1.26/0    */
                        IF TL_OPEN_G1YR_CT >= 0.000000 AND TL_OPEN_G1YR_CT < 7.000000 THEN
                        DO;
                                score2 = 0.094134;
                        END;
                        /*    x.51/1.10/1.62/1.26/1    */
                        ELSE IF TL_OPEN_G1YR_CT >= 7.000000 AND TL_OPEN_G1YR_CT <= 70.000000 THEN
                        DO;
                                score2 = 0.044810;
                        END;
                        /*    x.51/1.10/1.62/1    */
                        ELSE 
                        DO;
                                score2 = 0.069891;
                        END;
                END;
                /*    x.51/1.10/1    */
                ELSE 
                DO;
                        score2 = 0.012983;
                END;
        END;
        /*    x.51/1    */
        ELSE 
        DO;
                score2 = 0.017141;
        END;
END;
/*    x    */
ELSE 
DO;
        score2 = 0.031648;
END;
%put ********************* benchmark tree *****************************;

/*    x.28/0    */
IF channel = 'Interne' THEN
DO;
        score3 = 0.040269;
END;
/*    x.28/1    */
ELSE IF channel = 'NPS' THEN
DO;
        score3 = 0.030017;
END;
/*    x.28/2    */
ELSE IF channel = 'OBTM' THEN
DO;
        score3 = 0.032403;
END;
/*    x.28/3    */
ELSE IF channel = 'Other' THEN
DO;
        score3 = 0.024310;
END;
/*    x.28/4    */
ELSE IF channel = 'Tabling' THEN
DO;
        /*    x.28/4.31/0    */
        IF bureau_type = 'FBnoFICO' THEN
        DO;
                /*    x.28/4.31/0.15/0    */
                IF TL_CURR_04_09_CT = 0.000000 THEN
                DO;
                        /*    x.28/4.31/0.15/0.38/0    */
                        IF Grade = 'Freshman'
                        OR Grade = 'Unknown' THEN
                        DO;
                                /*    x.28/4.31/0.15/0.38/0.2/0    */
                                IF INQ_EVER_CT >= 0.000000 AND INQ_EVER_CT < 1.000000
                                OR INQ_EVER_CT >= 1.000000 AND INQ_EVER_CT < 2.000000
                                OR INQ_EVER_CT >= 2.000000 AND INQ_EVER_CT < 3.000000 THEN
                                DO;
                                        /*    x.28/4.31/0.15/0.38/0.2/0.42/0    */
                                        IF cat = 'A' THEN
                                        DO;
                                                score3 = 0.031682;
                                        END;
                                        /*    x.28/4.31/0.15/0.38/0.2/0.42/1    */
                                        ELSE IF cat = 'B' THEN
                                        DO;
                                                score3 = 0.052448;
                                        END;
                                        /*    x.28/4.31/0.15/0.38/0.2/0.42/2    */
                                        ELSE IF cat = 'C' THEN
                                        DO;
                                                score3 = 0.098611;
                                        END;
                                        /*    x.28/4.31/0.15/0.38/0.2/0    */
                                        ELSE 
                                        DO;
                                                score3 = 0.040398;
                                        END;
                                END;
                                /*    x.28/4.31/0.15/0.38/0.2/1    */
                                ELSE IF INQ_EVER_CT >= 3.000000 AND INQ_EVER_CT < 4.000000
                                     OR INQ_EVER_CT >= 4.000000 AND INQ_EVER_CT < 5.000000
                                     OR INQ_EVER_CT >= 5.000000 AND INQ_EVER_CT < 6.000000
                                     OR INQ_EVER_CT >= 6.000000 AND INQ_EVER_CT < 7.000000
                                     OR INQ_EVER_CT >= 7.000000 AND INQ_EVER_CT < 10.000000
                                     OR INQ_EVER_CT >= 10.000000 AND INQ_EVER_CT <= 84.000000 THEN
                                DO;
                                        /*    x.28/4.31/0.15/0.38/0.2/1.42/0    */
                                        IF cat = 'D' THEN
                                        DO;
                                                score3 = 0.051585;
                                        END;
                                        /*    x.28/4.31/0.15/0.38/0.2/1    */
                                        ELSE 
                                        DO;
                                                score3 = 0.051585;
                                        END;
                                END;
                                /*    x.28/4.31/0.15/0.38/0    */
                                ELSE 
                                DO;
                                        score3 = 0.045531;
                                END;
                        END;
                        /*    x.28/4.31/0.15/0.38/1    */
                        ELSE IF Grade = 'Graduate' THEN
                        DO;
                                /*    x.28/4.31/0.15/0.38/1.42/0    */
                                IF cat = 'I' THEN
                                DO;
                                        score3 = 0.021735;
                                END;
                                /*    x.28/4.31/0.15/0.38/1    */
                                ELSE 
                                DO;
                                        score3 = 0.021735;
                                END;
                        END;
                        /*    x.28/4.31/0.15/0.38/2    */
                        ELSE IF Grade = 'Junior'
                             OR Grade = 'Senior'
                             OR Grade = 'Sophomore' THEN
                        DO;
                                /*    x.28/4.31/0.15/0.38/2.12/0    */
                                IF COLG_INCM_SOURC_CD = . THEN
                                DO;
                                        /*    x.28/4.31/0.15/0.38/2.12/0.42/0    */
                                        IF cat = '9' THEN
                                        DO;
                                                score3 = 0.043887;
                                        END;
                                        /*    x.28/4.31/0.15/0.38/2.12/0    */
                                        ELSE 
                                        DO;
                                                score3 = 0.043887;
                                        END;
                                END;
                                /*    x.28/4.31/0.15/0.38/2.12/1    */
                                ELSE IF COLG_INCM_SOURC_CD = 'A'
                                     OR COLG_INCM_SOURC_CD = 'V' THEN
                                DO;
                                        /*    x.28/4.31/0.15/0.38/2.12/1.2/0    */
                                        IF INQ_EVER_CT >= 0.000000 AND INQ_EVER_CT < 5.000000 THEN
                                        DO;
                                                /*    x.28/4.31/0.15/0.38/2.12/1.2/0.42/0    */
                                                IF cat = 'E' THEN
                                                DO;
                                                        score3 = 0.039280;
                                                END;
                                                /*    x.28/4.31/0.15/0.38/2.12/1.2/0    */
                                                ELSE 
                                                DO;
                                                        score3 = 0.039280;
                                                END;
                                        END;
                                        /*    x.28/4.31/0.15/0.38/2.12/1.2/1    */
                                        ELSE IF INQ_EVER_CT >= 5.000000 AND INQ_EVER_CT <= 84.000000 THEN
                                        DO;
                                                /*    x.28/4.31/0.15/0.38/2.12/1.2/1.42/0    */
                                                IF cat = 'F' THEN
                                                DO;
                                                        score3 = 0.093494;
                                                END;
                                                /*    x.28/4.31/0.15/0.38/2.12/1.2/1    */
                                                ELSE 
                                                DO;
                                                        score3 = 0.093494;
                                                END;
                                        END;
                                        /*    x.28/4.31/0.15/0.38/2.12/1    */
                                        ELSE 
                                        DO;
                                                score3 = 0.046717;
                                        END;
                                END;
                                /*    x.28/4.31/0.15/0.38/2.12/2    */
                                ELSE IF COLG_INCM_SOURC_CD = 'F'
                                     OR COLG_INCM_SOURC_CD = 'T' THEN
                                DO;
                                        /*    x.28/4.31/0.15/0.38/2.12/2.42/0    */
                                        IF cat = 'G' THEN
                                        DO;
                                                score3 = 0.092282;
                                        END;
                                        /*    x.28/4.31/0.15/0.38/2.12/2    */
                                        ELSE 
                                        DO;
                                                score3 = 0.092282;
                                        END;
                                END;
                                /*    x.28/4.31/0.15/0.38/2.12/3    */
                                ELSE IF COLG_INCM_SOURC_CD = 'P'
                                     OR COLG_INCM_SOURC_CD = 'S' THEN
                                DO;
                                        /*    x.28/4.31/0.15/0.38/2.12/3.42/0    */
                                        IF cat = 'H' THEN
                                        DO;
                                                score3 = 0.034225;
                                        END;
                                        /*    x.28/4.31/0.15/0.38/2.12/3    */
                                        ELSE 
                                        DO;
                                                score3 = 0.034225;
                                        END;
                                END;
                                /*    x.28/4.31/0.15/0.38/2    */
                                ELSE 
                                DO;
                                        score3 = 0.043186;
                                END;
                        END;
                        /*    x.28/4.31/0.15/0    */
                        ELSE 
                        DO;
                                score3 = 0.042713;
                        END;
                END;
                /*    x.28/4.31/0.15/1    */
                ELSE IF TL_CURR_04_09_CT = 1.000000
                     OR TL_CURR_04_09_CT = 2.000000
                     OR TL_CURR_04_09_CT = 3.000000
                     OR TL_CURR_04_09_CT = 4.000000
                     OR TL_CURR_04_09_CT = 5.000000
                     OR TL_CURR_04_09_CT = 6.000000
                     OR TL_CURR_04_09_CT = 7.000000
                     OR TL_CURR_04_09_CT = 8.000000
                     OR TL_CURR_04_09_CT = 11.000000 THEN
                DO;
                        /*    x.28/4.31/0.15/1.42/0    */
                        IF cat = 'J' THEN
                        DO;
                                score3 = 0.258208;
                        END;
                        /*    x.28/4.31/0.15/1    */
                        ELSE 
                        DO;
                                score3 = 0.258208;
                        END;
                END;
                /*    x.28/4.31/0    */
                ELSE 
                DO;
                        score3 = 0.047278;
                END;
        END;
        /*    x.28/4.31/1    */
        ELSE IF bureau_type = 'FBwFICO' THEN
        DO;
                /*    x.28/4.31/1.15/0    */
                IF TL_CURR_04_09_CT = 0.000000 THEN
                DO;
                        /*    x.28/4.31/1.15/0.42/0    */
                        IF cat = 'K' THEN
                        DO;
                                score3 = 0.024849;
                        END;
                        /*    x.28/4.31/1.15/0    */
                        ELSE 
                        DO;
                                score3 = 0.024849;
                        END;
                END;
                /*    x.28/4.31/1.15/1    */
                ELSE IF TL_CURR_04_09_CT = 1.000000 THEN
                DO;
                        /*    x.28/4.31/1.15/1.13/0    */
                        IF SATIS_TL_CT >= 0.000000 AND SATIS_TL_CT < 1.000000
                        OR SATIS_TL_CT >= 1.000000 AND SATIS_TL_CT < 2.000000
                        OR SATIS_TL_CT >= 2.000000 AND SATIS_TL_CT < 3.000000 THEN
                        DO;
                                /*    x.28/4.31/1.15/1.13/0.42/0    */
                                IF cat = 'L' THEN
                                DO;
                                        score3 = 0.114635;
                                END;
                                /*    x.28/4.31/1.15/1.13/0    */
                                ELSE 
                                DO;
                                        score3 = 0.114635;
                                END;
                        END;
                        /*    x.28/4.31/1.15/1.13/1    */
                        ELSE IF SATIS_TL_CT >= 3.000000 AND SATIS_TL_CT < 4.000000
                             OR SATIS_TL_CT >= 4.000000 AND SATIS_TL_CT < 5.000000
                             OR SATIS_TL_CT >= 5.000000 AND SATIS_TL_CT < 6.000000
                             OR SATIS_TL_CT >= 6.000000 AND SATIS_TL_CT < 7.000000
                             OR SATIS_TL_CT >= 7.000000 AND SATIS_TL_CT < 9.000000
                             OR SATIS_TL_CT >= 9.000000 AND SATIS_TL_CT < 12.000000
                             OR SATIS_TL_CT >= 12.000000 AND SATIS_TL_CT <= 63.000000 THEN
                        DO;
                                /*    x.28/4.31/1.15/1.13/1.42/0    */
                                IF cat = 'M' THEN
                                DO;
                                        score3 = 0.045415;
                                END;
                                /*    x.28/4.31/1.15/1.13/1    */
                                ELSE 
                                DO;
                                        score3 = 0.045415;
                                END;
                        END;
                        /*    x.28/4.31/1.15/1    */
                        ELSE 
                        DO;
                                score3 = 0.066439;
                        END;
                END;
                /*    x.28/4.31/1.15/2    */
                ELSE IF TL_CURR_04_09_CT = 2.000000
                     OR TL_CURR_04_09_CT = 3.000000
                     OR TL_CURR_04_09_CT = 4.000000
                     OR TL_CURR_04_09_CT = 5.000000
                     OR TL_CURR_04_09_CT = 6.000000
                     OR TL_CURR_04_09_CT = 7.000000
                     OR TL_CURR_04_09_CT = 8.000000
                     OR TL_CURR_04_09_CT = 9.000000
                     OR TL_CURR_04_09_CT = 10.000000
                     OR TL_CURR_04_09_CT = 11.000000
                     OR TL_CURR_04_09_CT = 12.000000
                     OR TL_CURR_04_09_CT = 13.000000 THEN
                DO;
                        /*    x.28/4.31/1.15/2.42/0    */
                        IF cat = 'N' THEN
                        DO;
                                score3 = 0.125611;
                        END;
                        /*    x.28/4.31/1.15/2    */
                        ELSE 
                        DO;
                                score3 = 0.125611;
                        END;
                END;
                /*    x.28/4.31/1    */
                ELSE 
                DO;
                        score3 = 0.026590;
                END;
        END;
        /*    x.28/4.31/2    */
        ELSE IF bureau_type = 'InqOnly' THEN
        DO;
                /*    x.28/4.31/2.38/0    */
                IF Grade = 'Freshman'
                OR Grade = 'Junior'
                OR Grade = 'Senior'
                OR Grade = 'Sophomore'
                OR Grade = 'Unknown' THEN
                DO;
                        /*    x.28/4.31/2.38/0.12/0    */
                        IF COLG_INCM_SOURC_CD = ' '
                        OR COLG_INCM_SOURC_CD = 'F'
                        OR COLG_INCM_SOURC_CD = 'T' THEN
                        DO;
                                /*    x.28/4.31/2.38/0.12/0.42/0    */
                                IF cat = 'T' THEN
                                DO;
                                        score3 = 0.102384;
                                END;
                                /*    x.28/4.31/2.38/0.12/0    */
                                ELSE 
                                DO;
                                        score3 = 0.102384;
                                END;
                        END;
                        /*    x.28/4.31/2.38/0.12/1    */
                        ELSE IF COLG_INCM_SOURC_CD = 'A'
                             OR COLG_INCM_SOURC_CD = 'P'
                             OR COLG_INCM_SOURC_CD = 'S'
                             OR COLG_INCM_SOURC_CD = 'V' THEN
                        DO;
                                /*    x.28/4.31/2.38/0.12/1.15/0    */
                                IF TL_CURR_04_09_CT = 0.000000 THEN
                                DO;
                                        /*    x.28/4.31/2.38/0.12/1.15/0.42/0    */
                                        IF cat = '9' THEN
                                        DO;
                                                score3 = 0.050209;
                                        END;
                                        /*    x.28/4.31/2.38/0.12/1.15/0.42/1    */
                                        ELSE IF cat = 'O' THEN
                                        DO;
                                                score3 = 0.034824;
                                        END;
                                        /*    x.28/4.31/2.38/0.12/1.15/0.42/2    */
                                        ELSE IF cat = 'P' THEN
                                        DO;
                                                score3 = 0.035346;
                                        END;
                                        /*    x.28/4.31/2.38/0.12/1.15/0.42/3    */
                                        ELSE IF cat = 'Q' THEN
                                        DO;
                                                score3 = 0.048231;
                                        END;
                                        /*    x.28/4.31/2.38/0.12/1.15/0.42/4    */
                                        ELSE IF cat = 'R' THEN
                                        DO;
                                                score3 = 0.070973;
                                        END;
                                        /*    x.28/4.31/2.38/0.12/1.15/0    */
                                        ELSE 
                                        DO;
                                                score3 = 0.054802;
                                        END;
                                END;
                                /*    x.28/4.31/2.38/0.12/1.15/1    */
                                ELSE IF TL_CURR_04_09_CT = 1.000000
                                     OR TL_CURR_04_09_CT = 2.000000
                                     OR TL_CURR_04_09_CT = 3.000000
                                     OR TL_CURR_04_09_CT = 7.000000
                                     OR TL_CURR_04_09_CT = 8.000000 THEN
                                DO;
                                        /*    x.28/4.31/2.38/0.12/1.15/1.42/0    */
                                        IF cat = 'S' THEN
                                        DO;
                                                score3 = 0.367147;
                                        END;
                                        /*    x.28/4.31/2.38/0.12/1.15/1    */
                                        ELSE 
                                        DO;
                                                score3 = 0.367147;
                                        END;
                                END;
                                /*    x.28/4.31/2.38/0.12/1    */
                                ELSE 
                                DO;
                                        score3 = 0.055586;
                                END;
                        END;
                        /*    x.28/4.31/2.38/0    */
                        ELSE 
                        DO;
                                score3 = 0.061923;
                        END;
                END;
                /*    x.28/4.31/2.38/1    */
                ELSE IF Grade = 'Graduate' THEN
                DO;
                        /*    x.28/4.31/2.38/1.42/0    */
                        IF cat = 'U' THEN
                        DO;
                                score3 = 0.033296;
                        END;
                        /*    x.28/4.31/2.38/1    */
                        ELSE 
                        DO;
                                score3 = 0.033296;
                        END;
                END;
                /*    x.28/4.31/2    */
                ELSE 
                DO;
                        score3 = 0.059100;
                END;
        END;
        /*    x.28/4.31/3    */
        ELSE IF bureau_type = 'NoBureau' THEN
        DO;
                /*    x.28/4.31/3.12/0    */
                IF COLG_INCM_SOURC_CD = . THEN
                DO;
                        /*    x.28/4.31/3.12/0.42/0    */
                        IF cat = '9' THEN
                        DO;
                                score3 = 0.064603;
                        END;
                        /*    x.28/4.31/3.12/0.42/1    */
                        ELSE IF cat = 'K' THEN
                        DO;
                                score3 = 1.000000;
                        END;
                        /*    x.28/4.31/3.12/0.42/2    */
                        ELSE IF cat = 'Z' THEN
                        DO;
                                score3 = 0.011565;
                        END;
                        /*    x.28/4.31/3.12/0    */
                        ELSE 
                        DO;
                                score3 = 0.030012;
                        END;
                END;
                /*    x.28/4.31/3.12/1    */
                ELSE IF COLG_INCM_SOURC_CD = 'A'
                     OR COLG_INCM_SOURC_CD = 'T'
                     OR COLG_INCM_SOURC_CD = 'V' THEN
                DO;
                        /*    x.28/4.31/3.12/1.38/0    */
                        IF Grade = 'Freshman'
                        OR Grade = 'Junior'
                        OR Grade = 'Senior'
                        OR Grade = 'Sophomore'
                        OR Grade = 'Unknown' THEN
                        DO;
                                /*    x.28/4.31/3.12/1.38/0.42/0    */
                                IF cat = 'K' THEN
                                DO;
                                        score3 = 0.000000;
                                END;
                                /*    x.28/4.31/3.12/1.38/0.42/1    */
                                ELSE IF cat = 'V' THEN
                                DO;
                                        score3 = 0.052966;
                                END;
                                /*    x.28/4.31/3.12/1.38/0.42/2    */
                                ELSE IF cat = 'Z' THEN
                                DO;
                                        score3 = 0.008220;
                                END;
                                /*    x.28/4.31/3.12/1.38/0    */
                                ELSE 
                                DO;
                                        score3 = 0.020187;
                                END;
                        END;
                        /*    x.28/4.31/3.12/1.38/1    */
                        ELSE IF Grade = 'Graduate' THEN
                        DO;
                                /*    x.28/4.31/3.12/1.38/1.42/0    */
                                IF cat = 'W' THEN
                                DO;
                                        score3 = 0.008960;
                                END;
                                /*    x.28/4.31/3.12/1.38/1.42/1    */
                                ELSE IF cat = 'Z' THEN
                                DO;
                                        score3 = 0.003118;
                                END;
                                /*    x.28/4.31/3.12/1.38/1    */
                                ELSE 
                                DO;
                                        score3 = 0.004127;
                                END;
                        END;
                        /*    x.28/4.31/3.12/1    */
                        ELSE 
                        DO;
                                score3 = 0.018584;
                        END;
                END;
                /*    x.28/4.31/3.12/2    */
                ELSE IF COLG_INCM_SOURC_CD = 'F' THEN
                DO;
                        /*    x.28/4.31/3.12/2.42/0    */
                        IF cat = 'X' THEN
                        DO;
                                score3 = 0.121617;
                        END;
                        /*    x.28/4.31/3.12/2.42/1    */
                        ELSE IF cat = 'Z' THEN
                        DO;
                                score3 = 0.016508;
                        END;
                        /*    x.28/4.31/3.12/2    */
                        ELSE 
                        DO;
                                score3 = 0.036916;
                        END;
                END;
                /*    x.28/4.31/3.12/3    */
                ELSE IF COLG_INCM_SOURC_CD = 'P'
                     OR COLG_INCM_SOURC_CD = 'S' THEN
                DO;
                        /*    x.28/4.31/3.12/3.42/0    */
                        IF cat = 'Y' THEN
                        DO;
                                score3 = 0.052890;
                        END;
                        /*    x.28/4.31/3.12/3.42/1    */
                        ELSE IF cat = 'Z' THEN
                        DO;
                                score3 = 0.007589;
                        END;
                        /*    x.28/4.31/3.12/3    */
                        ELSE 
                        DO;
                                score3 = 0.016850;
                        END;
                END;
                /*    x.28/4.31/3    */
                ELSE 
                DO;
                        score3 = 0.019299;
                END;
        END;
        /*    x.28/4    */
        ELSE 
        DO;
                score3 = 0.031451;
        END;
END;
/*    x.28/5    */
ELSE IF channel = 'Take On' THEN
DO;
        score3 = 0.038098;
END;
/*    x    */
ELSE 
DO;
        score3 = 0.031648;
END;

%put*****************all channel old chaid ****************************;
IF bureau_type = 'FBnoFICO' THEN
DO;
        /*    x.31/0.15/0    */
        IF TL_CURR_04_09_CT = 0.000000 THEN
        DO;
                /*    x.31/0.15/0.38/0    */
                IF Grade = 'Freshman'
                OR Grade = 'Unknown' THEN
                DO;
                        /*    x.31/0.15/0.38/0.2/0    */
                        IF INQ_EVER_CT >= 0.000000 AND INQ_EVER_CT < 3.000000 THEN
                        DO;
                                /*    x.31/0.15/0.38/0.2/0.42/0    */
                                IF cat = 'A' THEN
                                DO;
                                        score4 = 0.032904;
                                END;
                                /*    x.31/0.15/0.38/0.2/0.42/1    */
                                ELSE IF cat = 'B' THEN
                                DO;
                                        score4 = 0.050480;
                                END;
                                /*    x.31/0.15/0.38/0.2/0.42/2    */
                                ELSE IF cat = 'C' THEN
                                DO;
                                        score4 = 0.084322;
                                END;
                                /*    x.31/0.15/0.38/0.2/0    */
                                ELSE 
                                DO;
                                        score4 = 0.040552;
                                END;
                        END;
                        /*    x.31/0.15/0.38/0.2/1    */
                        ELSE IF INQ_EVER_CT >= 3.000000 AND INQ_EVER_CT <= 84.000000 THEN
                        DO;
                                /*    x.31/0.15/0.38/0.2/1.42/0    */
                                IF cat = 'D' THEN
                                DO;
                                        score4 = 0.059682;
                                END;
                                /*    x.31/0.15/0.38/0.2/1    */
                                ELSE 
                                DO;
                                        score4 = 0.059682;
                                END;
                        END;
                        /*    x.31/0.15/0.38/0    */
                        ELSE 
                        DO;
                                score4 = 0.048503;
                        END;
                END;
                /*    x.31/0.15/0.38/1    */
                ELSE IF Grade = 'Graduate' THEN
                DO;
                        /*    x.31/0.15/0.38/1.42/0    */
                        IF cat = 'I' THEN
                        DO;
                                score4 = 0.016238;
                        END;
                        /*    x.31/0.15/0.38/1    */
                        ELSE 
                        DO;
                                score4 = 0.016238;
                        END;
                END;
                /*    x.31/0.15/0.38/2    */
                ELSE IF Grade = 'Junior'
                     OR Grade = 'Senior'
                     OR Grade = 'Sophomore' THEN
                DO;
                        /*    x.31/0.15/0.38/2.12/0    */
                        IF COLG_INCM_SOURC_CD = . THEN
                        DO;
                                /*    x.31/0.15/0.38/2.12/0.42/0    */
                                IF cat = '9' THEN
                                DO;
                                        score4 = 0.046295;
                                END;
                                /*    x.31/0.15/0.38/2.12/0    */
                                ELSE 
                                DO;
                                        score4 = 0.046295;
                                END;
                        END;
                        /*    x.31/0.15/0.38/2.12/1    */
                        ELSE IF COLG_INCM_SOURC_CD = 'A'
                             OR COLG_INCM_SOURC_CD = 'V' THEN
                        DO;
                                /*    x.31/0.15/0.38/2.12/1.2/0    */
                                IF INQ_EVER_CT >= 0.000000 AND INQ_EVER_CT < 5.000000 THEN
                                DO;
                                        /*    x.31/0.15/0.38/2.12/1.2/0.42/0    */
                                        IF cat = 'E' THEN
                                        DO;
                                                score4 = 0.042330;
                                        END;
                                        /*    x.31/0.15/0.38/2.12/1.2/0    */
                                        ELSE 
                                        DO;
                                                score4 = 0.042330;
                                        END;
                                END;
                                /*    x.31/0.15/0.38/2.12/1.2/1    */
                                ELSE IF INQ_EVER_CT >= 5.000000 AND INQ_EVER_CT <= 84.000000 THEN
                                DO;
                                        /*    x.31/0.15/0.38/2.12/1.2/1.42/0    */
                                        IF cat = 'F' THEN
                                        DO;
                                                score4 = 0.106620;
                                        END;
                                        /*    x.31/0.15/0.38/2.12/1.2/1    */
                                        ELSE 
                                        DO;
                                                score4 = 0.106620;
                                        END;
                                END;
                                /*    x.31/0.15/0.38/2.12/1    */
                                ELSE 
                                DO;
                                        score4 = 0.050662;
                                END;
                        END;
                        /*    x.31/0.15/0.38/2.12/2    */
                        ELSE IF COLG_INCM_SOURC_CD = 'F'
                             OR COLG_INCM_SOURC_CD = 'T' THEN
                        DO;
                                /*    x.31/0.15/0.38/2.12/2.42/0    */
                                IF cat = 'G' THEN
                                DO;
                                        score4 = 0.097712;
                                END;
                                /*    x.31/0.15/0.38/2.12/2    */
                                ELSE 
                                DO;
                                        score4 = 0.097712;
                                END;
                        END;
                        /*    x.31/0.15/0.38/2.12/3    */
                        ELSE IF COLG_INCM_SOURC_CD = 'P'
                             OR COLG_INCM_SOURC_CD = 'S' THEN
                        DO;
                                /*    x.31/0.15/0.38/2.12/3.42/0    */
                                IF cat = 'H' THEN
                                DO;
                                        score4 = 0.036709;
                                END;
                                /*    x.31/0.15/0.38/2.12/3    */
                                ELSE 
                                DO;
                                        score4 = 0.036709;
                                END;
                        END;
                        /*    x.31/0.15/0.38/2    */
                        ELSE 
                        DO;
                                score4 = 0.046265;
                        END;
                END;
                /*    x.31/0.15/0    */
                ELSE 
                DO;
                        score4 = 0.043226;
                END;
        END;
        /*    x.31/0.15/1    */
        ELSE IF TL_CURR_04_09_CT = 1.000000
             OR TL_CURR_04_09_CT = 2.000000
             OR TL_CURR_04_09_CT = 3.000000
             OR TL_CURR_04_09_CT = 4.000000
             OR TL_CURR_04_09_CT = 5.000000
             OR TL_CURR_04_09_CT = 6.000000
             OR TL_CURR_04_09_CT = 7.000000
             OR TL_CURR_04_09_CT = 8.000000
             OR TL_CURR_04_09_CT = 11.000000 THEN
        DO;
                /*    x.31/0.15/1.42/0    */
                IF cat = 'J' THEN
                DO;
                        score4 = 0.239507;
                END;
                /*    x.31/0.15/1    */
                ELSE 
                DO;
                        score4 = 0.239507;
                END;
        END;
        /*    x.31/0    */
        ELSE 
        DO;
                score4 = 0.047295;
        END;
END;
/*    x.31/1    */
ELSE IF bureau_type = 'FBwFICO' THEN
DO;
        /*    x.31/1.15/0    */
        IF TL_CURR_04_09_CT = 0.000000 THEN
        DO;
                /*    x.31/1.15/0.42/0    */
                IF cat = 'K' THEN
                DO;
                        score4 = 0.024755;
                END;
                /*    x.31/1.15/0    */
                ELSE 
                DO;
                        score4 = 0.024755;
                END;
        END;
        /*    x.31/1.15/1    */
        ELSE IF TL_CURR_04_09_CT = 1.000000 THEN
        DO;
                /*    x.31/1.15/1.13/0    */
                IF SATIS_TL_CT >= 0.000000 AND SATIS_TL_CT < 3.000000 THEN
                DO;
                        /*    x.31/1.15/1.13/0.42/0    */
                        IF cat = 'L' THEN
                        DO;
                                score4 = 0.105662;
                        END;
                        /*    x.31/1.15/1.13/0    */
                        ELSE 
                        DO;
                                score4 = 0.105662;
                        END;
                END;
                /*    x.31/1.15/1.13/1    */
                ELSE IF SATIS_TL_CT >= 3.000000 AND SATIS_TL_CT <= 63.000000 THEN
                DO;
                        /*    x.31/1.15/1.13/1.42/0    */
                        IF cat = 'M' THEN
                        DO;
                                score4 = 0.044500;
                        END;
                        /*    x.31/1.15/1.13/1    */
                        ELSE 
                        DO;
                                score4 = 0.044500;
                        END;
                END;
                /*    x.31/1.15/1    */
                ELSE 
                DO;
                        score4 = 0.060273;
                END;
        END;
        /*    x.31/1.15/2    */
        ELSE IF TL_CURR_04_09_CT = 2.000000
             OR TL_CURR_04_09_CT = 3.000000
             OR TL_CURR_04_09_CT = 4.000000
             OR TL_CURR_04_09_CT = 5.000000
             OR TL_CURR_04_09_CT = 6.000000
             OR TL_CURR_04_09_CT = 7.000000
             OR TL_CURR_04_09_CT = 8.000000
             OR TL_CURR_04_09_CT = 9.000000
             OR TL_CURR_04_09_CT = 10.000000
             OR TL_CURR_04_09_CT = 11.000000
             OR TL_CURR_04_09_CT = 12.000000
             OR TL_CURR_04_09_CT = 13.000000 THEN
        DO;
                /*    x.31/1.15/2.42/0    */
                IF cat = 'N' THEN
                DO;
                        score4 = 0.092057;
                END;
                /*    x.31/1.15/2    */
                ELSE 
                DO;
                        score4 = 0.092057;
                END;
        END;
        /*    x.31/1    */
        ELSE 
        DO;
                score4 = 0.026813;
        END;
END;
/*    x.31/2    */
ELSE IF bureau_type = 'InqOnly' THEN
DO;
        /*    x.31/2.38/0    */
        IF Grade = 'Freshman'
        OR Grade = 'Junior'
        OR Grade = 'Senior'
        OR Grade = 'Sophomore'
        OR Grade = 'Unknown' THEN
        DO;
                /*    x.31/2.38/0.12/0    */
                IF COLG_INCM_SOURC_CD = ' '
                OR COLG_INCM_SOURC_CD = 'F'
                OR COLG_INCM_SOURC_CD = 'T' THEN
                DO;
                        /*    x.31/2.38/0.12/0.42/0    */
                        IF cat = 'T' THEN
                        DO;
                                score4 = 0.097378;
                        END;
                        /*    x.31/2.38/0.12/0    */
                        ELSE 
                        DO;
                                score4 = 0.097378;
                        END;
                END;
                /*    x.31/2.38/0.12/1    */
                ELSE IF COLG_INCM_SOURC_CD = 'A'
                     OR COLG_INCM_SOURC_CD = 'P'
                     OR COLG_INCM_SOURC_CD = 'S'
                     OR COLG_INCM_SOURC_CD = 'V' THEN
                DO;
                        /*    x.31/2.38/0.12/1.15/0    */
                        IF TL_CURR_04_09_CT = 0.000000 THEN
                        DO;
                                /*    x.31/2.38/0.12/1.15/0.42/0    */
                                IF cat = '9' THEN
                                DO;
                                        score4 = 0.053281;
                                END;
                                /*    x.31/2.38/0.12/1.15/0.42/1    */
                                ELSE IF cat = 'O' THEN
                                DO;
                                        score4 = 0.032712;
                                END;
                                /*    x.31/2.38/0.12/1.15/0.42/2    */
                                ELSE IF cat = 'P' THEN
                                DO;
                                        score4 = 0.030773;
                                END;
                                /*    x.31/2.38/0.12/1.15/0.42/3    */
                                ELSE IF cat = 'Q' THEN
                                DO;
                                        score4 = 0.050319;
                                END;
                                /*    x.31/2.38/0.12/1.15/0.42/4    */
                                ELSE IF cat = 'R' THEN
                                DO;
                                        score4 = 0.069924;
                                END;
                                /*    x.31/2.38/0.12/1.15/0    */
                                ELSE 
                                DO;
                                        score4 = 0.054470;
                                END;
                        END;
                        /*    x.31/2.38/0.12/1.15/1    */
                        ELSE IF TL_CURR_04_09_CT = 1.000000
                             OR TL_CURR_04_09_CT = 2.000000
                             OR TL_CURR_04_09_CT = 3.000000
                             OR TL_CURR_04_09_CT = 7.000000
                             OR TL_CURR_04_09_CT = 8.000000 THEN
                        DO;
                                /*    x.31/2.38/0.12/1.15/1.42/0    */
                                IF cat = 'S' THEN
                                DO;
                                        score4 = 0.245216;
                                END;
                                /*    x.31/2.38/0.12/1.15/1    */
                                ELSE 
                                DO;
                                        score4 = 0.245216;
                                END;
                        END;
                        /*    x.31/2.38/0.12/1    */
                        ELSE 
                        DO;
                                score4 = 0.055200;
                        END;
                END;
                /*    x.31/2.38/0    */
                ELSE 
                DO;
                        score4 = 0.061817;
                END;
        END;
        /*    x.31/2.38/1    */
        ELSE IF Grade = 'Graduate' THEN
        DO;
                /*    x.31/2.38/1.42/0    */
                IF cat = 'U' THEN
                DO;
                        score4 = 0.023013;
                END;
                /*    x.31/2.38/1    */
                ELSE 
                DO;
                        score4 = 0.023013;
                END;
        END;
        /*    x.31/2    */
        ELSE 
        DO;
                score4 = 0.056169;
        END;
END;
/*    x.31/3    */
ELSE IF bureau_type = 'NoBureau' THEN
DO;
        /*    x.31/3.12/0    */
        IF COLG_INCM_SOURC_CD = . THEN
        DO;
                /*    x.31/3.12/0.42/0    */
                IF cat = '9' THEN
                DO;
                        score4 = 0.041270;
                END;
                /*    x.31/3.12/0.42/1    */
                ELSE IF cat = 'K' THEN
                DO;
                        score4 = 1.000000;
                END;
                /*    x.31/3.12/0.42/2    */
                ELSE IF cat = 'Z' THEN
                DO;
                        score4 = 0.022194;
                END;
                /*    x.31/3.12/0    */
                ELSE 
                DO;
                        score4 = 0.029814;
                END;
        END;
        /*    x.31/3.12/1    */
        ELSE IF COLG_INCM_SOURC_CD = 'A'
             OR COLG_INCM_SOURC_CD = 'T'
             OR COLG_INCM_SOURC_CD = 'V' THEN
        DO;
                /*    x.31/3.12/1.38/0    */
                IF Grade = 'Freshman'
                OR Grade = 'Junior'
                OR Grade = 'Senior'
                OR Grade = 'Sophomore'
                OR Grade = 'Unknown' THEN
                DO;
                        /*    x.31/3.12/1.38/0.42/0    */
                        IF cat = 'K' THEN
                        DO;
                                score4 = 0.000000;
                        END;
                        /*    x.31/3.12/1.38/0.42/1    */
                        ELSE IF cat = 'V' THEN
                        DO;
                                score4 = 0.049444;
                        END;
                        /*    x.31/3.12/1.38/0.42/2    */
                        ELSE IF cat = 'Z' THEN
                        DO;
                                score4 = 0.008297;
                        END;
                        /*    x.31/3.12/1.38/0    */
                        ELSE 
                        DO;
                                score4 = 0.021025;
                        END;
                END;
                /*    x.31/3.12/1.38/1    */
                ELSE IF Grade = 'Graduate' THEN
                DO;
                        /*    x.31/3.12/1.38/1.42/0    */
                        IF cat = 'W' THEN
                        DO;
                                score4 = 0.007478;
                        END;
                        /*    x.31/3.12/1.38/1.42/1    */
                        ELSE IF cat = 'Z' THEN
                        DO;
                                score4 = 0.003118;
                        END;
                        /*    x.31/3.12/1.38/1    */
                        ELSE 
                        DO;
                                score4 = 0.004401;
                        END;
                END;
                /*    x.31/3.12/1    */
                ELSE 
                DO;
                        score4 = 0.019211;
                END;
        END;
        /*    x.31/3.12/2    */
        ELSE IF COLG_INCM_SOURC_CD = 'F' THEN
        DO;
                /*    x.31/3.12/2.42/0    */
                IF cat = 'X' THEN
                DO;
                        score4 = 0.095531;
                END;
                /*    x.31/3.12/2.42/1    */
                ELSE IF cat = 'Z' THEN
                DO;
                        score4 = 0.016508;
                END;
                /*    x.31/3.12/2    */
                ELSE 
                DO;
                        score4 = 0.045889;
                END;
        END;
        /*    x.31/3.12/3    */
        ELSE IF COLG_INCM_SOURC_CD = 'P'
             OR COLG_INCM_SOURC_CD = 'S' THEN
        DO;
                /*    x.31/3.12/3.42/0    */
                IF cat = 'Y' THEN
                DO;
                        score4 = 0.031343;
                END;
                /*    x.31/3.12/3.42/1    */
                ELSE IF cat = 'Z' THEN
                DO;
                        score4 = 0.007589;
                END;
                /*    x.31/3.12/3    */
                ELSE 
                DO;
                        score4 = 0.017764;
                END;
        END;
        /*    x.31/3    */
        ELSE 
        DO;
                score4 = 0.020845;
        END;
END;
/*    x    */
ELSE 
DO;
        score4 = 0.031648;
END;

%put ******************* New Chaid v2 *********************************************;

/*    x.31/0    */
IF bureau_type = 'FBnoFICO'
OR bureau_type = 'InqOnly' THEN
DO;
        /*    x.31/0.15/0    */
        IF TL_CURR_04_09_CT = 0.000000 THEN
        DO;
                /*    x.31/0.15/0.37/0    */
                IF School = '2'
                OR School = 'E'
                OR School = 'F'
                OR School = 'G'
                OR School = 'L'
                OR School = 'M'
                OR School = 'N'
                OR School = 'O'
                OR School = 'V' THEN
                DO;
                        score5= 0.100064;
                        catv2=1;
                END;
                /*    x.31/0.15/0.37/1    */
                ELSE IF School = 'A'
                     OR School = 'B'
                     OR School = 'C'
                     OR School = 'D'
                     OR School = 'R'
                     OR School = 'T'
                     OR School = 'x' THEN
                DO;
                        /*    x.31/0.15/0.37/1.38/0    */
                        IF Grade = 'Freshman'
                        OR Grade = 'Junior'
                        OR Grade = 'Senior'
                        OR Grade = 'Sophomor'
                        OR Grade = 'Unknown' THEN
                        DO;
                                /*    x.31/0.15/0.37/1.38/0.12/0    */
                                IF COLG_INCM_SOURC_CD = ' '
                                OR COLG_INCM_SOURC_CD = 'A'
                                OR COLG_INCM_SOURC_CD = 'P'
                                OR COLG_INCM_SOURC_CD = 'S'
                                OR COLG_INCM_SOURC_CD = 'T'
                                OR COLG_INCM_SOURC_CD = 'V' THEN
                                DO;
                                        /*    x.31/0.15/0.37/1.38/0.12/0.28/0    */
                                        IF channel = 'Interne'
                                        OR channel = 'Take On' THEN
                                        DO;
                                                score5= 0.088494;
                                                catv2=2;
                                        END;
                                        /*    x.31/0.15/0.37/1.38/0.12/0.28/1    */
                                        ELSE IF channel = 'NPS'
                                             OR channel = 'OBTM'
                                             OR channel = 'Other'
                                             OR channel = 'Tabling' THEN
                                        DO;
                                                /*    x.31/0.15/0.37/1.38/0.12/0.28/1.19/0    */
                                                IF COLG_STATE_CD = ' '
                                                OR COLG_STATE_CD = 0.000000
                                                OR COLG_STATE_CD = 'AZ'
                                                OR COLG_STATE_CD = 'CA'
                                                OR COLG_STATE_CD = 'CO'
                                                OR COLG_STATE_CD = 'CT'
                                                OR COLG_STATE_CD = 'DE'
                                                OR COLG_STATE_CD = 'IA'
                                                OR COLG_STATE_CD = 'ID'
                                                OR COLG_STATE_CD = 'IL'
                                                OR COLG_STATE_CD = 'IN'
                                                OR COLG_STATE_CD = 'KY'
                                                OR COLG_STATE_CD = 'LA'
                                                OR COLG_STATE_CD = 'MD'
                                                OR COLG_STATE_CD = 'MI'
                                                OR COLG_STATE_CD = 'MN'
                                                OR COLG_STATE_CD = 'MO'
                                                OR COLG_STATE_CD = 'MT'
                                                OR COLG_STATE_CD = 'NC'
                                                OR COLG_STATE_CD = 'ND'
                                                OR COLG_STATE_CD = 'NE'
                                                OR COLG_STATE_CD = 'NH'
                                                OR COLG_STATE_CD = 'NM'
                                                OR COLG_STATE_CD = 'NY'
                                                OR COLG_STATE_CD = 'OH'
                                                OR COLG_STATE_CD = 'OR'
                                                OR COLG_STATE_CD = 'PA'
                                                OR COLG_STATE_CD = 'RI'
                                                OR COLG_STATE_CD = 'SD'
                                                OR COLG_STATE_CD = 'TN'
                                                OR COLG_STATE_CD = 'TX'
                                                OR COLG_STATE_CD = 'VA'
                                                OR COLG_STATE_CD = 'VT'
                                                OR COLG_STATE_CD = 'WA'
                                                OR COLG_STATE_CD = 'WI' 
                                                OR COLG_STATE_CD = 'ME' THEN
                                                DO;
                                                        /*    x.31/0.15/0.37/1.38/0.12/0.28/1.19/0.9/0    */
                                                        IF COLG_TIER_CD = '0'
                                                        OR COLG_TIER_CD = '6'
                                                        OR COLG_TIER_CD = '8'
                                                        OR COLG_TIER_CD = '9'
                                                        OR COLG_TIER_CD = 'F'
                                                        OR COLG_TIER_CD = 'G'
                                                        OR COLG_TIER_CD = 'T' THEN
                                                        DO;
                                                                score5= 0.065192;
                                                                catv2=3;
                                                        END;
                                                        /*    x.31/0.15/0.37/1.38/0.12/0.28/1.19/0.9/1    */
                                                        ELSE IF COLG_TIER_CD = '1'
                                                             OR COLG_TIER_CD = '2'
                                                             OR COLG_TIER_CD = '3'
                                                             OR COLG_TIER_CD = '4'
                                                             OR COLG_TIER_CD = '5' THEN
                                                        DO;
                                                                score5= 0.038675;
                                                                catv2=4;
                                                        END;
                                                        /*    x.31/0.15/0.37/1.38/0.12/0.28/1.19/0    */
                                                        ELSE 
                                                        DO;
                                                                score5= 0.040241;
                                                                catv2=0;
                                                        END;
                                                END;
                                                /*    x.31/0.15/0.37/1.38/0.12/0.28/1.19/1    */
                                                ELSE IF COLG_STATE_CD = 'AL'
                                                     OR COLG_STATE_CD = 'AR'
                                                     OR COLG_STATE_CD = 'DC'
                                                     OR COLG_STATE_CD = 'FL'
                                                     OR COLG_STATE_CD = 'GA'
                                                     OR COLG_STATE_CD = 'HI'
                                                     OR COLG_STATE_CD = 'KS'
                                                     OR COLG_STATE_CD = 'MA'
                                                     OR COLG_STATE_CD = 'MS'
                                                     OR COLG_STATE_CD = 'NJ'
                                                     OR COLG_STATE_CD = 'OK'
                                                     OR COLG_STATE_CD = 'SC'
                                                     OR COLG_STATE_CD = 'UT'
                                                     OR COLG_STATE_CD = 'WV' 
                                                     OR COLG_STATE_CD = 'WY' THEN
                                                DO;
                                                        score5= 0.101849;
                                                        catv2=5;
                                                END;
                                                /*    x.31/0.15/0.37/1.38/0.12/0.28/1    */
                                                ELSE 
                                                DO;
                                                        score5= 0.042312;
                                                        catv2=0;
                                                END;
                                        END;
                                        /*    x.31/0.15/0.37/1.38/0.12/0    */
                                        ELSE 
                                        DO;
                                                score5= 0.044220;
                                                catv2=0;
                                        END;
                                END;
                                /*    x.31/0.15/0.37/1.38/0.12/1    */
                                ELSE IF COLG_INCM_SOURC_CD = 'F' THEN
                                DO;
                                        score5= 0.129875;
                                        catv2=6;
                                END;
                                /*    x.31/0.15/0.37/1.38/0    */
                                ELSE 
                                DO;
                                        score5= 0.047159;
                                        catv2=0;
                                END;
                        END;
                        /*    x.31/0.15/0.37/1.38/1    */
                        ELSE IF Grade = 'Graduate' THEN
                        DO;
                                score5= 0.018719;
                                catv2=7;
                        END;
                        /*    x.31/0.15/0.37/1    */
                        ELSE 
                        DO;
                                score5= 0.042669;
                                catv2=0;
                        END;
                END;
                /*    x.31/0.15/0    */
                ELSE 
                DO;
                        score5= 0.049625;
                        catv2=0;
                END;
        END;
        /*    x.31/0.15/1    */
        ELSE IF TL_CURR_04_09_CT >= 1.000000 THEN
        DO;
                score5= 0.268483;
                catv2=8;
        END;
        /*    x.31/0    */
        ELSE 
        DO;
                score5= 0.051883;
                catv2=0;
        END;
END;
/*    x.31/1    */
ELSE IF bureau_type = 'FBwFICO' THEN
DO;
        /*    x.31/1.15/0    */
        IF TL_CURR_04_09_CT = 0.000000 THEN
        DO;
                /*    x.31/1.15/0.27/0    */
                IF TL_RVLV_BAL_AMT >= 0.000000 AND TL_RVLV_BAL_AMT < 1.000000 THEN
                DO;
                        /*    x.31/1.15/0.27/0.37/0    */
                        IF School = '2'
                        OR School = 'N'
                        OR School = 'O'
                        OR School = 'R' THEN
                        DO;
                                score5= 0.060615;
                                catv2=9;
                        END;
                        /*    x.31/1.15/0.27/0.37/1    */
                        ELSE IF School = 'A'
                             OR School = 'B'
                             OR School = 'C'
                             OR School = 'D'
                             OR School = 'E'
                             OR School = 'F'
                             OR School = 'G'
                             OR School = 'L'
                             OR School = 'M'
                             OR School = 'T'
                             OR School = 'V'
                             OR School = 'x' THEN
                        DO;
                                score5= 0.028079;
                                catv2=10;
                        END;
                        /*    x.31/1.15/0.27/0    */
                        ELSE 
                        DO;
                                score5= 0.029325;
                                catv2=0;
                        END;
                END;
                /*    x.31/1.15/0.27/1    */
                ELSE IF TL_RVLV_BAL_AMT >= 1.000000 AND TL_RVLV_BAL_AMT < 450.000000 THEN
                DO;
                        /*    x.31/1.15/0.27/1.25/0    */
                        IF TL_EVER_04_08_CT = 0.000000 THEN
                        DO;
                                /*    x.31/1.15/0.27/1.25/0.10/0    */
                                IF MAIL_TO_CD = 'H' THEN
                                DO;
                                        score5= 0.015690;
                                        catv2=11;
                                END;
                                /*    x.31/1.15/0.27/1.25/0.10/1    */
                                ELSE IF MAIL_TO_CD = 'S' THEN
                                DO;
                                        /*    x.31/1.15/0.27/1.25/0.10/1.19/0    */
                                        IF COLG_STATE_CD = 0.000000
                                        OR COLG_STATE_CD = 'AR'
                                        OR COLG_STATE_CD = 'CA'
                                        OR COLG_STATE_CD = 'CO'
                                        OR COLG_STATE_CD = 'DE'
                                        OR COLG_STATE_CD = 'GA'
                                        OR COLG_STATE_CD = 'IA'
                                        OR COLG_STATE_CD = 'IL'
                                        OR COLG_STATE_CD = 'IN'
                                        OR COLG_STATE_CD = 'MD'
                                        OR COLG_STATE_CD = 'MO'
                                        OR COLG_STATE_CD = 'MS'
                                        OR COLG_STATE_CD = 'MT'
                                        OR COLG_STATE_CD = 'ND'
                                        OR COLG_STATE_CD = 'NE'
                                        OR COLG_STATE_CD = 'NM'
                                        OR COLG_STATE_CD = 'NY'
                                        OR COLG_STATE_CD = 'OH'
                                        OR COLG_STATE_CD = 'SD'
                                        OR COLG_STATE_CD = 'TX'
                                        OR COLG_STATE_CD = 'UT'
                                        OR COLG_STATE_CD = 'VA'
                                        OR COLG_STATE_CD = 'VT'
                                        OR COLG_STATE_CD = 'WA'
                                        OR COLG_STATE_CD = 'WI' THEN
                                        DO;
                                                score5= 0.020560;
                                                catv2=12;
                                        END;
                                        /*    x.31/1.15/0.27/1.25/0.10/1.19/1    */
                                        ELSE IF COLG_STATE_CD = 'AL'
                                             OR COLG_STATE_CD = 'AZ'
                                             OR COLG_STATE_CD = 'CT'
                                             OR COLG_STATE_CD = 'DC'
                                             OR COLG_STATE_CD = 'FL'
                                             OR COLG_STATE_CD = 'ID'
                                             OR COLG_STATE_CD = 'KS'
                                             OR COLG_STATE_CD = 'KY'
                                             OR COLG_STATE_CD = 'LA'
                                             OR COLG_STATE_CD = 'MA'
                                             OR COLG_STATE_CD = 'ME'
                                             OR COLG_STATE_CD = 'MI'
                                             OR COLG_STATE_CD = 'MN'
                                             OR COLG_STATE_CD = 'NC'
                                             OR COLG_STATE_CD = 'NH'
                                             OR COLG_STATE_CD = 'NJ'
                                             OR COLG_STATE_CD = 'OK'
                                             OR COLG_STATE_CD = 'OR'
                                             OR COLG_STATE_CD = 'PA'
                                             OR COLG_STATE_CD = 'RI'
                                             OR COLG_STATE_CD = 'SC'
                                             OR COLG_STATE_CD = 'TN'
                                             OR COLG_STATE_CD = 'WV' 
                                             OR COLG_STATE_CD = 'WY' THEN
                                        DO;
                                                /*    x.31/1.15/0.27/1.25/0.10/1.19/1.30/0    */
                                                IF portfid = 'AA'
                                                OR portfid = 'click'
                                                OR portfid = 'dividend'
                                                OR portfid = 'driver'
                                                OR portfid = 'sony'
                                                OR portfid = 'ucs' THEN
                                                DO;
                                                        score5= 0.021233;
                                                        catv2=13;
                                                END;
                                                /*    x.31/1.15/0.27/1.25/0.10/1.19/1.30/1    */
                                                ELSE IF portfid = 'error'
                                                     OR portfid = 'platinum' THEN
                                                DO;
                                                        /*    x.31/1.15/0.27/1.25/0.10/1.19/1.30/1.28/0    */
                                                        IF channel = 'Interne'
                                                        OR channel = 'NPS'
                                                        OR channel = 'OBTM'
                                                        OR channel = 'Other'
                                                        OR channel = 'Take On' THEN
                                                        DO;
                                                                score5= 0.026802;
                                                                catv2=14;
                                                        END;
                                                        /*    x.31/1.15/0.27/1.25/0.10/1.19/1.30/1.28/1    */
                                                        ELSE IF channel = 'Tabling' THEN
                                                        DO;
                                                                score5= 0.081394;
                                                                catv2=15;
                                                        END;
                                                        /*    x.31/1.15/0.27/1.25/0.10/1.19/1.30/1    */
                                                        ELSE 
                                                        DO;
                                                                score5= 0.058718;
                                                                catv2=0;
                                                        END;
                                                END;
                                                /*    x.31/1.15/0.27/1.25/0.10/1.19/1    */
                                                ELSE 
                                                DO;
                                                        score5= 0.043566;
                                                        catv2=0;
                                                END;
                                        END;
                                        /*    x.31/1.15/0.27/1.25/0.10/1    */
                                        ELSE 
                                        DO;
                                                score5= 0.029036;
                                                catv2=0;
                                        END;
                                END;
                                /*    x.31/1.15/0.27/1.25/0    */
                                ELSE 
                                DO;
                                        score5= 0.019576;
                                        catv2=0;
                                END;
                        END;
                        /*    x.31/1.15/0.27/1.25/1    */
                        ELSE IF TL_EVER_04_08_CT >= 1.000000 THEN
                        DO;
                                score5= 0.061046;
                                catv2=16;
                        END;
                        /*    x.31/1.15/0.27/1    */
                        ELSE 
                        DO;
                                score5= 0.020064;
                                catv2=0;
                        END;
                END;
                /*    x.31/1.15/0.27/2    */
                ELSE IF TL_RVLV_BAL_AMT >= 409.000000 THEN
                DO;
                        /*    x.31/1.15/0.27/2.4/0    */
                        IF CREDT_ESTBL_MON_CT >= 6.000000 AND CREDT_ESTBL_MON_CT < 11.000000 THEN
                        DO;
                                score5= 0.079408;
                                catv2=17;
                        END;
                        /*    x.31/1.15/0.27/2.4/1    */
                        ELSE IF CREDT_ESTBL_MON_CT >= 11.000000 AND CREDT_ESTBL_MON_CT <= 714.000000 THEN
                        DO;
                                /*    x.31/1.15/0.27/2.4/1.2/0    */
                                IF INQ_EVER_CT >= 0.000000 AND INQ_EVER_CT < 10.000000 THEN
                                DO;
                                        score5= 0.029532;
                                        catv2=18;
                                END;
                                /*    x.31/1.15/0.27/2.4/1.2/1    */
                                ELSE IF INQ_EVER_CT >= 10 THEN
                                DO;
                                        /*    x.31/1.15/0.27/2.4/1.2/1.19/0    */
                                        IF COLG_STATE_CD = ' '
                                        OR COLG_STATE_CD = 'AR'
                                        OR COLG_STATE_CD = 'CO'
                                        OR COLG_STATE_CD = 'DE'
                                        OR COLG_STATE_CD = 'IN'
                                        OR COLG_STATE_CD = 'KS'
                                        OR COLG_STATE_CD = 'LA'
                                        OR COLG_STATE_CD = 'MA'
                                        OR COLG_STATE_CD = 'MD'
                                        OR COLG_STATE_CD = 'MN'
                                        OR COLG_STATE_CD = 'MO'
                                        OR COLG_STATE_CD = 'NE'
                                        OR COLG_STATE_CD = 'OK'
                                        OR COLG_STATE_CD = 'UT'
                                        OR COLG_STATE_CD = 'VA'
                                        OR COLG_STATE_CD = 'WV'
                                        OR COLG_STATE_CD = 'HI'
                                        OR COLG_STATE_CD = 'VT'
                                        OR COLG_STATE_CD = 'ND'
                                        OR COLG_STATE_CD = 'NV' THEN
                                        DO;
                                                score5= 0.046494;
                                                catv2=19;
                                        END;
                                        /*    x.31/1.15/0.27/2.4/1.2/1.19/1    */
                                        ELSE IF COLG_STATE_CD = '0'
                                             OR COLG_STATE_CD = 'AL'
                                             OR COLG_STATE_CD = 'AZ'
                                             OR COLG_STATE_CD = 'CA'
                                             OR COLG_STATE_CD = 'CT'
                                             OR COLG_STATE_CD = 'DC'
                                             OR COLG_STATE_CD = 'FL'
                                             OR COLG_STATE_CD = 'GA'
                                             OR COLG_STATE_CD = 'IA'
                                             OR COLG_STATE_CD = 'ID'
                                             OR COLG_STATE_CD = 'IL'
                                             OR COLG_STATE_CD = 'ME'
                                             OR COLG_STATE_CD = 'MI'
                                             OR COLG_STATE_CD = 'MS'
                                             OR COLG_STATE_CD = 'MT'
                                             OR COLG_STATE_CD = 'NC'
                                             OR COLG_STATE_CD = 'NH'
                                             OR COLG_STATE_CD = 'NJ'
                                             OR COLG_STATE_CD = 'NY'
                                             OR COLG_STATE_CD = 'OH'
                                             OR COLG_STATE_CD = 'OR'
                                             OR COLG_STATE_CD = 'PA'
                                             OR COLG_STATE_CD = 'RI'
                                             OR COLG_STATE_CD = 'SC'
                                             OR COLG_STATE_CD = 'TN'
                                             OR COLG_STATE_CD = 'TX'
                                             OR COLG_STATE_CD = 'WI'
                                             OR COLG_STATE_CD = 'KY'
                                             OR COLG_STATE_CD = 'WY' THEN
                                        DO;
                                                score5= 0.071553;
                                                catv2=20;
                                        END;
                                        /*    x.31/1.15/0.27/2.4/1.2/1    */
                                        ELSE 
                                        DO;
                                                score5= 0.050320;
                                                catv2=0;
                                        END;
                                END;
                                /*    x.31/1.15/0.27/2.4/1    */
                                ELSE 
                                DO;
                                        score5= 0.033251;
                                        catv2=0;
                                END;
                        END;
                        /*    x.31/1.15/0.27/2    */
                        ELSE 
                        DO;
                                score5= 0.036794;
                                catv2=0;
                        END;
                END;
                /*    x.31/1.15/0    */
                ELSE 
                DO;
                        score5= 0.030199;
                        catv2=0;
                END;
        END;
        /*    x.31/1.15/1    */
        ELSE IF TL_CURR_04_09_CT = 1.000000 THEN
        DO;
                /*    x.31/1.15/1.13/0    */
                IF SATIS_TL_CT >= 0.000000 AND SATIS_TL_CT < 9.000000 THEN
                DO;
                        score5= 0.093857;
                        catv2=21;
                END;
                /*    x.31/1.15/1.13/1    */
                ELSE IF SATIS_TL_CT >= 9.000000 THEN
                DO;
                        score5= 0.042554;
                        catv2=22;
                END;
                /*    x.31/1.15/1    */
                ELSE 
                DO;
                        score5= 0.078628;
                        catv2=0;
                END;
        END;
        /*    x.31/1.15/2    */
        ELSE IF TL_CURR_04_09_CT >= 2.000000 THEN
        DO;
                score5= 0.114024;
                catv2=23;
        END;
        /*    x.31/1    */
        ELSE 
        DO;
                score5= 0.032914;
                catv2=0;
        END;
END;
/*    x.31/2    */
ELSE IF bureau_type = 'NoBureau' THEN
DO;
        /*    x.31/2.1/1    */
        IF CAPS_ERR_CD in ('1Z','2Z','8S') THEN
        DO;
                /*    x.31/2.1/1.12/0    */
                IF COLG_INCM_SOURC_CD = ' '
                OR COLG_INCM_SOURC_CD = 'A'
                OR COLG_INCM_SOURC_CD = 'P'
                OR COLG_INCM_SOURC_CD = 'S'
                OR COLG_INCM_SOURC_CD = 'V' THEN
                DO;
                        /*    x.31/2.1/1.12/0.37/0    */
                        IF School = '2'
                        OR School = 'C'
                        OR School = 'F'
                        OR School = 'G'
                        OR School = 'L'
                        OR School = 'M'
                        OR School = 'N'
                        OR School = 'O'
                        OR School = 'R'
                        OR School = 'x' THEN
                        DO;
                                score5= 0.063705;
                                catv2=25;
                        END;
                        /*    x.31/2.1/1.12/0.37/1    */
                        ELSE IF School = 'A'
                             OR School = 'B'
                             OR School = 'D'
                             OR School = 'E'
                             OR School = 'T'
                             OR School = 'V' THEN
                        DO;
                                score5= 0.028804;
                                catv2=26;
                        END;
                        /*    x.31/2.1/1.12/0    */
                        ELSE 
                        DO;
                                score5= 0.039920;
                                catv2=0;
                        END;
                END;
                /*    x.31/2.1/1.12/1    */
                ELSE IF COLG_INCM_SOURC_CD = 'F'
                     OR COLG_INCM_SOURC_CD = 'T' THEN
                DO;
                        score5= 0.083577;
                        catv2=27;
                END;
                /*    x.31/2.1/1    */
                ELSE 
                DO;
                        score5= 0.043889;
                        catv2=0;
                END;
        END;
        /*    x.31/2    */
                /*    x.31/2.1/0    */
        ELSE IF CAPS_ERR_CD = . THEN
                DO;
                        score5= 0.009954;
                        catv2=24;
                END;       
        ELSE 
        DO;
                score5= 0.022652;
                catv2=0;
        END;
END;
/*    x    */
ELSE 
DO;
        score5= 0.036452;
        catv2=0;
END;


/** tag old old cp score cutoff **/
if school_type = '4 year' then do;
   if model_num = 'U1' then do;
      if segment = 'S1' and final_score_val >= 141 then cp0901 = 'Approve';
      else if segment = 'S2' and final_score_val >= 131 then cp0901 = 'Approve';
      else if segment = 'S3' and final_score_val >= 141 then cp0901 = 'Approve';
      else if segment = 'S4' and final_score_val >= 156 then cp0901 = 'Approve';
      else if segment = 'S5' and final_score_val >= 151 then cp0901 = 'Approve';
      else if segment = 'S6' and final_score_val >= 216 then cp0901 = 'Approve';
      else if segment = 'S7' and final_score_val >= 111 then cp0901 = 'Approve';
      end;
   
   else if model_num = 'U2' then do;
      if segment = 'S1' and final_score_val >= 211 then cp0901 = 'Approve';
      else if segment = 'S2' and final_score_val >= 236 then cp0901 = 'Approve';
      else if segment = 'S3' and final_score_val >= 186 then cp0901 = 'Approve';
      else if segment = 'S4' and final_score_val >= 236 then cp0901 = 'Approve';
      else if segment = 'S5' and final_score_val >= 136 then cp0901 = 'Approve';
      else if segment = 'S6' and final_score_val >= 221 then cp0901 = 'Approve';
      else if segment = 'S7' and final_score_val >= 156 then cp0901 = 'Approve';
      end;
   
   else if model_num = 'U3' then do;
      if segment = 'S1' and final_score_val >= 151 then cp0901 = 'Approve';
      else if segment = 'S2' and final_score_val >= 126 then cp0901 = 'Approve';
      else if segment = 'S3' and final_score_val >= 131 then cp0901 = 'Approve';
      else if segment = 'S4' and final_score_val >= 141 then cp0901 = 'Approve';
      else if segment = 'S5' and final_score_val >= 126 then cp0901 = 'Approve';
      end;
   
   else if model_num = 'U4' then do;
      if segment = 'S1' and final_score_val >= 166 then cp0901 = 'Approve';
      else if segment = 'S2' and final_score_val >= 201 then cp0901 = 'Approve';
      else if segment = 'S3' and final_score_val >= 161 then cp0901 = 'Approve';
      else if segment = 'S4' and final_score_val >= 196 then cp0901 = 'Approve';
      else if segment = 'S5' and final_score_val >= 146 then cp0901 = 'Approve';
      end;
end;
else if school_type = '2 year' then do;
   if model_num = 'T1' then do;
      if segment = 'S1' and final_score_val >= 205 then cp0901 = 'Approve';
      else if segment = 'S2' and final_score_val >= 190 then cp0901 = 'Approve';
      else if segment = 'S3' and final_score_val >= 200 then cp0901 = 'Approve';
      end;
   
   else if model_num = 'T2' then do;
      if segment = 'S1' and final_score_val >= 195 then cp0901 = 'Approve';
      else if segment = 'S2' and final_score_val >= 205 then cp0901 = 'Approve';
      else if segment = 'S3' and final_score_val >= 185 then cp0901 = 'Approve';
      else if segment = 'S4' and final_score_val >= 195 then cp0901 = 'Approve';
      end;
   
   else if model_num = 'T3' then do;
      if segment = 'S1' and final_score_val >= 215 then cp0901 = 'Approve';
      else if segment = 'S2' and final_score_val >= 215 then cp0901 = 'Approve';
      else if segment = 'S3' and final_score_val >= 215 then cp0901 = 'Approve';
      else if segment = 'S4' and final_score_val >= 195 then cp0901 = 'Approve';
      end;

end;

%put**************** Updated New CHAID ****************************;
if burtype in ('FB No FICO','Inq Only') then do;
     if tl_curr_04_09_ct > 0 then newcat=4;
     else if grade='Graduate' then newcat=3;
     else if colg_incm_sourc_cd = 'F' then newcat=2;
     else newcat=1;
    end;
   else if burtype = 'FB w/ FICO' then do;
     if tl_curr_04_09_ct >= 2 then newcat=12;
     else if tl_curr_04_09_ct= 1 and satis_tl_ct >= 9 then newcat=11;
     else if tl_curr_04_09_ct= 1 and satis_tl_ct < 9  then newcat=10;
     else do;
       if tl_rvlv_bal_amt >= 429 then do;
         if credt_estbl_mon_ct >= 11 then newcat=9;
         else if credt_estbl_mon_ct >=5 then newcat=8;
         else newcat=99;
        end;
       else if tl_rvlv_bal_amt >= 1 then do;
         if tl_ever_04_08_ct >=1 then newcat=7;
         else newcat=6;
        end;
       else newcat=5;
      end;
    end;
   else if burtype= 'No Hit' then do;
     if colg_incm_sourc_cd in ('F','T') then newcat=14;
     else newcat=13;
    end;
   else newcat=0;





%put *******************score cutoffs ******************************************;


if cat in ('A','E','I','H','K','M','O','U','W','Y') and cp0901 = 'Approve' then oldchaid = 1; else oldchaid=0;
if cat in ('I','H','L','M','N','U','W') and cp0901 = 'Approve' then oldchaidv2 = 1; else oldchaidv2=0;
if catv2 in (7,16,17,18,19,20,21,22,23,25) and cp0901 = 'Approve' then newchaid = 1; else newchaid=0;

if appdec='Approve' then current=1; else current=0;

run;

%mend;




/*
%branch(dset=sasdata.riskall);

data sasdata.score;
set sasdata.riskall;
keep cl_tid oldchaid current newchaid cp0901 newchaidv2;
run;

proc sort data=sasdata.score;
by cl_tid;
run;


%branch(dset=sasdata.valid);
*/
/************ Use proc reg to further reduce the number of input variables ********************/
title 'Use reggression model to further eliminate input variables';
/*
proc reg data=&dset;
stepwise: model &target = &vardata / vif selection=stepwise;
run;


proc logistic data=&dset des outest=sasdata.betas6;
model  &target = &vardata6 / selection=stepwise stb lackfit risklimits;
run;
*/
/*
proc logistic data=sasdata.train des outest=sasdata.betas11;
weight weight;
model  &target = &vardata5 / selection=stepwise stb lackfit risklimits;
run;
*/
/***************** Select Most Important Variables from Stepwise **************************/

%let model1= 
BKSCR       BURBAL    BURTLNUM  CALMT     CASHBAL   CASHCT    INQ6NUM     LIFECACT  M2SCR     OFFUSCRD  
OTBAMT    PURAPR    kpi4 kpi5 
;


/*
proc logistic data=sasdata.train des outest=sasdata.betas11;
weight weight;
model  &target = &model11  /  stb lackfit risklimits;
units ficoscr=100 m2scr=10 buroldtl=12;
run;
*/
/*
proc logistic data=sasdata.train des outest=sasdata.betas1;
model  &target = &model1 / stb lackfit risklimits;
run;

proc reg data=sasdata.sampleb;
stepwise: model &target = &vardata / vif selection=stepwise;
run;
*/

/******************************** Score Validation Dset ****************************************/
%let dset=sasdata.valid;

/*
%score(dset=&dset,model=model11,modelvar=&model11,betas=sasdata.betas11);
*/

/****************************** Assess Model **********************************/

proc format;
value rankfmt
low-1565='0'
1566-3131='1'
3132-4697='2'
4698-6263='3'
6264-7829='4'
7830-9395='5'
9396-10961='6'
10962-12527='7'
12528-14093='8'
14094-15659='9'
15660-17225='10'
17226-18791='11'
18792-20357='12'
20358-21923='13'
21924-23489='14'
23490-25055='15'
25056-26621='16'
26622-28187='17'
28188-29753='18'
29754-high='19'
;

run;


/*


proc sql;
create table swap as
select  current,
        newchaid,
        count(*)                as numaccts,
        sum(actual*wt)          as target,
        sum((1-actual)*wt)      as nontarget,
        sum(wt)                 as wt

from rankdata

group by current,
        newchaid
;
quit;

%csv(swap,"swap1..txt");


proc sql;
create table swap as
select  oldchaid,
        newchaid,
        count(*)                as numaccts,
        sum(actual*wt)          as target,
        sum((1-actual)*wt)      as nontarget,
        sum(wt)                 as wt

from rankdata

group by oldchaid,
        newchaid
;
quit;

%csv(swap,"swap2..txt");

proc sql;
create table swap as
select  actual,
        newchaid,
        count(*)                as numaccts,
        sum(actual*wt)          as target,
        sum((1-actual)*wt)      as nontarget,
        sum(wt)                 as wt

from rankdata

group by actual,
        newchaid
;
quit;

%csv(swap,"swap3..txt");


proc sql;
create table swap as
select  current,
        oldchaid,
        count(*)                as numaccts,
        sum(actual*wt)          as target,
        sum((1-actual)*wt)      as nontarget,
        sum(wt)                 as wt

from rankdata

group by current,
        oldchaid
;
quit;

%csv(swap,"swap4..txt");

proc sql;
create table swap as
select  actual,
        oldchaid,
        count(*)                as numaccts,
        sum(actual*wt)          as target,
        sum((1-actual)*wt)      as nontarget,
        sum(wt)                 as wt

from rankdata

group by actual,
        oldchaid
;
quit;

%csv(swap,"swap5.txt");


proc sql;
create table swap as
select  oldchaid,
        newchaidv2,
        count(*)                as numaccts,
        sum(actual*wt)          as target,
        sum((1-actual)*wt)      as nontarget,
        sum(wt)                 as wt

from rankdata

group by oldchaid,
        newchaidv2
;
quit;

%csv(swap,"swap6..txt");

proc sql;
create table swap as
select  actual,
        newchaidv2,
        count(*)                as numaccts,
        sum(actual*wt)          as target,
        sum((1-actual)*wt)      as nontarget,
        sum(wt)                 as wt

from rankdata

group by actual,
        newchaidv2
;
quit;

%csv(swap,"swap7..txt");
*/


/*
%rank(score=score1);


%rank(score=score1);

%rank(score=score3);
%rank(score=score2);
**/
/*
%let score=score4;
%rank(score=&score);

proc sql;
create table ksdata as
select  cat,
        channel,
        min(&score)             as minscore,
        max(&score)             as maxscore,
        count(*)                as numaccts,
        sum(actual*wt)          as target,
        sum((1-actual)*wt)      as nontarget,
        sum(wt)                 as wt,
        sum(tncm*wt)            as tncm1,
        sum(tncm2*wt)           as tncm2,
        sum(ncl1*wt)            as ncl1,
        sum(ncl2*wt)            as ncl2,
        sum(toprexp1*wt)        as toprexp1,
        sum(toprexp2*wt)        as toprexp2,
        sum(tanr1*wt)           as tanr1,
        sum(tanr2*wt)           as tanr2,
        sum((ncl1>0)*wt)        as ncl1a,
        sum((ncl2>0)*wt)        as ncl2a,
        sum(asign_credt_limit*wt) as crlmt,
        sum(billactv1*wt)       as billactv1,
        sum(billactv2*wt)       as billactv2

from sasdata.riskall

where month(acct_creat_dt) in (1,2,3) 
        and year(acct_creat_dt)=2000
      and cp0901 = 'Approve'

group by cat,
        channel
;
quit;

%csv(ksdata,"pnl&score.f.txt");
*/
%put ********************** This produces the output file for the Old Chaid ALL Data.xls************;
/*
%let score=score4;

proc sql;
create table ksdata as
select  cat,
        channel,
        min(&score)             as minscore,
        max(&score)             as maxscore,
        count(*)                as numaccts,
        sum(actual)          as target,
        sum((1-actual))      as nontarget,
        sum(1)                 as wt,
        sum(tncm)            as tncm1,
        sum(tncm2)           as tncm2,
        sum(ncl1)            as ncl1,
        sum(ncl2)            as ncl2,
        sum(toprexp1)        as toprexp1,
        sum(toprexp2)        as toprexp2,
        sum(tanr1)           as tanr1,
        sum(tanr2)           as tanr2,
        sum((ncl1>0))        as ncl1a,
        sum((ncl2>0))        as ncl2a,
        sum(asign_credt_limit) as crlmt,
        sum(billactv1)       as billactv1,
        sum(billactv2)       as billactv2

from sasdata.riskall

where acct_creat_dt<='31MAY2001'd
        and cp0901 = 'Approve'

group by cat,
        channel
;
quit;

%csv(ksdata,"pnl&score.h.txt");

%put ********************** This produces the output file for the New Chaid ALL Data.xls************;

%let score=score5;

proc sql;
create table ksdata as
select  newcat,
        channel,
        min(&score)             as minscore,
        max(&score)             as maxscore,
        count(*)                as numaccts,
        sum(actual)          as target,
        sum((1-actual))      as nontarget,
        sum(1)                 as wt,
        sum(tncm)            as tncm1,
        sum(tncm2)           as tncm2,
        sum(ncl1)            as ncl1,
        sum(ncl2)            as ncl2,
        sum(toprexp1)        as toprexp1,
        sum(toprexp2)        as toprexp2,
        sum(tanr1)           as tanr1,
        sum(tanr2)           as tanr2,
        sum((ncl1>0))        as ncl1a,
        sum((ncl2>0))        as ncl2a,
        sum(asign_credt_limit) as crlmt,
        sum(billactv1)       as billactv1,
        sum(billactv2)       as billactv2,
        sum(case when mob>12 and mob<24 then mob-12 
        	when mob>24 then 12
        	else 0 end)  as mobyr2

from sasdata.riskall

where acct_creat_dt<='31MAY2001'd
        and cp0901 = 'Approve'

group by newcat,
        channel
;
quit;

%csv(ksdata,"pnlnew3.txt");
*/
%put ********************** This produces the output file for the swap.xls ******************;

proc sql;
create table ksdata as
select  oldchaid,
	newchaid,
        channel,
        count(*)                as numaccts,
        sum(actual)          as target,
        sum((1-actual))      as nontarget,
        sum(1)                 as wt,
        sum(tncm)            as tncm1,
        sum(tncm2)           as tncm2,
        sum(ncl1)            as ncl1,
        sum(ncl2)            as ncl2,
        sum(toprexp1)        as toprexp1,
        sum(toprexp2)        as toprexp2,
        sum(tanr1)           as tanr1,
        sum(tanr2)           as tanr2,
        sum((ncl1>0))        as ncl1a,
        sum((ncl2>0))        as ncl2a,
        sum(asign_credt_limit) as crlmt,
        sum(billactv1)       as billactv1,
        sum(billactv2)       as billactv2,
        sum(case when mob>12 and mob<24 then mob-12 
        	when mob>24 then 12
        	else 0 end)  as mobyr2

from sasdata.riskall

where acct_creat_dt<='31MAY2001'd
        and cp0901 = 'Approve'

group by oldchaid,
	newchaid,
        channel
;
quit;

%csv(ksdata,"swap3.txt");

/*
data sasdata.riskall;
set sasdata.riskall;
mob=intck('month',acct_creat_dt,'31MAY2002'd)+1;
if newcat in (1,3,5,6,7,8,9,11,13) then newchaid=1; else newchaid=0;
run;

proc print data=sasdata.riskall (obs=10);
var cl_tid acct_creat_dt mob;
run;
*/

