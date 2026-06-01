<cfif isdefined('attributes.status') and len(attributes.status)>
	<cfquery name="get_upd" datasource="#dsn3#">
        SELECT 
        	*,
            (SELECT BRANCH_NAME FROM #dsn_alias#.BRANCH WHERE BRANCH_ID = EZGI_ANALYST_BRANCH.BRANCH_ID) as BRANCH_NAME
      	FROM 
        	EZGI_ANALYST_BRANCH 
       	WHERE 
        	ANALYST_BRANCH_ID = #attributes.upd_id#
    </cfquery>
  	<cfinclude template="../query/get_ezgi_branch_sonuc.cfm">
	<cftransaction>
		<cfif attributes.status eq 1> <!---Kilitli İse--->
        	<cfif get_sales.recordcount>
                <cfloop query="get_sales">
                    <cfquery name="add_row" datasource="#dsn3#"> <!---Satışlar Ekleniyor--->
                        INSERT INTO 
                            EZGI_ANALYST_BRANCH_ROW
                            (
                                EZGI_ANALYST_BRANCH_ID, 
                                NETTOTAL, 
                                QUANTITY,
                                DETAIL, 
                                DETAIL_ID, 
                                PRODUCT_CAT, 
                                PRODUCT_CATID, 
                                TYPE, 
                                TARGET_NETTOTAL, 
                                TARGET_QUANTITY,
                                INCOME
                            )
                        VALUES        
                            (
                                #attributes.upd_id#,
                                #get_sales.NETTOTAL#,
                                #get_sales.QUANTITY#,
                                NULL,
                                NULL,
                                '#get_sales.PRODUCT_CAT#',
                                #get_sales.PRODUCT_CATID#,
                                #get_sales.TYPE#,
                                #get_sales.H_NETTOTAL#,
                                #get_sales.H_QUANTITY#,
                                1
                            )
                    </cfquery>
       			</cfloop>
           	</cfif>
            <cfif GET_HEDEF.recordcount>
				<cfloop query="GET_HEDEF">
                	<cfquery name="add_row" datasource="#dsn3#"><!---Masraflar Ekleniyor--->
                    	INSERT INTO 
                            EZGI_ANALYST_BRANCH_ROW
                            (
                                EZGI_ANALYST_BRANCH_ID, 
                                EXPENSE, 
                                QUANTITY,
                                DETAIL, 
                                DETAIL_ID, 
                                PRODUCT_CAT, 
                                PRODUCT_CATID, 
                                TYPE, 
                                TARGET_NETTOTAL, 
                                TARGET_QUANTITY,
                                INCOME
                            )
                        VALUES        
                            (
                                #attributes.upd_id#,
                                #GET_HEDEF.GIDER#,
                                0,
                                '#GET_HEDEF.EXPENSE_ITEM_NAME#',
                                #GET_HEDEF.EXPENSE_ITEM_ID#,
                                '#GET_HEDEF.EXPENSE_CAT_NAME#',
                                #GET_HEDEF.EXPENSE_CAT_ID#,
                                NULL,
                                #GET_HEDEF.HEDEF#,
                                0,
                                2
                            )
                    </cfquery>
                </cfloop>
          	</cfif>
        	<cfquery name="add_row" datasource="#dsn3#"><!--- Sonuçlar Ekleniyor--->
            	INSERT INTO 
                	EZGI_ANALYST_BRANCH_RESULT
                 	(
                     	EZGI_ANALYST_BRANCH_ID, 
                      	SALES, 
                       	SMM, 
                       	LISTE_FIYAT, 
                      	EXPENSE, 
                       	COST, 
                     	BRANCH_ID, 
                       	BRANCH_NAME
                  	)
           		VALUES        
                	(
                    	#attributes.upd_id#,
                      	#sonuc_total_sales#,
                       	#sonuc_smm#,
                      	#0#,
                       	#sonuc_total_expense#,
                      	#cost_total#,
                      	#get_upd.BRANCH_ID#,
                     	'#get_upd.BRANCH_NAME#'
                	)
       		</cfquery>
        <cfelse>
        	<cfquery name="del_row" datasource="#dsn3#">
            	DELETE FROM EZGI_ANALYST_BRANCH_ROW WHERE EZGI_ANALYST_BRANCH_ID = #attributes.upd_id#
            </cfquery>
            <cfquery name="del_row" datasource="#dsn3#">
            	DELETE FROM EZGI_ANALYST_BRANCH_RESULT WHERE EZGI_ANALYST_BRANCH_ID = #attributes.upd_id#
            </cfquery>
        </cfif>
    </cftransaction>
</cfif>
<cf_date tarih = "attributes.start_date">
<cflock name="#CREATEUUID()#" timeout="90">
    <cftransaction>
        <cfquery name="add_analyst_branch" datasource="#dsn3#">
            UPDATE
                EZGI_ANALYST_BRANCH
         	SET
            	YEAR_VALUE = #attributes.year_value#, 
            	MONTH_VALUE = #attributes.month_value#, 
             	EMPLOYEE_ID = <cfif len(attributes.record_employee_id)>#attributes.record_employee_id#<cfelse>NULL</cfif>, 
              	DATE = #attributes.start_date#, 
             	RATE = #FilterNum(attributes.rate,2)#, 
             	DETAIL = <cfif len(attributes.detail)>'#left(attributes.detail,500)#'<cfelse>NULL</cfif>, 
            	PROCESS_STAGE = #attributes.process_stage#, 
             	BRANCH_ID = #attributes.branch_id#, 
               	<cfif isdefined('attributes.status') and len(attributes.status)>STATUS = #attributes.status#,</cfif>
             	UPDATE_EMP = #session.ep.userid#, 
              	UPDATE_DATE = #now()#, 
              	RECORD_IP =  '#cgi.remote_addr#'
         	WHERE
            	ANALYST_BRANCH_ID = #attributes.upd_id#
        </cfquery>
    </cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=report.list_ezgi_branch_analist&event=upd&upd_id=#attributes.upd_id#" addtoken="no">