<!---
    File: dsp_ezgi_iflow_workstation_load.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cf_xml_page_edit>
<style>
	body{
		background:white!important;
	}
	.box_yazi {font-size:16px;font:bold} 
	.box_yazi_td {font-size:13px!important;font-weight:bold!important;color:green;padding:12px 5px!important;} 
	.box_yazi_td2 {font-size:13px;font:bold}
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
<cfparam name="attributes.list_type" default="">
<cfparam name="attributes.is_process" default="">
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
	<cf_date tarih="attributes.start_date">
<cfelse>
	<cfset attributes.start_date = ''>
</cfif>
<cfif not len(attributes.master_plan_cat_id)>
    <cfquery name="GET_MASTER_PLAN_INFO" datasource="#DSN3#">
        SELECT MASTER_PLAN_PROCESS, MASTER_PLAN_CAT_ID FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
    </cfquery>
	<cfset attributes.master_plan_cat_id = GET_MASTER_PLAN_INFO.MASTER_PLAN_CAT_ID>
</cfif>

<!---Şablonu Listesini Alıyoruz--->
<cfquery name="get_station_sablon" datasource="#dsn3#">
	SELECT 
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
<cfif isdefined("attributes.is_form_submitted")>
    <cfquery name="get_production_operations" datasource="#dsn3#">
        SELECT DISTINCT
          	EPO.IFLOW_P_ORDER_ID,
            PO.P_ORDER_ID, 
            PO.QUANTITY, 
            PO.P_ORDER_NO, 
            PO.STOCK_ID, 
            PO.SPEC_MAIN_ID, 
            EIM.MASTER_PLAN_NUMBER, 
            EIM.MASTER_PLAN_DETAIL, 
            PORR.O_START_DATE, 
            PORR.O_CURRENT_NUMBER, 
            EIPO.P_ORDER_PARTI_NUMBER, 
            PO.LOT_NO, 
            ISNULL(PORR.AMOUNT,0) AS AMOUNT, 
            PORR.STAGE, 
            PORR.OPERATION_TYPE_ID,
            <cfif x_report_yontem eq 0><!---Otomatik İş Yükleme--->
             	PORR.STATION_ID AS O_STATION_IP,       
    		<cfelse><!---Manuel İş Yükleme--->
            	PORR.O_STATION_IP,
       		</cfif>
            PORR.O_STATION_START_DATE,
            PORR.P_OPERATION_ID,
            OT.OPERATION_TYPE,
            ISNULL((SELECT TOP (1) OPTIMUM_TIME FROM EZGI_OPERATION_OPTIMUM_TIME WHERE STOCK_ID = PO.STOCK_ID AND OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID AND STATUS = 1),0) AS OPTIMUM_TIME,
            TBL.REAL_AMOUNT,
            TBL.LOSS_AMOUNT,
            TBL.REAL_TIME,
            TBL.WAIT_TIME
        FROM            
            EZGI_IFLOW_PRODUCTION_ORDERS_PARTI AS EIPO WITH (NOLOCK) INNER JOIN
            EZGI_IFLOW_PRODUCTION_ORDERS AS EPO WITH (NOLOCK) ON EIPO.P_ORDER_PARTI_ID = EPO.REL_P_ORDER_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EPO.LOT_NO = PO.LOT_NO INNER JOIN
            PRODUCTION_OPERATION AS PORR WITH (NOLOCK) ON PO.P_ORDER_ID = PORR.P_ORDER_ID INNER JOIN
            EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) ON EPO.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID INNER JOIN
            OPERATION_TYPES AS OT ON OT.OPERATION_TYPE_ID = PORR.OPERATION_TYPE_ID LEFT JOIN
            (
            	SELECT 
                	OPERATION_ID, 
                    STATION_ID, 
                    SUM(REAL_AMOUNT) AS REAL_AMOUNT, 
                    SUM(LOSS_AMOUNT) AS LOSS_AMOUNT, 
                    SUM(REAL_TIME) AS REAL_TIME, 
                    SUM(WAIT_TIME) AS WAIT_TIME
				FROM     
                	PRODUCTION_OPERATION_RESULT
				GROUP BY 
                	OPERATION_ID, 
                    STATION_ID
            ) AS TBL ON TBL.OPERATION_ID = PORR.P_OPERATION_ID AND TBL.STATION_ID = PORR.O_STATION_IP
  		WHERE  
        	EIM.MASTER_PLAN_CAT_ID = #attributes.master_plan_cat_id#
            <cfif len(attributes.start_date)>
            	<cfif x_report_yontem eq 0><!---Otomatik İş Yükleme--->
                    AND PORR.O_START_DATE >= #attributes.start_date#
                    AND PORR.O_START_DATE < #DateAdd('d',1,attributes.start_date)#
                <cfelse><!---Manuel İş Yükleme--->
                    AND PORR.O_STATION_START_DATE = #attributes.start_date# 
                </cfif>
            </cfif>
		ORDER BY 
        	PORR.O_CURRENT_NUMBER,
        	PORR.O_START_DATE 
    </cfquery>
  	<cfquery name="get_stations" datasource="#dsn3#">
    	SELECT 
        	ISNULL(EZGI_KATSAYI, 0) AS EZGI_KATSAYI, 
            ISNULL(ACTIVE, 0) AS ACTIVE, 
            STATION_NAME, 
            UP_STATION, 
            EZGI_SETUP_TIME, 
            STATION_ID
		FROM     
        	WORKSTATIONS AS W
		WHERE  
        	ISNULL(ACTIVE, 0) = 1 AND 
            UP_STATION IN (#station_id_list#)
 	</cfquery>
    <cfquery name="get_stations_group" dbtype="query">
    	SELECT
        	COUNT (*) SAY,
            UP_STATION
      	FROM
        	get_stations
      	GROUP BY
        	UP_STATION
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
    	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
        	<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cfinput type="hidden" name="master_plan_cat_id" value="#attributes.master_plan_cat_id#">
            <cfinput type="hidden" name="station_date"  id="station_date" value="">
           	<cf_box_search>
                    <div class="form-group" id="form_ul_date">
                        <div class="col col-12">
                        	<div class="input-group">
                             	<cfsavecontent variable="message"><cf_get_lang dictionary_id='58492.Tarihi Kontrol Ediniz'></cfsavecontent>
                             	<cfinput type="text" name="start_date" value="#dateformat(attributes.start_date, dateformat_style)#" style="width:65px;" validate="#validate_style#" required="yes" maxlength="10" message="#message#"  placeholder="İşlem Tarihi">
                           		<span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <cf_wrk_search_button search_function='input_control()' button_type="4">
                    </div>
         	</cf_box_search>
    	</cfform> 
        
        <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
            <cfform action="" name="search_list" method="post">
                <cfsavecontent variable="title"><cf_get_lang dictionary_id='1366.İstasyon Yükü Raporu'></cfsavecontent>
                <cf_box title="#title#">
                	<cfset dikey = 1>
                    <cfset yatay = 1>
                    <cfif isdefined("attributes.is_form_submitted")>
                 	<div class="col col-12">
                        <cfloop query="get_station_sablon">
                            <cfquery name="get_sub_stations" dbtype="query">
                                SELECT * FROM get_stations WHERE UP_STATION = #get_station_sablon.WORKSTATION_ID# ORDER BY STATION_NAME
                            </cfquery>
                            <cfloop query="get_sub_stations">
                                <cfif yatay eq 13 and get_sub_stations.recordcount neq get_sub_stations.currentrow>
                                    </div>
                                    <div class="col col-12">
                                    <cfset yatay = 1>
                                </cfif>
                                <cfquery name="get_doluluk" dbtype="query">
                                    SELECT 
                                    	SUM(OPTIMUM_TIME*AMOUNT) AS DOLULUK,
                                    	SUM(REAL_AMOUNT) AS REAL_AMOUNT,
                                        SUM(AMOUNT) AS AMOUNT,
                                      	SUM(LOSS_AMOUNT) LOSS_AMOUNT,
                                     	SUM(REAL_TIME) REAL_TIME,
                                    	SUM(WAIT_TIME) WAIT_TIME
                                    FROM 
                                    	get_production_operations
                                    WHERE 
                                    	O_STATION_IP = #get_sub_stations.STATION_ID#
                                </cfquery>
                                <div class="col col-3">
                                    <table width="100%" height="300px" cellpadding="2" cellspacing="0" border="1">
                                        <tr>
                                            <td width="100%" height="20px" style="text-align:center" class="box_yazi_baslik" colspan="2">
                                                <cfoutput>#get_sub_stations.STATION_NAME# <cfif isnumeric(get_sub_stations.EZGI_KATSAYI)>(#AmountFormat(get_sub_stations.EZGI_KATSAYI,2)#)</cfif></cfoutput>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="50%" height="15px" style="text-align:center" class="box_yazi_td">
                                                Çalışma Zamanı
                                            </td>
                                            <td width="50%" style="text-align:center" class="box_yazi">
                                                <cfoutput>#get_station_sablon_main.WORK_TIME#</cfoutput>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="50%" height="20px" style="text-align:center" class="box_yazi_td">
                                                İş Yükü (Süre/Miktar)
                                            </td>
                                            <td width="50%" style="text-align:center" class="box_yazi">
                                                <cfoutput>
													<cfif get_doluluk.DOLULUK gt 0 and isnumeric(get_sub_stations.EZGI_KATSAYI) and get_sub_stations.EZGI_KATSAYI gt 0>
                                                    	#AmountFormat(get_doluluk.DOLULUK/get_sub_stations.EZGI_KATSAYI,0)#
                                                    <cfelse>
                                                    	0
                                                    </cfif>
                                                    / 
                                                    <cfif len(get_doluluk.AMOUNT)>
                                                    	#get_doluluk.AMOUNT#
                                                    <cfelse>
                                                    	0
                                                    </cfif>
												</cfoutput>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="50%" height="15px" style="text-align:center" class="box_yazi_td">
                                                Sonuç (Süre/Miktar)
                                            </td>
                                            <td width="50%" style="text-align:center" class="box_yazi">
                                                <cfoutput>
													<cfif len(get_doluluk.REAL_TIME)>
                                                    	#AmountFormat(get_doluluk.REAL_TIME,0)#
                                                    <cfelse>
                                                    	0
                                                    </cfif>
                                                    / #AmountFormat(get_doluluk.REAL_AMOUNT,0)#
												</cfoutput>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="text-align:center" height="200px">
                                                <!-- Grafik için benzersiz bir div alanı -->
                                                <cfset chartID = "dolulukPieChart_#get_sub_stations.STATION_ID#">
                                                <div id="<cfoutput>#chartID#</cfoutput>" style="width: 100%; height: 100%;"></div>
                        
                                                <!-- ColdFusion Script: DOLULUK Değerini Al -->
                                                <cfif get_doluluk.DOLULUK gt 0 and isnumeric(get_sub_stations.EZGI_KATSAYI) and get_sub_stations.EZGI_KATSAYI gt 0>
                                                    <cfset doluluk = get_doluluk.DOLULUK/get_sub_stations.EZGI_KATSAYI>
                                                <cfelse>
                                                    <cfset doluluk = 0>
                                                </cfif>
                                                <cfset toplam_sure = get_station_sablon_main.WORK_TIME>
                                                <cfset kalan_sure = toplam_sure - doluluk>
                                                <cfif kalan_sure lt 0>
                                                	<cfset kalan_sure = 0>
                                                </cfif>
                        
                                                <!-- JavaScript İçin JSON Veri Kümesi -->
                                                <script>
                                                    window.pieChartData = window.pieChartData || [];
                                                    window.pieChartData.push({
                                                        id: "<cfoutput>#chartID#</cfoutput>",
                                                        doluluk: <cfoutput>#doluluk#</cfoutput>,
                                                        kalan_sure: <cfoutput>#kalan_sure#</cfoutput>,
														baslik_1:'Doluluk',
														baslik_2:'Boş Süre'
                                                    });
                                                </script>
                                            </td>
                                            
                                            <td style="text-align:center">
                                            	<!-- Grafik için benzersiz bir div alanı -->
                                                <cfset chartID = "dolulukPieChart_#get_sub_stations.STATION_ID#">
                                                <div id="<cfoutput>#chartID#_2</cfoutput>" style="width: 100%; height: 100%;"></div>
                        
                                                <!-- ColdFusion Script: Üretim Adedini Al -->
                                                <cfif isnumeric(get_doluluk.AMOUNT) and isnumeric(get_doluluk.REAL_AMOUNT)>
                                                    <cfset uretim_miktar = get_doluluk.AMOUNT>
                                                <cfelse>
                                                    <cfset uretim_miktar = 0>
                                                </cfif>
                                                <cfif uretim_miktar gt 0 and isnumeric(get_doluluk.REAL_AMOUNT)>
                                                	<cfset sonuc_miktar = get_doluluk.REAL_AMOUNT>
                                               	<cfelse>
                                                	<cfset sonuc_miktar = 0>
                                                </cfif>
                                                <cfset kalan_miktar = uretim_miktar - sonuc_miktar>

                                                <!-- JavaScript İçin JSON Veri Kümesi -->
                                                <script>
                                                    window.pieChartData = window.pieChartData || [];
                                                    window.pieChartData.push({
                                                        id: "<cfoutput>#chartID#_2</cfoutput>",
                                                        doluluk: <cfoutput>#uretim_miktar#</cfoutput>,
                                                        kalan_sure: <cfoutput>#kalan_miktar#</cfoutput>,
														baslik_1:"İş Yükü Miktarı",
														baslik_2:"Kalan Miktar"
                                                    });
                                                </script>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <cfset yatay = yatay + 3>
                            </cfloop>
                        </cfloop>
                        
                        <!-- Google Charts - Tüm Grafikleri Tek Seferde Yükle -->
                        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
						<script type="text/javascript">
                            google.charts.load("current", {packages:["corechart"]});
                            google.charts.setOnLoadCallback(drawAllCharts);
                        
                            function drawAllCharts() {
                                if (window.pieChartData) {
                                    window.pieChartData.forEach(function(chartData) {
                                        var data = google.visualization.arrayToDataTable([
                                            ['Kategori', 'Değer', { role: 'style' }],
                                            [chartData.baslik_1, chartData.doluluk, '#ff5733'], // Dış çember - Doluluk
                                            [chartData.baslik_2, chartData.kalan_sure, '#33aaff'], // Dış çember - Boş Süre
                                        ]);
                        
                                        var options = {
                                            pieHole: 0.5,  // Donut Chart (Orta boşluk)
                                            legend: { position: 'none' }, // Legend'ı kaldırır
                                            pieSliceText: 'none', // Dilimlerin üzerine yazı yazılmasını engeller
                                            slices: {
                                                0: { offset: 0.1 }, // Doluluk - Hafif ayrık
                                                1: { offset: 0.1 }, // Boş Süre - Hafif ayrık
                                            }
                                        };
                        
                                        var chart = new google.visualization.PieChart(document.getElementById(chartData.id));
                                        chart.draw(data, options);
                                    });
                                }
                            }
                        </script>

                    </div>
                    </cfif>
                </cf_box> 
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
</script>