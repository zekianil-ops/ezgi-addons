<cfif isdefined('attributes.connect_id') or isdefined('attributes.upd_id')>
	<cfset grosstotal = get_connect.GROSSTOTAL_>
    <cfset nettotal = get_connect.NETTOTAL_>
    <cfset discounttotal = get_connect.DISCOUNTTOTAL_>
    <cfset sub_discounttotal = get_connect.SUB_DISCOUNTTOTAL_>
    <cfset tax = get_connect.TAX_>
    <cfset son_oran = 0>
<cfelse>
	<cfset grosstotal = 0>
    <cfset nettotal = 0>
    <cfset discounttotal = 0>
    <cfset sub_discounttotal = 0>
    <cfset tax = 0>
    <cfset son_oran = 0>
</cfif>	
<cf_box closable="0">
	<cf_box_elements>
		<div class="col col-3 col-md-4 col-sm-12" type="column" index="1" sort="true">
        	<div class="form-group require" id="item-order_head">
				<div class="col col-12 col-sm-12">
					<table cellspacing="0" cellpadding="0" border="0" style="height:100%; width:100%; border-collapse: collapse;">
                        <tr >
                            <td style="text-align:center; padding: 6px 8px; font-weight:bold" colspan="2"><cf_get_lang dictionary_id='57677.Döviz'></td>
                        </tr>
                        <cfif isdefined('attributes.connect_id')>
                            <input type="hidden" name="money_recordcount" value="<cfoutput>#get_money.recordcount#</cfoutput>">
                            <cfoutput query="get_connect_money">
                                <tr >
                                    <td style="width:30%; padding: 2px 8px;"><input type="radio" name="basket" value="#money_type#" onchange="doviz_change(#currentrow#)" <cfif IS_SELECTED>checked</cfif>> #money_type#</td>
                                    <td style="text-align:right; width:70%; padding: 2px 8px;">
                                        <input type="text" name="money_#currentrow#" id="money_#currentrow#" value="#TlFormat(rate2,4)#" onchange="doviz_change(#currentrow#)" class="box" <cfif session.ep.money eq money_type>readonly="readonly"</cfif>/>
                                        <input type="hidden" name="money_type_#currentrow#" id="money_type_#currentrow#" value="#money_type#"  />
                                    </td>
                                </tr>
                            </cfoutput>
                        <cfelse>
                            <input type="hidden" name="money_recordcount" value="<cfoutput>#get_money.recordcount#</cfoutput>">
                            <cfoutput query="get_money">
                                <tr >
                                    <td style="width:30%; padding: 2px 8px;"><input type="radio" name="basket" value="#money#" onchange="doviz_change(#currentrow#)" <cfif session.ep.money eq money>checked</cfif>> #money#</td>
                                    <td style="text-align:right; width:70%; padding: 2px 8px;">
                                        <input type="text" name="money_#currentrow#" id="money_#currentrow#" value="#TlFormat(rate2,4)#" onchange="doviz_change(#currentrow#)" class="box" <cfif session.ep.money eq money>readonly="readonly"</cfif>/>
                                        <input type="hidden" name="money_type_#currentrow#" id="money_type_#currentrow#" value="#money#"  />
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfif>
                    </table>
				</div>                
			</div>
        </div>
        <div class="col col-3 col-md-4 col-sm-12" type="column" index="2" sort="true">
        	<div class="form-group require" id="item-order_orta1">
				<div class="col col-12 col-sm-12">
           		</div>
          	</div>
        </div>
        <div class="col col-3 col-md-4 col-sm-12" type="column" index="3" sort="true">
        	<div class="form-group require" id="item-order_orta2">
				<div class="col col-12 col-sm-12">
           		</div>
           	</div>
        </div>
        <div class="col col-3 col-md-4 col-sm-12" type="column" index="4" sort="true">
        	<div class="form-group require" id="item-order_head">
				<div class="col col-12 col-sm-12">
                    <table cellspacing="0" cellpadding="0" border="0" width="100%" height="100%" style="border-collapse: collapse;">
                        <cfoutput>
                        <tr>
                            <td width="205" class="txtbold" style="text-align:right; padding: 3px 8px;"><cf_get_lang_main no='80.Toplam'>&nbsp;</td>
                            <td style="text-align:right; width:100px; padding: 3px 8px;" name="total_default">
                                <input type="text" name="sub_total_brut_other" id="sub_total_brut_other" style="width:100px;text-align:right; font-weight:bold" class="box" value="" readonly>
                                <input type="hidden" name="sub_total_net_other" id="sub_total_net_other" value="">
                            </td>
                            <td style="text-align:right; width:100px; padding: 3px 8px;" name="total_default">
                                <input type="text" name="sub_total_brut" id="sub_total_brut" style="width:100px;text-align:right; font-weight:bold" class="box" value="" readonly>
                                <input type="hidden" name="sub_total_net" id="sub_total_net" value="">
                            </td>
                        </tr>	
                        <tr>
                            <td style="text-align:right; padding: 3px 8px;"><cf_get_lang_main no='237.Toplam İndirim'>&nbsp;</td>
                            <td style="text-align:right; padding: 3px 8px;" name="total_discount_default">
                                <input type="text" name="sub_total_discount_other" id="sub_total_discount_other" style="width:100px;text-align:right; font-weight:bold" class="box" value="" readonly>
                            </td>
                            <td style="text-align:right; padding: 3px 8px;" name="total_discount_default">
                                <input type="text" name="sub_total_discount" id="sub_total_discount" style="width:100px;text-align:right; font-weight:bold" class="box" value="" readonly>
                            </td>
                        </tr>
                        <tr>
                            <td style="text-align:right; padding: 3px 8px;"><cf_get_lang_main no='227.KDV'>&nbsp;</td>
                            <td style="text-align:right; padding: 3px 8px;" name="total_discount_default">
                                <input type="text" name="sub_total_tax_other" id="sub_total_tax_other" style="width:100px;text-align:right; font-weight:bold" class="box" value="" readonly>
                            </td>
                            <td style="text-align:right; padding: 3px 8px;" name="total_discount_default">
                                <input type="text" name="sub_total_tax" id="sub_total_tax" style="width:100px;text-align:right; font-weight:bold" class="box" value="" readonly>
                            </td>
                        </tr>

                        <tr>
                            <td style="text-align:right; padding: 3px 8px;"><cf_get_lang dictionary_id="57680.Genel Toplam">&nbsp;</td>
                            <td style="text-align:right; padding: 3px 8px;" name="net_total_default">
                                <input type="text" name="sub_total_end_other" id="sub_total_end_other" style="width:100px;text-align:right; font-weight:bold" class="box" value="" readonly>
                            </td>
                            <td style="text-align:right; padding: 3px 8px;" name="net_total_default">
                                <input type="text" name="sub_total_end" id="sub_total_end" style="width:100px;text-align:right; font-weight:bold" class="box" value="" readonly="readonly">
                            </td>

                        </tr>
                        <tr>
                            <td style="text-align:right; padding: 3px 8px;"><cf_get_lang dictionary_id="57642.Net Toplam">&nbsp;</td>
                            <td style="text-align:right; padding: 3px 8px;" name="net_total_other_end">
                              <input type="text" name="net_total_other_end" id="net_total_other_end" style="width:100px;text-align:right; font-weight:bold" class="box" <cfif attributes.iskonto_izin eq 0>readonly</cfif> value="#TlFormat(0,2)#" onchange="change_total_other_end()">
                            </td>
                            <td style="text-align:right; padding: 3px 8px;" name="net_total_end">
                                <input type="text" name="net_total_end" id="net_total_end" style="width:100px;text-align:right; font-weight:bold" class="box" <cfif attributes.iskonto_izin eq 0>readonly</cfif> value="#TlFormat(0,2)#" onchange="change_total_end()">
                            </td>
                        </tr>
                        <tr id="ind_or">
                            <td style="text-align:right; padding: 3px 8px;"><cf_get_lang dictionary_id="63934.İndirim Oranı">&nbsp;</td>
                            <td style="text-align:right; padding: 3px 8px;" name="son_oran" colspan="2">
                               <input type="text" name="son_oran" id="son_oran" style="width:100%;text-align:center; font-weight:bold; background-color:green;color:white" class="box" value="#TlFormat(0,2)#" readonly="readonly">
                            </td>
                        </tr>
                        <tr id="hed_ur" style="display:none">
                            <td style="text-align:right; padding: 3px 8px;"></td>
                            <td style="text-align:center;" name="hediye_urun_td" colspan="2">
                            	<cfif attributes.campaign_type eq 2 or attributes.campaign_type eq 3 or attributes.campaign_type eq 4>
                                    <a style="cursor:pointer;" onclick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_connect_campaign_product&project_id=#attributes.project_id#&connect_id=#attributes.connect_id#&campaign_min_limit=#attributes.campaign_min_limit#&campaign_type=#attributes.campaign_type#','list');">
                                   		<input type="button" name="hediye_urun" id="hediye_urun" style="width:100%;text-align:center; font-weight:bold; background-color:orange;color:white" value="Hediye Ürün">
                                   </a>
                               </cfif>
                            </td>
                        </tr>
                        </cfoutput>
                    </table>
              	</div>                
			</div>
        </div>
  	</cf_box_elements>
</cf_box>
<cfif attributes.sales_type eq 4> <!---Kampanya Bazlı İskonto İse--->
	<cfquery name="get_barem" datasource="#dsn3#">
    	SELECT        
        	HIERARCHY, 
            PRODUCT_CAT, 
            PRODUCT_CAT_ID,
            CAT_PRICE, 
            CONNCET_PRICE,
            CAT_DISCOUNT_RATE,
            CAT_DISCOUNT_RATE_2,
            CAT_DISCOUNT_RATE_3
		FROM            
        	EZGI_CONNECT_CAT_PRICE
		WHERE        
        	EZGI_CONNECT_ID = #attributes.connect_id#
    </cfquery>
    <cf_box closable="0">
		<cf_box_elements>
			<div class="col col-12 col-sm-12">
                <cf_grid_list>
                    <thead>
                        <tr>
                            <th><cf_get_lang dictionary_id='55657.Sıra No'></th>
                            <th>Kategrori Kodu</th>
                            <th>Kategori</th>
                            <th>İskonto Baremi</th>
                            <th>İsk-1</th>
                            <th>İsk-2</th>
                            <th>İsk-3</th>
                            <th>Kategori Matrahı</th>
                            <th>Kalan</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_barem.recordcount>
                            <cfoutput query="get_barem">
                            	<input type="hidden" value="#PRODUCT_CAT_ID#" name="catid#PRODUCT_CAT_ID#" />
                            	<tr>
                                    <td style="width:25px; text-align:right">#currentrow#</td>
                                    <td>#HIERARCHY#</td>
                                    <td>#PRODUCT_CAT#</td>
                                    <input type="hidden" name="cat_price" id="cat_price#PRODUCT_CAT_ID#" value="#CAT_PRICE#">
                                    <td style="text-align:right">#TlFormat(CAT_PRICE,2)#</td>
                                    
                                    <td style="text-align:center">
                                    	<input type="text" name="cat_connect_discount_rate#PRODUCT_CAT_ID#" id="cat_connect_discount_rate#PRODUCT_CAT_ID#" style="width:40px;text-align:center" class="boxtext" readonly="readonly" value="#TlFormat(CAT_DISCOUNT_RATE,2)#" />
                                    </td>
                                    <td style="text-align:center">
                                    	<input type="text" name="cat_connect_discount_rate_2#PRODUCT_CAT_ID#" id="cat_connect_discount_rate_2#PRODUCT_CAT_ID#" style="width:40px;text-align:center" class="boxtext" readonly="readonly" value="#TlFormat(CAT_DISCOUNT_RATE_2,2)#" />
                                    </td>
                                    <td style="text-align:center">
                                    	<input type="text" name="cat_connect_discount_rate_3#PRODUCT_CAT_ID#" id="cat_connect_discount_rate_3#PRODUCT_CAT_ID#" style="width:40px;text-align:center" class="boxtext" readonly="readonly" value="#TlFormat(CAT_DISCOUNT_RATE_3,2)#" />
                                    </td>
                                    
                                    <td style="text-align:right">
                                    	<input type="text" name="cat_connect_price#PRODUCT_CAT_ID#" id="cat_connect_price#PRODUCT_CAT_ID#" style="width:60px;text-align:right" class="boxtext" readonly="readonly" value="#TlFormat(CONNCET_PRICE,2)#" />
                                    </td>
                                    <td style="text-align:right">
                                  		<input type="text" name="cat_connect_price_fark#PRODUCT_CAT_ID#" id="cat_connect_price_fark#PRODUCT_CAT_ID#" style="width:60px;text-align:right" class="boxtext" readonly="readonly" value="<cfif CAT_PRICE gte CONNCET_PRICE>#TlFormat(CAT_PRICE-CONNCET_PRICE,2)#<cfelse>#TlFormat(0,2)#</cfif>" />  
                                    </td>
                                    <td style="text-align:center">
                                    	<img src="<cfif CAT_PRICE gte CONNCET_PRICE>/images/b_ok.gif<cfelse>/images/c_ok.gif</cfif>" id="cat_confirm#PRODUCT_CAT_ID#">
                                    </td>
                                </tr>
                            </cfoutput>
                        </cfif>
                    </tbody>
                </cf_grid_list>
         	</div>
     	</cf_box_elements>
	</cf_box>
</cfif>

<script type="text/javascript">
	sub_total();
	function doviz_change(currentrow)
	{
		document.getElementById('connect_money').value = document.getElementById('money_type_'+currentrow).value;
		document.getElementById('connect_rate2').value = document.getElementById('money_'+currentrow).value;
		for (var ra=1;ra<=document.form_basket.record_num.value;ra++)
		{
			if(document.getElementById('money'+ra).value == document.getElementById('money_type_'+currentrow).value)
			{
				document.getElementById('row_rate2_'+ra).value = document.getElementById('connect_rate2').value;
			}
		 	hesapla(ra);
		}
		sub_total();
	}
	function change_total_other_end()
	{
		document.getElementById('net_total_end').value = commaSplit(parseFloat(filterNum(document.getElementById('net_total_other_end').value,2))*parseFloat(filterNum(document.getElementById('connect_rate2').value,4)),2);
		change_total_end();
	}
	function change_total_end()
	{	
		for (var rc=1;rc<=document.form_basket.record_num.value;rc++)
		{
			document.getElementById('discount_tut'+rc).value = commaSplit(0,2);
			hesapla(rc);
		}
		son_oran_hesapla();
	}
	function son_oran_hesapla()
	{
		oran = parseFloat(filterNum(document.getElementById('net_total_end').value,2))/parseFloat(filterNum(document.getElementById('sub_total_end').value,2));
		if(oran == 0)
			document.getElementById('son_oran').value=commaSplit(0,2);
		toplam_kdv_dahil_mal_bedeli = 0;
		for (var rb=1;rb<=document.form_basket.record_num.value;rb++)
		{
			satir_indirimli_fiyat = oran * parseFloat(filterNum(document.getElementById('total_brut_other'+rb).value,2));
			satir_indirimli_birimfiyat = satir_indirimli_fiyat / parseFloat(filterNum(document.getElementById('quantity'+rb).value,2));
			satir_iskonto = parseFloat(filterNum(document.getElementById('sales_price'+rb).value,2)) - satir_indirimli_birimfiyat;
			document.getElementById('discount_tut'+rb).value = commaSplit(satir_iskonto,2);
			hesapla(rb);
			toplam_kdv_dahil_mal_bedeli = toplam_kdv_dahil_mal_bedeli + (parseFloat(filterNum(document.getElementById('total_brut'+rb).value,2)) + (parseFloat(filterNum(document.getElementById('total_brut'+rb).value,2))*parseFloat(filterNum(document.getElementById('tax'+rb).value,2))/100));
		}
		document.getElementById('son_oran').value=commaSplit(((parseFloat(filterNum(document.getElementById('net_total_end').value,2))/toplam_kdv_dahil_mal_bedeli)-1)*-100,2);
		son_oran_color();
	}
	function son_oran_color()
	{
		if(document.getElementById('employee_max_disc_rate').value == 0 || parseFloat(filterNum(document.getElementById('son_oran').value,2))<=document.getElementById('employee_max_disc_rate').value)
			document.getElementById('son_oran').style.backgroundColor='green';
		else
			document.getElementById('son_oran').style.backgroundColor='red';	
		<cfoutput>
			campaign_min_limit = #attributes.campaign_min_limit#;
			campaign_type = #attributes.campaign_type#;
			is_campaign_product = #attributes.is_campaign_product#;
		</cfoutput>
		if(is_campaign_product == 0 && (campaign_type == 2 || campaign_type == 3 || campaign_type == 4) && campaign_min_limit <= parseFloat(filterNum(document.getElementById('sub_total_end').value,2)))
		{
			
			document.getElementById('hed_ur').style.display='';
			document.getElementById('ind_or').style.display='none';
		}
	}
	<cfif attributes.sales_type eq 4> <!---Satış Tipi : Kampanya Bazlı İskonto İse--->
	function hesapla_campaign_based_discount()
	{
		<cfif get_barem.recordcount>
        	<cfoutput query="get_barem"> <!---Önce Kampanya Bazlı İskonto Tablosunun Satırlarını Sıfırlıyorum--->
				cat_id = #get_barem.PRODUCT_CAT_ID#;
				document.getElementById('cat_connect_price'+cat_id).value=0;
			</cfoutput>
			for (var r=1;r<=document.form_basket.record_num.value;r++)
			{
				cat_id = document.getElementById('product_cat_id'+r).value;
				if(parseFloat(filterNum(document.getElementById('sales_price'+r).value,2)) > 0)
				{
					document.getElementById('cat_connect_price'+cat_id).value = commaSplit(parseFloat(filterNum(document.getElementById('cat_connect_price'+cat_id).value,2)) + (parseFloat(filterNum(document.getElementById('sales_price'+r).value,2))*parseFloat(filterNum(document.getElementById('quantity'+r).value,2))),2);
					if(parseFloat(filterNum(document.getElementById('cat_price'+cat_id).value,2)) >= parseFloat(filterNum(document.getElementById('cat_connect_price'+cat_id).value,2)))
					{
						document.getElementById('cat_connect_price_fark'+cat_id).value = commaSplit(parseFloat(filterNum(document.getElementById('cat_price'+cat_id).value,2)) - parseFloat(filterNum(document.getElementById('cat_connect_price'+cat_id).value,2)),2);
						document.getElementById('cat_confirm'+cat_id).src = "/images/b_ok.gif";
						
					}
					else
					{
						document.getElementById('cat_connect_price_fark'+cat_id).value = commaSplit(0,2);	
						document.getElementById('cat_confirm'+cat_id).src = "/images/c_ok.gif";
					}
				}
			}
			<cfoutput query="get_barem"> <!---Önce Kampanya Bazlı İskonto Tablosunun Satırlarını Sıfırlıyorum--->
				cat_id = #get_barem.PRODUCT_CAT_ID#;
				cat_connect_discount_rate = parseFloat(filterNum(document.getElementById('cat_connect_discount_rate'+cat_id).value,2));
				cat_connect_discount_rate_2 = parseFloat(filterNum(document.getElementById('cat_connect_discount_rate_2'+cat_id).value,2));
				cat_connect_discount_rate_3 = parseFloat(filterNum(document.getElementById('cat_connect_discount_rate_3'+cat_id).value,2));
				for (var r=1;r<=document.form_basket.record_num.value;r++)
				{
					if(document.getElementById('product_cat_id'+r).value == cat_id)
					{
						if(parseFloat(filterNum(document.getElementById('cat_connect_price_fark'+cat_id).value,2))==0)
						{
							document.getElementById('discount1_'+r).value =  commaSplit(cat_connect_discount_rate,2);
							document.getElementById('discount2_'+r).value =  commaSplit(cat_connect_discount_rate_2,2);
							document.getElementById('discount3_'+r).value =  commaSplit(cat_connect_discount_rate_3,2);
							satir_hesapla(r);
						}
						else
						{
							document.getElementById('discount1_'+r).value =  commaSplit(0,2);
							document.getElementById('discount2_'+r).value =  commaSplit(0,2);
							document.getElementById('discount3_'+r).value =  commaSplit(0,2);
							satir_hesapla(r);
						}
					}
				}
			</cfoutput>
		</cfif>
	}
	</cfif>
</script>