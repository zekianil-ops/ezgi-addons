
<cfif ListLen(attributes.product_id)>
	<cfif ListLen(attributes.old_cat_list) AND ListLen(attributes.OLD_BRANCH_HISTORY_LIST)>
    	<cfquery name="del_product_branch" datasource="#dsn1#">
        	DELETE FROM 
            	PRODUCT_BRANCH
			WHERE  
            	BRANCH_ID IN (#attributes.OLD_BRANCH_HISTORY_LIST#) AND 
                PRODUCT_ID IN
                      		(
                            	SELECT 
                                	PRODUCT_ID
                       			FROM      
                                	PRODUCT
                       			WHERE  
                                	( 
                                	<cfloop from="1" to="#ListLen(attributes.old_cat_list)#" index="i">
                                		PRODUCT_CODE LIKE '#ListGetAt(attributes.old_cat_list,i)#%' <cfif ListLen(attributes.old_cat_list) neq i>OR</cfif>
                                    </cfloop>
                                    )
                           	)
        </cfquery>
    </cfif>
	<cfloop list="#attributes.product_id#" index="iid">
    	<cfset attributes.pid = iid>
		<!--- // history --->
        <cfset new_branch_history_list = "">
        <cfloop  from="1" to="#attributes.branch_recordcount#" index="bid">
            <cfif isdefined('attributes.branch_id_#bid#')>
                <cfset new_branch_history_list = listappend(new_branch_history_list,evaluate('attributes.branch_id_#bid#'),',')>
            </cfif>
        </cfloop>
        <cfif old_branch_history_list neq new_branch_history_list>
            <cfif len(old_branch_history_list) eq 0>
                <cfset old_branch_history_list = '0'>
            </cfif>
            <cfset history_type_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>
            <cfloop list="#old_branch_history_list#" index="x">
                <cfquery name="get_our_company_id" datasource="#dsn#">
                    SELECT COMPANY_ID FROM BRANCH WHERE BRANCH_ID = #x#
                </cfquery>
                <cfquery name="add_branch_history" datasource="#dsn1#">
                    INSERT INTO
                        PRODUCT_COMPANY_BRANCH_HISTORY
                    (
                        HISTORY_TYPE_ID,
                        PRODUCT_ID,
                        OUR_COMPANY_ID,
                        BRANCH_ID,
                        RECORD_EMP,
                        RECORD_DATE,
                        RECORD_IP
                    )
                    VALUES
                    (
                        '#history_type_id#',
                        #attributes.pid#,
                        <cfif len(get_our_company_id.company_id)>#get_our_company_id.company_id#<cfelse>NULL</cfif>,
                        #x#,
                        #session.ep.userid#,
                        #now()#,
                        '#cgi.remote_addr#'
                    )
                </cfquery>
            </cfloop>
        </cfif>
        
        
         
        <!--- Sirket iliskisi --->
        <cfif isDefined("attributes.our_company_id")>
            <cfquery name="GET_PRODUCT_OUR_COMPANY" datasource="#DSN1#">
                SELECT OUR_COMPANY_ID FROM PRODUCT_OUR_COMPANY WHERE PRODUCT_ID = #attributes.pid#
            </cfquery>
            <cfquery name="GET_STOCK_IDS" datasource="#DSN3#">
                SELECT
                    STOCK_ID
                FROM
                    STOCKS
                WHERE
                    PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#">
            </cfquery>
            <cfloop list="#attributes.our_company_id#" index="compid">
                <cfif Not ListFind(ValueList(GET_PRODUCT_OUR_COMPANY.OUR_COMPANY_ID),compid)>
                    <cfquery name="add_PRODUCT_OUR_COMPANY" datasource="#DSN1#">
                        INSERT INTO 
                            PRODUCT_OUR_COMPANY
                        (
                            PRODUCT_ID,
                            OUR_COMPANY_ID
                        )
                        VALUES
                        (
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#compid#">
                        )
                    </cfquery>
                
                    <cfquery name="get_my_periods" datasource="#dsn#">
                        SELECT
                            *
                        FROM
                            SETUP_PERIOD
                        WHERE
                            OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#compid#">
                    </cfquery>
                    <cfoutput query="get_my_periods">
                        <cfif database_type is "MSSQL">
                            <cfset temp_dsn = "#DSN#_#PERIOD_YEAR#_#OUR_COMPANY_ID#">
                        <cfelseif database_type is "DB2">
                            <cfset temp_dsn = "#dsn#_#OUR_COMPANY_ID#_#right(period_year,2)#">
                        </cfif>
                        <cfloop query="GET_STOCK_IDS">
                            <cfquery name="INSRT_STK_ROW" datasource="#temp_dsn#">
                                INSERT INTO 
                                    STOCKS_ROW 
                                (
                                    STOCK_ID, 
                                    PRODUCT_ID
                                )
                                VALUES 
                                (
                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#stock_id#">, 
                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#">
                                )
                            </cfquery>
                        </cfloop>
                    </cfoutput>
                </cfif>	
            </cfloop>
        </cfif>
        
        <!--- Subelerle İliskisi --->
        <cfquery name="get_branch_record" datasource="#dsn1#">
            SELECT RECORD_EMP FROM PRODUCT_BRANCH WHERE PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#">
        </cfquery>
        <cfif attributes.branch_recordcount neq 0>
            <!---<cfquery name="del_product_branch" datasource="#dsn1#">
                DELETE FROM PRODUCT_BRANCH WHERE PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#">
            </cfquery>--->
            <cfloop  from="1" to="#attributes.branch_recordcount#" index="bid">
                <cfif isdefined('attributes.branch_id_#bid#')>
                    
                    <cfquery name="add_product_branch" datasource="#dsn1#">
                        INSERT INTO
                            PRODUCT_BRANCH
                            (
                                PRODUCT_ID,
                                BRANCH_ID,
                            <cfif get_branch_record.recordcount eq 0>
                                RECORD_EMP,
                                RECORD_DATE,
                                RECORD_IP
                            <cfelse>
                                UPDATE_EMP,
                                UPDATE_DATE,
                                UPDATE_IP
                            </cfif>
                            )
                            VALUES
                            (
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#">,
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.branch_id_#bid#')#">,
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                                <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
                            )
                    </cfquery>
                </cfif>
            </cfloop>
        </cfif>
	</cfloop>
</cfif>
<script type="text/javascript">
	alert('<cf_get_lang dictionary_id="47470.İşlem Tamamlandı">');
	window.close()
</script>
<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_product_companyies" addtoken="No">