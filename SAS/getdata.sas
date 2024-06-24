/***************************************************************************/
/* Title: Master Code 					                   */
/* Programer: Sean M. Burns                                                */
/***************************************************************************/

libname sasdata '/camsrvr/largefile/Cards_DM/INTERNAL/sburns/';
options compress=yes;

%include '/u/sburns/csv.sas';


%macro getdata(obspnum=,random=,hobspnum=);
%let begpnum=%eval(&obspnum+1);
%let endpnum=%eval(&obspnum+12);
%let begpnum6=%eval(&obspnum-5);
%let endpnum6=%eval(&obspnum);
%let pnum3=%eval(&obspnum-3);
%let ws_pernum=%eval(&obspnum); * Need to define logic;

* Define Formats;

proc format;
value linefmt
0='00000-00000'
1-500='00001-00500'
501-1500='00501-01500'
1501-3000='01501-03000'
3001-4500='03001-04500'
4501-6000='04501-06000'
6001-7500='06001-07500'
7501-9000='07501-09000'
9001-10500='09001-10500'
10501-12000='10501-12000'
12001-13501='12001-13501'
13501-15001='13501-15001'
15001-high='15001-high'
;

value $pidfmt
'Q'='RDG'
'S'='NTC'
'R'='College'
'C'='Platinum'
'B'='Diamond Rewards'
'M'='Platinum'
'Z'='Dividend'
'H'='Choice'
'U'='UCS'
'Y'='UCS Cash'
'G'='UCS Rewards'
'J'='Simplicity Cash '
'X'='Simplicity Rewards'
'P'='Simplicity Value'
'D'='Driver’s Edge'
'N'='Platinum'
'T'='U-Promise'
'E'='Premier Pass'
'F'='Premier Pass'
'A'='Citi - EROC'
'L'='Cit - Smith Barney'
'K'='Citi - WaMu'
'1'='Puerto Rico'
'2'='AAdvantage'
'*'='Not Classified'
other='Other'
;

value portfmt
1='TAM'
2='TAM'
4='VCR'
6='TAM'
7='TAM'
8='VCR'
9='VCR'
10='VCR'
11='VCR'
14='VCR'
15='VCR'
16='VCR'
17='VCR'
18='VCR'
20='VCR'
23='VCR'
24='VCR'
29='VCR'
31='TAM'
32='TAM'
33='VCR'
39='VCR'
40='VCR'
41='VCR'
42='VCR'
62='TAM'
72='VCR'
80='VCR'
81='VCR'
82='VCR'
85='VCR'
86='VCR'
87='VCR'
99='VCR'
123='TAM'
124='TAM'
130='TAM'
131='TAM'
134='TAM'
135='TAM'
136='TAM'
137='VCR'
140='TAM'
141='TAM'
143='VCR'
144='VCR'
145='VCR'
146='VCR'
147='VCR'
148='VCR'
149='VCR'
150='VCR'
151='VCR'
155='VCR'
156='TAM'
157='TAM'
158='TAM'
159='TAM'
160='TAM'
161='TAM'
162='TAM'
170='TAM'
171='TAM'
172='TAM'
173='TAM'
174='TAM'
202='VCR'
203='TAM'
204='TAM'
205='VCR'
206='VCR'
207='VCR'
208='VCR'
209='VCR'
254='VCR'
255='VCR'
256='VCR'
257='VCR'
258='VCR'
262='VCR'
263='VCR'
270='TAM'
272='TAM'
273='PR'
276='VCR'
277='PR'
278='PR'
279='PR'
280='PR'
281='PR'
282='PR'
283='PR'
284='PR'
285='PR'
286='PR'
353='TAM'
354='TAM'
355='TAM'
356='TAM'
362='TAM'
372='TAM'
410='TAM'
420='VCR'
421='VCR'
423='VCR'
424='VCR'
430='TAM'
450='VCR'
452='VCR'
453='VCR'
454='VCR'
455='VCR'
460='VCR'
462='PR'
486='VCR'
487='VCR'
559='TAM'
560='TAM'
561='TAM'
562='TAM'
563='TAM'
564='TAM'
597='TAM'
600='TAM'
612='TAM'
630='TAM'
631='VCR'
632='TAM'
633='VCR'
635='VCR'
728='VCR'
729='VCR'
730='VCR'
731='VCR'
732='VCR'
733='VCR'
734='VCR'
735='VCR'
736='VCR'
737='VCR'
774='VCR'
775='VCR'
776='VCR'
777='VCR'
778='VCR'
779='VCR'
780='VCR'
781='VCR'
782='VCR'
783='VCR'
784='VCR'
785='VCR'
786='VCR'
787='VCR'
788='VCR'
789='VCR'
790='VCR'
791='VCR'
795='VCR'
796='VCR'
797='VCR'
798='VCR'
799='VCR'
800='VCR'
801='VCR'
802='VCR'
803='VCR'
804='VCR'
805='VCR'
806='VCR'
807='VCR'
808='VCR'
809='VCR'
810='VCR'
811='VCR'
812='VCR'
other='UNDEF'
;


value $clasfmt
'1','2','3','4','5','6'='Underclass'
other='Grads'
;

value scrfmt
-1='-1'
0-10='0-10'
11-20='11-20'
21-30='21-30'
31-40='31-40'
41-50='41-50'
51-60='51-60'
61-70='61-70'
71-80='71-80'
81-90='81-90'
91-high='91-100'
;

value m3fmt
-1='-1'
0-40='00-40'
41-69='41-69'
70-90='70-90'
91-high='91-100'
;

value bk3fmt
-1='-1'
0-20='00-20'
21-high='21-100'
;

value ficofmt
0='000-000'
1-622='001-622'
623-671='623-671'
672-717='672-717'
717-999='718-999'
1000-high='999+high'
;

value mobfmt
low-12='00-12'
13-high='13-high'
;

value lclifmt
low-6='00-06'
7-high='7-high'
;


value utilfmt
low-0='low-0'
1-14='01-14'
15-28='15-28'
29-41='29-41'
42-54='42-54'
55-high='55-high'
;

value numfmt
0='0 '
1='1 '
2='2 '
3-high='3+'
;


value salefmt
low-<0='Negative '
0='0000-0000'
0<-100='0001-0100'
100<-1000='0100-1000'
1000<-high='1001-high'
;


value intfmt
low-<0='Negative '
0='000-000'
0<-10='001-010'
10<-65='010-065'
65<-high='065-high'
;

value bifmt
low-0='Negative '
0<-170='001-170'
170<-675='171-675'
675<-high='675-high'
;


value fltfmt
low-0='00-00'
0<-14='01-14'
14<-21='15-21'
21<-high='22+  '
;

value inactfmt
low-0='00'
1-4='01-04'
5-high='05+  '
;

value inacmfmt
low-0='00'
1='01-01'
2-5='02-05'
6-high='06+  '
;

value revlvfmt
low-0='00'
1-2='01-02'
3-6='03-06'
7-high='07+  '
;

value balfmt
low-0='00000-00000'
0<-1200='00001-01200'
1200<-5000='01201-05000'
5000<-high='05001-high '
;


value waprfmt
0='00.00%'
0<-12.99='01.00%-12.99%'
12.99<-19.99='13.00%-19.99%'
19.99<-high='19.00%+      '
;

value aprfmt
0='00.00%-00.00%'
0<-1.99='00.99%-01.99%'
1.99<-2.99='02.00%-02.99%'
2.99<-3.99='03.00%-03.99%'
3.99<-4.99='04.00%-04.99%'
4.99<-5.99='05.00%-05.99%'
5.99<-9.99='06.00%-09.99%'
9.99<-18.99='10.00%-18.99%'
18.99<-high='19.00%+      '
;

value $balscft
'N'='ACQ'
'P'='ACQ'
'Q'='ACQ'
'R'='ACQ'
'2'='ECM'
'3'='ECM'
'4'='ECM'
'5'='ECM'
'6'='ECM'
'7'='ECM'
'*'='ECM'
'L'='ECM'
'M'='ECM'
'$'='ECM'
'A'='ECM'
'B'='ECM'
'C'='ECM'
'D'='ECM'
'E'='ECM'
'F'='ECM'
'V'='ECM'
'W'='ECM'
'Z'='ECM'
'G'='OTH'
'H'='OTH'
'J'='OTH'
'K'='OTH'
'S'='OTH'
'U'='OTH'
'X'='OTH'
'Y'='OTH'
'/'='OTH'
'8'='OTH'
'9'='OTH'
'T'='OTH'
;

value psmfmt
1='01 - High Value Revolver '
2='02 - Medium Value Revolver '
3='03 - Low Value Revolver'
4='04 - High Value Transactor'
5='05 - Medium Value Transactor'
6='06 - Low Value Transactor'
7='07 - Occasional Revolver'
8='08 - Occasional Transactor'
9='09 - High Risk (HH) '
10='10 - High Risk (HF) '
11='11 - New Accounts (NN) '
12='12 - New Accounts (NA) '
13='13 - New Accounts (NB) '
14='14 - New Accounts (NC) '
15='15 - New Accounts (ND)'
16='16 - New Accounts (NG)'
17='17 - New Accounts (NU)'
18='18 - New Accounts (NV)'
19='19 - New Accounts (NW) '
20='20 - New Accounts (NX)'
21='21 - New Accounts (NY)'
22='22 - New Accounts (NZ)'
23='23 - Severely Inactive (IN) '
24='24 - Severely Inactive (IG) '
25='25 - Severely Inactive (IH) '
26='26 - Severely Inactive (IM) '
27='27 - Severely Inactive (IL) '
28='28 - Severely Inactive (IT)'
29='29 - Balcon Gamers (All Time) '
30='30 - Balcon Gamers (Other) '
31='31 - Self Activate (Revolver) '
32='32 - Self Activate (Transactor) '
;

value psm2fmt
1='01 - High Value Revolver '
2='02 - Medium Value Revolver '
3='03 - Low Value Revolver'
4='04 - High Value Transactor'
5='05 - Medium Value Transactor'
6='06 - Low Value Transactor'
7='07 - Occasional Revolver'
8='08 - Occasional Transactor'
9-10='09-10 - High Risk'
11-22='11-22 - New Accounts'
23-28='23-28 - Severely Inactive'
29-30='29-30 - Balcon Gamers'
31-32='31-32 - Self Activate'
other='Untagged'
;

value engfmt
1='1 - Normal '
2='2 - 1 Std dev from Norm'
3='3 - 2 Std dev from Norm'
4='4 - 3+ mo Sales Inactive'
5='5 - 1 mo Statement Inactive'
6='6 - 2 mo Statement Inactive'
7='7 - 3+ mo Statement Inactive'
98='98 - Default for New Segments'
99='99 - Global exclusions'
;

value $phamfmt
'1','A'='01'
'2','B'='02'
'3','C'='03'
'4','D'='04'
'5','E'='05'
'6','F'='06'
'7','G'='07'
'8','H'='08'
'9','J'='09'
'X','K'='10'
'Y','L'='11'
'Z','M'='12'
;

value $npsmfmt
'1'='01'
'2'='02'
'3'='03'
'4'='04'
'5'='05'
'6'='06'
'7'='07'
'8'='08'
'9'='09'
'0'='10'
'N'='11'
'D'='12'
;

value $segfmt
'0000'='OTH'
'0001'='GBR'
'0010'='REW'
'0011'='N/A'
'0100'='SPD'
'0101'='SPD'
'0110'='REW'
'0111'='N/A'
'1000'='OTH'
'1001'='SAB'
'1010'='REW'
'1011'='N/A'
'1100'='SAB'
'1101'='SAB'
'1110'='SAB'
'1111'='N/A'
;

value $seg2fmt
'G'='GBR'
'C','D'='SPD'
'2','3','4','5','6','7','8','9'='SAB'
'B','F'='REW'
'H'='OTH'
other='N/A'
;

run;


* Part 1;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  sasdata.getdata1 as 
  select * from connection to teradata(

select
clb.cl_tid,
clb.cid_tid,
clb.sales_inact_mos_ct,
clb.life_ca_amt,
clb.life_purch_amt,
clb.mon_on_book_ct,
clb.bill_actv_ind,
clb.sales_actv_ind,
clb.bill_dt,
clb.last_pay_dt,
clb.last_purch_dt,
clb.last_ca_dt,
clb.last_bad_check_dt,
clb.delnq_stat_cur_mon,
clb.purch_apr,
clb.ca_apr,
clb.wght_avg_apr,
clb.wght_avg_balc_apr,
clb.wght_avg_ca_apr,
clb.wght_avg_oth_apr,
clb.wght_avg_purch_apr,
clb.close_bal_amt,
clb.open_bal_amt,
clb.bucket_cd,
clb.totl_pay_amt,
clb.totl_sales_amt,
cl.acct_creat_dt,
cl.scode_1,
cl.scode_2,
cl.scode_3,
cl.scode_4,
cl.scode_5,
cl.scode_6,
cl.scode_7,
cl.scode_8,
cl.scode_9,
cl.scode_10,
cl.scode_11,
cl.scode_12,
cl.scode_13,
cl.scode_14,
cl.scode_15,
cl.scode_16,
cl.scode_17,
cl.scode_18,
cl.scode_19,
vers.schl_class_id,
vers.bankt_stat_cd,
vers.write_off_stat_cd,
vers.credt_montr_id,
vers.credt_montr_bur_cd,
vers.acct_stat_id,
vers.cccs_cd,
vers.early_warn_refr_cd,
vers.multi_lang_cd,
vers.retal_bank_stat_id,
vers.ins_claim_stat,
vers.zip_cd,
vers.hot_card_stat_cd,
vers.actv_milty_ind,
vers.state_cd,
vers.acct_type_id,
vers.strat_portf_id,
vers.pin_asign_dt,
vers.pin_desc_cd,
vers.pin_stat_id,
vers.secr_type_id,
feat.portf_id,
feat.totl_credt_limit,
feat.last_cli_chg_dt,
feat.ceil_credt_limit,
feat.apr_index_id,
feat.plast_ct,
cls.m3_score_val,
cls.bk3_score_val,
abili.abilitec_id,
clpsm.segmt_id,
clpsm.engag_lvl_id


FROM
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1
             
        JOIN cl_featr_versn feat
        on clb.cl_tid=feat.cl_tid
        and clb.featr_vid=feat.featr_vid               
        
        JOIN cl_versn vers
        on clb.cl_tid=vers.cl_tid
        and clb.cl_vid=vers.cl_vid     

	left outer JOIN cl_psm clpsm
        on clpsm.cl_tid=clb.cl_tid
        and clpsm.per_num=clb.per_num

        left outer join cl_abili abili
        on clb.cl_tid=abili.cl_tid

        left outer join cl_bill_score cls
        on clb.cl_tid=cls.cl_tid
        and clb.per_num=cls.per_num 


);

%put SAS Return Code:    &sqlrc;
%put SAS Number of Obs:  &sqlobs;
%put SQL Return Code:    &sqlxrc;
%put SQL Return Message: &sqlxmsg;


* Part 2;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  sasdata.getdata2 as 
  select * from connection to teradata(

select

clb.cl_tid,
chv.credt_card_acct_ct,
chv.worst_perf_stat_id,
pnl.interest,
coalesce(pnl.new_balcon_amt,0) as new_balcon_amt,
coalesce(pnl.ca_bal_amt,0) as ca_bal_amt,
coalesce(pnl.ca_amt,0) as ca_amt,
pnl.purch_amt,
coalesce(clba.totl_balc_bal_amt,0) as totl_balc_bal_amt,
coalesce(clba.ca_anr_amt,0) as ca_anr_amt,
ws.markt_tag_cd||ws.sub_markt_tag_cd as wallet_share,
ws.minpay_behav_cd,
ws.minpay_hist_ct,
ws.CREDT_XTEND_CD,
ws.CONSTRN_TAG_CD,
h.abilitec_addr_id,
case when clb.per_num>=6287 then CAST(m4.score_val AS DECIMAL(3)) else -1 end AS m4, 
case when clb.per_num>=6287 then CAST(bk4.score_val AS DECIMAL(3)) else -1 end AS bk4,
ph.phoen_cd

FROM
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1
          
        join ch_versn chv
        on chv.ch_tid=clb.ch_tid
        and chv.ch_vid=clb.ch_vid
        
        join cl_pnl_vw pnl
	on clb.cl_tid=pnl.cl_tid
	and clb.per_num=pnl.per_num
    
        left outer join cl_bill_actv clba
	on clb.cl_tid=clba.cl_tid
	and clb.per_num=clba.per_num	
	
	LEFT OUTER JOIN ECMTAGS_HIST ws
	ON ws.cl_tid = clb.cl_tid
	AND ws.per_num = &ws_pernum
	
	left outer join cl_abi_hh h
	on clb.cl_tid=h.cl_tid
	
	LEFT OUTER JOIN cl_bill_score_util m4
	ON m4.cl_tid = clb.cl_tid
	AND m4.per_num = clb.per_num
	AND m4.score_id = 'M4'
	
	LEFT OUTER JOIN cl_bill_score_util bk4
	ON bk4.cl_tid = clb.cl_tid
	AND bk4.per_num = clb.per_num
 	AND bk4.score_id = 'BK4'

	LEFT OUTER JOIN cl_bill_phoenix ph
	ON ph.cl_tid = clb.cl_tid
 	AND ph.per_num = clb.per_num
);

%put SAS Return Code:    &sqlrc;
%put SAS Number of Obs:  &sqlobs;
%put SQL Return Code:    &sqlxrc;
%put SQL Return Message: &sqlxmsg;


* Part 3 Get Bureau Data *********************************************;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  sasdata.getdata3 as 
  select * from connection to teradata(

select

clb.cl_tid,
bur.rejct_reasn_cd,
case when bur.sbu_segmt_id=10 then coalesce(bur.nuc_brt_hibal_cl,0)
    else coalesce(bur.ncc_brt_hibal_cl,0) end                                              as lmthbal,
case when bur.sbu_segmt_id=10 then coalesce(bur.hi_nuc_brt_cl_amt,0)
    else coalesce(bur.hi_ncc_brt_cl_amt,0) end                                             as lmthlmt,
case when bur.sbu_segmt_id=10 then coalesce(bur.nuc_brt_hi_cl_bal,0)
    else coalesce(bur.ncc_brt_hi_cl_bal,0) end                                             as balhlmt,             
case when bur.sbu_segmt_id=10 then coalesce(bur.hibal_nuc_brt_amt,0)
    else coalesce(bur.hibal_ncc_brt_amt,0) end                                             as hibal,
case when bur.sbu_segmt_id=10 then coalesce(bur.nuc_brt_bal_amt,0)
    else coalesce(bur.ncc_brt_bal_amt,0) end                                               as offusbal,
case when bur.sbu_segmt_id=10 then coalesce(bur.nuc_rvlv_cl_amt,0)
    else coalesce(bur.ncc_rvlv_cl_amt,0) end                                               as offuslmt,
case when bur.sbu_segmt_id=10 then coalesce(bur.nuc_brt_ct,0)
    else coalesce(bur.ncc_brt_ct,0) end                                                    as offuscrd,   
case when bur.sbu_segmt_id=10 then coalesce(bur.nuc_brt_nobal_ct,0)
    else coalesce(bur.ncc_brt_nobal_ct,0) end                                              as offuscrd_nobal, 
coalesce(bur.fico_bnk_opt_score,0)                                                         as ficoscr,
coalesce(bur.OLD_TL_AGE,0)                                                                 as ageoldtl,
bur.ecm_bur_dt,
case when bur.sbu_segmt_id=10 then coalesce(bur.dpd60_nuc_ever_ct,0)        
    else coalesce(bur.dpd60_ncc_ever_ct,0) end                                             as dpd60_ever_ct,
case when bur.sbu_segmt_id=10 then coalesce(bur.dpd30_nuc_ct,0)        
    else coalesce(bur.dpd30_ncc_ct,0) end                                                  as dpd30_curr_ct,
bur.bankt_ind,
coalesce(burx.tot_brt_bal_amt,0)          						as tot_brt_bal_amt,
burx.cnslr_ind,
burx.forcl_ind,
burx.garns_ind,
burx.repos_ind,
bur.SEC_HI_BRDN_PCT,
bur.bur_util,
bur.bankt_12mon_ind,
bur.fraud_alrt_ind,
bur.dpd60_ncc_ct,
bur.TOTL_TL_CT,
bur.RRTL_TL_BAL_AMT,
bur.RTL_TL_BAL_AMT,
bur.totl_ncc_instl_bal,
bur.totl_instl_paymt,
bur.ncc_instl_ct,
bur.ncc_brt_3mon_ct,
bur.ncc_brt_12mon_ct,
bur.inq_6mon_ct,
bur.instl_tl_ct,
bur.hi_debt_burdn_pct,
burx.BAL_MORTG_TRD_AMT,
burx.HOMEQ_TL_BAL_AMT,
burx.HOMEQ_TL_CT,
burx.MORTG_TRD_BAL_GT_0_CT,
bur.HE_AMT,
bur.HE_BAL,
bur.HE_PAY,
bur.HE_TERM,
bur.MORT_AMT,
bur.MORT_BAL,
bur.MORT_PAY,
bur.MORT_TERM,
bur.MRO_REFNC_MORTG_TRD_MON_CT,
bur.NEW_MO_PAYMT_REFNC_AMT,
bur.OLD_MO_PAYMT_REFNC_AMT,
bur.TOTL_MORTG_BAL_AMT,
bur.TOT_MORTG_PAYMT_AMT,
bur.TOT_REFNC_MORTG_TRD_BAL_AMT,
bur.TOT_SEC_MORTG_BAL_AMT,
bur.TOT_SEC_MORTG_NUM

FROM
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1
             
        LEFT OUTER JOIN ecm_bur bur
        on clb.cid_tid=bur.cid_tid
        and clb.ecm_bur_dt=bur.ecm_bur_dt
        
       	LEFT OUTER JOIN ecm_bur_ext burx
        on clb.cid_tid=burx.cid_tid
        and clb.ecm_bur_dt=burx.ecm_bur_dt          
 
);

%put SAS Return Code:    &sqlrc;
%put SAS Number of Obs:  &sqlobs;
%put SQL Return Code:    &sqlxrc;
%put SQL Return Message: &sqlxmsg;

* Part 4 Get Promo Data ***********************************************;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  sasdata.getdata4 as 
  select * from connection to teradata(

select

clb.cl_tid,
clpr.promo_id,
clpr.ptd_redem_pts,
poft.promo_abrev,
poft.promo_desc,
clpr.enrol_stat_cd

FROM
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1

	left outer join cl_promo_accum clpr
        on clpr.cl_tid=clb.cl_tid
        and clpr.per_num=clb.per_num 

	left outer join promo_featr poft
        on poft.promo_id=clpr.promo_id
	

where clpr.enrol_stat_cd='E'

);

%put SAS Return Code:    &sqlrc;
%put SAS Number of Obs:  &sqlobs;
%put SQL Return Code:    &sqlxrc;
%put SQL Return Message: &sqlxmsg;



* Part 5 Get Historical 6 Month Behavior ********************************;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  sasdata.getdata5 as 
  select * from connection to teradata(

select

clb.cl_tid,
clb1.per_num,
clb1.life_ca_amt,
clb1.life_purch_amt,
clb1.mon_on_book_ct,
clb1.bill_dt,
clb1.last_pay_dt,
clb1.last_purch_dt,
clb1.last_ca_dt,
clb1.close_bal_amt,
clb1.open_bal_amt,
clb1.bucket_cd,
clb1.totl_pay_amt,
clb1.totl_sales_amt,
clpsm.segmt_id,
clpsm.engag_lvl_id,
coalesce(clba.totl_balc_bal_amt,0) as totl_balc_bal_amt,
pnl.apr_index_id,
clb1.purch_apr,
clb1.wght_avg_apr


FROM
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1
             
        join cl_bill clb1   
        on clb1.cl_tid=cl.cl_tid
        and clb1.per_num between &begpnum6 and &endpnum6

        join cl_pnl_vw pnl
	on clb1.cl_tid=pnl.cl_tid
	and clb1.per_num=pnl.per_num
        
	left outer JOIN cl_psm clpsm
        on clpsm.cl_tid=clb1.cl_tid
        and clpsm.per_num=clb1.per_num
        
        left outer join cl_bill_actv clba
	on clb1.cl_tid=clba.cl_tid
	and clb1.per_num=clba.per_num        
);

%put SAS Return Code:    &sqlrc;
%put SAS Number of Obs:  &sqlobs;
%put SQL Return Code:    &sqlxrc;
%put SQL Return Message: &sqlxmsg;

proc sort data=sasdata.getdata5;
by cl_tid per_num;
run;

proc print data=sasdata.getdata5 (obs=100);
run;

data sasdata.getseries(keep=cl_tid billdt1-billdt7 status1-status7 psmseg1-psmseg7 numflt1-numflt7 pay1-pay7 bcbal1-bcbal7
			mean_float_num std_float_num transactor_num mean_obal_amt numrecs mean_bill_num mean_pay_amt
			higher_wapr higher_apr new_rbp);

array astatus(7) $1 status1-status7;
array apsmseg(7) psmseg1-psmseg7;
array anumflt(7) numflt1-numflt7;
array abilldt(7) billdt1-billdt7;
array apaydt(7) paydt1-paydt7;
array aobal(7) obal1-obal7;
array abcbal(7) bcbal1-bcbal7;
array anumbll(7) numbll1-numbll7;
array apay(7) pay1-pay7;
array aaprind(7) aprind1-aprind7;
array apapr(7) papr1-papr7;
array awapr(7) wapr1-wapr7;

lastacct=0;
do until(lastacct=1);
set sasdata.getdata5;
by cl_tid;
i=&obspnum-per_num+1;
lastacct=last.cl_tid;

if i >0 and i<=7 then 
	do;
	apsmseg(i)=segmt_id;
	abilldt(i)=bill_dt;
	apaydt(i)=last_pay_dt;
	aobal(i)=open_bal_amt;
	apay(i)=totl_pay_amt;
	abcbal(i)=totl_balc_bal_amt;
	aaprind(i)=apr_index_id;
	apapr(i)=purch_apr;
	awapr(i)=wght_avg_apr;
	if ((life_ca_amt+life_purch_amt)=0) and (close_bal_amt=0) then astatus(i)='N';
	else if (missing(last_pay_dt)+missing(last_purch_dt)+missing(last_ca_dt))=3 and close_bal_amt=0 then astatus(i)='N';
	else if close_bal_amt=0 then astatus(i)='I';
	else if open_bal_amt=0 then astatus(i)='Z';
	else if bucket_cd not in ('0') then astatus(i)='D';
	else if totl_pay_amt>=open_bal_amt then astatus(i)='T';
	else if totl_sales_amt=0 then astatus(i)='P';
	else if totl_sales_amt ne 0 then astatus(i)='R';
	end;
end;
numrecs=i;

* Number of Float Days;
do j=1 to 5;
anumflt(j)=intck('day',abilldt(j+1),apaydt(j));
anumbll(j)=intck('day',abilldt(j+1),abilldt(j));

end;

* Transactor Number;
transactor_num=0;
k=0;
do until(k>5);
k=k+1;
if astatus(k)='T' then transactor_num=transactor_num+1;
else k=999;
end;


mean_float_num=mean(of numflt1-numflt6);
mean_bill_num=mean(of numbll1-numbll6);
std_float_num=std(of numflt1-numflt6);
mean_obal_amt=mean(of obal1-obal6);
mean_pay_amt=mean(of pay1-pay6);

if wapr1>wapr6 then higher_wapr=1; else higher_wapr=0;
if papr1>papr6 then higher_apr=1; else higher_apr=0;
if aprind6 not in ('4','5','6','7','8','9') and aprind1 in ('4','5','6','7','8','9') then new_rbp=1; else new_rbp=0;

run;


proc print data=sasdata.getseries (obs=30);
format billdt1-billdt7 mmddyy8.;
run;

proc means data=sasdata.getseries;
run;

* Part 6 Bseg;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  sasdata.getdata6 as 
  select * from connection to teradata(

select

clb.cl_tid,
bseg.BSEG_APR_INDEX_ID,
bseg.BSEG_BAL_AMT,
bseg.BSEG_NUM,
bseg.BSEG_OFFER_APR,
bseg.CATGY_CD,
bseg.MNTRY_CATGY_CD,
bseg.RBP_REASN_CD,
bseg.bseg_recv_dt,
bseg.bseg_type_cd,
bseg.BSEG_PAY_AMT,
bseg.BSEG_SALES_AMT,
bseg.BSEG_INTR_AMT,
bseg.FEE_AMT,
bseg.apr_type_cd,
bseg.SOURC_CD


FROM
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1

        JOIN cl_bseg bseg
        on clb.cl_tid=bseg.cl_tid
        and clb.per_num=bseg.per_num
        

);

%put SAS Return Code:    &sqlrc;
%put SAS Number of Obs:  &sqlobs;
%put SQL Return Code:    &sqlxrc;
%put SQL Return Message: &sqlxmsg;

* Part 7 Household credit protector;

proc sql;
  reset inobs=max outobs=max loops=max noflow nofeedback noprompt nonumber;
  connect to teradata(tdpid=edwprod user=sb86355 database=p_bcd_v_i_consumer password=&passwd.);
     
  CREATE TABLE sasdata.getdata7 AS
  SELECT * FROM CONNECTION TO teradata(

with temp_table (abilitec_addr_id) as (
select
 	h.abilitec_addr_id
from
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1
        
        join cl_abi_hh h
        on h.cl_tid=clb.cl_tid
	)


    SELECT t.abilitec_addr_id

      FROM temp_table t

	join cl_abi_hh h
	on t.abilitec_addr_id=h.abilitec_addr_id

      JOIN cl_bill clbs
        ON clbs.cl_tid = h.cl_tid
       AND clbs.per_num = &obspnum

      JOIN cl_crdt_prot_versn_vw cpv
        ON cpv.cl_tid = clbs.cl_tid
       AND clbs.bill_dt BETWEEN cpv.effct_start_dt AND cpv.effct_end_dt

     WHERE cpv.cmf_ins_cd IN ('D', 'K', 'P')
       AND cpv.cmf_enrol_cd IN ('2', '3', '4', '7')
       AND h.qtr_per_num=&hobspnum

    GROUP BY 1
);
     
proc sort data=sasdata.getdata7;
  by abilitec_addr_id;
run;

*Part 8 Household Credit Shield;
proc sql;
  reset inobs=max outobs=max loops=max noflow nofeedback noprompt nonumber;
  connect to teradata(tdpid=edwprod user=sb86355 database=p_bcd_v_i_consumer password=&passwd.);
     
  CREATE TABLE sasdata.getdata8 AS
  SELECT * FROM CONNECTION TO teradata(

with temp_table (abilitec_addr_id) as (
select
 	h.abilitec_addr_id
from
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1
        
        join cl_abi_hh h
        on h.cl_tid=clb.cl_tid
	)

     
    SELECT t.abilitec_addr_id

      FROM temp_table t

	join cl_abi_hh h
	on t.abilitec_addr_id=h.abilitec_addr_id

      JOIN cl_bill clbs
        ON clbs.cl_tid = h.cl_tid
       AND clbs.per_num = &obspnum

      JOIN cl_crdt_shld_versn_vw csv
        ON csv.cl_tid = clbs.cl_tid
       AND clbs.bill_dt BETWEEN csv.effct_start_dt AND csv.effct_end_dt

     WHERE csv.cmf_ins_cd IN ('B', 'Y')
       AND NOT csv.totl_claim_ct = 0
       AND h.qtr_per_num=&hobspnum

    GROUP BY 1 
);
     
proc sort data=sasdata.getdata8;
  by abilitec_addr_id;
run;

* Credit Protector/Shield Indicator;
data getcpcs;
set sasdata.getdata7 sasdata.getdata8;
run;

proc sort data=getcpcs nodupkey;
by abilitec_addr_id;
run;

proc sort data=sasdata.getdata2;
by abilitec_addr_id;
run;

data sasdata.getdata2;
merge sasdata.getdata2 (in=a) getcpcs (in=c);
by abilitec_addr_id;
credit_protector_shield_ind=c;
run;

*Part 9 Relationship Delinquency;
proc sql;
  reset inobs=max outobs=max loops=max noflow nofeedback noprompt nonumber;
  connect to teradata(tdpid=edwprod user=sb86355 database=p_bcd_v_i_consumer password=&passwd.);
     
  CREATE TABLE sasdata.getdata9 AS
  SELECT * FROM CONNECTION TO teradata(

with temp_table (abilitec_id) as (
select
 	ab.abilitec_id
from
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1
        
        join cl_abili ab
        on h.cl_tid=clb.cl_tid
	)

     
    SELECT t.abilitec_id

      FROM temp_table t

        join cl_abili ab
        on t.abilitec_id=ab.abilitec_id
        
        
      JOIN cl_bill clbs
        ON clbs.cl_tid = ab.cl_tid
       AND clbs.per_num = &obspnum

     WHERE clbs.bucket_cd IN ('2', '3', '4', '5', '6', 'B', 'C', 'D', 'E', 'F', 'b', 'c', 'd', 'e', 'f') 

    GROUP BY 1
);
     
proc sort data=sasdata.getdata9;
  by abilitec_id;
run;

*Part 10 Relationship Delinquency;
proc sql;
  reset inobs=max outobs=max loops=max noflow nofeedback noprompt nonumber;
  connect to teradata(tdpid=edwprod user=sb86355 database=p_bcd_v_i_consumer password=&passwd.);
     
  CREATE TABLE sasdata.getdata10 AS
  SELECT * FROM CONNECTION TO teradata(

with temp_table (abilitec_id) as (
select
 	ab.abilitec_id
from
        cl cl
        
        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb.per_num= &obspnum
        and clb.enr_ind=1
        and clb.open_ind=1
        
        join cl_abili ab
        on h.cl_tid=clb.cl_tid
	)

    SELECT t.abilitec_id

      FROM temp_table t

        join cl_abili ab
        on t.abilitec_id=ab.abilitec_id

      JOIN cl_bill clbs
        ON clbs.cl_tid = ab.cl_tid
       AND clbs.per_num = &obspnum

      JOIN cl_versn versn
        ON versn.cl_tid = clbs.cl_tid
       AND versn.cl_vid = clbs.cl_vid

     WHERE versn.acct_type_id NOT IN ('N', 'E') 

    GROUP BY 1 
);
     
proc sort data=sasdata.getdata10;
  by abilitec_id;
run;
 
proc sort data=sasdata.getdata1;
  by abilitec_id;
run;

data sasdata.getdata1;
merge sasdata.getdata1 (in=a) sasdata.getdata9 (in=b) sasdata.getdata10 (in=c);
  by abilitec_id;
if a;
bucket_cd_rel_ind=b;
acct_type_id_rel_ind=c;
run;

* Sort Datasets;
proc sort data=sasdata.getdata1;
by cl_tid;
run;

proc sort data=sasdata.getdata2;
by cl_tid;
run;

proc sort data=sasdata.getdata3;
by cl_tid;
run;

proc sort data=sasdata.getdata4;
by cl_tid;
run;

proc sort data=sasdata.getseries;
by cl_tid;
run;



* Merge Datsets;

data sasdata.all;
*set sasdata.all;
merge sasdata.getdata1 (in=a) sasdata.getdata2 (in=b) sasdata.getdata3 (in=c) sasdata.getdata4 (in=d) 
	sasdata.getseries (in=e drop=billdt1-billdt6);
by cl_tid;
if a and b and c;

* Define Tags;
* College Ind;
if schl_class_id in ('0','1','2','3','4','5','6','7','8','9','A','B') then college_ind=1;
else college_ind=0;


* AXPID2;
length axpid2 $1;

if portf_id in (4,9,10,11,15,17,18,24,85,143,144,145,146,255,276) and multi_lang_cd=2 then axpid2='Q';
else if schl_class_id in ('0','1','2','3','4','5','6','7','8','9','A','B') then axpid2='R';
else if portf_id in (9, 10, 11, 23, 24, 29, 85, 205, 206, 207, 254, 256, 257, 421) then axpid2='C';
else if portf_id in (255) then axpid2='B';
else if portf_id in (276) then axpid2='M';
else if portf_id in (4, 460, 655, 657) then axpid2='Z';
else if portf_id in (15, 17, 18) then axpid2='H';
else if portf_id in (143, 144, 145, 149) then axpid2='U';
else if portf_id in (146, 151) then axpid2='Y';
else if portf_id in (150) then axpid2='G';
else if portf_id in (208) then axpid2='J';
else if portf_id in (209) then axpid2='X';
else if portf_id in (202) then axpid2='P';
else if portf_id in (123, 124, 130, 131, 140, 141, 653) then axpid2='D';
else if portf_id in (728-737, 797-799) then axpid2='N';
else if portf_id in (260, 261) then axpid2='T';
else if portf_id in (170) then axpid2='E';
else if portf_id in (172) then axpid2='F';
else if portf_id in (300-303, 305-308, 318-319, 323-325, 326-327, 337-338, 339, 340-345, 349-351, 352, 363-368, 
			371, 373, 376, 381-382, 383, 386-388, 384-385, 389-399, 550-553, 558, 565-567, 569-571,
			574-586, 588-596, 603-611, 613-618, ) then axpid2='A';
else if portf_id in (560-562, 597, 600) then axpid2='L';
else if portf_id in (759 - 760, 762 - 763, 765 - 769, 771 - 772) then axpid2='K';
* Not Specified by DBM;
else if portf_id in (1, 2, 160, 161, 203, 204, 272) then axpid2='2';
else if portf_id in (273,277,278,279,280,281,282,283,284,285,286,462) then axpid2='1';
else axpid2='*';
  
length product $20.;
product=put(axpid2,$pidfmt.);
if portf_id=85 and missing(promo_id)=0 then product='Platinum TY';


* AXPROD for use by High Risk Credit Criteria;
  if ( ( portf_id = 4
      or 9 <= portf_id <= 11
      or 15 <= portf_id <= 18
      or portf_id = 24
      or portf_id = 85
      or portf_id = 209
      or portf_id = 255
      or portf_id = 276 
       ) 
   and (multi_lang_cd = 2)
     ) then axprod = 1;
  else if (portf_id = 587) then axprod = 2;
  else if ( 260 <= portf_id <= 261
         or portf_id = 654
          ) then axprod = 3;
  else if ( 143 <= portf_id <= 146
         or 149 <= portf_id <= 151
         or portf_id = 450
         or 452 <= portf_id <= 455
         or 125 <= portf_id <= 126
          ) then axprod = 4;
  else if ( portf_id = 631
         or portf_id = 633
         or portf_id = 635
          ) then axprod = 5;
  else if ( portf_id = 4
         or 6 <= portf_id <= 11
         or 14 <= portf_id <= 18
         or portf_id = 20
         or 23 <= portf_id <= 24
         or portf_id = 29
         or 30 <= portf_id <= 33
         or 39 <= portf_id <= 42
         or portf_id = 72
         or 80 <= portf_id <= 82
         or 85 <= portf_id <= 87
         or portf_id = 99
         or 123 <= portf_id = 124
         or 130 <= portf_id = 131
         or portf_id = 137
         or 140 <= portf_id <= 141
         or portf_id = 147
         or portf_id = 155
         or portf_id = 202
         or 205 <= portf_id <= 209
         or 254 <= portf_id <= 258
         or 262 <= portf_id <= 263
         or portf_id = 276
         or 420 <= portf_id <= 421
         or 423 <= portf_id <= 424
         or portf_id = 460
         or 486 <= portf_id = 487
         or 650 <= portf_id <= 653
         or portf_id = 422
         or 480 <= portf_id <= 481
         or portf_id = 468
         or portf_id = 461
         or portf_id = 463
         or portf_id = 655
         or portf_id = 657
          ) then axprod = 6;
  else if ( portf_id = 1
         or portf_id = 2
         or portf_id = 10
         or portf_id = 62
         or 134 <= portf_id <= 135
         or portf_id = 148
         or 160 <= portf_id <= 161
         or 203 <= portf_id <= 204
         or portf_id = 270
         or portf_id = 272
         or portf_id = 410
         or 639 <= portf_id <= 640
         or 91 <= portf_id <= 94
         or portf_id = 136
         or 156 <= portf_id <= 159
         or portf_id = 430
          ) then axprod = 7;
  else if ( portf_id = 630
         or portf_id = 632
          ) then axprod = 8;
  else if ( portf_id = 162
         or portf_id = 170
         or 172 <= portf_id <= 174
         or 353 <= portf_id <= 356
         or portf_id = 362
         or portf_id = 369
         or portf_id = 372
         or portf_id = 171
         or 185 <= portf_id <= 186
         or portf_id = 641
          ) then axprod = 9;
  else if ( 728 <= portf_id <= 737
         or 797 <= portf_id <= 799
          ) then axprod = 10;
  else if ( 774 <= portf_id <= 791
         or 795 <= portf_id <= 796
         or 800 <= portf_id <= 812
          ) then axprod = 11;
  else if ( 300 <= portf_id <= 302
         or 305 <= portf_id <= 307
         or 318 <= portf_id <= 319
         or 323 <= portf_id <= 327
         or 337 <= portf_id <= 339
         or 344 <= portf_id <= 345
         or 349 <= portf_id <= 350
         or portf_id = 352
         or 363 <= portf_id <= 364
         or 367 <= portf_id <= 368
         or portf_id = 371
         or 373 <= portf_id <= 375
         or 381 <= portf_id <= 387
         or 389 <= portf_id <= 392
         or 394 <= portf_id <= 399
         or 550 <= portf_id <= 553
         or portf_id = 558
         or 565 <= portf_id <= 566
         or 570 <= portf_id <= 573
         or 575 <= portf_id <= 584
         or portf_id = 588
         or 591 <= portf_id <= 596
         or portf_id = 601
         or 603 <= portf_id <= 608
         or 610 <= portf_id <= 611
         or 613 <= portf_id <= 618
         or portf_id = 303
         or portf_id = 308
         or portf_id = 351
         or 360 <= portf_id <= 361
         or 365 <= portf_id <= 366
         or portf_id = 388
         or portf_id = 393
         or 567 <= portf_id <= 569
         or portf_id = 574
         or 585 <= portf_id <= 586
         or 589 <= portf_id <= 590
         or portf_id = 609
          ) then axprod = 12;
  else if ( 759 <= portf_id <= 773 ) then axprod = 13;
  else if ( 559 <= portf_id <= 562
         or portf_id = 597
         or 599 <= portf_id <= 600
         or portf_id = 612
         or 636 <= portf_id <= 638
          ) then axprod = 14;
  else if ( portf_id = 273
         or 277 <= portf_id <= 286
         or portf_id = 462
          ) then axprod = 15;
  else if ( 314 <= portf_id < 317
         or 328 <= portf_id <= 336
         or portf_id = 370
         or 554 <= portf_id <= 557
          ) then axprod = 16;
  else if ( 738 <= portf_id <= 758
         or portf_id = 792
          ) then axprod = 17;
  else if ( 703 <= portf_id <= 727
         or 793 <= portf_id <= 794
         or 815 <= portf_id <= 816
          ) then axprod = 18;
  else if (265 <= portf_id <= 267) then axprod = 19;
  else axprod = 99;

* Bureau Reject Indicator;
  if ( rejct_reasn_cd = '01' 
    or rejct_reasn_cd = '02'
    or rejct_reasn_cd = '03'
    or rejct_reasn_cd = '04'
     ) then brj_1234 = 1;
  else brj_1234 = 0;

* Portfolio;
length portfolio $15;
portfolio=put(portf_id,portfmt.);
if college_ind=1 and missing(promo_id)=0 then product='COLLEGE REW';
else if college_ind=1 and missing(promo_id)=1 then product='COLLEGE NON-REW';


* PSM Segment;
length psm_segment $30;
psm_segment=put(segmt_id,psm2fmt.);

* Redem Indicator;
if missing(ptd_redem_pts)=1 then redem_ind=0;
else if ptd_redem_pts>0 then redem_ind=1;
else redem_ind=0;


* High Risk Criteria;
length high_risk_reason $5;
if credit_protector_shield_ind=1 then high_risk_reason='C01';
else if bucket_cd in ('2','3','4','5','6','B','C','D','E','F') or
	bucket_cd_rel_ind=1 then high_risk_reason='C02';
else if bankt_stat_cd in ('b','B') then high_risk_reason='C03';
else if write_off_stat_cd in ('2','3') then high_risk_reason='C04';
else if credt_montr_id='K' then high_risk_reason='C05';
else if cccs_cd='Y' then high_risk_reason='C06';
else if ( zip_cd = '10043'
    or zip_cd = '11120'
    or zip_cd = '57117'
    or zip_cd = '89163'
    or zip_cd = '00000'
    or '00002'<=zip_cd<='00599'
    or '96900'<=zip_cd<='96999'
    or ((not (axprod = 15)) and ('00600'<=zip_cd<='00999'))
    or ((axprod = 15) and ('00600'<=zip_cd<='00999'))
     ) then high_risk_reason='C07';
else if (bankt_ind = 1) then high_risk_reason='C08';
else if acct_stat_id not in ('00','20','21') then high_risk_reason='C09';
else if (secr_type_id in ('C','F','G','H','P','S')) then high_risk_reason='C10';
*C11 Address Line 1 or Address Line 2='C/O CCSI COLL SP-P';
else if ( substr(early_warn_refr_cd, 1, 2) = 'C#'
	or substr(early_warn_refr_cd, 1, 2) = 'CJ'
     	) then high_risk_reason='C12';
else if ( ( not ( axprod = 10 or 15 <= axprod <= 19 ) )
		and last_bad_check_dt ne . 
   		and bill_dt - last_bad_check_dt <= 90  
   		and 0 <= m4 < 70
   		and 0 <= bk4 < 65
   		  ) then high_risk_reason='C14';
  else if ( axprod = 10
        and last_bad_check_dt ne .
        and bill_dt - last_bad_check_dt <= 90
        and 0 <= m4 <= 71
          ) then high_risk_reason='C14';
else if (zip_cd = '00001' ) then high_risk_reason='C15';
else if ( '09000' <= zip_cd <= '09899'
    or '34000' <= zip_cd <= '34099'
    or '96200' <= zip_cd <= '96699'
     ) then high_risk_reason='C17';
else if plast_ct=0 then high_risk_reason='F01';
* F02: Account=Expired;
else if hot_card_stat_cd not in ('0','3','8') then high_risk_reason='F03';
else if phoen_cd in ('00','1D','2D','1G','2G','1H','2H','1N','2N','1Z','2Z') then high_risk_reason='F05';
else if (state_cd = '' or zip_cd = '') then high_risk_reason='F09';
else if acct_type_id_rel_ind=1 then high_risk_reason='M01';
else if ( ( not ( 10 <= axprod <= 14 
            or 16 <= axprod <= 19
             )
       ) 
   and ( strat_portf_id = 72
      or strat_portf_id = 73
      or strat_portf_id = 87
      or strat_portf_id = 88
      or strat_portf_id = 93
      or strat_portf_id = 94
       )
     ) then high_risk_reason='M02';
else if ( ( not ( 10 <= axprod <= 14
            or 16 <= axprod <= 19
             )
   	    )
   	and ( portf_id = 39
   	   or portf_id = 40
   	    )
     ) then high_risk_reason='M03';
else if ((12 <= axprod <= 14 or 16 <= axprod <= 19)
   	and ( portf_id in (310,316,335,346,347,348,357,358,359,360,369,374,375,377,379,380,568,619,620,621,622))) 
   	 then high_risk_reason='M04';
else if (totl_credt_limit = 0) then high_risk_reason='M06';
else if (portf_id = 173) then high_risk_reason='M07';
else if (636 <= portf_id <= 638) then high_risk_reason='M08';
else if (strat_portf_id = 89) then high_risk_reason='M09';

else  if ( ( 2 <= axprod <= 9
      or 11 <= axprod <= 12
      or 14 <= axprod <= 15
      or axprod = 99
       )
   and brj_1234 = 0 
   and ( 0 <= m4 <= 24
      or (0 <= m4 <= 39 and 0 <= bk4 <= 54)
      or (0 <= m4 <= 49 and 0 <= bk4 <= 44)
      or 0 <= bk4 <= 19
       )
     ) then high_risk_reason='S0104';
else if ( ( axprod = 10 or axprod = 13) and brj_1234 = 0
   	and ( 0 <= m4 <= 29 
      or (0 <= m4 <= 44 and 0 <= bk4 <= 59)
      or (0 <= m4 <= 54 and 0 <= bk4 <= 49)
      or 0 <= bk4 <= 24
       )
     ) then high_risk_reason='S0508';
else if ( ( not ( 10 <= axprod <= 14
            or 16 <= axprod <= 19
             )
       )
   and brj_1234 = 1
   and ( 0 <= m4 <= 29
      or (0 <= m4 <= 44 and 0 <= bk4 <= 59)
      or (0 <= m4 <= 54 and 0 <= bk4 <= 49)
      or 0 <= bk4 <= 24
       )
     ) then high_risk_reason='S0912';
else if ( 10 <= axprod <= 14
   	and brj_1234 = 1
     ) then high_risk_reason='S13';
else if ( axprod = 1
   and ( 0 <= m4 <= 26
      or (0 <= m4 <= 56 and 15 <= bk4 <= 27)
      or 0 <= bk4 <= 14
       )
     ) then high_risk_reason='U0103';
* E01-E42: Need to add Partnership Group Score Fails;
else if axprod in (16,17,18) then high_risk_reason='PG NS';
else high_risk_reason='PASS';

        

* Inactive Statement Months Variable;
if (life_ca_amt+life_purch_amt+close_bal_amt)=0 then inactive_months=mon_on_book_ct;
else if (missing(last_pay_dt)+missing(last_purch_dt)+missing(last_ca_dt))=3 and close_bal_amt=0 then inactive_months=mon_on_book_ct;
else inactive_months=intck('month',max(last_pay_dt,last_purch_dt,last_ca_dt),bill_dt);
if close_bal_amt ne 0 then inactive_months=0;

inactive_tag=put(inactive_months,mobfmt.);

* Account Activity Status;
* N= Never Active;
* I=Inactive;
* Z= Zero Open balance;
* D=Past Due;
* T=Transactor;
* P=Pay Down;
* R=Revolver;

length status $1;
if ((life_ca_amt+life_purch_amt)=0) and (close_bal_amt=0) then status='N';
else if (missing(last_pay_dt)+missing(last_purch_dt)+missing(last_ca_dt))=3 and close_bal_amt=0 then status='N';
else if close_bal_amt=0 then status='I';
else if open_bal_amt=0 then status='Z';
else if bucket_cd not in ('0') then status='D';
else if totl_pay_amt>=open_bal_amt then status='T';
else if totl_sales_amt=0 then status='P';
else if totl_sales_amt ne 0 then status='R';


* Define Channel;
length channel $3;

if scode_1||scode_2||scode_3 in ('2TJ','2DL','8TJ','2T1','2DM','2T3','84H','8DH','8TK','2TY','2EM') then channel='PHA';
else if scode_1||scode_2||scode_3 in ('HDP','HDN') then channel='AAC';
else if scode_1||scode_2||scode_3||scode_4||scode_5 in ('4TMUL','4TMU4','4TMDL','4DNML','4DNLL','4DNFP','4DNFM',
	'4DPMN','4DPML') then channel='NPS';
else if scode_1||scode_2||scode_3||scode_4||scode_5 in ('4DPFS','4D3FI','4D3FL','4T3F2','4T3FL','6U3GF','6U2FL') 
	then channel='ALT';


* Define Channel Specific variables: market_cell, campaign, product and other channel specific variables;

length segment $3;
if channel='PHA' then 
	do;
	market_cell=scode_18||scode_19;
	campaign=scode_4||put(scode_5,$phamfmt.);
	if scode_1||scode_2||scode_3 in ('2TJ','2T1','2TY') then product='PLAT'; 		
		else if scode_1||scode_2||scode_3='2DL' then product='DPNR';
		else if scode_1||scode_2||scode_3 in ('8TJ','8TK') then product='UCSV';
		else if scode_1||scode_2||scode_3='2DP' then product='SIMV'; 
		else if scode_1||scode_2||scode_3='2DM' then product='DPRR';
		else if scode_1||scode_2||scode_3='2T3' then product='DIVD';
		else if scode_1||scode_2||scode_3='84H' then product='UCSC';
		else if scode_1||scode_2||scode_3='8DH' then product='UCSR';
		else product='UNDF'; 	
	ecm_ind=(scode_14 in ('B','C','D','E','G','J','M') );
	new_prime=(scode_1||scode_2||scode_3 in ('2T1')); 
	hispanic=(scode_1||scode_2||scode_3 in ('2TY')); 

	* Define Segments;
	segment=put(scode_16,$seg2fmt.);
	end;
else if channel='NPS' then
	do;
	market_cell=scode_10||scode_11;
	campaign=scode_8||put(scode_9,$npsmfmt.);
	if scode_1||scode_2||scode_3||scode_4||scode_5 in ('4TMDT','4TMUL','4TMU4') then product='PLAT';
	else if scode_1||scode_2||scode_3||scode_4||scode_5 in ('4DNML','4DNLL','4DNFP','4DNFM') then product='DPNR';
	else if scode_1||scode_2||scode_3||scode_4||scode_5 in ('4DPMN','4DPML') then product='SIMV';
	else product='UNDF';
	ecm_ind=0; * Need to define for NPS;
	end;
else if channel='ALT' then
	do;
	market_cell=scode_10||scode_11;
	campaign=scode_8||put(scode_9,$npsmfmt.);
	if scode_1||scode_2||scode_3||scode_4||scode_5 in ('4T3F2','4T3FL') then product='PLAT';
	else if scode_1||scode_2||scode_3||scode_4||scode_5 in ('4D3FI','4D3FL') then product='DPNR';
	else if scode_1||scode_2||scode_3||scode_4||scode_5 in ('4DPFS') then product='SIMV';
	else if scode_1||scode_2||scode_3||scode_4||scode_5 in ('6U3GF','6U2FL') then product='UCSV';

	else product='UNDF';

	ecm_ind=0; * Need to define for Alternate Channel;

	end;


* Tags;
tag_line=put(totl_credt_limit,linefmt.);
tag_apr=put(purch_apr,aprfmt.);
tag_wapr=put(wght_avg_apr,aprfmt.);
tag_int=put(interest,intfmt.);
tag_bal=put(close_bal_amt,salefmt.);
tag_m3=put(m3_score_val,m3fmt.);
tag_fico=put(ficoscr,ficofmt.);
tag_class=put(schl_class_id,$clasfmt.);
tag_mob=put(mon_on_book_ct,mobfmt.);

* Balcon Balance Ind;
if bcbal1>0 then balcon_ind=1; else balcon_ind=0;

* Balcon Only;
if bcbal1>0 and bcbal1=close_bal_amt then balcon_only=1; else balcon_only=0;


run;


************************ Reports **********************************************************;
* Data Statistics;
proc freq data=sasdata.all;
tables psm_segment product portfolio schl_class_id segmt_id engag_lvl_id/ missing;
format segmt_id psm2fmt. engag_lvl_id engfmt.;
run;

proc means data=sasdata.all;
run;


* Part 7 performance data*********************************;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  sasdata.pnl as 
  select * from connection to teradata(

select

clb.cl_tid,
clb.per_num,
clb.mon_on_book_ct,
clb.open_ind,
clb.enr_ind,      
clb.bill_actv_ind,
clb.mon2_avg_bal_amt,
clb.close_bal_amt,
clb.volun_close_ind,
clb.new_close_ind,
coalesce(pnl.ca_bal_amt,0) as ca_bal_amt,
coalesce(pnl.new_balcon_amt,0) as new_balcon_amt,
pnl.totl_credt_limit,
clb.revlv_ind,
clb.totl_pay_amt,
clb.new_bankt_ind,
clb.new_gcl_ind,
clb.new_wo_ind,
pnl.purch_amt,
coalesce(pnl.ca_amt,0) as ca_amt,
clb.sales_actv_ind,
clb.totl_sales_amt,
clb.open_bal_amt,  
pnl.interest,
pnl.late_fees,
pnl.ocl_fee,
pnl.ua_balc_fee,
pnl.bad_chk_fee,
pnl.ua_annl_fee,
pnl.cash_adv_fee,
pnl.interchange,
pnl.aff_rebate,
pnl.cof,
pnl.gcl,
pnl.recovery,
pnl.recovery_ass_sale_amt,
pnl.totl_wo_bal_amt,
clb.buckt_1_ind,
clb.buckt_2_ind,
clb.buckt_3_ind,
clb.buckt_4_ind,
clb.buckt_5_ind,
clb.buckt_6_ind,
coalesce(pnl.ca_pay_amt,0) as ca_pay_amt,
coalesce(pnl.purch_pay_amt,0) as purch_pay_amt,
clb.wght_avg_apr,
coalesce(pnl.purch_bal_amt,0) as purch_bal_amt,
coalesce(pnl.ca_intr_amt,0) as ca_intr_amt,
coalesce(pnl.purch_intr_amt,0) as purch_intr_amt,
clb.purch_apr,
clb.ca_apr,
pnl.apr_index_id,
pnl.balc_fee_wo,
pnl.interest_wo,
coalesce(pnl.prior_ca_bal_amt,0) as prior_ca_bal_amt,
coalesce(pnl.prior_purch_bal_amt,0) as prior_purch_bal_amt,
clb.high_bill_bal_amt,
clb.life_ca_amt,
clb.life_purch_amt,
clb.bill_dt,
clb.last_pay_dt,
clb.last_purch_dt,
clb.last_ca_dt,
clb.bucket_cd,
clb.balcon_bseg_ct,
coalesce(clba.totl_balc_bal_amt,0) as totl_balc_bal_amt
        
from    cl cl
        
        join cl_bill clb1
        on clb1.cl_tid=cl.cl_tid
        and cl.cl_randm_digit=0
        and clb1.per_num= &obspnum
        and clb1.enr_ind=1
        and clb1.open_ind=1

        join cl_bill clb
        on clb.cl_tid=cl.cl_tid
        and clb.per_num between &begpnum6 and &endpnum
        
        join cl_pnl_vw pnl
	on clb.cl_tid=pnl.cl_tid
	and clb.per_num=pnl.per_num
	
        left outer join cl_bill_actv clba
	on clb.cl_tid=clba.cl_tid
	and clb.per_num=clba.per_num	

);

%put SAS Return Code:    &sqlrc;
%put SAS Number of Obs:  &sqlobs;
%put SQL Return Code:    &sqlxrc;
%put SQL Return Message: &sqlxmsg;


proc freq data=sasdata.pnl;
tables per_num;
run;

proc means data=sasdata.pnl;
run;


data sasdata.pnl;
set sasdata.pnl;
enr_ind_old=enr_ind;

if enr_ind=1 and open_ind=0 and open_bal_amt=0 and close_bal_amt=0 then enr_ind=0;

* Performance Status;
length status $1;
if enr_ind=0 then status='C';
else if ((life_ca_amt+life_purch_amt)=0) and (close_bal_amt=0) then status='N';
else if (missing(last_pay_dt)+missing(last_purch_dt)+missing(last_ca_dt))=3 and close_bal_amt=0 then status='N';
else if close_bal_amt=0 then status='I';
else if open_bal_amt=0 then status='Z';
else if bucket_cd not in ('0') then status='D';
else if totl_pay_amt>=open_bal_amt then status='T';
else if totl_sales_amt=0 then status='P';
else if totl_sales_amt ne 0 then status='R';


if per_num<6299 then ncm=interest-interest_wo-cof+late_fees+ocl_fee+ua_balc_fee-balc_fee_wo+bad_chk_fee+ua_annl_fee+cash_adv_fee+
	interchange-aff_rebate-gcl+recovery;
	else ncm=interest-cof+late_fees+ocl_fee+ua_balc_fee+bad_chk_fee+ua_annl_fee+cash_adv_fee+
	interchange-aff_rebate--(totl_wo_bal_amt - gcl)-gcl+recovery_ass_sale_amt
;
	
operating_exp=open_ind*0.84+bill_actv_ind*2.16+(buckt_1_ind+buckt_2_ind+buckt_3_ind+buckt_4_ind+buckt_5_ind+buckt_6_ind)*5.78;
bi=ncm-operating_exp;

run;




* PNL Performance Post;
proc sql;
create table pnlsum as
select 
a.product,
p.per_num,
sum(p.open_ind*p.enr_ind)                                       as open_accts_num,
sum(p.enr_ind)                                                  as enr_accts_num,
sum(p.bill_actv_ind*p.enr_ind*p.open_ind)                       as bill_active_open_accts_num,
sum(p.bill_actv_ind*p.enr_ind*(1-p.open_ind))                   as bill_active_close_accts_num,
sum(p.volun_close_ind*p.new_close_ind)                          as volun_close_accts_num,
sum((1-p.volun_close_ind)*p.new_close_ind)                      as involun_close_accts_num,
sum(p.mon2_avg_bal_amt*p.enr_ind)                               as anr_amt,
sum(p.close_bal_amt*p.enr_ind)                                  as close_bal_amt,
sum(p.open_bal_amt*p.enr_ind)                                   as open_bal_amt,
sum(p.ca_bal_amt*p.enr_ind)                                     as cash_bal_amt,
sum(p.purch_bal_amt*p.enr_ind)                                  as purchase_bal_amt,
sum(case when p.totl_sales_amt=p.late_fees and p.sales_actv_ind=1 then
        0 else p.sales_actv_ind*p.enr_ind end)                  as sales_active_accts_num,
sum(p.totl_sales_amt*p.enr_ind)                                 as sales_amt,
sum((p.purch_amt-p.new_balcon_amt-p.late_fees)*p.enr_ind)       as purchase_amt,
sum(p.ca_amt*p.enr_ind)                                         as cash_amt,
sum(p.new_balcon_amt*p.enr_ind)                                 as balcon_amt,
sum(p.totl_credt_limit*p.enr_ind*p.open_ind)                    as credit_limit_amt,
sum(p.revlv_ind*p.enr_ind)                                      as revlv_accts_num,
sum(p.totl_pay_amt*p.enr_ind)                                   as pay_amt,
sum(p.ca_pay_amt*p.enr_ind)                                     as cash_pay_amt,
sum(p.purch_pay_amt*p.enr_ind)                                  as purchase_pay_amt,
sum(p.interest)                                                 as interest_amt,
sum(p.cof)                                                      as cof_amt,
sum(p.late_fees)                                                as late_fee_amt,
sum(p.ocl_fee)                                                  as ocl_fee_amt,
sum(p.ua_balc_fee)                                              as balcon_fee_amt,
sum(case when p.per_num<6299 then p.interest_wo+p.balc_fee_wo 
	else p.totl_wo_bal_amt - p.gcl end)                     as adjustment_amt,
sum(p.bad_chk_fee)                                              as bad_check_fee_amt,
sum(p.ua_annl_fee)                                              as annual_fee_amt,
sum(p.cash_adv_fee)                                             as cash_fee_amt,
sum(p.interchange)                                              as interchange_amt,
sum(p.aff_rebate)                                               as affinity_rebate_amt,
sum(p.gcl)                                                      as gcl_amt,
sum(case when p.per_num<6299 then p.recovery 
	else pnl.recovery_ass_sale_amt)                         as recovery_amt,
sum(p.buckt_1_ind*p.enr_ind)                                    as cycle_1_accts_num,
sum(p.buckt_2_ind*p.enr_ind)                                    as cycle_2_accts_num,
sum(p.buckt_3_ind*p.enr_ind)                                    as cycle_3_accts_num,
sum(p.buckt_4_ind*p.enr_ind)                                    as cycle_4_accts_num,
sum(p.buckt_5_ind*p.enr_ind)                                    as cycle_5_accts_num,
sum(p.buckt_6_ind*p.enr_ind)                                    as cycle_6_accts_num,
sum(p.buckt_1_ind*p.enr_ind*p.close_bal_amt)                    as cycle_1_bal_amt,
sum(p.buckt_2_ind*p.enr_ind*p.close_bal_amt)                    as cycle_2_bal_amt,
sum(p.buckt_3_ind*p.enr_ind*p.close_bal_amt)                    as cycle_3_bal_amt,
sum(p.buckt_4_ind*p.enr_ind*p.close_bal_amt)                    as cycle_4_bal_amt,
sum(p.buckt_5_ind*p.enr_ind*p.close_bal_amt)                    as cycle_5_bal_amt,
sum(p.buckt_6_ind*p.enr_ind*p.close_bal_amt)                    as cycle_6_bal_amt,
sum(p.new_gcl_ind)                                              as gcl_accts_num,
sum(p.new_bankt_ind)                                            as bankrupt_accts_num,
sum(p.new_wo_ind)                                               as wo_accts_num,
sum(p.new_bankt_ind*p.gcl)                                      as bankrupt_amt,
sum(p.new_wo_ind*p.gcl)                                         as wo_amt,
sum(p.ca_intr_amt*p.enr_ind)                                    as cash_interest_amt,
sum(p.purch_intr_amt*p.enr_ind)                                 as purchase_interest_amt,
sum(p.purch_apr*p.enr_ind)                                      as purchase_apr,
sum(p.ca_apr*p.enr_ind)                                         as cash_apr,
sum(p.wght_avg_apr*p.enr_ind)                                   as wght_avg_apr,
sum((case when p.apr_index_id in ('4','5','6','7','8','9') 
        then 1 else 0 end)*p.enr_ind*p.close_bal_amt)           as punitive_bal_amt,
sum((case when p.apr_index_id in ('4','5','6','7','8','9') 
        then 1 else 0 end)*p.enr_ind)                           as punitive_accts_num,
sum((case when p.apr_index_id in ('4','5','6','7','8','9') 
        then 1 else 0 end)*p.enr_ind*p.purch_apr)               as punitive_apr,
sum(p.revlv_ind*p.enr_ind*p.close_bal_amt)                      as revlv_bal_amt,
sum(p.revlv_ind*p.enr_ind*p.wght_avg_apr)                       as revlv_wght_apr,
sum(case when (p.purch_amt-p.new_balcon_amt-p.late_fees)*p.enr_ind>0 then 1 else 0 end) as purchase_num,
sum((case when (p.buckt_1_ind+p.buckt_2_ind+p.buckt_3_ind+p.buckt_4_ind
	+p.buckt_5_ind+p.buckt_6_ind)>0 then 1 else 0 end)*p.enr_ind) as delq16_num,
sum((case when (p.buckt_1_ind+p.buckt_2_ind+p.buckt_3_ind+p.buckt_4_ind
	+p.buckt_5_ind+p.buckt_6_ind)>0 then p.close_bal_amt else 0 end)*p.enr_ind) as delq16_amt,
sum(p.operating_exp)						as operating_exp,
sum(p.bi)							as bi,
sum(p.totl_balc_bal_amt*p.enr_ind)				as totl_balc_bal_amt

from    sasdata.all a,
        sasdata.pnl p
        
where a.cl_tid=p.cl_tid

group by
a.product,
p.per_num
;
quit;

%csv(pnlsum,"pnlsum.txt");



%mend getdata;


%getdata(obspnum=6270,random==0,hobspnum=);

/* SDI */
/*
LEFT OUTER JOIN 

            sdi_acct_vw sdi

            on clb.cl_tid = sdi.cl_tid

            and sdi.qtr_per_num = &qtr_per_num
*/
	
	