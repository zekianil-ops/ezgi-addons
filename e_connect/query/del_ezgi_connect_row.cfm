<cfquery name="get_connect_defaults_row" datasource="#dsn3#">
     SELECT  ISNULL(IS_EXPORT,0) AS IS_EXPORT FROM EZGI_CONNECT_SETUP_ROW WHERE EMPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfquery name="get_connect_money" datasource="#DSN3#">
	SELECT        
    	MONEY_TYPE, 
        RATE2, 
        RATE1, 
        IS_SELECTED
	FROM            
    	EZGI_CONNECT_MONEY
	WHERE        
    	ACTION_ID = #attributes.connect_id#
</cfquery>
<cfif isdefined('attributes.connect_id')>
	<cfoutput query="get_connect_money">
        <cfset 'RATE1_#MONEY_TYPE#' = RATE1>
        <cfset 'RATE2_#MONEY_TYPE#' = RATE2>
    </cfoutput>
</cfif>
<cfquery name="get_connect_money_selected" dbtype="query">
	SELECT 
    	MONEY_TYPE,
        RATE2
	FROM     
     	get_connect_money
	WHERE
   		IS_SELECTED = 1
</cfquery>
<cfquery name="get_connect" datasource="#DSN3#">
	SELECT 
		SALES_TYPE,
        PROJECT_ID,
        ISNULL((SELECT CAMPAIGN_TYPE FROM PROJECT_DISCOUNTS WHERE PROJECT_ID = EZGI_CONNECT.PROJECT_ID),0) AS CAMPAIGN_TYPE
   	FROM 
    	EZGI_CONNECT
   	WHERE 
    	CONNECT_ID = #attributes.connect_id#
</cfquery>
<cfset connect_rate2 = get_connect_money_selected.RATE2>
<cfset connect_money = get_connect_money_selected.MONEY_TYPE>
<cfset miktar = 1>
<cfif listlen(attributes.connect_row_id_list)>
	<cfloop list="#attributes.connect_row_id_list#" index="i">
		<cflock timeout="90">
        <cftransaction>
        	<cfquery name="del_connect_row" datasource="#dsn3#">
            	DELETE FROM
                	EZGI_CONNECT_ROW
              	WHERE
                	CONNECT_ROW_ID = #i#	
            </cfquery>
        </cftransaction>
		</cflock>
  	</cfloop>
    <cfinclude template="hsp_ezgi_connect_row_include.cfm">
</cfif>
<cfset url_str = "">
<cfif isdefined('attributes.property_group_list') and ListLen(attributes.property_group_list)>
    <cfloop list="#attributes.property_group_list#" index="ii">
        <cfif isdefined('attributes.categori_id_list_#ii#') and len(Evaluate('attributes.categori_id_list_#ii#'))>
            <cfset url_str = "#url_str#&categori_id_list_#ii#=#Evaluate('attributes.categori_id_list_#ii#')#">
        </cfif>
    </cfloop>
</cfif>
<script type="text/javascript">
    window.location ="<cfoutput>#request.self#?fuseaction=sales.list_ezgi_connect#url_str#&event=upd&<cfif len(url_str) or len(attributes.keyword)>is_form_submitted=1</cfif>&id_list=#attributes.id_list#&connect_id=#attributes.connect_id#&keyword=#attributes.keyword#</cfoutput>";
</script>
