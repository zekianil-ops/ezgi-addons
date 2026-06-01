<!---
    File: list_shipping.cfm
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
<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,2)#">
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
<cfif isdefined("attributes.is_form_submitted")>
  <cfinclude template="../query/get_shipping_list.cfm">
  <cfelse>
  <cfset get_sevk_fis.recordcount = 0>
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
<cfparam name="attributes.totalrecords" default='#get_sevk_fis.recordcount#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="frm_search" method="post" action="#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.list_shipping">
        	<input type="hidden" name="is_form_submitted" value="1">
            <cf_box_search>
                <div class="form-group">
                	<cfsavecontent variable="message"><cf_get_lang dictionary_id="54667.Lütfen Barkod No Giriniz"></cfsavecontent>
                   	<cfinput type="text" name="keyword" value="#attributes.keyword#" maxlength="20" placeholder="#message#">
                </div>
				<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
           	 </cf_box_search>
            <cf_box_search_detail>
                <div id="detail_search_div" style="display:table-row;">
                	<cf_box_elements>
                        <div class="col col-12">
                            <div class="form-group" id="piece_type_">
                                <label class="col col-2"><cf_get_lang dictionary_id='57742.Tarih'></label>
                              	<div class="col col-5">
                                	<div class="input-group">
                                	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                    <cfinput type="text" maxlength="10" name="date1" value="#dateformat(attributes.date1,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="date1"></span>
                                    </div>
                                </div>
                                <div class="col col-5">
                                	<div class="input-group">
                                	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                    <cfinput type="text" maxlength="10" name="date2" value="#dateformat(attributes.date2,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="date2"></span>
                               		</div>
                     			</div>
                			</div>
                     	</div>
                        <div class="col col-12">
                            <div class="form-group" id="piece_type_">
                                <label class="col col-2">Depo</label>
                              	<div class="col col-10">
                                	<select name="department_in_id" style="width:280px; height:20px">
                                        <option value=""><cf_get_lang dictionary_id='45348.Tüm Depolar'></option>
                                        <cfoutput query="get_all_location" group="department_id">
                                            <option value="#department_id#">#department_head#</option>
                                            <cfoutput>
                                                <option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_in_id,'-')# and location_id is #ListLast(attributes.department_in_id,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                                            </cfoutput> 
                                        </cfoutput>
                                    </select>
                                </div>
                			</div>
                     	</div>
                        <div class="col col-12">
                            <div class="form-group" id="piece_type_">
                              	<label class="col col-2"><cf_get_lang dictionary_id='57894.Statü'></label>
                              	<div class="col col-10">
                                	<select name="kontrol_status">
                                        <option value="1" <cfif attributes.kontrol_status eq 1>selected</cfif>><cf_get_lang dictionary_id='29539.Satır Bazında'></option>
                                        <option value="2" <cfif attributes.kontrol_status eq 2>selected</cfif>><cf_get_lang dictionary_id='57660.Belge Bazında'></option>
                                    </select>
                                </div>
                			</div>
                     	</div>
                	</cf_box_elements>
               	</div>
          	</cf_box_search_detail>
    	</cfform>
  	</cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='811.Sevkiyat Kontrol'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
      	<cf_form_list>
        	<thead>
              	<tr>
                 	<th style="width:25%"><cf_get_lang dictionary_id='57880.Belge No'></th>
                    <th style="width:100%"><cf_get_lang dictionary_id='58061.Cari'></th>
                    <!-- sil -->
    				<th style="width:10%">&nbsp;</th>
                    <!-- sil -->
               	</tr>
          	</thead>
            <tbody>
				<cfif get_sevk_fis.recordcount>
                    <cfoutput query="get_sevk_fis">
                    	<cfquery name="PACKEGE_CONTROL_STATUS" datasource="#DSN3#">
                			<cfif IS_TYPE eq 1>
                                SELECT     
                                    CONTROL_STATUS
                                FROM         
                                    EZGI_SHIPPING_PACKAGE_LIST
                                WHERE     
                                    TYPE = 1 AND 
                                    SHIPPING_ID = #get_sevk_fis.SHIP_RESULT_ID#
                            <cfelseif IS_TYPE eq 2>
                                SELECT     
                                    CONTROL_STATUS
                                FROM         
                                    EZGI_SHIPPING_PACKAGE_LIST
                                WHERE     
                                    TYPE = 2 AND 
                                    SHIPPING_ID = #get_sevk_fis.SHIP_RESULT_ID#
                            </cfif>
                        </cfquery>
         				<cfif PACKEGE_CONTROL_STATUS.recordcount> 
           					<cfif PACKEGE_CONTROL_STATUS.CONTROL_STATUS eq 1>
                				<cfset url_param = "#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.form_shipping_control_fis&department_id=#attributes.department_in_id#&ship_id=">
             				<cfelse>
                				<cfset url_param = "#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.form_shipping_control&department_id=#attributes.department_in_id#&ship_id=">
            				</cfif>
        				<cfelse>
            				<cfif attributes.kontrol_status eq 1>
                				<cfset url_param = "#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.form_shipping_control_fis&department_id=#attributes.department_in_id#&ship_id=">
             				<cfelse>
                				<cfset url_param = "#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.form_shipping_control&department_id=#attributes.department_in_id#&ship_id=">
           					</cfif>
       					</cfif>
                    	<tr> 
                            <td style=" height:25px">
                            	<a href="#url_param##SHIP_RESULT_ID#&DELIVER_PAPER_NO=#DELIVER_PAPER_NO#&date1=#dateformat(attributes.date1,dateformat_style)#&date2=#dateformat(attributes.date2,dateformat_style)#&page=#attributes.page#&kontrol_status=#attributes.kontrol_status#&is_type=#IS_TYPE#"class="tableyazi">
                					#DELIVER_PAPER_NO#
            					</a>
      						</td>
                            <td><cfif IS_TYPE eq 1>#unvan#<cfelse>#DEPARTMENT_HEAD#</cfif></td>
                            <cfif IS_TYPE eq 1>    
                                <cfquery name="PACKEGE_CONTROL" datasource="#DSN3#">
                                    SELECT     
                                        ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                                        ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT
                                    FROM         
                                        (
                                        SELECT     
                                            PAKET_SAYISI AS PAKETSAYISI, 
                                            PAKET_ID AS STOCK_ID, 
                                            BARCOD, 
                                            STOCK_CODE, 
                                            PRODUCT_NAME,
                                            (
                                            SELECT     
                                                SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                                            FROM          
                                                EZGI_SHIPPING_PACKAGE_LIST
                                            WHERE      
                                                TYPE = 1 AND 
                                                STOCK_ID = TBL.PAKET_ID AND 
                                                SHIPPING_ID = TBL.SHIP_RESULT_ID
                                            ) AS CONTROL_AMOUNT
                                        FROM         
                                            (
                                            SELECT
                                                SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                                                PAKET_ID, 
                                                BARCOD, 
                                                STOCK_CODE, 
                                                PRODUCT_NAME, 
                                                PRODUCT_TREE_AMOUNT, 
                                                SHIP_RESULT_ID
                                            FROM
                                                (   
                                                SELECT     
                                                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                                    EPS.PAKET_ID, 
                                                    S.BARCOD, 
                                                    S.STOCK_CODE, 
                                                    S.PRODUCT_NAME, 
                                                    S.PRODUCT_TREE_AMOUNT, 
                                                    ESR.SHIP_RESULT_ID,
                                                    ESRR.ORDER_ROW_ID
                                                FROM          
                                                    SPECTS AS SP INNER JOIN
                                                    EZGI_SHIP_RESULT AS ESR INNER JOIN
                                                    EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                                                    STOCKS AS S INNER JOIN
                                                    EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
                                                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                                                WHERE      
                                                    ESR.SHIP_RESULT_ID = #SHIP_RESULT_ID# AND
                                                    ISNULL(S1.IS_PROTOTYPE,0) = 1
                                                GROUP BY 
                                                    EPS.PAKET_ID, 
                                                    S.BARCOD, 
                                                    S.STOCK_CODE, 
                                                    S.PRODUCT_NAME, 
                                                    S.PRODUCT_TREE_AMOUNT, 
                                                    ESR.SHIP_RESULT_ID,
                                                    ESRR.ORDER_ROW_ID
                                                UNION ALL  
                                                SELECT     
                                                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                                    EPS.PAKET_ID, 
                                                    S.BARCOD, 
                                                    S.STOCK_CODE, 
                                                    S.PRODUCT_NAME, 
                                                    S.PRODUCT_TREE_AMOUNT, 
                                                    ESR.SHIP_RESULT_ID,
                                                    ESRR.ORDER_ROW_ID
                                                FROM          
                                                    EZGI_SHIP_RESULT AS ESR INNER JOIN
                                                    EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                                    EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                                    STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                                                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                                                WHERE      
                                                    ESR.SHIP_RESULT_ID = #SHIP_RESULT_ID# AND
                                                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                                                GROUP BY 
                                                    EPS.PAKET_ID, 
                                                    S.BARCOD, 
                                                    S.STOCK_CODE, 
                                                    S.PRODUCT_NAME, 
                                                    S.PRODUCT_TREE_AMOUNT, 
                                                    ESR.SHIP_RESULT_ID,
                                                    ESRR.ORDER_ROW_ID
                                                ) AS TBL1
                                            GROUP BY
                                                PAKET_ID, 
                                                BARCOD, 
                                                STOCK_CODE, 
                                                PRODUCT_NAME, 
                                                PRODUCT_TREE_AMOUNT, 
                                                SHIP_RESULT_ID
                                            ) AS TBL
                                        ) AS TBL2
                                </cfquery>
                            <cfelse>
                                <cfquery name="PACKEGE_CONTROL" datasource="#DSN3#">
                                    SELECT     
                                        ISNULL(SUM(PAKETSAYISI), 0) AS PAKET_SAYISI, 
                                        ISNULL(SUM(CONTROL_AMOUNT), 0) AS CONTROL_AMOUNT
                                    FROM         
                                        (		
                                        SELECT     
                                            PAKET_SAYISI AS PAKETSAYISI, 
                                            PAKET_ID AS STOCK_ID, 
                                            BARCOD, 
                                            STOCK_CODE, 
                                            PRODUCT_NAME,
                                            (
                                            SELECT     
                                                SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                                            FROM          
                                                EZGI_SHIPPING_PACKAGE_LIST
                                            WHERE      
                                                TYPE = 2 AND 
                                                STOCK_ID = TBL.PAKET_ID AND 
                                                SHIPPING_ID = TBL.SHIP_RESULT_ID
                                            ) AS CONTROL_AMOUNT, SHIP_RESULT_ID
                                        FROM         
                                            (
                                            SELECT     
                                                SUM(PAKET_SAYISI) AS PAKET_SAYISI, 
                                                PAKET_ID, 
                                                BARCOD, 
                                                STOCK_CODE, 
                                                PRODUCT_NAME, 
                                                PRODUCT_TREE_AMOUNT, 
                                                SHIP_RESULT_ID
                                            FROM          
                                                (
                                                 SELECT     
                                                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                                    EPS.PAKET_ID, 
                                                    S.BARCOD, 
                                                    S.STOCK_CODE, 
                                                    S.PRODUCT_NAME, 
                                                    S.PRODUCT_TREE_AMOUNT, 
                                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
                                                    ESRR.ORDER_ROW_ID
                                                FROM          
                                                    SPECTS AS SP INNER JOIN
                                                    EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                                                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                                                    STOCKS AS S INNER JOIN
                                                    EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID INNER JOIN
                                                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                                                WHERE      
                                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #SHIP_RESULT_ID# AND
                                                    ISNULL(S1.IS_PROTOTYPE,0) = 1
                                                GROUP BY 
                                                    EPS.PAKET_ID, 
                                                    S.BARCOD, 
                                                    S.STOCK_CODE, 
                                                    S.PRODUCT_NAME, 
                                                    S.PRODUCT_TREE_AMOUNT, 
                                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                                                    ESRR.ORDER_ROW_ID
                                                UNION ALL  
                                                SELECT     
                                                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                                                    EPS.PAKET_ID, 
                                                    S.BARCOD, 
                                                    S.STOCK_CODE, 
                                                    S.PRODUCT_NAME, 
                                                    S.PRODUCT_TREE_AMOUNT, 
                                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
                                                    ESRR.ORDER_ROW_ID
                                                FROM          
                                                    EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                                                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                                                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                                    EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                                    STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                                                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                                                WHERE      
                                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #SHIP_RESULT_ID# AND
                                                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                                                GROUP BY 
                                                    EPS.PAKET_ID, 
                                                    S.BARCOD, 
                                                    S.STOCK_CODE, 
                                                    S.PRODUCT_NAME, 
                                                    S.PRODUCT_TREE_AMOUNT, 
                                                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                                                    ESRR.ORDER_ROW_ID
                                                ) AS TBL1
                                            GROUP BY 
                                                PAKET_ID, 
                                                BARCOD, 
                                                STOCK_CODE, 
                                                PRODUCT_NAME, 
                                                PRODUCT_TREE_AMOUNT, 
                                                SHIP_RESULT_ID
                                            ) AS TBL
                                        ) AS TBL2
                                </cfquery>
                            </cfif> 
                            <!-- sil -->
                            <td align="center">
                                 <cfif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI eq 0 and PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                    <img src="/images/plus_ques.gif" border="0" title="<cf_get_lang dictionary_id='29975.Barkod Yok'>">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI - PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                    <img src="/images/c_ok.gif" border="0" title="<cf_get_lang dictionary_id='330.Kontrol Edildi'>">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.CONTROL_AMOUNT eq 0>
                                    <img src="/images/caution_small.gif" border="0" title="<cf_get_lang dictionary_id='331.Kontrol Edilmedi'>">
                                 <cfelseif PACKEGE_CONTROL.recordcount AND PACKEGE_CONTROL.PAKET_SAYISI gt PACKEGE_CONTROL.CONTROL_AMOUNT>
                                    <img src="/images/warning.gif" border="0" title="<cf_get_lang dictionary_id='332.Kontrol Eksik'>">   
                                 </cfif>
                            </td>
                            <!-- sil -->
                    	</tr>
                    </cfoutput>
                <cfelse>
                	<tfoot>
                        <tr>
                            <td colspan="3" height="20">
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
    	<cfif isDefined('attributes.department_in_id') and len(attributes.department_in_id)>
        	<cfset adres = adres & '&department_in_id=' & attributes.department_in_id>
      	</cfif>
   		<cfif isdate(attributes.date1)>
        	<cfset adres = "#adres#&date1=#dateformat(attributes.date1,dateformat_style)#">
      	</cfif>
    	<cfif isdate(attributes.date2)>
        	<cfset adres = "#adres#&date2=#dateformat(attributes.date2,dateformat_style)#">
     	</cfif>
      	<cfif isDefined('attributes.kontrol_status') and len(attributes.kontrol_status) >
        	<cfset adres = "#adres#&kontrol_status=#attributes.kontrol_status#" >
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