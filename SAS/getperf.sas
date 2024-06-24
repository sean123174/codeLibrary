/***************************************************************************/
/* Title: ECM ARC PNL Code				                   */
/* Programer: Sean M. Burns                                                */
/***************************************************************************/
options compress=yes;
%include '/u/sburns/csv.sas';


%macro getdata(obspnum=,ecm_id=);

* Define Libnames;
libname sasdata '/camsrvr/largefile/Cards_DM/INTERNAL/sburns/';


* Defines Marco Variables;
%let begpnum=%eval(&obspnum+1);
%let endpnum=%eval(&obspnum+24);
%let begpnum6=%eval(&obspnum-5);
%let endpnum6=%eval(&obspnum-1);
%put endpnum = &endpnum;


* Check that last per_num of perfomance period does not exceed the last month per_num;
data _null_;
per_num= 6200+(year(date())-2000)*12+month(date())-1;

if &endpnum>per_num then 
call symput('endpnum',per_num);
call symput('per_num',per_num);
run;
%put per_num = &per_num;
%put endpnum = &endpnum;


* Part 1: Pull variables at selection month to define cash segments;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  sasdata.all as 
  select * from connection to teradata(

select

cl.cl_tid,
arc.ecm_id,
arc.markt_cell,
arc.promo_id

FROM

	cl cl
	        
	join ecm_arc_vw arc
	on arc.cl_tid=cl.cl_tid
	
	and arc.ecm_id=&ecm_id
	and (
	(arc.ecm_id=10307 and arc.promo_id=18 
			and arc.markt_cell in ('09001','09003','09046','09004','09006','09048','09007','09008',
	                '09010','09009','09011','09012','09013','09016','09014','09015',
	                '09017','09018','09019','09050','09020','09021','09022','09023',
	                '09024','09025','09026','09027','09028','09029','09030','09031',
	                '09052','09032','09033','09034','09035','09036','09037','09038',
	                '09039','09040','09041','09042','09043','09044'))
	or (arc.ecm_id=10403 and arc.promo_id=18 
			and arc.markt_cell in ('17060','17061','17062','17063','17064','17065'))
	or (arc.ecm_id=10505 and arc.promo_id=260 
			and arc.markt_cell in ('10100','10101','10102','10103','10104','10105','10106',
               		'10107','10108','10109','10110','10111','10112','10113','10114'))
	or (arc.ecm_id=10510 and arc.promo_id=279
			and arc.markt_cell in ('10101','10102','10103','10104','10111','10112','10113','10114','10115','10116',
			'10117','10118','10119','10120','10121','10122','10123','10124','10125','10126',
			'10127'))
	)



);

%put SAS Return Code:    &sqlrc;
%put SAS Number of Obs:  &sqlobs;
%put SQL Return Code:    &sqlxrc;
%put SQL Return Message: &sqlxmsg;


************************ Reports **********************************************************;
* Data Statistics;
proc freq data=sasdata.all;
tables ecm_id markt_cell cash_segment cash_treatment/ missing;
run;

proc means data=sasdata.all;
run;


* Performance data*********************************;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  tempdata.pnl as 
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
	        
	join ecm_arc_vw arc
	on arc.cl_tid=cl.cl_tid
	
	and arc.ecm_id=&ecm_id
	and (
	(arc.ecm_id=10307 and arc.promo_id=18 
			and arc.markt_cell in ('09001','09003','09046','09004','09006','09048','09007','09008',
	                '09010','09009','09011','09012','09013','09016','09014','09015',
	                '09017','09018','09019','09050','09020','09021','09022','09023',
	                '09024','09025','09026','09027','09028','09029','09030','09031',
	                '09052','09032','09033','09034','09035','09036','09037','09038',
	                '09039','09040','09041','09042','09043','09044'))
	or (arc.ecm_id=10403 and arc.promo_id=18 
			and arc.markt_cell in ('17060','17061','17062','17063','17064','17065'))
	or (arc.ecm_id=10505 and arc.promo_id=260 
			and arc.markt_cell in ('10100','10101','10102','10103','10104','10105','10106',
               		'10107','10108','10109','10110','10111','10112','10113','10114'))
	or (arc.ecm_id=10510 and arc.promo_id=279
			and arc.markt_cell in ('10101','10102','10103','10104','10111','10112','10113','10114','10115','10116',
			'10117','10118','10119','10120','10121','10122','10123','10124','10125','10126',
			'10127'))
	)

             
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


proc freq data=tempdata.pnl;
tables per_num;
run;

proc means data=tempdata.pnl;
run;


data tempdata.pnl;
set tempdata.pnl;
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

ncm=interest-interest_wo-cof+late_fees+ocl_fee+ua_balc_fee-balc_fee_wo+bad_chk_fee+ua_annl_fee+cash_adv_fee+
	interchange-aff_rebate-gcl+recovery;
operating_exp=open_ind*0.84+bill_actv_ind*2.16+(buckt_1_ind+buckt_2_ind+buckt_3_ind+buckt_4_ind+buckt_5_ind+buckt_6_ind)*5.78;
bi=ncm-operating_exp;

run;


* Bseg;
proc sql;
reset INOBS=MAX OUTOBS=MAX LOOPS=MAX NOFLOW NOFEEDBACK NOPROMPT NONUMBER ;
  connect to teradata(database=p_bcd_v_i_consumer TDPID=edwprod user=sb86355 password=&passwd);
  
  create table  tempdata.bseg as 
  select * from connection to teradata(

select

bseg.cl_tid,
bseg.per_num,
sum(bseg.bseg_bal_amt*clb.enr_ind) as total_bseg_bal,
sum(case when bseg.catgy_cd=2 then bseg.bseg_bal_amt*clb.enr_ind else 0 end) as balcon_bsegbal_amt,
sum(case when bseg.mntry_catgy_cd='P' and bseg.catgy_cd=1 then bseg.bseg_bal_amt*clb.enr_ind else 0 end) as purch_bsegbal_amt,
sum(case when bseg.mntry_catgy_cd='C' and bseg.catgy_cd=1 then bseg.bseg_bal_amt*clb.enr_ind else 0 end) as cash_bsegbal_amt,

sum(bseg.bseg_sales_amt*clb.enr_ind) as total_bseg_sales_amt,
sum(case when bseg.catgy_cd=2 then bseg.bseg_sales_amt*clb.enr_ind else 0 end) as other_balcon_sales_amt,
sum(case when bseg.mntry_catgy_cd='P' and bseg.catgy_cd=1 then bseg.bseg_sales_amt*clb.enr_ind else 0 end) as purch_bseg_sales_amt,
sum(case when bseg.mntry_catgy_cd='C' and bseg.catgy_cd=1 then bseg.bseg_sales_amt*clb.enr_ind else 0 end) as cash_bseg_sales_amt,

sum(bseg.bseg_pay_amt*clb.enr_ind) as total_bseg_pay_amt,
sum(case when bseg.catgy_cd=2 then bseg.bseg_pay_amt*clb.enr_ind else 0 end) as other_balcon_pay_amt,
sum(case when bseg.mntry_catgy_cd='P' and bseg.catgy_cd=1 then bseg.bseg_pay_amt*clb.enr_ind else 0 end) as purch_bseg_pay_amt,
sum(case when bseg.mntry_catgy_cd='C' and bseg.catgy_cd=1 then bseg.bseg_pay_amt*clb.enr_ind else 0 end) as cash_bseg_pay_amt,


sum(bseg.bseg_bal_amt*bseg.bseg_offer_apr*clb.enr_ind) as total_bseg_apr,
sum(case when bseg.catgy_cd=2 then bseg.bseg_bal_amt*bseg.bseg_offer_apr*clb.enr_ind else 0 end) as other_balcon_apr,
sum(case when bseg.mntry_catgy_cd='P' and bseg.catgy_cd=1 then bseg.bseg_bal_amt*bseg.bseg_offer_apr*clb.enr_ind else 0 end) as purch_bseg_apr,
sum(case when bseg.mntry_catgy_cd='C' and bseg.catgy_cd=1 then bseg.bseg_bal_amt*bseg.bseg_offer_apr*clb.enr_ind else 0 end) as cash_bseg_apr,

sum(bseg.bseg_intr_amt*clb.enr_ind) as total_bseg_intr_amt,
sum(case when bseg.catgy_cd=2 then bseg.bseg_intr_amt*clb.enr_ind else 0 end) as other_balcon_intr_amt,
sum(case when bseg.mntry_catgy_cd='P' and bseg.catgy_cd=1 then bseg.bseg_intr_amt*clb.enr_ind else 0 end) as purch_bseg_intr_amt,
sum(case when bseg.mntry_catgy_cd='C' and bseg.catgy_cd=1 then bseg.bseg_intr_amt*clb.enr_ind else 0 end) as cash_bseg_intr_amt,

max(bseg.bseg_num) as max_bseg_num,

count(*) as numrecs



FROM
	cl cl
	        
	join ecm_arc_vw arc
	on arc.cl_tid=cl.cl_tid
	
	and arc.ecm_id=&ecm_id
	and (
	(arc.ecm_id=10307 and arc.promo_id=18 
			and arc.markt_cell in ('09001','09003','09046','09004','09006','09048','09007','09008',
	                '09010','09009','09011','09012','09013','09016','09014','09015',
	                '09017','09018','09019','09050','09020','09021','09022','09023',
	                '09024','09025','09026','09027','09028','09029','09030','09031',
	                '09052','09032','09033','09034','09035','09036','09037','09038',
	                '09039','09040','09041','09042','09043','09044'))
	or (arc.ecm_id=10403 and arc.promo_id=18 
			and arc.markt_cell in ('17060','17061','17062','17063','17064','17065'))
	or (arc.ecm_id=10505 and arc.promo_id=260 
			and arc.markt_cell in ('10100','10101','10102','10103','10104','10105','10106',
               		'10107','10108','10109','10110','10111','10112','10113','10114'))
	or (arc.ecm_id=10510 and arc.promo_id=279
			and arc.markt_cell in ('10101','10102','10103','10104','10111','10112','10113','10114','10115','10116',
			'10117','10118','10119','10120','10121','10122','10123','10124','10125','10126',
			'10127'))
	)
 

 	JOIN cl_bill clb
 	on arc.cl_tid=clb.cl_tid
 	and clb.per_num between &begpnum6 and &endpnum
 	
        JOIN cl_bseg bseg
        on clb.cl_tid=bseg.cl_tid
        and bseg.per_num=clb.per_num

group by
bseg.cl_tid,
bseg.per_num
);

%put SAS Return Code:    &sqlrc;
%put SAS Number of Obs:  &sqlobs;
%put SQL Return Code:    &sqlxrc;
%put SQL Return Message: &sqlxmsg;

proc means data=tempdata.bseg;
run;


* PNL Performance Post;
proc sql;
create table pnlsum as
select 
a.markt_cell,
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
sum(p.interest_wo)                                              as interest_wo_amt,
sum(p.cof)                                                      as cof_amt,
sum(p.late_fees)                                                as late_fee_amt,
sum(p.ocl_fee)                                                  as ocl_fee_amt,
sum(p.ua_balc_fee)                                              as balcon_fee_amt,
sum(p.balc_fee_wo)                                              as balcon_fee_wo_amt,
sum(p.bad_chk_fee)                                              as bad_check_fee_amt,
sum(p.ua_annl_fee)                                              as annual_fee_amt,
sum(p.cash_adv_fee)                                             as cash_fee_amt,
sum(p.interchange)                                              as interchange_amt,
sum(p.aff_rebate)                                               as affinity_rebate_amt,
sum(p.gcl)                                                      as gcl_amt,
sum(p.recovery)                                                 as recovery_amt,
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
sum(b.total_bseg_bal) 						as total_bseg_bal,
sum(b.balcon_bsegbal_amt) 					as balcon_bsegbal_amt,
sum(b.purch_bsegbal_amt) 					as purch_bsegbal_amt,
sum(b.cash_bsegbal_amt) 					as cash_bsegbal_amt,
sum(b.total_bseg_sales_amt) 					as total_bseg_sales_amt,
sum(b.other_balcon_sales_amt) 					as other_balcon_sales_amt,
sum(b.purch_bseg_sales_amt) 					as purch_bseg_sales_amt,
sum(b.cash_bseg_sales_amt) 					as cash_bseg_sales_amt,
sum(b.total_bseg_pay_amt) 					as total_bseg_pay_amt,
sum(b.other_balcon_pay_amt) 					as other_balcon_pay_amt,
sum(b.purch_bseg_pay_amt) 					as purch_bseg_pay_amt,
sum(b.cash_bseg_pay_amt) 					as cash_bseg_pay_amt,
sum(b.total_bseg_apr) 						as total_bseg_apr,
sum(b.other_balcon_apr) 					as other_balcon_apr,
sum(b.purch_bseg_apr) 						as purch_bseg_apr,
sum(b.cash_bseg_apr) 						as cash_bseg_apr,
sum(b.total_bseg_intr_amt) 					as total_bseg_intr_amt,
sum(b.other_balcon_intr_amt) 					as other_balcon_intr_amt,
sum(b.purch_bseg_intr_amt) 					as purch_bseg_intr_amt,
sum(b.cash_bseg_intr_amt) 					as cash_bseg_intr_amt


from    sasdata.all a,
        tempdata.pnl p,
        tempdata.bseg b
        
where a.cl_tid=p.cl_tid
and p.cl_tid=b.cl_tid
and p.per_num=b.per_num


group by
a.markt_cell,
p.per_num
;
quit;

%csv(pnlsum,"pnlsum_&ecm_id..txt");


%mend;

%getdata(obspnum=6253,ecm_id=10403);

%getdata(obspnum=6265,ecm_id=10505);
%getdata(obspnum=6270,ecm_id=10510);









