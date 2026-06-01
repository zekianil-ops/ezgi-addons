<!---
    File: list_ezgi_shipping_orders.cfm
    Folder: Add_Ons\ezgi\e-pda\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.store" default="">
<cfparam name="attributes.location" default="">
<cfparam name="attributes.keyword" default="">
<cfquery name="get_default_departments" datasource="#dsn#">
	SELECT        
    	DEFAULT_RF_TO_SV_DEP, 
        DEFAULT_RF_TO_SV_LOC
	FROM            
    	EZGI_PDA_DEPARTMENT_DEFAULTS
	WHERE        
    	EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>. <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>!");
		window.location ="<cfoutput>#request.self#?fuseaction=myhome.welcome</cfoutput>";
	</script>
    <cfabort>
</cfif>
<cfquery name="GET_PDA_DEFAULT" datasource="#DSN3#">
	SELECT ISNULL(PDA_CONTROL_TYPE,1) AS PDA_CONTROL_TYPE FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfparam name="attributes.kontrol_status" default="#GET_PDA_DEFAULT.PDA_CONTROL_TYPE#">
<cfset default_departments = '#get_default_departments.DEFAULT_RF_TO_SV_DEP#'> 
<cfparam name="attributes.department_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,2)#">
<cfif isdefined("attributes.is_form_submitted")>
  	<cfquery name="get_shipping_orders_group" datasource="#dsn3#">
    	SELECT        
        	PP.PRODUCT_PLACE_ID, 
            TBL.SHELF_NUMBER AS ALTERNATIVE_SHELF_ID,
            PP.SHELF_CODE, 
            TBL.SHELF_CODE AS ALTERNATIVE_SHELF_CODE,
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME, 
            S.BARCOD,
            PPR.MIN_AMOUNT, 
            PPR.AMOUNT, 
            TBL.REAL_STOCK AS FAZLA_STOK, 
         	GSSL.REAL_STOCK AS GERCEK_STOK
		FROM            
       		PRODUCT_PLACE AS PP INNER JOIN
           	PRODUCT_PLACE_ROWS AS PPR ON PP.PRODUCT_PLACE_ID = PPR.PRODUCT_PLACE_ID INNER JOIN
         	STOCKS AS S ON PPR.STOCK_ID = S.STOCK_ID INNER JOIN
          	(
            	SELECT        
            		GSLT.REAL_STOCK, 
                    GSLT.STOCK_ID, 
                    GSLT.SHELF_NUMBER, 
                    PPP.SHELF_CODE
            	FROM            
                	#dsn2_alias#.GET_STOCK_LAST_SHELF AS GSLT INNER JOIN
                 	PRODUCT_PLACE AS PPP ON GSLT.SHELF_NUMBER = PPP.PRODUCT_PLACE_ID
              	WHERE        
                	GSLT.SHELF_NUMBER > 0 AND 
                    PPP.SHELF_TYPE = 2
           	) AS TBL ON PPR.STOCK_ID = TBL.STOCK_ID INNER JOIN
        	#dsn2_alias#.GET_STOCK_LAST_SHELF AS GSSL ON PPR.PRODUCT_PLACE_ID = GSSL.SHELF_NUMBER AND PPR.STOCK_ID = GSSL.STOCK_ID AND ISNULL(PPR.MIN_AMOUNT, 0) > GSSL.REAL_STOCK
		WHERE        
        	PP.PLACE_STATUS = 1 AND 
            <cfif len(attributes.department_id)>
                PP.STORE_ID = #ListGetAt(attributes.department_id,1,'-')# AND 
                PP.LOCATION_ID =  #ListGetAt(attributes.department_id,2,'-')# AND
            </cfif> 
            <cfif len(attributes.keyword)>
            	S.BARCOD = '#attributes.keyword#' AND
            </cfif>
            PP.SHELF_TYPE = 1
 	 </cfquery>
     <cfquery name="get_shipping_orders" dbtype="query">
     	SELECT
        	 PRODUCT_PLACE_ID, 
             SHELF_CODE, 
             PRODUCT_CODE, 
             PRODUCT_NAME, 
             MIN_AMOUNT, 
             AMOUNT, 
             GERCEK_STOK, 
             BARCOD
		FROM
        	get_shipping_orders_group
       	GROUP BY
        	PRODUCT_PLACE_ID, 
             SHELF_CODE, 
             PRODUCT_CODE, 
             PRODUCT_NAME, 
             MIN_AMOUNT, 
             AMOUNT, 
             GERCEK_STOK, 
             BARCOD	
     </cfquery>
<cfelse>
	<cfset get_shipping_orders.recordcount= 0>
</cfif>
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT 
		D.DEPARTMENT_HEAD,
		SL.DEPARTMENT_ID,
		SL.LOCATION_ID,
		SL.STATUS,
		SL.COMMENT
	FROM 
		STOCKS_LOCATION SL,
		DEPARTMENT D,
		BRANCH B
	WHERE
		D.DEPARTMENT_ID IN (#default_departments#) AND
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID
</cfquery>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default=20>
<cfset attributes.startrow = ((attributes.page-1)*attributes.maxrows)+1>
<cfparam name="attributes.totalrecords" default='#get_shipping_orders.recordcount#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="frm_search" method="post" action="#request.self#?fuseaction=pda.list_ezgi_shipping_orders">
        	<input type="hidden" name="is_form_submitted" value="1">
            <cf_box_search>
                <div class="form-group">
                	<cfsavecontent variable="message"><cf_get_lang dictionary_id="54667.Lütfen Barkod No Giriniz"></cfsavecontent>
                   	<cfinput type="text" name="keyword" value="#attributes.keyword#" maxlength="20" placeholder="#message#">
                </div>
                <div class="form-group">
                	<select name="department_id" style="width:280px; height:20px">
                     	<option value=""><cf_get_lang dictionary_id='45348.Tüm Depolar'></option>
                      	<cfoutput query="get_all_location" group="department_id">
                        	 <option value="#department_id#">#department_head#</option>
                           	<cfoutput>
                            	<option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_id,'-')# and location_id is #ListLast(attributes.department_id,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                        	</cfoutput> 
                     	 </cfoutput>
                 	</select>
                </div>
				<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
           	 </cf_box_search>
    	</cfform>
  	</cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='30795.Sevk Emirleri'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
      	<cf_form_list>
        	<thead>
              	<tr>
                	<th style="width:20"><cf_get_lang dictionary_id='44267.Sıra No'></th>
                    <th><cf_get_lang dictionary_id='45868.Ürün / Stok'></th>
                 	<th style="width:90"><cf_get_lang dictionary_id='1130.Artacak Raf No'></th>
                    <th style="width:90"><cf_get_lang dictionary_id='1131.Azalacak Raf No'></th>
                    <th style="width:90"><cf_get_lang dictionary_id='46709.Planlanan Miktar'></th>
                    <!-- sil -->
    				<th style="width:10%">&nbsp;</th>
                    <!-- sil -->
               	</tr>
          	</thead>
            <tbody>
				<cfif get_shipping_orders.recordcount>
                    <cfoutput query="get_shipping_orders">
                    	<cfquery name="get_shipping_orders_alternative" dbtype="query">
                        	SELECT
                            	ALTERNATIVE_SHELF_ID,
            					ALTERNATIVE_SHELF_CODE,
          						FAZLA_STOK
							FROM
        						get_shipping_orders_group
                         	WHERE
                            	PRODUCT_PLACE_ID=#PRODUCT_PLACE_ID#	
                          	ORDER BY
                            	ALTERNATIVE_SHELF_CODE
                        </cfquery>
                    	<tr>
                        	<td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">#BARCOD#</td>
                            <td style="text-align:center">#SHELF_CODE#</td>
                            <td style="text-align:center">
                            	<select name="alternative_shelf_code">
                                	<cfloop query="get_shipping_orders_alternative">
                                    	<option value="#ALTERNATIVE_SHELF_ID#">#ALTERNATIVE_SHELF_CODE# - #FAZLA_STOK#</option>
                                    </cfloop>
                                </select>
                            </td>
                            <td style="text-align:right">#(GERCEK_STOK-AMOUNT)*-1#</td>
                            <td style="text-align:center">
                                 <a href="#request.self#?fuseaction="><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
                            </td>
                        </tr>
                  	</cfoutput>
                <cfelse>
                	<tfoot>
                        <tr>
                            <td colspan="6" height="20">
                                <cfif not isdefined("attributes.is_form_submitted")>
                                    <cf_get_lang dictionary_id='57701.Filtre Ediniz'>
                                <cfelse>
                                    <cf_get_lang dictionary_id='57484.Kayıt Yok'>
                                </cfif>
                                !
                            </td>
                        </tr>
                    </tfoot>
                </cfif>
            </tbody>
        </cf_form_list>
        <cfset adres = url.fuseaction>
    	<cfif isDefined('attributes.department_id') and len(attributes.department_id)>
        	<cfset adres = adres & '&department_id=' & attributes.department_id>
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
	$('#keyword').focus();
	function input_control()
	{	
		return true;
	}
</script>