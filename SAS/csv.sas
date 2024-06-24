 /*                                                                  */ 
 /* MODULE:   CSV                                                    */ 
 /* TYPE:     MODIFICATION                                           */ 
 /* AUTHOR:   PETER CZEGLEDI                                         */ 
 /* DATE:     4/4/97                                                 */ 
 /* SAS PGM:  BCV40.SAS.CNTL(CSV)                                    */ 
 /* DESC:     ELIMINATE EXTRANEOUS TRAILING BLANK ON ALPHA VARIABLES */ 
 /*           SORT NUMERIC SUFFIXES AS NUMERICS, NOT ALPHANUMERIC    */ 
 /*                                                                  */ 
 /* MODULE:   CSV                                                    */ 
 /* TYPE:     MODIFICATION                                           */ 
 /* AUTHOR:   PETER CZEGLEDI                                         */ 
 /* DATE:     4/4/97                                                 */ 
 /* SAS PGM:  BCV40.SAS.CNTL(CSV)                                    */ 
 /* DESC:     ALLOW DROPPING OR KEEPING VARIABLES AS A PARAMETER.    */ 
 /*           PARAMETER 4 IS THE DDNAME FOR A LIST OF KEEP VARIABLES.*/ 
 /*           PARAMETER 5 IS THE DDNAME FOR A LIST OF DROP VARIABLES.*/ 
 /*           EITHER PARAMETER 4 OR PARAMETER 5 CAN BE USED, BUT NOT */ 
 /*           BOTH.                                                  */ 
 /*                                                                  */ 
 /* MODULE:   COMMADLM                                               */ 
 /* TYPE:     MODIFICATION                                           */ 
 /* AUTHOR:   PETER CZEGLEDI                                         */ 
 /* DATE:     12/1/93                                                */ 
 /* SAS PGM:  BCV40.SAS.CNTL(COMMADLM)                               */ 
 /* DESC:     ELIMINATE LINE WRAPPING BECAUSE FTP ALLOWS UNLIMITED   */ 
 /*           LINE LENGTH                                            */ 
 /*                                                                  */ 
 /* MODULE:   COMMADLM                                               */ 
 /* TYPE:     ORIGINAL                                               */ 
 /* AUTHOR:   PETER CZEGLEDI                                         */ 
 /* DATE:     12/1/93                                                */ 
 /* SAS PGM:  BCV40.SAS.CNTL(COMMADLM)                               */ 
 /* DESC:     MACRO TO PRODUCE COMMA DELIMITED OUTPUT OF THE CONTENTS*/ 
 /*           OF A SAS DATASET TO BE USED IN PC SPREADSHEETS         */ 
 /*           PARAMETERS:                                            */ 
 /*           - THE FIRST PARAMETER IS THE SAS INPUT DATASET         */ 
 /*           - THE SECOND IS THE EXTERNAL OUTPUT FILE DD            */ 
 /*           - THE THIRD INDICATES WHETHER LABELS ARE TO BE USED    */ 
 /*             INSTEAD OF VARIABLE NAMES FOR THOSE VARIABLES THAT   */ 
 /*             WERE DEFINED WITH A LABEL IN THE HEADING LINE        */ 
 /*                                                                  */ 
  %MACRO CSV(SASDD,CSVDD,LAB);                            
  PROC CONTENTS DATA=&SASDD OUT=_COMMAD_  NOPRINT;                      
  RUN;                                                                  

%put -----------SASDD : &SASDD;
%put -----------CSVDD : &CSVDD;
                                                             
DATA _COMMAD_;                                                        
    DROP REVNAME NAMELEN DIGITS CHARS DIGIT1;                           
    LENGTH SORT2 4;                                                     
    SET _COMMAD_;                                                       
    REVNAME=REVERSE(TRIM(NAME));                                        
    NAMELEN=LENGTH(NAME);                                               
    DIGITS=INDEXC(REVNAME,'ABCDEFGHIJKLMNOPQRSTUVWXYZ_')-1;             
    CHARS =NAMELEN-DIGITS;                                              
    SORT1=SUBSTR(NAME,1,CHARS);                                         
    IF DIGITS GT 0 THEN                                                 
      DO;                                                               
        DIGIT1=CHARS+1;                                                 
        SORT2=INPUT(SUBSTR(NAME,DIGIT1),4.);                            
      END;                                                              
  RUN;                                                                  
  
  /* Sorts variables by position in the dataset */
  PROC SORT DATA=_COMMAD_;                                              
        by varnum;
  RUN;                                                                  
                                                                        
  DATA _NULL_;                                                          
    LENGTH V T R $ 5 N $ 4 L $ 40;                                      
    SET _COMMAD_ END=THATSALL;                                          
    VARCOUNT+1;                                                         
    IF _N_=1 THEN                                                       
      DO;                                                               
        RUN=1;                                                          
        SUMLEN=0;                                                       
      END;                                                              
    N=LEFT(PUT(_N_,4.));                                                
    SUBSTR(V,1,1)='V';                                                  
    SUBSTR(V,2)=N;                                                      
    SUBSTR(T,1,1)='T';                                                  
    SUBSTR(T,2)=N;                                                      
    SUBSTR(L,1,1)='L';                                                  
    SUBSTR(L,2)=N;                                                      
    SUBSTR(R,1,1)='R';                                                  
    SUBSTR(R,2)=N;                                                      
    IF LABEL='' THEN LABEL=NAME;                                        
    IF TYPE = 1 THEN                                                    
      DO;                                                               
        IF LENGTH=8 THEN LENGTH=17;                                     
         ELSE IF LENGTH=4 THEN LENGTH=10;                               
          ELSE IF LENGTH=2 THEN LENGTH=6;                               
      END;                                                              
    IF FORMATL THEN                                                     
      DO;                                                               
        IF TYPE =1 AND                                                  
           INDEXC(SUBSTR(FORMAT,1,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ') AND  
           NOT( FORMAT='E'     OR                                       
                FORMAT='FRACT' OR                                       
                FORMAT='Z'                                              
              ) THEN                                                    
        TYPE = 2;        /* FORCE DOUBLE QUOTE CHARACTER DELIMITING */  
        IF FORMATL > LENGTH THEN LENGTH=FORMATL;                        
      END;                                                              
    SUMLEN+LENGTH;                                                      
    IF SUMLEN > 999999999 THEN  /* ALLOW LEEWAY FOR INSERTED QUOTES */  
      DO;                                                               
        SUMLEN=LENGTH;                                                  
        RUN+1;                                                          
      END;                                                              
    CALL SYMPUT(V,TRIM(NAME));                                          
    CALL SYMPUT(T,TRIM(TYPE));                                          
    CALL SYMPUT(L,TRIM(LABEL));                                         
    CALL SYMPUT(R,TRIM(RUN));                                           
    RETAIN VARMAX;                                                      
    VARMAX=MAX(VARMAX,VARCOUNT);                                        
    IF THATSALL THEN                                                    
      DO;                                                               
        CALL SYMPUT('VARS',VARMAX);                                     
        CALL SYMPUT('RUNS',RUN);                                        
      END;                                                              
  RUN;                                                                  
  %DO J=1 %TO &RUNS;                                                    
  DATA _NULL_;                                                          
    _MINONE_=-1;                                                        
    SET &SASDD;                                                         
    FILE &CSVDD LRECL=16767 BLKSIZE=32760;                            
    IF _N_=1 THEN                                                       
      PUT                                                               
      %DO I=1 %TO &VARS;                                                
         %IF &I=1 %THEN @2 ;                                    
         %IF &J=&&R&I %THEN                                             
         %DO;                                                           
           %IF .&LAB=.LABEL %THEN                                       
             %UNQUOTE(%QUOTE(%'%"&&L&I%"%'));                           
            %ELSE %UNQUOTE(%QUOTE(%'%"&&V&I%"%'));                      
           %IF &I NE &VARS %THEN ',';                                   
         %END;                                                          
      %END;                                                             
      %STR(;)                                                           
    PUT @2                                                              
    %DO I=1 %TO &VARS;                                                                                          
       %IF &J=&&R&I %THEN                                               
       %DO;                                                             
         %IF &&T&I=2 %THEN '"';                                         
         &&V&I                                                          
         %IF &&T&I=2 %THEN +_MINONE_ '"';                               
         %IF &I NE &VARS %THEN %STR(",");                               
       %END;                                                            
    %END;                                                               
    ;                                                                   
  RUN;                                                                  
  %END;                                                                 
  %MEND CSV;                                                            
