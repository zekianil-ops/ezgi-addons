<cfquery name="get_partner" datasource="#dsn3#">
	SELECT        
    	SALES_COMPANY_ID
	FROM            
    	EZGI_VIRTUAL_OFFER
	WHERE        
    	VIRTUAL_OFFER_ID =
                    		(
                            	SELECT        
                                	VIRTUAL_OFFER_ID
                               	FROM            
                                	EZGI_VIRTUAL_OFFER_ROW
                               	WHERE        
                                	EZGI_ID = #attributes.ezgi_id#
                         	)
</cfquery>
<cfquery name="get_money" datasource="#dsn#">
	SELECT * FROM SETUP_MONEY WHERE PERIOD_ID = #session.ep.period_id# ORDER BY MONEY_SYMBOL
</cfquery>
<cfoutput query="get_money">
	<cfset 'RATE2_#MONEY#' = RATE2>
</cfoutput>
<cfquery name="get_cost_defaults" datasource="#dsn3#">
	SELECT STOCK_ID, IS_MONTAGE FROM EZGI_VIRTUAL_OFFER_COST_DEFAULT WHERE IS_ACTIVE = 1 ORDER BY SORT_NO
</cfquery>
<cfquery name="get_montage_row" datasource="#dsn3#">
	SELECT PRODUCT_NAME, MAIN_UNIT, STOCK_ID, AMOUNT, PRODUCT_UNIT_ID, PRICE, OTHER_MONEY,IS_HZM,ROW_TOTAL FROM EZGI_MONTAGE_ROW WHERE EZGI_ID = #attributes.ezgi_id#
</cfquery>
<cfquery name="get_virtual_offer_money" datasource="#dsn3#">
	SELECT      
    	MONEY_TYPE, 
        ACTION_ID, 
        RATE2, 
        RATE1, 
        IS_SELECTED
	FROM            
    	EZGI_VIRTUAL_OFFER_MONEY
	WHERE        
    	ACTION_ID =
                	(
                    	SELECT        
                        	VIRTUAL_OFFER_ID
                    	FROM            
                       		EZGI_VIRTUAL_OFFER_ROW
                   		WHERE        
                        	EZGI_ID = #attributes.ezgi_id#
                  	)
</cfquery>
<cfif get_virtual_offer_money.recordcount>
	<cfquery name="get_row_money" dbtype="query">
    	SELECT RATE2 FROM get_virtual_offer_money WHERE MONEY_TYPE = '#attributes.row_money#'
    </cfquery>
    <cfset row_money_rate2 = get_row_money.rate2>
<cfelse>
	<cfquery name="get_row_money" dbtype="query">
    	SELECT RATE2 FROM get_money WHERE MONEY = '#attributes.row_money#'
    </cfquery>
    <cfset row_money_rate2 = get_row_money.rate2>
</cfif>
<cfset gtotal=0>
<cfset mtotal=0>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
    	<cfform name="upd_virtual_cost" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_virtual_cost" enctype="multipart/form-data">
			<cfif len(get_partner.SALES_COMPANY_ID)>
                <cfinput type="hidden" name="is_mrk" value="1">
            </cfif>
            <cfinput type="hidden" name="ezgi_id" value="#attributes.ezgi_id#">
            <cfinput type="hidden" name="record_num" value="#get_cost_defaults.recordcount#">
            <cf_basket id="upd_default_color_bask">
            	<cf_grid_list sort="0">
                	<thead>
                        <tr>
                            <th style="width:25px; height:20px; text-align:center">E/H</th>
                            <th>Hizmet Adı</th>
                            <th style="width:70px">Miktar</th>
                            <th style="width:50px">Birim</th>
                            <th style="width:70px">Birim Fiyat</th>
                            <th style="width:40px">Döviz</th>
                            <th style="width:65px">Tutar</th>
                            <th style="width:70px">Tutar (<cfoutput>#session.ep.money#</cfoutput>)</th>
                            <cfif len(get_partner.SALES_COMPANY_ID)>
                                <th style="width:25px; text-align:center">MRK</th>
                            </cfif>
                        </tr>
                    </thead>
                    <tbody>
                        <cfloop query="get_cost_defaults">
                            <cfquery name="get_montage_stock_id" dbtype="query">
                                SELECT * FROM get_montage_row WHERE STOCK_ID = #STOCK_ID#
                            </cfquery>
                            <cfif get_montage_stock_id.recordcount>
                                <cfset 'select_#get_cost_defaults.STOCK_ID#' = 1>
                                <cfif get_montage_stock_id.IS_HZM eq 1>
                                    <cfset 'select_hzm#get_cost_defaults.STOCK_ID#' = 1>
                                </cfif>
                                <cfset stock_id_ = get_montage_stock_id.STOCK_ID>
                                <cfset product_name_ = get_montage_stock_id.PRODUCT_NAME>
                                <cfset main_unit_ = get_montage_stock_id.MAIN_UNIT>
                                <cfset product_unit_id_ = get_montage_stock_id.PRODUCT_UNIT_ID>
                                <cfset price_ = get_montage_stock_id.PRICE>
                                <cfset money_ = get_montage_stock_id.OTHER_MONEY>
                                <cfset miktar = get_montage_stock_id.amount>
                                <cfset row_total = get_montage_stock_id.row_total>
                            <cfelse>
                                <cfquery name="get_stock_info" datasource="#dsn3#">
                                    SELECT 
                                        PRODUCT_NAME, 
                                        STOCK_ID,
                                        (SELECT MAIN_UNIT FROM #dsn1_alias#.PRODUCT_UNIT WHERE PRODUCT_ID = STOCKS.PRODUCT_ID AND PRODUCT_UNIT_STATUS = 1 AND IS_MAIN = 1) AS MAIN_UNIT,
                                        (SELECT PRODUCT_UNIT_ID FROM #dsn1_alias#.PRODUCT_UNIT WHERE PRODUCT_ID = STOCKS.PRODUCT_ID AND PRODUCT_UNIT_STATUS = 1 AND IS_MAIN = 1) AS PRODUCT_UNIT_ID,
                                        ISNULL((SELECT PRICE FROM #dsn1_alias#.PRICE_STANDART WHERE PRODUCT_ID = STOCKS.PRODUCT_ID AND PURCHASESALES = 1 AND PRICESTANDART_STATUS = 1),0) AS PRICE,
                                        (SELECT MONEY FROM #dsn1_alias#.PRICE_STANDART WHERE PRODUCT_ID = STOCKS.PRODUCT_ID AND PURCHASESALES = 0 AND PRICESTANDART_STATUS = 1) AS MONEY
                                    FROM
                                        STOCKS
                                    WHERE
                                        STOCK_ID = #stock_id#
                                </cfquery>
                                <cfset stock_id_ = get_stock_info.STOCK_ID>
                                <cfset product_name_ = get_stock_info.product_name>
                                <cfset main_unit_ = get_stock_info.MAIN_UNIT>
                                <cfset product_unit_id_ = get_stock_info.PRODUCT_UNIT_ID>
                                <cfset price_ = get_stock_info.PRICE>
                                <cfset money_ = get_stock_info.MONEY>
                                <cfset miktar = 0>
                                <cfset row_total = 0>
                                <cfif get_cost_defaults.IS_MONTAGE eq 1>
                                    <cfquery name="get_montage" datasource="#dsn3#">
                                        SELECT ISNULL(AMOUNT,0) AMOUNT FROM EZGI_VIRTUAL_OFFER_ROW_MONTAGE WHERE EZGI_ID = #attributes.ezgi_id# AND STOCK_ID=#get_stock_info.STOCK_ID#
                                    </cfquery>
                                    <cfif get_montage.recordcount>
                                        <cfset miktar = get_montage.amount>
                                    </cfif>
                                </cfif>
                            </cfif>
                            <cfoutput>
                                <tr>
                                    <td style="height:20px; text-align:center">
                                        <input type="checkbox" name="select_product#currentrow#" id="select_product#currentrow#" value="1" onChange="check_control(#currentrow#)" <cfif isdefined('select_#get_cost_defaults.STOCK_ID#')>checked</cfif>>
                                    </td>
                                    <td><cfinput type="text" name="product_name#currentrow#" id="product_name#currentrow#" value="#product_name_#"  readonly="yes" style="width:100%"></td>
                                    <td><cfinput type="text" name="amount#currentrow#" id="amount#currentrow#" value="#TlFormat(miktar,2)#" style="width:50px; text-align:right" onChange="hesapla(#currentrow#);" ></td>
                                    <td><cfinput type="text" name="main_unit#currentrow#" id="main_unit#currentrow#" value="#main_unit_#" style="width:40px;" readonly="yes"></td>
                                    <cfinput type="hidden" name="product_unit_id#currentrow#" value="#product_unit_id_#">
                                    <cfinput type="hidden" name="stock_id#currentrow#" value="#stock_id_#">
                                    <td><cfinput type="text" name="price#currentrow#" id="price#currentrow#" value="#TlFormat(price_,2)#" style="width:55px; text-align:right" onChange="hesapla(#currentrow#);" ></td>
                                    <td>
                                        <select name="money#currentrow#" id="money#currentrow#" style="width:50px; height:20px" onchange="satir_doviz_hesapla(#currentrow#);">
                                            <cfloop query="get_money">
                                                <option value="#money#" <cfif money_ eq get_money.money>selected</cfif>>#money#</option>
                                            </cfloop>
                                        </select>
                                        <input type="hidden" value="#TlFormat(Evaluate('RATE2_#money_#'),4)#" id="row_rate2_#currentrow#" name="row_rate2_#currentrow#">
                                    </td>
                                    <cfset total=miktar*price_>
                                    <cfif isdefined('select_#get_cost_defaults.STOCK_ID#')>
                                        <cfset gtotal = gtotal + total>
                                        <cfset mtotal = mtotal + (total*Evaluate('RATE2_#money_#'))>
                                    </cfif>
                                    <td><cfinput type="text" name="total#currentrow#" id="total#currentrow#" value="#TlFormat(total,2)#" style="width:70px; text-align:right" ></td>
                                    <td><cfinput type="text" name="totalm#currentrow#" id="totalm#currentrow#" value="#TlFormat(row_total,2)#" style="width:70px; text-align:right" ></td>
                                    <cfif len(get_partner.SALES_COMPANY_ID)>
                                        <td style="height:20px; text-align:center">
                                            <input type="checkbox" name="select_hzm#currentrow#" id="select_hzm#currentrow#" value="1" <cfif isdefined('select_hzm#get_cost_defaults.STOCK_ID#')>checked</cfif>>
                                        </td>
                                    </cfif>
                                </tr>
                            </cfoutput>
                        </cfloop>
                        <tr>
                            <td colspan="6" style="font-weight:bold">Toplam</td>
                            <td style="font-weight:bold; text-align:right">
                                <cfinput type="text" name="gtotal" id="gtotal" value="#TlFormat(gtotal,2)#" style="width:70px; text-align:right; font-weight:bold" > 
                            </td>
                            <td style="font-weight:bold; text-align:right">
                                <cfinput type="text" name="mtotal" id="mtotal" value="#TlFormat(mtotal,2)#" style="width:70px; text-align:right; font-weight:bold" > 
                            </td>
                            <cfif len(get_partner.SALES_COMPANY_ID)>
                                <td>&nbsp;</td>
                            </cfif>
                        </tr>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="6" height="20" style="text-align:left; font-weight:bold">	
                                <cfif row_money_rate2 gt 0>
                                    <cfset row_money_total = mtotal/row_money_rate2>
                                <cfelse>
                                    <cfset row_money_total = 0>
                                </cfif>
                                Satır Dövizi (<cfoutput>#attributes.row_money#</cfoutput>) : 
                                <cfinput type="text" name="row_money_total" id="row_money_total" value="#TlFormat(row_money_total,2)#" style="font-weight:bold" class="box">
                            </td>
                            <cfif len(get_partner.SALES_COMPANY_ID)>
                                <cfset row_span = 3>
                            <cfelse>
                                <cfset row_span = 2>
                            </cfif>
                            <td colspan="<cfoutput>#row_span#</cfoutput>" height="20" style="text-align:right">
                            	<cfif isdefined('attributes.kilit_stage') and not attributes.kilit_stage>
                                	<cf_workcube_buttons is_upd='1' is_delete='0' add_function='kontrol()'> 
                              	</cfif>
                            </td>
                        </tr>
                    </tfoot>
              	</cf_grid_list>
            </cf_basket>
 		</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	function kontrol()
	{
		return true;
	}
	function check_control(row)
	{
		if(parseFloat(filterNum(document.getElementById('price'+row).value,2)) == 0)
		{
			alert('Fiyat 0 dan Büyük Olmalıdır');
			return false;
		}
		if(parseFloat(filterNum(document.getElementById('amount'+row).value,2)) == 0)
		{
			alert('Miktar 0 dan Büyük Olmalıdır');
			return false;
		}
		hesapla(row);
	}
	function hesapla(row)
	{
		
		gtotal=0;
		mtotal=0;
		row_money_rate2 = <cfoutput>#row_money_rate2#</cfoutput>;
		for (var r=1;r<=document.upd_virtual_cost.record_num.value;r++)
		{
			if(eval('document.all.select_product'+r).checked==true)
			{
				total = parseFloat(filterNum(document.getElementById('price'+r).value,2)) * parseFloat(filterNum(document.getElementById('amount'+r).value,2));
				document.getElementById('total'+r).value = commaSplit(total,2);
				gtotal = gtotal + total;
				total = parseFloat(filterNum(document.getElementById('price'+r).value,2)) * parseFloat(filterNum(document.getElementById('amount'+r).value,2)) * parseFloat(filterNum(document.getElementById('row_rate2_'+r).value,4));
				document.getElementById('totalm'+r).value = commaSplit(total,2);
				mtotal = mtotal + total;
			}
			else
			{
				total = 0;
				document.getElementById('total'+r).value = commaSplit(total,2);
				gtotal = gtotal + total;
				total = 0;
				document.getElementById('totalm'+r).value = commaSplit(total,2);
				mtotal = mtotal + total;
			}
			document.getElementById('gtotal').value = commaSplit(gtotal,2);
			document.getElementById('mtotal').value = commaSplit(mtotal,2);
			document.getElementById('row_money_total').value = commaSplit(mtotal/row_money_rate2,2);
		}
	}
	function satir_doviz_hesapla(currentrow)
	{
		row_money = document.getElementById('money'+currentrow).value;
		<cfif get_virtual_offer_money.recordcount>
			<cfoutput query="get_virtual_offer_money">
				money_type = '#get_virtual_offer_money.money_type#';
				money_currentrow = #get_virtual_offer_money.currentrow#;
				rate2 = #TlFormat(get_virtual_offer_money.rate2,4)#;
				if(row_money==money_type)
				{
					document.getElementById('row_rate2_'+currentrow).value=rate2;
				}
			</cfoutput>
		<cfelse>
			<cfoutput query="get_money">
				money_type = '#get_money.money#';
				money_currentrow = #get_money.currentrow#;
				rate2 = #TlFormat(get_money.rate2,4)#;
				if(row_money==money_type)
				{
					document.getElementById('row_rate2_'+currentrow).value=rate2;
				}
			</cfoutput>
		</cfif>
		hesapla(currentrow);
	}
</script>

