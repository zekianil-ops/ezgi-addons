<!---
    File: upd_ezgi_iflow_master_plan.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif isdefined('attributes.start_date') and isdate(attributes.start_date)>
    <cf_date tarih = "attributes.start_date">
    <cfset attributes.start_date = dateadd("n",attributes.start_m,dateadd("h",attributes.start_h ,attributes.start_date))>
<cfelse>
    <cfset attributes.start_date =''>
</cfif>
<cfif isdefined('attributes.finish_date') and isdate(attributes.finish_date)>
    <cf_date tarih = "attributes.finish_date">
    <cfset attributes.finish_date = dateadd("n",attributes.finish_m,dateadd("h",attributes.finish_h ,attributes.finish_date))>
<cfelse>
    <cfset attributes.finish_date =''>
</cfif>
<cflock name="#CREATEUUID()#" timeout="90">
	<cftransaction>
		<cfquery name="upd_master_plan" datasource="#dsn3#">
			UPDATE  
          		EZGI_IFLOW_MASTER_PLAN
          	SET
            	MASTER_PLAN_PROCESS = <cfif isdefined('attributes.is_stock_reserve')>1<cfelse>0</cfif>,
            	GROSSTOTAL = #attributes.ara_stok#,
				MASTER_PLAN_START_DATE = #attributes.start_date#,
				MASTER_PLAN_FINISH_DATE = #attributes.finish_date#,
				MASTER_PLAN_DETAIL = <cfif isdefined('attributes.detail') and len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>, 
				MASTER_PLAN_STATUS = <cfif isdefined('attributes.master_plan_status') and len(attributes.master_plan_status)>#attributes.master_plan_status#<cfelse>0</cfif>, 
				MASTER_PLAN_STAGE = #attributes.process_stage#,
				UPDATE_EMP = #session.ep.userid#, 
				UPDATE_IP = '#cgi.remote_addr#', 
				UPDATE_DATE = #now()#				
          	WHERE
            	MASTER_PLAN_ID = #attributes.master_plan_id#
		</cfquery>
        <cfquery name="get_master_plan" datasource="#dsn3#">
        	SELECT IFLOW_P_ORDER_ID FROM EZGI_IFLOW_PRODUCTION_ORDERS WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
        </cfquery>
        <cfif get_master_plan.recordcount>
        	<cfset tur = get_master_plan.recordcount>
            <cfset satirlar = queryNew("id, old_currentrow, new_currentrow","integer, integer, integer") />
            <cfloop from="1" to="#tur#" index="i">
            	<cfloop query="get_master_plan">
                	<cfif isdefined('sira_#i#_#get_master_plan.IFLOW_P_ORDER_ID#')>
						<cfset Temp = QueryAddRow(satirlar)>
                        <cfset Temp = QuerySetCell(satirlar, "id",get_master_plan.IFLOW_P_ORDER_ID)>
                        <cfset Temp = QuerySetCell(satirlar, "old_currentrow",i)>
                        <cfset Temp = QuerySetCell(satirlar, "new_currentrow",Evaluate('sira_#i#_#get_master_plan.IFLOW_P_ORDER_ID#'))>
                    </cfif>
                </cfloop>
            </cfloop>
            <cfquery name="satirlar" dbtype="query">
            	SELECT * FROM satirlar ORDER BY new_currentrow
            </cfquery>
            <cfloop query="satirlar">
            	<cfquery name="upd_prod_order" datasource="#dsn3#">
                	UPDATE       
                    	EZGI_IFLOW_PRODUCTION_ORDERS
					SET                
                    	DP_ORDER_ID = #satirlar.currentrow#
					WHERE        
                    	MASTER_PLAN_ID = #attributes.master_plan_id# AND 
                        IFLOW_P_ORDER_ID = #satirlar.id#
                </cfquery>
            </cfloop>
        	<cfset attributes.iflow_master_plan_id = attributes.master_plan_id>
            <cfquery name="GET_MASTER_PLAN_INFO" datasource="#DSN3#">
                SELECT MASTER_PLAN_PROCESS, MASTER_PLAN_CAT_ID FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
            </cfquery>
        	<cfinclude template="upd_ezgi_iflow_production_parti_operations.cfm"> <!---Üretim Zamanı Hesaplama İşlemine Gidiyor--->
        </cfif>
 	</cftransaction>
</cflock>
<!---<cfinclude template="upd_ezgi_iflow_master_plan_operation.cfm">
<cflock name="#CREATEUUID()#" timeout="90">
	<cftransaction>
    	<cfquery name="get_iflow_master_plan" datasource="#dsn3#">
        	SELECT LOT_NO FROM EZGI_IFLOW_PRODUCTION_ORDERS WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
        </cfquery>
    	<cfif get_iflow_master_plan.recordcount>
            <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
            	<cfif attributes.x_is_parti eq 1>	
                	<cfquery name="upd_p_order" datasource="#dsn3#">
                        UPDATE 
                            PRODUCTION_ORDERS
                        SET          
                            START_DATE = EIPO.P_ORDER_START_DATE, 
                            FINISH_DATE = EIPO.P_ORDER_FINISH_DATE
                        FROM     
                            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPO INNER JOIN
                            EZGI_IFLOW_PRODUCTION_ORDERS AS EPO ON EIPO.P_ORDER_PARTI_ID = EPO.REL_P_ORDER_ID INNER JOIN
                            PRODUCTION_ORDERS ON EPO.LOT_NO = PRODUCTION_ORDERS.LOT_NO
                        WHERE  
                            EPO.MASTER_PLAN_ID = #attributes.master_plan_id#
            		</cfquery>
                    <cfquery name="upd_e_p_order" datasource="#dsn3#">
                    	UPDATE 
                        	EZGI_IFLOW_PRODUCTION_ORDERS
						SET          
                        	START_DATE = EIPO.P_ORDER_START_DATE, 
                            FINISH_DATE = EIPO.P_ORDER_FINISH_DATE, 
                            CUTTING_FINISH_DATE = EIPO.P_ORDER_FINISH_DATE
						FROM     
                        	EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPO INNER JOIN
                  			EZGI_IFLOW_PRODUCTION_ORDERS ON EIPO.P_ORDER_PARTI_ID = EZGI_IFLOW_PRODUCTION_ORDERS.REL_P_ORDER_ID
						WHERE  
                        	EZGI_IFLOW_PRODUCTION_ORDERS.MASTER_PLAN_ID = #attributes.master_plan_id#
                  	</cfquery>
            	<cfelse>
                    <cfquery name="upd_p_order" datasource="#dsn3#">
                        UPDATE 
                            PRODUCTION_ORDERS
                        SET          
                            START_DATE = EM.MASTER_PLAN_START_DATE, 
                            FINISH_DATE = EM.MASTER_PLAN_FINISH_DATE
                        FROM     
                            EZGI_IFLOW_PRODUCTION_ORDERS AS EO INNER JOIN
                            EZGI_IFLOW_MASTER_PLAN AS EM ON EO.MASTER_PLAN_ID = EM.MASTER_PLAN_ID INNER JOIN
                            PRODUCTION_ORDERS ON EO.LOT_NO = PRODUCTION_ORDERS.LOT_NO
                        WHERE  
                            EM.MASTER_PLAN_ID = #attributes.master_plan_id#
                    </cfquery>
                </cfif>
                <cfquery name="upd_p_order" datasource="#dsn3#">
                    UPDATE 
                        PRODUCTION_ORDERS
                    SET          
                        IS_STOCK_RESERVED = <cfif isdefined('attributes.is_stock_reserve')>1<cfelse>0</cfif>
                    FROM     
                        EZGI_IFLOW_PRODUCTION_ORDERS AS EO INNER JOIN
                        EZGI_IFLOW_MASTER_PLAN AS EM ON EO.MASTER_PLAN_ID = EM.MASTER_PLAN_ID INNER JOIN
                        PRODUCTION_ORDERS ON EO.LOT_NO = PRODUCTION_ORDERS.LOT_NO
                    WHERE  
                        EM.MASTER_PLAN_ID = #attributes.master_plan_id#
                        <cfif isdefined('attributes.is_stock_reserve')>
                        	AND PRODUCTION_ORDERS.QUANTITY > ISNULL(PRODUCTION_ORDERS.RESULT_AMOUNT,0)
                        </cfif>
                </cfquery>
            </cfif>
        </cfif>
    </cftransaction>
</cflock>
---><script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=prod.list_ezgi_iflow_master_plan&event=upd&master_plan_id=#attributes.master_plan_id#</Cfoutput>';
</script>
