/* Labeling States on a United States Map */

/* Set graphics options */

goptions reset=global ftext=zapfi htext=4 gunit=pct
         cback=white colors=(black) border;

/******************************************************************/
/* Create the response data set, POP. The data for POP contains   */
/* state abbreviations (ST) and the percent of population change  */
/* for each state (CHANGE). The STFIPS function converts the      */
/* two-letter postal codes to numeric FIPS codes (STATE) that can */
/* be used as an identification variable with the map data set,   */ 
/* MAPS.USCENTER.                                                 */
/******************************************************************/

data pop(drop=st);
   input st $ change @@;
   state=stfips(st);
   cards;
AR	0.0300
MT	0.0416
FL	0.0331
OK	0.0240
KY	0.0334
PR	0.0319
CT	0.0253
UT	0.0339
MN	0.0294
MI	0.0331
IN	0.0316
DE	0.0241
LA	0.0277
WV	0.0380
PA	0.0304
HI	0.0294
WA	0.0311
WI	0.0342
NE	0.0320
TN	0.0320
IA	0.0300
ND	0.0425
NV	0.0367
NY	0.0243
AZ	0.0297
MA	0.0225
SC	0.0345
TX	0.0264
NC	0.0288
GA	0.0354
MS	0.0317
OH	0.0311
ID	0.0297
ME	0.0303
CA	0.0319
NH	0.0324
NJ	0.0291
AL	0.0315
KS	0.0334
MO	0.0251
DC	0.0306
VI	0.0300
MD	0.0247
NM	0.0269
VA	0.0273
CO	0.0284
SD	0.0338
IL	0.0253
AK	0.0411
RI	0.0341
OR	0.0305
VT	0.0275
WY	0.0488
;
run;

/*****************************************************************/
/* Create the Annotate data set, MAPLABEL, from MAPS.USCENTER.   */
/* MAPLABEL labels each state with a two-letter abbreviation.    */
/* MAPS.USCENTER provides the x and y coordinates for the labels */
/* FLAG, which is initially turned off, signals when external    */
/* labeling is in effect. The labels are drawn after the map     */
/* because the value of WHEN is a (after).                       */
/*****************************************************************/

data maplabel;
   length function $ 8;
   retain flag 0 xsys ysys '2' hsys '3' when 'a' style 'swissb';
   set maps.uscenter(where=(fipstate(state) ne 'DC') drop=long lat);
   
      function='label'; text=fipstate(state); size=2.5; position='5';
   
     /* The FIPSTATE function creates the label   */
     /* text by converting the FIPS codes from    */
     /* MAPS.USCENTER to two-letter postal codes. */

   if ocean='Y' then               
      do;                          
         position='6'; output;    
         function='move';                                                      
         flag=1;
      end;
      
  /* If the labeling coordinates are outside the state (OCEAN='Y'), Annotate    */
  /* adds the label and prepares to draw the leader line. Note: OCEAN is a      */
  /* character variable and is therefore case sensitive. OCEAN='Y' must specify */
  /* an uppercase Y.                                                            */
      
  /* When external labeling is in effect, Annotate */
  /* draws the leader line and resets the flag.    */                                            
   else if flag=1 then            
      do;                                                                   
         function='draw'; size=.5;
         flag=0;
      end;
   output;
run;
  /* Create a format for the value of CHANGE. The PCHANGE. */
proc format;                                   
   value pchange   
                   low - 0.025     = '<2.5%'  /* population values.                                  */
                 .025001 - 0.03    = '3%'
                 0.03001 - 0.04   = '4%'
                 0.04001 - high  = '>4%';
run;

/****************************************************************/
/* Define patterns for the map.  Pattern colors are gray-scale  */
/* values ranging from GRAY44 (dark gray) to GRAYFF (white).    */
/* Because patterns are assigned in order to response values,   */
/* beginning with the lowest value, the patterns are ordered    */
/* from lightest to darkest, so that white represents the least */
/* change and dark gray the most.                               */
/****************************************************************/

pattern1 value=solid color=grayff;    /* white */
pattern2 value=solid color=gray99;
pattern3 value=solid color=gray77;
pattern4 value=solid color=gray55;
*pattern5 value=solid color=gray77;
*pattern6 value=solid color=gray44;    /* dark gray */

/*****************************************************************/
/* Add titles and footnotes. The null FOOTNOTE3 statement shifts */
/* the map left to make room for the legend.                     */
/*****************************************************************/

title1 height=6 'Tabling Volume by States';
footnote1 justify=left ' Source: DM/College RAT Database';
footnote3 height=10 angle=90 ' ';

/***********************************************************************/
/* Modify the position and appearance of the legend. ACROSS=1 places   */
/* the entries in a single column. ORIGIN= positions the legend to     */
/* the right of the map.  MODE=SHARE allows the legend to occupy space */
/* allocated to the map.                                               */
/***********************************************************************/

legend1 label=none shape=bar(4,3) value=(height=2) across=1 origin=(78,18)
        mode=share;

/************************************************************************/
/* Produce the map. The CHORO statement includes the annotation defined */
/* in the MAPLABEL data set.  DISCRETE is added so that each formatted  */
/* value of CHANGE is treated as a separate response level.             */
/************************************************************************/

proc gmap data=pop map=maps.us;
   format change pchange.;
   id state;
   choro change / legend=legend1 discrete coutline=black annotate=maplabel;
run;
quit;
