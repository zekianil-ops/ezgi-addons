<!---
    File: list_ezgi_iflow_production_order_parti.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/12/2024
    Description:
--->
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.sort_type" default="2">
<cfparam name="attributes.search_master_plan_id" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfset attributes.start_date = ''>
</cfif>

<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
	<cf_date tarih="attributes.finish_date">
<cfelse>
	<cfset attributes.finish_date = ''>
</cfif>
<cfquery name="get_master_plan" datasource="#dsn3#">
    SELECT DISTINCT 
        EIM.MASTER_PLAN_ID, 
        EIM.MASTER_PLAN_NUMBER, 
        EIM.MASTER_PLAN_DETAIL
    FROM            
        EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) INNER JOIN
        EZGI_IFLOW_PRODUCTION_ORDERS AS EIPO WITH (NOLOCK) ON EIM.MASTER_PLAN_ID = EIPO.MASTER_PLAN_ID INNER JOIN
        EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPOP WITH (NOLOCK) ON EIPO.REL_P_ORDER_ID = EIPOP.P_ORDER_PARTI_ID INNER JOIN
        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EIPO.LOT_NO = PO.LOT_NO INNER JOIN
        EZGI_IFLOW_MASTER_PLAN AS EI WITH (NOLOCK) ON EIM.MASTER_PLAN_CAT_ID = EI.MASTER_PLAN_CAT_ID AND EIM.MASTER_PLAN_PROCESS = EI.MASTER_PLAN_PROCESS
    WHERE        
        EIM.MASTER_PLAN_STATUS = 1 AND 
        <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
       	 	EI.MASTER_PLAN_ID = #attributes.master_plan_id# AND 
            EIM.MASTER_PLAN_ID <> #attributes.master_plan_id# AND
        </cfif>
        PO.IS_STAGE <> 2
    ORDER BY 
        EIM.MASTER_PLAN_NUMBER
</cfquery>
<cfif isdefined("attributes.is_form_submitted")>
	<cfquery name="get_production_order_parti" datasource="#dsn3#">
    	SELECT DISTINCT 
            EIM.MASTER_PLAN_ID, 
            EIPOP.P_ORDER_PARTI_ID, 
            EIPOP.P_ORDER_PARTI_NUMBER, 
            EIM.MASTER_PLAN_NUMBER, 
            EIM.MASTER_PLAN_NAME, 
            EIM.MASTER_PLAN_DETAIL, 
            EIPOP.P_ORDER_PARTI_DETAIL, 
            EIM.MASTER_PLAN_PROCESS, 
            EIM.IS_PROCESS, 
            EIM.MASTER_PLAN_STATUS, 
            EIM.MASTER_PLAN_START_DATE, 
            EIM.MASTER_PLAN_FINISH_DATE
        FROM            
            EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS AS EIPO WITH (NOLOCK) ON EIM.MASTER_PLAN_ID = EIPO.MASTER_PLAN_ID INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPOP WITH (NOLOCK) ON EIPO.REL_P_ORDER_ID = EIPOP.P_ORDER_PARTI_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EIPO.LOT_NO = PO.LOT_NO INNER JOIN
            EZGI_IFLOW_MASTER_PLAN AS EI WITH (NOLOCK) ON EIM.MASTER_PLAN_CAT_ID = EI.MASTER_PLAN_CAT_ID AND EIM.MASTER_PLAN_PROCESS = EI.MASTER_PLAN_PROCESS
        WHERE        
            EIM.MASTER_PLAN_STATUS = 1 AND 
            <cfif isdefined('attributes.keyword') and len(attributes.keyword)>
            	(
                	EIM.MASTER_PLAN_NUMBER LIKE '#attributes.keyword#%' OR
                	EIM.MASTER_PLAN_DETAIL LIKE '#attributes.keyword#%' OR
                    EIPOP.P_ORDER_PARTI_NUMBER LIKE '#attributes.keyword#%'
                ) AND
            </cfif>
            <cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
            	EI.MASTER_PLAN_ID = #attributes.master_plan_id# AND 
                EIM.MASTER_PLAN_ID <> #attributes.master_plan_id# AND
            </cfif>
            <cfif isdefined('attributes.search_master_plan_id') and len(attributes.search_master_plan_id)>
            	EIM.MASTER_PLAN_ID = #attributes.search_master_plan_id# AND
            </cfif>
            PO.IS_STAGE <> 2
        ORDER BY 
            EIM.MASTER_PLAN_START_DATE
    </cfquery>
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_production_order_parti.recordcount = 0>
    <cfset arama_yapilmali = 1>
</cfif>


<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_production_order_parti.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
        	<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cfif len(attributes.master_plan_id)>
                <cfinput name="master_plan_id" id="master_plan_id" type="hidden" value="#attributes.master_plan_id#">
         	</cfif>
            <cf_box_search>
                    <div class="form-group"  id="item-keyword">
                        <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                         <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
                    </div>
                    <div class="form-group medium" id="item-master_plan_id">
                        <select name="search_master_plan_id">
                            <cfoutput query="get_master_plan">
                                <option value="#MASTER_PLAN_ID#" <cfif attributes.search_master_plan_id eq MASTER_PLAN_ID>selected</cfif>>#MASTER_PLAN_NUMBER# - #MASTER_PLAN_DETAIL#</option>
                            </cfoutput>
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
      	</cfform>
   		<cfsavecontent variable="title">Partiler</cfsavecontent>
    	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
                    <cf_grid_list>   
                        <thead>
                            <tr valign="middle">
                                <th style="width:25px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                                <th style="width:80px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='695.Plan No'></th>
                                <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57629.Açıklama'></th>
                                <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'> - <cf_get_lang dictionary_id='57700.Bitiş Tarihi'></th>
                                <th style="width:80px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36528.Parti No'></th>
                                <!-- sil -->
                                <th style="width:25px; text-align:center; vertical-align:middle" class="header_icn_none" >
                                	<input type="checkbox" alt="<cf_get_lang dictionary_id ='206.Hepsini Seç'>" onClick="grupla(-1);">
                                </th>
                                <!-- sil -->
                            </tr>
                        </thead>
                        <tbody>
                            <cfif get_production_order_parti.recordcount>
                                <cfoutput query="get_production_order_parti" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
									<tr>
                                        <td style="text-align:right; font-weight:bold" nowrap="nowrap">#CURRENTROW#</td>
                                        <td style="text-align:center; font-weight:bold" nowrap="nowrap">#MASTER_PLAN_NUMBER#</td>
                                        <td style="text-align:center; font-weight:bold" nowrap="nowrap">#MASTER_PLAN_DETAIL#</td>
                                        <td style="text-align:center; font-weight:bold" nowrap="nowrap">#DateFormat(MASTER_PLAN_START_DATE,dateformat_style)# - #DateFormat(MASTER_PLAN_FINISH_DATE,dateformat_style)#</td>
                                        <td style="text-align:center; font-weight:bold" nowrap="nowrap">#P_ORDER_PARTI_NUMBER#</td>
                                        <!-- sil -->
                                		<td style="text-align:center;"><input type="checkbox" name="select_production" value="#P_ORDER_PARTI_ID#"></td>
                                        <!-- sil -->
                                 	</tr>
                                </cfoutput>
                                <tr>
                                	<td colspan="6" style="text-align:right; font-weight:bold">
                                    	<a style="cursor:pointer" onclick="grupla(-2);">
                                        	<cfif isdefined('attributes.search_master_plan_id') and len(attributes.search_master_plan_id)>
                                    			<button name="onay" id="onay" style="background-color:silver; width:150px; height:25px">Transfer Et</button>
                                            </cfif>
                                        </a>
                                    </td>
                                </tr>
							<cfelse>
                            	<tr> 
                                    <td colspan="6" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
                                </tr>
                            </cfif>
                     	</tbody>
                 	</cf_grid_list>
       	</cf_box>
     		<cfset adres = url.fuseaction>
            <cfif len(attributes.keyword)>
               	<cfset adres = '#adres#&keyword=#URLEncodedFormat(attributes.keyword)#'>
       		</cfif>
         	<cfif len(attributes.sort_type)>
         		<cfset adres = '#adres#&sort_type=#attributes.sort_type#'>
           	</cfif>
         	<cfif len(attributes.master_plan_id)>
             	<cfset adres = '#adres#&master_plan_id=#attributes.master_plan_id#'>
         	</cfif>
            <cfif len(attributes.search_master_plan_id)>
           		<cfset adres = '#adres#&search_master_plan_id=#attributes.search_master_plan_id#'>
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
		
		var master_plan_id=document.getElementById('master_plan_id').value;
		iflow_parti_list= '';
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
					iflow_parti_list+=my_objets.value+',';
			}
		}

		iflow_parti_list = iflow_parti_list.substr(0,iflow_parti_list.length-1);//sondaki virgülden kurtarıyoruz.

		if(list_len(iflow_parti_list))
		{
			document.getElementById('onay').disabled = true;
			if(type == -2)
			{
				window.location='<cfoutput>#request.self#?fuseaction=prod.emptypopup_trf_ezgi_iflow_production_order_parti</cfoutput>&iflow_parti_list='+iflow_parti_list+'&master_plan_id='+master_plan_id;
				document.getElementById('onay').disabled = false;
			}
		}
		else
			alert("Transfer Etmek İstediğiniz Partileri Seçiniz!")
	}
	function input_control()
	{
		return true;		
	}
</script>