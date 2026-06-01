<!---
    File: add_ezgi_stock_update_file.cfm
    Folder: Add_Ons\ezgi\e-pda\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfset attributes.raf = 0>
<cfif ListLen(attributes.ROW_ID_LIST)>
	<cfset satirlar_sayim = queryNew("id, amount","integer, Decimal") />
    <cfset satirlar_fire = queryNew("id, amount","integer, Decimal") />
    <cfoutput>
        <cfloop list="#attributes.ROW_ID_LIST#" index="i">
            <cfif isdefined('attributes.SELECT_ROW_#i#')>
                <cfset Temp = QueryAddRow(satirlar_fire)>
                <cfset amount_ = FilterNum(Evaluate('attributes.amount_row_#i#'),2)>
                <cfset stock_id_ = Evaluate('attributes.SELECT_ROW_#i#')>
                <cfset Temp = QuerySetCell(satirlar_fire, "id", stock_id_)> 
                <cfset Temp = QuerySetCell(satirlar_fire, "amount", amount_)>
            </cfif>
            <cfif isdefined('attributes.row_#i#')>
            	<cfloop from="1" to="#Evaluate('attributes.row_#i#')#" index="j">
                	<cfif isdefined('attributes.SELECT_ROW_#i#_#j#')>
                    	<cfset Temp = QueryAddRow(satirlar_sayim)>
						<cfset amount_ = FilterNum(Evaluate('attributes.amount_row_#i#_#j#'),2)>
                        <cfset stock_id_ = Evaluate('attributes.SELECT_ROW_#i#_#j#')>
                        <cfset Temp = QuerySetCell(satirlar_sayim, "id", stock_id_)> 
                        <cfset Temp = QuerySetCell(satirlar_sayim, "amount", amount_)>
                    </cfif>
                </cfloop>
            </cfif>
        </cfloop>
   	</cfoutput>
</cfif>
<cfif satirlar_sayim.recordcount>
	<cfset attributes.process_cat = attributes.sayim_process_cat_id>
    <cfset attributes.action_id = ''>
    <cfset attributes.is_mobile = 1>
    <cfset attributes.tersfis = 1>
    <cfset attributes.dep_out = attributes.department_out_id>
	<cfset attributes.dep_in = attributes.department_in_id>
    <cfloop query="satirlar_sayim">
		<cfset attributes.action_id = ListAppend(attributes.action_id,'#satirlar_sayim.currentrow#-#satirlar_sayim.id#-#satirlar_sayim.amount#-#attributes.raf#')>
    </cfloop>
    <cfinclude template="../../e_pda/query/add_ambar_fis.cfm">
    <cfquery name="upd_stock_fis" datasource="#dsn2#">
    	UPDATE 
        	STOCK_FIS
		SET          
        	REF_NO = '#attributes.fis_number#'
		WHERE  
        	FIS_ID = #GET_ID.MAX_ID#
    </cfquery>
</cfif>
<cfif satirlar_fire.recordcount>
	<cfset attributes.process_cat = attributes.fire_process_cat_id>
    <cfset attributes.action_id = ''>
    <cfset attributes.is_mobile = 1>
    <cfset attributes.tersfis = 1>
    <cfset attributes.dep_out = attributes.department_out_id>
	<cfset attributes.dep_in = attributes.department_in_id>
    <cfloop query="satirlar_fire">
		<cfset attributes.action_id = ListAppend(attributes.action_id,'#satirlar_fire.currentrow#-#satirlar_fire.id#-#satirlar_fire.amount#-#attributes.raf#')>
    </cfloop>
    <cfinclude template="../../e_pda/query/add_ambar_fis.cfm">
    <cfquery name="upd_stock_fis" datasource="#dsn2#">
    	UPDATE 
        	STOCK_FIS
		SET          
        	REF_NO = '#attributes.fis_number#'
		WHERE  
        	FIS_ID = #GET_ID.MAX_ID#
    </cfquery>
</cfif>
<script type="text/javascript">
 	alert("Kayıt İşlemi Başarıyla Tamamlanmıştır.");
	wrk_opener_reload();
    window.close()
</script>