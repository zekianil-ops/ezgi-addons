<!---
    File: list_ezgi_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset fuseaction_ = ListGetAt(attributes.fuseaction,2,'.')>
<cfparam name="attributes.oby" default="1">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.status" default="2">
<cfparam name="attributes.design_type" default="">
<cfparam name="attributes.color_type" default="">
<cfparam name="attributes.is_prototip" default="2">
<cfparam name="attributes.cat_id" default="">
<cfparam name="attributes.category_name" default="">
<cfparam name="attributes.cat" default="">
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
		get_design_list_action = createObject("component", "addOns.ezgi.cfc.get_designs");
		get_design_list_action.dsn3 = dsn3;
		get_designs = get_design_list_action.get_designs_
		(
		 	status : '#iif(isdefined("attributes.status"),"attributes.status",DE(""))#',
			oby : '#iif(isdefined("attributes.oby"),"attributes.oby",DE(""))#',
			keyword : '#IIf(IsDefined("attributes.keyword"),"attributes.keyword",DE(""))#',
			design_type : '#IIf(IsDefined("attributes.design_type"),"attributes.design_type",DE(""))#',
			color_type : '#IIf(IsDefined("attributes.color_type"),"attributes.color_type",DE(""))#',
			process_stage : '#IIf(IsDefined("attributes.process_stage"),"attributes.process_stage",DE(""))#',
			is_prototip : '#IIf(IsDefined("attributes.is_prototip"),"attributes.is_prototip",DE(""))#',
			cat : '#iif(isdefined("attributes.cat"),"attributes.cat",DE(""))#',
			category_name : '#iif(isdefined("attributes.category_name"),"attributes.category_name",DE(""))#',
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
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%ezgi_product_tree_creative%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="get_colors">
	<cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
</cfoutput>
<cfparam name="attributes.totalrecords" default='#get_designs.query_count#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_list" action="#request.self#?fuseaction=prod.list_ezgi_product_tree_creative" method="post">
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
                	<select name="design_type" id="design_type" style="width:160px; height:20px">
                     	<option value="0" <cfif attributes.design_type eq 0>selected</cfif>><cf_get_lang dictionary_id="58651.Türü"></option>
                       	<option value="1" <cfif attributes.design_type eq 1>selected</cfif>><cf_get_lang dictionary_id="830.Modül - Paket - Parça"></option>
                    	<option value="2" <cfif attributes.design_type eq 2>selected</cfif>><cf_get_lang dictionary_id="829.Modül - Paket"></option>
                      	<option value="3" <cfif attributes.design_type eq 3>selected</cfif>><cf_get_lang dictionary_id="141.Modül"></option>
                 	</select>
               	</div>
                <div class="form-group medium">
                	<select name="color_type" id="color_type" style="width:65px; height:20px">
                   		<option value="0" <cfif attributes.color_type eq 0>selected</cfif>><cf_get_lang dictionary_id="37325.Renk"></option>
                     	<cfoutput query="get_colors">
                          	<option <cfif attributes.color_type eq COLOR_ID>selected</cfif> value="#COLOR_ID#">#COLOR_NAME#</option>
                    	</cfoutput>
            		</select>
               	</div>
           		<div class="form-group medium">
                	<select name="oby" id="oby" style="width:100px;">
                     	<option value="0" <cfif attributes.oby eq 0>selected</cfif>><cf_get_lang dictionary_id="58924.Sıralama"></option>
                      	<option value="1" <cfif attributes.oby eq 1>selected</cfif>><cf_get_lang dictionary_id="58585.Kod"></option>
                       	<option value="2" <cfif attributes.oby eq 2>selected</cfif>><cf_get_lang dictionary_id="57897.Adı"></option>
             		</select>
              	</div>
                <div class="form-group medium">
               	 	<select name="is_prototip" id="is_prototip" style="width:100px;height:20px">
                     	<option value="0" <cfif attributes.is_prototip eq 0>selected</cfif>><cf_get_lang dictionary_id="57708.Tümü"></option>
                     	<option value="1" <cfif attributes.is_prototip eq 1>selected</cfif>><cf_get_lang dictionary_id="45427.Özelleştirilebilir"></option>
                  		<option value="2" <cfif attributes.is_prototip eq 2>selected</cfif>><cf_get_lang dictionary_id="37227.Standart"></option>
                 	</select>
               	</div>
                <div class="form-group medium">
                	<select name="status" id="status" style="width:65px;">
                  		<option value="1" <cfif attributes.status eq 1>selected</cfif>><cf_get_lang dictionary_id="57708.Tümü"></option>
                   		<option value="2" <cfif attributes.status eq 2>selected</cfif>><cf_get_lang dictionary_id="57493.Aktif"></option>
                   		<option value="3" <cfif attributes.status eq 3>selected</cfif>><cf_get_lang dictionary_id="57494.Pasif"></option>
                	</select>
              	</div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
                <div class="form-group">
					<a  class="ui-btn ui-btn-gray2" href="javascript://" onclick="ezgi_revision()">
                    	<i class="fa fa-exchange" title="<cf_get_lang dictionary_id='36643.Revizyon Yönetimi'>"></i>
                  	</a>
                </div>
          	</cf_box_search>
            <cf_box_search_detail>
                <div id="detail_search_div" style="display:table-row;"></div>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="item-cat_id">
                        <label class="col col-12"><cf_get_lang dictionary_id='57486.Kategori'></label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="cat_id" id="cat_id" value="<cfif len(attributes.cat_id) and len(attributes.category_name)><cfoutput>#attributes.cat_id#</cfoutput></cfif>">
                                <input type="hidden" name="cat" id="cat" value="<cfif len(attributes.cat) and len(attributes.category_name)><cfoutput>#attributes.cat#</cfoutput></cfif>">
                                <input name="category_name" type="text" id="category_name"  onfocus="AutoComplete_Create('category_name','PRODUCT_CATID,PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID,HIERARCHY','cat_id,cat','','3','200','','1');" value="<cfif len(attributes.category_name)><cfoutput>#attributes.category_name#</cfoutput></cfif>" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_id=search_list.cat_id&field_code=search_list.cat&field_name=search_list.category_name</cfoutput>');"></span>
                            </div>
                        </div>
                    </div>
              	</div>
            </cf_box_search_detail>
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id="16.Mobilya Tasarım"></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
     	<cf_grid_list>
        	<thead>
            	<tr>
                	<th width="20"><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th><cf_get_lang dictionary_id="57486.Kategori"></th>
                    <th><cf_get_lang dictionary_id="43440.Tasarım Adı"></th>
                    <th><cf_get_lang dictionary_id="37325.Renk"></th>
                    <th><cf_get_lang dictionary_id="58937.Transfer İşlemi"></th>
                    <th><cf_get_lang dictionary_id="58651.Türü"></th>
                    <th><cf_get_lang dictionary_id="58859.Süreç"></th>
                    <th><cf_get_lang dictionary_id="57627.Kayıt Tarihi"></th>
                    <th><cf_get_lang dictionary_id="57629.Açıklama"></th>
                    
                    <!-- sil -->
            			<th width="20" class="header_icn_none">
                        	<a href="<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='17.Tasarım Ekle'>"></i></a>
            			</th>
                   	<!-- sil -->
                    <th width="20" class="header_icn_none" id="select_revision" style="display:none">
                    	<cfif isdefined("attributes.is_submitted")><input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: all_select_control('all_conv_product','_conversion_product_',<cfoutput>#get_designs.recordcount#</cfoutput>);"></cfif>
                    </th>
              	</tr>
         	</thead>
          	<tbody>
            	<input type="hidden" name="select_revision_on" id="select_revision_on" value="0">
            	<cfif get_designs.recordcount>
                	<cfset color_id_list =''>
                    <cfset process_stage_list = ''>
					<cfoutput query="get_designs">
                        <cfif len(process_stage) and not listfind(process_stage_list,process_stage)>
                            <cfset process_stage_list=listappend(process_stage_list,process_stage)>
                        </cfif>
                        <cfif len(color_id) and not listfind(color_id_list,color_id)>
                            <cfset color_id_list=listappend(color_id_list,color_id)>
                        </cfif>
                    </cfoutput>
                    <cfif len(process_stage_list)>
						<cfset process_stage_list=listsort(process_stage_list,"numeric","ASC",",")>
                        <cfquery name="PROCESS_TYPE" datasource="#DSN#">
                            SELECT
                                STAGE,
                                PROCESS_ROW_ID
                            FROM
                                PROCESS_TYPE_ROWS
                            WHERE
                                PROCESS_ROW_ID IN(#process_stage_list#)
                            ORDER BY
                                PROCESS_ROW_ID
                        </cfquery>
                    </cfif>
                    <cfif len(color_id_list)>
						<cfset color_id_list=listsort(color_id_list,"numeric","ASC",",")>
                        <cfquery name="get_color" datasource="#DSN3#">
                            SELECT  COLOR_ID, COLOR_NAME FROM EZGI_COLORS WHERE COLOR_ID IN(#color_id_list#) ORDER BY COLOR_ID
                        </cfquery>
                    </cfif>
                	<cfoutput query="get_designs">
						<tr oncontextmenu="javascript:wrk_right_menu('design_id',#design_id#);return false;"> 
                        	<td>#rownum#</td>
                         	<td><a href="#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&design_id=#design_id#" class="tableyazi">#PRODUCT_CAT#</a></td>
                            <td>#design_name#</td>
                            <td>
                            	<cfif isdefined('COLOR_NAME_#COLOR_ID#')>
                                	#Evaluate('COLOR_NAME_#COLOR_ID#')#
                                </cfif>
                            </td>
                            <td>
                            	<cfif process_id eq 1>
                                	<cf_get_lang dictionary_id="830.Modül - Paket - Parça">
                                <cfelseif process_id eq 2>
                                	<cf_get_lang dictionary_id="829.Modül - Paket">
                               	<cfelseif process_id eq 3>
                                	<cf_get_lang dictionary_id="36742.Modül">
                                </cfif>
                            </td>
                            <td>
                            	<cfif PROTOTIP eq 0>
                                	<cf_get_lang dictionary_id="37227.Standart">
                                <cfelseif PROTOTIP eq 1>
                                	<cf_get_lang dictionary_id="45427.Özelleştirilebilir">
                                </cfif>
                            
                            </td>
                            <td>#PROCESS_TYPE.STAGE[listfind(process_stage_list,process_stage,',')]#</td>
                            <td>#DateFormat(RECORD_DATE,dateformat_style)#</td>
                            <td>#detail#</td>
                            
                          	<!-- sil -->
                                <td>
                                    <a href="#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&design_id=#design_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                                </td>
                         	<!-- sil -->
                            <td id="select_revision_#currentrow#" style="display:none; text-align:center">
                            	<input type="checkbox" name="conversion_product_#DESIGN_ID#" value="#DESIGN_ID#" id="_conversion_product_#currentrow#">
                            </td>
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
        <cfif len(attributes.status)>
        	<cfset adres = "#adres#&status=#attributes.status#">
        </cfif>
        <cfif len(attributes.design_type)>
        	<cfset adres = "#adres#&design_type=#attributes.design_type#">
        </cfif>
        <cfif len(attributes.color_type)>
        	<cfset adres = "#adres#&color_type=#attributes.color_type#">
        </cfif>
        <cfif len(attributes.is_prototip)>
        	<cfset adres = "#adres#&is_prototip=#attributes.is_prototip#">
        </cfif>
        <cfif isdefined('attributes.process_stage') and len(attributes.process_stage)>
        	<cfset adres = "#adres#&process_stage=#attributes.process_stage#">
        </cfif>
       	<cfif len(attributes.cat) and len(attributes.category_name)>
        	<cfset adres = '#adres#&cat=#attributes.cat#&category_name=#attributes.category_name#'>
        </cfif>
        <cf_paging 
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#&is_submitted=1">
    </cf_box>
</div>
<div id="select_revision_foot" class="col col-12 col-md-12 col-sm-12 col-xs-12" style="display:none">
 	<cf_box scroll="0">
      	<form name="aktar_form" method="post" action="">
     		<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
       			<div class="form-group" id="item-old_stock_name">
                  	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57657.Ürün'></label>
                  	<div class="col col-8 col-xs-12">
                     	<div class="input-group">
                                <input type="hidden" name="old_stock_id" id="old_stock_id" value="">
                                <input type="hidden" name="old_product_id" id="old_product_id" value="">
                                <input type="text" name="old_stock_name" id="old_stock_name" value="" onFocus="AutoComplete_Create('old_stock_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE','get_product_autocomplete','0','STOCK_ID,PRODUCT_ID','old_stock_id,old_product_id','','3','225');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=aktar_form.old_stock_id&product_id=aktar_form.old_product_id&field_name=aktar_form.old_stock_name');"></span>
                     	</div>
                  	</div>
             	</div>
         	</div>
          	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
            	<div class="form-group" id="item-new_stock_name">
                	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58674.Yeni'> <cf_get_lang dictionary_id='57657.Ürün'></label>
                 	<div class="col col-8 col-xs-12">
                   		<div class="input-group">
                                <input type="hidden" name="new_stock_id" id="new_stock_id" value="0">
                                <input type="hidden" name="new_product_id" id="new_product_id" value="">
                                <input type="text" name="new_stock_name" id="new_stock_name" value="" onFocus="AutoComplete_Create('new_stock_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE','get_product_autocomplete','0','STOCK_ID,PRODUCT_ID','new_stock_id,new_product_id','','3','225');" autocomplete="off">
                                <span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=aktar_form.new_stock_id&product_id=aktar_form.new_product_id&field_name=aktar_form.new_stock_name');"></span>
                  		</div>
                  	</div>
              	</div>
         	</div> 
            <input type="hidden" name="convert_design_id" id="convert_design_id" value="">
			</form>  
            <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
            	<div class="form-group" id="item-new_stock_name">
                	<button  value="" name="do_revision" id="do_revision" onClick="do_revision(1);" style="width:140px; height:25px;"><img src="/images/action_plus.gif" alt="<cf_get_lang dictionary_id='47870.Revizyon'>" border="0">&nbsp;<cf_get_lang dictionary_id='47870.Revizyon'></button>
                    <button  value="" name="do_revision_2" id="do_revision_2" onClick="do_revision(2);" style="width:140px; height:25px;"><img src="/images/find.gif" alt="<cf_get_lang dictionary_id='50555.İlişkili Ürünler'>" border="0">&nbsp;<cf_get_lang dictionary_id='50555.İlişkili Ürünler'></button>
                 	<div class="col col-8 col-xs-12">
                   		<div class="input-group">
                                
                  		</div>
                  	</div>
              	</div>
         	</div>  
	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;
	}
	function ezgi_revision()
	{
		<cfif isdefined('attributes.is_submitted')>
			row_count=<cfoutput>#get_designs.recordcount#</cfoutput>;
		<cfelse>
			row_count=0;
		</cfif>
		if(document.getElementById('select_revision_on').value == 0)
		{
			document.getElementById('select_revision').style.display='';
			document.getElementById('select_revision_foot').style.display='';
			for(r=1;r<=row_count;r++)
			{
				document.getElementById("select_revision_"+r).style.display='';	
			}
			document.getElementById('select_revision_on').value=1;
		}
		else
		{
			document.getElementById('select_revision').style.display='none';
			document.getElementById('select_revision_foot').style.display='none';
			for(r=1;r<=row_count;r++)
			{
				document.getElementById("select_revision_"+r).style.display='none'	
			}
			document.getElementById('select_revision_on').value=0;
		}
	}
	function all_select_control(all_conv_product,_conversion_product_,number)
	{
		for(var cl_ind=1; cl_ind <= number; cl_ind++)
		{
			if(document.getElementById(all_conv_product).checked == true)
			{
				if(document.getElementById('_conversion_product_'+cl_ind) != undefined && document.getElementById('_conversion_product_'+cl_ind).checked == false)
					document.getElementById('_conversion_product_'+cl_ind).checked = true;
			}
			else
			{
				if(document.getElementById('_conversion_product_'+cl_ind) != undefined && document.getElementById('_conversion_product_'+cl_ind).checked == true)
					document.getElementById('_conversion_product_'+cl_ind).checked = false;
			}
		}
	}
	function do_revision(type)
	{
		if(type ==1)
		{
			if(document.aktar_form.new_stock_id.value == '' || document.aktar_form.new_stock_name.value == '')//eklenecek ürün secili olmali
			{
				alert('<cf_get_lang dictionary_id="58674.Yeni"> <cf_get_lang dictionary_id="58227.Ürün Seçmelisiniz">!');
				return false;
			}
			if(document.aktar_form.new_stock_id.value == document.aktar_form.old_stock_id.value)
			{
				alert('<cf_get_lang dictionary_id="60443.Aynı Ürünü Bir Defa Seçebilirsiniz">!');
				return false;
			}
		}
		if(document.aktar_form.old_stock_id.value == '' || document.aktar_form.old_stock_name.value == '')//cikarilacak ürün secili olmali
		{
			alert('<cf_get_lang dictionary_id="58227.Ürün Seçmelisiniz">!');
			return false;
		}
		<cfif isdefined('attributes.is_submitted')>
			row_count=<cfoutput>#get_designs.recordcount#</cfoutput>;
		<cfelse>
			row_count=0;
		</cfif>
		var convert_list ="";
		for(rr=1;rr<=row_count;rr++)
		{
			if(document.getElementById('_conversion_product_'+rr).checked == true)
			{
				convert_list += document.getElementById('_conversion_product_'+rr).value+",";
			}
		}
		if(convert_list)//Tasarım Seçili ise
		{
			sor=confirm('<cf_get_lang dictionary_id="58587.Devam Etmek İstediğinizden Emin misiniz">');
			if(sor==true)
			{
				
				if(type ==1)
					document.getElementById('do_revision').disabled=true;
				document.getElementById('convert_design_id').value=convert_list.substr(0,convert_list.length-1);
				aktar_form.action="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative_revision&type="+type;
				aktar_form.target="blank";
				aktar_form.submit();
			}
			else
				return false;
		}
		else
		{
			alert('<cf_get_lang dictionary_id="35384.En Az Bir Seçim Yapmalısınız">!');
			return false;	
		}
	}
</script>