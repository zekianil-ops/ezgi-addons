<cfquery name="get_upd" datasource="#dsn3#">
        SELECT 
        	ESD.SHIPPING_DEMAND_ID, 
            ESD.ORDER_ROW_ID, 
            ESD.DEMAND_ORDER_ROW_ID, 
            ESD.EMPLOYEE_ID, 
            ESD.DEMAND_EMPLOYEE_ID, 
            ESD.DEMAND_STATUS_ID, 
            ESD.SHIPPING_DEMAND_STAGE, 
            ESD.START_DATE, 
         	ESD.FINISH_DATE,
            ESD.DETAIL, 
            ORR.PRODUCT_NAME,
            O.ORDER_NUMBER,
            O.ORDER_ID, 
            O.ORDER_ID DEMAND_ORDER_ID,
            O1.ORDER_NUMBER AS DEMAND_ORDER_NUMBER
		FROM     
        	EZGI_SHIPPING_DEMAND AS ESD INNER JOIN
            ORDER_ROW AS ORR ON ESD.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
            ORDER_ROW AS ORR1 ON ESD.DEMAND_ORDER_ROW_ID = ORR1.ORDER_ROW_ID INNER JOIN
            ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
            ORDERS AS O1 ON ORR1.ORDER_ID = O1.ORDER_ID
     	WHERE
        	ESD.SHIPPING_DEMAND_ID = #attributes.SHIPPING_DEMAND_ID#
</cfquery>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
	<cf_box style="height:700px;">
    	<cfform name="form_basket" method="post" action="">
        	<cfinput type="hidden" name="SHIPPING_DEMAND_ID" value="#attributes.SHIPPING_DEMAND_ID#">
            <cfinput type="hidden" name="order_row_id" value="#get_upd.order_row_id#">
            <cfinput type="hidden" name="demand_order_row_id" value="#get_upd.demand_order_row_id#">
        	<cf_box_elements>
            	<cfoutput>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    	
                        <div class="form-group" id="item-cat">
                            <label class="col col-4 col-xs-12">Talep Eden </label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group" id="item-demander">#get_emp_info(get_upd.EMPLOYEE_ID,0,0)#</div>
                            </div>
                        </div>	
                        <div class="form-group require" id="item-demand_date">
                            <label class="col col-4 col-sm-12">Talep Tarihi</label>
                            <div class="col col-8 col-sm-12">#DateFormat(get_upd.START_DATE,dateformat_style)#</div>                
                        </div>
                        <div class="form-group" id="item-product_name">
                            <label class="col col-4 col-xs-12">Ürün</label>
                            <div class="col col-8 col-xs-12">#get_upd.PRODUCT_NAME#</div>
                        </div>

                        <div class="form-group" id="item-order_numer">
                            <label class="col col-4 col-xs-12">Sipariş No</label>
                            <div class="col col-8 col-xs-12">
                                <div class="input-group">#get_upd.DEMAND_ORDER_NUMBER#</div>
                            </div>
                        </div>
                        <div class="form-group" id="item-process_cat">
                            <label class="col col-4 col-xs-12"><cf_get_lang_main no='642.Süreç/Asama'> *</label>
                            <div class="col col-8 col-xs-12">
                                <cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0' select_value='#get_upd.SHIPPING_DEMAND_STAGE#'>
                            </div>
                        </div>
                        <div class="form-group" id="item-status_type">	
                            <label class="col col-4 col-xs-12">Talep Onayı</label>				
                            <div class="col col-8 col-xs-12">
                            	<cfif get_upd.DEMAND_STATUS_ID eq 2 or get_upd.DEMAND_STATUS_ID eq 2>
                                	<cfif get_upd.DEMAND_STATUS_ID eq 2>Kabul</cfif>
                                    <cfif get_upd.DEMAND_STATUS_ID eq 3>Red</cfif>
                                <cfelse>
                                    <select name="status_type" id="status_type">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option> 
                                        <option value="2" <cfif get_upd.DEMAND_STATUS_ID eq 2>selected</cfif>>Kabul</option> 
                                        <option value="3" <cfif get_upd.DEMAND_STATUS_ID eq 3>selected</cfif>>Red</option> 
                                    </select>
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-detail">
                            <label class="col col-4 col-xs-12"><cf_get_lang_main no='217.Açiklama'> *</label>
                            <div class="col col-8 col-xs-12">
                                <textarea name="detail" id="detail" style="width:200px;height:60px;">#get_upd.DETAIL#</textarea>
                            </div>
                        </div>
                    </div>
                </cfoutput>
         	</cf_box_elements>
          	<cf_box_footer>
            	<div class="col col-12">
                	<cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
           		</div>
        	</cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		if(document.getElementById('status_type').value ==3 && document.getElementById('detail').value =='')
		{
			alert('Red Seçeneğinde Mutlaka Açıklama Belirmelisiniz');
			return false;
		}
		if(process_cat_control())
			return true;
		else
			return false;
	}	
</script>