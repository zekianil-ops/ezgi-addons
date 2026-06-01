<!---
    File: add_ezgi_private_product_tree_creative_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.is_excel" default="">
<cfparam name="attributes.process_id" default="">

<cfquery name="get_design_info" datasource="#dsn3#">
	SELECT        
    	DESIGN_ID, 
        CONSUMER_ID, 
        COMPANY_ID, 
        MEMBER_TYPE
	FROM        
    	EZGI_DESIGN WITH (NOLOCK)
	WHERE        
    	DESIGN_ID = #attributes.design_id# AND 
        (COMPANY_ID >0 OR CONSUMER_ID>0)
</cfquery>
<cfif not get_design_info.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='247.Müşteri veya Proje Eksik, Lütfen Tamamlayıp Tekrar Deneyin!'>");
		window.close()
	</script>
</cfif>
<cfquery name="get_offer_row" datasource="#dsn3#">
	SELECT        
    	O.OFFER_ID, 
        O.OFFER_NUMBER, 
        O.OFFER_DATE,
        ORR.WRK_ROW_ID,
        ORR.OFFER_ROW_ID,
        ORR.STOCK_ID, 
        ORR.QUANTITY, 
        ORR.UNIT, 
        ORR.UNIT_ID, 
        ORR.PRODUCT_NAME, 
        ORR.SPECT_VAR_ID, 
        ORR.SPECT_VAR_NAME, 
        ORR.PRODUCT_NAME2, 
        O.OFFER_HEAD, 
        O.OFFER_DETAIL, 
      	O.DELIVER_PLACE, 
        O.LOCATION_ID,
        EDMR.WRK_ROW_RELATION_ID,
        (SELECT PRODUCT_CODE FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = ORR.STOCK_ID) AS PRODUCT_CODE,
        ISNULL((SELECT MAIN_PROTOTIP_TYPE FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_MAIN_RELATED_ID = ORR.STOCK_ID AND MAIN_PROTOTIP_ID IS NULL),0) AS MAIN_PROTOTIP_TYPE
	FROM           
    	OFFER AS O WITH (NOLOCK) INNER JOIN
      	OFFER_ROW AS ORR WITH (NOLOCK) ON O.OFFER_ID = ORR.OFFER_ID INNER JOIN
      	EZGI_DESIGN_MAIN_ROW AS E WITH (NOLOCK) ON ORR.STOCK_ID = E.DESIGN_MAIN_RELATED_ID INNER JOIN
     	EZGI_DESIGN AS ED WITH (NOLOCK) ON E.DESIGN_ID = ED.DESIGN_ID LEFT OUTER JOIN
 		EZGI_DESIGN_MAIN_ROW AS EDMR WITH (NOLOCK) ON ORR.WRK_ROW_ID = EDMR.WRK_ROW_RELATION_ID
	WHERE
    	O.OFFER_STATUS = 1 AND 
        O.PURCHASE_SALES = 1 AND 
        O.OFFER_ZONE = 0 AND 
        ED.IS_PROTOTIP = 1 AND
        <cfif isdefined('attributes.process_id') and len(attributes.process_id)>
    		ED.PROCESS_ID = #attributes.process_id# AND 
        </cfif>
        <cfif isdefined('attributes.keyword') and len(attributes.keyword)>
        	O.OFFER_NUMBER LIKE '%#attributes.keyword#%' AND
        </cfif>
        <cfif isdefined('attributes.list_type') and attributes.list_type eq 1>
        	EDMR.WRK_ROW_RELATION_ID IS NULL AND
        <cfelseif isdefined('attributes.list_type') and attributes.list_type eq 2>
        	EDMR.WRK_ROW_RELATION_ID IS NOT NULL AND
        </cfif>
        <cfif get_design_info.MEMBER_TYPE eq 'partner' AND LEN(get_design_info.COMPANY_ID)>
    		O.COMPANY_ID = #get_design_info.COMPANY_ID#
    	<cfelseif len(get_design_info.CONSUMER_ID)>
        	O.CONSUMER_ID = #get_design_info.CONSUMER_ID#
        </cfif>
  	ORDER BY
    	O.OFFER_ID DESC	
</cfquery>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_offer_row.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="new_product" id="new_product" method="post" action="">
		<cfinput name="design_id" value="#attributes.design_id#" type="hidden">
        <cfinput name="process_id" value="#attributes.process_id#" type="hidden">
    	<cf_box scroll="0">
        	<cf_box_search>
                <div class="form-group">
                    <cfsavecontent variable="filtre"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	 <cfinput type="text" style="width:150px;" placeholder="#filtre#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                	<select name="list_type" id="list_type" style="width:80px; height:20px">
                    	<option value="0" <cfif attributes.list_type eq 0>selected</cfif>>Tümü</option>
                    	<option value="1" <cfif attributes.list_type eq 1>selected</cfif>>Aktarım Yapılacaklar</option>
                     	<option value="2" <cfif attributes.list_type eq 2>selected</cfif>>Aktarım Yapılmışlar</option>
                 	</select>
                </div>
                <div class="form-group">
                	<input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>>
                	<cf_get_lang_main no='446.Excel Getir'>
                </div>
          		<div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
          		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="1">
                </div>
          	</cf_box_search>
    	</cf_box>
        <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
			<cfset filename = "#createuuid()#">
            <cfheader name="Expires" value="#Now()#">
            <cfcontent type="application/vnd.msexcel;charset=utf-8">
            <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
            <cfset attributes.startrow=1>
            <cfset attributes.maxrows = get_offer_row.recordcount>
        </cfif>
   		<cfsavecontent variable="title"><cf_get_lang dictionary_id='30007.Satış Teklifleri'></cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_grid_list>
             	<thead>
                  	<tr>
                     	<th><cf_get_lang dictionary_id="58577.Sıra"></th>
                      	<th><cf_get_lang dictionary_id="58530.Aktarım Türü"></th>
                     	<th><cf_get_lang dictionary_id="58820.Başlık"></th>
                     	<th><cf_get_lang dictionary_id="57742.Tarih"></th>
                     	<th><cf_get_lang dictionary_id="58212.Teklif No"></th>
                      	<th><cf_get_lang dictionary_id="58800.Ürün Kodu"></th>
                     	<th><cf_get_lang dictionary_id="58221.Ürün Adı"></th>
                     	<th><cf_get_lang dictionary_id="57635.Miktar"></th>
                    	<th><cf_get_lang dictionary_id="57636.Birim"></th>
                     	<th><input type="checkbox" title="<cfoutput><cf_get_lang dictionary_id="206.Hepsini Seç"></cfoutput>" onClick="transfer_product_tree(-1);"></th>
                 	</tr>
              	</thead>
             	<tbody>
					<cfif get_offer_row.recordcount>
                     	<cfoutput query="get_offer_row">
                        		<tr id="row_#currentrow#">
                                	<td style="text-align:right;" nowrap="nowrap">#currentrow#&nbsp;</td>
                                	<td style="text-align:left;" nowrap="nowrap">&nbsp;
                                   		<cfif MAIN_PROTOTIP_TYPE eq 0><cf_get_lang dictionary_id="58156.Diğer"></cfif>
                                 		<cfif MAIN_PROTOTIP_TYPE eq 1><cf_get_lang dictionary_id="802.Kapı"></cfif>
                                      	<cfif MAIN_PROTOTIP_TYPE eq 2><cf_get_lang dictionary_id="803.Mutfak"></cfif>
                                      	<cfif MAIN_PROTOTIP_TYPE eq 3><cf_get_lang dictionary_id="58937.Transfer İşlemi"></cfif>
                                 	</td>
                                  	<td style="text-align:left;" nowrap="nowrap">&nbsp;#OFFER_HEAD#</td>
                                 	<td style="text-align:center;" nowrap="nowrap">#DateFormat(OFFER_DATE,dateformat_style)#</td>
                                  	<td style="text-align:center;" nowrap="nowrap">#OFFER_NUMBER#</td>
                                 	<td style="text-align:center;" nowrap="nowrap">#PRODUCT_CODE#</td>
                                 	<td style="text-align:left;" nowrap="nowrap" title="#PRODUCT_NAME2#">&nbsp;#PRODUCT_NAME#</td>
                                 	<td style="text-align:right;" nowrap="nowrap">#TlFormat(QUANTITY,2)#&nbsp;</td>
                                 	<td style="text-align:center;" nowrap="nowrap">&nbsp;#UNIT#</td>
                                 	<td style="text-align:center;" nowrap="nowrap" >
                                      	<cfif len(WRK_ROW_RELATION_ID)> <!---Bu Modül Daha Önce Transfer Edilmişse--->
                                         	<img src="images/c_ok.gif" title="<cf_get_lang dictionary_id='248.Transfer Edilmiş Ürün'>" />
                                     	<cfelse>
                                        	<input name="select_production" id="select_production" type="checkbox" value="#OFFER_ROW_ID#" style="text-align:center; vertical-align:middle" checked="checked" />
                                      	</cfif>
                                 	</td>
                              	</tr>
                     	</cfoutput>
                  		<tfoot>
                          	<tr>
                            	<td colspan="11" height="20" style="text-align:right">
                              		<cfsavecontent variable="devam"><cf_get_lang dictionary_id='58126.Devam'></cfsavecontent>
                               		<button name="buton" onClick="transfer_product_tree(-2)" style="width:100px; height:30px; background-color:lightseagreen; color:white"><cfoutput>#devam#</cfoutput></button>
                            	</td>
                        	</tr>
                      	</tfoot>
              		<cfelse>
                     	<tr> 
                         	<td colspan="11" height="20"><cf_get_lang dictionary_id='72.Kayıt Yok'>!</td>
                      	</tr>
                 	</cfif>
            	</tbody>
            </cf_grid_list>
      	</cf_box>
  	</cfform>
</div>                

<script language="javascript">
	function transfer_product_tree(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		offer_id_list = '';
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
				offer_id_list +=my_objets.value+',';
			}
		}
		offer_id_list = offer_id_list.substr(0,offer_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(offer_id_list!='')
		{
			if(type == -2)
			{
				sor=confirm('<cf_get_lang dictionary_id='249.Seçtiğiniz Kayıtları Özel Tasarıma Transfer Ediyorum!'>');
				if (sor == true)
				{
					document.getElementById("new_product").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_add_ezgi_private_product_tree_creative_main_row";
					document.getElementById("new_product").submit();
				}
				else
					return false;
			}
		}
	}
</script>
