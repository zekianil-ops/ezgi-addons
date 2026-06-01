<!---
    File: add_shipping_control_stock.cfm
    Folder: Add_Ons\ezgi\e-pda\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfsetting showdebugoutput="yes">
<cfif listlen(attributes.stock_id_list)>
	<cfquery name="DELETE_PACKAGE_LIST" datasource="#DSN3#">
		DELETE EZGI_SHIPPING_PACKAGE_LIST WHERE SHIPPING_ID = #attributes.SHIP_ID# AND SHIPPING_ROW_ID = #attributes.shipping_row_id# AND TYPE = #attributes.is_type#
	</cfquery>
	<cfloop list="#attributes.stock_id_list#" index="sid">
		<cfquery name="ADD_PACKAGE_LIST" datasource="#dsn3#">
			INSERT INTO 
			EZGI_SHIPPING_PACKAGE_LIST
			(
				SHIPPING_ID,
				STOCK_ID,
				AMOUNT,
				CONTROL_AMOUNT,
                REF_STOCK_ID,
                SHIPPING_ROW_ID,
                CONTROL_STATUS,
                TYPE,
                RECORD_EMP,
                RECORD_DATE
			)
			VALUES
			(
				#attributes.SHIP_ID#,
				#sid#,
				#Evaluate('attributes.amount#sid#')#,
				#Evaluate('attributes.control_amount#sid#')#,
                #attributes.f_stock_id#,
                #attributes.shipping_row_id#,
                #attributes.kontrol_status#,
                #attributes.is_type#,
                #session.ep.userid#,
                #now()#
			)
		</cfquery>
	</cfloop>
</cfif>
<cflocation url="#request.self#?fuseaction=pda.form_shipping_control_fis&ship_id=#attributes.SHIP_ID#&department_id=#department_id#&date1=#date1#&date2=#date2#&page=#page#&kontrol_status=1&is_type=#attributes.is_type#&deliver_paper_no=#attributes.DELIVER_PAPER_NO#" addtoken="no">  
