<!---
    File: list_virtual_offer_analist.cfm
    Folder: Add_Ons\ezgi\e-sales\display
    Author: Ezgi Yazılım
    Date: 08/06/2022
    Description:
--->
<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.product_cat" default=''>
<cfparam name="attributes.is_excel" default="">
<cfquery name="get_money" datasource="#dsn#">
	SELECT MONEY_ID,MONEY, RATE2, RATE1 FROM SETUP_MONEY WHERE PERIOD_ID = #session.ep.period_id#
</cfquery>
<cfquery name="get_virtual_offer_money" datasource="#DSN3#">
	SELECT        
    	MONEY_TYPE, 
        RATE2, 
        RATE1, 
        IS_SELECTED
	FROM            
    	EZGI_VIRTUAL_OFFER_MONEY
	WHERE        

    	ACTION_ID = #attributes.virtual_offer_id#
</cfquery>
<cfif isdefined('attributes.virtual_offer_id')>
	<cfoutput query="get_virtual_offer_money">
        <cfset 'RATE1_#MONEY_TYPE#' = RATE1>
        <cfset 'RATE2_#MONEY_TYPE#' = RATE2>
    </cfoutput>
<cfelse>
	<cfoutput query="get_money">
        <cfset 'RATE1_#MONEY#' = RATE1>
        <cfset 'RATE2_#MONEY#' = RATE2>
    </cfoutput>
</cfif>
<cfquery name="get_product_cat" datasource="#DSN3#">
	SELECT 
      	PC.PRODUCT_CAT, 
        PC.PRODUCT_CATID
	FROM     
    	EZGI_VIRTUAL_OFFER_ROW AS ORR INNER JOIN
        STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        PRODUCT_CAT AS PC ON S.PRODUCT_CATID = PC.PRODUCT_CATID
	WHERE  
    	ORR.VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
 	GROUP BY
    	PC.PRODUCT_CAT, 
        PC.PRODUCT_CATID
 	ORDER BY
    	PC.PRODUCT_CAT
</cfquery>

<cfquery name="get_detail" datasource="#DSN3#">
	SELECT 
    	ORR.VIRTUAL_OFFER_ID, 
        ORR.VIRTUAL_OFFER_ROW_ID,
        ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.UNIT,
        ORR.PRICE as SALES_PRICE, 
        ORR.OTHER_MONEY as MONEY, 
        ORR.TAX, 
        ORR.NETTOTAL, 
        ORR.VIRTUAL_OFFER_ROW_CURRENCY, 
        ORR.DISCOUNT_1, 
        ORR.DISCOUNT_2, 
        ORR.DISCOUNT_3, 
        ORR.DISCOUNT_COST as DISCOUNT_TUT, 
        ORR.PRODUCT_NAME2, 
        ORR.PRODUCT_NAME,
        ORR.ROW_DISCOUNTTOTAL, 
        ORR.PRICE_OTHER, 
        ORR.COST, 
        ORR.EZGI_ID, 
        ORR.SORT_NO, 
        S.STOCK_CODE, 
      	PC.PRODUCT_CAT, 
        PC.PRODUCT_CATID
	FROM     
    	EZGI_VIRTUAL_OFFER_ROW AS ORR INNER JOIN
        STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
        PRODUCT_CAT AS PC ON S.PRODUCT_CATID = PC.PRODUCT_CATID
	WHERE  
    	ORR.VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
		<cfif isdefined('attributes.keyword') and len (attributes.keyword)>
        	AND
            	(
                	ORR.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                    ORR.PRODUCT_NAME2 LIKE '%#attributes.keyword#%'
                )
        </cfif>
        <cfif isdefined('attributes.product_cat') and len (attributes.product_cat)>
    		AND PC.PRODUCT_CATID = #attributes.product_cat#
        </cfif>
  	ORDER BY
    	ORR.SORT_NO	
</cfquery>
<cfparam name="attributes.maxrows" default="#SESSION.EP.MAXROWS#">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.totalrecords" default="#get_detail.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<cfsavecontent variable="message"><cf_get_lang dictionary_id='57564.Ürünler'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
   <div class="col col-12">
	<cf_box title="#message#" >
    	<cfform name="v_offer_list" action="#request.self#?fuseaction=prod.popup_list_virtual_offer_analist" method="post">
        	<cfinput type="hidden" name="virtual_offer_id" id="virtual_offer_id" value="#attributes.virtual_offer_id#">
			<cfinput type="hidden" name="is_filter" id="is_filter" value="1">
            <cf_box_search>
            	<div class="form-group" id="item-keyword">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" placeholder="#message#" id="keyword"  value="#attributes.keyword#" maxlength="200">
				</div>
                <div class="form-group" id="item-product_cat">
					<select name="product_cat" id="product_cat">
                		<option value="">Seçiniz</option>
                   		<cfoutput query="get_product_cat">
                         	<option value="#PRODUCT_CATID#" <cfif isdefined("attributes.product_cat") and attributes.product_cat eq #product_CATID#>selected</cfif>>#product_cat#</option>
                     	</cfoutput>
               		</select>
				</div>
                <div class="form-group">
                	<input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
                	<cf_get_lang_main no='446.Excel Getir'>
                </div>
                <div class="form-group small">
					<cfinput type="text" name="maxrows" id="maxrows" value="#attributes.maxrows#" validate="integer" range="1," required="yes" message="Sayi_Hatasi_Mesaj" onkeyup="return(formatcurrency(this,event,0));">
				</div>
				<div class="form-group">   
					<cf_wrk_search_button search_function='input_control()' button_type="1">
				</div>
          	</cf_box_search>
            <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
				<cfset filename = "#createuuid()#">
                <cfheader name="Expires" value="#Now()#">
                <cfcontent type="application/vnd.msexcel;charset=utf-16">
                <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
                <meta http-equiv="Content-Type" content="text/html; charset=utf-16">
                <cfset attributes.startrow=1>
                <cfset attributes.maxrows = get_detail.recordcount>
            </cfif>
			<cf_grid_list id="operation_panel" sort="0">
            	<thead>
					<tr>
                    	<th width="20px"></th>
                    	<th width="30">S.No</th>
                        <th width="100"><cf_get_lang dictionary_id="57518.Stok Kodu"></th>
                        <th><cf_get_lang dictionary_id="44019.Ürün"></th>
                        <th width="70">Miktar</th>
                        <th width="25"><cf_get_lang dictionary_id="57636.Birim"></th>
                      	<th width="75"><cf_get_lang dictionary_id="58084.Fiyat"></th>
                      	<th width="40"><cf_get_lang dictionary_id="57677.Döviz"></th>
                        <th width="75">Hizmet</th>
                        <th width="50">İskonto</th>
                        <th width="30">İsk-1</th>
                        <th width="30">İsk-2</th>
                        <th width="30">İsk-3</th>
                        <th width="30">KDV</th>
                        <th width="70" style="text-align:center">Toplam Tutar</th>
                        <th width="70" style="text-align:center">Satır Tutar (TL)</th>
                        <th width="150">A&ccedil;ıklama</th>
                        <th width="25">
                        	<input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <cfif get_detail.recordcount>
						<cfoutput query="get_detail" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
                        	<cfset row_net_other_ = sales_price+cost-discount_tut>
                           	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount_1/100)>
                          	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount_2/100)>
                           	<cfset row_net_other_ = row_net_other_-(row_net_other_*discount_3/100)>
                            
                            <cfset total_brut_other_ = (sales_price+cost)*quantity>
                          	<cfset total_net_other_ = total_brut_other_-(discount_tut*quantity)>
                          	<cfset total_net_other_ = total_net_other_-(total_net_other_*discount_1/100)>
                           	<cfset total_net_other_ = total_net_other_-(total_net_other_*discount_2/100)>
                          	<cfset total_net_other_ = total_net_other_-(total_net_other_*discount_3/100)>
                          	<cfset total_tax_other_ = total_net_other_*tax/100>
                            
                            <cfset total_brut_ = Evaluate('RATE2_#MONEY#')*total_brut_other_>
                        	<cfset total_net_ = Evaluate('RATE2_#MONEY#')*total_net_other_>
                            <tr height="20" class="sorter">
                            	<td style="text-align:center"><span class="icn-md icon-align-justify handle"></span>
                            	<td style="text-align:right" class="row_number">
                                	<input type="text" name="current_id#currentrow#" id="current_id#currentrow#" value="#currentrow#" readonly="readonly" style="width:25px; text-align:right;">
                                    <cfinput type="hidden" name="virtual_offer_row_id" id="virtual_offer_row_id" value="#get_detail.virtual_offer_row_id#">
                                </td>           
                                <td style="text-align:center">#STOCK_CODE#</td>
                                <td style="text-align:left">#PRODUCT_NAME#</td>
                                <td style="text-align:right">#TlFormat(QUANTITY,2)#</td>
                                <td style="text-align:left">#UNIT#</td>
                                <td style="text-align:right">#TlFormat(sales_price,2)#</td>
                                <td style="text-align:left">#MONEY#</td>
                                <td style="text-align:right">#TlFormat(cost,2)#</td>
                                <td style="text-align:right">#TlFormat(discount_tut,2)#</td>
                                <td style="text-align:center">#TlFormat(discount_1,2)#</td>
                                <td style="text-align:center">#TlFormat(discount_2,2)#</td>
                                <td style="text-align:center">#TlFormat(discount_3,2)#</td>
                                <td style="text-align:center">#TlFormat(tax,0)#</td>
                                <td style="text-align:right">#TlFormat(total_brut_other_,2)#</td>
                                <td style="text-align:right">#TlFormat(total_brut_,2)#</td>
                                <td style="text-align:left">#PRODUCT_NAME2#</td>
                                <td style="text-align:center">
                                	<input type="checkbox" name="select_production" value="#VIRTUAL_OFFER_ROW_ID#">
                                </td>
                         	</tr>
                        </cfoutput> 
                        <tfoot>
                        	<td colspan="14"></td>
                            <td colspan="2"><button  value="" name="update_buton" id="update_buton" onClick="kaydet();" style="width:150px; height:35px; background-color:darkturquoise"><cf_get_lang dictionary_id='58230.Satır No'> <cf_get_lang dictionary_id='57464.Güncelle'></button></td>
                            <td colspan="2"><button  value="" name="gonder" onClick="grupla();" style="width:180px; height:35px;"><cf_get_lang dictionary_id='36523.Malzeme İhtiyaç Listesi'></button></td>	
                            
                        </tfoot>
                    <cfelse>
                        <tr> 
                            <td colspan="8">
                                <cfif isdefined('attributes.is_filter')>
                                    <cf_get_lang dictionary_id="58486.Kayıt Bulunamadı">!
                                <cfelse>
                                    <cf_get_lang dictionary_id="57701.Filtre Ediniz">!
                                </cfif>
                            </td>
                        </tr>
                    </cfif>
                </tbody>
           	</cf_grid_list>
       	</cfform> 
	</cf_box>
    <cfif attributes.totalrecords gt attributes.maxrows>
        <table width="99%">
            <tr> 
                <td>
                <cfset adres = "prod.popup_list_virtual_offer_analist&is_filter=1">
                <cfif len(attributes.keyword)>
                    <cfset adres = "#adres#&keyword=#attributes.keyword#">
                </cfif>
                <cfif isdefined('attributes.product_cat') and len(attributes.product_cat)>
                    <cfset adres = "#adres#&product_cat=#attributes.product_cat#">
                </cfif>
                <cf_paging
                    page="#attributes.page#"
                    maxrows="#attributes.maxrows#"
                    totalrecords="#attributes.totalrecords#"
                    startrow="#attributes.startrow#"
                    adres="#adres#">
                </td>
            </tr>
        </table>
    </cfif>
    </div>
</div>

<script type="text/javascript">
	$( "#keyword" ).focus();
	function input_control()
	{
		if(document.getElementById('is_excel').checked==false)
			return true;
	}
	function kaydet()
	{
		document.getElementById('update_buton').disabled = true;
		sor=confirm('Satır Sıralamasını Bu Şekilde Güncelleme Yapıyorum?');
		if(sor==true)
		{
			document.getElementById("v_offer_list").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_add_ezgi_virtual_offer_analist";
			document.getElementById("v_offer_list").submit();	
		}
		else
		{
			document.getElementById('update_buton').disabled = false;
			return false;	
		}
	}
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		offer_row_id_list = '';
		chck_leng = document.getElementsByName('select_production').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_production[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_production;
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

				offer_row_id_list +=my_objets.value+',';
			}
		}
		offer_row_id_list = offer_row_id_list.substr(0,offer_row_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(offer_row_id_list!='')
		{
			window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_dsp_ezgi_virtual_cost&virtual_offer_row_id='+offer_row_id_list);
		}
	}
	//sortable
	const operationsPanel = $("#operation_panel");

	var sortableSettings = {
		operations: {
			connectWith: '.sorter',
			handle: '.handle',
			start: function (event, ui) {},
			stop: function (event, ui) {
				operationsPanel.find("> tbody tr").each(function (index) {
					$(this).find("td.row_number input[type = text]").val(index + 1);
				});
			}
		}
	};

	operationsPanel.find("> tbody").sortable(sortableSettings.operations);

</script>