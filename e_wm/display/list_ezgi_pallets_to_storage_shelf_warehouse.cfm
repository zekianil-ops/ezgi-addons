<cfset fuseaction_ = ListGetAt(attributes.fuseaction,2,'.')>
<cfparam name="attributes.oby" default="2">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.collect_type" default="">
<cfparam name="attributes.first_shelf_id" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.process_status" default="2">
<cfquery name="packing_size_type" datasource="#dsn3#">
	SELECT PACKING_SIZE_TYPE_ID, PACKING_SIZE_TYPE_CODE + ' - ' + PACKING_SIZE_TYPE_NAME AS PACKING_SIZE_TYPE_NAME FROM EZGI_WM_SETUP_PACKING_SIZE_TYPE ORDER BY PACKING_SIZE_TYPE_CODE DESC
</cfquery>
<cfquery name="first_shelf" datasource="#dsn3#">
	SELECT PRODUCT_PLACE_ID, SHELF_CODE FROM PRODUCT_PLACE WHERE SHELF_TYPE = 4 AND PLACE_STATUS = 1 ORDER BY SHELF_CODE
</cfquery>
<cfoutput query="first_shelf">
	<cfset 'SHELF_CODE_#PRODUCT_PLACE_ID#' = SHELF_CODE>
</cfoutput>
<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
	  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_pallets.recordcount=0;
	get_pallets.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_pallet_list_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_pallets_to_storage_shelf_warehouse");
		get_pallet_list_action.dsn3 = dsn3;
		get_pallet_list_action.dsn_alias = dsn_alias;
		get_pallets = get_pallet_list_action.get_pallets_
		(
		 	dsn_alias : '#dsn_alias#',
			process_status : '#iif(isdefined("attributes.process_status"),"attributes.process_status",DE(""))#',
			collect_type : '#iif(isdefined("attributes.collect_type"),"attributes.collect_type",DE(""))#',
			first_shelf_id : '#iif(isdefined("attributes.first_shelf_id"),"attributes.first_shelf_id",DE(""))#',
			list_type : '#iif(isdefined("attributes.list_type"),"attributes.list_type",DE(""))#',
			oby : '#iif(isdefined("attributes.oby"),"attributes.oby",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#'
		);
		arama_yapilmali=0;
		}
	else
	{
		arama_yapilmali=1;
	}
</cfscript>
<cfparam name="attributes.totalrecords" default='#get_pallets.query_count#'>
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
                	<select name="first_shelf_id" id="first_shelf_id">
                    	<option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                      	<cfoutput query="first_shelf">
                         	<option value="#PRODUCT_PLACE_ID#" <cfif attributes.first_shelf_id eq first_shelf.PRODUCT_PLACE_ID>selected</cfif>>#first_shelf.SHELF_CODE#</option>
                      	</cfoutput>
           			</select>
                </div>
                <div class="form-group medium">
                	<select name="collect_type" id="collect_type">
                    	<option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                      	<cfoutput query="packing_size_type">
                         	<option value="#PACKING_SIZE_TYPE_ID#" <cfif attributes.collect_type eq packing_size_type.PACKING_SIZE_TYPE_ID>selected</cfif>>#packing_size_type.PACKING_SIZE_TYPE_NAME#</option>
                      	</cfoutput>
           			</select>
                </div>
           		<div class="form-group medium">
                	<select name="oby" id="oby" style="width:100px;">
                     	<option value="0" <cfif attributes.oby eq 0>selected</cfif>><cf_get_lang dictionary_id ='58924.Sıralama'></option>
                        <option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id='823.Palet Türü'></option>
                      	<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></option>
             		</select>
              	</div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
          	</cf_box_search>
            <cf_box_search_detail>
                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
                </div>
			</cf_box_search_detail>	
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='1311.Stoklama Rafına Transfer İşlemi'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th width="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th style="width:70px;"><cf_get_lang dictionary_id='57633.Barkod'></th>
                    <th style="width:70px;"><cf_get_lang dictionary_id='352.Giriş Rafı'></th>
                    <cfif attributes.list_type eq 2>
                        <th style="width:70px;"><cf_get_lang dictionary_id ='57637.Seri No'></th>
                    <cfelse>
                        <th style="width:100px;"><cf_get_lang dictionary_id='823.Palet Türü'></th>
                    </cfif>
                    <th style="width:100px;"><cf_get_lang dictionary_id='57655.Başlama Tarihi'></th>
                    <!-- sil -->
                    <th style="width:25px" class="header_icn_none">
                    	<span style="display:none">
                      	<a href="<cfoutput>#request.self#?fuseaction=stock.list_ezgi_pallets_to_storage_shelf_warehouse&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
                        </span>
            		</th>
                   	<!-- sil -->
              	</tr>
         	</thead>
          	<tbody>
            	<cfif get_pallets.recordcount>
                	
                    <cfoutput query="get_pallets">
                        <tr height="25px">
                            <td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">#BARCODE#</td>
                          	<td style="text-align:center"><cfif isdefined('SHELF_CODE_#SHELF_NUMBER#')>#Evaluate('SHELF_CODE_#SHELF_NUMBER#')#</cfif></td>
                            <cfif attributes.list_type eq 2>
                                <td style="text-align:center">#SERIAL_NO#</td>
                            <cfelse>
                                <td>#SHELF_SIZE_TYPE_CODE#</td>
                            </cfif>
                            <td style="text-align:center" nowrap>#DateFormat(UPDATE_DATE,dateformat_style)# #TimeFormat(UPDATE_DATE,'hh:mm')#</td>
                            <!-- sil -->
                            <td style="text-align:center; width:25px; color:red">
                           		<cfif IS_KARMA>(*)</cfif>
                          	</td>
                            <!-- sil -->
                        </tr>
                    </cfoutput>
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
        <cfif len(attributes.process_status)>
        	<cfset adres = "#adres#&process_status=#attributes.process_status#">
        </cfif>
        <cfif len(attributes.collect_type)>
        	<cfset adres = "#adres#&type=#attributes.collect_type#">
        </cfif>
        <cfif len(attributes.list_type)>
        	<cfset adres = "#adres#&list_type=#attributes.list_type#">
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
</script>