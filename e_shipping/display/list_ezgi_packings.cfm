<cfset fuseaction_ = ListGetAt(attributes.fuseaction,2,'.')>
<cfparam name="attributes.oby" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.type" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.status" default="2">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.product_catid" default="">
<cfparam name="attributes.product_cat" default="">
<cfparam name="attributes.product_cat_code" default="">
<cfif isdefined('attributes.spect_var_id') and attributes.spect_var_id gt 0>
	<cfquery name="get_spect" datasource="#dsn3#">
    	SELECT SPECT_MAIN_ID,SPECT_VAR_NAME FROM SPECTS WHERE SPECT_VAR_ID = #attributes.spect_var_id#
    </cfquery>
    <cfif get_spect.recordcount and len(get_spect.SPECT_MAIN_ID)>
    	<cfparam name="attributes.spect_main_id" default="#get_spect.SPECT_MAIN_ID#">
		<cfparam name="attributes.spect_name" default="#get_spect.SPECT_VAR_NAME#">
    <cfelse>
    	<cfparam name="attributes.spect_main_id" default="">
		<cfparam name="attributes.spect_name" default="">
    </cfif>
<cfelse>
	<cfparam name="attributes.spect_main_id" default="">
	<cfparam name="attributes.spect_name" default="">
</cfif>
<cfif isdefined('attributes.sid') and attributes.sid gt 0>
	<cfquery name="get_stock" datasource="#dsn3#">
    	SELECT PRODUCT_ID,PRODUCT_NAME FROM STOCKS WHERE STOCK_ID = #attributes.sid#
    </cfquery>
    <cfif get_stock.recordcount and len(get_stock.PRODUCT_ID)>
    	<cfparam name="attributes.stock_id" default="#attributes.sid#">
        <cfparam name="attributes.product_id" default="#get_stock.PRODUCT_ID#">
        <cfparam name="attributes.product_name" default="#get_stock.PRODUCT_NAME#">
    <cfelse>
    	<cfparam name="attributes.stock_id" default="">
        <cfparam name="attributes.product_id" default="">
        <cfparam name="attributes.product_name" default="">
    </cfif>
<cfelse>
	<cfparam name="attributes.stock_id" default="">
	<cfparam name="attributes.product_id" default="">
	<cfparam name="attributes.product_name" default="">
</cfif>
<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
	  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_packings.recordcount=0;
	get_packings.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_packing_list_action = createObject("component", "addOns.ezgi.cfc.get_packings");
		get_packing_list_action.dsn3 = dsn3;
		get_packing_list_action.dsn_alias = dsn_alias;
		get_packings = get_packing_list_action.get_packings_
		(
		 	dsn_alias : '#dsn_alias#',
		 	company_id : '#iif(isdefined("attributes.company_id"),"attributes.company_id",DE(""))#',
			consumer_id : '#iif(isdefined("attributes.consumer_id"),"attributes.consumer_id",DE(""))#',
			member_name : '#iif(isdefined("attributes.member_name"),"attributes.member_name",DE(""))#',
		 	status : '#iif(isdefined("attributes.status"),"attributes.status",DE(""))#',
			type : '#iif(isdefined("attributes.type"),"attributes.type",DE(""))#',
			list_type : '#iif(isdefined("attributes.list_type"),"attributes.list_type",DE(""))#',
			oby : '#iif(isdefined("attributes.oby"),"attributes.oby",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#',
			stock_id : '#iif(isdefined("attributes.stock_id"),"attributes.stock_id",DE(""))#',
        	product_id : '#iif(isdefined("attributes.product_id"),"attributes.product_id",DE(""))#',
        	product_name : '#iif(isdefined("attributes.product_name"),"attributes.product_name",DE(""))#',
			spect_main_id : '#iif(isdefined("attributes.spect_main_id"),"attributes.spect_main_id",DE(""))#',
			spect_name : '#iif(isdefined("attributes.spect_name"),"attributes.spect_name",DE(""))#',
			product_catid : '#iif(isdefined("attributes.product_catid"),"attributes.product_catid",DE(""))#',
			product_cat : '#iif(isdefined("attributes.product_cat"),"attributes.product_cat",DE(""))#',
			product_cat_code : '#iif(isdefined("attributes.product_cat_code"),"attributes.product_cat_code",DE(""))#'
		);
		arama_yapilmali=0;
		}
	else
	{
		arama_yapilmali=1;
	}
</cfscript>
<cfparam name="attributes.totalrecords" default='#get_packings.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_list" action="#request.self#?fuseaction=#attributes.fuseaction#" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cf_box_search>
				<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium">
                	<select name="list_type" id="list_type" style="width:100px;">
                  		<option value="1" <cfif attributes.list_type eq 1>selected</cfif>><cf_get_lang dictionary_id='57660.Belge Bazında'></option>
                   		<option value="2" <cfif attributes.list_type eq 2>selected</cfif>><cf_get_lang dictionary_id='29539.Satır Bazında'></option>
                	</select>
              	</div>
                <div class="form-group medium">
                	<select name="type" id="type" style="width:100px; height:20px">
                  		<option value="" <cfif attributes.type eq ''>selected</cfif>><cf_get_lang dictionary_id='823.Palet Türü'></option>
                      	<option value="1" <cfif attributes.type eq 1>selected</cfif>><cf_get_lang dictionary_id='820.Standart Paket'></option>
                        <option value="2" <cfif attributes.type eq 2>selected</cfif>><cf_get_lang dictionary_id='821.Özel Paket'></option>
                        <option value="3" <cfif attributes.type eq 3>selected</cfif>><cf_get_lang dictionary_id='822.Lokasyon Paleti'></option>
                        <option value="4" <cfif attributes.type eq 4>selected</cfif>><cf_get_lang dictionary_id='59323.Loat Bazında'> <cf_get_lang dictionary_id='37244.Palet'></option>
                  	</select>
                </div>
           		<div class="form-group medium">
                	<select name="oby" id="oby" style="width:100px;">
                     	<option value="0" <cfif attributes.oby eq 0>selected</cfif>><cf_get_lang dictionary_id ='58924.Sıralama'></option>
                        <option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id='823.Palet Türü'></option>
                      	<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></option>
                       	
             		</select>
              	</div>
                <div class="form-group medium">
                	<select name="status" id="status" style="width:100px;">
                  		<option value="1" <cfif attributes.status eq 1>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                   		<option value="2" <cfif attributes.status eq 2>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                   		<option value="3" <cfif attributes.status eq 3>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                	</select>
              	</div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
          	</cf_box_search>
            <cf_box_search_detail>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="item-member_name">
                  		<label class="col col-12"><cf_get_lang dictionary_id ='57519.Cari Hesap'></label>
                        <div class="input-group">
							<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                            <input type="hidden" name="company_id"  id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                            <input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                            <input type="text" name="member_name"   id="member_name" style="width:100px;height:20px" placeholder=""  value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" autocomplete="off">
                            <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=search_list.consumer_id&field_comp_id=search_list.company_id&field_member_name=search_list.member_name&field_type=search_list.member_type&select_list=7,8&keyword='+encodeURIComponent(document.search_list.member_name.value),'list');"></span>
                        </div>      
                    </div>
                    <div class="form-group" id="item-product_cat">
                        <label class="col col-12"><cf_get_lang dictionary_id ='57486.Kategori'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="product_cat_code" id="product_cat_code" value="<cfif len(attributes.product_cat)><cfoutput>#attributes.product_cat_code#</cfoutput></cfif>">
                                <input type="hidden" name="product_catid" id="product_catid" value="<cfoutput>#attributes.product_catid#</cfoutput>">
                                <cfinput type="text" name="product_cat" id="product_cat" style="width:110px;" value="#attributes.product_cat#" onFocus="AutoComplete_Create('product_cat','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID','product_catid','','3','200');">
                                <span class="input-group-addon icon-ellipsis btnPointer" title="Kategori Ekle" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&field_code=search_list.product_cat_code&is_sub_category=1&field_id=search_list.product_catid&field_name=search_list.product_cat');"></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-product_name">
                        <label class="col col-12"><cf_get_lang dictionary_id='57657.Ürün'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="stock_id" id="stock_id" value="<cfoutput>#attributes.stock_id#</cfoutput>">
                                <input type="hidden" name="product_id" id="product_id" value="<cfoutput>#attributes.product_id#</cfoutput>">
                                <input type="text"   name="product_name"  id="product_name"   value="<cfoutput>#attributes.product_name#</cfoutput>" passthrough="readonly=yes" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE,','get_product_autocomplete','0','PRODUCT_ID,STOCK_ID','product_id,stock_id','','3','225');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="spect_remove();windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=search_list.stock_id&product_id=search_list.product_id&field_name=search_list.product_name&keyword='+encodeURIComponent(document.search_list.product_name.value),'list');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-spect_name">
                        <label class="col col-12"><cf_get_lang dictionary_id='57647.Spec'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="spect_main_id" id="spect_main_id" value="<cfoutput>#attributes.spect_main_id#</cfoutput>">
                                <input type="text" name="spect_name" id="spect_name" value="<cfoutput>#attributes.spect_name#</cfoutput>" style="width:110px;">
                                <span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="product_control();"></span>
                            </div>
                        </div>
                    </div>
               	</div>
			</cf_box_search_detail>	          	
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='37244.Palet'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th width="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th style="width:70px;"><cf_get_lang dictionary_id='57633.Barkod'></th>
                    <th style="width:70px;"><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                    <th style="width:70px;"><cf_get_lang dictionary_id='45254.Raf No'></th>
                    <th style="width:70px;"><cf_get_lang dictionary_id='41701.Lot No'></th>
                    <cfif attributes.list_type eq 2>
                    	<th style="text-align:left"><cf_get_lang dictionary_id ='58221.Ürün Adı'></th>
                        <th style="width:70px;"><cf_get_lang dictionary_id ='57637.Seri No'></th>
                        <th style="width:70px;"><cf_get_lang dictionary_id ='57635.Miktar'></th>
                        <th style="width:70px;"><cf_get_lang dictionary_id ='57647.Spekt'></th>
                    <cfelse>
                    	<th><cf_get_lang dictionary_id ='57519.Cari Hesap'></th>
                        <th style="width:100px;"><cf_get_lang dictionary_id='823.Palet Türü'></th>
                        <th style="width:60px;"><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
                        <th style=""><cf_get_lang dictionary_id='57629.Açıklama'></th>
                        <th style="width:25px" class="header_icn_none">
                          	<input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
                     	</th>
                    </cfif>
                    <!-- sil -->
            			<th width="20" class="header_icn_none">
                        	<a href="<cfoutput>#request.self#?fuseaction=sales.list_ezgi_packingS&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
            			</th>
                   	<!-- sil -->
              	</tr>
         	</thead>
          	<tbody>
            	<cfif get_packings.recordcount>
                	<!---<cfdump var="#get_packings#">--->
                    <cfoutput query="get_packings">
                        <tr>
                            <td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center"><a href="#request.self#?fuseaction=sales.list_ezgi_packingS&event=upd&packing_id=#PACKING_ID#" class="tableyazi">#BARCODE#</a></td>
                          	<td style="text-align:center" nowrap>#ORDER_NUMBER#</td>
                            <td style="text-align:center">#SHELF_CODE#</td>
                            <td 
                            	<cfif (attributes.list_type eq 2 and D_ORDER_ID neq 0 and not len(ORDER_NUMBER) and len(I_LOT_NO))>
                                	style="text-align:center;background-color:red;color:white" title="Üretim Siparişe Bağlanmış - Palet Siparişe Bağlanmamış" 
                              	<cfelseif (attributes.list_type eq 2 and D_ORDER_ID eq 0 and not len(ORDER_ID) and len(I_LOT_NO) and type neq 1)>
                                	style="text-align:center;background-color:blue;color:white" title="Üretim Siparişe Bağlanmamış - Palet Siparişe Bağlanmış"
                                <cfelseif (attributes.list_type eq 2 and D_ORDER_ID neq ORDER_ID and len(I_LOT_NO) and type neq 1)>
                                	style="text-align:center;background-color:orange;color:white" title="Üretim Farklı Siparişe Bağlanmış" 
                                </cfif>
                            >
								<cfif attributes.list_type eq 2>
                            		#I_LOT_NO#
                               	<cfelse>
									<cfif type eq 4>
                                    	#LOT_NO#
                                  	</cfif>
                             	</cfif>
                          	</td>
                            <cfif attributes.list_type eq 2>
                            	<td style="text-align:left">#PRODUCT_NAME#</td>
                                <td style="text-align:center">#SERIAL_NO#</td>
                                <td style="text-align:center">#AMOUNT#</td>
                                <td style="text-align:center">#SPECT_MAIN_ID#</td>
                            <cfelse>
                                <td>#UNVAN#</td>
                                <td>
                                    <cfif type eq 1><cf_get_lang dictionary_id='820.Standart Paket'></cfif>
                                    <cfif type eq 2><cf_get_lang dictionary_id='821.Özel Paket'></cfif>
                                    <cfif type eq 3><cf_get_lang dictionary_id='822.Lokasyon Paleti'></cfif>
                                    <cfif type eq 4><cf_get_lang dictionary_id='59323.Loat Bazında'> <cf_get_lang dictionary_id='37244.Palet'></cfif>
                                </td>
                                <td>#DateFormat(RECORD_DATE,dateformat_style)#</td>
                                <td>#detail#</td>
                            </cfif>
                            <!-- sil -->
                            <cfif attributes.list_type eq 1>
                                <td style="text-align:center;">
                                	<input type="checkbox" name="select_production" value="#packing_id#">
                                </td>
                            </cfif>
                            <td style="text-align:center;">
                           		<a href="#request.self#?fuseaction=sales.list_ezgi_packingS&event=upd&packing_id=#PACKING_ID#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                          	</td>
                            <!-- sil -->
                        </tr>
                    </cfoutput>
                    <cfif attributes.list_type eq 1>
                    	<tr>
                        	<td colspan="20" style="text-align:right">
                            	<button name="yazdir" onclick="grupla();">Toplu Yazdır</button>
                            
                            </td>
                        </tr>
                    </cfif>
            	<cfelse>
               		<tr> 
                    	<td colspan="10" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                 	</tr>
             	</cfif>
         	</tbody>
      	</cf_grid_list>
        <cfset adres = url.fuseaction>
        <cfif len(attributes.keyword)>
        	<cfset adres = "#adres#&keyword=#attributes.keyword#">
        </cfif>
        <cfif len(attributes.oby)>
        	<cfset adres = "#adres#&oby=#attributes.oby#">
        </cfif>
        <cfif len(attributes.status)>
        	<cfset adres = "#adres#&status=#attributes.status#">
        </cfif>
        <cfif len(attributes.type)>
        	<cfset adres = "#adres#&type=#attributes.type#">
        </cfif>
        <cfif len(attributes.list_type)>
        	<cfset adres = "#adres#&list_type=#attributes.list_type#">
        </cfif>
        <cfif len(attributes.spect_name)>
        	<cfset adres = "#adres#&spect_name=#attributes.spect_name#&spect_main_id=#attributes.spect_main_id#">
        </cfif>
        <cfif len(attributes.product_name)>
        	<cfset adres = "#adres#&product_name=#attributes.product_name#&product_id=#attributes.product_id#&stock_id=#attributes.stock_id#">
        </cfif>
        <cfif len(attributes.product_cat)>
        	<cfset adres = "#adres#&product_cat=#attributes.product_cat#&product_catid=#attributes.product_catid#&product_cat_code=#attributes.product_cat_code#">
        </cfif>
        <cfif len(attributes.member_name)>
        	<cfif len(consumer_id)>		
        		<cfset adres = "#adres#&consumer_id=#attributes.consumer_id#">
            </cfif>
            <cfif len(company_id)>		
        		<cfset adres = "#adres#&company_id=#attributes.company_id#">
            </cfif>
        </cfif>
        <cf_paging 
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#&is_submitted=1">
    </cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;
	}
	function product_control()/*Ürün seçmeden spect seçemesin.*/
	{
		if(document.search_list.stock_id.value=="" || document.search_list.product_name.value=="" )
		{
		alert("<cf_get_lang dictionary_id ='36828.Spect Seçmek için öncelikle ürün seçmeniz gerekmektedir'>");
		return false;
		}
		else
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_spect_main&field_main_id=search_list.spect_main_id&field_name=search_list.spect_name&is_display=1&stock_id='+document.search_list.stock_id.value,'list');
	}
	function spect_remove()/*Eğer ürün seçildikten sonra spect seçilmişse yeniden ürün seçerse ilgili spect'i kaldır.*/
	{
		document.search_list.spect_main_id.value = "";
		document.search_list.spect_name.value = "";	
	}
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
			packing_id_list = '';
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

						packing_id_list +=my_objets.value+',';
				}
			}
			packing_id_list = packing_id_list.substr(0,packing_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(packing_id_list!='')
			{
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_print_files&print_type=78&iid='+packing_id_list,'wide');
			}
	}

</script>