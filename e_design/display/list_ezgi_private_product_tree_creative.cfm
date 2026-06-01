<!---
    File: list_ezgi_private_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset fuseaction_ = ListGetAt(attributes.fuseaction,2,'.')>
<cfparam name="attributes.oby" default="2">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.status" default="2">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.member_type" default="">
<cfparam name="attributes.member_name" default="">
<cfparam name="attributes.page" default=1>
<cfif not (isDefined('attributes.maxrows') and isNumeric(attributes.maxrows))>
  <cfset attributes.maxrows = session.ep.maxrows>
</cfif>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfscript>
	get_designs.recordcount=0;
	get_designs.query_count=0;
	if (isdefined("attributes.is_submitted"))
	{
		get_design_list_action = createObject("component", "addOns.ezgi.cfc.get_private_designs");
		get_design_list_action.dsn3 = dsn3;
		get_design_list_action.dsn_alias = dsn_alias;
		get_designs = get_design_list_action.get_designs_
		(
		 	dsn_alias : '#dsn_alias#',
		 	company_id : '#iif(isdefined("attributes.company_id"),"attributes.company_id",DE(""))#',
			consumer_id : '#iif(isdefined("attributes.consumer_id"),"attributes.consumer_id",DE(""))#',
			member_name : '#iif(isdefined("attributes.member_name"),"attributes.member_name",DE(""))#',
		 	status : '#iif(isdefined("attributes.status"),"attributes.status",DE(""))#',
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
<cfquery name="GET_PROCESS_TYPE" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%ezgi_private_product_tree_creative%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="GET_PROCESS_TYPE">
	<cfset 'STAGE#PROCESS_ROW_ID#' = STAGE>
</cfoutput>
<cfparam name="attributes.totalrecords" default='#get_designs.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_list" action="#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative" method="post">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
			<cfsavecontent  variable="filtre">
				<cf_get_lang dictionary_id='57460.Filtre'>
			</cfsavecontent>
            <cf_box_search>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filtre#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group medium">
                	<select name="process_stage" id="process_stage" style="width:100px; height:20px">
                  		<option value=""><cf_get_lang dictionary_id="58859.Süreç"></option>
                      	<cfoutput query="get_process_type">
                        	<option value="#process_row_id#"<cfif isdefined('attributes.process_stage') and attributes.process_stage eq process_row_id>selected</cfif>>#stage#</option>
                    	</cfoutput>
                  	</select>
                </div>
           		<div class="form-group medium">
                	<select name="oby" id="oby" style="width:100px;">
                      	<option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id="57925.Artan Tarih"></option>
                       	<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id="57926.Azalan Tarih"></option>
             		</select>
              	</div>
                <div class="form-group medium">
                	<select name="status" id="status" style="width:65px;">
                  		<option value="1" <cfif attributes.status eq 1>selected</cfif>><cf_get_lang dictionary_id="57708.Tümü"></option>
                   		<option value="2" <cfif attributes.status eq 2>selected</cfif>><cf_get_lang dictionary_id="57493.Aktif"></option>
                   		<option value="3" <cfif attributes.status eq 3>selected</cfif>><cf_get_lang dictionary_id="57494.Pasif"></option>
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
    <cfsavecontent variable="title"><cf_get_lang dictionary_id="44.Özel Mobilya Tasarım"></cfsavecontent>
    <cfsavecontent variable="right">
     	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_private_product_tree_creative_from_efurniturecad</cfoutput>','wide');" class="tableyazi">
         	<img src="/images/quiz.gif" align="absmiddle" border="0" title="<cf_get_lang dictionary_id='1369.E-Furniture Cad'>" />
      	</a>
   	</cfsavecontent> 
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1" right_images="#right#">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th width="20"><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th><cf_get_lang dictionary_id="57880.Belge No"></th>
                    <th><cf_get_lang dictionary_id="57880.Teklif No"></th>
            		<th><cf_get_lang dictionary_id="57519.Cari Hesap"></th>
                    <th style="width:70px;"><cf_get_lang dictionary_id="58859.Süreç"></th>
                    <th style="width:60px;"><cf_get_lang dictionary_id="57627.Kayıt Tarihi"></th>
                    <th style=""><cf_get_lang dictionary_id="57629.Açıklama"></th>
                    <!-- sil -->
            			<th width="20" class="header_icn_none">
                        	<a href="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>
            			</th>
                   	<!-- sil -->
              	</tr>
         	</thead>
          	<tbody>
            	<cfif get_designs.recordcount>
                    <cfset design_id_list = ValueList(get_designs.DESIGN_ID)>
                    <cfquery name="get_offer_number" datasource="#dsn3#">
                        SELECT        
                            EDM.DESIGN_ID, 
                            O.OFFER_NUMBER,
                            O.OFFER_ID
                        FROM            
                            EZGI_DESIGN_MAIN_ROW AS EDM INNER JOIN
                            OFFER_ROW AS OFR ON EDM.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID INNER JOIN
                            OFFER AS O ON OFR.OFFER_ID = O.OFFER_ID
                        WHERE        
                            EDM.DESIGN_ID IN (#design_id_list#)
                    </cfquery>
                    <cfoutput query="get_designs">
                    	<cfquery name="get_design_offer_number" dbtype="query">
                        	SELECT OFFER_NUMBER,OFFER_ID FROM get_offer_number WHERE DESIGN_ID = #get_designs.DESIGN_ID# GROUP BY OFFER_NUMBER,OFFER_ID ORDER BY OFFER_NUMBER
                        </cfquery>
                        <tr>
                            <td style="text-align:right">#currentrow#</td>
                            <td style="text-align:right" title="<cf_get_lang dictionary_id='57464.Güncelle'>">
                            	<a href="#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&design_id=#design_id#">
                                	#design_id#
                               	</a>
                            </td>
                            <td style="text-align:center">
                            	<cfloop query="get_design_offer_number">
                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#get_design_offer_number.OFFER_ID#','longpage');">
                                		#get_design_offer_number.OFFER_NUMBER#
                                    </a>
                                    &nbsp;
                                </cfloop>
                            </td>
                          	<td><a href="#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&design_id=#design_id#" class="tableyazi">#UNVAN#</a></td>
                            <td><cfif isdefined('STAGE#PROCESS_STAGE#')>#Evaluate('STAGE#PROCESS_STAGE#')#</cfif></td>
                            <td>#DateFormat(RECORD_DATE,dateformat_style)#</td>
                            <td>#detail#</td>
                            <!-- sil -->
                            <td>
                           		<a href="#request.self#?fuseaction=prod.list_ezgi_private_product_tree_creative&event=upd&design_id=#design_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                        	 </td>
                            <!-- sil -->
                        </tr>
                    </cfoutput>
            	<cfelse>
               		<tr> 
                    	<td colspan="8" height="20"><cfif arama_yapilmali eq 1><cf_get_lang dictionary_id='57701.Filtre Ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</cfif></td>
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
</script>