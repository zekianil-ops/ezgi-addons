<!---
    File: add_ezgi_prod_order_rework.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/09/2025
    Description:
--->
<cfparam name="attributes.keyword" default="">
<cfquery name="get_master_plan_sablon" datasource="#dsn3#">
	SELECT SHIFT_ID FROM EZGI_MASTER_PLAN_SABLON WHERE PROCESS_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.islem_id#">
</cfquery>
<cfif isdefined("attributes.is_form_submitted") and get_master_plan_sablon.recordcount>
	<cfquery name="get_production_order_demand" datasource="#dsn3#">
    	SELECT 
        	PO.P_ORDER_ID, 
            PO.STOCK_ID, 
          	PO.STATION_ID, 
            PO.QUANTITY, 
            PO.STATUS, 
            PO.PROJECT_ID, 
            PO.P_ORDER_NO, 
            PO.IS_STOCK_RESERVED, 
            PO.LOT_NO, 
            PO.SPEC_MAIN_ID, 
            PO.IS_GROUP_LOT, 
            PO.RECORD_EMP, 
            PO.RECORD_DATE, 
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME,
            W.STATION_NAME
		FROM     
        	PRODUCTION_ORDERS AS PO INNER JOIN
            STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID INNER JOIN
            WORKSTATIONS AS W ON PO.STATION_ID = W.STATION_ID
		WHERE  
        	PO.IS_STAGE = - 1 AND 
            PO.PRODUCTION_LEVEL = N'0' AND 
            PO.STATION_ID IN
                      		(
                            	SELECT 
                                	WORKSTATION_ID
                       			FROM      
                                	EZGI_MASTER_PLAN_SABLON
                       			WHERE   
                                	SHIFT_ID = #get_master_plan_sablon.SHIFT_ID#
                        	) AND 
        	PO.STATUS = 1 AND 
            PO.IS_DEMONTAJ = 0
            <cfif isdefined('attributes.keyword') and len(attributes.keyword)>
            	(
                	S.PRODUCT_NAME LIKE '#attributes.keyword#%' OR
                	S.PRODUCT_CODE LIKE '#attributes.keyword#%' OR
                    PO.LOT_NO LIKE '#attributes.keyword#%'
                ) AND
            </cfif>
    	ORDER BY 
            S.PRODUCT_NAME
    </cfquery>
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_production_order_demand.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>


<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_production_order_demand.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
        	<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
         	<cfinput name="islem_id" id="islem_id" type="hidden" value="#attributes.islem_id#">
            <cfinput name="master_alt_plan_id" id="master_alt_plan_id" type="hidden" value="#attributes.master_alt_plan_id#">
            <cf_box_search>
                    <div class="form-group"  id="item-keyword">
                        <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                         <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
                    </div>
                    <div class="form-group small">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                        <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                    </div>
                    <div class="form-group">
                        <cf_wrk_search_button search_function='input_control()' button_type="4">
                    </div>
          	</cf_box_search>
      	</cfform>
   		<cfsavecontent variable="title">Talepler</cfsavecontent>
    	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
                    <cf_grid_list>   
                        <thead>
                            <tr valign="middle">
                                <th style="width:25px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                                <th style="width:80px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='29474.Emir No'></th>
                                <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58800.Ürün Kodu'></th>
                                <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                <th style="width:80px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57635.Miktar'></th>
                                <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58834.İstasyon'></th>
                                <th style="width:80px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57627.Kayıt Tarihi'></th>
                                <th style="width:80px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57899.Kaydeden'></th>
                                <th style="width:80px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='45498.Lot No'></th>
                                <!-- sil -->
                                <th style="width:25px; text-align:center; vertical-align:middle" class="header_icn_none" >
                                	<input type="checkbox" alt="<cf_get_lang dictionary_id ='206.Hepsini Seç'>" onClick="grupla(-1);">
                                </th>
                                <!-- sil -->
                            </tr>
                        </thead>
                        <tbody>
                            <cfif get_production_order_demand.recordcount>
                                <cfoutput query="get_production_order_demand" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
									<tr>
                                        <td style="text-align:right;" nowrap="nowrap">#CURRENTROW#</td>
                                        <td style="text-align:center;" nowrap="nowrap">#P_ORDER_NO#</td>
                                        <td style="text-align:center;" nowrap="nowrap">#PRODUCT_CODE#</td>
                                        <td style="text-align:left;" nowrap="nowrap">#PRODUCT_NAME#</td>
                                        <td style="text-align:right;" nowrap="nowrap">#AmountFormat(QUANTITY)#</td>
                                        <td style="text-align:left;" nowrap="nowrap">#STATION_NAME#</td>
                                        <td style="text-align:center;" nowrap="nowrap">#DateFormat(RECORD_DATE,dateformat_style)#</td>
                                        <td style="text-align:left;" nowrap="nowrap">#get_emp_info(RECORD_EMP,0,0)# </td>
                                        <td style="text-align:center;" nowrap="nowrap">#LOT_NO#</td>
                                        <!-- sil -->
                                		<td style="text-align:center;"><input type="checkbox" name="select_production" value="#LOT_NO#"></td>
                                        <!-- sil -->
                                 	</tr>
                                </cfoutput>
                                <tr>
                                	<td colspan="10" style="text-align:right; font-weight:bold">
                                    	<a style="cursor:pointer" onclick="grupla(-2);">
                                        	<cfif isdefined('attributes.master_alt_plan_id') and len(attributes.master_alt_plan_id)>
                                    			<button name="onay" id="onay" style="background-color:silver; width:250px; height:25px">Üretim Emrine Transfer Et</button>
                                            </cfif>
                                        </a>
                                    </td>
                                </tr>
							<cfelse>
                            	<tr> 
                                    <td colspan="10" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                                </tr>
                            </cfif>
                     	</tbody>
                 	</cf_grid_list>
       	</cf_box>
     		<cfset adres = url.fuseaction>
            <cfif len(attributes.keyword)>
               	<cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
       		</cfif>
         	<cf_paging 
                        page="#attributes.page#"
                        maxrows="#attributes.maxrows#"
                        totalrecords="#attributes.totalrecords#"
                        startrow="#attributes.startrow#"
                        adres="#adres#&is_form_submitted=1">
        
		
   	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function grupla(type)
	{
		
		p_order_lot_list= '';
		chck_leng = document.getElementsByName('select_production').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_production[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_production;
			if(type == -1){//hepsini seç denilmişse	
				if(my_objets.checked == true)
					my_objets.checked = false;
				else
					my_objets.checked = true;
			}
			else
			{
				if(my_objets.checked == true)
					p_order_lot_list+=my_objets.value+',';
			}
		}
		if(type == -2)
		{
			p_order_lot_list = p_order_lot_list.substr(0,p_order_lot_list.length-1);//sondaki virgülden kurtarıyoruz.
			
			if(list_len(p_order_lot_list))
			{
				document.getElementById('onay').disabled = true;
				
					window.location='<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_prod_order_rework&master_alt_plan_id=#attributes.master_alt_plan_id#&islem_id=#attributes.islem_id#</cfoutput>&p_order_lot_list='+p_order_lot_list;
					document.getElementById('onay').disabled = false;
				
			}
			else
				alert("Üretim Emrine Transfer Etmek İstediğiniz Talepleri Seçiniz!")
		}		
	}
	function input_control()
	{
		return true;		
	}
</script>