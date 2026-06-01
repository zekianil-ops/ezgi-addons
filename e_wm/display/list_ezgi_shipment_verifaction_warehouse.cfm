<cfset fuseaction_ = ListGetAt(attributes.fuseaction,2,'.')>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.collect_type" default="">
<cfif isdefined("attributes.date2") and isdate(attributes.date2)>
  <cf_date tarih="attributes.date2">
  <cfelse>
  <cfset attributes.date2 = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.date1") and isdate(attributes.date1)>
  <cf_date tarih="attributes.date1">
  <cfelse>
  <cfset attributes.date1 = wrk_get_today()>
</cfif>
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID,
        SHIPMENT_WAREHOUSE
	FROM     
    	EZGI_WM_SETUP_ROW
	WHERE  
    	EMPLOYEE_POSITION_ID = #session.ep.POSITION_CODE#
</cfquery>
<cfif not get_default_departments.recordcount or not len(get_default_departments.SHELF_WAREHOUSE) or not len(get_default_departments.SHIPMENT_WAREHOUSE)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfparam name="attributes.depo" default="#Replace(get_default_departments.SHIPMENT_WAREHOUSE,',','-')#">

<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
	  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_shipment.recordcount=0;
	get_shipment.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_pallet_list_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_shipment_warehouse");
		get_pallet_list_action.dsn3 = dsn3;
		get_pallet_list_action.dsn_alias = dsn_alias;
		get_shipment = get_pallet_list_action.get_shipment_
		(
		 	dsn_alias : '#dsn_alias#',
			dsn2_alias : '#dsn2_alias#',
			collect_type : '#iif(isdefined("attributes.collect_type"),"attributes.collect_type",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			depo : '#IIf(IsDefined("attributes.depo"),"attributes.depo",DE(""))#',
			date1 : '#IIf(IsDefined("attributes.date1"),"attributes.date1",DE(""))#',
			date2 : '#IIf(IsDefined("attributes.date2"),"attributes.date2",DE(""))#',
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
<cfparam name="attributes.totalrecords" default='#get_shipment.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_list" action="#request.self#?fuseaction=#attributes.fuseaction#" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cf_box_search>
				<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                 	<div class="input-group">
                     	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                      	<cfinput type="text" maxlength="10" name="date1" value="#dateformat(attributes.date1,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                      	<span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                  	</div>
                  	<div class="input-group">
                     	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                     	<cfinput type="text" maxlength="10" name="date2" value="#dateformat(attributes.date2,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                    	<span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
               		</div>
               	</div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="3">
                </div>
          	</cf_box_search>
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='1320.Transfer Doğrulama İşlemi'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th style="width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th><cf_get_lang dictionary_id='57880.Belge No'></th>
                    <th><cf_get_lang dictionary_id='58061.Cari'></th>
                    <th><cf_get_lang dictionary_id='1316.Sevkiyat Alanı'></th>
					<!---<th><cf_get_lang dictionary_id='57201.Kontrol'></th>--->
              	</tr>
         	</thead>
          	<tbody>
            	<cfif get_shipment.recordcount>
                    <cfoutput query="get_shipment">
                        <tr height="35px">
                        	<td style="text-align:right">#currentrow#</td>
                          	<td>
                             	<cfset url_param = "#request.self#?fuseaction=stock.list_ezgi_shipment_verifaction_warehouse&event=add&DELIVER_PAPER_NO=#DELIVER_PAPER_NO#&is_type=#IS_TYPE#&ship_id=#SHIP_RESULT_ID#">
                                <cfif len(SHIPMENT_PRODUCT_PLACE_ID) and AMOUNT gt 0>
									<a href="#url_param#"class="tableyazi">
										#DELIVER_PAPER_NO#
									</a>
                                <cfelse>
                                	#DELIVER_PAPER_NO#
                                </cfif>
                         	</td>
                       		<td>
                             	<cfif IS_TYPE eq 1> 
                                	#left(unvan,25)#<cfif len(unvan) gt 25>...</cfif>
                             	<cfelse>
                                 	#left(DEPARTMENT_HEAD,25)#<cfif len(DEPARTMENT_HEAD) gt 25>...</cfif>
                             	</cfif>      
                         	</td>
                       		<td>#SHELF_CODE#</td>
                          	<!---<td align="center" style="background-color:<cfif AMOUNT eq CONTROL_AMOUNT>red<cfelseif AMOUNT gt 0 and CONTROL_AMOUNT eq 0>orange<cfelseif AMOUNT gt CONTROL_AMOUNT>green<cfelseif AMOUNT lt CONTROL_AMOUNT>black</cfif>;color:white; font-weight:bold">#CONTROL_AMOUNT#/#AMOUNT#</td>--->
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
        <cfif isDefined('attributes.depo') and len(attributes.depo)>
        	<cfset adres = adres & '&depo=' & attributes.depo>
      	</cfif>
        <cfif isDefined('attributes.department_out_id') and len(attributes.department_out_id)>
        	<cfset adres = adres & '&department_out_id=' & attributes.department_out_id>
      	</cfif>
   		<cfif isdate(attributes.date1)>
        	<cfset adres = "#adres#&date1=#dateformat(attributes.date1,dateformat_style)#">
      	</cfif>
    	<cfif isdate(attributes.date2)>
        	<cfset adres = "#adres#&date2=#dateformat(attributes.date2,dateformat_style)#">
     	</cfif>
       	<cfif isDefined('attributes.keyword') and len(attributes.keyword) >
        	<cfset adres = "#adres#&keyword=#attributes.keyword#" >
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