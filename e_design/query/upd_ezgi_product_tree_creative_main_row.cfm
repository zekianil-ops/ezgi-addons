<!---
    File: upd_ezgi_product_tree_creative_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="upd_process" datasource="#dsn3#">
	UPDATE
    	EZGI_DESIGN_MAIN_ROW
   	SET
    	<cfif isdefined('attributes.new_design_id') and attributes.design_id neq attributes.new_design_id><!---Özel Mobilya Tasarım Modülü Değil Mobilya Tasarımdan Geliyorsa ve  Tasarım Değişmişse--->
        	DESIGN_ID = #attributes.new_design_id#,
        </cfif>
        DESIGN_MAIN_NAME = '#attributes.design_name_main_row#', 
        DESIGN_MAIN_COLOR_ID = #attributes.color_type#, 
        MAIN_ROW_SETUP_ID = #attributes.setup_type#, 
        DESIGN_MAIN_STATUS = 1, 
        KARMA_KOLI_MIKTAR = <cfif len(attributes.main_row_amount)>#attributes.main_row_amount#<cfelse>NULL</cfif>, 
        OLCU1 = <cfif len(attributes.olcu1)>#attributes.olcu1#<cfelse>NULL</cfif>,
        OLCU2 = <cfif len(attributes.olcu2)>#attributes.olcu2#<cfelse>NULL</cfif>,
        OLCU3 = <cfif len(attributes.olcu3)>#attributes.olcu3#<cfelse>NULL</cfif>,
        SALES_PRICE = <cfif isdefined('attributes.sales_price') and len(attributes.sales_price)>#filternum(attributes.sales_price)#<cfelse>NULL</cfif>,
        MONEY = <cfif isdefined('attributes.money') and len(attributes.money)>'#attributes.money#'<cfelse>NULL</cfif>,
        MAIN_PROTOTIP_TYPE = <cfif isdefined('attributes.spect_type') and len(attributes.spect_type)>'#attributes.spect_type#'<cfelse>0</cfif>,
        MEASURE_ID = <cfif isdefined('attributes.spect_type') and attributes.spect_type eq 1 and isdefined('attributes.measure_id') and len(attributes.measure_id)>#attributes.measure_id#<cfelse>NULL</cfif>,
        PRIVATE_PRICE_TYPE = <cfif isdefined('attributes.spect_type') and attributes.spect_type eq 1 and len(attributes.private_price_type)>'#attributes.private_price_type#'<cfelse>0</cfif>,
       	PRIVATE_PRICE = <cfif isdefined('attributes.spect_type') and attributes.spect_type eq 1 and attributes.private_price_type neq 0>#FilterNum(attributes.private_price,2)#<cfelse>0</cfif>,
      	PRIVATE_PRICE_MONEY= <cfif isdefined('attributes.spect_type') and attributes.spect_type eq 1 and attributes.private_price_type eq 1>'#attributes.private_price_money#'<cfelse>NULL</cfif>,
        UPDATE_EMP = #session.ep.userid#, 
      	UPDATE_IP = '#cgi.remote_addr#', 
        UPDATE_DATE = #now()#
 	WHERE
    	DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
</cfquery>
<cfif isdefined('attributes.new_design_id') and attributes.design_id neq attributes.new_design_id>
	<cfquery name="upd_package" datasource="#dsn3#">
    	UPDATE EZGI_DESIGN_PACKAGE_ROW SET DESIGN_ID = #attributes.new_design_id# WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
    </cfquery>
    <cfquery name="upd_piece" datasource="#dsn3#">
    	UPDATE EZGI_DESIGN_PIECE_ROWS SET DESIGN_ID = #attributes.new_design_id# WHERE DESIGN_MAIN_ROW_ID = #attributes.design_main_row_id#
    </cfquery>
</cfif>
<script type="text/javascript">
        wrk_opener_reload();
        window.close();
</script>