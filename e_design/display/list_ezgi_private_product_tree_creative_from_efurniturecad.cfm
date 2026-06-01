<!---
    File: list_ezgi_private_product_tree_creative_from_efurniturecad.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cfparam name="attributes.oby" default="2">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.status" default="2">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.member_name" default="">

<cfif isdefined('attributes.is_submitted') and len(attributes.is_submitted)>
	<cfset cad_dsn3 = '#dsn#_efurniturecad_#session.ep.company_id#'>
    <cfquery name="list_e_furniturecad" datasource="#cad_dsn3#">
        SELECT DISTINCT
            WRK_ROW_ID
        FROM     
            dbo.WORKCUBE_AUTOCAD_PRODUCT_TREE
        WHERE
            E_DESIGN_MAIN_ROW_ID IS NULL AND
            ISNULL(IS_ACTIVE,0) = 1
    </cfquery>
    <cfif list_e_furniturecad.recordcount> 
    	<cfset e_furniturecad_list = ValueList(list_e_furniturecad.WRK_ROW_ID)>
        <cfquery name="get_e_furniturecad" datasource="#dsn3#">
            SELECT 
                CASE
                    WHEN O.COMPANY_ID IS NOT NULL THEN
                       (
                        SELECT     
                            NICKNAME
                        FROM         
                            #dsn_alias#.COMPANY
                        WHERE     
                            COMPANY_ID = O.COMPANY_ID
                        )
                    WHEN O.CONSUMER_ID IS NOT NULL THEN      
                        (	
                        SELECT     
                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.CONSUMER
                        WHERE     
                            CONSUMER_ID = O.CONSUMER_ID
                        )
                END AS UNVAN,   
                OFR.OFFER_ID, 
                O.OFFER_DATE,
                O.OFFER_NUMBER, 
                O.OFFER_DETAIL, 
                O.CONSUMER_ID, 
                O.COMPANY_ID
            FROM            
                OFFER_ROW AS OFR INNER JOIN
                OFFER AS O ON OFR.OFFER_ID = O.OFFER_ID
            WHERE
            	(
                <cfloop query="list_e_furniturecad">
            		OFR.WRK_ROW_ID = '#list_e_furniturecad.WRK_ROW_ID#' <cfif list_e_furniturecad.recordcount gt list_e_furniturecad.currentrow>OR</cfif>
              	</cfloop>
                )
                <cfif attributes.status gt 1> 
                    <cfif attributes.status eq 2>        
                        AND OFR.OFFER_ID NOT IN
                    <cfelseif attributes.status eq 3>
                        AND OFR.OFFER_ID IN
                    </cfif>
                                 (
                                    SELECT 
                                        DISTINCT ORR.OFFER_ID
                                    FROM            
                                        EZGI_DESIGN_MAIN_ROW AS EMR INNER JOIN
                                        OFFER_ROW AS ORR ON EMR.OFFER_ROW_ID = ORR.OFFER_ROW_ID
                                    WHERE        
                                        NOT (EMR.OFFER_ROW_ID IS NULL)
                                )
                </cfif>
                <cfif len(attributes.company_id) and len(attributes.member_name)>
                    AND COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                </cfif>
                <cfif len(attributes.consumer_id) and len(attributes.member_name)>
                    AND CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">
                </cfif>
                <cfif isdefined('attributes.keyword') and len(attributes.keyword)>
                    AND 
                        (
                            UNVAN LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> OR
                            O.OFFER_NUMBER LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%"> OR
                            O.OFFER_DETAIL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#attributes.keyword#%">
                        )
                </cfif>
            ORDER BY
                O.OFFER_DATE
                <cfif attributes.oby eq 1>
                    asc
                <cfelse>
                    desc
                </cfif>
        </cfquery>
        <cfset arama_yapilmali = 0>
    <cfelse>
    	<cfset arama_yapilmali = 0>
    </cfif>
<cfelse>
	<cfset arama_yapilmali = 1>
	<cfset get_e_furniturecad.recordcount = 0>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfparam name="attributes.totalrecords" default='#get_e_furniturecad.recordcount#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_list" action="#request.self#?fuseaction=prod.popup_list_ezgi_private_product_tree_creative_from_efurniturecad" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
			<cfsavecontent  variable="filtre">
				<cf_get_lang dictionary_id='57460.Filtre'>
			</cfsavecontent>
            <cf_box_search>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filtre#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
           		<div class="form-group medium">
                	<select name="oby" id="oby" style="width:100px;">
                      	<option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id="57925.Artan Tarih"></option>
                       	<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id="57926.Azalan Tarih"></option>
             		</select>
              	</div>
                <div class="form-group medium">
					<div class="input-group">
                    	<input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                      	<input type="hidden" name="company_id"  id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                       	<input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                      	<input type="text" name="member_name"   id="member_name" style="width:110px;height:20px"  value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" autocomplete="off">
                    	<span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars&field_consumer=search_list.consumer_id&field_comp_id=search_list.company_id&field_member_name=search_list.member_name&field_type=search_list.member_type&select_list=7,8&keyword='+encodeURIComponent(document.search_list.member_name.value),'list');"></span>
                    </div>
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
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id="1369.E-Furniture CAD"></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th width="20"><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th style="width:70px;"><cf_get_lang dictionary_id="57880.Teklif No"></th>
                    <th style="width:60px;"><cf_get_lang dictionary_id="46831.Teklif Tarihi"></th>
            		<th><cf_get_lang dictionary_id="57519.Cari Hesap"></th>
                    <th><cf_get_lang dictionary_id="57629.Açıklama"></th>
              	</tr>
         	</thead>
          	<tbody>
            	<cfif get_e_furniturecad.recordcount>
                    <cfoutput query="get_e_furniturecad">
                        <tr>
                            <td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">
                            	<a style="cursor:pointer" onclick="add_e_furniturecad(#OFFER_ID#,'#OFFER_NUMBER#')">
                                	#OFFER_NUMBER#
                               	</a>
                            </td>
                            <td style="text-align:center">#DateFormat(OFFER_DATE,dateformat_style)#</td>
                          	<td>#UNVAN#</td>
                            <td>#OFFER_DETAIL#</td>
                        </tr>
                    </cfoutput>
                    <tfoot>
                        <tr>
                            <td colspan="4" style="text-align:right"><cf_get_lang dictionary_id='58859.Süreç'>*</td>
                            <td style="text-align:left"><cf_workcube_process is_upd='0' process_cat_width='100' is_detail='0'></td>
                        </tr>
                    </tfoot>
            	<cfelse>
               		<tr> 
                    	<td colspan="5" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
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
	function add_e_furniturecad(offer_id,offer_number)
	{
		process_stage = document.getElementById('process_stage').value;
		if(process_stage == '')
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='58859.Süreç'> !");
			document.getElementById('process_stage').focus();
			return false;
		}
		else
		{
			sor = confirm(offer_number+' Nolu Teklif İçin Özel Mobilya Tasarım Kaydı Oluşturuyorum. Kabul Ediyormusun?')
			if(sor == true)
			{
				window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_product_tree_creative_import_efurniturecad_for_offer&offer_id="+offer_id+"&process_stage="+process_stage;
			}
			else
				return false;
		}
		
	}
</script>