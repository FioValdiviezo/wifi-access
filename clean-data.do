
/*---------------------------------------------------------------------------------------------------
  Internet Acces by region 
* Author	: Fiorella E. Valdiviezo (fiorella.valdiviezo@alum.udep.edu.pe)
* Objetive	: Analyze inequality in internet access by region and age.
---------------------------------------------------------------------------------------------------*/

*------------------------------------------------------------------
*						DATA PREPARATION
*------------------------------------------------------------------
****************************************
************* MODULO EDUCACION**********
clear all
*set mem 600m antes era para ampliar la memoria pero ahora se hace automaticamente
set more off

global dir "C:\Users\Z50-CORE-I5\Desktop\Social Mobility Measure\Gaps Measure"

cd "$dir"

use "$dir\sumaria-2020.dta"

* Verficamos los ID del modulo 300 (Nivel persona)
cap isid ubigeo conglome vivienda 
isid ubigeo conglome vivienda hogar 
*Cuando le hago sort al ID, se ordena junto con los otros variables. De modo que el orden se mantiene
*pero ahora estan ordenados de manera ascendente en base a los IDs. 
keep ubigeo conglome vivienda hogar dominio mieperho factor07
sort conglome vivienda hogar ubigeo
save "$dir\base1.dta", replace


****************************************
************* MODULO EDUCACION**********
* p314a:  en el mes anterior, usted hizo use del servicion de internet?
* Nota: Los  hogares fueron encuestados solo una vez, y algunos en meses diferentes. 
* Merge ---> Many to one

use "$dir\enaho01a-2020-300.dta", clear
keep conglome vivienda vivienda hogar codperso ubigeo dominio p208a p314a
merge m:1  ubigeo conglome vivienda hogar using "base1.dta"
drop _m


*el factor de exp que tenemos es por hogar no por persona.
*para gen el factor por persona se multiplica el que ya tenemos por mieperho

gen ff=factor07*mieperho

rename p208a edad
rename p314a accestowifi
rename state dominio
rename dominio state
rename weight ff
rename ff weight

gen internet = 1 if(accestowifi == 1 )

replace internet = 2 if internet == .

export excel using "C:\Users\Z50-CORE-I5\Desktop\Social Mobility Measure\Gaps Measure\data.xlsx", sheetmodify firstrow(variables) nolabel







