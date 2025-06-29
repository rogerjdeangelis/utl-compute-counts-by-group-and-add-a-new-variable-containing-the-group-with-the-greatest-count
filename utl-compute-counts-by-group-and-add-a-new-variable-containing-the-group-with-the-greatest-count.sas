%let pgm=utl-compute-counts-by-group-and-add-a-new-variable-containing-the-group-with-the-greatest-count;

%stop_submission;

Compute counts by group and add a new variable containing the group with the greatest count

PROBLEM (DOES NOT REQUIRE BP COLUMN)
                                                MOST
     INPUT                    OUTPUT            FREQUENT
  SEX    BP             SEX1  N1    SEX2  N2    SEX

   M     N(normal)       F     4     M     3    F (more females than males)
   M     L(LOW)
   F     H(Highh)
   M     N
   F     L
   F     N
   F     L

  CONTENTS

     1 sas sql (pure sql solution)

     2 r sql (pure sql solution)
       (same code works in (r, python, octave-matlab and excel)
       see https://tinyurl.com/yt5v5ca3

     3 Notes aboout Art's transpose macro

github
https://tinyurl.com/nhjn367f
https://github.com/rogerjdeangelis/utl-compute-counts-by-group-and-add-a-new-variable-containing-the-group-with-the-greatest-count
                                                                           U
NOTE: SAS does not allow the 'order by clause' in a subquery.

github
https://tinyurl.com/yt5v5ca3
https://github.com/rogerjdeangelis/utl-cumulative-sum-by-group-in-the-order-of-rank-variable-sas-and-sql-r-python-octave-excel

related
https://tinyurl.com/3nfdf5rn
https://communities.sas.com/t5/SAS-Programming/Getting-frequency-counts-for-different-values-of-a-variable-by/m-p/774213#M246034

/**************************************************************************************************************************/
/*   INPUT                    |  PROCESS                                            |  OUTPUT                             */
/*   ====                     |  =======                                            |  ======                             */
/* SD1.HAVE                   |  1 SAS SQL                                          |  SEX1  N1    SEX2  N2    MAXSEX     */
/* ========                   |  =========                                          |                                     */
/*                            |                                                     |   F     4     M     3       F       */
/*                            |  Process                                            |                                     */
/* SEX    BP                  |   1 Select counts by sex                            |                                     */
/*                            |     then order by descending count                  |                                     */
/*  M     N                   |     and select the first obsevation                 |                                     */
/*  M     N                   |   2 create a table with counts by sex               |                                     */
/*  F     L                   |     and left join the sex from step 1               |                                     */
/*  M     H                   |   3 transpose to one observation of                 |                                     */
/*  F     L                   |     four columns Male MailCount                     |                                     */
/*  F     N                   |     Female FemaleCount                              |                                     */
/*  F     L                   |     Asts transpose macro can be used                |                                     */
/*                            |                                                     |                                     */
/*                            |                                                     |                                     */
/*                            |   1 SAS SQL                                         |                                     */
/*                            |   =========                                         |                                     */
/*                            |                                                     |                                     */
/* options                    |   proc sql;                                         |                                     */
/*  validvarname=upcase;      |   reset outobs=1;                                   |                                     */
/* libname sd1 "d:/sd1";      |   select                                            |                                     */
/* data sd1.have;             |      sex                                            |                                     */
/*  input sex$ bp$ @@;        |     ,count(*) as cnt                                |                                     */
/* cards4;                    |   into                                              |                                     */
/* M N                        |     :sex                                            |                                     */
/* M N                        |    ,:cnt                                            |                                     */
/* M L                        |   from                                              |                                     */
/* F H                        |     sd1.have                                        |                                     */
/* F L                        |   group                                             |                                     */
/* F N                        |     by sex                                          |                                     */
/* F L                        |   order                                             |                                     */
/* ;;;;                       |    by calculated cnt desc;                          |                                     */
/* run;quit;                  |                                                     |                                     */
/*                            |   reset outobs=max;                                 |                                     */
/*                            |   create                                            |                                     */
/*                            |     table sqlout as                                 |                                     */
/*                            |   select                                            |                                     */
/*                            |     sex                                             |                                     */
/*                            |    ,count(*)  as cnt                                |                                     */
/*                            |   from                                              |                                     */
/*                            |     sd1.have                                        |                                     */
/*                            |   group                                             |                                     */
/*                            |     by sex ;                                        |                                     */
/*                            |                                                     |                                     */
/*                            |   create                                            |                                     */
/*                            |     table want as                                   |                                     */
/*  SEX1    N1    SEX2    N2  |   select                                            |                                     */
/*                            |     max(case when (sex='F') then 'F'  end) as sex1  |                                     */
/*   F       4     M       3  |    ,max(case when (sex='F') then  cnt end) as N1    |                                     */
/*                            |    ,max(case when (sex='M') then 'M'  end) as sex2  |                                     */
/*                            |    ,max(case when (sex='M') then  cnt end) as N2    |                                     */
/*                            |    ,"&sex" as maxsex                                |                                     */
/*                            |   from                                              |                                     */
/*                            |     sqlout                                          |                                     */
/*                            |  ;quit;                                             |                                     */
/*                            |                                                     |                                     */
/*                            |-------------------------------------------------------------------------------------------*/
/*                            |                                                     |                                     */
/*                            |   2 R SQL                                           |                                     */
/*                            |   =======                                           |                                     */
/*                            |                                                     |                                     */
/*                            |   %utl_rbeginx;                                     |                                     */
/*                            |   parmcards4;                                       |                                     */
/*                            |   library(haven)                                    |                                     */
/*                            |   library(sqldf)                                    |                                     */
/*                            |   source("c:/oto/fn_tosas9x.R")                     |                                     */
/*                            |   options(sqldf.dll = "d:/dll/sqlean.dll")          |                                     */
/*                            |   have<-read_sas("d:/sd1/have.sas7bdat")            |                                     */
/*                            |   print(have)                                       |                                     */
/*                            |   want<-sqldf("                                     |                                     */
/*                            |    with                                             |                                     */
/*                            |      _temp_ as (                                    |                                     */
/*                            |    select                                           |                                     */
/*                            |      sex                                            |                                     */
/*                            |     ,count(*) as cnt                                |                                     */
/*                            |     ,(select                                        |                                     */
/*                            |          sex                                        |                                     */
/*                            |       from                                          |                                     */
/*                            |          have                                       |                                     */
/*                            |       group                                         |                                     */
/*                            |          by sex                                     |                                     */
/*                            |        order                                        |                                     */
/*                            |          by count(*) desc limit 1) as maxsex        |                                     */
/*                            |    from                                             |                                     */
/*                            |      have                                           |                                     */
/*                            |    group                                            |                                     */
/*                            |      by sex  )                                      |                                     */
/*                            |    select                                           |                                     */
/*                            |      max(case when (sex='F') then 'F'  end) as sex1 |                                     */
/*                            |     ,max(case when (sex='F') then  cnt end) as N1   |                                     */
/*                            |     ,max(case when (sex='M') then 'M'  end) as sex2 |                                     */
/*                            |     ,max(case when (sex='M') then  cnt end) as N2   |                                     */
/*                            |     ,maxsex                                         |                                     */
/*                            |    from                                             |                                     */
/*                            |      _temp_                                         |                                     */
/*                            |    ")                                               |                                     */
/*                            |    want;                                            |                                     */
/*                            |    fn_tosas9x(                                      |                                     */
/*                            |         inp    = want                               |                                     */
/*                            |        ,outlib ="d:/sd1/"                           |                                     */
/*                            |        ,outdsn ="want"                              |                                     */
/*                            |        )                                            |                                     */
/*                            |   ;;;;                                              |                                     */
/*                            |   %utl_rendx;                                       |                                     */
/*                            |                                                     |                                     */
/*                            |-------------------------------------------------------------------------------------------*/
/*                            |                                                     |                                     */
/*                            |   3 ART'S TRANSPOSE                                 |   MAXSEX   SEX1 CNT1    SEX2 CNT2   */
/*                            |   =================                                 |                                     */
/*                            |                                                     |     F       F     4      M     3    */
/*                            |   SUPPOSE YOU WANT TO TRANSPOSE                     |                                     */
/*                            |                                                     |                                     */
/*                            |   WORK.SQLOUT                                       |                                     */
/*                            |                                                     |                                     */
/*                            |    SEX    CNT    MAXSEX                             |                                     */
/*                            |                                                     |                                     */
/*                            |     F      4       F                                |                                     */
/*                            |     M      3       F                                |                                     */
/*                            |                                                     |                                     */
/*                            |   THIS DOES NOT WORK                                |                                     */
/*                            |                                                     |                                     */
/*                            |   proc transpose data=sqlout out=fat;               |                                     */
/*                            |   by maxsex;                                        |                                     */
/*                            |   var sex cnt;                                      |                                     */
/*                            |   run;quit;                                         |                                     */
/*                            |                                                     |                                     */
/*                            |    _NAME_     COL1    COL2                          |                                     */
/*                            |                                                     |                                     */
/*                            |     SEX         F       M                           |                                     */
/*                            |     CNT         4       3                           |                                     */
/*                            |                                                     |                                     */
/*                            |   This does work Art's Macro                        |                                     */
/*                            |                                                     |                                     */
/*                            |   %utl_transpose(                                   |                                     */
/*                            |     data=sqlout                                     |                                     */
/*                            |    ,out=xpo                                         |                                     */
/*                            |    ,var=sex cnt                                     |                                     */
/*                            |    ,by=maxsex                                       |                                     */
/*                            |    );                                               |                                     */
/*                            |                                                     |                                     */
/*                            |    MAXSEX   SEX1 CNT1    SEX2 CNT2                  |                                     */
/*                            |                                                     |                                     */
/*                            |      F       F     4      M     3                   |                                     */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
