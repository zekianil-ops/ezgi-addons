<cfset fuseaction_ = ListGetAt(attributes.fuseaction,2,'.')>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.collect_type" default="">
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID
	FROM     
    	EZGI_WM_SETUP_ROW
	WHERE  
    	EMPLOYEE_POSITION_ID = #session.ep.POSITION_CODE#
</cfquery>
<cfif not get_default_departments.recordcount or not len(get_default_departments.SHELF_WAREHOUSE)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfparam name="attributes.depo" default="#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#">

<cfquery name="packing_size_type" datasource="#dsn3#">
	SELECT PACKING_SIZE_TYPE_ID, PACKING_SIZE_TYPE_CODE + ' - ' + PACKING_SIZE_TYPE_NAME AS PACKING_SIZE_TYPE_NAME FROM EZGI_WM_SETUP_PACKING_SIZE_TYPE ORDER BY PACKING_SIZE_TYPE_CODE DESC
</cfquery>

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
		get_pallet_list_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_pallets_to_collect_shelf_warehouse");
		get_pallet_list_action.dsn3 = dsn3;
		get_pallet_list_action.dsn_alias = dsn_alias;
		get_pallets = get_pallet_list_action.get_pallets_
		(
		 	dsn_alias : '#dsn_alias#',
			collect_type : '#iif(isdefined("attributes.collect_type"),"attributes.collect_type",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			depo : '#IIf(IsDefined("attributes.depo"),"attributes.depo",DE(""))#',
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
                	<select name="collect_type" id="collect_type">
                    	<option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                      	<cfoutput query="packing_size_type">
                         	<option value="#PACKING_SIZE_TYPE_ID#" <cfif attributes.collect_type eq packing_size_type.PACKING_SIZE_TYPE_ID>selected</cfif>>#packing_size_type.PACKING_SIZE_TYPE_NAME#</option>
                      	</cfoutput>
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
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='1313.Toplama Rafına Transfer İşlemi'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th style="width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th><cf_get_lang dictionary_id='1312.Palet Barkod'></th>
                    <th><cf_get_lang dictionary_id='43312.Çıkış Rafı'></th>
                    <th><cf_get_lang dictionary_id='352.Giriş Rafı'></th>
                    <th><cf_get_lang dictionary_id='1305.Palet Tip'></th>
                    <th><cf_get_lang dictionary_id='45925.Raf Tip'></th>
                    <!-- sil -->
                    <th style="width:25px; display:none" class="header_icn_none">
                      	<a href="<cfoutput>#request.self#?fuseaction=stock.list_ezgi_pallets_to_collect_shelf_warehouse&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
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
                          	<td style="text-align:center">#NEW_SHELF_CODE#</td>
                            <td style="text-align:center">#SHELF_CODE#</td>
                            <td style="text-align:center">#PACKING_SIZE_TYPE_CODE#</td>
                            <td style="text-align:center">#SHELF_SIZE_TYPE_CODE#</td>
                            <!-- sil -->
                            <td style="text-align:center; display:none">
                           		
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
        <cfif len(attributes.collect_type)>
        	<cfset adres = "#adres#&type=#attributes.collect_type#">
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