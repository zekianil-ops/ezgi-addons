<!---
    File: add_ambar_fis_4.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description: İç Talep Bazlı Ambar Fişi - Sevk İrsaliyesi
--->
<cf_xml_page_edit>

<cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch_2'>
    <cfset default_process_type = 81> <!---Sevk İrsaliyesi--->
<cfelse>
    <cfset default_process_type = '113,111'> <!---Ambar Fişi--->
</cfif>
<cfparam name="attributes.anamenu" default="1">
<cfparam name="attributes.department_in_id" default="">
<cfparam name="attributes.process_cat_id" default="">
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<!---<cfset default_process_type = '113,111'>--->
<cfquery name="get_default_departments" datasource="#dsn#">
    SELECT        
        DEFAULT_MK_TO_RF_DEP, 
        DEFAULT_MK_TO_RF_LOC
    FROM            
        EZGI_PDA_DEPARTMENT_DEFAULTS
    WHERE        
        EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfset default_departments = '#get_default_departments.DEFAULT_MK_TO_RF_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
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
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID AND
        B.COMPANY_ID=#session.ep.company_id# 
</cfquery>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT DISTINCT  
    	SPC.PROCESS_CAT_ID,
        SPC.PROCESS_CAT
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE IN (#default_process_type#) AND 
        SPCF.FUSE_NAME = 'pda.form_add_ambar_fis' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>

<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		history.back();	
	</script>
</cfif>
<cfif not isdefined('attributes.internaldemand_no')>
	<cfquery name="get_period" datasource="#dsn#">
            SELECT     
                TOP (2)
                PERIOD_YEAR
            FROM         
                SETUP_PERIOD WITH (NOLOCK)
            WHERE     
                OUR_COMPANY_ID = #session.ep.company_id#
            ORDER BY
                PERIOD_YEAR desc      
 	</cfquery>
    <cfset our_company_years = Valuelist(get_period.PERIOD_YEAR)>
    <cfquery name="GET_INTERNALDEMAND" datasource="#dsn3#">
    	SELECT
        	INTERNAL_ID, 
            INTERNAL_NUMBER
      	FROM
        	(
            SELECT
                INTERNAL_ID, 
                INTERNAL_NUMBER,
                STOCK_ID,
                CASE
                    WHEN 
                        QUANTITY > AMBAR_STOCK	
                    THEN
                        1
                    ELSE
                        0
                END AS  DURUM
            FROM
                (
                SELECT
                    INTERNAL_ID, 
                    INTERNAL_NUMBER,
                    STOCK_ID,
                    SUM(QUANTITY) AS QUANTITY,
                    SUM(AMBAR_STOCK) AS AMBAR_STOCK
                FROM
                    (
                    SELECT 
                        I.INTERNAL_ID, 
                        I.SUBJECT, 
                        I.PRIORITY, 
                        I.TARGET_DATE, 
                        I.REF_NO, 
                        I.INTERNAL_NUMBER,
                        IRR.QUANTITY, 
                        IRR.STOCK_ID,
                        ISNULL((
                            SELECT
                                SUM(AMOUNT) AS AMBAR_STOCK
                            FROM
                                (      
                                <cfloop list="#our_company_years#" index="comp_ii">
                                	<cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch_2'><!---Sevk İrsaliyesi--->
                                    	 SELECT     
                                            SHR.AMOUNT,
                                            SHR.STOCK_ID
                                        FROM    
                                            #dsn#_#comp_ii#_#session.ep.company_id#.SHIP AS SH INNER JOIN
                                            #dsn#_#comp_ii#_#session.ep.company_id#.SHIP_ROW AS SHR ON SH.SHIP_ID = SHR.SHIP_ID     
                                        WHERE     
                                            SH.SHIP_TYPE IN (81) AND 
                                            SHR.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID AND
                                            SHR.STOCK_ID = IRR.STOCK_ID
                                            <cfif listlen(our_company_years) neq 1 and comp_ii neq listlast(our_company_years,',')> UNION ALL </cfif>
                                   	<cfelse><!---Ambar Fişi--->
                                        SELECT     
                                            SR.AMOUNT,
                                            SR.STOCK_ID
                                        FROM         
                                            #dsn#_#comp_ii#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                                            #dsn#_#comp_ii#_#session.ep.company_id#.STOCK_FIS_ROW AS SR WITH (NOLOCK) ON SF.FIS_ID = SR.FIS_ID
                                        WHERE     
                                            SF.FIS_TYPE IN (113,111) AND 
                                            SR.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID AND
                                            SR.STOCK_ID = IRR.STOCK_ID
                                            <cfif listlen(our_company_years) neq 1 and comp_ii neq listlast(our_company_years,',')> UNION ALL </cfif>
                        			</cfif>                   
                                </cfloop>
                                 ) AS TBL
                        ),0) AS AMBAR_STOCK
                    FROM     
                        INTERNALDEMAND AS I WITH (NOLOCK) INNER JOIN
                        INTERNALDEMAND_ROW AS IRR WITH (NOLOCK) ON I.INTERNAL_ID = IRR.I_ID INNER JOIN
                        STOCKS AS S WITH (NOLOCK) ON IRR.STOCK_ID = S.STOCK_ID
                    WHERE  
                    	I.IS_ACTIVE = 1 AND
                        YEAR(I.TARGET_DATE) IN (#our_company_years#)
                    	<cfif isdefined('x_author_control') and ListLen(x_author_control)>
                    		AND I.INTERNALDEMAND_STAGE IN (#x_author_control#) 
                        </cfif>
                        <cfif isdefined('x_to_who_control') and x_to_who_control eq 1>
                            AND I.TO_POSITION_CODE = 
                                            (
                                                SELECT 
                                                    POSITION_CODE
                                                FROM     
                                                    #dsn_alias#.EMPLOYEE_POSITIONS
                                                WHERE  
                                                    EMPLOYEE_ID = #session.ep.userid#
                                            )
                  		</cfif>
                    ) AS TBL
                GROUP BY
                    INTERNAL_ID, 
                    INTERNAL_NUMBER,
                    STOCK_ID	
                ) AS TBL_1
        	) AS TBL_2
     	WHERE
        	DURUM <>0
 		GROUP BY
        	INTERNAL_ID, 
            INTERNAL_NUMBER           
    </cfquery>
    <cfif not GET_INTERNALDEMAND.recordcount>
		<script type="text/javascript">
			<cfif isdefined('x_to_who_control') and x_to_who_control eq 1>
            	alert("Tarafınıza Gelen İç Talep Bulunamadı");
			<cfelse>
				alert("İç Talep Bulunamadı");
			</cfif>
        </script>
        <cfabort>
    <cfelse>
    	<cfset internaldemand_list = ''>
    	<cfoutput query="GET_INTERNALDEMAND">
        	<cfset internaldemand_row = '#INTERNAL_NUMBER#*#INTERNAL_ID#'>
        	<cfset internaldemand_list = Listappend(internaldemand_list,internaldemand_row)>
        </cfoutput>
    </cfif>
    <cfset get_shelf.recordcount = 0>
<cfelse>
	<cfquery name="get_period" datasource="#dsn#">
            SELECT     
                TOP (2)
                PERIOD_YEAR
            FROM         
                SETUP_PERIOD WITH (NOLOCK)
            WHERE     
                OUR_COMPANY_ID = #session.ep.company_id#
            ORDER BY
                PERIOD_YEAR desc      
 	</cfquery>
    <cfset our_company_years = Valuelist(get_period.PERIOD_YEAR)>
	<cfquery name="GET_INTERNALDEMAND_ROW" datasource="#dsn3#">
		SELECT 
        	I.REF_NO, 
            I.INTERNAL_NUMBER, 
            IRR.STOCK_ID, 
            IRR.UNIT, 
            SS.SPECT_MAIN_ID, 
            S.PRODUCT_NAME, 
            S.PRODUCT_CODE, 
            S.BARCOD,
            I.DEPARTMENT_IN,
            I.LOCATION_IN,
            I.DEPARTMENT_OUT,
            I.LOCATION_OUT,
            SUM(IRR.QUANTITY) IC_TALEP,
            ISNULL((
            	SELECT 
                	PRODUCT_STOCK
				FROM     
                	#dsn2_alias#.EZGI_GET_STOCK_LOCATION_TOTAL
              	WHERE
                	STOCK_ID= S.STOCK_ID 
                    <cfif len(attributes.department_out_id)>
                    	AND DEPO = '#attributes.department_out_id#'
                    </cfif>
            ),0) AS PRODUCT_STOCK,
            ISNULL((
            	SELECT
                    SUM(AMOUNT) AS AMBAR_STOCK
                FROM
                    (      
                    <cfloop list="#our_company_years#" index="comp_ii">
                    	<cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch_2'><!---Sevk İrsaliyesi--->
                          	SELECT     
                            	SHR.AMOUNT,
                            	SHR.STOCK_ID
                         	FROM    
                              	#dsn#_#comp_ii#_#session.ep.company_id#.SHIP AS SH INNER JOIN
                             	#dsn#_#comp_ii#_#session.ep.company_id#.SHIP_ROW AS SHR ON SH.SHIP_ID = SHR.SHIP_ID     
                         	WHERE     
                            	SH.SHIP_TYPE IN (81) AND 
                             	SHR.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID AND
                             	SHR.STOCK_ID = IRR.STOCK_ID
                      			<cfif listlen(our_company_years) neq 1 and comp_ii neq listlast(our_company_years,',')> UNION ALL </cfif>
                 		<cfelse><!---Ambar Fişi--->
                           	SELECT     
                                SR.AMOUNT,
                                SR.STOCK_ID
                            FROM         
                                #dsn#_#comp_ii#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                                #dsn#_#comp_ii#_#session.ep.company_id#.STOCK_FIS_ROW AS SR WITH (NOLOCK) ON SF.FIS_ID = SR.FIS_ID
                            WHERE     
                                SF.FIS_TYPE IN (113,111) AND 
                                SR.WRK_ROW_RELATION_ID = IRR.WRK_ROW_ID AND
                                SR.STOCK_ID = IRR.STOCK_ID
                                <cfif listlen(our_company_years) neq 1 and comp_ii neq listlast(our_company_years,',')> UNION ALL </cfif>         
               			</cfif>
                    </cfloop>
                     ) AS TBL
            ),0) AS AMBAR_STOCK
		FROM     
        	INTERNALDEMAND AS I WITH (NOLOCK) INNER JOIN
            INTERNALDEMAND_ROW AS IRR WITH (NOLOCK) ON I.INTERNAL_ID = IRR.I_ID INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON IRR.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
            SPECTS AS SS WITH (NOLOCK) ON IRR.SPECT_VAR_ID = SS.SPECT_VAR_ID
		WHERE  
        	I.INTERNAL_ID = #attributes.internaldemand_no#
       	GROUP BY
        	I.DEPARTMENT_IN,
            I.LOCATION_IN,
            I.DEPARTMENT_OUT,
            I.LOCATION_OUT,
        	S.BARCOD,
        	I.REF_NO, 
            I.INTERNAL_NUMBER, 
            IRR.STOCK_ID, 
            IRR.UNIT, 
            IRR.WRK_ROW_ID,
            SS.SPECT_MAIN_ID, 
            S.PRODUCT_NAME, 
            S.PRODUCT_CODE,
            S.STOCK_ID
      	ORDER BY
        	S.PRODUCT_NAME
	</cfquery>
	<cfif GET_INTERNALDEMAND_ROW.recordcount and len(GET_INTERNALDEMAND_ROW.DEPARTMENT_OUT) and len(GET_INTERNALDEMAND_ROW.LOCATION_OUT)>
    	<cfset attributes.department_out_id ="#GET_INTERNALDEMAND_ROW.DEPARTMENT_OUT#-#GET_INTERNALDEMAND_ROW.LOCATION_OUT#">
    <cfelse> 
    	<cfset attributes.department_out_id = "#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
    </cfif>
   	<cfif GET_INTERNALDEMAND_ROW.recordcount and len(GET_INTERNALDEMAND_ROW.DEPARTMENT_IN) and len(GET_INTERNALDEMAND_ROW.LOCATION_IN)>
    	<cfset attributes.department_in_id = "#GET_INTERNALDEMAND_ROW.DEPARTMENT_IN#-#GET_INTERNALDEMAND_ROW.LOCATION_IN#">
    <cfelse> 
    	<cfset attributes.department_in_id ="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
    </cfif>
    <cfset stock_id_list = ValueList(GET_INTERNALDEMAND_ROW.STOCK_ID)>
    <cfset barcod_list = ValueList(GET_INTERNALDEMAND_ROW.BARCOD)>
    <cfquery name="get_shelf" datasource="#dsn3#">
    	SELECT TOP (1) PRODUCT_PLACE_ID FROM EZGI_PRODUCT_PLACE WHERE DEPO = '#attributes.department_out_id#'
    </cfquery>
</cfif>

<script language="javascript" type="text/javascript">
	var row_count = 0;
  	var barcod = '';
  	var stockid = '';
  	var spectmainid = 0;
  	var stockcode = '';
  	var amount = '';
  	var cikar = 0;
  	var islemtipi = 0;//0-ekle 1-çıkar
  	var buton = 0;// <1-buton pasif, >0-buton aktif
</script>
<cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch_2'>
	<cfsavecontent variable="title">
    	<cf_get_lang dictionary_id="1389.İç Talep Bazlı Sevk İrsaliyesi">
    	<cfoutput><cfif isdefined('attributes.internaldemand_no')> : #GET_INTERNALDEMAND_ROW.INTERNAL_NUMBER#</cfif></cfoutput>
    </cfsavecontent>
<cfelse>
	<cfsavecontent variable="title">
    	<cf_get_lang dictionary_id="1321.İç Talep Bazlı Ambar Fişi">
        <cfoutput><cfif isdefined('attributes.internaldemand_no')> : #GET_INTERNALDEMAND_ROW.INTERNAL_NUMBER#</cfif></cfoutput>
  	</cfsavecontent>
</cfif>
<cfform name="form_basket" id="form_basket">
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    	<cf_box scroll="0">
        	<cfinput id="ekle" type="hidden" name="ekle" value="0">
          	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
            <cfif get_shelf.recordcount>
            	<cfinput id="is_dept_shelf" type="hidden" name="is_dept_shelf" value="1">
         	<cfelse>
            	<cfinput id="is_dept_shelf" type="hidden" name="is_dept_shelf" value="0">
            </cfif>
          	<input type="hidden" name="active_period" value="#session.pda.period_id#" />
            <cfif isdefined('attributes.param')>
            	<cfinput id="param" type="hidden" name="param" value="#attributes.param#">
            </cfif>
            <cf_box_search>
            	<div class="col col-12" id="area_1" <cfif isdefined('attributes.internaldemand_no')>style="display:none"</cfif>>
                  	<div class="col col-4">
                     	<label><cf_get_lang dictionary_id='43583.İç Talep No'></label>
               		</div>
                    <cfif x_demand_control eq 0> <!---İç Talep No Seçerek--->
                        <div class="col col-6">
                            <div class="form-group">
                                <cfif not isdefined('attributes.internaldemand_no')>
    
                                    <select name="internaldemand_no" id="internaldemand_no">
                                        <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        <cfoutput query="GET_INTERNALDEMAND">
                                            <option value="#INTERNAL_ID#">#INTERNAL_NUMBER#</option>	
                                        </cfoutput>
                                    </select>
                                </cfif>
                            </div>
                        </div>
                        <div class="col col-2">
                            <div class="form-group">
                                <input id="internaldemand_confirm" name="internaldemand_confirm" style="color:white" value="<cf_get_lang dictionary_id="58693.Seç">" type="button" onClick="internaldemand_area();" />
                            </div>
                            <div id="internaldemand_div"></div>
                        </div>
                 	<cfelse> <!---İç Talep No Girerek--->
                    	 <div class="col col-6">
                            <div class="form-group">
                            	<input type="text" name="internaldemand_number" id="internaldemand_number" value="" />
                                <input type="hidden" name="internaldemand_no" id="internaldemand_no" value="" />
                            </div>
                      	</div>
                        <div class="col col-2">
                            <div class="form-group">
                                <input type="button" id="internaldemand_confirm" name="internaldemand_confirm" style="color:white" value="<cf_get_lang dictionary_id="57565.Ara">"  onClick="internaldemand_search();" />
                            </div>
                            <div id="internaldemand_div"></div>
                        </div>
                    </cfif>
               	</div>
                 <div id="area_2" <cfif not isdefined('attributes.internaldemand_no')>style="display:none"</cfif>>
                    <div class="col col-12">
                        <div class="col col-2">
                            <cf_get_lang dictionary_id='57635.Miktar'>
                        </div>
                        <div class="col col-3">
                            <cf_get_lang dictionary_id='57633.Barkod'>
                        </div>
                        <div class="col col-3" id="shelf_head" <cfif not get_shelf.recordcount>style="display:none"</cfif>>
                            <cf_get_lang dictionary_id='36714.Raf'>
                        </div>
                        <div class="col col-4" id="shelf_amount_head" <cfif not get_shelf.recordcount>style="display:none"</cfif>>
                            <cf_get_lang dictionary_id="30002.Raf Dağılım">
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-2">
                            <div class="form-group">
                                <cfinput id="add_other_amount" name="add_other_amount" type="text" onfocus="islemtipi=0;" style=" text-align:right" maxlength="6" value="1" />
                            </div>
                        </div>
                        <div class="col col-3">
                            <div class="form-group">
                                <cfinput id="add_other_barcod" name="add_other_barcod" type="text"  maxlength="20" value="" />
                            </div>
                        </div>
                        <div class="col col-3" id="shelf" <cfif not get_shelf.recordcount>style="display:none"</cfif>>
                            <div class="form-group">
                                <cfinput id="add_other_shelf" name="add_other_shelf" type="text" onfocus="islemtipi=0;"  maxlength="20" value="" />
                            </div>
                        </div>
                        <div class="col col-4" id="shelf_amount" <cfif not get_shelf.recordcount>style="display:none"</cfif>>
                            <div class="form-group" id="shelf_select_td" style="display:none">
                                <select name="shelf_select" id="shelf_select" style="width:70px;height:20px;text-align:center">
                                    <option value=""><cf_get_lang dictionary_id='339.Ürün Rafları'></option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-6">
                            <cf_get_lang dictionary_id='29428.Çıkış Depo'>
                        </div>
                        <div class="col col-6">
                            <cf_get_lang dictionary_id='33658.Giriş Depo'>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-6">
                            <div class="form-group">
                                <select name="txt_department_out" id="txt_department_out" style="width:120px; height:20px" onchange="change_department_out(this.value)">
                                    <cfoutput query="get_all_location" group="department_id">
                                        <option disabled="disabled" value="#department_id#"<cfif attributes.department_out_id eq department_id>selected</cfif>>#department_head#</option>
                                    <cfoutput>
                                    <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_out_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif></option>
                                    </cfoutput> 
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="col col-6">
                            <div class="form-group">
                                <select name="txt_department_in" style="width:120px; height:20px" onchange="document.getElementById('department_in').value = this.value">
                                    <cfoutput query="get_all_location" group="department_id">
                                       <option disabled="disabled"  value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                                    <cfoutput>
                                    <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif></option>
                                    </cfoutput> 
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-12">
                            <cf_get_lang dictionary_id='45271.Fiş Tipi'>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-12">
                            <div class="form-group">
                                <select name="process_cat_id" id="process_cat_id" style="height:20px">
                                	<cfoutput query="get_process_cat">
                                    	<option value="#PROCESS_CAT_ID#"<cfif attributes.process_cat_id eq PROCESS_CAT_ID>selected</cfif>>#PROCESS_CAT#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
          	</cf_box_search>
        </cf_box>
        <cfsavecontent variable="sekme1">Stok Fişi</cfsavecontent>
        <cfsavecontent variable="sekme2">Kontrol</cfsavecontent>
        <div id="basket_main_div">
        	<div class="row">
                <div class="col col-12 uniqueRow">
                    <cf_basket_form id="upd_connect" class="row">
                        <div id="tab-container" class="tabStandart margin-top-5">
                            <div id="tab-head">
                                <ul class="tabNav">
                                    <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_liste" href="#liste"><cfoutput>#sekme1#</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_kontrol" href="#kontrol"><cfoutput>#sekme2#</cfoutput></a></li>
                                </ul>
                            </div>
                            <div id="tab-content" class="margin-top-10"> 
                                <div id="liste" class="content row">
                                    <cf_box title="#title#">
                                    	<cf_form_list>
                                            <thead>
                                                <tr>
                                                    <th style="width:20%"><cf_get_lang dictionary_id='57633.Barkod'></th>
                       								<th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        							<th style="width:15%"><cf_get_lang dictionary_id='57635.Miktar'></th>

                        							<th style="width:20%"><cf_get_lang dictionary_id='36714.Raf'></th>
                                                </tr>
                                            </thead>
                                            <form name="product_row" id="product_row" method="post">
                                                <tbody name="table1" id="table1">
                                                </tbody>
                                            </form>
        									<tfoot <cfif not isdefined('attributes.internaldemand_no')>style="display:none"</cfif>>
                                                <tr>	
                                                    <td colspan="4" id="onay_td" style="display:none">
                                                        <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit();" />
                                                    </td>
                                                </tr>
                							</tfoot>
                                       		<input type="hidden" id="department_in" name="department_in" value="<cfoutput>#attributes.department_in_id#</cfoutput>" />
                                         	<input type="hidden" id="department_out" name="department_out" value="<cfoutput>#attributes.department_out_id#</cfoutput>" />
                                        	<input type="hidden" id="row_count" name="row_count" value="0" />
                                       		<input type="hidden" id="action_id" name="action_id" value="" />
        								</cf_form_list>
                                  	</cf_box>
                              	</div>
                           		<div id="kontrol" class="content row">
									<cf_box title="#title#">
                                        <cf_grid_list>
                                        	<thead>
                                                <tr>
                                                	<th ><cf_get_lang dictionary_id='58577.Sıra'></th>
                       								<th ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                    <th >Depo</th>
                        							<th ><cf_get_lang dictionary_id='57635.Miktar'></th>
                        							<th >CNT</th>
                                                    <th >Kalan</th>
                                                </tr>
                                            </thead>
                                            <tbody name="table2" id="table2">
                                            	<cfif isdefined('attributes.internaldemand_no') and GET_INTERNALDEMAND_ROW.recordcount>
                                                	<cfinput type="hidden" id="row_count_content" name="row_count_content" value="#GET_INTERNALDEMAND_ROW.recordcount#">
                                                	<cfoutput query="GET_INTERNALDEMAND_ROW">
                                                    	<tr id="row#currentrow#" height="20">
                                                        	<td style="text-align:left">
                                                            	<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1" >
                                                                <input name="STOCK_ID#currentrow#" id="STOCK_ID#currentrow#" type="hidden" value="#STOCK_ID#">
                                                                <input name="SPECT_MAIN_ID#currentrow#" id="SPECT_MAIN_ID#currentrow#" type="hidden" value="#SPECT_MAIN_ID#">
                                                                <input name="row_number#currentrow#" type="text" value="#currentrow#" style="width:10px">
                                                            </td>
                                                            <td style="text-align:left"><input name="PRODUCT_NAME#currentrow#" id="PRODUCT_NAME#currentrow#" type="text" value="#PRODUCT_NAME#"></td>
                                                            <td style="text-align:right"><b>#PRODUCT_STOCK#</b></td>
                                                            <td style="text-align:right">
                                                            	<input name="MIKTAR#currentrow#" id="MIKTAR#currentrow#" type="text" value="#IC_TALEP#" style="text-align:right; width:40px">
                                                            </td>
                                                            <td style="text-align:right">
                                                            	<input name="KONTROL#currentrow#" id="KONTROL#currentrow#" type="text" value="#AMBAR_STOCK#" style="text-align:right; width:40px">
                                                            </td>
                                                            <td style="text-align:right">
                                                            	<input name="KALAN#currentrow#" id="KALAN#currentrow#" type="text" value="#IC_TALEP-AMBAR_STOCK#" style="text-align:right; width:40px">
                                                            </td>
                                                        </tr>
                                                    </cfoutput>
                                                </cfif>
                                            </tbody>
                                        </cf_grid_list>
                                    </cf_box>
                                </div>
                            </div>
                      	</div>
        			</cf_basket_form>
                </div>
           	</div>                     
       	</div>            
    </div>
</cfform>
<script language="javascript" type="text/javascript">
	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);	
	document.onkeydown = checkKeycode
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			<cfif isdefined('attributes.internaldemand_no')><!--- İç Talep Submit edilmişse--->
				if (document.getElementById('add_other_barcod').value.length == '' && document.getElementById('add_other_shelf').value.length >0)
				{
					alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').focus();	
				
				}
				else
				{
					if(document.getElementById('is_dept_shelf').value==1)<!--- Eğer Depo Raflı ise--->
					{
						if (document.getElementById('add_other_barcod').value.length >0 && document.getElementById('add_other_shelf').value.length >0)	
							search_shelf(document.getElementById('add_other_shelf').value);
						else
							get_stock(document.getElementById('add_other_barcod').value);
					}
					else <!--- Eğer Depo Raflı Değil ise--->
						get_stock(document.getElementById('add_other_barcod').value);
				}
			<cfelse><!--- İç Talep Submit edilmemişse--->
				internaldemand_search();
			</cfif>
		}
	}
	function get_stock(barcode)
    {
	 	carpan = ''; birim = ''; barcod = ''; stockid = ''; stockcode = ''; spectmainid = 0; //ilk önce sıfırlıyoruz
		k_= 0;
		if(document.getElementById('add_other_amount').value.length == 0)
		{
			alert('<cf_get_lang dictionary_id='29943.Lütfen miktar giriniz.'>');
			k_=1;
			return false;
		}
	 	if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
			barcode = barcode.substring(1,length(barcode));
		uzunluk = barcode.length;
		spectmainid = 0;
		ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
		if(uzunluk > ean)
		{
			spectmainid = barcode.substring(ean,uzunluk);
			barcode = barcode.substring(0,ean);
		}
		<cfif isdefined('attributes.internaldemand_no')>
			if(list_find('<cfoutput>#barcod_list#</cfoutput>',barcode,','))
			{
				
			}
			else
			{
				alert("İç Talepte Olmayan Ürün: "+barcode);
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_shelf').value = '';
				document.getElementById('add_other_barcod').focus();
				k_ = 1;
				return false;
				
			}
		</cfif>
	 	if (k_ == 0)
     	{
			/*var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME,S.IS_PROTOTYPE FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";
			var get_product = wrk_query(new_sql,'dsn3');*/
			
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
			
		 	if (get_product.STOCK_ID == undefined)
		 	{
				document.getElementById('ekle').value = 1;
				alert('<cf_get_lang dictionary_id='341.Ürün Bulunamadı'>');
		 	}
		 	else
		 	{	
				if(get_product.IS_PROTOTYPE==1 && spectmainid==0)
				{
					alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
				}
				else
				{
					carpan = get_product.MULTIPLIER;
					birim = get_product.MAIN_UNIT;
					stockid = get_product.STOCK_ID;
					stockcode = get_product.PRODUCT_NAME;
					document.getElementById('add_other_shelf').focus();
					if(document.getElementById('is_dept_shelf').value==1)<!--- Eğer Depo Raflı ise--->
					{
						set_shelfs(stockid,spectmainid);
					}
					else<!--- Eğer Depo Raflı Değil ise--->
					{
						add_row(barcode);
					}
				}
    		}
		}
		else
		{
			carpan = ''; birim = ''; barcod = ''; stockid = ''; stockcode = ''; spectmainid = 0;
			return false;
		}
	}
	function add_amount()
	{
		if(document.getElementById('is_dept_shelf').value==1)<!--- Eğer Depo Raflı ise--->
		{
			if(spectmainid==0)
			{
				/*var shelf_sql="SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+document.getElementById('add_other_shelf').value+"' AND STOCK_ID = "+stockid+" AND REAL_STOCK > 0 ORDER BY REAL_STOCK DESC";*/
				var listParam = document.getElementById('add_other_shelf').value+ "*" +stockid;
				var get_shelf_amount = wrk_safe_query('get_shelf_stock_stock_id_ezgi','dsn2',0,listParam);
			}
			else
			{
				/*var shelf_sql="SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+document.getElementById('add_other_shelf').value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid+" AND REAL_STOCK > 0 ORDER BY REAL_STOCK DESC";*/
				var listParam = document.getElementById('add_other_shelf').value+ "*" +stockid+ "*" +spectmainid;
				var get_shelf_amount = wrk_safe_query('get_shelf_stock_spectmainid_ezgi','dsn2',0,listParam);
			}
			/*var get_shelf_amount = wrk_query(shelf_sql,'dsn2');*/
			control_amount=get_shelf_amount.REAL_STOCK;
			if(get_shelf_amount.recordcount)
			{
				if(row_count >0) /*ilk Satırdan sonrası*/
				{
					for(i=1;i<=row_count;i++)
					{
						if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid && document.getElementById('shelf_code'+i).value == shelf_code)
							control_amount=control_amount-document.getElementById('amount'+i).value;
					}
					control_amount=control_amount-document.getElementById('add_other_amount').value;
					if(control_amount*1<0*1)
					{
						document.getElementById('ekle').value=1;
						alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: "+get_shelf_amount.REAL_STOCK);
						document.getElementById('add_other_amount').value = 1;
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
						return false;
					}
				}
				else
				{
					control_amount=control_amount-document.getElementById('add_other_amount').value;
					if(control_amount*1<0*1)
					{
						document.getElementById('ekle').value=1;
						alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: "+get_shelf_amount.REAL_STOCK);
						document.getElementById('add_other_amount').value = 1;
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
						return false;
					}	
				}
			}
			else
			{
				document.getElementById('ekle').value=1;
				alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: 0");
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_shelf').value = '';
				document.getElementById('add_other_barcod').focus();
				return false;
			}
			if (document.getElementById('ekle').value==0)
			{
				document.getElementById('shelf_select_td').style.display='none';
				if(row_count*1>0*1) /*ilk Satırdan sonrası*/
				{
					for(i=1;i<=row_count;i++)
					{
						if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid && document.getElementById('shelf_code'+i).value == shelf_code)
						{
							document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
							if (document.getElementById('frm_row'+i).style.display == 'none')
									document.getElementById('frm_row'+i).style.display='block';
							document.getElementById('ekle').value=1;
						}
					}
				}
				else
					document.getElementById('txt_department_out').disabled = true;
			}
		}
		else <!--- Eğer Depo Raflı Değil ise--->
		{
			if(spectmainid==0)
			{
				var listParam = document.getElementById('department_out').value+ "*" +stockid;
				var get_depo_amount = wrk_safe_query('get_depo_stock_stock_id_ezgi','dsn2',0,listParam);
			}
			else
			{
				var listParam = document.getElementById('department_out').value+ "*" +spectmainid;
				var get_depo_amount = wrk_safe_query('get_depo_stock_spectmainid_ezgi','dsn2',0,listParam);
			}
			control_amount=get_depo_amount.PRODUCT_STOCK;
			if(get_depo_amount.recordcount)
			{
				if(row_count >0) /*ilk Satırdan sonrası*/
				{
					for(i=1;i<=row_count;i++)
					{
						if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid)
							control_amount=control_amount-document.getElementById('amount'+i).value;
					}
					control_amount=control_amount-document.getElementById('add_other_amount').value;
					if(control_amount*1<0*1)
					{
						document.getElementById('ekle').value=1;
						alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Çıkış Deposundaki Stok Miktarı : "+get_depo_amount.PRODUCT_STOCK);
						document.getElementById('add_other_amount').value = 1;
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_barcod').focus();
						return false;
					}
				}
				else
				{
					control_amount=control_amount-document.getElementById('add_other_amount').value;
					if(control_amount*1<0*1)
					{
						document.getElementById('ekle').value=1;
						alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>.  Çıkış Deposundaki Stok Miktarı : "+get_depo_amount.PRODUCT_STOCK);
						document.getElementById('add_other_amount').value = 1;
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_barcod').focus();
						return false;
					}	
				}
			}
			else
			{
				document.getElementById('ekle').value=1;
				alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Çıkış Deposundaki Stok Miktarı : 0");
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();
				return false;
			}
			if (document.getElementById('ekle').value==0)
			{
				amount_control(stockid,spectmainid);
				document.getElementById('shelf_select_td').style.display='none';
				if(row_count >0) /*ilk Satırdan sonrası*/
				{
					for(i=1;i<=row_count;i++)
					{
						if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid )
						{
							document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
							if (document.getElementById('frm_row'+i).style.display == 'none')
								document.getElementById('frm_row'+i).style.display='block';
							document.getElementById('ekle').value=1;
						}
					}
				}
				else
					document.getElementById('txt_department_out').disabled = true;
			}
		}
	}
	function add_row(barcode)
	{
		if (k_==0)
		{
			amount = document.getElementById('add_other_amount').value;
			if(amount == 0)
			{
				alert('<cf_get_lang dictionary_id='344.Miktar 0 dan Büyük Olmalıdır'>.');
				document.getElementById('shelf_select_td').style.display='none';
				return false;
			}
			add_amount();
			if (document.getElementById('ekle').value == 0)
			{
				row_count++;
				document.getElementById('row_count').value = row_count;
				var newRow;
				var newCell;	
				newRow = document.getElementById("table1").insertRow(document.getElementById("table1").rows.length);
				newRow.setAttribute("name","frm_row" + row_count);
				newRow.setAttribute("id","frm_row" + row_count);		
				newRow.setAttribute("NAME","frm_row" + row_count);
				newRow.setAttribute("ID","frm_row" + row_count);		
				
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" readonly="yes" style="border:none;height:20px" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+stockcode+'" name="stockcode'+row_count+'" id="stockcode'+row_count+'" size="13" readonly="yes" style="border:none" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" style="text-align:right;border:none" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" readonly="yes"  style="text-align:" />';
				newCell = newRow.insertCell();
				if(document.getElementById('is_dept_shelf').value==1)<!--- Eğer Depo Raflı ise--->
					newCell.innerHTML = '<input type="text" value="'+shelf_code+'" name="shelf_code'+row_count+'" id="shelf_code'+row_count+'" size="12" readonly="yes" style="text-align:right;border:none" />';
				else
					newCell.innerHTML = '<input type="text" value="" name="shelf_code'+row_count+'" id="shelf_code'+row_count+'" size="12" readonly="yes" style="text-align:right;border:none" />';
			
				document.getElementById('onay_td').style.display='';
			}
			else
				document.getElementById('ekle').value = 0;
				
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_amount').value = 1;
			document.getElementById('add_other_barcod').focus();
		}
	}
	function search_shelf(shelf_8)
	{
		var cikis_depo = document.all.txt_department_out.value;
		/*var shelf_sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '"+shelf_8+"'";
		var get_shelf = wrk_query(shelf_sql,'dsn3');*/
		
		var listParam = shelf_8;
		var get_shelf = wrk_safe_query('get_amount_shelf_amount_ezgi','dsn3',0,listParam);
		if(get_shelf.recordcount)
		{
			var cikis_depo_s = get_shelf.STORE_ID.toString()+'-'+get_shelf.LOCATION_ID.toString();
			if(cikis_depo != cikis_depo_s)
			{
					alert('<cf_get_lang dictionary_id='345.Seçtiğiniz Raf Giriş Lokasyonunda Yoktur'>!');	
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('add_other_barcod').focus();	
			}
			else
			{
				if (document.getElementById('add_other_barcod').value.length > 0)
				{
					barcode = document.getElementById('add_other_barcod').value;
					shelf_code = document.getElementById('add_other_shelf').value;
					buton_kontrol();
					document.getElementById('txt_department_out').disabled = true;
					add_row(barcode);
				}
				else if (document.getElementById('add_other_barcod').value.length == 0)
				{
						document.getElementById('add_other_barcod').focus();	
				}
				else
				{
						alert('<cf_get_lang dictionary_id='347.Ürün Barkodu Hatalı'>');
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
				}
			}
		}
		else
		{
			alert('<cf_get_lang dictionary_id='348.Seçtiğiniz Raf Hiç Tanımlanmamış'>!');
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_shelf').focus();
		}
	}
	function set_shelfs(stockid,spectmainid)
	{
		document.getElementById('shelf_select_td').style.display='';
		if(spectmainid==0)
		{
			/*var product_shelfs="SELECT REAL_STOCK,SHELF_CODE,PRODUCT_PLACE_ID FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID = "+stockid+" AND REAL_STOCK > 0 ORDER BY REAL_STOCK DESC";*/
			var listParam = form_basket.txt_department_out.value+ "*" +stockid;
			var get_product_shelfs = wrk_safe_query('get_shelf_depo_stock_id_ezgi','dsn2',0,listParam);
		}
		else
		{
			/*var product_shelfs="SELECT REAL_STOCK,SHELF_CODE,PRODUCT_PLACE_ID FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid+" AND REAL_STOCK > 0 ORDER BY REAL_STOCK DESC";*/
			var listParam = form_basket.txt_department_out.value+ "*" +stockid+ "*" +spectmainid;
			var get_product_shelfs = wrk_safe_query('get_shelf_depo_spectmainid_ezgi','dsn2',0,listParam);
		}
		/*var get_product_shelfs = wrk_query(product_shelfs,'dsn2');*/
		
		var option_count = document.getElementById('shelf_select').options.length; 
		for(x=option_count;x>=0;x--)
			document.getElementById('shelf_select').options[x] = null;
		if(get_product_shelfs.recordcount != 0)
		{	
			for(var xx=0;xx<get_product_shelfs.recordcount;xx++)
			{
				document.getElementById('shelf_select').options[xx]=new Option(get_product_shelfs.SHELF_CODE[xx]+"-"+get_product_shelfs.REAL_STOCK[xx],get_product_shelfs.PRODUCT_PLACE_ID[xx],get_product_shelfs.REAL_STOCK[xx]);
			}
		}
		else
		{
			document.getElementById('shelf_select').options[0] = new Option('Raf Tanımsız','');
			alert('Seçtiğiniz Ürün Lokasyondaki Raflarda Yoktur');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_barcod').focus();
		}
		
	}
	function amount_control(stockid,spectmainid)
	{
		row_count_content = document.getElementById('row_count_content').value;
		for(i=1;i<=row_count_content;i++)
		{
			if(document.getElementById('STOCK_ID'+i).value==stockid)
			{
				document.getElementById('KONTROL'+i).value = (document.getElementById('KONTROL'+i).value*1)+(document.getElementById('add_other_amount').value*1);
				document.getElementById('KALAN'+i).value = (document.getElementById('KALAN'+i).value*1)-(document.getElementById('add_other_amount').value*1);
				if(document.getElementById('KALAN'+i).value < 0)
				{
					sor=confirm('Fazla Çıkış Yapmaktasınız. İşlemi Geri Alıyorum?')
					if(sor==true)
					{
						document.getElementById('KONTROL'+i).value = (document.getElementById('KONTROL'+i).value*1)-(document.getElementById('add_other_amount').value*1);
						document.getElementById('KALAN'+i).value = (document.getElementById('KALAN'+i).value*1)+(document.getElementById('add_other_amount').value*1);
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
						document.getElementById('ekle').value=1;
						return false;
					}
				}
			}
		}
	}
	function kontrol_kayit()
	{
		if(form_basket.txt_department_in.value == "")
		{
			alert('<cf_get_lang dictionary_id='57723.Önce Depo Seçmelisiniz'>');
			return false;
		}
		else if(form_basket.txt_department_in.value.indexOf('-') == -1)
		{
			alert('<cf_get_lang dictionary_id='349.Lütfen giriş için doğru depo seçiniz'>');
			return false;
		}
		else
		{
			actionidolustur();
			<cfif isdefined('attributes.internaldemand_no')>
				<cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch_2'><!---Sevk İrsaliyesi--->
					window.location.href='<cfoutput>#request.self#?fuseaction=pda.emptypopup_add_ezgi_ship_dispatch&dispatch=2&e_internaldemand_id=#attributes.internaldemand_no#&ref_no=#GET_INTERNALDEMAND_ROW.INTERNAL_NUMBER#</cfoutput>&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value;
				<cfelse><!---Ambar Fişi--->
					window.location.href='<cfoutput>#request.self#?fuseaction=pda.add_ambar_fis&e_internaldemand_id=#attributes.internaldemand_no#&ref_no=#GET_INTERNALDEMAND_ROW.INTERNAL_NUMBER#&ambarfis=13<cfif isdefined('attributes.param')>&param= and attributes.param</cfif></cfoutput>&tersfis=1&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value;
				</cfif>
			</cfif>
		}
	}
	function actionidolustur()
	{
	  	var j = 0;
	  	for(i=1;i<=row_count;i++)
	  	{
		  	if(document.getElementById('amount'+i).value > 0)
		  	{
				if (j > 0)
				document.getElementById('action_id').value = document.getElementById('action_id').value + ',';
				document.getElementById('action_id').value = document.getElementById('action_id').value + i + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('stockid'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('amount'+i).value + '-';
				if(document.getElementById('is_dept_shelf').value==1)<!--- Eğer Depo Raflı ise--->
					document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('shelf_code'+i).value + '-';
				else
					document.getElementById('action_id').value = document.getElementById('action_id').value +'0'+ '-';
					
				document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('spectmainid'+i).value;
				j++;
		  	}
		  	document.getElementById('row_count').value = j;
	  	}
	}
	function internaldemand_area()
	{
		<cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch_2'>
			document.getElementById("form_basket").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ezgi_ship_dispatch_2";
		<cfelse>
			document.getElementById("form_basket").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis_4";
		</cfif>
		document.getElementById("form_basket").submit();
	}
	<cfif not isdefined('attributes.internaldemand_no')>
		function internaldemand_search()
		{
			
			if(document.getElementById('internaldemand_number').value =='')
			{
				document.getElementById('internaldemand_number').focus();
				alert('İç Talep Numarası Boş Olamaz!!!');
				return false;
			}
			else
			{
				internal_number = document.getElementById('internaldemand_number').value;
				internaldemand_list = <cfoutput>'#internaldemand_list#'</cfoutput>;
				list_row_count = list_len(internaldemand_list);
				if(list_row_count>0)
				{
					buldum = 0;
					for(i=1;i<=list_row_count;i++)
					{
						row_deger = list_getat(internaldemand_list,i);
						internal_num = list_getat(row_deger,1,'*');
						if(internal_num==internal_number)
						{
							buldum = 1;
							document.getElementById('internaldemand_no').value = list_getat(row_deger,2,'*');
							<cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch_2'>
								document.getElementById("form_basket").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ezgi_ship_dispatch_2";
							<cfelse>
								document.getElementById("form_basket").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis_4";
							</cfif>
							document.getElementById("form_basket").submit();
						}
					}
					if(buldum==0)
					{
						document.getElementById('internaldemand_number').focus();
						alert('İç Talep Bulunamadı!!!');
						return false;
					}
				}
				else
				{
					document.getElementById('internaldemand_number').focus();
					alert('İç Talep Bulunamadı!!!');
					return false;
				}
			}
		}
	</cfif>
	function change_department_out(out_dept)
	{
		document.getElementById('department_out').value = out_dept;
		/*var get_dep_is_shelfs="SELECT TOP (1) PRODUCT_PLACE_ID FROM EZGI_PRODUCT_PLACE WHERE DEPO = '+out_dept+'";*/
		var listParam = out_dept;
		var get_dep_is_shelfs = wrk_safe_query('get_is_shelf_depocode_ezgi','dsn3',0,listParam);
		if(get_dep_is_shelfs.recordcount)
		{
			document.getElementById('shelf_amount_head').style.display='';
			document.getElementById('shelf_head').style.display='';
			document.getElementById('shelf_amount').style.display='';
			document.getElementById('shelf').style.display='';
			document.getElementById('is_dept_shelf').value = 1;
		}
		else
		{
			document.getElementById('shelf_amount_head').style.display='none';
			document.getElementById('shelf_head').style.display='none';
			document.getElementById('shelf_amount').style.display='none';
			document.getElementById('shelf').style.display='none';
			document.getElementById('is_dept_shelf').value = 0;
		}
	}
</script>