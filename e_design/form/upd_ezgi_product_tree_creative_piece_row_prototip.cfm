<!---
    File: upd_ezgi_product_tree_creative_piece_row_prototip.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset var_="upd_purchase_basket">
<cfquery name="get_upd_piece" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_PIECE WITH (NOLOCK) WHERE PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>
<cfquery name="get_prototip_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_PIECE_PROTOTIP_DEFAULT WITH (NOLOCK) WHERE PIECE_TYPE = #get_upd_piece.PIECE_TYPE#
</cfquery>
<cfquery name="get_money" datasource="#dsn#">
	SELECT MONEY_ID, MONEY, PERIOD_ID FROM SETUP_MONEY WITH (NOLOCK) WHERE PERIOD_ID = #session.ep.period_id#
</cfquery>
<cfif not get_prototip_defaults.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='149.Önce Tasarım Genel Default Bilgilerini Tanımlayınız'>!");
		window.close()
	</script>
    <cfabort>
</cfif>
<cfif get_upd_piece.PIECE_TYPE eq 4>
    <cfquery name="get_piece_alternatives" datasource="#dsn3#">
        SELECT    
        	ISNULL(ED.IS_SPECIAL_MEASURE,0) AS IS_SPECIAL_MEASURE,
            ED.ALTERNATIVE_AMOUNT_FORMUL, 
            ED.ALTERNATIVE_AMOUNT AS AMOUNT,
            S.PRODUCT_NAME,
            S.STOCK_ID,
            S.PRODUCT_ID
		FROM            
    		EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE AS ED WITH (NOLOCK) INNER JOIN
          	STOCKS AS S WITH (NOLOCK) ON ED.ALTERNATIVE_STOCK_ID = S.STOCK_ID
		WHERE        
        	ED.PIECE_ROW_ID = #attributes.design_piece_row_id#
    </cfquery>
    <cfquery name="get_piece_prototip" datasource="#dsn3#">
    	SELECT * FROM EZGI_DESIGN_PIECE_PROTOTIP WHERE PIECE_ROW_ID = #attributes.design_piece_row_id#
 	</cfquery>
<cfelse>
	<cfif not isdefined('attributes.ezgi_piece_row_row_id')>
        <cfquery name="get_piece_alternatives" datasource="#dsn3#">
            SELECT    
            	ISNULL(ED.IS_SPECIAL_MEASURE,0) AS IS_SPECIAL_MEASURE,  
            	ED.PIECE_ROW_PROTOTIP_ALTERNATIVE_ID,  
                ED.ALTERNATIVE_AMOUNT_FORMUL, 
                ED.ALTERNATIVE_AMOUNT AS AMOUNT, 
                EP.PIECE_NAME AS PRODUCT_NAME,
                ED.ALTERNATIVE_PIECE_ROW_ID AS STOCK_ID,
                ED.ALTERNATIVE_PIECE_ROW_ID AS PRODUCT_ID
            FROM 
                EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE AS ED WITH (NOLOCK) INNER JOIN
                EZGI_DESIGN_PIECE_ROWS AS EP WITH (NOLOCK) ON ED.ALTERNATIVE_PIECE_ROW_ID = EP.PIECE_ROW_ID
            WHERE        
                ED.PIECE_ROW_ID = #attributes.design_piece_row_id#
        </cfquery>
        <cfquery name="get_piece_prototip" datasource="#dsn3#">
            SELECT * FROM EZGI_DESIGN_PIECE_PROTOTIP WITH (NOLOCK) WHERE PIECE_ROW_ID = #attributes.design_piece_row_id#
        </cfquery>
  	<cfelse>
    	<cfquery name="get_piece_alternatives" datasource="#dsn3#">
        	SELECT 
                EA.ALTERNATIVE_AMOUNT_FORMUL, 
                EA.ALTERNATIVE_AMOUNT AS AMOUNT, 
                S.PRODUCT_NAME,
                S.STOCK_ID,
                S.PRODUCT_ID
			FROM     
            	EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE AS EA WITH (NOLOCK) INNER JOIN
                STOCKS AS S WITH (NOLOCK) ON EA.ALTERNATIVE_STOCK_ID = S.STOCK_ID
			WHERE  
            	EA.EZGI_PIECE_ROW_ROW_ID = #attributes.ezgi_piece_row_row_id#
			ORDER BY 
            	EA.PIECE_ROW_PROTOTIP_ALTERNATIVE_ID
        </cfquery>
        <cfquery name="get_piece_prototip" datasource="#dsn3#">
            SELECT * FROM EZGI_DESIGN_PIECE_PROTOTIP WHERE EZGI_PIECE_ROW_ROW_ID = #attributes.ezgi_piece_row_row_id#
        </cfquery>
        <cfquery name="get_alternative_cat" datasource="#dsn3#">
        	SELECT 
            	S.PRODUCT_NAME, 
                S.PRODUCT_CATID, 
                PC.PRODUCT_CAT,
                S.STOCK_ID
			FROM     
            	STOCKS AS S WITH (NOLOCK) INNER JOIN
                PRODUCT_CAT AS PC WITH (NOLOCK) ON S.PRODUCT_CATID = PC.PRODUCT_CATID INNER JOIN
                EZGI_DESIGN_PIECE_ROW AS EP WITH (NOLOCK) ON S.STOCK_ID = EP.STOCK_ID
			WHERE  
            	EP.EZGI_PIECE_ROW_ROW_ID = #attributes.ezgi_piece_row_row_id#
        </cfquery>
        <cfif get_alternative_cat.recordcount>
        	<cfset catid = get_alternative_cat.PRODUCT_CATID>
			<cfset cat = get_alternative_cat.PRODUCT_CAT>
        <cfelse>
        	<cfset catid = 0>
			<cfset cat = ''>
        </cfif>
    </cfif>
</cfif>

<cfquery name="get_design" datasource="#dsn3#">
	SELECT  * FROM EZGI_DESIGN WITH (NOLOCK) WHERE DESIGN_ID = #get_upd_piece.design_id#
</cfquery>
<cfquery name="Get_Alternative_Questions" datasource="#dsn#">
	SELECT        
    	QUESTION_ID, 
        QUESTION_NAME
	FROM        
    	SETUP_ALTERNATIVE_QUESTIONS WITH (NOLOCK)
	ORDER BY 
    	QUESTION_NAME
</cfquery>
<cfif get_piece_prototip.recordcount>
	<cfset standart_boy_formul = get_piece_prototip.BOY_FORMUL>
    <cfset standart_en_formul = get_piece_prototip.EN_FORMUL>
    <cfset standart_amount_formul = get_piece_prototip.AMOUNT_FORMUL>
    <cfset standart_price_formul = get_piece_prototip.PRICE_FORMUL>
<cfelse>
	<cfset standart_boy_formul = get_prototip_defaults.DEFAULT_BOY_FORMUL>
    <cfset standart_en_formul = get_prototip_defaults.DEFAULT_EN_FORMUL>
    <cfset standart_amount_formul = get_prototip_defaults.DEFAULT_AMOUNT_FORMUL>
    <cfset standart_price_formul = ''>
</cfif>
<br />
<cfsavecontent variable="title"><cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
 	<cfform name="upd_alternatives" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative_piece_row_prototip">
    	<cf_box title="#title#">
        	<cfinput type="hidden" name="design_piece_row_id" value="#attributes.design_piece_row_id#">
        	<cfinput type="hidden" name="piece_type" value="#get_upd_piece.PIECE_TYPE#">
            <cfif isdefined('attributes.ezgi_piece_row_row_id')>
            	<cfinput type="hidden" name="ezgi_piece_row_row_id" value="#attributes.ezgi_piece_row_row_id#">
                <cfinput type="hidden" name="alternative_piece_row_row_id" value="#get_alternative_cat.stock_id#">
            </cfif>
         	<cfoutput>
                <cf_box_elements>
                    <div class="col col-6 col-md-6 col-sm-8 col-xs-12" type="column" index="1" sort="true">
                    	<!---<cfif not isdefined('attributes.ezgi_piece_row_row_id')>--->
                            <div class="form-group" id="item-is_price">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='38006.Fiyat Eklenmesin'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="checkbox" name="is_price" id="is_price" value="1" <cfif  get_piece_prototip.IS_PRICE_CHANGE eq 1>checked</cfif>>
                                </div>
                            </div>
                            
                            <cfif get_upd_piece.PIECE_TYPE eq 4>
                                <div class="form-group" id="item-is_similar_stock">
                                    <label class="col col-4 col-xs-12">Benzer Ürün</label>
                                    <div class="col col-8 col-xs-12">
                                        <input type="checkbox" name="is_similar_stock" id="is_similar_stock" value="1" onchange="similar_stock();" <cfif  get_piece_prototip.IS_SIMILAR_STOCK eq 1>checked</cfif>>
                                    </div>
                                </div>
                           	<cfelse>
                            	<div class="form-group" id="item-price_formul">
                                    <label class="col col-4 col-xs-12">Fiyat Formülü</label>
                                    <div class="col col-8 col-xs-12">
                                        <cfinput type="text" name="price_formul" id="price_formul" value="#standart_price_formul#" style="width:300px; height:20px">
                                    </div>
                                </div>
                            </cfif>
                            <div class="form-group" id="piece_en_" style="display:<cfif get_upd_piece.PIECE_TYPE eq 4 and get_piece_prototip.IS_SIMILAR_STOCK neq 1>none</cfif>">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='893.Boy Formülü'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfinput type="text" name="boy_formul" id="boy_formul" value="#standart_boy_formul#" style="width:300px; height:20px">
                                </div>
                            </div>
                            <div class="form-group" id="piece_boy_" style="display:<cfif get_upd_piece.PIECE_TYPE eq 4 and get_piece_prototip.IS_SIMILAR_STOCK neq 1>none</cfif>">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='892.En Formülü'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfinput type="text" name="en_formul" id="en_formul" value="#standart_en_formul#" style="width:300px; height:20px">
                                </div>
                            </div>
                            <div class="form-group" id="is_amount_">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='59111.Miktar Göster'></label>
                                <div class="col col-8 col-xs-12">
                                    <input type="checkbox" name="is_amount" id="is_amount" value="1" <cfif  get_piece_prototip.IS_AMOUNT_CHANGE eq 1>checked</cfif>>
                                </div>
                            </div>
                            <div class="form-group" id="private_price_type_">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='812.Özel Ölçü Fiyat Türü'></label>
                                <div class="col col-4 col-xs-12">
                                    <select name="private_price_type" id="private_price_type" style="width:130px; height:20px" onchange="private_field();">
                                        <option value="0" <cfif get_piece_prototip.private_price_type eq 0>selected</cfif>><cf_get_lang dictionary_id ='58546.Yok'></option>
                                        <option value="1" <cfif get_piece_prototip.private_price_type eq 1>selected</cfif>><cf_get_lang dictionary_id ='58544.Sabit'></option>
                                        <option value="2" <cfif get_piece_prototip.private_price_type eq 2>selected</cfif>><cf_get_lang dictionary_id ='47476.Yüzde'></option>
                                    </select>
                                </div>
                                <div class="col col-2 col-xs-12" id="private_price_" style="display:<cfif not get_piece_prototip.recordcount or get_piece_prototip.private_price_type eq 0>none</cfif>">
                                    <cfif len(get_piece_prototip.private_price)>
                                        <cfset private_price = get_piece_prototip.private_price>
                                    <cfelse>
                                        <cfset private_price = 0>
                                    </cfif>
                                    <cfinput type="text" name="private_price" id="private_price" value="#TlFormat(private_price,2)#" style="width:50px; height:20px; text-align:right">
                                </div>
                                <div class="col col-2 col-xs-12" id="private_price_money_" style="display:<cfif not get_piece_prototip.recordcount or get_piece_prototip.private_price_type neq 1>none</cfif>">
                                    <select name="private_price_money" id="private_price_money" style="width:50px; height:20px">
                                        <cfloop query="get_money">
                                            <option value="#money#" <cfif get_piece_prototip.private_price_money eq get_money.money>selected</cfif>>#money#</option> 
                                        </cfloop>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group" id="is_amount_formul_">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='891.Miktar Formülü'></label>
                                <div class="col col-8 col-xs-12">
                                    <cfinput type="text" name="amount_formul" id="amount_formul" value="#standart_amount_formul#" style="width:300px; height:20px">
                                </div>
                            </div>
                        <!---</cfif>--->
                        <div class="form-group" id="piece_alternative_Question_">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='36454.Alternatif Sorusu'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="alternative_question_id" id="alternative_question_id" style="width:130px; height:20px" onChange="piece_alternative_Question();">
                                	<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                	<cfloop query="Get_Alternative_Questions">
                                    	<option value="#QUESTION_ID#" <cfif get_piece_prototip.QUESTION_ID eq QUESTION_ID>style="font-weight:bold" selected </cfif>>#QUESTION_NAME#</option>
                                 	</cfloop>
                             	</select>
                            </div>
                        </div>
               		</div>
               	</cf_box_elements>
                <cf_box_footer>
         	<div class="col col-12">
            	<cf_record_info 
                	query_name="get_upd_piece"
                 	record_emp="RECORD_EMP" 
                 	record_date="record_date"
                	update_emp="UPDATE_EMP"
               		update_date="update_date">
          		<cf_workcube_buttons 
              		is_upd='1' 
                  	is_delete='1' 
                 	delete_page_url='#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative_piece_row_prototip&is_delete=1&design_piece_row_id=#attributes.design_piece_row_id#'
                	add_function='kontrol()'>
      		</div>
   		</cf_box_footer>
          	</cfoutput>
		</cf_box>
        <cf_basket id="piece_alternative_Products_">
        	<div id="aksesuar_" style=" <cfif not len(get_piece_prototip.QUESTION_ID)>display:none</cfif>">
                <cf_grid_list sort="0">
                	 <thead>
                     	<tr>
                         	<th style="width:30px; text-align:center">
                             	<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_piece_alternatives.recordcount#</cfoutput>">
                              	<a href="javascript:openProducts();"><img src="/images/plus_list.gif"  border="0"></a>
                          	</th>
                           	<th nowrap="nowrap"><cf_get_lang dictionary_id='57452.Stok'></th>
                           	<th width="60px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <cfif not isdefined('attributes.ezgi_piece_row_row_id')>
                            <th style="text-align:center; width:80px">Özel Ölçü</th>
							<th style="text-align:center; width:80px">Sanal Teklif</th>
                            </cfif>
                       	</tr>
                 	</thead>
                    <tbody name="new_row" id="new_row">
                     	<cfif get_piece_alternatives.recordcount>
                        	<cfoutput query="get_piece_alternatives">
                               	<tr name="frm_row" id="frm_row#currentrow#">
                                 	<td style="text-align:center">
                                     	<a style="cursor:pointer" onclick="sil(#currentrow#);" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>
                                       	<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                   	</td>
                                	<td nowrap="nowrap">
                                    	<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#get_piece_alternatives.product_id#">
                                    	<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#get_piece_alternatives.stock_id#">
                                   		<input type="text" name="product_name#currentrow#" id="product_name#currentrow#" value="#get_piece_alternatives.product_name#" style="width:200px;">
                                	</td>
                                  	<td>
                                  		<input type="text" name="quantity#currentrow#" id="quantity#currentrow#" value="#TlFormat(get_piece_alternatives.amount,4)#" style="width:50px; text-align:right;">
                                 	</td>
                                    <cfif not isdefined('attributes.ezgi_piece_row_row_id')>
                                    <td style="text-align:center">
										<input type="checkbox" name="is_special_measure_#currentrow#" id="is_special_measure_#currentrow#" <cfif IS_SPECIAL_MEASURE eq 1>checked</cfif>>
									</td>
									<td style="text-align:center">
                                    	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_virtual_offer_special&type=piece&measure_type=#get_upd_piece.PIECE_TYPE#&measure=#get_piece_alternatives.stock_id#&row_id=#attributes.design_piece_row_id#','small');"></span>
											<img src="images/elements.gif" id="is_virtual_offer_#currentrow#" title="Görünmesini İstediğiniz Sanal Telifi Ekleyin" <cfif IS_SPECIAL_MEASURE eq 0>style="display:none"</cfif>/>
                                        </a>
									</td>
                                    </cfif>
                               	</tr>
							</cfoutput>
                       	</cfif>
                   	</tbody>
                </cf_grid_list>
            </div>
     	</cf_basket>
   	</cfform>
</div>
<script type="text/javascript">
	var row_count=document.upd_alternatives.record_num.value;
	function piece_alternative_Question()
	{
		if(document.getElementById('alternative_question_id').value>0)
			document.getElementById('aksesuar_').style.display = '';
		if(document.getElementById('alternative_question_id').value=='')
			document.getElementById('aksesuar_').style.display = 'none';
	}
	function openProducts()
	{
		<cfif isdefined('attributes.ezgi_piece_row_row_id')>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_ezgi_stocks&price_cat=-2&list_order_no=3,4&product_catid=#catid#&product_cat=#cat#&is_filter=1&add_product_cost=1&module_name=product&var_=#var_#&is_action=1&startdate=&price_lists='</cfoutput>,'page');
		<cfelse>
			<cfif get_upd_piece.PIECE_TYPE eq 4>
				windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_ezgi_stocks&price_cat=-2&list_order_no=3,4&add_product_cost=1&module_name=product&var_=#var_#&is_action=1&startdate=&price_lists='</cfoutput>,'page');
			<cfelse>
				windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_ezgi_stocks&price_cat=-2&ezgi_design=1&ezgi_prototip=1&add_product_cost=1&module_name=product&var_=#var_#&is_action=1&startdate=&price_lists='</cfoutput>,'page');
			</cfif>
		</cfif>
	}
	function add_row(stockid,stockprop,sirano,product_id,product_name,manufact_code,tax,tax_purchase,add_unit,product_unit_id,money,is_serial_no,discount1,discount2,discount3,discount4,discount5,discount6,discount7,discount8,discount9,discount10,del_date_no,p_price,s_price,product_cost,extra_product_cost,is_production,list_price,other_list_price,spec_main_id,spec_main_name)
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.className = 'color-row';
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.upd_alternatives.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>';	
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="Hidden" name="stock_id'+row_count+'" value="' + stockid + '">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="product_id'+row_count+'" value="'+product_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="unit_id'+row_count+'" value="'+product_unit_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="product_name' + row_count + '" style="width:200px;" class="boxtext" value="'+product_name+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="<cfoutput>#TlFormat(1,4)#</cfoutput>" style="width:50px; text-align:right;">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="checkbox" name="is_special_measure_'+row_count+'" id="is_special_measure_'+row_count+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '';
	}
	function sil(sy)
	{
	
		var element=eval("upd_alternatives.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";		
	}
	function private_field()
	{
		private_= document.getElementById('private_price_type').value;
		if(private_ == 0)
		{
			document.getElementById('private_price_').style.display='none';	
			document.getElementById('private_price_money_').style.display='none';	
		}
		else if(private_ == 1)
		{
			document.getElementById('private_price_').style.display='';	
			document.getElementById('private_price_money_').style.display='';	
		}
		else if(private_ == 2)
		{
			document.getElementById('private_price_').style.display='';	
			document.getElementById('private_price_money_').style.display='none';	
		}
	}
	function similar_stock()
	{
		if(eval('document.all.is_similar_stock').checked==true)
		{
			document.getElementById('piece_en_').style.display='';
			document.getElementById('piece_boy_').style.display='';
		}
		else
		{
			document.getElementById('piece_en_').style.display='none';
			document.getElementById('piece_boy_').style.display='none';	
		}
	}
</script>
