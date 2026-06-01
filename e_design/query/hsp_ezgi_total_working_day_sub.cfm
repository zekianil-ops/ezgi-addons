<!---
    File: hsp_ezgi_total_working_day_sub.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfquery name="get_general_offtime" dbtype="query">
	SELECT        
    	OFFTIME_NAME, START_DATE, FINISH_DATE, IS_HALFOFFTIME
  	FROM            
     	get_general_offtime_table
   	WHERE   
     	START_DATE >= '#DateFormat(test_gun,'mm/dd/yyyy')#' AND
     	FINISH_DATE <= '#DateFormat(test_gun,'mm/dd/yyyy')#'
</cfquery>
<cfif get_general_offtime.recordcount>
 	<cfif get_general_offtime.IS_HALFOFFTIME eq 1>
        <cfset tatil = 1>
  	<cfelse>
        <cfset tatil = 2>
 	</cfif>
 <cfelse>
    <cfset tatil = 0>    
</cfif>