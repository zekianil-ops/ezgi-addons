<!---
    File: add_ezgi_shipping_internaldemand.cfm
    Folder: Add_Ons\ezgi\e_shipping\query
    Author: Ezgi Yazılım
    Date: 01/01/2017
    Description:
--->
<cf_date tarih='attributes.order_date'>
<cfif (not len(attributes.process_stage))>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='647.Süreç Tanımlarınız Eksiktir'>!");
		history.go(-1);
	</script>
	<cfabort>
</cfif>
<cfset order_row_id_list_ = ''>
<cfloop list="#order_row_id_list#" index="i">
	<cfif isdefined("select_order_row_#i#")>
    	<cfset order_row_id_list_ = ListAppend(order_row_id_list_,i)>
        <cfset "amount_#i#" = Evaluate('select_order_row_#i#')>
    </cfif>
</cfloop>
<cfif (not len(order_row_id_list_))>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='311.Lütfen Önce Seçim Yapınız'>");
		history.go(-1);
	</script>
	<cfabort>
</cfif>

<cfif isdefined("attributes.action_date") and len(attributes.action_date)><cf_date tarih='attributes.action_date'></cfif>
<cfif isdefined("attributes.deliver_date") and len(attributes.deliver_date)><cf_date tarih='attributes.deliver_date'></cfif>
<cfset attributes.action_date_value = createdatetime(year(attributes.action_date),month(attributes.action_date),day(attributes.action_date),attributes.start_h,attributes.start_m,0)>
<cfif len(attributes.deliver_date)>
	<cfset attributes.deliver_date_value = createdatetime(year(attributes.deliver_date),month(attributes.deliver_date),day(attributes.deliver_date),attributes.deliver_h,attributes.deliver_m,0)>
<cfelse>
	<cfset attributes.deliver_date_value = "NULL">
</cfif>
<cf_papers paper_type="ship_fis">
<cflock timeout="60">
  	<cftransaction>
		<cfquery name="ADD_SHIP_RESULT" datasource="#DSN3#" result="MAX_ID">
			INSERT INTO
				EZGI_SHIP_RESULT_INTERNALDEMAND
				(
				IS_TYPE,
				SHIP_METHOD_TYPE,
				NOTE,
				REFERENCE_NO,
                OUT_DATE,
				DELIVERY_DATE,
                DELIVER_EMP,
				DEPARTMENT_ID,
                LOCATION_ID,
                DEPARTMENT_IN_ID,
                LOCATION_IN_ID,
				SHIP_STAGE,
				RECORD_EMP,
				RECORD_IP,
				RECORD_DATE
                )
			VALUES
				(
				2,
				<cfif len(attributes.ship_method_id)>#attributes.ship_method_id#<cfelse>NULL</cfif>,
				'#attributes.note#',
				'#attributes.reference_no#',
				<cfif len(attributes.action_date_value)>#attributes.action_date_value#<cfelse>NULL</cfif>,
				<cfif len(attributes.deliver_date_value)>#attributes.deliver_date_value#<cfelse>NULL</cfif>,
				<cfif len(attributes.deliver_id2)>#attributes.deliver_id2#<cfelse>NULL</cfif>,
				<cfif len(attributes.department_id)>#attributes.department_id#<cfelse>NULL</cfif>,
                <cfif len(attributes.location_id)>#attributes.location_id#<cfelse>NULL</cfif>,
                <cfif len(attributes.department_in_id)>#attributes.department_in_id#<cfelse>NULL</cfif>,
                <cfif len(attributes.location_in_id)>#attributes.location_in_id#<cfelse>NULL</cfif>,
				#attributes.process_stage#,
				#session.ep.userid#,
				'#cgi.remote_addr#',
				#now()#
				)
		</cfquery>
        <cfloop list="#order_row_id_list_#" index="i">
        	<cfquery name="get_same_order_row_id" datasource="#dsn3#">
            	SELECT ORDER_ROW_ID FROM EZGI_SHIP_RESULT_INTERNALDEMAND_ROW WHERE ORDER_ROW_ID = #i#
            </cfquery>
            <cfif get_same_order_row_id.recordcount>
            	<script type="text/javascript">
					alert("<cf_get_lang dictionary_id='29974.Hatalı Kayıt Bilgileri'>");
					history.go(-1);
				</script>
				<cfabort>
            </cfif>
            <cfquery name="ADD_SHIP_RESULT_ROW" datasource="#DSN3#">
                INSERT INTO
                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW
                    (
                        SHIP_RESULT_INTERNALDEMAND_ID,
                        ORDER_ID, 
                        ORDER_ROW_ID, 
                        ORDER_ROW_AMOUNT
                    )
                    VALUES
                    (
                        #MAX_ID.IDENTITYCOL#,
                        #attributes.order_id#,
                        #i#,
                        #Filternum(Evaluate('attributes.row_amount_#i#'))#
                    )
            </cfquery>
        </cfloop>
  	</cftransaction>
</cflock>
<cfsavecontent variable="sevk_no"><cf_get_lang dictionary_id='375.Sevk Talep No'></cfsavecontent>
<cf_workcube_process 
	is_upd='1' 
	old_process_line='0'
	process_stage='#attributes.process_stage#' 
	record_member='#session.ep.userid#' 
	record_date='#now()#'
	action_table='EZGI_SHIP_RESULT_INTERNALDEMAND'
	action_column='EZGI_SHIP_RESULT_INTERNALDEMAND_ID'
	action_id='#MAX_ID.IDENTITYCOL#'
	action_page='#request.self#?fuseaction=sales.popup_add_ezgi_shipping_internaldemand&order_id=#attributes.order_id#'
	warning_description = '#sevk_no# : #MAX_ID.IDENTITYCOL#'>
<script type="text/javascript">
	alert("Kayıt İşleminiz Başarıyla Tamamlanmıştır");
	wrk_opener_reload()
	window.close();
</script>