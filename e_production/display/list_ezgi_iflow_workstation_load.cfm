<!---
    File: list_ezgi_iflow_workstation_load.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cfif isdefined('attributes.form_send_value') and attributes.form_send_value eq 1>
	<cfif len(attributes.form_send_date) and Listlen(attributes.form_send_id_list)>
    	<cf_date tarih="attributes.form_send_date">
    	<cftransaction>
            <cfloop list="#attributes.form_send_id_list#" index="p_id">
                <cfquery name="upd_p_operation_station_start_date" datasource="#dsn3#">
                	UPDATE 
                    	PRODUCTION_OPERATION
					SET          
                    	O_STATION_START_DATE = #attributes.form_send_date#
					WHERE  
                    	P_OPERATION_ID = #p_id#
                </cfquery>
            </cfloop>
        </cftransaction>
    </cfif>
</cfif>
<style>
	body{
		background:white!important;
	}
	.box_yazi {font-size:16px;font:bold} 
	.box_yazi_td {font-size:17px!important;font-weight:bold!important;color:green;padding:12px 5px!important;} 
	.box_yazi_td2 {font-size:18px;font:bold}
	.box_yazi_baslik {font-size:15px;font:bold; background-color:LightGray; vertical-align:middle}
	.button_hover:hover{
		background-color:#e3e3e3!important;
		border-color:black!important;
	}
	.button_change{
		font-size:15px; font-weight:bold;height:80px; width:80px;border-radius: 10px;border-color: #00000085;
	}
	.numarator{
		background-color:#e3e3e36b;font-size:22px; font-weight:bold;height:70px; width:70px;border-radius: 10px;margin:2px 0px;
	}
	.numarator_cons{
		background-color:#e3e3e36b;font-size:22px; font-weight:bold;width:217px;height:75px;border-radius: 10px;margin:2px 0px;
	}
	.fire{
		padding:100px;
	}
	.warning_message{
		font-size:56px; font-weight:bold; text-align:center; padding:100px 0px;
	}
	.tablesorter-header-inner{
		font-size:16px!important;
	}
	@media screen and (max-width: 769px) {
		footer {
			display:block;
		}
		/* button{
			width:100px!important;
			height:100px!important;
		} */
		.mobil_info{
			left: 0%!important;
		}
		.numarator_cons{
			width:305px!important;	
		}
	}
	@media screen and (min-width: 1150px) {
		.numarator{
			height:85px!important; 
			width:85px!important;
		}
		.numarator_cons{
			width:265px!important;	
			height:75px!important;	
		}
		
	}
	@media screen and (min-width: 1340px) {
		/* button{
			width:120px!important;
			height:120px!important;
		} */
	}
	@media screen and (max-width: 992px) {
		.fire{
			padding:0px;
		}
	}
	@media screen and (max-width: 578px) {
		footer{
			position:unset!important;
		}
		.numarator_cons {
			width: 220px !important;
		}
		.warning_message{
			font-size:24px;
		}
	}
	</style>

<cfset total_time = 0>
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.operation_type_id" default="">
<cfparam name="attributes.master_plan_id" default="">
<cfparam name="attributes.master_plan_cat_id" default="">
<cfparam name="attributes.start_date" default="">
<cfparam name="attributes.finish_date" default="">
<cfparam name="attributes.station_start_date" default="">
<cfparam name="attributes.station_finish_date" default="">
<cfparam name="attributes.station_id_list" default="">
<cfparam name="attributes.list_type" default="">
<cfparam name="attributes.is_process" default="">
<cfparam name="attributes.thickness_id" default="">
<cfparam name="attributes.color_id" default="">

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

<cfif isdefined("attributes.station_start_date") and isdate(attributes.station_start_date)>
	<cf_date tarih="attributes.station_start_date">
<cfelse>
	<cfset attributes.station_start_date = ''>
</cfif>

<cfif isdefined("attributes.station_finish_date") and isdate(attributes.station_finish_date)>
	<cf_date tarih="attributes.station_finish_date">
<cfelse>
	<cfset attributes.station_finish_date = ''>
</cfif>

<cfif isdefined("attributes.station_date") and isdate(attributes.station_date)>
	<cf_date tarih="attributes.station_date">
<cfelse>
	<cfif len(attributes.start_date)>
		<cfset attributes.station_date = attributes.start_date>
  	<cfelse>
    	<cfset attributes.station_date = ''>
    </cfif>
</cfif>
<cfif not len(attributes.master_plan_cat_id)>
    <cfquery name="GET_MASTER_PLAN_INFO" datasource="#DSN3#">
        SELECT MASTER_PLAN_PROCESS, MASTER_PLAN_CAT_ID FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
    </cfquery>
	<cfset attributes.master_plan_cat_id = GET_MASTER_PLAN_INFO.MASTER_PLAN_CAT_ID>
</cfif>

<!---Şablonu Listesini Alıyoruz--->
<cfquery name="get_station_sablon" datasource="#dsn3#">
	SELECT DISTINCT
    	EMPS.WORKSTATION_ID, 
        EMPS.SIRA, 
        EMPS.UP_WORKSTATION_ID, 
        ISNULL(EMPS.UP_WORKSTATION_TIME,0) AS UP_WORKSTATION_TIME, 
        W.STATION_NAME,
        ISNULL(EMPS.CURRENT_POINT,0) AS CURRENT_POINT, 
        EMD.FABRIC_CAT, 
        EMD.POINT_METHOD,
        EMD.WORK_TIME
	FROM     
   		EZGI_MASTER_PLAN_SABLON AS EMPS WITH (NOLOCK) INNER JOIN
     	WORKSTATIONS AS W WITH (NOLOCK) ON EMPS.WORKSTATION_ID = W.STATION_ID INNER JOIN
      	EZGI_MASTER_PLAN_DEFAULTS AS EMD WITH (NOLOCK) ON EMPS.SHIFT_ID = EMD.SHIFT_ID
	WHERE  
     	EMPS.SHIFT_ID = #attributes.master_plan_cat_id# AND
        EMPS.STATUS_ID = 1 AND
        NOT(EMPS.WORKSTATION_ID IS NULL) 
	ORDER BY 
    	EMPS.SIRA
</cfquery>
<cfset station_id_list = ValueList(get_station_sablon.WORKSTATION_ID)>
<cfif not ListLen(station_id_list)>
	<script type="text/javascript">
      	alert("Ilk Olarak Çalışma Programlarındaki İstasyon Tanımlarını Yapınız!");
      	window.close()
 	</script>
 	<cfabort>
</cfif>
<cfquery name="get_operations" datasource="#dsn3#">
	SELECT 
    	OT.OPERATION_TYPE_ID, 
        OT.OPERATION_TYPE,
        ISNULL(TBL.SAYI,0) AS SAYI,
        ISNULL(TBL.EZGI_KATSAYI,1) AS EZGI_KATSAYI
	FROM     
    	OPERATION_TYPES AS OT LEFT JOIN
        (
        	SELECT 
            	COUNT(*) AS SAYI, 
                ISNULL(MAX(W.EZGI_KATSAYI), 0) AS EZGI_KATSAYI, 
                WP.OPERATION_TYPE_ID
			FROM     
            	WORKSTATIONS_PRODUCTS AS WP INNER JOIN
                WORKSTATIONS AS W ON WP.WS_ID = W.STATION_ID
			WHERE  
            	W.ACTIVE = 1
			GROUP BY 
            	WP.OPERATION_TYPE_ID
        ) AS TBL ON TBL.OPERATION_TYPE_ID=OT.OPERATION_TYPE_ID
	WHERE  
    	OT.OPERATION_TYPE_ID IN
                      		(
                            	SELECT 
                                	OPERATION_TYPE_ID
                       			FROM      
                                	WORKSTATIONS_PRODUCTS
                       			WHERE   
                                	WS_ID IN
                                             (
                                             	SELECT 
                                                	STATION_ID
                                              	FROM      
                                                	WORKSTATIONS
                                              	WHERE   
                                                	UP_STATION IN (#station_id_list#) AND 
                                                    ACTIVE = 1
                                          	)
  								GROUP BY 
    								OPERATION_TYPE_ID
  								HAVING  
    								NOT (OPERATION_TYPE_ID IS NULL)
                         	)
  		AND OT.OPERATION_STATUS = 1
	ORDER BY
    	OT.OPERATION_TYPE
</cfquery>
<!---Hesaplama Şeklini Öğrenmek İçim Master Plan Şablon Dosyasının 1. Satırına Bakıyorum--->
<cfquery name="get_station_sablon_main" dbtype="query">
	SELECT 
     	SIRA, 
       	CURRENT_POINT, 
     	FABRIC_CAT, 
   		POINT_METHOD,
        WORK_TIME
	FROM     
   		get_station_sablon
	WHERE  
        SIRA = 1 
</cfquery>

<cfif not get_station_sablon_main.recordcount>
 	Master Plan Tanımı Yapınız. Veya 1. sıra Tanımı Bulunamamıştır
 	<cfdump var="#get_station_sablon_main#">
 	<cfabort>
</cfif>

<cfquery name="get_master_plan" datasource="#dsn3#">
	SELECT        
    	MASTER_PLAN_ID, 
        MASTER_PLAN_NUMBER, 
        MASTER_PLAN_DETAIL
	FROM            
    	EZGI_IFLOW_MASTER_PLAN WITH (NOLOCK)
  	<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
        WHERE 
            MASTER_PLAN_CAT_ID IN    
            
                    (
                        SELECT        
                            MASTER_PLAN_CAT_ID
                        FROM       
                            EZGI_IFLOW_MASTER_PLAN AS M
                        WHERE        
                            MASTER_PLAN_ID IN (#attributes.master_plan_id#)
                    )
    </cfif>
	ORDER BY 
    	MASTER_PLAN_NUMBER
</cfquery>
<cfquery name="get_stations" datasource="#dsn3#">
 	SELECT DISTINCT
    	ISNULL(W.EZGI_KATSAYI, 0) AS EZGI_KATSAYI, 
      	ISNULL(W.ACTIVE,0) ,
    	W.STATION_NAME, 
   		W.STATION_ID, 
    	W.EZGI_SETUP_TIME ,
  		ISNULL(WP.DEFAULT_STATUS, 0)         
 	FROM     
   		WORKSTATIONS_PRODUCTS AS WP INNER JOIN
 		WORKSTATIONS AS W ON WP.WS_ID = W.STATION_ID
   	WHERE  
  		ISNULL(W.ACTIVE,0) = 1
  	ORDER BY
     	ISNULL(WP.DEFAULT_STATUS, 0) DESC,
      	ISNULL(W.ACTIVE,0) DESC,
   		W.STATION_NAME
</cfquery>
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) WHERE  IS_ACTIVE = 1 ORDER BY COLOR_NAME
</cfquery>
<cfquery name="get_thickness" datasource="#dsn3#">
	SELECT DISTINCT      
    	THICKNESS_ID, 
        THICKNESS_NAME
	FROM            
    	EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
	WHERE        
        LIST_ORDER_NO = 1
	ORDER BY 
    	THICKNESS_NAME
</cfquery>
<cfif isdefined("attributes.is_form_submitted")>
    <cfquery name="get_production_operations" datasource="#dsn3#">
    	WITH DesignData AS (
                            SELECT 
                                SPEC_MAIN_ID,
                                MAX(CASE WHEN Type = 'Design' THEN Name END) AS DESIGN_MAIN_NAME,
                                MAX(CASE WHEN Type = 'Package' THEN Name END) AS PACKAGE_NAME,
                                MAX(CASE WHEN Type = 'Piece' THEN Name END) AS PIECE_NAME
                            FROM (
                                    SELECT 
                                        MAIN_SPECT_RELATED_ID AS SPEC_MAIN_ID, 
                                        DESIGN_MAIN_NAME AS Name, 
                                        'Design' AS Type 
                                    FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
                                    
                                    UNION ALL
                                    
                                    SELECT 
                                        PACKAGE_SPECT_RELATED_ID AS SPEC_MAIN_ID, 
                                        PACKAGE_NAME AS Name, 
                                        'Package' AS Type 
                                    FROM EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK)
                                    
                                    UNION ALL
                                    
                                    SELECT 
                                        PIECE_SPECT_RELATED_ID AS SPEC_MAIN_ID, 
                                        PIECE_NAME AS Name, 
                                        'Piece' AS Type 
                                    FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
                            	) AS SubQuery
                      		GROUP BY 
                            	SPEC_MAIN_ID
        )
        SELECT DISTINCT
            CASE 
                WHEN ISNULL(S.IS_PROTOTYPE, 0) = 0 THEN S.PRODUCT_NAME
                ELSE COALESCE(D.DESIGN_MAIN_NAME, D.PACKAGE_NAME, D.PIECE_NAME)
            END AS PRODUCT_NAME,
          	EPO.IFLOW_P_ORDER_ID,
            PO.P_ORDER_ID, 
            PO.QUANTITY, 
            PO.P_ORDER_NO, 
            PO.STOCK_ID, 
            PO.SPEC_MAIN_ID, 
            S.PRODUCT_CODE, 
            EIM.MASTER_PLAN_NUMBER, 
            EIM.MASTER_PLAN_DETAIL, 
            PORR.O_START_DATE, 
            PORR.O_CURRENT_NUMBER, 
            EIPO.P_ORDER_PARTI_NUMBER, 
            PO.LOT_NO, 
            ISNULL(PORR.AMOUNT,0) AS AMOUNT, 
            PORR.STAGE, 
            PORR.OPERATION_TYPE_ID,
            PORR.O_STATION_IP,
            W.STATION_NAME,
            PORR.O_STATION_START_DATE,
            PORR.P_OPERATION_ID,
            OT.OPERATION_TYPE,
            ISNULL((SELECT SUM(REAL_AMOUNT) AS REAL_AMOUNT FROM PRODUCTION_OPERATION_RESULT WHERE OPERATION_ID = PORR.P_OPERATION_ID),0) AS REAL_AMOUNT
            <cfif get_station_sablon_main.POINT_METHOD eq 1> <!---Süreli ise--->
            	,ISNULL((SELECT TOP (1) OPTIMUM_TIME FROM EZGI_OPERATION_OPTIMUM_TIME WHERE STOCK_ID = S.STOCK_ID AND OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID AND STATUS = 1),0) AS OPTIMUM_TIME
            </cfif>
        FROM            
            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPO WITH (NOLOCK) INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) ON EIPO.P_ORDER_PARTI_ID = EPO.REL_P_ORDER_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EPO.LOT_NO = PO.LOT_NO INNER JOIN
            PRODUCTION_OPERATION AS PORR WITH (NOLOCK) ON PO.P_ORDER_ID = PORR.P_ORDER_ID INNER JOIN
            EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) ON EPO.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID INNER JOIN
            OPERATION_TYPES AS OT ON OT.OPERATION_TYPE_ID = PORR.OPERATION_TYPE_ID LEFT JOIN
            DesignData AS D ON PO.SPEC_MAIN_ID = D.SPEC_MAIN_ID LEFT JOIN
            WORKSTATIONS AS W ON W.STATION_ID = PORR.O_STATION_IP
  		WHERE  
        	EIM.MASTER_PLAN_CAT_ID = #attributes.master_plan_cat_id#
            <cfif len(attributes.master_plan_id)>      
        		AND EPO.MASTER_PLAN_ID IN (#attributes.master_plan_id#)
            </cfif>
            <cfif len(attributes.keyword)>
            	AND
                	(
                    	PO.LOT_NO LIKE '%#attributes.keyword#%' OR
                        EIPO.P_ORDER_PARTI_NUMBER LIKE '%#attributes.keyword#%' OR
                    	PO.P_ORDER_NO LIKE '%#attributes.keyword#%' 
                    )
            </cfif>
            <cfif len(attributes.color_id)>
                AND S.STOCK_ID IN (SELECT PIECE_RELATED_ID FROM EZGI_DESIGN_PIECE_ROWS WHERE PIECE_COLOR_ID = #attributes.color_id#) 
            </cfif>
            <cfif len(attributes.thickness_id)>
                AND S.STOCK_ID IN (SELECT PIECE_RELATED_ID FROM EZGI_DESIGN_PIECE_ROWS WHERE KALINLIK = #attributes.thickness_id#) 
            </cfif>
            <cfif isdefined('attributes.operation_type_id') and len(attributes.operation_type_id)>
            	AND OT.OPERATION_TYPE_ID = #attributes.operation_type_id#
         	</cfif>
            <cfif len(attributes.start_date)>
            	AND PORR.O_START_DATE >=#attributes.start_date# 
            </cfif>
            <cfif len(attributes.finish_date)>
            	AND PORR.O_START_DATE < #DateAdd('d',1,attributes.finish_date)# 
            </cfif>
            <cfif len(attributes.station_start_date)>
            	AND PORR.O_STATION_START_DATE >=#attributes.station_start_date# 
            </cfif>
            <cfif len(attributes.station_finish_date)>
            	AND PORR.O_STATION_START_DATE < #DateAdd('d',1,attributes.station_finish_date)# 
            </cfif>
            <cfif isdefined('attributes.station_id_list') and ListLen(attributes.station_id_list)>
            	AND PORR.O_STATION_IP IN (#attributes.station_id_list#)
         	</cfif>
            <cfif len(attributes.list_type)>
            	<cfif attributes.list_type eq 1>
            		AND PORR.STAGE IN (0,1) 
             	<cfelseif attributes.list_type eq 2>
                	AND PORR.STAGE = 3
                </cfif>
            </cfif>
		ORDER BY 
        	PORR.O_CURRENT_NUMBER,
        	PORR.O_START_DATE 
    </cfquery>

    	<cfquery name="get_stations" datasource="#dsn3#">
            SELECT DISTINCT
                ISNULL(W.EZGI_KATSAYI, 0) AS EZGI_KATSAYI, 
                ISNULL(W.ACTIVE,0) ,
                W.STATION_NAME, 
                W.STATION_ID, 
                W.EZGI_SETUP_TIME ,
                ISNULL(WP.DEFAULT_STATUS, 0)         
            FROM     
                WORKSTATIONS_PRODUCTS AS WP INNER JOIN
                WORKSTATIONS AS W ON WP.WS_ID = W.STATION_ID
            WHERE  
            	<cfif len(attributes.operation_type_id)>
                WP.OPERATION_TYPE_ID = #attributes.operation_type_id# AND
                </cfif>
                ISNULL(W.ACTIVE,0) = 1
            ORDER BY
                ISNULL(WP.DEFAULT_STATUS, 0) DESC,
                ISNULL(W.ACTIVE,0) DESC,
                W.STATION_NAME
        </cfquery>
	<cfset arama_yapilmali = 0>
<cfelse>
	<cfset get_production_operations.recordcount =0>
    <cfset arama_yapilmali = 1>
</cfif>

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#get_production_operations.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>


<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" id="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
        	<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cfinput type="hidden" name="master_plan_cat_id" value="#attributes.master_plan_cat_id#">
            <cfinput type="hidden" name="station_date"  id="station_date" value="">
            <cfinput type="hidden" name="form_send_value" id="form_send_value" value="">
            <cfinput type="hidden" name="form_send_date" id="form_send_date" value="">
            <cfinput type="hidden" name="form_send_id_list" id="form_send_id_list" value="">
            
           	<cf_box_search>
                    <div class="form-group"  id="item-keyword">
                        <cfsavecontent variable="filter">Parti, Lot, Emir No</cfsavecontent>
                         <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
                    </div>
                    <div class="form-group medium" id="item-master_plan_id">
                        <select name="master_plan_id">
                            <option value="" <cfif attributes.master_plan_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="get_master_plan">
                                <option value="#MASTER_PLAN_ID#" <cfif attributes.master_plan_id eq MASTER_PLAN_ID>selected</cfif>>#MASTER_PLAN_NUMBER# - #MASTER_PLAN_DETAIL#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <div class="form-group" id="form_ul_stations">
                    	<select name="operation_type_id" onChange="process_change(this.value)">
                         	<option value="" <cfif attributes.operation_type_id eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                         	<cfoutput query="get_operations">
                            	<option value="#OPERATION_TYPE_ID#" <cfif attributes.operation_type_id eq OPERATION_TYPE_ID>selected</cfif>>#OPERATION_TYPE#</option>
                         	</cfoutput>
                    	</select>
                   	</div>
                    <div class="form-group" id="form_ul_list_type">
                    	<select name="list_type" id="list_type" style="width:100px; height:20px">
                        	<option value="" <cfif attributes.list_type eq ''>selected</cfif>><cf_get_lang dictionary_id='1065.Tüm Operasyonlar'></option>
                            <option value="1" <cfif attributes.list_type eq 1>selected</cfif>><cf_get_lang dictionary_id='408.İşlemdeki Operasyonlar'></option>
                            <option value="2" <cfif attributes.list_type eq 2>selected</cfif>><cf_get_lang dictionary_id='1145.Biten Operasyonlar'></option>
                        </select>
                   	</div>

                    <div class="form-group" id="form_ul_date">
                        <div class="col col-12">
                            <div class="col col-6 pl-0">
                                <div class="input-group">
                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='30122.Başlangıç Tarihini Kontrol Ediniz'></cfsavecontent>
                                    <cfinput type="text" name="start_date" value="#dateformat(attributes.start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                                </div>
                            </div>
                            <div class="col col-6 pl-0">
                                <div class="input-group">
                                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                    <cfinput type="text" name="finish_date" value="#dateformat(attributes.finish_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="form_ul_is_process" <cfif not len(attributes.operation_type_id)>style="display:none"</cfif>>
                        <input type="checkbox" name="is_process" id="is_process" value="1" <cfif attributes.is_process eq 1>checked</cfif>>
                        İstasyon Planla
                    </div>
                    <div class="form-group small">
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                        <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,3000" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="4" style="width:25px;">
                    </div>
                    <div class="form-group">
                        <cf_wrk_search_button search_function='input_control()' button_type="4">
                    </div>
         	</cf_box_search>
            <cfif get_station_sablon_main.POINT_METHOD eq 1>
            	<cf_box_search_detail>
                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    	<div class="col col-4 pl-0">
                        	<label class="col col-2 col-xs-12">Yükleme İstasyonu</label>
                       	</div>
                     	<div class="col col-8 pl-0">
                            <div class="form-group" id="form_ul_station">
                                <div class="input-group">
                                     <select name="station_id_list" style="width:150px;height:60px" multiple="multiple">
                                        <cfoutput query="get_stations">
                                            <option value="#STATION_ID#" <cfif ListFind(attributes.station_id_list,STATION_ID)>selected</cfif>>#STATION_NAME#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                        </div>
                  	</div>

                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    	<div class="form-group" id="form_ul_station_color">
                            <select name="color_id" id="color_id" style="width:130px;height:20px">
                                <option value=""><cf_get_lang dictionary_id='199.Renk'></option>
                                <cfoutput query="get_colors">
                                    <option value="#COLOR_ID#" <cfif  attributes.color_id eq COLOR_ID>style="font-weight:bold" selected </cfif>>#COLOR_NAME#</option>
                                </cfoutput>
                            </select>
                        </div>
                        <div class="form-group" id="form_ul_tickness">
                            <select name="thickness_id" id="thickness_id" style="width:70px;height:20px">
                                <option value=""><cf_get_lang dictionary_id='75.Kalınlık'></option>
                                <cfoutput query="get_thickness">
                                    <option value="#THICKNESS_ID#" <cfif attributes.thickness_id eq THICKNESS_ID>selected</cfif>>#THICKNESS_NAME#</option>
                                </cfoutput>
                            </select>
                        </div>
                    </div>

                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                    	<div class="form-group" id="form_ul_station_date">
                            <div class="col col-12">
                            	<div class="col col-4 pl-0">
                                	<label class="col col-2 col-xs-12">Yükleme Tarih </label>
                                </div>
                                <div class="col col-4 pl-0">
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='30122.Başlangıç Tarihini Kontrol Ediniz'></cfsavecontent>
                                        <cfinput type="text" name="station_start_date" value="#dateformat(attributes.station_start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="station_start_date"></span>
                                    </div>
                                </div>
                                <div class="col col-4 pl-0">
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                        <cfinput type="text" name="station_finish_date" value="#dateformat(attributes.station_finish_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#">
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="station_finish_date"></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
         		</cf_box_search_detail>
            </cfif>
    	</cfform> 
        <cfset colspan_1 = 13>
        <cfif get_station_sablon_main.POINT_METHOD eq 1>
        	<cfset colspan_1 = 16>
        </cfif>
        
        <cfif isdefined('attributes.is_process') and attributes.is_process eq 1>
            <div class="col col-3 col-md-12 col-sm-12 col-xs-12">
            	<cfform action="" name="station_list" method="post">
                    <cfsavecontent variable="title"><cf_get_lang dictionary_id='29473.İstasyonlar'></cfsavecontent>
                 	<cf_box title="#title#">
   						<div class="col col-12">
                       		<div class="col col-6 pl-0"></div>
                          	<label class="col col-2 col-xs-12">Tarih </label>
                            <div class="col col-4 pl-0">
                            	<div class="form-group" id="form_ul_date">  
                                 	<div class="input-group">
                                      	<cfsavecontent variable="message"><cf_get_lang dictionary_id='30123.Bitiş Tarihini Kontrol Ediniz'></cfsavecontent>
                                     	<cfinput type="text" name="station_date_"  id="station_date_" value="#dateformat(attributes.station_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="no" maxlength="10" message="#message#" onChange="station_date_change()">
                                     	<span class="input-group-addon"><cf_wrk_date_image date_field="station_date_"></span>
                                	</div>
                           		</div>   
                         	</div>
                                         
                       	</div>
                       	<div class="col col-12">
                        	<div align="left" id="DISPLAY_CREATIVE_DETAIL" style="border:none;"></div>
                        </div>
                 	</cf_box>
                </cfform>        
            </div>
        </cfif>
        <div class="col col-<cfif isdefined('attributes.is_process') and attributes.is_process eq 1>9<cfelse>12</cfif> col-md-12 col-sm-12 col-xs-12">
            <cfform action="" name="search_list" method="post">
                <cfsavecontent variable="title"><cf_get_lang dictionary_id='36368.Fabrika Üretim Emirleri'></cfsavecontent>
                <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
                    <cf_grid_list id="operation_panel" sort="0">   
                        <thead>
                            <tr>
                                <th colspan="<cfoutput>#colspan_1#</cfoutput>" height="30px"><cfif isdefined("attributes.is_form_submitted") and len(attributes.operation_type_id)><cfoutput>#get_production_operations.OPERATION_TYPE#</cfoutput> İş Listesi</cfif></th>
                            </tr>
                            <tr valign="middle">
                                <!---<cfif isdefined('attributes.is_process') and attributes.is_process eq 1>
                                    <th style="width:25px; text-align:center; vertical-align:middle"></th>
                                </cfif>--->
                                <th style="width:25px; height:30px; text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                
                                <th style="width:70px; text-align:center; vertical-align:middle">Başlama Tarihi</th>
                                <th style="width:70px; text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='695.Plan No'></th>
                                <th style="width:70px; text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='36528.Parti No'></th>
                                <th style="width:70px; text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='41701.Lot No'></th>
                                <th style="width:70px; text-align:center; vertical-align:middle">Emir No</th>        
                                <th style="width:100px; text-align:center; vertical-align:middle">Operasyon</th>
                                <th style="text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='57657.Ürün'></th>
                                <th style="width:120px; text-align:center; vertical-align:middle">Yüklenen İstasyon</th>
                             	<th style="width:70px; text-align:center; vertical-align:middle">Yüklenen Tarih</th>
                                    

                                <th style="width:50px; text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                <th style="width:50px; text-align:center; vertical-align:middle"><cf_get_lang dictionary_id='302.Biten'></th>
                                <th style="width:50px; text-align:center; vertical-align:middle;"><cf_get_lang dictionary_id='58444.Kalan'></th>
                                <cfif get_station_sablon_main.POINT_METHOD eq 1> <!---Süreli ise--->
                                    <th style="width:50px; text-align:center; vertical-align:middle">Süre</th>
                                    <th style="width:70px; text-align:center; vertical-align:middle">Toplam Süre</th>
                                    <th style="width:25px; text-align:center; vertical-align:middle">
                                        <input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: wrk_select_all2('all_conv_product','_conversion_product_',<cfoutput>#get_production_operations.recordcount#</cfoutput>);">
                                    </th>
                                </cfif>
                            </tr>
                        </thead>
                        <tbody>
                            <cfif get_production_operations.recordcount>
                                <cfoutput query="get_production_operations" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                                    <tr name="frm_row#currentrow#" id="frm_row#currentrow#" title="#MASTER_PLAN_DETAIL#">
                                        <!---<cfif isdefined('attributes.is_process') and attributes.is_process eq 1>
                                            <input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                            <td class="text-center"><span class="icn-md icon-align-justify handle"></td>
                                        </cfif>--->
                                        <td style="text-align:right; height:25px"><input type="text" name="current_id#currentrow#" id="current_id#currentrow#" value="#currentrow#" readonly="readonly" style="width:25px; text-align:right;"></td>
                                        <td style="text-align:center;">#DateFormat(O_START_DATE,dateformat_style)#</td>
                                        <td style="text-align:center;">#MASTER_PLAN_NUMBER#</td>
                                        <td style="text-align:center;">#P_ORDER_PARTI_NUMBER#</td>
                                        <td style="text-align:center;">#LOT_NO#</td>
                                        <td style="text-align:center;">#P_ORDER_NO#</td>
                                        <td style="text-align:center;">#OPERATION_TYPE#</td>
                                        <td style="text-align:left;">#PRODUCT_NAME#</td>
                                        <cfif isdefined('attributes.is_process') and attributes.is_process eq 1>
                                        	<td style="text-align:center;" nowrap>
                                          		<cfif get_stations.recordcount>
                                                    <select name="station_id_" onChange="station_id_change(this.value,'#get_production_operations.P_OPERATION_ID#')">	
                                                    	<option value="" <cfif not len(get_production_operations.O_STATION_IP)>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
														<cfloop query="get_stations">
                                                            <option value="#get_stations.STATION_ID#" <cfif get_stations.STATION_ID eq get_production_operations.O_STATION_IP>selected</cfif>>#get_stations.STATION_NAME#</option>
                                                        </cfloop>
                                                    </select>
                                              	<cfelse>
                                                  İstasyon Bulunamdı  
                                            	</cfif>
                                            </td>
                                            
                                        <cfelse>
                                        	<td style="text-align:left;">#STATION_NAME#</td>	
                                        </cfif>
                                        <td style="text-align:center;" nowrap>#DateFormat(O_STATION_START_DATE,dateformat_style)#</td>
                                        <td style="text-align:right;">#AmountFormat(AMOUNT)#</td>
                                        <td style="text-align:right;">#AmountFormat(REAL_AMOUNT)#</td>
                                        <td style="text-align:right; font-weight:bold; color:white;background-color:<cfif STAGE eq 0>orange<cfelseif STAGE eq 1>green<cfelseif STAGE eq 3>red</cfif>">#AmountFormat(AMOUNT-REAL_AMOUNT)#</td>
                                        <cfif get_station_sablon_main.POINT_METHOD eq 1> <!---Süreli ise--->
                                            <td style="text-align:right;">#AmountFormat(OPTIMUM_TIME)#</td>
                                            <cfset row_time = (AMOUNT-REAL_AMOUNT)*OPTIMUM_TIME>
                                            <input type="hidden"  name="row_time_#currentrow#" id="row_time_#currentrow#" value="#row_time#" />
                                            <td style="text-align:right;">#AmountFormat(row_time)#</td>
                                            <cfset total_time = total_time + row_time>
                                            <td style="text-align:center;">
                                                <cfif STAGE eq 3>
                                                    <img src="/images/d_ok.gif" border="0" title="">
                                                    <cfinput type="hidden" name="kontrol_#currentrow#" id="kontrol_#currentrow#" value="0">
                                                <cfelse>
                                                    <cfinput type="hidden" name="kontrol_#currentrow#" id="kontrol_#currentrow#" value="1">
                                                    <input type="checkbox" name="select_order_row_#P_OPERATION_ID#" value="#P_OPERATION_ID#" id="_conversion_product_#currentrow#" onClick="hesapla();">
                                                </cfif>  
                                            </td>
                                        </cfif>
                                    </tr>
                                </cfoutput>
                            </cfif>
                        </tbody>
                  		<cfif get_station_sablon_main.POINT_METHOD eq 1 and len(attributes.operation_type_id)>
                            <tfoot>
                                <tr>
                                    <td style="text-align:right" colspan="<cfoutput>#colspan_1#</cfoutput>">
                                    	<input type="text" name="send_date" id="send_date" value="<cfoutput>#dateformat(DateAdd('d',1,now()),dateformat_style)#</cfoutput>" validate="eurodate" maxlength="10" style="width:65px; height:30px" >
                                        <cf_wrk_date_image date_field="send_date">
                                      	&nbsp;&nbsp;&nbsp;&nbsp;
                                        <input type="button" onClick="send_button()" value="Gönder" style="background-color:green; font-size:12px; font-weight:bold">
                                    </td>
                                </tr>
                            </tfoot>
                        </cfif>
                    </cf_grid_list>
                </cf_box> 
                <cfif get_station_sablon_main.POINT_METHOD eq 1 and len(attributes.operation_type_id)> <!---Süreli ise--->
                    <cfquery name="get_this_operations" dbtype="query">
                        SELECT SAYI,EZGI_KATSAYI FROM get_operations WHERE OPERATION_TYPE_ID = #attributes.operation_type_id#
                    </cfquery>
                    <cfset station_row = get_this_operations.SAYI>
                    <cfset katsayi = get_this_operations.EZGI_KATSAYI>
                    <cfif len(get_station_sablon_main.WORK_TIME) and get_station_sablon_main.WORK_TIME gt 0>
						<cfset day_time =get_station_sablon_main.WORK_TIME>
                    <cfelse>
                        <cfset day_time = get_defaults.DEFAULT_DAILY_WORKING_TIME*3600>
                    </cfif>
                    <cf_box style="box-shadow: none!important;">
                        <cf_grid_list> 
                            <thead>
                                <tr>
                                    <th class="box_yazi_td2" style="text-align:center">Makina Sayısı</th>
                                    <th class="box_yazi_td2" style="text-align:center">Katsayı</th>
                                    <th class="box_yazi_td2" style="text-align:center">Liste Çalışma Zamanı</th>
                                    <th class="box_yazi_td2" style="text-align:center">Seçilen Çalışma Zamanı</th>
                                    <th class="box_yazi_td2" style="text-align:center">Toplam Çalışma Zamanı</th>
                                    <th class="box_yazi_td2" style="text-align:center">İstasyon Yükü</th>	
                                </tr>
                            </thead>
                            <cfoutput>
                                <tbody>
                                    <tr height="30px">
                                        <td class="box_yazi_td" style="text-align:center">
                                             <input type="text"  name="station_row_" id="station_row_" style="font-size:17px!important;font-weight:bold!important;color:green;padding:12px 5px!important; text-align:center" value="#station_row#" readonly/>
                                        </td>
                                        <td class="box_yazi_td" style="text-align:center">
                                             <input type="text"  name="katsayi" id="katsayi" style="font-size:17px!important;font-weight:bold!important;color:green;padding:12px 5px!important; text-align:center" value="#AmountFormat(katsayi)#" readonly/>
                                        </td>
                                        <td class="box_yazi_td" style="text-align:center">#AmountFormat(total_time)#</td>
                                        <td class="box_yazi_td" style="text-align:center">
                                            <input type="text"  name="total_time_" id="total_time_" style="font-size:17px!important;font-weight:bold!important;color:green;padding:12px 5px!important; text-align:center" value="0" readonly/>
                                        </td>

                                        <input type="hidden"  name="day_time" id="day_time" value="#day_time#" />
                                        <td class="box_yazi_td" style="text-align:center">#AmountFormat(day_time)#</td>
                                        <td class="box_yazi_td" style="text-align:center">
                                            <input type="text"  name="day_time_rate" id="day_time_rate"  style="font-size:17px!important;font-weight:bold!important;color:green;padding:12px 5px!important; text-align:center" value="0" readonly/>
                                        </td>
                                    </tr>
                                </tbody>
                                
                            </cfoutput>
                        </cf_grid_list> 
                    </cf_box>
                </cfif>
            </cfform>  
        </div>      
   	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;		
	}
	function process_change(operation_type_id)
	{
		if(operation_type_id != '')
		{
			document.getElementById('form_ul_is_process').style.display='';
		}
		else
		{
			document.getElementById('form_ul_is_process').style.display='none';
			document.getElementById('is_process').checked = false;
			document.getElementById('is_process').value = 0;
		}
	}
	<cfif get_station_sablon_main.POINT_METHOD eq 1 and len(attributes.operation_type_id)> <!---Süreli ise ve operasyon seçilmişse--->
		connectAjax(0,0,0);
		function station_date_change()
		{
			connectAjax(0,0,0);
		}
		function station_id_change(station_id,p_operation_id)
		{
			if(station_id=='')
			{
				sor=confirm('İstasyonu Boş Giriyorsunuz Emin misiniz?');
				if(sor==true)
					connectAjax(1,station_id,p_operation_id);
				else
					return false;
			}
			else
				connectAjax(1,station_id,p_operation_id);
		}
		function connectAjax(type,station_id,p_operation_id)
		{
			day_time = document.getElementById('day_time').value;
			station_date = document.getElementById('station_date_').value;	
			var bb = '<cfoutput>#request.self#?fuseaction=prod.emptypopup_ajax_ezgi_iflow_workstation_load&operation_type_id=#attributes.operation_type_id#</cfoutput>&station_date='+station_date+'&type='+type+'&station_id='+station_id+'&p_operation_id='+p_operation_id+'&day_time='+day_time;
			AjaxPageLoad(bb,'DISPLAY_CREATIVE_DETAIL',1);
		}
		function wrk_select_all2(all_conv_product,_conversion_product_,number)
		{
			<cfoutput>
				start_row = #attributes.startrow#;
				end_row = #attributes.maxrows#;
			</cfoutput>
			for(var cl_ind=1; cl_ind <= number; cl_ind++)
			{
				if(document.getElementById('kontrol_'+cl_ind).value == 1)
				{
					if(document.getElementById(all_conv_product).checked == true)
					{
						if(document.getElementById('_conversion_product_'+cl_ind).checked == false)
							document.getElementById('_conversion_product_'+cl_ind).checked = true;
					}
					else
					{
						if(document.getElementById('_conversion_product_'+cl_ind).checked == true)
							document.getElementById('_conversion_product_'+cl_ind).checked = false;
					}
				}
			}
			hesapla();
		}
		function hesapla()
		{
			total_time_ = 0;
			day_time = document.getElementById('day_time').value;
			<cfoutput>
				station_row = #station_row#;
				katsayi = #katsayi#;
				start_row = #attributes.startrow#;
				end_row = #attributes.maxrows#;
				number=#get_production_operations.recordcount#;
			</cfoutput>
			if(end_row>number)
				end_row=number;
			for(var satir=start_row; satir <= end_row; satir++)
			{
				if(document.getElementById('kontrol_'+satir).value == 1)
				{
					if(document.getElementById('_conversion_product_'+satir).checked == true)
					{
						total_time_ = (total_time_*1)+(document.getElementById('row_time_'+satir).value*1);
					}
				}
			}
			document.getElementById('total_time_').value = commaSplit(total_time_,2);
			if(total_time_ > 0 && day_time > 0 && station_row >0)

			{
				document.getElementById('day_time_rate').value = commaSplit(total_time_/day_time/station_row/katsayi*100,2);
				
			}
			else
				document.getElementById('day_time_rate').value = commaSplit(0,2);
		}
		function send_button()
		{
			<cfoutput>
				start_row = #attributes.startrow#;
				end_row = #attributes.maxrows#;
			</cfoutput>
			id_list = '';
			if(end_row>number)
				end_row=number;
			for(var satir=start_row; satir <= end_row; satir++)
			{
				if(document.getElementById('kontrol_'+satir).value == 1)
				{
					if(document.getElementById('_conversion_product_'+satir).checked == true)
					{
						id_list +=document.getElementById('_conversion_product_'+satir).value+',';
					}
				}
			}
			
			id_list = id_list.substr(0,id_list.length-1);//sondaki virgülden kurtarıyoruz.
			
			if(id_list!='')
			{
				if(document.getElementById('send_date').value=='')
				{
					alert('Tarih Boş Olamaz');
					return false;
				}
				else
				{
					sor=confirm('Seçtiğiniz Satırları Belirlediğiniz Tarihe Gönderiyorum.')
					if(sor==true)
					{
						document.getElementById('form_send_date').value = document.getElementById('send_date').value;
						document.getElementById('form_send_value').value = 1;
						document.getElementById('form_send_id_list').value = id_list;
						document.getElementById("search").submit();
					}
					else
						return false
					
				}
				
			}
			else
			{
				alert('Önce Satır Seçmelisiniz.!!!');
				return false;
			}
		}
	</cfif>
</script>