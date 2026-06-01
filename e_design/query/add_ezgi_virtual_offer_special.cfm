<!---
    File: add_ezgi_virtual_offer_special.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cftransaction>
	<cfquery name="get_special_row" datasource="#dsn3#">
    	SELECT 
        	* 
        FROM 
        	EZGI_VIRTUAL_OFFER_SPECIAL_ROW 
       	WHERE 
        	ROW_ID = #attributes.row_id# AND
            TYPE = '#attributes.type#'
             <cfif isdefined('attributes.TASK_V_OFFER_NUMBER') and len(attributes.TASK_V_OFFER_NUMBER) and len(attributes.TASK_V_OFFER_ID)>
             	AND VIRTUAL_OFFER_ID = #attributes.TASK_V_OFFER_ID#
           	</cfif>
            <cfif isdefined('attributes.measure_type') and len(attributes.measure_type)>
            	AND MEASURE_TYPE= #attributes.measure_type#
          	</cfif>
            <cfif isdefined('attributes.measure') and len(attributes.measure)>
            	AND MEASURE = #measure#
          	</cfif>
    </cfquery>
    <cfif not get_special_row.recordcount>
        <cfquery name="add_special_row" datasource="#dsn3#">
            INSERT INTO        
                EZGI_VIRTUAL_OFFER_SPECIAL_ROW
                (
                    TYPE, 
                    ROW_ID, 
                    VIRTUAL_OFFER_ID, 
                    DETAIL, 
                    MEASURE_TYPE, 
                    MEASURE, 
                    RECORD_EMP, 
                    RECORD_DATE, 
                    RECORD_IP
                )
            VALUES 
                (
                '#attributes.type#',
                #attributes.row_id#,
                <cfif isdefined('attributes.TASK_V_OFFER_NUMBER') and len(attributes.TASK_V_OFFER_NUMBER) and len(attributes.TASK_V_OFFER_ID)>#attributes.TASK_V_OFFER_ID#<cfelse>NULL</cfif>,
                <cfif len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.measure_type') and len(attributes.measure_type)>#attributes.measure_type#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.measure') and len(attributes.measure)>#measure#<cfelse>NULL</cfif>,
                #session.ep.userid#,
                #now()#,
                '#cgi.remote_addr#'
                )
        </cfquery>
    </cfif>
</cftransaction>
<script type="text/javascript">
	alert("Ölçü Sanal Teklif ile İlişkilendirilmiştir.!");
 	window.close()
</script>
