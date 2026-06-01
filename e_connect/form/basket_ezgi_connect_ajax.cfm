<cfinclude template="basket_ezgi_connect_queries.cfm">
<cfset get_property_group_list = ValueList(get_property_group.PROPERTY_ID)>

<cfset url_str = "">
<cfif ListLen(get_property_group_list)>
	<cfset url_str = "#url_str#&property_group_list=#get_property_group_list#">
</cfif>
<cfset checked_id_list =''>
<cfloop list="#get_property_group_list#" index="ii">
	<cfif isdefined('attributes.categori_id_list_#ii#') and len(Evaluate('attributes.categori_id_list_#ii#'))>
		<cfset url_str = "#url_str#&categori_id_list_#ii#=#Evaluate('attributes.categori_id_list_#ii#')#">
        <cfset checked_id_list ="#checked_id_list##Evaluate('attributes.categori_id_list_#ii#')#,">
    </cfif>
</cfloop>
<cf_grid_list sort="1">
    <thead>
        <tr>
            <cfoutput>
            <th>
                <input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
            </th>
            <th><cf_get_lang dictionary_id='55657.Sıra No'></th>
            <th><cf_get_lang dictionary_id='58964.Fiyat Listesi'></th>
            <th><cf_get_lang dictionary_id='57564.Ürünler'></th>
            <th><cf_get_lang dictionary_id='57635.Miktar'></th>
            <th><cf_get_lang dictionary_id='57636.Birim'></th>
            <th><cf_get_lang dictionary_id='57638.Birim Fiyat'></th>
            <th><cf_get_lang dictionary_id='57677.Döviz'></th>
            <th><cf_get_lang dictionary_id="57641.İskonto"></th>
            <th style=" text-align:center">
                <input type="text" name="disc_1" id="disc_1" value="#TlFormat(0,2)#" class="boxtext" style="width:30px; text-align:center" onChange="top_disc(1)" <cfif attributes.iskonto_izin eq 0>readonly</cfif>>
            </th>
            <th style=" text-align:center">
                <input type="text" name="disc_2" id="disc_2" value="#TlFormat(0,2)#" class="boxtext" style="width:30px; text-align:center" onChange="top_disc(2)" <cfif attributes.iskonto_izin eq 0>readonly</cfif>>
            </th>
            <th style=" text-align:center">
                <input type="text" name="disc_3" id="disc_3" value="#TlFormat(0,2)#" class="boxtext" style="width:30px; text-align:center" onChange="top_disc(3)" <cfif attributes.iskonto_izin eq 0>readonly</cfif>>
            </th>
            <th nowrap>
                <cf_get_lang dictionary_id="57639.KDV">
                <input type="text" name="kdv_top" id="kdv_top" value="" class="boxtext" style="width:15px; text-align:center" maxlength="2" onChange="top_kdv(this.value)">
            </th>
            <th><cf_get_lang dictionary_id="57629.Açıklama"></th>
            <th><cf_get_lang dictionary_id="57397.Net Fiyat"></th>
            <th><cf_get_lang dictionary_id="57642.Net Toplam"></th>
            <th><cf_get_lang dictionary_id="64382.KDV Dahil Fiyat"></th>
            <th><cf_get_lang dictionary_id="29534.Toplam Tutar"></th>
            <th>(#session.ep.money#) <cf_get_lang dictionary_id="57673.Tutar"></th>
            <cfif attributes.x_ssh eq 1> <!---SSH Sepeti İse--->
            	<th></th>
            </cfif>
            </cfoutput> 
        </tr>
    </thead>
    <tbody name="new_row" id="new_row">
        <input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_connect_row.recordcount#</cfoutput>">
        <cfif get_connect_row.recordcount>
            <cfoutput query="get_connect_row">
            	<input type="hidden" name="product_cat_id#currentrow#" id="product_cat_id#currentrow#" value="#PRODUCT_CATID#">
                <input type="hidden" name="special_code#currentrow#" id="special_code#currentrow#" value="#PRODUCT_CODE_2#">
                <input type="hidden" name="is_campaign_product#currentrow#" id="is_campaign_product#currentrow#" value="#IS_CAMPAIGN_PRODUCT_#">
                <input type="hidden" name="is_campaign_product_#CONNECT_ROW_ID#" id="is_campaign_product_#CONNECT_ROW_ID#" value="#IS_CAMPAIGN_PRODUCT_#">
                <input type="hidden" value="1" name="row_kontrol#currentrow#">
                <input type="hidden" value="#ezgi_id#" name="ezgi_id#currentrow#">
                <input type="hidden" value="#wrk_row_relation_id#" name="WRK_ROW_RELATION_ID_#currentrow#">
                <tr id="frm_row#currentrow#" title="#PRODUCT_NAME#" style="height: auto; min-height: 30px;">
                    <td style="text-align:center; width:20px; vertical-align:middle;">
                     	<input type="checkbox" name="select_connect_row" value="#CONNECT_ROW_ID#" style="margin: 0 auto; display: block;">
                    </td>
                    <td style="text-align:right; width:30px">#currentrow#&nbsp;</td>
                    <td nowrap style="text-align:left; width:100px">
                        <select name="row_price_cat_id#currentrow#" id="row_price_cat_id#currentrow#" style="width:100px;" onchange="price_change(#currentrow#);">
                            <option value="-2"<cfif get_connect_row.row_price_cat_id eq -2> selected</cfif>><cf_get_lang dictionary_id='58721.Standart Satış'></option>
                            <cfloop query="get_price_cat">
                                <option value="#get_price_cat.price_catid#"<cfif get_connect_row.row_price_cat_id eq get_price_cat.price_catid> selected</cfif>>#get_price_cat.price_cat#</option>
                            </cfloop>
                        </select>
                    </td>
                    <td nowrap style="text-align:left; width:220px">
                        <input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#stock_id#">
                        <input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#product_id#">
                        <input type="text" name="product_name#currentrow#" id="product_name#currentrow#" style=" width:220px" class="boxtext" readonly="readonly" value="#product_name#">
                    </td>
                    <td nowrap style="text-align:right; width:40px">
                        <input type="text" name="quantity#currentrow#" id="quantity#currentrow#" value="#TlFormat(QUANTITY,2)#" style="width:40px; text-align:right;" onchange="hesapla(#currentrow#);">
                    </td>
                    <td nowrap style="text-align:left; width:40px">
                        <input type="text" name="main_unit#currentrow#" id="main_unit#currentrow#" style="width:40px;" class="boxtext" value="#unit#">
                    </td>
                    <td nowrap style="text-align:right; width:60px">
                        <input type="text" name="sales_price#currentrow#" id="sales_price#currentrow#" style="width:60px;text-align:right" class="boxtext" value="#TlFormat(sales_price,2)#" onchange="hesapla(#currentrow#);"  readonly="readonly">
                    </td>
                    <td nowrap style="text-align:left; width:60px">
                        <select name="money#currentrow#" id="money#currentrow#" style="width:60px;" onchange="satir_doviz_hesapla(#currentrow#);">
                            <cfloop query="get_money"><option value="#money#" <cfif get_connect_row.money eq get_money.money>selected</cfif>>#money#</option></cfloop>
                        </select>
                        <input type="hidden" value="#TlFormat(Evaluate('RATE2_#get_connect_row.money#'),4)#" id="row_rate2_#currentrow#" name="row_rate2_#currentrow#">
                        <input type="hidden" value="#get_connect_row.money#" name="old_money_#currentrow#" id="old_money_#currentrow#">
                        <input type="hidden" value="#TlFormat(Evaluate('RATE2_#get_connect_row.money#'),4)#" id="old_row_rate2_#currentrow#" name="old_row_rate2_#currentrow#">
                    </td>
                    <td nowrap style="text-align:right; width:60px">
                        <input type="text" name="discount_tut#currentrow#" id="discount_tut#currentrow#" style="width:60px; text-align:right" class="boxtext" <cfif attributes.iskonto_izin eq 0>readonly</cfif> value="#TlFormat(discount_tut,2)#" onchange="hesapla(#currentrow#);">
                    </td>
                    <td nowrap style="text-align:right; width:30px">
                        <input type="text" name="discount1_#currentrow#" id="discount1_#currentrow#" style="width:30px; text-align:center" class="boxtext" <cfif attributes.iskonto_izin eq 0>readonly</cfif> value="#TlFormat(discount1,2)#" onchange="hesapla(#currentrow#);">
                    </td>
                    <td nowrap style="text-align:right; width:30px">
                        <input type="text" name="discount2_#currentrow#" id="discount2_#currentrow#" style="width:30px; text-align:center" class="boxtext" <cfif attributes.iskonto_izin eq 0>readonly</cfif> value="#TlFormat(discount2,2)#" onchange="hesapla(#currentrow#);">
                    </td>
                    <td nowrap style="text-align:right; width:30px">
                        <input type="text" name="discount3_#currentrow#" id="discount3_#currentrow#" style="width:30px; text-align:center" class="boxtext" <cfif attributes.iskonto_izin eq 0>readonly</cfif> value="#TlFormat(discount3,2)#" onchange="hesapla(#currentrow#);">
                    </td>
                    <td nowrap style="text-align:center; width:40px">
                        <input type="text" name="tax#currentrow#" id="tax#currentrow#" style="width:40px; text-align:center" class="boxtext" value="#TlFormat(tax,0)#" onchange="hesapla(#currentrow#);">
                    </td>
                    <td nowrap style="text-align:left;">
                        <input type="text" name="detail#currentrow#" value="#PRODUCT_NAME2#">
                    </td>
                    <cfset row_net_other_ = sales_price-discount_tut>
                    <cfset row_net_other_ = row_net_other_-(row_net_other_*discount1/100)>
                    <cfset row_net_other_ = row_net_other_-(row_net_other_*discount2/100)>
                    <cfset row_net_other_ = row_net_other_-(row_net_other_*discount3/100)>
                    <td nowrap style="text-align:right; width:60px">
                        <input type="text" name="row_net_other#currentrow#" id="row_net_other#currentrow#" style="width:60px;text-align:right" class="boxtext" value="#TlFormat(row_net_other_,2)#" readonly>
                    </td>
                    <cfset total_brut_other_ = sales_price*quantity>
                    <cfset total_net_other_ = total_brut_other_-(discount_tut*quantity)>
                    <cfset total_net_other_ = total_net_other_-(total_net_other_*discount1/100)>
                    <cfset total_net_other_ = total_net_other_-(total_net_other_*discount2/100)>
                    <cfset total_net_other_ = total_net_other_-(total_net_other_*discount3/100)>
                    <cfset total_tax_other_ = total_net_other_*tax/100>
                    <cfset total_kdvli_net_other_ = total_net_other_+total_tax_other_>
                    <td nowrap style="text-align:right; width:60px">
                        <input type="text" name="total_net_other#currentrow#" id="total_net_other#currentrow#" style="width:60px;text-align:right" class="boxtext" value="#TlFormat(total_net_other_,2)#" readonly>
                    </td>
                    <td nowrap style="text-align:right; width:60px">
                        <input type="text" name="total_net_kdvli_other#currentrow#" id="total_net_kdvli_other#currentrow#" style="width:60px;text-align:right" class="boxtext" value="#TlFormat(total_kdvli_net_other_,2)#" readonly>
                    </td>
                    <td nowrap style="text-align:right; width:60x">
                        <input type="text" name="total_brut_other#currentrow#" id="total_brut_other#currentrow#" style="width:60px;text-align:right" class="boxtext" value="#TlFormat(total_brut_other_,2)#" readonly>
                    </td>
                    <input type="hidden" name="total_tax_other#currentrow#" id="total_tax_other#currentrow#" value="#TlFormat(total_tax_other_,2)#">
                    <cfif len(MONEY)>
                        <cfset total_brut_ = Evaluate('RATE2_#MONEY#')*total_brut_other_>
                        <cfset total_net_ = Evaluate('RATE2_#MONEY#')*total_net_other_>
                        <cfset total_tax_ = Evaluate('RATE2_#MONEY#')*total_tax_other_ >
                    </cfif>
                    <td nowrap style="text-align:right; width:60px">
                        <input type="text" name="total_brut#currentrow#" id="total_brut#currentrow#" style="width:60px;text-align:right" class="boxtext" value="#TlFormat(total_brut_,2)#" readonly>
                    </td>
                    <cfif attributes.x_ssh eq 1> <!---SSH Sepeti İse--->
                    	<cfquery name="get_connet_ssh_image" datasource="#dsn3#">
                        	SELECT CONNECT_ROW_IMAGE_ID FROM EZGI_CONNECT_ROW_IMAGES WHERE CONNECT_ROW_ID = #CONNECT_ROW_ID#
                        </cfquery>
                        <cfif get_connet_ssh_image.recordcount>
                        	<cfset ssh_upd = 1>
                        <cfelse>
                        	<cfset ssh_upd = 0>
                        </cfif>
                        <td style="width:25px; text-align:center">
                        	<span class="fa fa-camera" style="cursor:pointer" onclick="add_main_images(#ssh_upd#,#CONNECT_ROW_ID#,'#product_name#');" title="<cf_get_lang dictionary_id='57514.Resim Ekle'>"></span>
                        </td>
                    </cfif>
                    <input type="hidden" name="total_tax#currentrow#" id="total_tax#currentrow#" value="#TlFormat(total_tax_,2)#">

                    <input type="hidden" name="total_net#currentrow#" id="total_net#currentrow#" value="#TlFormat(total_net_,2)#">
                </tr>
            </cfoutput>
        </cfif>
    </tbody>
</cf_grid_list>
<script type="text/javascript">
	var row_count = document.form_basket.record_num.value;
	function hesapla(row)
	{
		<cfif attributes.sales_type eq 4> <!---Satış Tipi : Kampanya Bazlı İskonto İse--->
			hesapla_campaign_based_discount();
		</cfif>
		satir_hesapla(row);
	}
	function satir_hesapla(row)
	{
		document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('sales_price'+row).value,2)) - parseFloat(filterNum(document.getElementById('discount_tut'+row).value,2)),2);
		document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,2)) - (parseFloat(filterNum(document.getElementById('row_net_other'+row).value,2))*parseFloat(filterNum(document.getElementById('discount1_'+row).value,2))/100),2);
		document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,2)) - (parseFloat(filterNum(document.getElementById('row_net_other'+row).value,2))*parseFloat(filterNum(document.getElementById('discount2_'+row).value,2))/100),2);
		document.getElementById('row_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,2)) - (parseFloat(filterNum(document.getElementById('row_net_other'+row).value,2))*parseFloat(filterNum(document.getElementById('discount3_'+row).value,2))/100),2);
		document.getElementById('total_net_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('row_net_other'+row).value,2)) * parseFloat(filterNum(document.getElementById('quantity'+row).value,2)),2);
		document.getElementById('total_tax_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net_other'+row).value,2)*document.getElementById('tax'+row).value/100),2);
		document.getElementById('total_net_kdvli_other'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net_other'+row).value,2)) + parseFloat(filterNum(document.getElementById('total_tax_other'+row).value,2)),2);
		
		document.getElementById('total_net'+row).value = commaSplit((parseFloat(filterNum(document.getElementById('sales_price'+row).value,2))) * parseFloat(filterNum(document.getElementById('quantity'+row).value,2)) * parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4)),2);
		document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,2)) - (parseFloat(filterNum(document.getElementById('discount_tut'+row).value,2)) * parseFloat(filterNum(document.getElementById('quantity'+row).value,2)) * parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4))),2);
		document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,2)) - (parseFloat(filterNum(document.getElementById('total_net'+row).value,2))*parseFloat(filterNum(document.getElementById('discount1_'+row).value,2))/100),2);
		document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,2)) - (parseFloat(filterNum(document.getElementById('total_net'+row).value,2))*parseFloat(filterNum(document.getElementById('discount2_'+row).value,2))/100),2);
		document.getElementById('total_net'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,2)) - (parseFloat(filterNum(document.getElementById('total_net'+row).value,2))*parseFloat(filterNum(document.getElementById('discount3_'+row).value,2))/100),2);
		document.getElementById('total_tax'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('total_net'+row).value,2)*document.getElementById('tax'+row).value/100),2);
		document.getElementById('total_brut'+row).value = commaSplit((parseFloat(filterNum(document.getElementById('sales_price'+row).value,2)))*parseFloat(filterNum(document.getElementById('quantity'+row).value,2))*parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4)),2);
		document.getElementById('total_brut_other'+row).value = commaSplit((parseFloat(filterNum(document.getElementById('sales_price'+row).value,2)))*parseFloat(filterNum(document.getElementById('quantity'+row).value,2)),2);
		sub_total();
	}
	function sub_total()
	{
		document.getElementById('sub_total_brut').value = 0;
		document.getElementById('sub_total_net').value = 0;
		document.getElementById('sub_total_tax').value = 0;
		document.getElementById('sub_total_brut_other').value = 0;
		document.getElementById('sub_total_net_other').value = 0;
		document.getElementById('sub_total_tax_other').value = 0;
		for (var r=1;r<=document.form_basket.record_num.value;r++)
		{
			document.getElementById('sub_total_brut').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_brut').value,2))+parseFloat(filterNum(document.getElementById('total_brut'+r).value,2)),2);
			document.getElementById('sub_total_net').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_net').value,2))+parseFloat(filterNum(document.getElementById('total_net'+r).value,2)),2);
			document.getElementById('sub_total_discount').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_brut').value,2))-parseFloat(filterNum(document.getElementById('sub_total_net').value,2)),2);
			document.getElementById('sub_total_tax').value =  commaSplit(parseFloat(filterNum(document.getElementById('sub_total_tax').value,2))+parseFloat(filterNum(document.getElementById('total_tax'+r).value,2)),2);
			document.getElementById('sub_total_end').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_net').value,2))+parseFloat(filterNum(document.getElementById('sub_total_tax').value,2)),2);
			
			document.getElementById('sub_total_brut_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_brut').value,2))/parseFloat(filterNum(document.getElementById('connect_rate2').value,4)),2);
			document.getElementById('sub_total_net_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_net').value,2))/parseFloat(filterNum(document.getElementById('connect_rate2').value,4)),2);
			document.getElementById('sub_total_discount_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_discount').value,2))/parseFloat(filterNum(document.getElementById('connect_rate2').value,4)),2);
			document.getElementById('sub_total_tax_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_tax').value,2))/parseFloat(filterNum(document.getElementById('connect_rate2').value,4)),2);
			document.getElementById('sub_total_end_other').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_end').value,2))/parseFloat(filterNum(document.getElementById('connect_rate2').value,4)),2);
		}
		if(parseFloat(filterNum(document.getElementById('sub_total_discount').value,2)) >0 && parseFloat(filterNum(document.getElementById('sub_total_brut').value,2))>0)
			document.getElementById('son_oran').value = commaSplit(parseFloat(filterNum(document.getElementById('sub_total_discount').value,2))/parseFloat(filterNum(document.getElementById('sub_total_brut').value,2))*100,2);
			
		son_oran_color();
	}
	function satir_doviz_hesapla(currentrow)
	{
		row_money = document.getElementById('money'+currentrow).value;
		<cfif isdefined('attributes.connect_id')>
			<cfoutput query="get_connect_money">
				money_type = '#get_connect_money.money_type#';
				money_currentrow = #get_connect_money.currentrow#
				money_rate2 = #get_connect_money.rate2#
				if(row_money==money_type)
				{
					document.getElementById('sales_price'+currentrow).value=commaSplit(parseFloat(filterNum(document.getElementById('sales_price'+currentrow).value,4))/money_rate2*parseFloat(filterNum(document.getElementById('row_rate2_'+currentrow).value,4)),2);
					document.getElementById('old_row_rate2_'+currentrow).value=document.getElementById('row_rate2_'+currentrow).value;
					document.getElementById('old_money_'+currentrow).value=document.getElementById('money'+currentrow).value;
					document.getElementById('row_rate2_'+currentrow).value=document.getElementById('money_'+money_currentrow).value;
				}
			</cfoutput>
		<cfelse>
			<cfoutput query="get_money">
				money_type = '#get_money.money#';
				money_currentrow = #get_money.currentrow#
				if(row_money==money_type)
				{
					document.getElementById('row_rate2_'+currentrow).value=document.getElementById('money_'+money_currentrow).value;
				}
			</cfoutput>
		</cfif>
		hesapla(currentrow);
	}
	function top_disc(iskonto)
	{
		iskonto_oran = document.getElementById('disc_'+iskonto).value;
		for (var r=1;r<=document.form_basket.record_num.value;r++)
		{
			document.getElementById('discount'+iskonto+'_'+r).value = iskonto_oran;	
			hesapla(r);
		}
	}
	function top_kdv(kdv_top)
	{
		if(kdv_top.length >0 && kdv_top >=0 && kdv_top<=99)
		{
			for (var r=1;r<=document.form_basket.record_num.value;r++)
			{
				document.getElementById('tax'+r).value = kdv_top;	
				hesapla(r);
			}
		}
		else
		{
			alert("KDV Oranı Nümerik Değer Olmalıdır.!");
			return false;
		}
	}
	function price_change(row)
	{
		if(row ==0)
		{
			price_catid = document.getElementById('price_catid').value;
			for (var r=1;r<=document.form_basket.record_num.value;r++)
			{
				document.getElementById('row_price_cat_id'+r).value = price_catid;
				product_id=document.getElementById('product_id'+r).value;
				/*var new_sql = "SELECT TOP (1) PRICE, MONEY FROM PRICE WHERE PRICE_CATID = "+price_catid+" AND PRODUCT_ID = "+product_id+" AND FINISHDATE IS NULL ORDER BY STARTDATE DESC";*/
				/*var get_price = wrk_query(new_sql,'dsn3');*/
				
				var listParam = price_catid + "*" + product_id;
				var get_price = wrk_safe_query('get_price_price_catid_product_id_ezgi','dsn3',0,listParam);
				
				if(get_price.recordcount != 0)
				{
					document.getElementById('sales_price'+r).style.color = "black";
					document.getElementById('sales_price'+r).value = commaSplit(parseFloat(get_price.PRICE),2);
					document.getElementById('money'+r).value = get_price.MONEY;
					row_money = get_price.MONEY;
					<cfif isdefined('attributes.connect_id')>
						<cfoutput query="get_connect_money">
							money_type = '#get_connect_money.money_type#';
							money_currentrow = #get_connect_money.currentrow#
							money_rate2 = #get_connect_money.rate2#
							if(row_money==money_type)
							{
								document.getElementById('old_row_rate2_'+r).value=document.getElementById('row_rate2_'+r).value;
								document.getElementById('old_money_'+r).value=document.getElementById('money'+r).value;
								document.getElementById('row_rate2_'+r).value=document.getElementById('money_'+money_currentrow).value;
							}
						</cfoutput>
					<cfelse>
						<cfoutput query="get_money">
							money_type = '#get_money.money#';
							money_currentrow = #get_money.currentrow#
							if(row_money==money_type)
							{
								document.getElementById('row_rate2_'+r).value=document.getElementById('money_'+money_currentrow).value;
							}
						</cfoutput>
					</cfif>
					hesapla(r);
				}
				else
				{
					document.getElementById('sales_price'+r).style.color = "red";	
				}
			}
		}
		else
		{
			r = row;
			price_catid = document.getElementById('row_price_cat_id'+r).value;
			product_id=document.getElementById('product_id'+r).value;
			/*var new_sql = "SELECT TOP (1) PRICE, MONEY FROM PRICE WHERE PRICE_CATID = "+price_catid+" AND PRODUCT_ID = "+product_id+" AND FINISHDATE IS NULL ORDER BY STARTDATE DESC";*/
			/*var get_price = wrk_query(new_sql,'dsn3');*/
				
			var listParam = price_catid + "*" + product_id;
			var get_price = wrk_safe_query('get_price_price_catid_product_id_ezgi','dsn3',0,listParam);
			
			if(get_price.recordcount != 0)
			{
				document.getElementById('sales_price'+r).style.color = "black";
				document.getElementById('sales_price'+r).value = commaSplit(parseFloat(get_price.PRICE),2);
				document.getElementById('money'+r).value = get_price.MONEY;
				row_money = get_price.MONEY;
				<cfif isdefined('attributes.connect_id')>
					<cfoutput query="get_connect_money">
						money_type = '#get_connect_money.money_type#';
						money_currentrow = #get_connect_money.currentrow#
						money_rate2 = #get_connect_money.rate2#
						if(row_money==money_type)
						{
							document.getElementById('old_row_rate2_'+r).value=document.getElementById('row_rate2_'+r).value;
							document.getElementById('old_money_'+r).value=document.getElementById('money'+r).value;
							document.getElementById('row_rate2_'+r).value=document.getElementById('money_'+money_currentrow).value;
						}
					</cfoutput>
				<cfelse>
					<cfoutput query="get_money">
						money_type = '#get_money.money#';
						money_currentrow = #get_money.currentrow#
						if(row_money==money_type)
						{
							document.getElementById('row_rate2_'+r).value=document.getElementById('money_'+money_currentrow).value;
						}
					</cfoutput>
				</cfif>
				hesapla(r);
			}
			else
			{
				document.getElementById('sales_price'+r).style.color = "red";	
			}
		}
	}
	function grupla(type)
	{
		<cfoutput>
			is_campaign_product = #attributes.is_campaign_product#;
		</cfoutput>
		
			connect_row_id_list = '';
			chck_leng = document.getElementsByName('select_connect_row').length;
			for(ci=0;ci<chck_leng;ci++)
			{
				var my_objets = document.all.select_connect_row[ci];
				if(chck_leng == 1)
					var my_objets =document.all.select_connect_row;
				if(type == -1)
				{//hepsini seç denilmişse	
					if(my_objets.checked == true)
						my_objets.checked = false;
					else
						my_objets.checked = true;
				}
				else
				{
					if(my_objets.checked == true)
					{
						if(is_campaign_product == 1 && document.getElementById('is_campaign_product_'+my_objets.value).value==0) //Eğer Sepet İçinde Hediye Ürün eklenmişse ve Bu satır Hediye Ürün Değilse
						{
							alert('Sepet İçinde Kampanya Hediye Ürünü Hariç, Silme İşlemi Yapılamaz');
							return false;
						}
						connect_row_id_list +=my_objets.value+',';
					}
				}
			}
			connect_row_id_list = connect_row_id_list.substr(0,connect_row_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(connect_row_id_list!='')
			{
				if(confirm('Seçilen Satırları Silmek İstediğinizden Emin misiniz?'))
					window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_del_ezgi_connect_row&#url_str#&connect_id=#attributes.connect_id#&price_cat_id=#get_connect.PRICE_CAT_ID#&id_list=#attributes.id_list#</cfoutput>&keyword="+document.getElementById('keyword').value+'&connect_row_id_list='+connect_row_id_list;		
				else
					return false;
			}
	}
	function add_main_images(ssh_upd,connect_row_id,product_name)
	{
		if(ssh_upd==1)
			windowopen('<cfoutput>#request.self#?fuseaction=sales.form_upd_ezgi_popup_image&id='+connect_row_id+'&type=connect_row&detail='+product_name+'&table=EZGI_CONNECT_ROW_IMAGES</cfoutput>','small');
		else	
			windowopen('<cfoutput>#request.self#?fuseaction=sales.form_add_ezgi_popup_image&id='+connect_row_id+'&type=connect_row&detail='+product_name+'&table=EZGI_CONNECT_ROW_IMAGES</cfoutput>','small');
	}
</script>
<cfinclude template="footer_ezgi_connect.cfm">