<!---
    File: add_ezgi_shipping_internaldemand.cfm
    Folder: Add_Ons\ezgi\e_shipping\form
    Author: Ezgi Yazılım
    Date: 01/01/2017
    Description:
--->
<cf_xml_page_edit>
<br />
<cfset total_weight = 0>
<cfset total_volume = 0>
<cfquery name="GET_ORDER" datasource="#DSN3#">
	SELECT 
		ORDERS.ORDER_NUMBER,
		ORDERS.ORDER_DATE,
        ORDERS.DELIVERDATE,
		ORDERS.SHIP_METHOD,
		ORDERS.SHIP_ADDRESS,
		ORDERS.COMPANY_ID,
		ORDERS.PARTNER_ID,
		ORDERS.CONSUMER_ID,
        ORDERS.DELIVER_DEPT_ID, 
        ORDERS.LOCATION_ID, 
        ORDERS.REF_NO,
        ORDERS.ORDER_DETAIL,
        ORDERS.RESERVED,
		COMPANY_CREDIT.SHIP_METHOD_ID SHIP_METHOD_ID
  	FROM
		ORDERS
	        LEFT JOIN #dsn_alias#.COMPANY_CREDIT COMPANY_CREDIT ON ORDERS.COMPANY_ID = COMPANY_CREDIT.COMPANY_ID AND COMPANY_CREDIT.OUR_COMPANY_ID = #session.ep.company_id#
	WHERE
		ORDERS.ORDER_ID = #attributes.order_id#
</cfquery>
<cfif len(get_order.ship_method) or len(get_order.ship_method_id)>
	<cfquery name="GET_SHIP_METHOD" datasource="#DSN#">
		SELECT 
        	SHIP_METHOD,SHIP_METHOD_ID 
      	FROM 
        	SHIP_METHOD 
        WHERE 
        	SHIP_METHOD_ID =
				<cfif len(get_order.ship_method)>
                	#get_order.ship_method#
              	<cfelse>
                	#get_order.SHIP_METHOD_ID#
              	</cfif> 
	</cfquery>
</cfif>

<cfquery name="get_shippng_plan" datasource="#dsn3#">
	SELECT     
    	ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
        ESR.DELIVER_EMP, 
        ESR.NOTE, 
        ESR.SHIP_RESULT_INTERNALDEMAND_ID AS DELIVER_PAPER_NO, 
        ESR.REFERENCE_NO, 
        ESR.OUT_DATE, 
        ESR.SHIP_METHOD_TYPE, 
        ESR.DELIVERY_DATE, 
        ESR.DEPARTMENT_ID, 
        ESR.LOCATION_ID,
        ESR.DEPARTMENT_IN_ID, 
        ESR.LOCATION_IN_ID,
        ESR.SHIP_STAGE, 
        ESR.IS_TYPE, 
        ESR.RECORD_EMP, 
        ESR.RECORD_DATE, 
        ESR.UPDATE_EMP, 
        ESR.UPDATE_DATE,
        SM.SHIP_METHOD,
        TBL_1.DEPO_NAME AS CIKIS_DEPO,
        TBL_2.DEPO_NAME AS GIRIS_DEPO
	FROM         
    	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR LEFT OUTER JOIN
    	#dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID LEFT JOIN
        (
        	SELECT 
            	D.DEPARTMENT_ID, 
                SL.LOCATION_ID,
                D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS DEPO_NAME
			FROM     
            	#dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) INNER JOIN
                #dsn_alias#.STOCKS_LOCATION AS SL WITH (NOLOCK) ON D.DEPARTMENT_ID = SL.DEPARTMENT_ID INNER JOIN
                #dsn_alias#.BRANCH AS B WITH (NOLOCK) ON D.BRANCH_ID = B.BRANCH_ID
        ) AS TBL_1 ON ESR.DEPARTMENT_ID = TBL_1.DEPARTMENT_ID AND ESR.LOCATION_ID = TBL_1.LOCATION_ID LEFT JOIN
        (
        	SELECT 
            	D.DEPARTMENT_ID, 
                SL.LOCATION_ID,
                D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS DEPO_NAME
			FROM     
            	#dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) INNER JOIN
                #dsn_alias#.STOCKS_LOCATION AS SL WITH (NOLOCK) ON D.DEPARTMENT_ID = SL.DEPARTMENT_ID INNER JOIN
                #dsn_alias#.BRANCH AS B WITH (NOLOCK) ON D.BRANCH_ID = B.BRANCH_ID
        ) AS TBL_2 ON ESR.DEPARTMENT_IN_ID = TBL_2.DEPARTMENT_ID AND ESR.LOCATION_IN_ID = TBL_2.LOCATION_ID
	WHERE     
    	ESR.SHIP_RESULT_INTERNALDEMAND_ID IN
                          	(
                           	SELECT     
                            	SHIP_RESULT_INTERNALDEMAND_ID
                            FROM          
                            	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW
                            WHERE      
                            	ORDER_ID = #attributes.order_id#
                           	)
</cfquery>
<cfif GET_ORDER.recordcount>
    
	<cfparam name="attributes.reference_no" default="#GET_ORDER.REF_NO#">
    <cfquery name="get_default_department" datasource="#dsn#">
    	SELECT DEFAULT_RF_TO_SV_DEP, DEFAULT_RF_TO_SV_LOC FROM EZGI_PDA_DEPARTMENT_DEFAULTS WHERE EPLOYEE_ID = #session.ep.userid#
    </cfquery>
    <cfif not get_default_department.recordcount or not len(get_default_department.DEFAULT_RF_TO_SV_DEP) or not len(get_default_department.DEFAULT_RF_TO_SV_LOC)>
		<script type="text/javascript">
            alert("<cf_get_lang dictionary_id='326.Kullanıcı İçin Default Depo Tanımlayınız.!'>");
            window.close()
        </script>
        <cfabort>
    </cfif>
    
    <cfif get_default_department.recordcount>
    	<cfset default_dep = ListGetAt(get_default_department.DEFAULT_RF_TO_SV_DEP,2)>
        <cfset default_loc = ListGetAt(get_default_department.DEFAULT_RF_TO_SV_LOC,2)>
    <cfelse>
    	<cfset default_dep =''>
        <cfset default_loc =''>
    </cfif>
    <cfquery name="get_department" datasource="#dsn#">
		SELECT     
        	DEPARTMENT.DEPARTMENT_HEAD, 
            DEPARTMENT.BRANCH_ID, 
            DEPARTMENT.DEPARTMENT_ID, 
            STOCKS_LOCATION.LOCATION_ID, 
            STOCKS_LOCATION.COMMENT
		FROM         
    		DEPARTMENT INNER JOIN
        	STOCKS_LOCATION ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
  	  	WHERE 
        	DEPARTMENT.DEPARTMENT_ID = #default_dep# AND 
            STOCKS_LOCATION.LOCATION_ID = #default_loc#     
	</cfquery>
    <cfparam name="attributes.branch_id" default="#get_department.BRANCH_ID#">
    <cfparam name="attributes.department_id" default="#get_department.DEPARTMENT_ID#">
    <cfparam name="attributes.location_id" default="#get_department.LOCATION_ID#">
    <cfparam name="attributes.department_name" default="#get_department.DEPARTMENT_HEAD#-#get_department.COMMENT#">
    
    <cfquery name="get_department_in" datasource="#dsn#">
		SELECT     
        	DEPARTMENT.DEPARTMENT_HEAD, 
            DEPARTMENT.BRANCH_ID, 
            DEPARTMENT.DEPARTMENT_ID, 
            STOCKS_LOCATION.LOCATION_ID, 
            STOCKS_LOCATION.COMMENT
		FROM         
    		DEPARTMENT INNER JOIN
        	STOCKS_LOCATION ON DEPARTMENT.DEPARTMENT_ID = STOCKS_LOCATION.DEPARTMENT_ID
  	  	WHERE     
        	DEPARTMENT.DEPARTMENT_ID = #GET_ORDER.DELIVER_DEPT_ID# AND 
            STOCKS_LOCATION.LOCATION_ID = #GET_ORDER.LOCATION_ID# 	   
	</cfquery>
    <cfparam name="attributes.branch_in_id" default="#get_department_in.BRANCH_ID#">
    <cfparam name="attributes.department_in_id" default="#get_department_in.DEPARTMENT_ID#">
    <cfparam name="attributes.location_in_id" default="#get_department_in.LOCATION_ID#">
    <cfparam name="attributes.department_in_name" default="#get_department_in.DEPARTMENT_HEAD#-#get_department_in.COMMENT#">
    
	<cfquery name="get_order_det" datasource="#DSN3#">
		SELECT
        	ISNULL(PU.WEIGHT,0) AS WEIGHT,
            ISNULL(PU.VOLUME,0) AS VOLUME,
			ORR.STOCK_ID,
            ORR.QUANTITY,
            ORR.ORDER_ROW_ID,
            ORD.ORDER_ID,
            ORD.ORDER_HEAD, 
            ORD.ORDER_NUMBER,
            ORR.SPECT_VAR_ID,
            ORR.SPECT_VAR_NAME,
            ORD.SALES_ADD_OPTION_ID,
            ORD.ORDER_STAGE,
            ORR.ORDER_ROW_CURRENCY,
			ORR.NETTOTAL,
			ORR.TAX,
            ORD.DELIVER_DEPT_ID,
            (SELECT DEPARTMENT_HEAD FROM #dsn_alias#.DEPARTMENT WHERE DEPARTMENT_ID = ORR.DELIVER_DEPT) AS DEPARTMENT_HEAD,
            (SELECT COMMENT FROM #dsn_alias#.STOCKS_LOCATION WHERE DEPARTMENT_ID = ORR.DELIVER_DEPT AND LOCATION_ID = ORR.DELIVER_LOCATION) AS COMMENT,
            S.PRODUCT_NAME,
            S.STOCK_CODE,
            S.STOCK_CODE_2,
            S.PRODUCT_ID,
            ISNULL(S.IS_KARMA,0) AS IS_KARMA,
            ISNULL(ORR.DELIVER_AMOUNT,0) AS DELIVER_AMOUNT,
            (
            SELECT     
            	SPECT_MAIN_ID
			FROM         
            	SPECTS
			WHERE     
            	SPECT_VAR_ID = ORR.SPECT_VAR_ID
            ) AS SPECT_MAIN_ID,
            (
            	SELECT       
                	SUM(REAL_STOCK) AS REAL_STOCK
				FROM            
                	#dsn2_alias#.GET_STOCK_LAST_LOCATION
				WHERE  
                	<cfif len(default_dep) and len(default_loc)>     
                        LOCATION_ID = #default_loc# AND 
                        DEPARTMENT_ID = #default_dep# AND 
                    </cfif>
                    STOCK_ID = ORR.STOCK_ID
           	) AS DEPO
		FROM
			ORDER_ROW ORR,
			ORDERS ORD,
			STOCKS S,
            PRODUCT_UNIT PU
		WHERE
			ORD.ORDER_ID = ORR.ORDER_ID AND
			ORR.STOCK_ID = S.STOCK_ID AND 
            S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID AND
            ORD.ORDER_ID = #attributes.order_id#
	</cfquery>
    <cfset order_row_id_list = Valuelist(get_order_det.ORDER_ROW_ID)>
    <cfquery name="get_teshir" datasource="#dsn3#">
    	SELECT ORDER_ROW_ID FROM EZGI_ORDER_TESHIR WHERE ORDER_ROW_ID IN (#order_row_id_list#)
    </cfquery>
    <cfoutput query="get_teshir">
  		<cfset 'teshir_#ORDER_ROW_ID#'= ORDER_ROW_ID>
    </cfoutput>
	<cfquery name="get_ship_det" datasource="#DSN3#">
		SELECT     
            SUM(ESRR.ORDER_ROW_AMOUNT) ORDER_ROW_AMOUNT, 
            ESRR.ORDER_ROW_ID
		FROM         
        	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR INNER JOIN
            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR ON ESRR.SHIP_RESULT_INTERNALDEMAND_ID = ESR.SHIP_RESULT_INTERNALDEMAND_ID
		WHERE     
        	ESRR.ORDER_ROW_ID IN (#order_row_id_list#)
      	GROUP BY
        	ESRR.ORDER_ROW_ID
	</cfquery>
	<cfoutput query="get_ship_det">
    	<cfset 'ORDER_ROW_AMOUNT_#ORDER_ROW_ID#' = ORDER_ROW_AMOUNT>
    </cfoutput>
</cfif>
<cfsavecontent variable="sevk_talep"><cf_get_lang dictionary_id='1378.İlişkili Sevk Talepleri'></cfsavecontent>
<cf_seperator id="iliskili_sevk" header="#sevk_talep#" is_closed=0>
<table id="iliskili_sevk" width="100%">
	<tr>
		<td>
			 <cf_medium_list>
				<thead>
					<tr> 
						<th></th>
						<th><cf_get_lang dictionary_id='375.Sevk Talep No'></th>
						<th><cf_get_lang dictionary_id='38422.Sevk Tarihi'></th>
                        <th><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></th>
                        
                        <th><cf_get_lang dictionary_id='29428.Çıkış Depo'></th>
                        <th><cf_get_lang dictionary_id='56969.Giriş Depo'></th>
                        
                        <th><cf_get_lang dictionary_id='38281.Planlayan'></th>
                        <th><cf_get_lang dictionary_id='58784.Referans'></th>
                        <th><cf_get_lang dictionary_id='377.KNT.'></th>
					</tr>
              	</thead>
                <tbody>
                	<cfif get_shippng_plan.recordcount>
                     	<cfoutput query="get_shippng_plan">
              				<tr>
                            	<td align="center" id="order_row#currentrow#" class="color-row" onclick="gizle_goster(order_stocks_detail#currentrow#);connectAjax('#currentrow#','#SHIP_RESULT_INTERNALDEMAND_ID#');gizle_goster(siparis_goster#currentrow#);gizle_goster(siparis_gizle#currentrow#);">
                                    <img id="siparis_goster#currentrow#" src="/images/listele.gif" title="<cf_get_lang dictionary_id ='58596.Göster'>">
                                    <img id="siparis_gizle#currentrow#" src="/images/listele_down.gif" title="<cf_get_lang dictionary_id='58628	.Gizle'>" style="display:none">
                                </td>
                                <td>#DELIVER_PAPER_NO#</td>
                                <td>#Dateformat(OUT_DATE, dateformat_style)#</td> 
                                <td>#SHIP_METHOD#</td>
                                
                                <td>#CIKIS_DEPO#</td>
                                <td>#GIRIS_DEPO#</td>
                                
                                <td>#get_emp_info(DELIVER_EMP,0,0)#</td>
                                <td>#REFERENCE_NO#</td>
                                <td style="text-align:center; width:20px">
                                	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.popup_upd_ezgi_shipping_internaldemand&iid=#SHIP_RESULT_INTERNALDEMAND_ID#&order_id=#attributes.order_id#','wide');" class="tableyazi" title="<cf_get_lang dictionary_id='724.Sevk Fişine Git'>">
                                    	<img src="/images/update_list.gif" border="0" />
                                    </a>
                                </td>     
                         	</tr>
                            <tr id="order_stocks_detail#currentrow#" style="display:none" class="nohover">
                                <td colspan="9">
                                    <div align="left" id="DISPLAY_ORDER_STOCK_INFO#currentrow#"></div>
                                </td>
                			</tr>
                     	</cfoutput>
                  	</cfif>
              	</tbody>
          	 </cf_medium_list>            
		</td>
	</tr>
</table>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='30065.Sevk Talebi Ekle'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#">
    	<cfform name="add_packet_ship" id="add_packet_ship" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_ezgi_shipping_internaldemand&order_id=#url.order_id#">
        	<cfinput type="hidden" name="today_value" id="today_value" value="#DateFormat(now(),dateformat_style)#">
            <cfinput type="hidden" name="order_row_id_list" value="#order_row_id_list#">
			<input type="hidden" name="order_comp" id="order_comp" value="<cfoutput>#get_par_info(get_order.company_id,1,0,0)#</cfoutput>">
			<input type="hidden" name="order_cons" id="order_cons" value="<cfoutput>#get_cons_info(get_order.consumer_id,1,0,0)#</cfoutput>">
			<input type="hidden" name="order_number" id="order_number" value="<cfoutput>#get_order.order_number#</cfoutput>">
			<cfif len(get_order.ship_address)>
				<input type="hidden" name="order_adress" id="order_adress" value="<cfoutput>#get_order.ship_address#</cfoutput>">
			<cfelse>
				<input type="hidden" name="order_adress" id="order_adress" value="">
			</cfif>
			<cfif len(get_order.ship_method)>
				<input type="hidden" name="order_type" id="order_type" value="<cfoutput>#get_ship_method.ship_method#</cfoutput>">
			<cfelse>
				<input type="hidden" name="order_type" id="order_type" value="">
			</cfif>
			<input type="hidden" name="order_date" id="order_date" value="<cfoutput>#dateformat(get_order.order_date,dateformat_style)#</cfoutput>">
        	<cf_basket_form id="add_packet_ship_">
            	<div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
            						<div class="col col-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="form-group" id="item-stage">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58859.Süreç'>*</label>
	                            			<div class="col col-8 col-xs-12">
                                             	<cf_workcube_process is_upd='0' is_detail='0'>
                                          	</div>
                                     	</div>
    									<div class="form-group" id="item-department-out">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29428.Çıkış Depo'>*</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                            	<input type="hidden" name="branch_id" id="branch_id" value="<cfif isdefined("attributes.branch_id")><cfoutput>#attributes.branch_id#</cfoutput></cfif>">
                                                <input type="hidden" name="department_id" id="department_id" value="<cfif isdefined("attributes.department_id")><cfoutput>#attributes.department_id#</cfoutput></cfif>">
                                                <input type="hidden" name="location_id" id="location_id" value="<cfif isdefined("attributes.location_id")><cfoutput>#attributes.location_id#</cfoutput></cfif>">
                                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='45473.Yaptığınız İşleme Bağlı Olarak Depo Girmelisiniz'> !</cfsavecontent>
                                                <cfif isdefined("attributes.department_name")>
                                                    <cfinput type="text" name="department_name" id="department_name" value="#attributes.department_name#" passthrough="readonly=yes" message="#message#" style="width:170px;">
                                                <cfelse>
                                                    <cfinput type="text" name="department_name" id="department_name" value="" passthrough="readonly=yes" message="#message#" style="width:170px;">
                                                </cfif>
                                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_stores_locations&form_name=add_packet_ship&field_name=department_name&field_id=department_id&field_location_id=location_id&branch_id=branch_id','list')"></span>
                                				</div>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-sevk">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29500.Sevk Yöntemi'> *</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<input type="hidden" name="ship_method_id" id="ship_method_id" value="<cfif isdefined("attributes.ship_method_id")><cfoutput>#attributes.ship_method_id#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method_id#</cfoutput></cfif>">
													<input type="text" name="ship_method_name" id="ship_method_name" value="<cfif isdefined("attributes.ship_method_name")><cfoutput>#attributes.ship_method_name#</cfoutput><cfelseif isdefined('get_ship_method')><cfoutput>#get_ship_method.ship_method#</cfoutput></cfif>" readonly style="width:170px;">
                                                	<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_ship_methods&field_name=add_packet_ship.ship_method_name&field_id=add_packet_ship.ship_method_id','medium');"></span>
                                				</div>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-detail">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<textarea name="note" id="note" style="height:60px"><cfoutput>#get_shippng_plan.NOTE#</cfoutput></textarea>
                                          	</div>
                                     	</div>
                                 	</div>
                                    <div class="col col-6 col-xs-12" type="column" index="2" sort="true">
                                        <div class="form-group" id="item-reference">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58794.Referans No'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<input type="text" name="reference_no" id="reference_no" readonly="readonly" value="<cfoutput>#attributes.reference_no#</cfoutput>" maxlength="25" style="width:100px;">
                                          	</div>
                                     	</div>
                                        
                                        <div class="form-group" id="item-department-in">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='56969.Giriş Depo'>*</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                            	<input type="hidden" name="branch_in_id" id="branch_in_id" value="<cfif isdefined("attributes.branch_in_id")><cfoutput>#attributes.branch_in_id#</cfoutput></cfif>">
                                                <input type="hidden" name="department_in_id" id="department_in_id" value="<cfif isdefined("attributes.department_in_id")><cfoutput>#attributes.department_in_id#</cfoutput></cfif>">
                                                <input type="hidden" name="location_in_id" id="location_in_id" value="<cfif isdefined("attributes.location_in_id")><cfoutput>#attributes.location_in_id#</cfoutput></cfif>">
                                                <cfsavecontent variable="message_in"><cf_get_lang dictionary_id='45473.Yaptığınız İşleme Bağlı Olarak Depo Girmelisiniz'> !</cfsavecontent>
                                                <cfif isdefined("attributes.department_in_name")>
                                                    <cfinput type="text" name="department_in_name" id="department_in_name" value="#attributes.department_in_name#" passthrough="readonly=yes" message="#message_in#" style="width:170px;">
                                                <cfelse>
                                                    <cfinput type="text" name="department_in_name" id="department_in_name" value="" passthrough="readonly=yes" message="#message_in#" style="width:170px;">
                                                </cfif>
                                                <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_stores_locations&form_name=add_packet_ship&field_name=department_in_name&field_id=department_in_id&field_location_id=location_in_id&branch_id=branch_in_id','list')"></span>
                                				</div>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-outdate">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='45463.Depo Çıkış Tarihi'></label>
	                            			<div class="col col-4 col-xs-12">
                                            	<div class="input-group">
                                             		<cfsavecontent variable="message"><cf_get_lang dictionary_id='45464.Depo Çıkış Tarihi Girmelisiniz'> !</cfsavecontent>
													<cfinput type="text" name="action_date" id="action_date" value="#dateformat(get_order.DELIVERDATE,dateformat_style)#" validate="eurodate" required="Yes" message="#message#">
                                                	<span class="input-group-addon"><cf_wrk_date_image date_field="action_date"></span>
                                                </div>
                                          	</div>
                                            <div class="col col-2 col-xs-12">
                                            	<select name="start_h" id="start_h">
													<cfoutput>
                                                        <cfloop from="0" to="23" index="i">
                                                            <option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
                                                        </cfloop>
                                                    </cfoutput>
                                                </select>
                                           	</div>
                                            <div class="col col-2 col-xs-12">
                                                <select name="start_m" id="start_m">
                                                    <cfoutput>
                                                        <cfloop from="0" to="59" index="i">
                                                            <option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
                                                        </cfloop>
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-deliverdate">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></label>
	                            			<div class="col col-4 col-xs-12">
                                            	<div class="input-group">
                                             		<cfsavecontent variable="message"><cf_get_lang dictionary_id='45647.Lütfen Teslim Tarihi Formatını Doğru Giriniz'>!</cfsavecontent>
													<cfinput type="text" name="deliver_date" id="deliver_date" value="#dateformat(get_order.DELIVERDATE,dateformat_style)#" validate="eurodate" style="width:65px;" message="#message#">
                                                	<span class="input-group-addon"><cf_wrk_date_image date_field="deliver_date"></span>
                                                </div>
                                          	</div>
                                            <div class="col col-2 col-xs-12">
                                            	<select name="deliver_h" id="deliver_h">
													<cfoutput>
                                                        <cfloop from="0" to="23" index="i">
                                                            <option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
                                                        </cfloop>

                                                    </cfoutput>
                                                </select>
                                           	</div>
                                            <div class="col col-2 col-xs-12">
                                                <select name="deliver_m" id="deliver_m">
                                                    <cfoutput>
                                                        <cfloop from="0" to="59" index="i">
                                                            <option value="#numberformat(i,00)#">#numberformat(i,00)#</option>
                                                        </cfloop>
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                     	</div>
                                    	<div class="form-group" id="item-deliveremp">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='276.Talep Eden'></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<input type="hidden" name="deliver_id2" id="deliver_id2" value="<cfoutput>#session.ep.userid#</cfoutput>">
													<input type="text" name="deliver_name2" id="deliver_name2" value="<cfoutput>#get_emp_info(session.ep.userid,0,0)#</cfoutput>" readonly>
                    								<span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id2=add_packet_ship.deliver_id2&field_name=add_packet_ship.deliver_name2&select_list=1','list');"></span>
                                				</div>
                                          	</div>
                                     	</div>    
                                        
                                 	</div>
                               	</cf_box_elements>
                          	</div>
                      	</div>
             	</div>
         	</cf_basket_form>
	
     		<cf_basket id="upd_default_measure_bask">
            	<cf_grid_list sort="0">
                	<thead>
                        <tr>
                           <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="width:80px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th><cf_get_lang dictionary_id='57646.Teslim Depo'></th>
                            <th style="width:60px"><cf_get_lang dictionary_id='57789.Özel Kod'></th>
                            <th style="width:90px"><cf_get_lang dictionary_id='57482.Aşama'></th>
                            <th style="width:80px"><cf_get_lang dictionary_id='57647.Spec'></th>
                            <th style="width:40px"><cf_get_lang dictionary_id='29784.Ağırlık'></th>
                            <th style="width:40px"><cf_get_lang dictionary_id='30114.Hacim'></th>
                            <th style="text-align:right; width:60px"><cf_get_lang dictionary_id='57611.Sipariş'></th>
                            <th style="text-align:center; width:15px"></th>
                            <th style="text-align:center; width:15px">&nbsp;
                                <input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: wrk_select_all2('all_conv_product','_conversion_product_',<cfoutput>#get_order_det.recordcount#</cfoutput>);">
                           </th>
                		</tr>
                  	</thead>
                    <tbody id="table2">
						<cfset irs_top=0>
                        <cfif get_order_det.recordcount>
                            <cfoutput query="get_order_det">
                                <cfset stock_id=get_order_det.STOCK_ID>
                                <tr>
                                    <td style="text-align:right;">#Currentrow#</td>
                                    <td>
                                    	<cfif IS_KARMA eq 1>
                                            <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_dsp_karma_koli&pid=#product_id#','page');">
                                        <cfelse>
                                            <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=stock.detail_store_stock_popup&stock_id=#stock_id#&product_id=#product_id#','page');">
                                        </cfif>
                                    		#get_order_det.STOCK_CODE#
                                       	</a>
                                   	</td>
                                    <td>#get_order_det.PRODUCT_NAME#</td>
                                    <td>#get_order_det.COMMENT#-#get_order_det.DEPARTMENT_HEAD#</td>
                                    <td>#get_order_det.STOCK_CODE_2#</td>
                                    <td style="text-align:center">
                                    	<cfif order_row_currency eq -8><cf_get_lang_main no ='1952.Fazla Teslimat'>
										<cfelseif order_row_currency eq -7><cf_get_lang_main no ='1951.Eksik Teslimat'>
                                   		<cfelseif order_row_currency eq -6><cf_get_lang_main no='1349.Sevk'>
                                       	<cfelseif order_row_currency eq -5><cf_get_lang_main no ='44.Üretim'>
                                      	<cfelseif order_row_currency eq -4><cf_get_lang_main no ='1950.Kismi Üretim'>
                                      	<cfelseif order_row_currency eq -3><cf_get_lang_main no ='1949.Kapatildi'>
                                      	<cfelseif order_row_currency eq -2><cf_get_lang_main no ='1948.Tedarik'>
                                     	<cfelseif order_row_currency eq -1><cf_get_lang_main no='1305.Açık'>
                                      	<cfelseif order_row_currency eq -9><cf_get_lang_main no ='1094.İptal'>
                                      	<cfelseif order_row_currency eq -10><cf_get_lang dictionary_id='40876.Kapatıldı(Manuel)'></cfif>
                                    </td>
                                    <td>
                                        <cfif len(SPECT_VAR_ID)>
                                            <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_upd_spect&id=#SPECT_VAR_ID#&stock_id=#stock_id#','list');" class="tableyazi">#spect_main_id#-#spect_var_id#</a>	
                                        </cfif>
                                    </td>
                                    <td style="text-align:right;">#AmountFormat(get_order_det.WEIGHT*get_order_det.QUANTITY)#</td>
                                    <td style="text-align:right;">#AmountFormat(get_order_det.VOLUME/1000000*get_order_det.QUANTITY)#</td>
                                    <cfset total_weight = total_weight + (get_order_det.WEIGHT*get_order_det.QUANTITY)>
                                    <cfset total_volume = total_volume + (get_order_det.VOLUME/1000000*get_order_det.QUANTITY)>
                                    <input type="hidden"  name="volume_#currentrow#" id="volume_#currentrow#" value="#round(get_order_det.VOLUME/1000000*get_order_det.QUANTITY*100)/100#" />
                                    <input type="hidden"  name="weight_#currentrow#" id="weight_#currentrow#" value="#round(get_order_det.WEIGHT*get_order_det.QUANTITY*100)/100#" />
									<input type="hidden" name="nettotal_w_tax_#currentrow#" id="nettotal_w_tax_#currentrow#" 
										value="#round((get_order_det.NETTOTAL * (1 + get_order_det.TAX/100)) * 100) / 100#">									
                                    <td style="text-align:right;">#AmountFormat(get_order_det.QUANTITY)#</td>
                                 	<cfif isdefined('ORDER_ROW_AMOUNT_#ORDER_ROW_ID#')>
                                      	<cfset row_amount = get_order_det.QUANTITY-Evaluate('ORDER_ROW_AMOUNT_#ORDER_ROW_ID#')>
                                  	<cfelse>
                                      	<cfset row_amount = get_order_det.QUANTITY>
                                  	</cfif>
                                  	<input type="hidden" style="text-align:right; width:40px" readonly="readonly" name="row_amount_#ORDER_ROW_ID#" value="#amountformat(row_amount)#" />
                                    <td style="text-align:center">
                                    	<cfif isdefined('ORDER_ROW_AMOUNT_#ORDER_ROW_ID#')> <!---Plan Oluşturulmuşsa Teşhir işlemi Yapılamaz--->
                                        
                                        <cfelse>
											<cfif isdefined('teshir_#ORDER_ROW_ID#')>
                                                <a href="javascript://" onClick="sil(#ORDER_ROW_ID#,#ORDER_ID#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
                                            <cfelse>
                                                <cfif irs_top eq 0>
                                                    <a href="javascript://" onClick="ekle(#ORDER_ROW_ID#,#ORDER_ID#);"><img src="/images/plus_list.gif" align="absmiddle" border="0"></a>
                                                </cfif>
                                            </cfif>
                                        </cfif>
                                    </td>
                                    <td style="text-align:center;">
                                    	<cfif isdefined('teshir_#ORDER_ROW_ID#')><!---Teşhir İşaretlenmişse--->
                                        	<img src="/images/b_ok.gif" border="0" title="">
                                        <cfelse>
											<cfif not isdefined('ORDER_ROW_AMOUNT_#ORDER_ROW_ID#')><!--- Plan Oluşturulmamışsa--->
                                                <cfif ORDER_ROW_CURRENCY eq -3 or ORDER_ROW_CURRENCY eq -9 or ORDER_ROW_CURRENCY eq -8 or ORDER_ROW_CURRENCY eq -10><!--- Satır Sevk Yapılmışsa  VE (İptal, Kapatalıdı, Manuel Kapatıldı, Fazla Teslimat)--->
                                                    <img src="/images/d_ok.gif" border="0" title="">
                                                    <cfinput type="hidden" name="kontrol_#currentrow#" id="kontrol_#currentrow#" value="0">
                                                <cfelse>
                                                    <cfinput type="hidden" name="kontrol_#currentrow#" id="kontrol_#currentrow#" value="1">
                                                    <input type="checkbox" name="select_order_row_#ORDER_ROW_ID#" value="#QUANTITY#" id="_conversion_product_#currentrow#" onClick="hesapla();"
                                                        <cfif SALES_ADD_OPTION_ID eq 2>
                                                             checked="checked" readonly="readonly"
                                                        </cfif> 
                                                    >
                                                </cfif>
                                            <cfelse>
                                                <img src="/images/c_ok.gif" border="0" title="<cf_get_lang dictionary_id='763.Sevk Planına Alınmış'>">
                                                <cfinput type="hidden" name="kontrol_#currentrow#" id="kontrol_#currentrow#" value="0">
                                            </cfif>
                                        </cfif>
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfif>
                    </tbody>
                    <tfoot>
                    	<cfoutput>
                    	<tr>
                        	<td style="text-align:left; font-weight:bold" colspan="7"><cf_get_lang dictionary_id='57492.Toplam'></td>
                            <td style="text-align:right; font-weight:bold">
                            	<input style="text-align:right; font-weight:bold; border:none; width:95%" type="text" name="total_weight" id="total_weight" value="#AmountFormat(0,2)#">
                            </td>
                            <td style="text-align:right; font-weight:bold">
                            	<input style="text-align:right; font-weight:bold; border:none; width:95%" type="text" name="total_volume" id="total_volume" value="#AmountFormat(0,2)#">
                            </td>
                            <td colspan="3"></td>
                        </tr>
                        </cfoutput>
                    </tfoot>
               	</cf_grid_list>
                <div id="action_buttons">
					<cf_popup_box_footer>
						<cf_workcube_buttons is_upd='0' add_function='control()'>
					</cf_popup_box_footer>
				</div>
            </cf_basket>
        </cfform>
    </cf_box>
</div>
<script type="text/javascript">
	function wrk_select_all2(all_conv_product,_conversion_product_,number)
	{
		for(var cl_ind=1; cl_ind <= number; cl_ind++)
		{
			if(document.getElementById('kontrol_'+cl_ind).value == 1)
			{
				if(document.getElementById(all_conv_product).checked == true)
				{
					if(document.getElementById('_conversion_product_'+cl_ind).checked == false)
						document.getElementById('_conversion_product_'+cl_ind).checked = true;
				}
				else
				{
					if(document.getElementById('_conversion_product_'+cl_ind).checked == true)
						document.getElementById('_conversion_product_'+cl_ind).checked = false;
				}
			}
		}
		hesapla();
	}
	function control()
	{
		<cfif x_out_date_control eq 1>
		if (!date_check(add_packet_ship.today_value,add_packet_ship.action_date,"Sevk tarihi Bugünden Önceye Yapılamaz.!"))
			return false;
		</cfif>
		if(document.getElementById("ship_method_id").value == "")	
		{
			alert("<cf_get_lang dictionary_id='764.Lütfen Sevk Yöntemi Seçiniz'> !");
			return false;
		}
		if(process_cat_control())
			return true;
		else
			return false;
	}
	function connectAjax(crtrow,ship_result_internaldemand_id)
	{
		var load_url_ = '<cfoutput>#request.self#?fuseaction=sales.emptypopup_ajax_ezgi_shipping_detail</cfoutput>&ship_result_internaldemand_id='+ship_result_internaldemand_id;
		AjaxPageLoad(load_url_,'DISPLAY_ORDER_STOCK_INFO'+crtrow,1);
	}
	function ekle(order_row_id,order_id)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_add_ezgi_teshir&order_row_id='+order_row_id+'&order_id='+order_id;	
	}
	function sil(order_row_id,order_id)
	{	
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_teshir&order_row_id='+order_row_id+'&order_id='+order_id;
	}
</script>