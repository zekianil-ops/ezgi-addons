<!---
    File: list_ezgi_dispatch_row.cfm
    Folder: Add_Ons\ezgi\e_shipping\display
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->

<cfset module_name="sales">
<cfquery name="get_department_name" datasource="#DSN#">
	SELECT 
		SL.LOCATION_ID,
		SL.COMMENT,
		D.DEPARTMENT_ID,
		D.DEPARTMENT_HEAD,
		D.BRANCH_ID
	FROM
		STOCKS_LOCATION SL,
		DEPARTMENT D
	WHERE 
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID
		AND D.BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id#)
	ORDER BY
		D.DEPARTMENT_HEAD,
		SL.COMMENT
</cfquery>
<cfquery name="get_ship_row" datasource="#dsn2#">
	SELECT  
    	SIR.DISPATCH_SHIP_ID,   
    	SIR.PRODUCT_ID, 
        SIR.AMOUNT, 
        SIR.UNIT, 
        SIR.STOCK_ID, 
        SIR.NAME_PRODUCT, 
        SIR.SPECT_VAR_ID, 
        SIR.SPECT_VAR_NAME, 
        SIR.SHIP_ROW_ID, 
      	S.STOCK_CODE,
        (SELECT DELIVER_DATE FROM SHIP_INTERNAL WHERE DISPATCH_SHIP_ID = SIR.DISPATCH_SHIP_ID) AS DELIVER_DATE
	FROM         
    	SHIP_INTERNAL_ROW AS SIR INNER JOIN
     	#dsn3_alias#.STOCKS AS S ON SIR.STOCK_ID = S.STOCK_ID 
	WHERE     
    	SIR.DISPATCH_SHIP_ID = #attributes.ship_id#     
</cfquery>
<cfquery name="get_ship" datasource="#dsn2#">
	SELECT        
    	SI.DELIVER_DATE, 
        ISNULL(SI.SHIPMENT_PACKAGE_AMOUNT,0) AS SHIPMENT_PACKAGE_AMOUNT,
        SI.DEPARTMENT_OUT, 
        SI.LOCATION_OUT, 
        SI.DEPARTMENT_IN, 
        SI.LOCATION_IN, 
        SH.SHIP_ID, 
        SH.SHIP_NUMBER, 
        ISNULL(SH.IS_DELIVERED,0) AS IS_DELIVERED,
        (SELECT COMMENT FROM #dsn_alias#.STOCKS_LOCATION WHERE DEPARTMENT_ID = SI.DEPARTMENT_OUT AND LOCATION_ID = SI.LOCATION_OUT) AS COMMENT
	FROM            
    	SHIP_INTERNAL AS SI LEFT OUTER JOIN
  		SHIP AS SH ON SI.DISPATCH_SHIP_ID = SH.DISPATCH_SHIP_ID
	WHERE        
    	SI.DISPATCH_SHIP_ID = #attributes.ship_id#
</cfquery>
<cfset location_info_ = get_location_info(get_ship.department_out,get_ship.location_out)>
<cfset attributes.out_departments = '#get_ship.DEPARTMENT_OUT#-#get_ship.LOCATION_OUT#'>
<cfset attributes.in_departments = '#get_ship.DEPARTMENT_IN#-#get_ship.LOCATION_IN#'>


<cfsavecontent variable="title_"><cf_get_lang dictionary_id='753.Sevk Talebi Düzenleme'></cfsavecontent>
<cfform name="orders" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_ship_internal_deliverdate" method="post">
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box title="#title_#">
			<cfinput type="hidden" name="ship_id" value="#attributes.ship_id#">
          	<cf_basket_form id="upd_default_measure">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                   		<div class="row formContent">
                                <cf_box_elements>
            						<div class="col col-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="form-group" id="item-termdate">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></label>
	                            			<div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                <cfinput type="text" name="delivery_date" id="delivery_date" value="#dateformat(get_ship_row.deliver_date,dateformat_style)#" validate="eurodate" required="Yes" style="width:85px;">
                                                <span class="input-group-addon"><cf_wrk_date_image date_field="delivery_date"></span>
                                                </div>
                                          	</div>
                                     	</div>
                                        <div class="form-group" id="item-outstore">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29428.Çıkış Depo'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<select name="out_departments" id="out_departments" style="width:180px;height:20px">
                                                    <option value=""><cf_get_lang dictionary_id='30031.Lokasyon'></option>
                                                    <cfoutput query="get_department_name">
                                                        <option value="#department_id#-#location_id#" <cfif isdefined("attributes.out_departments") and attributes.out_departments is '#department_id#-#location_id#'>selected</cfif>>#department_head#-#comment#</option>
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                      	</div>
                                        <div class="form-group" id="item-instore">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36506.Giriş Depo'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<select name="in_departments" id="in_departments" style="width:180px;height:20px">
                                                    <option value=""><cf_get_lang dictionary_id='30031.Lokasyon'></option>
                                                    <cfoutput query="get_department_name">
                                                        <option value="#department_id#-#location_id#" <cfif isdefined("attributes.in_departments") and attributes.in_departments is '#department_id#-#location_id#'>selected</cfif>>#department_head#-#comment#</option>
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                      	</div>
                                        
                                  	</div>
                                    <div class="col col-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="form-group" id="item-paket">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='1096.toplam paket Sayısı'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	  <cfinput type="text" name="package_amount" id="package_amount" value="#TlFormat(get_ship.SHIPMENT_PACKAGE_AMOUNT,0)#" style="width:85px;">
                                          	</div>
                                      	</div>
                                        <cfif len(get_ship.SHIP_ID)>
                                        	<div class="form-group" id="item-sevkok">
                                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29587.Sevk İrsaliyesi'> </label>
                                                <div class="col col-8 col-xs-12">
                                                	<cfoutput>
                                                    <a href="#request.self#?fuseaction=stock.add_ship_dispatch&event=upd&ship_id=#get_ship.SHIP_ID#" class="tableyazi">
                                                        #get_ship.SHIP_NUMBER#
                                                    </a>
                                                    </cfoutput>
                                                </div>
                                            </div>
                                        
                                        	<div class="form-group" id="item-sevktes">
                                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='45616.Teslim Alındı'></label>
                                                <div class="col col-8 col-xs-12">
                                                    <cfif get_ship.IS_DELIVERED>
                                                        <span class="icn-md icon-check"></span>
                                                    <cfelse>
                                                        <span class="icn-md icon-times"></span>
                                                    </cfif>
                                                </div>
                                            </div>
                                        </cfif>
									</div>
                                </cf_box_elements>
                                <cf_box_footer>
									<div class="col col-12 col-xs-12">
                                     	<cf_workcube_buttons is_upd='1' delete_page_url='#request.self#?fuseaction=stock.emptypopup_upd_dispatch_internaldemand&event=del&shipDel=1&upd_id=#attributes.ship_id#&head=#location_info_#'>
                                    </div>
                				</cf_box_footer>
                     	</div>
                  	</div>
             	</div>
         	</cf_basket_form> 
            <cf_basket id="upd_default_measure_bask">
            	<cf_grid_list sort="0">
                	<thead>
                         <tr>
                            <th><cf_get_lang dictionary_id='58577.Sıra'></th> 
                            <th><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th><cf_get_lang dictionary_id='33925.Spec Main'></th>
                            <th width="50" style="text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th width="15"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_ship_row.recordcount>
                            <cfoutput query="get_ship_row">
                                <tr>
                                	<td>#currentrow#</td>
                                    <td>#STOCK_CODE#</td>
                                    <td>#NAME_PRODUCT#</td>
                                    <td>#SPECT_VAR_NAME#</td>
                                    <td style="text-align:right;">#TLFormat(amount,2)#</td>
                                    <td style="text-align:center;">
                                      	<a href="javascript://" onClick="sil(#DISPATCH_SHIP_ID#,#SHIP_ROW_ID#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>

                                    </td>
                                </tr>
                                
                            </cfoutput>
                        </cfif>
                    </tbody>
              	</cf_grid_list>  
          	</cf_basket>
        </cf_box>
    </div>
</cfform>
<script language="javascript">
	function sil(ship_id,ship_row_id)
	{	
		sor = confirm('<cf_get_lang dictionary_id='752.Satırı Silmek İstediğinizden Emin misiniz?'>');
		if(sor == true)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_dispatch_row&ship_id='+ship_id+'&ship_row_id='+ship_row_id,'small');
		else
			return false;
	}
</script>
