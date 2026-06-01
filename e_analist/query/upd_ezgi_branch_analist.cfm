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
	<cfinclude template="../query/get_ezgi_branch_gelirler.cfm">
  	<cfinclude template="../query/get_ezgi_branch_giderler.cfm">
  	<cfinclude template="../query/get_ezgi_branch_sonuc.cfm">
    <!---<cfdump var="#GET_INVOICE#"><cfabort>--->
	<cftransaction>
		<cfif attributes.status eq 1>
        	<cfif get_upd.IS_BRANCH eq 0>
                <cfquery name="get_smm" dbtype="query">
                    SELECT SUM(ROW_COST) AS SMM FROM GET_INVOICE
                </cfquery>
          	<cfelse>
            	<cfif len(get_TOTAL.SMM)>
					<cfset get_smm.smm = get_TOTAL.SMM>
                <cfelse>
                    <cfset get_smm.smm = 0>
                </cfif>
            </cfif>
            <cfif len(get_sales_TOTAL.NETTOTAL)>
                <cfset satis_total = get_sales_TOTAL.NETTOTAL>
            <cfelse>
                <cfset satis_total = 0>
            </cfif>
            <cfif len(get_hedef_sales.HEDEF)>
                <cfset satis_hedef = get_hedef_sales.HEDEF>
            <cfelse>
                <cfset satis_hedef = 0>
            </cfif>
            <cfif len(GET_TOTAL_EXPENSE.GIDER)>
                <cfset expense_gider = GET_TOTAL_EXPENSE.GIDER>
            <cfelse>
                <cfset expense_gider = 0>
            </cfif>
        	<cfif get_sales.recordcount>
                <cfloop query="get_sales">
                    <cfquery name="add_row" datasource="#dsn3#">
                        INSERT INTO 
                            EZGI_ANALYST_BRANCH_ROW
                            (
                                EZGI_ANALYST_BRANCH_ID, 
                                NETTOTAL, 
                                DETAIL, 
                                DETAIL_ID, 
                                PRODUCT_CAT, 
                                PRODUCT_CATID, 
                                TYPE, 
                                TARGET, 
                                INCOME
                            )
                        VALUES        
                            (
                                #attributes.upd_id#,
                                #NETTOTAL#,
                                NULL,
                                NULL,
                                '#PRODUCT_CAT#',
                                #PRODUCT_CATID#,
                                #TYPE#,
                                #satis_hedef#,
                                1
                            )
                    </cfquery>
       			</cfloop>
           	</cfif>
            <cfif GET_HEDEF.recordcount>
				<cfloop query="GET_HEDEF">
                	<cfquery name="add_row" datasource="#dsn3#">
                    	INSERT INTO 
                            EZGI_ANALYST_BRANCH_ROW
                            (
                                EZGI_ANALYST_BRANCH_ID, 
                                NETTOTAL, 
                                DETAIL, 
                                DETAIL_ID, 
                                PRODUCT_CAT, 
                                PRODUCT_CATID, 
                                TYPE, 
                                TARGET, 
                                INCOME
                            )
                        VALUES        
                            (
                                #attributes.upd_id#,
                                #GET_HEDEF.GIDER#,
                                '#GET_HEDEF.EXPENSE_ITEM_NAME#',
                                #GET_HEDEF.EXPENSE_ITEM_ID#,
                                '#GET_HEDEF.EXPENSE_CAT_NAME#',
                                #GET_HEDEF.EXPENSE_CAT_ID#,
                                NULL,
                                #GET_HEDEF.HEDEF#,
                                2
                            )
                    </cfquery>
                </cfloop>
          	</cfif>
            <cfif get_TOTAL.recordcount>
            	<cfquery name="add_row" datasource="#dsn3#">
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
                          	#satis_total#,
                            #get_smm.SMM#,
                            #get_TOTAL.LISTE_FIYAT#,
                            #expense_gider#,
                            #get_TOTAL.TOTAL_COST#,
                            #get_upd.BRANCH_ID#,
                            '#get_upd.BRANCH_NAME#'
                        )
               	</cfquery>
              	<cfquery name="add_row" datasource="#dsn3#">
                	INSERT INTO 
                            EZGI_ANALYST_BRANCH_ROW
                            (
                                EZGI_ANALYST_BRANCH_ID, 
                                NETTOTAL, 
                                LISTE_FIYAT,
                                DETAIL, 
                                DETAIL_ID, 
                                PRODUCT_CAT, 
                                PRODUCT_CATID, 
                                TYPE, 
                                TARGET,
                                SMM, 
                                EXPENSE,
                                INCOME
                            )
                        VALUES        
                            (
                                #attributes.upd_id#,
                                #satis_total#,
                                #get_TOTAL.LISTE_FIYAT#,
                                NULL,
                                NULL,
                                NULL,
                                #get_upd.BRANCH_ID#,
                                NULL,
                                #get_TOTAL.TOTAL_COST#,
                                #get_smm.SMM#,
                                #expense_gider#,
                                3
                            )
                </cfquery>
            </cfif>
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
<script type="text/javascript">
	window.location.href = '<cfoutput>#request.self#?fuseaction=report.upd_ezgi_branch_analist&upd_id=#attributes.upd_id#</Cfoutput>';
</script>