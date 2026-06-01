<!---
    File: add_ezgi_product_tree.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfif len(attributes.add_stock_id) and len(attributes.product_name)>
    <cfquery name="check_sub" datasource="#dsn3#">
        SELECT
            PRODUCT_ID,
	    (SELECT PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE PRODUCT_ID = PRODUCT_TREE.PRODUCT_ID) AS PRODUCT_NAME
        FROM
            PRODUCT_TREE
        WHERE
            RELATED_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.MAIN_STOCK_ID#">
        AND
            STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.add_stock_id#">
    </cfquery>
    <cfif check_sub.recordcount or (attributes.PRODUCT_ID eq attributes.MAIN_PRODUCT_ID)>
        <script type="text/javascript">
            alert("<cf_get_lang dictionary_id='265.Hatalı Ürün'> : <cfoutput>#attributes.product_name#</cfoutput> <cf_get_lang dictionary_id='266.Bu Ürünü Eklerseniz Ürün Ağacınızda Hiyerarşi Sorunu Oluşur!'>");
        </script>
        <cfabort>
    </cfif>
</cfif>
<cfif attributes.MAIN_STOCK_ID neq attributes.add_stock_id>
	<cfinclude template="../../../../V16/production_plan/query/get_history_product_tree.cfm">
	<cfquery name="add_sub" datasource="#dsn3#" result="MAX_ID">
    	INSERT INTO
			PRODUCT_TREE
			(
				STOCK_ID,
                PRODUCT_ID,
				RELATED_ID,
				AMOUNT,
				UNIT_ID,
				SPECT_MAIN_ID,
				IS_CONFIGURE,
				IS_SEVK,
                LINE_NUMBER,
                OPERATION_TYPE_ID,
                IS_PHANTOM,
                RELATED_PRODUCT_TREE_ID,
                QUESTION_ID,
				PROCESS_STAGE,
				MAIN_STOCK_ID,
				IS_FREE_AMOUNT,
				FIRE_AMOUNT,
				FIRE_RATE,
				DETAIL,
                RECORD_EMP,
             	RECORD_DATE
			)
		VALUES
			(
				#attributes.main_stock_id#,
				<cfif  isdefined('attributes.product_id') and len(attributes.product_id) and len(attributes.product_name)>#attributes.product_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.add_stock_id) and len(attributes.product_name)>#attributes.add_stock_id#<cfelse>NULL</cfif>,
				#round(attributes.AMOUNT*100000000)/100000000#,
				<cfif len(attributes.UNIT_ID)>#attributes.UNIT_ID#<cfelse>NULL</cfif>,
				<cfif len(attributes.spect_main_id)>#attributes.spect_main_id#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.is_configure") and len(attributes.is_configure)>0<cfelse>1</cfif>,
				<cfif isdefined("attributes.is_sevk") and len(attributes.is_sevk)>1<cfelse>0</cfif>,
                <cfif isdefined('attributes.line_number') and len(attributes.line_number)>#attributes.line_number#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.operation_type_id') and len(attributes.operation_type_id) and not len(attributes.product_name)>#attributes.operation_type_id#<cfelse>NULL</cfif>,
                <cfif isdefined('attributes.is_phantom') and len(attributes.is_phantom)>1<cfelse>0</cfif>,
				<cfif isdefined('attributes.PRODUCT_TREE_ID') and len(attributes.PRODUCT_TREE_ID) >#attributes.PRODUCT_TREE_ID#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.alternative_questions') and len(attributes.alternative_questions) and not (isdefined('attributes.operation_type_id') and len(attributes.operation_type_id))>#attributes.alternative_questions#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.process_stage_') and len(attributes.process_stage_) >#attributes.process_stage_#<cfelse>NULL</cfif>,
				<cfif isdefined("attributes.operation_main_stock_id") and len(attributes.operation_main_stock_id) and isdefined('attributes.PRODUCT_TREE_ID') and len(attributes.PRODUCT_TREE_ID)>#attributes.operation_main_stock_id#<cfelse>NULL</cfif>,
               	<cfif isdefined("attributes.is_free_amount")>1<cfelse>0</cfif>,
				<cfif isdefined('attributes.fire_amount') and len(attributes.fire_amount)>#attributes.fire_amount#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.fire_rate') and len(attributes.fire_rate)>#attributes.fire_rate#<cfelse>NULL</cfif>,
				<cfif isdefined('attributes.detail') and len(attributes.detail)>'#attributes.detail#'<cfelse>NULL</cfif>,
			   	#session.ep.userid#,
                #now()#            
			)
	</cfquery>
	<!---Ek Bilgiler--->
    <cfset attributes.info_id = max_id.IDENTITYCOL>

    <cfset attributes.is_upd = 0>
    <cfset attributes.info_type_id=-6>

    <cfinclude template="../../../../V16/objects/query/add_info_plus2.cfm">
    <cfset attributes.actionId = attributes.MAIN_STOCK_ID>
    <!---Ek Bilgiler--->
<cfelse>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='36941.Ürüne Kendisini Ekleyemezsiniz'>!");
		history.back();
	</script>
	<cfabort>
</cfif>
