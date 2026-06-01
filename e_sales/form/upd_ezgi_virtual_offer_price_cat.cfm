<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.is_excel" default="">
<cfparam name="attributes.price_type" default="">
<cfif isdefined("attributes.is_submitted")>
	<cfquery name="get_price_row" datasource="#DSN3#">
    	SELECT     
        	PRICE_CAT_ROW_ID, 
            PRICE_CAT_ID, 
            PRODUCT_CODE_2, 
            PRODUCT_NAME, 
            STOCK_ID, 
            PIECE_ROW_ID, 
            SALES_PRICE, 
            SALES_PRICE_MONEY, 
            PURCHASE_PRICE, 
            PURCHASE_PRICE_MONEY, 
            COST_PRICE, 
            COST_PRICE_MONEY,
            MONTAGE_TYPE,
            PRICE_TYPE,
            IS_RATE
		FROM        
        	EZGI_VIRTUAL_OFFER_PRICE_ROW WITH (NOLOCK)
      	WHERE
        	PRICE_CAT_ID = #attributes.price_cat_id#
            <cfif len (attributes.keyword)>
				AND 
                	( 
                	PRODUCT_NAME LIKE '#attributes.keyword#%'  OR
                    PRODUCT_CODE_2 LIKE '#attributes.keyword#%'
                    )
			</cfif>
            <cfif len(attributes.price_type)>
            	AND PRICE_TYPE = #attributes.price_type#
            </cfif>
      	ORDER BY
        	PRODUCT_CODE_2
	</cfquery>
<cfelse>
	<cfset get_price_row.recordcount=0>
</cfif>
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'> 
<cfparam name="attributes.totalrecords" default="#get_price_row.recordcount#">
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows) + 1 >
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
		<cfform name="add_bill" action="#request.self#?fuseaction=prod.upd_ezgi_virtual_offer_price_cat&price_cat_id=#attributes.price_cat_id#">
			<input type="hidden" name="is_submitted" id="is_submitted" value="1">
			<cf_box_search more="0"> 
				<div class ="form-group">
					<cfinput type="text" name="keyword" style="width:80px;" value="#attributes.keyword#" maxlength="50" placeholder="#getLang(48,'Filtre',57460)#">
				</div>
                <div class ="form-group">
					<select name="price_type" id="price_type">
                    	<option value="" <cfif attributes.price_type eq "">selected</cfif>>Tümü</option>
                    	<option value="0" <cfif attributes.price_type eq 0>selected</cfif>>Sanal Bağlantı</option>
                     	<option value="1" <cfif attributes.price_type eq 1>selected</cfif>>Ürün Bağlantısı</option>
                     	<option value="2" <cfif attributes.price_type eq 2>selected</cfif>>Parça Bağlantısı</option>
                 	</select>
				</div>
                <div class ="form-group">
					<cf_get_lang dictionary_id='57858.Excel Getir'><input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
				</div>
				<div class ="form-group small">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
					<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,5000" message="#message#" onKeyUp="isNumber(this)" maxlength="4" style="width:35px;">
				</div>
				<div class ="form-group">
					<cf_wrk_search_button search_function='input_control()' button_type="1">
					<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'> 
				</div>
			</cf_box_search>
		</cfform>
	</cf_box>
	<cfsavecontent variable="right_menu">
    	<a style="cursor:pointer" onclick="add_price_upload(<cfoutput>#attributes.price_cat_id#</cfoutput>);">
    		<img src="/images/doc_export.gif" title="Fiyat Dosyası Yükle" />
      	</a>
    </cfsavecontent>
	<cf_box title="Fiyat Listesi Güncelle"  hide_table_column="1" right_images="#right_menu#">
    	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
			<cfset filename="Sanal_Fiyat_Liste#dateformat(now(),'ddmmyyyy')#_#timeformat(now(),'HHMMl')#_#session.ep.userid#">
            <cfheader name="Expires" value="#Now()#">
            <cfcontent type="application/vnd.msexcel;charset=utf-16">
            <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
            <meta http-equiv="Content-Type" content="text/plain; charset=utf-16">
            <cfset attributes.startrow=1>
            <cfset attributes.maxrows=get_price_row.recordcount>
        </cfif>
		<cf_grid_list>
			<thead>
				<tr>
					<th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th width="60">STOCK_ID</th>
                    <th width="60">PIECE_ROW_ID</th>
					<th width="150">Ürün Kodu</th>
                    
					<th>Ürün Adı</th>
					<th width="100">Satış Fiyatı</th>
					<th style="width:50"><cf_get_lang dictionary_id='57677.Döviz'></th>
					<th width="100">Bayi Alış</th>
					<th style="width:50"><cf_get_lang dictionary_id='57677.Döviz'></th>
					<th width="100">Maliyet Fiyatı</th>
					<th style="width:50"><cf_get_lang dictionary_id='57677.Döviz'></th>
                    <th width="60"><cf_get_lang dictionary_id="34513.Montaj Tipi"></th>
                    <th width="60">Fiyat Tipi</th>
                    <th width="60">IS_RATE</th>
					<!-- sil --><th width="20" class="header_icn_none"><a href="javascript://" onClick="windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_virtual_offer_price_row&price_cat_id=#attributes.price_cat_id#</cfoutput>','medium');"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th><!-- sil -->
				</tr>
			</thead>
			<tbody>
            	<cfif isdefined("attributes.is_submitted") and get_price_row.recordcount>
					<cfoutput query="get_price_row" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <tr>
                            <td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">#STOCK_ID#</td>
                            <td style="text-align:center">#PIECE_ROW_ID#</td>
                            <td>
                            	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
                                	#PRODUCT_CODE_2#
                                <cfelse>
                            		<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_upd_ezgi_virtual_offer_price_row&PRICE_CAT_ROW_ID=#PRICE_CAT_ROW_ID#','medium');">#PRODUCT_CODE_2#</a>
                              	</cfif>
                          	</td>
                            
                            <td>#PRODUCT_NAME#</td>
                            <td style="text-align:right">#TlFormat(SALES_PRICE)#</td>
                            <td>#SALES_PRICE_MONEY#</td>
                            <td style="text-align:right">#TlFormat(PURCHASE_PRICE)#</td>
                            <td>#PURCHASE_PRICE_MONEY#</td>
                            <td style="text-align:right">#TlFormat(COST_PRICE)#</td>
                            <td>#COST_PRICE_MONEY#</td>
                            <td style="text-align:center">#MONTAGE_TYPE#</td>
                            <td style="text-align:center">#PRICE_TYPE#</td>
                            <td style="text-align:center">#IS_RATE#</td>
                            <!-- sil --><td><a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_upd_ezgi_virtual_offer_price_row&PRICE_CAT_ROW_ID=#PRICE_CAT_ROW_ID#','medium');"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td><!-- sil -->
                        </tr>
                    </cfoutput>
				</tbody>
				<tfoot>
				<cfelse>
						<tr>
							<td colspan="16"><cfif isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='57484.Kayıt Yok'><cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfif>!</td>
						</tr>
					</tfoot>
                </cfif>
			
		</cf_grid_list>

		<cfset url_str = "&is_submitted=1">
		<cfif isDefined('attributes.keyword') and len (attributes.keyword)>
			<cfset url_str = '#url_str#&keyword=#attributes.keyword#'>
		</cfif>
        <cfif isDefined('attributes.price_type') and len (attributes.price_type)>
			<cfset url_str = '#url_str#&price_type=#attributes.price_type#'>
		</cfif>
		<cf_paging
			page="#attributes.page#" 
			maxrows="#attributes.maxrows#" 
			totalrecords="#attributes.totalrecords#" 
			startrow="#attributes.startrow#" 
			adres="prod.upd_ezgi_virtual_offer_price_cat&price_cat_id=#attributes.price_cat_id##url_str#">
	</cf_box>
</div>
<script type="text/javascript">
   	document.getElementById('keyword').focus();
	function input_control()
	{
		if(document.getElementById('is_excel').checked==false)
			return true;
	}
	function add_price_upload(price_cat_id)
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_add_ezgi_virtual_offer_price_row_download&price_cat_id='+price_cat_id,'small');		
	}
</script>
