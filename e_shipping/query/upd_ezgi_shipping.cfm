<!---
    File: upd_ezgi_shipping.cfm
    Folder: Add_Ons\ezgi\e_shipping\query
    Author: Ezgi Yazılım
    Date: 01/01/2017
    Description:
--->
<cfif isdefined("attributes.action_date") and len(attributes.action_date)><cf_date tarih='attributes.action_date'></cfif>
<cfif isdefined("attributes.deliver_date") and len(attributes.deliver_date)><cf_date tarih='attributes.deliver_date'></cfif>
<cfset attributes.action_date_value = createdatetime(year(attributes.action_date),month(attributes.action_date),day(attributes.action_date),attributes.start_h,attributes.start_m,0)>
<cfif len(attributes.deliver_date)>
	<cfset attributes.deliver_date_value = createdatetime(year(attributes.deliver_date),month(attributes.deliver_date),day(attributes.deliver_date),attributes.deliver_h,attributes.deliver_m,0)>
<cfelse>
	<cfset attributes.deliver_date_value = "NULL">
</cfif>
<cflock timeout="60">
  	<cftransaction>
		<cfquery name="UPD_SHIP_RESULT" datasource="#DSN3#">
			UPDATE
				EZGI_SHIP_RESULT
			SET
				SHIP_METHOD_TYPE = <cfif len(attributes.ship_method_id)>#attributes.ship_method_id#<cfelse>NULL</cfif>,
				NOTE = '#attributes.note#',
				REFERENCE_NO = '#attributes.reference_no#',
                OUT_DATE = <cfif len(attributes.action_date_value)>#attributes.action_date_value#<cfelse>NULL</cfif>,
				DELIVERY_DATE = <cfif len(attributes.deliver_date_value)>#attributes.deliver_date_value#<cfelse>NULL</cfif>,
                DELIVER_EMP = <cfif len(attributes.deliver_id2)>#attributes.deliver_id2#<cfelse>NULL</cfif>,
				DEPARTMENT_ID = <cfif len(attributes.department_id)>#attributes.department_id#<cfelse>NULL</cfif>,
                LOCATION_ID = <cfif len(attributes.location_id)>#attributes.location_id#<cfelse>NULL</cfif>,
				SHIP_STAGE = #attributes.process_stage#,
				UPDATE_EMP = #session.ep.userid#,
				UPDATE_IP = '#cgi.remote_addr#',
				UPDATE_DATE = #now()#
         	WHERE
            	SHIP_RESULT_ID = #attributes.ship_result_id#
		</cfquery>
        <cfquery name="get_shipping_row" datasource="#dsn3#">
        	SELECT ORDER_ROW_ID FROM EZGI_SHIP_RESULT_ROW WHERE  SHIP_RESULT_ID = #attributes.ship_result_id#
        </cfquery>
        <cfset order_row_id_list = ValueList(get_shipping_row.ORDER_ROW_ID)>
        <cfif ListLen(order_row_id_list)>
        	<cfloop list="#order_row_id_list#" index="i">
                <cfquery name="UPD_ORDER_ROW_DELIVER_DATE" datasource="#DSN3#">
                    UPDATE    
                        ORDER_ROW
                    SET              
                        DELIVER_DATE = #attributes.action_date_value#
                    WHERE     
                        ORDER_ROW_ID = #i#
                </cfquery>
           	</cfloop>
      	</cfif>
  	</cftransaction>
</cflock>
<cflocation url="#request.self#?fuseaction=sales.popup_upd_ezgi_shipping&iid=#attributes.ship_result_id#" addtoken="no">
