<cfquery name="GET_MONEY_RATE" datasource="#dsn2#">
	SELECT MONEY FROM SETUP_MONEY WHERE MONEY_STATUS = 1 ORDER BY MONEY_ID
</cfquery>
<cfquery name="GET_PRICE_ROW" datasource="#dsn3#">
	SELECT *, ISNULL(IS_RATE,0) AS IS_RATE FROM EZGI_VIRTUAL_OFFER_PRICE_ROW WHERE PRICE_CAT_ROW_ID = #attributes.PRICE_CAT_ROW_ID#
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="Fiyat Güncelle">
    <cf_box>
        <cfform name="add_price" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_virtual_offer_price_row">	
        	<cfinput name="PRICE_CAT_ROW_ID" value="#attributes.PRICE_CAT_ROW_ID#" type="hidden"> 
            <cfoutput>
            <cf_box_elements>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="item-price_type">
                        <label class="col col-4 col-xs-12">Fiyat Kart Tipi</label>
                     	<div class="col col-8 col-xs-12">
                        	<select name="price_type" id="price_type" onchange="card_change(this.value)">
                            	<option value="0" <cfif GET_PRICE_ROW.PRICE_TYPE eq "0">selected</cfif>>Sanal Bağlantı</option>
                              	<option value="1" <cfif GET_PRICE_ROW.PRICE_TYPE eq "1">selected</cfif>>Ürün Bağlantısı</option>
                            	<option value="2" <cfif GET_PRICE_ROW.PRICE_TYPE eq "2">selected</cfif>>Parça Bağlantısı</option>
                         	</select>
                        </div>
                    </div>
                	<div class="form-group" id="item-code">
                        <label class="col col-4 col-xs-12">Bağlantı Kodu</label>
                     	<div class="col col-8 col-xs-12">
                        	<input type="text" name="product_code" id="product_code" maxlength="30"  value="#GET_PRICE_ROW.PRODUCT_CODE_2#" >
                        </div>
                    </div>
                    <div class="form-group" id="item-virtual" <cfif GET_PRICE_ROW.PRICE_TYPE neq "0">style="display:none"</cfif>>
                        <label class="col col-4 col-xs-12">Sanal Ürün *</label>
                     	<div class="col col-8 col-xs-12">
                        	<input type="text" name="virtual_product" id="virtual_product" maxlength="50"  value=" <cfif GET_PRICE_ROW.PRICE_TYPE eq "0">#GET_PRICE_ROW.PRODUCT_NAME#</cfif>" >
                        </div>
                    </div>
                    <div class="form-group" id="item-stock" <cfif GET_PRICE_ROW.PRICE_TYPE neq "1">style="display:none"</cfif>>
                        <label class="col col-4 col-xs-12">Ürün Kartı *</label>
                     	<div class="col col-8 col-xs-12">
                        	<div class="input-group">
                                <input type="text" name="urun" id="urun" style="width:200px;" value="<cfif len(GET_PRICE_ROW.stock_id)>#GET_PRICE_ROW.PRODUCT_NAME#</cfif>">
                                <input type="hidden" name="pid" id="pid">
                                <input type="hidden" name="stock_id" id="stock_id" value="#GET_PRICE_ROW.stock_id#"> 
                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac();"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-piece" <cfif GET_PRICE_ROW.PRICE_TYPE neq "2">style="display:none"</cfif>>
                        <label class="col col-4 col-xs-12">Parça Kartı *</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                                <input type="text" name="parca" id="parca" style="width:200px;" value="<cfif len(GET_PRICE_ROW.PIECE_ROW_ID)>#GET_PRICE_ROW.PRODUCT_NAME#</cfif>">
                                <input type="hidden" name="piece_id" id="piece_id" value="#GET_PRICE_ROW.PIECE_ROW_ID#">
                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac_piece();"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-fiyat1_id">
                        <label class="col col-4 col-xs-12">Satış Fiyatı*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                            	<input type="text" name="sales_money_value" id="sales_money_value" maxlength="20"  value="#Tlformat(GET_PRICE_ROW.SALES_PRICE)#" class="moneybox" style="width:130px;" onkeyup="return(FormatCurrency(this,event));">
                                <span class="input-group-addon">
                                    <select name="sales_money" id="sales_money" style="width:60px;">
                                    <cfloop query="GET_MONEY_RATE">
                                    <option value="#money#" <cfif GET_PRICE_ROW.SALES_PRICE_MONEY eq money>selected</cfif>>#money#</option>
                                    </cfloop>
                                    </select>	
                                </span>
                            </div> 
                        </div>
                    </div>
                    <div class="form-group" id="item-fiyat2_id">
                        <label class="col col-4 col-xs-12">Bayi Alış Fiyatı*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                            	<input type="text" name="purchase_money_value" id="purchase_money_value" maxlength="20"  value="#Tlformat(GET_PRICE_ROW.purchase_PRICE)#" class="moneybox" style="width:130px;" onkeyup="return(FormatCurrency(this,event));">
                                <span class="input-group-addon">
                                    <select name="purchase_money" id="purchase_money" style="width:60px;">
                                    <cfloop query="GET_MONEY_RATE">
                                    <option value="#money#" <cfif GET_PRICE_ROW.PURCHASE_PRICE_MONEY eq money>selected</cfif>>#money#</option>
                                    </cfloop>
                                    </select>	
                                </span>
                            </div> 
                        </div>
                    </div>
                    
                    <div class="form-group" id="item-fiyat3_id">
                        <label class="col col-4 col-xs-12">Maliyet Fiyatı*</label>
                        <div class="col col-8 col-xs-12">
                            <div class="input-group">
                            	<input type="text" name="cost_money_value" id="cost_money_value" maxlength="20"  value="#Tlformat(GET_PRICE_ROW.COST_PRICE)#" class="moneybox" style="width:130px;" onkeyup="return(FormatCurrency(this,event));">
                            	<span class="input-group-addon">
                                    <select name="cost_money" id="cost_money" style="width:60px;">
                                    <cfloop query="GET_MONEY_RATE">
                                    <option value="#money#" <cfif GET_PRICE_ROW.COST_PRICE_MONEY eq money>selected</cfif>>#money#</option>
                                    </cfloop>
                                    </select>	
                                </span>
                            </div> 
                        </div>
                    </div>
                    <div class="form-group" id="item-type">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="34513.Montaj Tipi">*</label>
                        <div class="col col-8 col-xs-12">
                         	<select name="montage_type" id="montage_type">
                            	<option value="0" <cfif GET_PRICE_ROW.MONTAGE_TYPE eq 0>selected</cfif>><cf_get_lang dictionary_id="34748.Diğer"></option>
                              	<option value="1" <cfif GET_PRICE_ROW.MONTAGE_TYPE eq 1>selected</cfif>><cf_get_lang dictionary_id="46502.Kapak"></option>
                            	<option value="2" <cfif GET_PRICE_ROW.MONTAGE_TYPE eq 2>selected</cfif>>Gövde</option>
                            	<option value="3" <cfif GET_PRICE_ROW.MONTAGE_TYPE eq 3>selected</cfif>>Arkalık</option>
                         	</select>	
                        </div>
                    </div>
                    <div class="form-group" id="item-type">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="133.Üretim Gideri Katsayısı"></label>
                        <div class="col col-8 col-xs-12">
                         	<select name="is_rate" id="is_rate">
                            	<option value="0" <cfif GET_PRICE_ROW.IS_RATE eq 0>selected</cfif>><cf_get_lang dictionary_id="48213.Hariç"></option>
                              	<option value="1" <cfif GET_PRICE_ROW.IS_RATE eq 1>selected</cfif>><cf_get_lang dictionary_id="53621.Dahil"></option>
                         	</select>	
                        </div>
                    </div>
              	</div>      
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
                    <cf_workcube_buttons is_upd='1' is_cancel="0"
                            del_function_for_submit='del_kontrol()'
                            delete_page_url='#request.self#?fuseaction=prod.emptypopup_del_ezgi_virtual_offer_price_row&PRICE_CAT_ROW_ID=#attributes.PRICE_CAT_ROW_ID#' 
                            delete_alert='Ürüne ait Fiyatı Siliyorsunuz. Emin misiniz?' 
                            add_function='kontrol()'> 
                </div>
            </cf_box_footer>
            </cfoutput>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	function pencere_ac()
	{
		temizle();
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&product_id=add_price.pid&field_id=add_price.stock_id&list_order_no=0,3,4,5,6,7,8,9&field_name=add_price.urun",'list');
	}
	function pencere_ac_piece()
	{
		temizle();
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_list_ezgi_pieces&piece_id=add_price.piece_id&field_id=add_price.piece_id&field_name=add_price.parca",'wide');
	}
	function kontrol()
	{
		if(document.getElementById('product_code').value =='')
		{
			alert('Zorunlu Alan : Bağlantı Kodu');
			document.getElementById('sales_money_value').focus();
			return false;
		}
		if(document.getElementById('sales_money_value').value <= 0 || document.getElementById('sales_money_value').value =='')
		{
			alert('Zorunlu Alan : Satış Fiyatı');
			document.getElementById('sales_money_value').focus();
			return false;
		}
		if(document.getElementById('purchase_money_value').value <= 0 || document.getElementById('purchase_money_value').value =='')
		{
			alert('Zorunlu Alan : Bayi Alış Fiyatı');
			document.getElementById('purchase_money_value').focus();
			return false;
		}
		if(document.getElementById('cost_money_value').value <= 0 || document.getElementById('cost_money_value').value =='')
		{
			alert('Zorunlu Alan : Maliyet Fiyatı');
			document.getElementById('cost_money_value').focus();
			return false;
		}
		if(document.getElementById('price_type').value==0)
		{
			if(document.getElementById('virtual_product').value=='')
			{
				alert('Sanal Ürün Adı Giriniz.!!');
				return false;
			}
		}
		else if(document.getElementById('price_type').value==1)
		{
			if(document.getElementById('urun').value=='')
			{
				alert('Ürün Kartı Giriniz.!!');
				return false;
			}
		}
		else if(document.getElementById('price_type').value==2)
		{
			if(document.getElementById('parca').value=='')
			{
				alert('Parça Kartı Giriniz.!!');
				return false;
			}
		}
		return true;
	}
	function del_kontrol()
	{
	 	return true;	
	}
	function temizle()
	{
		document.getElementById('urun').value = '';
		document.getElementById('parca').value = '';
		document.getElementById('stock_id').value = '';
		document.getElementById('piece_id').value = '';
	}
	function card_change(type)
	{
		if(type==0)
		{
			document.getElementById('item-virtual').style.display="";
			document.getElementById('item-stock').style.display="none";
			document.getElementById('item-piece').style.display="none";
		}
		else if(type==1)
		{
			document.getElementById('item-virtual').style.display="none";
			document.getElementById('item-stock').style.display="";
			document.getElementById('item-piece').style.display="none";
		}
		else if(type==2)
		{
			document.getElementById('item-virtual').style.display="none";
			document.getElementById('item-stock').style.display="none";
			document.getElementById('item-piece').style.display="";
		}
	}
</script>