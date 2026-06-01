<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
</head>
<!---
    File: cpy_ezgi_product_tree_creative.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfparam name="attributes.x_pvc_kalinlik_erkisi_arama" default="1"><!---1 ise KALINLIK_ETKISI_CODE göre arama yapar - 0 ise KALINLIK_ETKISI_NAME göre arama Yapar--->
<cfquery name="get_design_main_row_setup" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK) ORDER BY MAIN_ROW_SETUP_NAME
</cfquery>
<cfloop query="get_design_main_row_setup">
	<cfset 'MAIN_ROW_SETUP_NAME_#MAIN_ROW_SETUP_ID#' = MAIN_ROW_SETUP_NAME>
</cfloop>
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>
<cfoutput query="get_colors">
	<cfset 'COLOR_NAME_#COLOR_ID#' = COLOR_NAME>
</cfoutput>
<cfquery name="get_thickness" datasource="#dsn3#">
	SELECT THICKNESS_ID, THICKNESS_VALUE FROM EZGI_THICKNESS WITH (NOLOCK)
</cfquery>
<cfoutput query="get_thickness">
	<cfset 'THICKNESS_VALUE_#THICKNESS_ID#' = THICKNESS_VALUE>
</cfoutput>
<cfquery name="get_thickness_ext" datasource="#dsn3#">
	SELECT THICKNESS_ID, THICKNESS_VALUE FROM EZGI_THICKNESS_EXT WITH (NOLOCK)
</cfquery>
<cfoutput query="get_thickness_ext">
	<cfset 'THICKNESS_VALUE_EXT_#THICKNESS_ID#' = THICKNESS_VALUE>
</cfoutput>
<!---Tasarım Bilgisi Ekleme--->
<cfquery name="get_design" datasource="#dsn3#">
	SELECT  * FROM EZGI_DESIGN WITH (NOLOCK) WHERE DESIGN_ID = #attributes.old_design_id#
</cfquery>
<cftransaction>
    <cfquery name="add_design" datasource="#dsn3#">
        INSERT INTO 
            EZGI_DESIGN
            (
            DESIGN_NAME, 
            COLOR_ID, 
            PROCESS_ID, 
            IS_PROTOTIP,
            STATUS, 
            DETAIL, 
            CONSUMER_ID, 
            COMPANY_ID, 
            MEMBER_TYPE,
            MEMBER_NAME,
            PROJECT_ID, 
            PROJECT_HEAD, 
            PROCESS_STAGE,
            PRODUCT_CAT,
            PRODUCT_CAT_CODE,
            PRODUCT_CATID,
            PRODUCT_QUANTITY,
            RECORD_EMP, 
            RECORD_IP, 
            RECORD_DATE
            )
        VALUES        
            (
            '#attributes.new_design_name#',
            #attributes.new_design_color#,
            #get_design.PROCESS_ID#,
            <cfif isdefined('new_design_is_prototype') and new_design_is_prototype eq 1>1<cfelse>0</cfif>,
            #get_design.STATUS#,
            '#get_design.DETAIL#',
            <cfif len(get_design.consumer_id)>#get_design.consumer_id#<cfelse>NULL</cfif>,
            <cfif len(get_design.company_id)>#get_design.company_id#<cfelse>NULL</cfif>,
            <cfif len(get_design.member_type)>'#get_design.member_type#'<cfelse>NULL</cfif>,
            <cfif len(get_design.member_name)>'#get_design.member_name#'<cfelse>NULL</cfif>,
            <cfif len(get_design.project_id)>#get_design.project_id#<cfelse>NULL</cfif>,
            <cfif len(get_design.project_head)>'#get_design.project_head#'<cfelse>NULL</cfif>,
            #get_design.process_stage#,
            <cfif len(get_design.product_cat)>'#get_design.product_cat#'<cfelse>NULL</cfif>,
            <cfif len(get_design.product_cat_code)>'#get_design.product_cat_code#'<cfelse>NULL</cfif>,
            <cfif len(get_design.product_catid)>#get_design.product_catid#<cfelse>NULL</cfif>,
            <cfif len(get_design.PRODUCT_QUANTITY)>#get_design.PRODUCT_QUANTITY#<cfelse>1</cfif>,
            #session.ep.userid#,
            '#cgi.remote_addr#',
            #now()#
            )
    </cfquery>
    <cfquery name="GET_MAXID" datasource="#dsn3#">
        SELECT MAX(DESIGN_ID) AS MAX_ID FROM EZGI_DESIGN WITH (NOLOCK)
    </cfquery>
    <cfset attributes.new_design_id = GET_MAXID.MAX_ID>
    <!---Tasarım Bilgisi Ekleme--->
    <!---Modül Bilgisi Ekleme--->
    <cfquery name="get_main" datasource="#dsn3#">
        SELECT * FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE DESIGN_ID = #attributes.old_design_id# ORDER BY DESIGN_MAIN_ROW_ID
    </cfquery>

    <cfloop query="get_main">
        <cfset new_main_color_name = Evaluate("COLOR_NAME_#Evaluate('new_design_color_#get_main.DESIGN_MAIN_COLOR_ID#')#") >
        <cfset new_main_name = Replace(DESIGN_MAIN_NAME,'#old_design_name#','#new_design_name#','All')>
        <cfset new_main_name = Replace(new_main_name,'#old_design_color_name#','#Evaluate("COLOR_NAME_#new_design_color#")#','All')>
        <cfquery name="add_main" datasource="#dsn3#">
            INSERT INTO 
                EZGI_DESIGN_MAIN_ROW
                (
                DESIGN_ID, 
                DESIGN_MAIN_NAME, 
                DESIGN_MAIN_COLOR_ID, 
                MAIN_ROW_SETUP_ID, 
                DESIGN_MAIN_STATUS, 
                KARMA_KOLI_MIKTAR, 
                OLCU1,
                OLCU2,
                MAIN_PROTOTIP_TYPE,
                RECORD_EMP, 
                RECORD_IP, 
                RECORD_DATE
                )
            VALUES        
                (
                #attributes.new_design_id#,
                '#new_main_name#',
                #Evaluate('new_design_color_#get_main.DESIGN_MAIN_COLOR_ID#')#,
                #get_main.MAIN_ROW_SETUP_ID#,
                #get_main.DESIGN_MAIN_STATUS#,
                <cfif len(get_main.KARMA_KOLI_MIKTAR)>#get_main.KARMA_KOLI_MIKTAR#<cfelse>NULL</cfif>,
                <cfif len(get_main.olcu1)>#get_main.olcu1#<cfelse>NULL</cfif>,
                <cfif len(get_main.olcu2)>#get_main.olcu2#<cfelse>NULL</cfif>,
                <cfif len(get_main.MAIN_PROTOTIP_TYPE)>#get_main.MAIN_PROTOTIP_TYPE#<cfelse>NULL</cfif>,
                #session.ep.userid#,
                '#cgi.remote_addr#',
                #now()#
                )
        </cfquery>
        <cfquery name="GET_MAIN_MAXID" datasource="#dsn3#">
            SELECT MAX(DESIGN_MAIN_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
        </cfquery>
        <cfset 'attributes.new_design_main_id_#get_main.DESIGN_MAIN_ROW_ID#' = GET_MAIN_MAXID.MAX_ID>
        <!---Operasyon Kopyalama--->
     	<cfquery name="cpy_main_rota" datasource="#dsn3#">
        	INSERT INTO 
             	EZGI_DESIGN_PIECE_ROTA
             	(
                  	MAIN_ROW_ID,
                 	OPERATION_TYPE_ID, 
                 	SIRA, 
                	AMOUNT
             	)
        	SELECT      
             	#GET_MAIN_MAXID.MAX_ID#, 
             	OPERATION_TYPE_ID, 
              	SIRA, 
              	AMOUNT
         	FROM            
             	EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
          	WHERE        
           		MAIN_ROW_ID = #get_main.DESIGN_MAIN_ROW_ID#
       	</cfquery>
    </cfloop>	
    <!---Modül Bilgisi Ekleme--->
    <!---Paket Bilgisi Ekleme--->
    <cfquery name="get_package" datasource="#dsn3#">
        SELECT * FROM EZGI_DESIGN_PACKAGE WITH (NOLOCK) WHERE DESIGN_ID = #attributes.old_design_id# ORDER BY DESIGN_MAIN_ROW_ID,PACKAGE_NUMBER
    </cfquery>
    <cfloop query="get_package">
    	<cfif isdefined('attributes.new_design_main_id_#get_package.DESIGN_MAIN_ROW_ID#')>
			<cfset new_package_name = Replace(get_package.PACKAGE_NAME,'#old_design_name#','#new_design_name#','All')>
            <cfset new_package_name = Replace(new_package_name,'#old_design_color_name#','#Evaluate("COLOR_NAME_#new_design_color#")#','All')>
            <cfquery name="add_package" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_DESIGN_PACKAGE_ROW
                    (
                    DESIGN_ID, 
                    DESIGN_MAIN_ROW_ID, 
                    PACKAGE_NUMBER, 
                    PACKAGE_AMOUNT,
                    PACKAGE_BOYU, 
                    PACKAGE_ENI, 
                    PACKAGE_KALINLIK, 
                    PACKAGE_WEIGHT,
                    PACKAGE_COLOR_ID,
                    PACKAGE_NAME,
                    PACKAGE_PARTNER_ID,
                    PACKAGE_IS_MASTER
                    )
                VALUES
                    (
                    #attributes.new_design_id#,
                    #Evaluate('attributes.new_design_main_id_#get_package.DESIGN_MAIN_ROW_ID#')#,
                    #get_package.PACKAGE_NUMBER#,
                    #get_package.PACKAGE_AMOUNT#,
                    <cfif len(get_package.PACKAGE_BOYU)>#get_package.PACKAGE_BOYU#<cfelse>NULL</cfif>, 
                    <cfif len(get_package.PACKAGE_ENI)>#get_package.PACKAGE_ENI#<cfelse>NULL</cfif>, 
                    <cfif len(get_package.PACKAGE_KALINLIK)>#get_package.PACKAGE_KALINLIK#<cfelse>NULL</cfif>, 
                    <cfif len(get_package.PACKAGE_WEIGHT)>#get_package.PACKAGE_WEIGHT#<cfelse>NULL</cfif>,
                    <cfif get_package.PACKAGE_IS_MASTER eq 0>
                        #get_package.PACKAGE_COLOR_ID#,
                        '#get_package.PACKAGE_NAME#',
                        #get_package.PACKAGE_PARTNER_ID#,
                        0
                    <cfelseif get_package.PACKAGE_IS_MASTER eq 1>
                        #get_package.PACKAGE_COLOR_ID#,
                        '#get_package.PACKAGE_NAME#',
                        #get_package.PACKAGE_ROW_ID#,
                        0
                    <cfelse>
                        <cfif isdefined('new_design_color_#get_package.PACKAGE_COLOR_ID#')>#Evaluate('new_design_color_#get_package.PACKAGE_COLOR_ID#')#<cfelse>NULL</cfif>,
                        '#new_package_name#',
                        NULL,
                        NULL
                    </cfif>
                    )
            </cfquery>
      	<cfelse>
        	<script type="text/javascript">
				alert("Dikkat - Modüle Bağlı Olmayan Ortak Paket(ler) Var!");
				window.history.go(-1);
			</script>
            <cfabort>
        </cfif>
        <cfquery name="GET_PACKAGE_MAXID" datasource="#dsn3#">
            SELECT MAX(PACKAGE_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_PACKAGE_ROW WITH (NOLOCK)
        </cfquery>
        <cfset 'attributes.new_package_id_#get_package.PACKAGE_ROW_ID#' = GET_PACKAGE_MAXID.MAX_ID>
     	<!---Operasyon Kopyalama--->
     	<cfquery name="cpy_package_rota" datasource="#dsn3#">
        	INSERT INTO 
             	EZGI_DESIGN_PIECE_ROTA
             	(
                 	PACKAGE_ROW_ID,
                 	OPERATION_TYPE_ID, 
                 	SIRA, 
                	AMOUNT
             	)
        	SELECT      
             	#GET_PACKAGE_MAXID.MAX_ID#, 
             	OPERATION_TYPE_ID, 
              	SIRA, 
              	AMOUNT
         	FROM            
             	EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
          	WHERE        
           		PACKAGE_ROW_ID = #get_package.PACKAGE_ROW_ID#
       	</cfquery>
    </cfloop>
    <!---Paket Bilgisi Ekleme--->
    <!---Parça Bilgisi Ekleme--->
   	<cfset all_tree = 1>
  	<cfquery name="get_piece_info" datasource="#dsn3#">
      	SELECT 
        	* 
      	FROM 
        	EZGI_DESIGN_PIECE WITH (NOLOCK)
      	WHERE 
        	DESIGN_ID = #attributes.old_design_id# AND
			PACKAGE_IS_MASTER IS NULL
      	ORDER BY 
        	PIECE_TYPE, 
            PIECE_CODE
  	</cfquery>
    <cfset new_design_id  = attributes.new_design_id>
  	<cfset old_design_id  = attributes.old_design_id>
  	<cfloop query="get_piece_info">
    	<cfif isdefined('new_design_color_#get_piece_info.PIECE_COLOR_ID#')>
    		<cfset new_piece_color_id = Evaluate('new_design_color_#get_piece_info.PIECE_COLOR_ID#')>
        <cfelse>
        	<cfset new_piece_color_id = get_piece_info.PIECE_COLOR_ID>
        </cfif>
        <cfset old_piece_color_id = get_piece_info.PIECE_COLOR_ID>
        <cfset new_main_id = Evaluate('attributes.new_design_main_id_#get_piece_info.DESIGN_MAIN_ROW_ID#')>
        <cfset old_main_id = get_piece_info.DESIGN_MAIN_ROW_ID>
        <cfif len(get_piece_info.DESIGN_PACKAGE_ROW_ID)>
			<cfset new_package_id = Evaluate('attributes.new_package_id_#get_piece_info.DESIGN_PACKAGE_ROW_ID#')>
            <cfset old_package_id = get_piece_info.DESIGN_PACKAGE_ROW_ID>
        <cfelse>
        	<cfset new_package_id = ''>
            <cfset old_package_id = ''>
        </cfif>
        <cfset old_piece_id = get_piece_info.PIECE_ROW_ID>
        
        <cfif get_piece_info.PIECE_TYPE eq 1> <!---Yonga Levha İse--->
            <cfquery name="get_yonga_levha" datasource="#dsn3#">
                SELECT STOCK_ID FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST WHERE LIST_ORDER_NO = 1 AND COLOR_ID = #new_piece_color_id# AND THICKNESS_ID = #get_piece_info.KALINLIK#
            </cfquery>
            <cfif get_yonga_levha.recordcount eq 1> <!---Tek Yonga Levha Bulduysa İşleme Devam--->
                <cfset yonga_levha_material_id = get_yonga_levha.STOCK_ID>
            <cfelseif get_yonga_levha.recordcount gte 2> <!---Birden Fazla Yonga Levha Bulduysa Geri--->
            	<cfdump var="#get_yonga_levha#"><cfabort>
                <script type="text/javascript">
                    alert('<cfoutput><cf_get_lang dictionary_id='199.Renk'> :#Evaluate("COLOR_NAME_#new_piece_color_id#")#  <cf_get_lang dictionary_id='75.Kalınlık'> :#Evaluate("THICKNESS_VALUE_#get_piece_info.KALINLIK#")#</cfoutput> <cf_get_lang dictionary_id="989.Bu Parametrelerde Birden Fazla Yonga Levha Bulunmuştur. Öncelikle Sorunu Giderin !">');
					window.history.go(-1);
                </script>
                <cfabort>
            <cfelse> <!---Yonga Levha Bulamadıysa Geri--->
                <script type="text/javascript">
                    alert('<cfoutput><cf_get_lang dictionary_id='199.Renk'> :#Evaluate("COLOR_NAME_#new_piece_color_id#")#  <cf_get_lang dictionary_id='75.Kalınlık'> : #Evaluate("THICKNESS_VALUE_#get_piece_info.KALINLIK#")# <cf_get_lang dictionary_id='75.Bu Parametrelerde Yonga Levha Bulunamamıştır !'></cfoutput>');
                	window.history.go(-1);
                </script>
                <cfabort>
            </cfif>
        </cfif>
		<cfif get_piece_info.PIECE_TYPE eq 1 or get_piece_info.PIECE_TYPE eq 3> <!---Yonga Levha veya Montaj Ürünü İse PCV Tanımlama--->
            <cfquery name="get_pvc_old" datasource="#dsn3#">
            	SELECT        
                    EDPR.STOCK_ID, 
                    EDPR.AMOUNT, 
                    EDPR.SIRA_NO, 
                    EDPR.PIECE_ROW_ROW_TYPE, 
                    EPP.COLOR_ID, 
                    EPP.THICKNESS_ID, 
                    EPP.KALINLIK_ETKISI_CODE AS KALINLIK_ETKISI
                FROM            
                    EZGI_DESIGN_PIECE_ROW AS EDPR WITH (NOLOCK) INNER JOIN
                    EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EPP WITH (NOLOCK) ON EDPR.STOCK_ID = EPP.STOCK_ID
                WHERE        
                    EDPR.PIECE_ROW_ID = #old_piece_id#  AND 
                    EDPR.PIECE_ROW_ROW_TYPE = 1
                ORDER BY 
                    EDPR.SIRA_NO
            </cfquery>
            <cfif get_pvc_old.recordcount>
                <cfloop query="get_pvc_old">
                	<cfif attributes.x_pvc_kalinlik_erkisi_arama eq 1>
                        <cfquery name="get_pvc_new" datasource="#dsn3#">
                            SELECT 
                                STOCK_ID 
                            FROM 
                                EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
                            WHERE 
                                COLOR_ID = #new_piece_color_id# AND 
                                LIST_ORDER_NO = 3 AND 
                                THICKNESS_ID = #get_pvc_old.THICKNESS_ID# AND
                                KALINLIK_ETKISI_CODE = '#get_pvc_old.KALINLIK_ETKISI#'
                        </cfquery>
                    <cfelse>
                        <cfquery name="get_pvc_new" datasource="#dsn3#">
                            SELECT 
                                STOCK_ID 
                            FROM 
                                EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
                            WHERE 
                                COLOR_ID = #new_piece_color_id# AND 
                                LIST_ORDER_NO = 3 AND 
                                THICKNESS_ID = #get_pvc_old.THICKNESS_ID# AND
                                KALINLIK_ETKISI_NAME = '#get_pvc_old.KALINLIK_ETKISI#'
                        </cfquery>
                    </cfif>
                    <cfif get_pvc_new.recordcount eq 1> <!---Tek PVC Bulduysa İşleme Devam--->
                        <cfset 'pvc_related_product_id_#SIRA_NO#' = get_pvc_new.STOCK_ID>
                    <cfelseif get_pvc_new.recordcount gte 2> <!---Birden Fazla PVC Bulduysa Geri--->
                        <script type="text/javascript">
                            alert('<cfoutput><cf_get_lang dictionary_id='199.Renk'> :#Evaluate("COLOR_NAME_#new_piece_color_id#")#  <cf_get_lang dictionary_id='75.Kalınlık'> :#Evaluate("THICKNESS_VALUE_#get_pvc_old.THICKNESS_ID#")# * #get_pvc_old.KALINLIK_ETKISI#</cfoutput> <cf_get_lang dictionary_id='987.Bu Parametrelerde Birden Fazla PVC Bulunmuştur. Öncelikle Sorunu Giderin !'> ');
							window.history.go(-1);
                        </script>
                        <cfabort>
                    <cfelse> <!---PVC Bulamadıysa Geri--->
                    	<cfif isdefined('attributes.is_pvc_not_same') and Evaluate('attributes.is_pvc_not_same') eq 1><!--- Bulunamadıysa Aynı PVC yi Kullan seçilmişse ise--->
                        	<cfset 'pvc_related_product_id_#SIRA_NO#' = get_pvc_old.stock_id>
                        <cfelse>
							<script type="text/javascript">
                                alert('<cfoutput><cf_get_lang dictionary_id='199.Renk'> :#Evaluate("COLOR_NAME_#new_piece_color_id#")#   <cf_get_lang dictionary_id='75.Kalınlık'> : #Evaluate("THICKNESS_VALUE_#get_pvc_old.THICKNESS_ID#")# * #get_pvc_old.KALINLIK_ETKISI#</cfoutput> <cf_get_lang dictionary_id='986.Bu Parametrelerde PVC Bulunamamıştır'> !');
								window.history.go(-1);
                            </script>
                            <cfabort>
                        </cfif>
                    </cfif>
                </cfloop>
            <cfelse> <!---PVC Listesi Alınamadıysa--->
            
            </cfif>
        </cfif>
        <cfquery name="get_piece_row" datasource="#dsn3#"> <!---Bu Parçanın Eklentileri Bulunuyor--->
            SELECT 
            	PIECE_ROW_ROW_ID,
                STOCK_ID, 
                AMOUNT, 
                SIRA_NO,
                RELATED_PIECE_ROW_ID, 
                PIECE_ROW_ROW_TYPE,
                EZGI_PIECE_ROW_ROW_ID 
          	FROM 
            	EZGI_DESIGN_PIECE_ROW WITH (NOLOCK) 
          	WHERE 
            	PIECE_ROW_ID = #old_piece_id#
        </cfquery>
        <cfset new_piece_code = get_piece_info.PIECE_CODE>
        <cfset ortak_parca_stock_id = 0>
     	<cfif isdefined('attributes.is_otak_parca') and attributes.is_otak_parca eq 1 and get_design.PROCESS_ID eq 1><!---Workcube Bağlantılı Ortak Parça Olarak Kopyala İse ve Design Modül Paket Parça İse--->
            <cfquery name="get_piece_ortak" datasource="#dsn3#"> <!---Bu Parça Daha Önce Ortak Olarak Kullanılmış mı--->
                SELECT 
                    PIECE_RELATED_ID
                FROM     
                    EZGI_DESIGN_PIECE_ROWS AS EPR WITH (NOLOCK)
                WHERE  
                    PIECE_RELATED_ID =
                                    (
                                        SELECT 
                                            TOP (100) PERCENT PIECE_RELATED_ID
                                        FROM      
                                            EZGI_DESIGN_PIECE_ROWS AS EZGI_DESIGN_PIECE_ROWS_2 WITH (NOLOCK)
                                        WHERE   
                                            PIECE_RELATED_ID IN
                                                            (
                                                                SELECT 
                                                                    PIECE_RELATED_ID
                                                                FROM      
                                                                    EZGI_DESIGN_PIECE_ROWS AS EZGI_DESIGN_PIECE_ROWS_1 WITH (NOLOCK)
                                                                WHERE   
                                                                    PIECE_TYPE <> 4
                                                                GROUP BY 
                                                                    PIECE_RELATED_ID
                                                                HAVING  
                                                                    NOT (PIECE_RELATED_ID IS NULL) AND 
                                                                    COUNT(*) > 1
                                                            ) AND 
                                            PIECE_ROW_ID = #old_piece_id#
                                    ) AND
                     PIECE_ROW_ID <> #old_piece_id#
            </cfquery>
            <cfif get_piece_ortak.recordcount>
            	<cfset ortak_parca_stock_id = get_piece_ortak.PIECE_RELATED_ID>
            </cfif>
      	</cfif>
        <cfquery name="add_piece" datasource="#dsn3#"> <!---Yeni Parça Ekleniyor--->
            INSERT INTO 
                EZGI_DESIGN_PIECE_ROWS
                (
                    PIECE_RELATED_ID,
                    PIECE_NAME, 
                    PIECE_COLOR_ID, 
                    MASTER_PRODUCT_ID, 
                    MATERIAL_ID, 
                    TRIM_TYPE,
                    TRIM_SIZE, 
                    TRIM_1,
                    TRIM_2,
                    TRIM_3,
                    TRIM_4,
                    IS_FLOW_DIRECTION, 
                    BOYU, 
                    ENI, 
                    KESIM_BOYU,
                    KESIM_ENI,
                    KALINLIK,
                    PIECE_DETAIL, 
                    PIECE_CODE,
                    PIECE_TYPE,
                    DESIGN_MAIN_ROW_ID, 
                    DESIGN_PACKAGE_ROW_ID, 
                    DESIGN_ID,
                    PIECE_STATUS,
                    PIECE_AMOUNT,
                    AGIRLIK,
                    CANALIZING_TYPE, 
                    BOY_FARK,
                    EN_FARK,
                    RECORD_EMP, 
                    RECORD_IP, 
                    RECORD_DATE
                )
            VALUES        
                (
                    <cfif get_piece_info.PIECE_TYPE eq 4>
                    	#ListFirst(Evaluate('attributes.new_design_stock_id_#get_piece_info.PIECE_RELATED_ID#'))#
                   	<cfelse>
                    	<cfif isdefined('ortak_parca_stock_id') and ortak_parca_stock_id gt 0>
                        	#ortak_parca_stock_id#
                       	<cfelse>
                        	NULL
                      	</cfif>
                  	</cfif>,
                    <cfif get_piece_info.PIECE_TYPE eq 4>
                    	'#ListGetAt(Evaluate('attributes.new_design_stock_id_#get_piece_info.PIECE_RELATED_ID#'),2)#',
                  	<cfelse>
                    	<cfif len(get_piece_info.PIECE_NAME)>'#get_piece_info.PIECE_NAME#'<cfelse>NULL</cfif>,
                    </cfif>
                    <cfif len(new_piece_color_id)>#new_piece_color_id#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.MASTER_PRODUCT_ID)>#get_piece_info.MASTER_PRODUCT_ID#<cfelse>NULL</cfif>,
                    <cfif isdefined('yonga_levha_material_id') and len(yonga_levha_material_id)>#yonga_levha_material_id#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.TRIM_TYPE)>#get_piece_info.TRIM_TYPE#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.TRIM_SIZE)>#get_piece_info.TRIM_SIZE#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.TRIM_1)>#get_piece_info.TRIM_1#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.TRIM_2)>#get_piece_info.TRIM_2#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.TRIM_3)>#get_piece_info.TRIM_3#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.TRIM_4)>#get_piece_info.TRIM_4#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.IS_FLOW_DIRECTION)>#get_piece_info.IS_FLOW_DIRECTION#<cfelse>0</cfif>,
                    <cfif len(get_piece_info.BOYU)>#get_piece_info.BOYU#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.ENI)>#get_piece_info.ENI#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.KESIM_BOYU)>#get_piece_info.KESIM_BOYU#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.KESIM_ENI)>#get_piece_info.KESIM_ENI#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.KALINLIK)>#get_piece_info.KALINLIK#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.PIECE_DETAIL)>'#get_piece_info.PIECE_DETAIL#'<cfelse>NULL</cfif>,
                    '#new_piece_code#',
                    #get_piece_info.PIECE_TYPE#,
                    #new_main_id#,
                    <cfif len(new_package_id)>#new_package_id#<cfelse>NULL</cfif>,
                    #new_design_id#,
                    #get_piece_info.PIECE_STATUS#,
                    #get_piece_info.PIECE_AMOUNT#,
                    <cfif len(get_piece_info.AGIRLIK)>#get_piece_info.AGIRLIK#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.CANALIZING_TYPE)>#get_piece_info.CANALIZING_TYPE#<cfelse>NULL</cfif>, 
                    <cfif len(get_piece_info.BOY_FARK)>#get_piece_info.BOY_FARK#<cfelse>NULL</cfif>,
                    <cfif len(get_piece_info.EN_FARK)>#get_piece_info.EN_FARK#<cfelse>NULL</cfif>,
                    #session.ep.userid#,
                    '#cgi.remote_addr#',
                    #now()#
                )
        </cfquery>
     	<cfquery name="get_piece_max_id" datasource="#dsn3#"> <!---Yeni Parçanın ID si Bulunuyor--->
            SELECT MAX(PIECE_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK)
        </cfquery>
        <cfset 'new_piece_id_#old_piece_id#' = get_piece_max_id.MAX_ID>
        <cfloop query="get_piece_row"> <!---Eski parçanın Eklentileri Döndürülerek Yeni Parçaya Ekleniyor--->
            <cfquery name="add_piece_row" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_DESIGN_PIECE_ROW
                    (
                        PIECE_ROW_ID, 
                        SIRA_NO,
                        PIECE_ROW_ROW_TYPE,
                        AMOUNT,
                        <cfif get_piece_row.PIECE_ROW_ROW_TYPE eq 4>
                            RELATED_PIECE_ROW_ID
                        <cfelse>
                            STOCK_ID
                        </cfif>
                    )
                VALUES        
                    (
                        #get_piece_max_id.max_id#,
                        #get_piece_row.SIRA_NO#,
                        #get_piece_row.PIECE_ROW_ROW_TYPE#,
                        #get_piece_row.AMOUNT#,
                        <cfif get_piece_row.PIECE_ROW_ROW_TYPE eq 1><!---PVC--->
                            #Evaluate('pvc_related_product_id_#SIRA_NO#')#
                        <cfelseif get_piece_row.PIECE_ROW_ROW_TYPE eq 0> <!---Yonga Levha--->
                            #yonga_levha_material_id#
                        <cfelseif get_piece_row.PIECE_ROW_ROW_TYPE eq 4> <!---Montaj Edilen Parçalar--->
                        	<cfif isdefined('new_piece_id_#get_piece_row.RELATED_PIECE_ROW_ID#')>#Evaluate('new_piece_id_#get_piece_row.RELATED_PIECE_ROW_ID#')#<cfelse>NULL</cfif>
                      	<cfelseif get_piece_row.PIECE_ROW_ROW_TYPE eq 2 or get_piece_row.PIECE_ROW_ROW_TYPE eq 3> <!---Aksesuar veya Hizmet--->
                            #ListFirst(Evaluate('attributes.new_design_stock_id_#get_piece_row.STOCK_ID#'))#
                        <cfelse>
                            #get_piece_row.STOCK_ID#
                        </cfif>
                    )
            </cfquery>
            <cfquery name="get_piece_row_row_max_id" datasource="#dsn3#"> <!---Yeni Parçaya Eklenen Eklentinin Yeni Id si Bulunuyor--->
                SELECT MAX(PIECE_ROW_ROW_ID) AS MAX_ID FROM EZGI_DESIGN_PIECE_ROW WITH (NOLOCK)
            </cfquery>
            <cfquery name="upd_ezgi_piece_row_row" datasource="#dsn3#"> <!---Yeni Parça ID si EZGI Id ye güncelleniyor--->
            	UPDATE 
                	EZGI_DESIGN_PIECE_ROW 
               	SET 
                	EZGI_PIECE_ROW_ROW_ID = #get_piece_row_row_max_id.MAX_ID#
               	WHERE 
                	PIECE_ROW_ROW_ID = #get_piece_row_row_max_id.MAX_ID#
            </cfquery>
            <cfif isdefined('new_design_is_prototype') and new_design_is_prototype eq 1 and len(get_piece_row.EZGI_PIECE_ROW_ROW_ID)><!---Özelleştirilebilir Ürün İse--->
				<!---Aksesuar Özelleştirme Bilgisi Kopyalama--->
                <cfquery name="cpy_prototip_row_row" datasource="#dsn3#">
                    INSERT INTO
                        EZGI_DESIGN_PIECE_PROTOTIP
                        (
                            EZGI_PIECE_ROW_ROW_ID, 
                            QUESTION_ID, 
                            BOY_FORMUL, 
                            EN_FORMUL, 
                            IS_AMOUNT_CHANGE, 
                            IS_PRICE_CHANGE, 
                            IS_SIMILAR_STOCK, 
                            AMOUNT_FORMUL, 
                            PRIVATE_PRICE_TYPE, 
                            PRIVATE_PRICE, 
                            PRIVATE_PRICE_MONEY
                        )
                    SELECT 
                        #get_piece_row_row_max_id.MAX_ID#,
                        QUESTION_ID, 
                        BOY_FORMUL, 
                        EN_FORMUL, 
                        IS_AMOUNT_CHANGE, 
                        IS_PRICE_CHANGE, 
                        IS_SIMILAR_STOCK, 
                        AMOUNT_FORMUL, 
                        PRIVATE_PRICE_TYPE, 
                        PRIVATE_PRICE, 
                        PRIVATE_PRICE_MONEY
                    FROM     
                        EZGI_DESIGN_PIECE_PROTOTIP WITH (NOLOCK)
                    WHERE  
                        EZGI_PIECE_ROW_ROW_ID = #get_piece_row.EZGI_PIECE_ROW_ROW_ID#
                </cfquery>
                <!---Aksesuar Özelleştirme Bilgisi Kopyalama--->
                
                <!---Aksesuar Alternatif Bilgisi Kopyalama--->
                <cfquery name="cpy_prototip_row_row_alternative" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE
                        (
                            EZGI_PIECE_ROW_ROW_ID, 
                            ALTERNATIVE_PIECE_ROW_ROW_ID, 
                            ALTERNATIVE_STOCK_ID, 
                            ALTERNATIVE_AMOUNT_FORMUL, 
                            ALTERNATIVE_AMOUNT
                        )
                    SELECT 
                        #get_piece_row_row_max_id.MAX_ID#, 
                        ALTERNATIVE_PIECE_ROW_ROW_ID, 
                        ALTERNATIVE_STOCK_ID, 
                        ALTERNATIVE_AMOUNT_FORMUL, 
                        ALTERNATIVE_AMOUNT
                    FROM     
                        EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE WITH (NOLOCK)
                    WHERE  
                        EZGI_PIECE_ROW_ROW_ID = #get_piece_row.EZGI_PIECE_ROW_ROW_ID#
                </cfquery>
                <!---Aksesuar Alternatif Bilgisi Kopyalama--->
            </cfif>
        </cfloop> 
        <cfif get_piece_info.PIECE_TYPE eq 1 or get_piece_info.PIECE_TYPE eq 2 or get_piece_info.PIECE_TYPE eq 3> <!---Operasyon Kopyalama--->
            <cfquery name="cpy_rota" datasource="#dsn3#">
                INSERT INTO 
                    EZGI_DESIGN_PIECE_ROTA
                    (
                        PIECE_ROW_ID, 
                        OPERATION_TYPE_ID, 
                        SIRA, 
                        AMOUNT
                    )
                SELECT      
                    #get_piece_max_id.MAX_ID#, 
                    OPERATION_TYPE_ID, 
                    SIRA, 
                    AMOUNT
                FROM            
                    EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
                WHERE        
                    PIECE_ROW_ID = #old_piece_id#
            </cfquery>
        </cfif>
      	<cfif isdefined('new_design_is_prototype') and new_design_is_prototype eq 1><!---Özelleştirilebilir Ürün İse--->
        	<!---Parça Özelleştirme Bilgisi Kopyalama--->
        	<cfquery name="cpy_prototip_row" datasource="#dsn3#">
            	INSERT INTO
                	EZGI_DESIGN_PIECE_PROTOTIP
                  	(
                    	PIECE_ROW_ID, 
                        QUESTION_ID, 
                        BOY_FORMUL, 
                        EN_FORMUL, 
                        IS_AMOUNT_CHANGE, 
                        IS_PRICE_CHANGE, 
                        IS_SIMILAR_STOCK, 
                        AMOUNT_FORMUL, 
                        PRIVATE_PRICE_TYPE, 
                        PRIVATE_PRICE, 
                        PRIVATE_PRICE_MONEY
                  	)
				SELECT 
                	#get_piece_max_id.MAX_ID#,
                    QUESTION_ID, 
                    BOY_FORMUL, 
                    EN_FORMUL, 
                    IS_AMOUNT_CHANGE, 
                    IS_PRICE_CHANGE, 
                    IS_SIMILAR_STOCK, 
                    AMOUNT_FORMUL, 
                    PRIVATE_PRICE_TYPE, 
                    PRIVATE_PRICE, 
                    PRIVATE_PRICE_MONEY
				FROM     
                	EZGI_DESIGN_PIECE_PROTOTIP WITH (NOLOCK)
				WHERE  
                	PIECE_ROW_ID = #old_piece_id#
            </cfquery>
            <!---Parça Özelleştirme Bilgisi Kopyalama--->
            
            <!---Parça Alternatif Bilgisi Kopyalama--->
            <cfquery name="cpy_prototip_row_alternative" datasource="#dsn3#">
            	INSERT INTO 
                	EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE
                  	(
                    	PIECE_ROW_ID, 
                        ALTERNATIVE_PIECE_ROW_ID, 
                        ALTERNATIVE_STOCK_ID, 
                        ALTERNATIVE_AMOUNT_FORMUL, 
                        ALTERNATIVE_AMOUNT
                 	)
				SELECT 
                	#get_piece_max_id.MAX_ID#, 
                    ALTERNATIVE_PIECE_ROW_ID, 
                    ALTERNATIVE_STOCK_ID, 
                    ALTERNATIVE_AMOUNT_FORMUL, 
                    ALTERNATIVE_AMOUNT
				FROM     
                	EZGI_DESIGN_PIECE_PROTOTIP_ALTERNATIVE WITH (NOLOCK)
				WHERE  
                	PIECE_ROW_ID = #old_piece_id#
            </cfquery>
            <!---Parça Alternatif Bilgisi Kopyalama--->
        </cfif>
  	</cfloop>
    <!---Parça Bilgisi Ekleme--->
</cftransaction>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&design_id=#get_maxid.max_id#" addtoken="no">
</body>
</html>