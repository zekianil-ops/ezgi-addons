<!---
    File: upd_ezgi_product_tree_creative_piece_row.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfparam name="attributes.related_product_id" default="">
<cfparam name="attributes.related_stock_id" default="">
<cfparam name="attributes.related_product_name" default="">
<cfparam name="attributes.package_row_id" default="">
<cfquery name="get_main_defaults" datasource="#dsn3#">
	SELECT        
    	DEFAULT_YONGA_LEVHA_THICKNESS, 
        DEFAULT_YONGA_LEVHA_FIRE_RATE, 
        DEFAULT_PVC_THICKNESS, 
        DEFAULT_PVC_FIRE_AMOUNT, 
        DEFAULT_PIECE_TYPE, 
        DEFAULT_TRIM_TYPE, 
    	DEFAULT_TRIM_AMOUNT,
        DEFAULT_PIECE_STYLE_ID,
        DEFAULT_PIECE_UNIT,
        DEFAULT_PIECE_CANALIZING        
	FROM            
    	EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<!---Defaultlar--->
<cfparam name="attributes.piece_type" default="#get_main_defaults.DEFAULT_PIECE_TYPE#">
<cfparam name="attributes.pvc_fire_amount" default="#get_main_defaults.DEFAULT_PVC_FIRE_AMOUNT#">
<cfparam name="attributes.yonga_levha_fire_rate" default="#get_main_defaults.DEFAULT_YONGA_LEVHA_FIRE_RATE#">
<cfparam name="attributes.default_thickness" default="#get_main_defaults.DEFAULT_YONGA_LEVHA_THICKNESS#">
<cfparam name="attributes.unit" default="#get_main_defaults.DEFAULT_PIECE_UNIT#">
<cfset default_style = get_main_defaults.DEFAULT_PIECE_STYLE_ID>
<!---Defaultlar--->

<cfquery name="get_upd_piece" datasource="#dsn3#"> <!---Update Edilecek Parçanın Bilgileri--->
	SELECT 
    	*,
        ISNULL(TRIM_1,0) AS EDGE_TRIM_1,
        ISNULL(TRIM_2,0) AS EDGE_TRIM_2,
        ISNULL(TRIM_3,0) AS EDGE_TRIM_3,
        ISNULL(TRIM_4,0) AS EDGE_TRIM_4,
        ISNULL(BOY_FARK,0) AS BOY_FARKI,
        ISNULL(EN_FARK,0) AS EN_FARKI,
        ISNULL((SELECT TOP (1) PU.MAIN_UNIT FROM #dsn1_alias#.PRODUCT_UNIT AS PU INNER JOIN #dsn1_alias#.STOCKS AS S ON PU.PRODUCT_ID = S.PRODUCT_ID WHERE S.STOCK_ID = EZGI_DESIGN_PIECE.PIECE_RELATED_ID),'#attributes.unit#') AS MAIN_UNIT
   	FROM 
    	EZGI_DESIGN_PIECE WITH (NOLOCK)
   	WHERE 
    	PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>
<cfset module_name="product">
<cfset var_="upd_purchase_basket">
<cfset total_weight =0>


<cfif x_is_weight eq 1>
	<cfinclude template="../query/get_ezgi_product_tree_creative_material.cfm">
	<cfif get_material.recordcount>
        <CFQuery NAme="get_weight" DBtype="Query" >
            SELECT
                SUM(AMOUNT*WEIGHT) AS TOTAL_WEIGHT
            FROM
                get_material
        </cfquery>	
        <cfset total_weight = get_weight.TOTAL_WEIGHT>
    </cfif>
</cfif>

<cfquery name="get_money" datasource="#dsn2#">
	SELECT MONEY FROM SETUP_MONEY WITH (NOLOCK)
</cfquery>
<cfquery name="get_design_piece_image" datasource="#dsn3#">
	SELECT TOP (1) * FROM EZGI_DESIGN_PIECE_IMAGES WITH (NOLOCK) WHERE DESIGN_PIECE_ROW_ID = #attributes.design_piece_row_id# ORDER BY DESIGN_PIECE_ROW_ID DESC
</cfquery>

<cfif isdefined('attributes.erp_link')>
	<!---Bağlantılı Paket ve Modüller Çekiliyor--->
    <cfquery name="get_related_design" datasource="#dsn3#">
        SELECT        
            EDP.PIECE_ROW_ID, 
            EDP.DESIGN_ID, 
            EDP.DESIGN_MAIN_ROW_ID, 
            EDP.DESIGN_PACKAGE_ROW_ID, 
            EDM.DESIGN_MAIN_NAME, 
            EDR.PACKAGE_NAME
        FROM           	
            EZGI_DESIGN_PIECE_ROWS AS EDP WITH (NOLOCK) INNER JOIN
            EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) ON EDP.DESIGN_MAIN_ROW_ID = EDM.DESIGN_MAIN_ROW_ID INNER JOIN
            EZGI_DESIGN_PACKAGE_ROW AS EDR WITH (NOLOCK) ON EDP.DESIGN_PACKAGE_ROW_ID = EDR.PACKAGE_ROW_ID
        WHERE        
            EDP.PIECE_ROW_ID = #attributes.design_piece_row_id#
    </cfquery>
</cfif>

<!---Parça Defaultlar--->
<cfparam name="attributes.trim_type" default="#get_upd_piece.TRIM_TYPE#">
<cfparam name="attributes.trim_rate" default="#get_upd_piece.TRIM_SIZE#">
<!---Parça Defaultlar--->
<cfquery name="get_upd_piece_row" datasource="#dsn3#"> <!---Update Edilecek Parçanın Satır Bilgileri--->
	SELECT 
    	EDP.*,
        (SELECT TOP (1) PIECE_NAME FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = EDP.RELATED_PIECE_ROW_ID) AS PIECE_NAME,
        (SELECT TOP (1) PIECE_CODE FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = EDP.RELATED_PIECE_ROW_ID) AS PIECE_CODE,
        ISNULL((SELECT QUESTION_ID FROM EZGI_DESIGN_PIECE_PROTOTIP WITH (NOLOCK) WHERE EZGI_PIECE_ROW_ROW_ID = EDP.EZGI_PIECE_ROW_ROW_ID),0) AS PIECE_QUESTION_ID,
       	S.PRODUCT_ID, 
        S.PRODUCT_NAME, 
        S.BARCOD,
        PU.MAIN_UNIT
	FROM     
    	PRODUCT_UNIT AS PU WITH (NOLOCK) INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON PU.PRODUCT_UNIT_ID = S.PRODUCT_UNIT_ID RIGHT OUTER JOIN
        EZGI_DESIGN_PIECE_ROW AS EDP WITH (NOLOCK) ON S.STOCK_ID = EDP.STOCK_ID
	WHERE  
    	EDP.PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>

<cfquery name="is_montage_used" datasource="#dsn3#"> <!---Bu Ürün Montajda Kullanıldı mı--->
	SELECT        
    	EZGI_DESIGN_PIECE_ROW.PIECE_ROW_ID, 
        EZGI_DESIGN_PIECE_ROW.RELATED_PIECE_ROW_ID
	FROM            
    	EZGI_DESIGN_PIECE_ROW WITH (NOLOCK) INNER JOIN
     	EZGI_DESIGN_PIECE WITH (NOLOCK) ON EZGI_DESIGN_PIECE_ROW.RELATED_PIECE_ROW_ID = EZGI_DESIGN_PIECE.PIECE_ROW_ID
	WHERE        
    	EZGI_DESIGN_PIECE_ROW.RELATED_PIECE_ROW_ID = #attributes.design_piece_row_id#
</cfquery>
<cfif get_upd_piece.PIECE_TYPE eq 3>
<cfquery name="get_montage_product" datasource="#dsn3#">  <!---Montaj Edilebilecek Parçalara Bu Parçadaki Montaj Edilmiş Parçaların Eklenmesi--->
	SELECT        
    	PIECE_ROW_ID, 
        PIECE_NAME, 
        PIECE_CODE, 
        SUM(PIECE_AMOUNT) AS PIECE_AMOUNT, 
        SUM(USED_AMOUNT) AS USED_AMOUNT
	FROM            
    	(
        	SELECT        
            	E.PIECE_ROW_ID, 
                E.PIECE_NAME, 
                E.PIECE_CODE, 
                E.PIECE_AMOUNT, 
                ISNULL(TBL_1.AMOUNT, 0) AS USED_AMOUNT
        	FROM            
            	EZGI_DESIGN_PIECE AS E WITH (NOLOCK) LEFT OUTER JOIN
           		(
                	SELECT        
                    	RELATED_PIECE_ROW_ID, 
                        SUM(AMOUNT) AS AMOUNT
                	FROM            
                    	EZGI_DESIGN_PIECE_ROW WITH (NOLOCK)
                 	GROUP BY 
                    	RELATED_PIECE_ROW_ID
            	) AS TBL_1 ON E.PIECE_ROW_ID = TBL_1.RELATED_PIECE_ROW_ID
     		WHERE        
            	E.PIECE_TYPE IN (1,2) AND 
                E.PIECE_STATUS = 1 AND 
                E.DESIGN_MAIN_ROW_ID = #get_upd_piece.DESIGN_MAIN_ROW_ID# AND
                ISNULL(TBL_1.AMOUNT, 0) < E.PIECE_AMOUNT
       		UNION ALL
      		SELECT        
            	EPR.RELATED_PIECE_ROW_ID, 
                EP.PIECE_NAME, 
                EP.PIECE_CODE, 
                EPR.AMOUNT, 
                0 AS USED_AMOUNT
       		FROM            
            	EZGI_DESIGN_PIECE_ROW AS EPR WITH (NOLOCK) INNER JOIN
           		EZGI_DESIGN_PIECE_ROWS AS EP WITH (NOLOCK) ON EPR.RELATED_PIECE_ROW_ID = EP.PIECE_ROW_ID
          	WHERE        
            	EPR.PIECE_ROW_ID = #attributes.design_piece_row_id#
     	) AS TBL
	GROUP BY 
    	PIECE_ROW_ID, 
        PIECE_NAME, 
        PIECE_CODE
</cfquery>
<cfelse>
	<cfset get_montage_product.recordcount =0>
</cfif>
<cfquery name="get_yari_mamul" dbtype="query">
	SELECT * FROM get_upd_piece_row WHERE PIECE_ROW_ROW_TYPE = 4
</cfquery>
<cfquery name="get_aksesuar" dbtype="query">
	SELECT * FROM get_upd_piece_row WHERE PIECE_ROW_ROW_TYPE = 2
</cfquery>
<cfquery name="get_hzm" dbtype="query">
	SELECT * FROM get_upd_piece_row WHERE PIECE_ROW_ROW_TYPE = 3
</cfquery>
<cfquery name="get_pvc_1" dbtype="query">
	SELECT * FROM get_upd_piece_row WHERE PIECE_ROW_ROW_TYPE = 1 AND SIRA_NO = 1
</cfquery>
<cfif get_pvc_1.recordcount>
	<cfset pvc_1 = get_pvc_1.STOCK_ID>
<cfelse>
	<cfset pvc_1 = 0>
</cfif>
<cfquery name="get_pvc_2" dbtype="query">
	SELECT * FROM get_upd_piece_row WHERE PIECE_ROW_ROW_TYPE = 1 AND SIRA_NO = 2
</cfquery>
<cfif get_pvc_2.recordcount>
	<cfset pvc_2 = get_pvc_2.STOCK_ID>
<cfelse>
	<cfset pvc_2 = 0>
</cfif>
<cfquery name="get_pvc_3" dbtype="query">
	SELECT * FROM get_upd_piece_row WHERE PIECE_ROW_ROW_TYPE = 1 AND SIRA_NO = 3
</cfquery>
<cfif get_pvc_3.recordcount>
	<cfset pvc_3 = get_pvc_3.STOCK_ID>
<cfelse>
	<cfset pvc_3 = 0>
</cfif>
<cfquery name="get_pvc_4" dbtype="query">
	SELECT * FROM get_upd_piece_row WHERE PIECE_ROW_ROW_TYPE = 1 AND SIRA_NO = 4
</cfquery>
<cfif get_pvc_4.recordcount>
	<cfset pvc_4 = get_pvc_4.STOCK_ID>
<cfelse>
	<cfset pvc_4 = 0>
</cfif>


<!---Parça Defaultlarını Çekme--->
<cfquery name="get_colors" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK) ORDER BY COLOR_NAME
</cfquery>

<cfquery name="get_piece_defaults" datasource="#dsn3#">
	SELECT PIECE_DEFAULT_ID, PIECE_DEFAULT_CODE, PIECE_DEFAULT_NAME FROM EZGI_DESIGN_PIECE_DEFAULTS WITH (NOLOCK) ORDER BY PIECE_DEFAULT_NAME
</cfquery>

<!---Parça Defaultlarını Çekme--->
<!---Paket Bilgisi Çekme--->
<cfquery name="get_design_package_row" datasource="#dsn3#">
	SELECT PACKAGE_NUMBER, PACKAGE_ROW_ID FROM EZGI_DESIGN_PACKAGE WITH (NOLOCK) WHERE DESIGN_MAIN_ROW_ID = #get_upd_piece.design_main_row_id# AND PACKAGE_PARTNER_ID IS NULL ORDER BY PACKAGE_NUMBER
</cfquery>

<!---Paket Bilgisi Çekme--->
<!---Modül Bilgisi Çekme--->
<cfquery name="get_design_main_row" datasource="#dsn3#">
	SELECT 
    	*, 
        (SELECT MAIN_ROW_SETUP_NAME FROM EZGI_DESIGN_MAIN_ROW_SETUP WITH (NOLOCK) WHERE MAIN_ROW_SETUP_ID = EZGI_DESIGN_MAIN_ROW.MAIN_ROW_SETUP_ID) as MAIN_ROW_SETUP_NAME,
        (SELECT COLOR_NAME FROM EZGI_COLORS WITH (NOLOCK) WHERE COLOR_ID = EZGI_DESIGN_MAIN_ROW.DESIGN_MAIN_COLOR_ID) as COLOR_NAME
  	FROM 
    	EZGI_DESIGN_MAIN_ROW WITH (NOLOCK)
  	WHERE 
    	DESIGN_MAIN_ROW_ID = #get_upd_piece.design_main_row_id#
</cfquery>

<cfset main_setup_name = get_design_main_row.MAIN_ROW_SETUP_NAME>
<!---Modül Bilgisi Çekme--->
<!---Kalınlık Bilgisi Çekme--->
<cfif len(get_upd_piece.PIECE_COLOR_ID)>
    <cfquery name="get_thickness" datasource="#dsn3#">
    	SELECT        
    	THICKNESS_ID, 
        THICKNESS_VALUE, 
        THICKNESS_NAME, 
        UNIT
	FROM            
    	EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
	WHERE        
    	COLOR_ID = #get_upd_piece.PIECE_COLOR_ID# AND 
        LIST_ORDER_NO = 1
	ORDER BY 
    	THICKNESS_NAME
    </cfquery>
<cfelse>
	<cfset get_thickness.recordcount = 0>
</cfif>
<!---Kalınlık Bilgisi Çekme--->
<!---Style Bilgisi Çekme--->
<cfquery name="get_style" datasource="#dsn3#">
	SELECT  * FROM EZGI_DESIGN_PIECE_STYLE WITH (NOLOCK) ORDER BY EZGI_PIECE_STYLE_NAME
</cfquery>

<!---Style Bilgisi Çekme--->
<!---Tasarım Bilgisi Çekme--->
<cfquery name="get_design" datasource="#dsn3#">
	SELECT  
    	DESIGN_CODE, 
        DESIGN_NAME, 
        COLOR_ID, 
        PROCESS_ID, 
        STATUS, 
        ISNULL(IS_PROTOTIP,0) AS IS_PROTOTIP, 
        ISNULL(IS_PRIVATE,0) AS IS_PRIVATE, 
        DETAIL, 
        PROJECT_HEAD, 
        PROCESS_STAGE, 
        PRODUCT_CAT,  
       	PRODUCT_QUANTITY, 
        RECORD_EMP, 
        RECORD_IP, 
        RECORD_DATE, 
        UPDATE_EMP, 
        UPDATE_IP, 
        UPDATE_DATE
   	FROM 
    	EZGI_DESIGN WITH (NOLOCK)
   	WHERE 
    	DESIGN_ID = #get_upd_piece.DESIGN_ID#
</cfquery>

<!---Tasarım Bilgisi Çekme--->
<!---Yonga Levha Reçete Satırlarını Belirleme--->
<cfquery name="get_yonga_levha" datasource="#DSN3#">
	SELECT        
    	*
	FROM            
    	EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
	WHERE
    	LIST_ORDER_NO = 1
    	<cfif len(get_upd_piece.PIECE_COLOR_ID)>
        	AND COLOR_ID = #get_upd_piece.PIECE_COLOR_ID# 
        </cfif>
        <cfif len(get_upd_piece.KALINLIK)>
        	AND THICKNESS_ID = #get_upd_piece.KALINLIK#
        </cfif>
	ORDER BY 
    	THICKNESS_NAME
</cfquery>

<!---Yonga Levha Reçete Satırlarını Belirleme--->
<!---PVC Reçete Satırlarını Belirleme--->
<cfquery name="get_pvc1" datasource="#DSN3#">
	SELECT        


    	*,
        0 AS S_TYPE
	FROM            
    	EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
	WHERE
    	LIST_ORDER_NO = 3
        <cfif len(get_upd_piece.KALINLIK)>
    		AND THICKNESS_ID = #get_upd_piece.KALINLIK#
      	</cfif>        
    	<cfif len(get_upd_piece.PIECE_COLOR_ID)>


        	AND COLOR_ID = #get_upd_piece.PIECE_COLOR_ID# 
        </cfif>
	ORDER BY 
    	PRODUCT_NAME
</cfquery>

<cfset s_stock_id_list = ValueList(get_pvc1.STOCK_ID)>
<cfquery name="get_pvc2" datasource="#DSN3#">
	SELECT        
    	*,
        1 AS S_TYPE
	FROM            
    	EZGI_DESIGN_PRODUCT_PROPERTIES_UST WITH (NOLOCK)
	WHERE
    	LIST_ORDER_NO = 3
    	<cfif len(get_upd_piece.KALINLIK)>
    		AND THICKNESS_ID = #get_upd_piece.KALINLIK#    
        </cfif>    
        <cfif Listlen(s_stock_id_list)>  
        	AND STOCK_ID NOT IN (#s_stock_id_list#) 
        </cfif>
	ORDER BY 
    	PRODUCT_NAME
</cfquery>

<cfquery name="get_pvc" dbtype="query">
	<cfif Listlen(s_stock_id_list)>
        SELECT
            PRODUCT_NAME,
            STOCK_ID,
            S_TYPE
        FROM
            get_pvc1
        UNION ALL
    </cfif>
    SELECT
    	PRODUCT_NAME,
        STOCK_ID,
        S_TYPE
   	FROM
    	get_pvc2
 	ORDER BY
    	S_TYPE,
        PRODUCT_NAME	 	
</cfquery>
<!---PVC Reçete Satırlarını Belirleme--->
<!---Parça Hammadde İse PRODUCT_ID çekme--->
<cfif get_upd_piece.piece_type eq 4>
	<cfquery name="get_product_id" datasource="#dsn1#">
    	SELECT PRODUCT_ID FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_upd_piece.PIECE_RELATED_ID#
    </cfquery>
    <cfset related_product_id = get_product_id.PRODUCT_ID>
<cfelse>
	<cfset related_product_id = 0>
</cfif>
<!---Parça Hammadde İse PRODUCT_ID çekme--->
<!---Ortak Parça Varmı--->
<cfquery name="get_ortak_piece" datasource="#dsn3#">
	SELECT        
    	EPR.PIECE_RELATED_ID, 
        EPR.DESIGN_ID,
        EPR.DESIGN_MAIN_ROW_ID, 
        EPR.DESIGN_PACKAGE_ROW_ID, 
        ED.DESIGN_NAME, 
        EC.COLOR_NAME, 
        EPR.PIECE_NAME, 
        EPR.PIECE_ROW_ID, 
        S.PRODUCT_NAME, 
  		S.PRODUCT_CODE
	FROM            
    	EZGI_DESIGN_PIECE_ROWS AS EPR WITH (NOLOCK) INNER JOIN
      	EZGI_DESIGN AS ED WITH (NOLOCK) ON EPR.DESIGN_ID = ED.DESIGN_ID INNER JOIN
    	STOCKS AS S WITH (NOLOCK) ON EPR.PIECE_RELATED_ID = S.STOCK_ID LEFT OUTER JOIN
    	EZGI_COLORS AS EC WITH (NOLOCK) ON ED.COLOR_ID = EC.COLOR_ID
	WHERE        
    	EPR.PIECE_RELATED_ID =
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
                                                                	(NOT (PIECE_RELATED_ID IS NULL)) AND 
                                                                    COUNT(*) > 1
                                                          	) AND 
                                 		PIECE_ROW_ID =#attributes.design_piece_row_id#
                               	) AND 
    	EPR.PIECE_ROW_ID <> #attributes.design_piece_row_id# AND
        ISNULL(ED.IS_PRIVATE, 0) = 0 <!---AND
        ISNULL(ED.IS_PROTOTIP,0) = 0--->
</cfquery>

<cfif get_ortak_piece.recordcount>
	<cfset is_common_piece_list = ValueList(get_ortak_piece.PIECE_ROW_ID)>
    <cfset is_common_piece_list = ListDeleteDuplicates(is_common_piece_list,',')>
</cfif>
<!---Ortak Parça Varmı--->
<!---Özelleştirilebilen Dizayn ise Özellik Girildimi--->
<cfif get_design.IS_PROTOTIP>
	<cfquery name="get_prototip" datasource="#dsn3#">
    	SELECT * FROM EZGI_DESIGN_PIECE_PROTOTIP WHERE PIECE_ROW_ID = #attributes.design_piece_row_id#
    </cfquery>
</cfif>

<!---Özelleştirilebilen Dizayn ise Özellik Girildimi--->
<cfsavecontent variable="right">
	<cfoutput>
      	<cfif get_ortak_piece.RECORDCOUNT>
       		<img src="/images/bugpro.gif" border="0" style="vertical-align:top" title="<cf_get_lang dictionary_id='58599.Dikkat'> : <cf_get_lang dictionary_id='63.Ortak Parça'>" >
      		&nbsp;
     	</cfif>
    	<cfif get_design.IS_PROTOTIP and get_design_main_row.MAIN_PROTOTIP_TYPE eq 1>
        	<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_row_prototip&design_piece_row_id=#attributes.design_piece_row_id#','small');">
				<cfif get_prototip.recordcount>
                    <img src="images/cube_vote_red.gif"  title="<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> " border="0" style="vertical-align:middle">
                <cfelse>
                    <img src="images/cube_vote_yellow.gif"  title="<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> " border="0" style="vertical-align:middle">
                </cfif>
      		</a>&nbsp;
      	</cfif>
  		<cfif is_montage_used.recordcount>
        	<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_row&design_piece_row_id=#is_montage_used.piece_row_id#','list');"><img src="/images/tree_bt_related.gif" border="0" title="<cf_get_lang dictionary_id='929.İlişkili  Üst Parça'>"></a>&nbsp;
      	</cfif>
     	<cfif get_upd_piece.PIECE_TYPE eq 1 or get_upd_piece.PIECE_TYPE eq 2>
       		<a style="cursor:pointer" onclick="copy_piece_row(#get_upd_piece.PIECE_ROW_ID#);"><img src="images/plus.gif"  title="<cf_get_lang dictionary_id='57476.Kopyala'>" border="0" style="vertical-align:middle"></a>&nbsp;
     	</cfif>
        <a style="cursor:pointer" onclick="options_info();"><img src="images/help_desk_it.gif"  title="<cf_get_lang dictionary_id='886.Ek Bilgi Tanımları'>" border="0" style="vertical-align:middle"></a>&nbsp;
     	<cfif get_upd_piece.PIECE_TYPE eq 1 or get_upd_piece.PIECE_TYPE eq 2 or get_upd_piece.PIECE_TYPE eq 3>
         	<a href="javascript://" onClick="add_piece_images();"><img src="/images/photo.gif" align="absmiddle" title="<cf_get_lang dictionary_id='57514.Resim Ekle'>"></a>&nbsp;
         	<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_rota&piece_id=#attributes.design_piece_row_id#<cfif get_ortak_piece.recordcount and ListLen(is_common_piece_list)>&is_common_piece_list=#is_common_piece_list#</cfif>','list');"><img src="/images/action.gif" border="0" title="#getLang('campaign',244)# #getLang('main',2806)#" style="vertical-align:top" ></a>
     	</cfif>
  	</cfoutput>
   	&nbsp;&nbsp;
</cfsavecontent>
<cfsavecontent variable="title_">
	<cfoutput>
    	<cf_get_lang dictionary_id='920.Parça Güncelle'> &nbsp;&nbsp;&nbsp;
      	&nbsp;
      	<span style="line-height:28px;padding:3px;font-size:14px;font-family:Geneva, tahoma, arial,Helvetica, sans-serif;font-weight:bold;">
         	#get_upd_piece.PIECE_CODE#
       	</span>
      	&nbsp;
   	</cfoutput>
</cfsavecontent>
<cf_box title="#title_#" right_images="#right#">
    <cf_box>
    	<cfform name="upd_piece_main_row" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative_piece_row">
        	<cfinput type="hidden" name="design_id" value="#get_upd_piece.DESIGN_ID#">
        	<cfinput type="hidden" name="design_main_row_id" value="#get_upd_piece.design_main_row_id#">
           	<cfinput type="hidden" name="design_piece_row_id" value="#attributes.design_piece_row_id#">
           	<cfinput type="hidden" name="pvc_fire_amount" value="#attributes.pvc_fire_amount#">
           	<cfinput type="hidden" name="yonga_levha_fire_rate" value="#attributes.yonga_levha_fire_rate#">
          	<cfinput type="hidden" name="piece_trim_type" value="#get_main_defaults.DEFAULT_TRIM_TYPE#">
            <cfif get_ortak_piece.recordcount>
             	<cfinput type="hidden" name="is_common_piece_list" value="#is_common_piece_list#">
         	</cfif>
            <cf_box_elements>
            	<div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                	<div class="form-group" id="piece_type_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='831.Parça Tipi'>*</label>
                       	<div class="col col-7 col-xs-12">
                        	<select name="piece_type" id="piece_type" style="width:200px;height:20px" onchange="piece_types();">
                            	<option value="1" <cfif get_upd_piece.PIECE_TYPE eq 1>selected</cfif>>01-<cf_get_lang dictionary_id ='898.Yonga Levha Reçete İşlemi'></option>
                             	<option value="2" <cfif get_upd_piece.PIECE_TYPE eq 2>selected</cfif>>02-<cf_get_lang dictionary_id ='899.Genel Reçete İşlemi'></option>
                             	<option value="3" <cfif get_upd_piece.PIECE_TYPE eq 3>selected</cfif>>03-<cf_get_lang dictionary_id ='74.Reçetedeki Ürünün Montajı'></option>
                              	<option value="4" <cfif get_upd_piece.PIECE_TYPE eq 4>selected</cfif>>04-<cf_get_lang dictionary_id ='900.Hammadde Ekle'></option>
                        	</select>
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_default_type_" <cfif get_upd_piece.piece_type eq 4>style="display:none"</cfif>>
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='832.Örnek Parça'>*</label>
                       	<div class="col col-7 col-xs-12">
                        	<div class="input-group">
                            	<select name="default_type" id="default_type" style="width:130px;height:20px" onchange="hesapla();">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_piece_defaults">
                                        <option value="#PIECE_DEFAULT_ID#" <cfif get_upd_piece.MASTER_PRODUCT_ID eq PIECE_DEFAULT_ID>selected</cfif>>#PIECE_DEFAULT_NAME#</option>
                                    </cfoutput>
                                </select>
                            	<span class="input-group-addon">
                                	<span class="icn-md icon-add" style="cursor:pointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_ezgi_default_piece&event=add&is_piece=1','small');" title="<cf_get_lang dictionary_id='44630.Ekle'>"></span>
                            	</span>
                            </div>
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_name_" <cfif get_upd_piece.piece_type eq 4>style="display:none"</cfif>>

                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='399.Parça Adı'>*</label>
                       	<div class="col col-7 col-xs-12">
                        	<cfinput type="text" name="design_name_piece_row" id="design_name_piece_row" value="#get_upd_piece.PIECE_NAME#" maxlength="100" style="width:200px;" >
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_related_name_" <cfif get_upd_piece.piece_type eq 1 or get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 3>style="display:none"</cfif>>
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58221.Ürün Adı'>*</label>
                       	<div class="col col-7 col-xs-12">
                        	<div class="input-group">
                                <input type="text" name="related_product_name" id="related_product_name" value="<cfoutput>#get_upd_piece.PIECE_NAME#</cfoutput>" style="width:190px; vertical-align:top">
                                <input type="hidden" name="related_product_id" id="related_product_id" value="<cfoutput>#related_product_id#</cfoutput>">
                                <input type="hidden" name="related_stock_id" id="related_stock_id" value="<cfoutput>#get_upd_piece.PIECE_RELATED_ID#</cfoutput>"> 
                            	<span class="input-group-addon">
                                	<span class="icn-md icon-ellipsis" style="cursor:pointer" onclick="openProducts(2);" title="<cf_get_lang dictionary_id='44630.Ekle'>"></span>
                    			</span>
                    		</div>
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_color_" <cfif get_upd_piece.piece_type eq 4>style="display:none"</cfif>>
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='29765.Renk Düzenle'> <span id="piece_color__" style="font-weight:bold;<cfif get_upd_piece.piece_type eq 2>display:none</cfif>">*</span></label>
                       	<div class="col col-7 col-xs-12">
                        	<select name="color_type" id="color_type" style="width:130px;height:20px" onchange="set_thickness(this.value)">
                             	<option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                             	<cfoutput query="get_colors">
                                	<option value="#COLOR_ID#" <cfif  get_upd_piece.piece_color_id eq COLOR_ID>style="font-weight:bold" selected </cfif>>#COLOR_NAME#</option>
                             	</cfoutput>
                       		</select>
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_amount_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57635.Miktar'>*</label>
                       	<div class="col col-3 col-xs-12">
                        	<cfinput type="text" id="piece_amount" name="piece_amount" value="#TlFormat(get_upd_piece.piece_amount,4)#" maxlength="9" style="width:70px;text-align:right">
                     	</div>
                        <div class="col col-4 col-xs-12">
                        	<cfinput type="text" id="unit" name="unit" value="#get_upd_piece.main_unit#" maxlength="15">
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_kalinlik_" <cfif get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 4>style="display:none"</cfif>>
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='75.Kalınlık'> (mm.) <span id="piece_kalinlik__" style="font-weight:bold;<cfif get_upd_piece.piece_type eq 3>display:none</cfif>">*</span></label>
                       	<div class="col col-7 col-xs-12">
                        	<select name="piece_kalinlik" id="piece_kalinlik" style="width:70px;height:20px"  onchange="set_product(this.value)">
                             	<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                             	<cfif get_thickness.recordcount gt 0>
                                	<cfoutput query="get_thickness">
                                    	<option value="#THICKNESS_ID#" <cfif get_upd_piece.KALINLIK eq THICKNESS_ID>selected</cfif>>#THICKNESS_NAME#</option>
                               		</cfoutput>
                            	</cfif>
                         	</select>
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_boy_" <cfif get_upd_piece.piece_type eq 4>style="display:none"</cfif>>
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='99.Boy'> (mm.) <span id="piece_boy__" style="font-weight:bold;<cfif get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 3>display:none</cfif>">*</span></label>
                       	<div class="col col-3 col-xs-12">
                        	<cfinput type="text" name="piece_boy" id="piece_boy" value="#TlFormat(get_upd_piece.BOYU,1)#" onkeyup="return(FormatCurrency(this,event,1));" maxlength="7" style="width:70px;text-align:right">

                     	</div>
                        <cfif len(default_style)>
                            <div class="col col-2 col-xs-12">
                                <cfinput type="text" name="boy_fark" id="boy_fark" value="#TlFormat(get_upd_piece.BOY_FARKI,1)#" maxlength="4" style="text-align:right" onkeyup="return(FormatCurrency(this,event,1));">
                            </div>
                        </cfif>
                        <div class="col col-2 col-xs-12" id="kaba_piece_boy_" <cfif get_upd_piece.piece_type eq 3>style="display:none"</cfif>>
                        	<cfinput type="text" name="kaba_piece_boy" id="kaba_piece_boy" value="#TlFormat(get_upd_piece.kesim_boyu,1)#" readonly="yes" style="width:70px;text-align:right; font-weight:bold">
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_en_" <cfif get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 4>style="display:none"</cfif>>
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='98.En'> (mm.)<span id="piece_en__" style="font-weight:bold;<cfif get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 3>display:none</cfif>">*</span></label>
                       	<div class="col col-3 col-xs-12">
                        	<cfinput type="text" name="piece_en" id="piece_en" value="#TlFormat(get_upd_piece.ENI,1)#"onkeyup="return(FormatCurrency(this,event,1));"  maxlength="7" style="width:70px;text-align:right">
                     	</div>
                        <cfif len(default_style)>
                            <div class="col col-2 col-xs-12">
                                <cfinput type="text" name="en_fark" id="en_fark" value="#TlFormat(get_upd_piece.EN_FARKI,1)#" maxlength="4" style="text-align:right" onkeyup="return(FormatCurrency(this,event,1));">
                            </div>
                        </cfif>
                        <div class="col col-2 col-xs-12" id="kaba_piece_en_" <cfif get_upd_piece.piece_type eq 3>style="display:none"</cfif>>
                        	<cfinput type="text" name="kaba_piece_en" id="kaba_piece_en" value="#TlFormat(get_upd_piece.kesim_eni,1)#" readonly="yes" style="width:70px;text-align:right; font-weight:bold">
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_su_yonu_" <cfif get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 3 or get_upd_piece.piece_type eq 4>style="display:none"</cfif>>
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='901.Desen Boyuna'></label>
                       	<div class="col col-7 col-xs-12" style="height:30px; vertical-align:middle">
                            <input type="checkbox" name="piece_su_yonu" id="piece_su_yonu" value="1" style="height:30px" <cfif get_upd_piece.IS_FLOW_DIRECTION eq 1>checked</cfif> />
                     	</div>
                  	</div>
                    <cfif len(default_style)>
                        <div class="form-group" id="piece_style_">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='1287.Parça Stili'></label>
                            <div class="col col-7 col-xs-12" style="height:30px; vertical-align:middle">
                                <select name="piece_style" id="piece_style" style="width:70px;height:20px" onChange="style_change(this.value);">
                                    <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="get_style">
                                        <option value="#EZGI_PIECE_STYLE_ID#" <cfif get_upd_piece.PIECE_STYLE eq EZGI_PIECE_STYLE_ID>selected</cfif>>#EZGI_PIECE_STYLE_NAME#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </cfif>
                    <div class="form-group" id="piece_weight_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='29784.Ağırlık'> (kg.)</label>
                     	<div class="col col-4 col-xs-12">
                         	<cfinput type="text" name="auto_piece_weight" readonly="yes" id="auto_piece_weight" value="#Tlformat(total_weight,3)#" maxlength="7" style=" font-weight:bolder;text-align:right; background-color:gainsboro">
                      	</div>
                       	<div class="col col-3 col-xs-12">
                        	<cfinput type="text" id="piece_weight" name="piece_weight" value="#TlFormat(get_upd_piece.AGIRLIK,3)#" maxlength="6" style="text-align:right">
                     	</div>
                  	</div>
                 	<div class="form-group" id="piece_kod_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='844.Parça No'></label>
                       	<div class="col col-7 col-xs-12">
                        	<cfinput type="text" name="design_code_piece_row" id="design_code_piece_row" value="#get_upd_piece.PIECE_CODE#" maxlength="50" style="width:70px;" >
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_package_no_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='400.Paket No'></label>
                       	<div class="col col-7 col-xs-12">
                        	<select name="piece_package_no" id="piece_package_no" style="width:70px;height:20px; text-align:center" onchange="piece_floor_no()">
                         		<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                             	<cfif not is_montage_used.recordcount>
                               		<cfoutput query="get_design_package_row">
                                    	<option value="#PACKAGE_ROW_ID#" <cfif get_upd_piece.DESIGN_PACKAGE_ROW_ID eq PACKAGE_ROW_ID>selected</cfif>>#PACKAGE_NUMBER#</option>
                               		</cfoutput>
                             	</cfif>
                        	</select>
                     	</div>
                  	</div>
					
                    <cfif get_design.PROCESS_ID eq 1>
                        <div class="form-group" id="piece_package_floor_no_" style="<cfif get_upd_piece.DESIGN_PACKAGE_ROW_ID eq ''>display:none</cfif>">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='903.Paket Kat No'></label>
                            <div class="col col-7 col-xs-12">
                                <select name="piece_package_floor_no" id="piece_package_floor_no" style="width:70px;height:20px; text-align:center">
                                 	<option value=""  <cfif get_upd_piece.PIECE_FLOOR eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                  	<option value="1" <cfif get_upd_piece.PIECE_FLOOR eq 1>selected</cfif>>1</option>
                                  	<option value="2" <cfif get_upd_piece.PIECE_FLOOR eq 2>selected</cfif>>2</option>
                                  	<option value="3" <cfif get_upd_piece.PIECE_FLOOR eq 3>selected</cfif>>3</option>
                                  	<option value="4" <cfif get_upd_piece.PIECE_FLOOR eq 4>selected</cfif>>4</option>
                                 	<option value="5" <cfif get_upd_piece.PIECE_FLOOR eq 5>selected</cfif>>5</option>
                                  	<option value="6" <cfif get_upd_piece.PIECE_FLOOR eq 6>selected</cfif>>6</option>
                                 	<option value="7" <cfif get_upd_piece.PIECE_FLOOR eq 7>selected</cfif>>7</option>
                                	<option value="8" <cfif get_upd_piece.PIECE_FLOOR eq 8>selected</cfif>>8</option>
                                  	<option value="9" <cfif get_upd_piece.PIECE_FLOOR eq 9>selected</cfif>>9</option>
									<option value="10" <cfif get_upd_piece.PIECE_FLOOR eq 10>selected</cfif>>10</option>
                                   	<option value="11" <cfif get_upd_piece.PIECE_FLOOR eq 11>selected</cfif>>11</option>
                                  	<option value="12" <cfif get_upd_piece.PIECE_FLOOR eq 12>selected</cfif>>12</option>
                                  	<option value="13" <cfif get_upd_piece.PIECE_FLOOR eq 13>selected</cfif>>13</option>
                                  	<option value="14" <cfif get_upd_piece.PIECE_FLOOR eq 14>selected</cfif>>14</option>
                                 	<option value="15" <cfif get_upd_piece.PIECE_FLOOR eq 15>selected</cfif>>15</option>
                            	</select>
                            </div>
                        </div>
                        <div class="form-group" id="piece_package_rota_" style="<cfif get_upd_piece.DESIGN_PACKAGE_ROW_ID eq ''>display:none</cfif>">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='103.Paketleme Rotası'></label>
                            <div class="col col-7 col-xs-12">
                                <select name="piece_package_rota" id="piece_package_rota" style="width:70px;height:20px; text-align:center">
                                	<option value=""  <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq ''>selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                 	<option value="A" <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq 'A'>selected</cfif>>A</option>
                                  	<option value="B" <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq 'B'>selected</cfif>>B</option>
                                  	<option value="C" <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq 'C'>selected</cfif>>C</option>
                                   	<option value="D" <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq 'D'>selected</cfif>>D</option>
                                  	<option value="E" <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq 'E'>selected</cfif>>E</option>
                                  	<option value="F" <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq 'F'>selected</cfif>>F</option>
                                 	<option value="G" <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq 'G'>selected</cfif>>G</option>
                                 	<option value="H" <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq 'H'>selected</cfif>>H</option>
                                	<option value="I" <cfif get_upd_piece.PIECE_PACKAGE_ROTA eq 'I'>selected</cfif>>I</option>
                            	</select>
                            </div>
                        </div>
                   	</cfif> 
                    <div class="form-group" id="piece_price_" <cfif get_upd_piece.piece_type eq 1 or get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 3>style="display:none"</cfif>>
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='58778.Ürün Fiyatı'></label>
                       	<div class="col col-5 col-xs-12">
                        	<input type="text" name="product_price" id="product_price" value="<cfoutput>#TlFormat(get_upd_piece.PIECE_PRICE,4)#</cfoutput>" style="width:70px; height:20px; vertical-align:top; text-align:right">
                      	</div>
                        <div class="col col-2 col-xs-12">
                          	<select name="product_price_money" style="vertical-align:top;width:70px; height:20px">
                              	<cfoutput query="get_money">
                                	<option value="#money#" <cfif money eq get_upd_piece.PIECE_PRICE_MONEY>selected</cfif>>#money#</option>
                             	</cfoutput>
                         	</select>
                     	</div>
                  	</div>
                    <div class="form-group" id="piece_detail_">
                     	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id ='57629.Açıklama'></label>
                       	<div class="col col-7 col-xs-12">
                        	<textarea name="piece_detail" id="piece_detail" style="width:200px; height:50px"><cfoutput>#get_upd_piece.PIECE_DETAIL#</cfoutput></textarea>
                     	</div>
                  	</div>
               	</div>
                <div class="col col-6 col-md-6 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                   	<div class="col col-11 col-xs-12" id="yonga_levha_" style="<cfif get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 3 or get_upd_piece.piece_type eq 4>display:none</cfif>">
                      	<cfsavecontent variable="yonga"><cf_get_lang dictionary_id ='62.Yonga Levha'></cfsavecontent>
						<cf_seperator title="#yonga#" id="_yonga_levha" is_closed="1">
                     	<div class="form-group" id="_yonga_levha">
                         	<select name="piece_yonga_levha" id="piece_yonga_levha" style="width:290px;height:20px">
                             	<cfoutput query="get_yonga_levha">
                                 	<option value="#STOCK_ID#" <cfif get_upd_piece.MATERIAL_ID eq STOCK_ID>selected</cfif>>#PRODUCT_NAME#</option>
                              	</cfoutput>
                         	</select>
                     	</div>
                   	</div>   
                  	<div class="col col-11 col-xs-12" id="yari_mamul_" style="<cfif get_upd_piece.piece_type eq 1 or get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 4>display:none</cfif>">
                        <cfsavecontent variable="yari_mamul"><cf_get_lang dictionary_id ='78.Montaj Edilecek Yarımamüller'></cfsavecontent>
						<cf_seperator title="#yari_mamul#" id="_yari_mamul" is_closed="1">
                       	<cf_form_list id="_yari_mamul">
                            <thead>
                             	<tr>
                                	<th style="width:20px; height:20px">
                                        <cfinput type="hidden" name="record_num_yrm" id="record_num_yrm" value="#get_yari_mamul.recordcount#">
                                        <a href="javascript:add_row_yrm();"><img src="/images/plus_list.gif"  border="0"></a>
                                    </th>
                                    <th width="100%" nowrap="nowrap"><cf_get_lang dictionary_id='57452.Stok'></th>
                                    <th width="60px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            	</tr>
                         	</thead>
                        	<tbody name="new_row_yrm" id="new_row_yrm">
                             	<cfif get_yari_mamul.recordcount>
                                 	<cfoutput query="get_yari_mamul">
                                     	<tr name="frm_row_yrm" id="frm_row_yrm#currentrow#">
                                        	<td>
                                             	<a style="cursor:pointer" onclick="sil_yrm(#currentrow#);">
                                                	<img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0">
                                              	</a>
                                              	<input type="hidden" name="row_kontrol_yrm#currentrow#" id="row_kontrol_yrm#currentrow#" value="1">
                                         	</td>
                                         	<td nowrap="nowrap">
                                            	<select name="piece_yari_mamul#currentrow#" id="piece_yari_mamul#currentrow#" style="width:100%;height:30px;border-style:none" >

                                                	<cfif get_montage_product.recordcount>
                                                        <cfloop query="get_montage_product">
                                                            <option value="#PIECE_ROW_ID#" <cfif get_yari_mamul.RELATED_PIECE_ROW_ID eq PIECE_ROW_ID>selected</cfif>>#PIECE_NAME#</option>
                                                        </cfloop>
                                                    </cfif>
                                             	</select>
                                         	</td>
                                          	<td>
                                            	<input type="text" name="quantity_yrm#currentrow#" id="quantity_yrm#currentrow#" value="#TlFormat(get_yari_mamul.amount,4)#" onkeyup="isNumber(this);" style="width:60px; height:25px; text-align:right; border-style:none">
                                         	</td>
                                    	</tr>
									</cfoutput>
                          		</cfif>
                          	</tbody>
                        </cf_form_list>
                    </div>  
                    <div class="col col-11 col-xs-12" id="kenar_" style="<cfif get_upd_piece.piece_type eq 2 or get_upd_piece.piece_type eq 4>display:none</cfif>">
                        <cfsavecontent variable="kenar"><cf_get_lang dictionary_id ='79.Kenar Bantları'></cfsavecontent>
						<cf_seperator title="#kenar#" id="_kenar" is_closed="1">
                       	<cf_flat_list id="_kenar">
                            <tbody style="width:100%;" cellpadding="0" cellspacing="0" border="0">
                                 <tr>
                                    <td style="width:35px; height:25px;text-align:center">
                                        <img src="/images/production/ust.gif" onClick="pvc_search(1);" title="<cf_get_lang dictionary_id='860.Üst Arka'>" style="text-align:center; vertical-align:middle;width:25px; height:20px; cursor:pointer" />
                                    </td>
                                    <td style="text-align:left; height:30px; width:20%; display:none" id="td1_pvc_search_1">
                                    	<cfinput type="text" name="search_1" id="search_1" value="" maxlength="10" style="width:100%; height:23px; border-color:azure" onKeyup="pvc_search_value(1);">
                                        <cfinput type="hidden" id="keyw_1" name="keyw_1" value="0">
                                    </td>
                                    <td colspan="2" style="text-align:left; width:100%" id="td2_pvc_search_1">
                                    	<div class="form-group">
                                            <select name="pvc_materials_1" id="pvc_materials_1" style="width:100%;height:30px;<cfif pvc_1 eq 0>display:none</cfif>">
                                                <cfoutput query="get_pvc">
                                                    <option value="#STOCK_ID#" <cfif S_TYPE eq 0>style="font-weight:bold"</cfif> <cfif pvc_1 eq STOCK_ID>selected</cfif>>#PRODUCT_NAME#</option>
                                                </cfoutput>
                                            </select>
                                        </div>
                                    </td>
                                    <td style="width:25px; text-align:center">
                                        <cfif pvc_1 gt 0>
                                            <a style="cursor:pointer" onclick="change_image(1);">
                                                <img src="images/production/true.png" style="width:15px; height:15px" title="<cf_get_lang dictionary_id='83.Seçildi'>" id="true_false_1">
                                            </a>
                                            <cfinput type="hidden" id="anahtar_1" name="anahtar_1" value="1">
                                        <cfelse>
                                            <a style="cursor:pointer" onclick="change_image(1);">
                                                <img src="images/production/false.png" style="width:15px; height:15px" title="<cf_get_lang dictionary_id='84.Seçilmedi'>" id="true_false_1">
                                            </a>
                                            <cfinput type="hidden" id="anahtar_1" name="anahtar_1" value="0">
                                        </cfif>
                                        
                                    </td>
                                    <td style="width:25px; text-align:center">
										<cfif get_main_defaults.DEFAULT_TRIM_TYPE eq 3>
                                            <input type="checkbox" name="pvc_select_1" value="1" <cfif get_upd_piece.EDGE_TRIM_1 gt 0>checked</cfif> />
                                        </cfif>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width:35px; height:25px;text-align:center">
                                        <img src="/images/production/alt.gif" title="<cf_get_lang dictionary_id='859.Alt Ön'>" onClick="pvc_search(2);" style="text-align:center; vertical-align:middle;width:25px; height:20px; cursor:pointer" />
                                    </td>
                                    <td style="text-align:left; height:30px; width:20%; display:none" id="td1_pvc_search_2">
                                    	<cfinput type="text" name="search_2" id="search_2" value="" maxlength="10" style="width:100%; height:23px; border-color:azure" onKeyUp="pvc_search_value(2);">
                                        <cfinput type="hidden" id="keyw_2" name="keyw_2" value="0">
                                    </td>
                                    <td colspan="2" style="text-align:left; width:100%" id="td2_pvc_search_2">
                                    	<div class="form-group">
                                            <select name="pvc_materials_2" id="pvc_materials_2" style="width:100%;height:30px;<cfif pvc_2 eq 0>display:none</cfif>">
                                                <cfoutput query="get_pvc">
                                                    <option value="#STOCK_ID#" <cfif S_TYPE eq 0>style="font-weight:bold"</cfif> <cfif pvc_2 eq STOCK_ID>selected</cfif>>#PRODUCT_NAME#</option>
                                                </cfoutput>
                                            </select>
                                        </div>
                                    </td>
                                    <td style="text-align:center">
                                        <cfif pvc_2 gt 0>
                                            <a style="cursor:pointer" onclick="change_image(2);">
                                                <img src="images/production/true.png" style="width:15px; height:15px" title="<cf_get_lang dictionary_id='83.Seçildi'>" id="true_false_2">
                                            </a>
                                            <cfinput type="hidden" id="anahtar_2" name="anahtar_2" value="1">
                                        <cfelse>
                                            <a style="cursor:pointer" onclick="change_image(2);">
                                                <img src="images/production/false.png" style="width:15px; height:15px" title="<cf_get_lang dictionary_id='84.Seçilmedi'>" id="true_false_2">
                                            </a>
                                            <cfinput type="hidden" id="anahtar_2" name="anahtar_2" value="0">
                                        </cfif>
                                    </td>
                                    <td style="width:25px; text-align:center">
										<cfif get_main_defaults.DEFAULT_TRIM_TYPE eq 3>
                                            <input type="checkbox" name="pvc_select_2" value="1" <cfif get_upd_piece.EDGE_TRIM_2 gt 0>checked</cfif> />
                                        </cfif>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width:35px; height:25px;text-align:center">
                                        <img src="/images/production/sol_yan.gif" title="<cf_get_lang dictionary_id='858.Sağ Üst'>" onClick="pvc_search(3);" style="text-align:center; vertical-align:middle;width:25px; height:20px; cursor:pointer" />
                                    </td>
                                    <td style="text-align:left; height:30px; width:20%; display:none" id="td1_pvc_search_3">
                                    	<cfinput type="text" name="search_3" id="search_3" value="" maxlength="10" style="width:100%; height:23px; border-color:azure" onKeyUp="pvc_search_value(3);">
                                        <cfinput type="hidden" id="keyw_3" name="keyw_3" value="0">
                                    </td>
                                    <td colspan="2" style="text-align:left; width:100%" id="td2_pvc_search_3">
                                    	<div class="form-group">
                                            <select name="pvc_materials_3" id="pvc_materials_3" style="width:100%;height:30px;<cfif pvc_3 eq 0>display:none</cfif>">
                                                <cfoutput query="get_pvc">
                                                    <option value="#STOCK_ID#" <cfif S_TYPE eq 0>style="font-weight:bold"</cfif> <cfif pvc_3 eq STOCK_ID>selected</cfif>>#PRODUCT_NAME#</option>
                                                </cfoutput>
                                            </select>
                                        </div>
                                    </td>
                                    <td style="text-align:center">
                                        <cfif pvc_3 gt 0>
                                            <a style="cursor:pointer" onclick="change_image(3);">
                                                <img src="images/production/true.png" style="width:15px; height:15px" title="<cf_get_lang dictionary_id='83.Seçildi'>" id="true_false_3">
                                            </a>
                                            <cfinput type="hidden" id="anahtar_3" name="anahtar_3" value="1">
                                        <cfelse>
                                            <a style="cursor:pointer" onclick="change_image(3);">
                                                <img src="images/production/false.png" style="width:15px; height:15px" title="<cf_get_lang dictionary_id='84.Seçilmedi'>" id="true_false_3">
                                            </a>
                                            <cfinput type="hidden" id="anahtar_3" name="anahtar_3" value="0">
                                        </cfif>
                                    </td>
                                    <td style="width:25px; text-align:center">
										<cfif get_main_defaults.DEFAULT_TRIM_TYPE eq 3>
                                            <input type="checkbox" name="pvc_select_3" value="1" <cfif get_upd_piece.EDGE_TRIM_3 gt 0>checked</cfif> />
                                        </cfif>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width:35px; height:25px;text-align:center">
                                        <img src="/images/production/sag_yan.gif" title="<cf_get_lang dictionary_id='857.Sol Alt'>" onClick="pvc_search(4);" style="text-align:center; vertical-align:middle;width:25px; height:20px; cursor:pointer" />
                                    </td>
                                    <td style="text-align:left; height:30px; width:20%; display:none" id="td1_pvc_search_4">
                                    	<cfinput type="text" name="search_4" id="search_4" value="" maxlength="10" style="width:100%; height:23px; border-color:azure" onKeyUp="pvc_search_value(4);">
                                        <cfinput type="hidden" id="keyw_4" name="keyw_4" value="0">
                                    </td>
                                    <td colspan="2" style="text-align:left; width:100%" id="td2_pvc_search_4">
                                    	<div class="form-group">
                                            <select name="pvc_materials_4" id="pvc_materials_4" style="width:100%;height:30px;<cfif pvc_4 eq 0>display:none</cfif>">
                                                <cfoutput query="get_pvc">
                                                    <option value="#STOCK_ID#" <cfif S_TYPE eq 0>style="font-weight:bold"</cfif> <cfif pvc_4 eq STOCK_ID>selected</cfif>>#PRODUCT_NAME#</option>
                                                </cfoutput>
                                            </select>
                                        </div>
                                    </td>
                                    <td style="text-align:center">
                                        <cfif pvc_4 gt 0>
                                            <a style="cursor:pointer" onclick="change_image(4);">
                                                <img src="images/production/true.png" style="width:15px; height:15px" title="<cf_get_lang dictionary_id='83.Seçildi'>" id="true_false_4">
                                            </a>
                                            <cfinput type="hidden" id="anahtar_4" name="anahtar_4" value="1">
                                        <cfelse>
                                            <a style="cursor:pointer" onclick="change_image(4);">
                                                <img src="images/production/false.png" style="width:15px; height:15px" title="<cf_get_lang dictionary_id='84.Seçilmedi'>" id="true_false_4">
                                            </a>
                                            <cfinput type="hidden" id="anahtar_4" name="anahtar_4" value="0">
                                        </cfif>
                                    </td>
                                    <td style="width:25px; text-align:center">
										<cfif get_main_defaults.DEFAULT_TRIM_TYPE eq 3>
                                            <input type="checkbox" name="pvc_select_4" value="1" <cfif get_upd_piece.EDGE_TRIM_4 gt 0>checked</cfif> />
                                        </cfif>
                                    </td>
                                </tr>
                                <cfif get_main_defaults.DEFAULT_TRIM_TYPE eq 1 or get_main_defaults.DEFAULT_TRIM_TYPE eq 2>
                                	<tr id="trim_rate_" <cfif get_upd_piece.piece_type neq 1>style="display:none"</cfif>>
                                        <td colspan="3" nowrap="nowrap" style="text-align:left; vertical-align:middle; height:30px">
                                        	<div class="form-group">
                                                <select name="trim_type" id="trim_type" style="width:100%;height:30px;" onchange="change_trim_type_(this.value);">
                                                	<cfif get_main_defaults.DEFAULT_TRIM_TYPE eq 1>
                                                    	<option value="0" <cfif get_upd_piece.trim_type eq 0>selected</cfif>><cf_get_lang dictionary_id='89.Tıraşlama Yok'></option>
                                                    </cfif>
                                                    <option value="1" <cfif get_upd_piece.trim_type eq 1>selected</cfif>><cf_get_lang dictionary_id='856.Sabit Tıraşlama'></option>
                                                </select>
                                            </div>
                                        </td>
                                        <td colspan="2" style="text-align:right; vertical-align:middle;">
                                         	<span id="trim_rate_display_" style="<cfif get_upd_piece.trim_type eq 0>display:none</cfif>">
                                           		<cfinput name="trim_rate" id="trim_rate" value="#TlFormat(get_upd_piece.trim_size,1)#"  style="text-align:right; width:45px; height:25px; vertical-align:middle; border-style:none">
                                        	</span> 
                                        </td>
                                    </tr>
                                <cfelseif get_main_defaults.DEFAULT_TRIM_TYPE eq 0>
                                    <cfinput type="hidden" name="trim_rate" id="trim_rate" value="0">
                                    <cfinput type="hidden" name="trim_type" id="trim_type" value="0">
                                <cfelseif get_main_defaults.DEFAULT_TRIM_TYPE eq 3>
                                    <cfinput type="hidden" name="trim_rate" id="trim_rate" value="#TlFormat(attributes.trim_rate,1)#">
                                    <cfinput type="hidden" name="trim_type" id="trim_type" value="1">
                                 </cfif>
                                 <cfif get_main_defaults.DEFAULT_PIECE_CANALIZING eq 1>
                                 	<tr id="canalize_type_">
                                        <td colspan="5" nowrap="nowrap" style="text-align:left; vertical-align:middle; height:30px">
											<div class="form-group">
												<select name="canalize_type" id="canalize_type" style="width:100%;height:30px" class="form-group">
													<option value="0" <cfif get_upd_piece.CANALIZING_TYPE eq 0 or not len(get_upd_piece.CANALIZING_TYPE)>selected</cfif>><cf_get_lang dictionary_id='1294.Kanal Açma Yok'></option>
													<option value="1" <cfif get_upd_piece.CANALIZING_TYPE eq 1>selected</cfif>><cf_get_lang dictionary_id='1295.Tek Taraflı Kanal Açma'> (<cf_get_lang dictionary_id ='99.Boy'>)</option>
													<option value="2" <cfif get_upd_piece.CANALIZING_TYPE eq 2>selected</cfif>><cf_get_lang dictionary_id='1296.İki Taraflı Kanal Açma'> (<cf_get_lang dictionary_id ='99.Boy'>)</option>
													<option value="3" <cfif get_upd_piece.CANALIZING_TYPE eq 3>selected</cfif>><cf_get_lang dictionary_id='1295.Tek Taraflı Kanal Açma'> (<cf_get_lang dictionary_id ='98.En'>)</option>
													<option value="4" <cfif get_upd_piece.CANALIZING_TYPE eq 4>selected</cfif>><cf_get_lang dictionary_id='1296.İki Taraflı Kanal Açma'> (<cf_get_lang dictionary_id ='98.En'>)</option>
												</select>
											</div>
                                        </td>
                                      </tr>
                                 </cfif>
                            </tbody>
                        </cf_flat_list>
                    </div>
                    <div class="col col-11 col-xs-12" id="aksesuar_" style="<cfif get_upd_piece.piece_type eq 4>display:none</cfif>">
                        <cfsavecontent variable="aksesuar"><cf_get_lang dictionary_id ='91.Aksesuarlar'></cfsavecontent>
						<cf_seperator title="#aksesuar#" id="_aksesuar" is_closed="1">
                       	<cf_form_list id="_aksesuar">
                        	<thead>
                                <tr>
                                    <th width="20px" style="text-align:center">
                                        <input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_aksesuar.recordcount#</cfoutput>">
                                        <a href="javascript:openProducts(1);"><img src="/images/plus_list.gif"  border="0"></a>
                                    </th>
                                    <cfif x_barcode_control eq 1>
                                    	<th width="60px"><cf_get_lang dictionary_id='57633.Barkod'></th>
                                    </cfif>
                                    <th width="100%" nowrap="nowrap"><cf_get_lang dictionary_id='57452.Stok'></th>
                                    <th width="60px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                    <th width="30px"><a href="javascript:CopyProducts();"><img src="/images/copy_list.gif"  border="0"></a><!---<cf_get_lang dictionary_id="57636.Birim">---></th>
                                    <cfif get_design_main_row.MAIN_PROTOTIP_TYPE eq 4 or get_design_main_row.MAIN_PROTOTIP_TYPE eq 1>
                                    	<th style="text-align:center"></th>
                                 	</cfif>
                                </tr>
                            </thead>
                            <tbody name="new_row" id="new_row">
                              	<cfif get_aksesuar.recordcount>
                                 	<cfoutput query="get_aksesuar">
                                    	<input type="hidden" name="aks_ezgi_piece_row_row_id#currentrow#" id="aks_ezgi_piece_row_row_id#currentrow#" value="#EZGI_PIECE_ROW_ROW_ID#">
                                      	<tr name="frm_row" id="frm_row#currentrow#">
                                         	<td style="text-align:center">
                                             	<a style="cursor:pointer" onclick="sil(#currentrow#);">
                                                  	<img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0">
                                               	</a>
                                                <input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                        	</td>
                                            <cfif x_barcode_control eq 1>
                                                <td style="text-align:center">
                                                    <input type="text" name="barcode#currentrow#" id="barcode#currentrow#" value="#get_aksesuar.barcod#" style="width:59px; border-style:none">
                                                </td>
                                            </cfif>
                                       		<td nowrap="nowrap">
                                            	<input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#get_aksesuar.product_id#">
                                              	<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#get_aksesuar.stock_id#">
                                              	<input type="text" name="product_name#currentrow#" id="product_name#currentrow#" value="#get_aksesuar.product_name#" style="width:98%; height:25px; border-style:none">
                                        	</td>
                                         	<td><input type="text" name="quantity#currentrow#" id="quantity#currentrow#" value="#TlFormat(get_aksesuar.amount,4)#" style="width:60px;height:25px; text-align:right; border-style:none"></td>
                                            <td><input type="text" id="unit#currentrow#" name="unit#currentrow#" value="#get_aksesuar.MAIN_UNIT#" style="width:30px;height:25px; text-align:left;; border-style:none"></td>
                                            <cfif get_design_main_row.MAIN_PROTOTIP_TYPE eq 4 or get_design_main_row.MAIN_PROTOTIP_TYPE eq 1>
                                            	<td style="text-align:center; width:25px">
                                                	<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_row_prototip&design_piece_row_id=#attributes.design_piece_row_id#&ezgi_piece_row_row_id=#get_aksesuar.EZGI_PIECE_ROW_ROW_ID#','small');">
														<cfif PIECE_QUESTION_ID gt 0>
                                                            <img src="images/cube_vote_red.gif"  title="<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> " border="0" style="vertical-align:middle">
                                                        <cfelse>
                                                            <img src="images/cube_vote_yellow.gif"  title="<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> " border="0" style="vertical-align:middle">
                                                        </cfif>
                                                    </a>
                                                </td>
                                            </cfif>
                                     	</tr>
                                	</cfoutput>
                            	</cfif>
                         	</tbody>
                        </cf_form_list>
                    </div>
                    <div class="col col-11 col-xs-12" id="hizmet_" style="<cfif get_upd_piece.piece_type neq 1>display:none</cfif>">
                        <cfsavecontent variable="hizmet"><cf_get_lang dictionary_id ='92.Hizmet Giderleri'></cfsavecontent>
						<cf_seperator title="#hizmet#" id="_hizmet" is_closed="1">
                       	<cf_form_list id="_hizmet">
                            <thead>
                             	<tr>
                                	<th width="20px">
                                     	<input type="hidden" name="record_num_hzm" id="record_num_hzm" value="<cfoutput>#get_hzm.recordcount#</cfoutput>">
                                      	<a href="javascript:add_row_hzm();"><img src="/images/plus_list.gif"  border="0"></a>
                                  	</th>
                                 	<th width="100%" nowrap="nowrap"><cf_get_lang dictionary_id ='33678.Hizmet Tipleri'></th>
                                	<th width="60px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                             	</tr>
                         	</thead>
                          	<tbody name="new_row_hzm" id="new_row_hzm">
                            	<cfif get_hzm.recordcount>
                                	<cfoutput query="get_hzm">
                                    	<input type="hidden" name="hzm_ezgi_piece_row_row_id#currentrow#" id="hzm_ezgi_piece_row_row_id#currentrow#" value="#EZGI_PIECE_ROW_ROW_ID#">
                                     	<tr name="frm_row_hzm" id="frm_row_hzm#currentrow#">
                                         	<td>
                                            	<a style="cursor:pointer" onclick="sil_hzm(#currentrow#);">
                                                 	<img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0">
                                             	</a>
                                             	<input type="hidden" name="row_kontrol_hzm#currentrow#" id="row_kontrol_hzm#currentrow#" value="1">
                                         	</td>
                                         	<td nowrap="nowrap">
                                             	<input type="hidden" name="pid_hzm#currentrow#" id="pid_hzm#currentrow#" value="#get_hzm.product_id#">
                                            	<input type="hidden" name="stock_id_hzm#currentrow#" id="stock_id_hzm#currentrow#" value="#get_hzm.stock_id#">
                                               	<input type="text" name="urun_hzm#currentrow#" id="urun_hzm#currentrow#" value="#get_hzm.product_name#" style="width:95%; height:25px; border-style:none">
                                             	<a href="javascript://" onclick="pencere_ac_hzm(#currentrow#);"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
                                        	</td>
                                        	<td>
                                            	<input type="text" name="quantity_hzm#currentrow#" id="quantity_hzm#currentrow#" value="#TlFormat(get_hzm.amount,4)#"  style="width:60px; height:25px; text-align:right;border-style:none">
                                           	</td>
                                    	</tr>
                             		</cfoutput>
                           		</cfif>
                 			</tbody>
                        </cf_form_list>
                    </div>
                    
                    
            	</div>
          	</cf_box_elements>
            <cf_box_footer>
            	<div class="col col-12">
                	<div class="form-group" style="text-align:right">
						<cfif get_ortak_piece.RECORDCOUNT>
                            <input type="checkbox" name="is_name_change" value="1"> Ortak Parçaların İsmleri de Güncellensin
                        </cfif>
                	</div>
                </div>
                <div class="col col-12">
                	<div class="col col-8">
                     	<cf_record_info 
                            query_name="get_upd_piece"
                            record_emp="RECORD_EMP" 
                            record_date="record_date"
                            update_emp="UPDATE_EMP"
                            update_date="update_date">
                   	</div>
                	<div class="col col-4">
						<cfif not is_montage_used.recordcount>
                            <cf_workcube_buttons 
                                    is_upd='1' 
                                    delete_page_url='#request.self#?fuseaction=prod.emptypopup_del_ezgi_product_tree_creative_piece_row&design_piece_row_id=#attributes.design_piece_row_id#'
                                    add_function='kontrol()'>
                        <cfelse>
                            <cf_workcube_buttons 
                                        is_upd='1' 
                                        is_delete = '0' 
                                        delete_page_url='#request.self#?fuseaction=prod.emptypopup_del_ezgi_product_tree_creative_piece_row&design_piece_row_id=#attributes.design_piece_row_id#'
                                        add_function='kontrol()'>
                        </cfif>
                    </div>
                </div>
            </cf_box_footer>
       	</cfform> 
        <cf_box_elements>
        	<div class="col col-12">
        		<cfif isdefined('attributes.erp_link')>
                	<br />
                    <div id="related_" style="width:100%; height:20px">
                    	<cf_form_list id="_related_">
                         	<tbody>
                              	<tr height="25px"  id="piece_related_">
                                  	<td width="100%">
                                    <a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.list_ezgi_product_tree_creative&event=upd&piece_type_select=&sort_id=5&design_id=#get_related_design.DESIGN_ID#&design_main_row_id=#get_related_design.DESIGN_MAIN_ROW_ID#&design_package_row_id=#get_related_design.DESIGN_PACKAGE_ROW_ID#&design_piece_row_id=#get_related_design.PIECE_ROW_ID#</cfoutput>','longpage');">
                                    	<span style="font-size:12px">
                                    		<cfoutput> #get_related_design.DESIGN_MAIN_NAME# - #get_related_design.PACKAGE_NAME#</cfoutput>
                                        </span>
                                    </a>
                               		</td>
                            	</tr>
                         	</tbody>
                    	</cf_form_list>
                    </div>
             	</cfif>
             	<cfif len(get_design_piece_image.PATH)>
                	<br />
                  	<div id="image_" style="width:100%; <cfif get_upd_piece.piece_type eq 4>display:none</cfif>">
						<cfsavecontent variable="resim">
							<cf_get_lang dictionary_id='58080.Resim'>
						</cfsavecontent>	
                    	<cf_seperator title="#resim#" id="_image" is_closed="1">
                   		<cf_form_list id="_image">
                         	<tbody>
                           		<tr height="25px"  id="image_">
                                 	<cfoutput>
                                     	<td valign="top">
                                         	<img src="/documents/product/#get_design_piece_image.PATH#" style="height:600px; width:900px; vertical-align:middle">
                                     	</td>
                                	</cfoutput>

                           		</tr>
                          	</tbody>
                     	</cf_form_list>
                 	</div>
              	</cfif>
          	</div>
      	</cf_box_elements>
    </cf_box>
</cf_box>
<script type="text/javascript">
	var row_count=document.upd_piece_main_row.record_num.value;
	var row_count_hzm=document.upd_piece_main_row.record_num_hzm.value;
	var row_count_yrm=document.upd_piece_main_row.record_num_yrm.value;
	function copy_piece_row(piece_row_id)
	{
		copy_confirm = confirm('<cf_get_lang dictionary_id='104.Kopyalama İşlemine Başlıyorum'> !');
		if(copy_confirm == true)
		window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_cpy_ezgi_product_tree_creative_piece_row&this_tree=1&design_piece_row_id="+piece_row_id;	
	}
	function piece_types()
	{
		if(document.getElementById('piece_type').value == 1)
		{
			document.getElementById('piece_default_type_').style.display = "";
			document.getElementById('piece_color_').style.display = "";
			document.getElementById('piece_kalinlik_').style.display = "";
			document.getElementById('piece_boy_').style.display = "";
			document.getElementById('piece_en_').style.display = "";
			document.getElementById('piece_su_yonu_').style.display = "";
			document.getElementById('piece_related_name_').style.display = "none";
			document.getElementById('piece_price_').style.display = "none";
			document.getElementById('piece_name_').style.display = "";
			document.getElementById('yonga_levha_').style.display = "";
			document.getElementById('yari_mamul_').style.display = "none";
			document.getElementById('kenar_').style.display = "";
			document.getElementById('trim_rate_').style.display = "";
			document.getElementById('aksesuar_').style.display = "";
			document.getElementById('hizmet_').style.display = "";
			document.getElementById('piece_color__').style.display = "";
			document.getElementById('piece_boy__').style.display = "";
			document.getElementById('piece_en__').style.display = "";
			document.getElementById('piece_kalinlik__').style.display = "";
			document.getElementById('kaba_piece_boy_').style.display = "";
			document.getElementById('kaba_piece_en_').style.display = "";
			document.getElementById('piece_style_').style.display = "";
		}
		else if(document.getElementById('piece_type').value == 2)
		{
			document.getElementById('piece_default_type_').style.display = "";
			document.getElementById('piece_color_').style.display = "";
			document.getElementById('piece_kalinlik_').style.display = "none";
			document.getElementById('piece_boy_').style.display = "";
			document.getElementById('piece_en_').style.display = "none";
			document.getElementById('piece_su_yonu_').style.display = "none";
			document.getElementById('piece_related_name_').style.display = "none";
			document.getElementById('piece_price_').style.display = "none";
			document.getElementById('piece_name_').style.display = "";
			document.getElementById('yonga_levha_').style.display = "none";
			document.getElementById('yari_mamul_').style.display = "none";
			document.getElementById('kenar_').style.display = "none";
			document.getElementById('aksesuar_').style.display = "";
			document.getElementById('hizmet_').style.display = "none";
			document.getElementById('piece_boy__').style.display = "none";
			document.getElementById('piece_color__').style.display = "none";
			document.getElementById('piece_style_').style.display = "none";
		}
		else if(document.getElementById('piece_type').value == 3)
		{
			document.getElementById('piece_default_type_').style.display = "";
			document.getElementById('piece_color_').style.display = "";
			document.getElementById('piece_kalinlik_').style.display = "";
			document.getElementById('piece_boy_').style.display = "";
			document.getElementById('piece_en_').style.display = "";
			document.getElementById('piece_su_yonu_').style.display = "none";
			document.getElementById('piece_related_name_').style.display = "none";
			document.getElementById('piece_price_').style.display = "none";
			document.getElementById('piece_name_').style.display = "";
			document.getElementById('yonga_levha_').style.display = "none";
			document.getElementById('yari_mamul_').style.display = "";
			document.getElementById('kenar_').style.display = "";
			document.getElementById('trim_rate_').style.display = "none";
			document.getElementById('aksesuar_').style.display = "";
			document.getElementById('hizmet_').style.display = "none";
			document.getElementById('piece_color__').style.display = "";
			document.getElementById('piece_boy__').style.display = "none";
			document.getElementById('piece_en__').style.display = "none";
			document.getElementById('piece_kalinlik__').style.display = "none";
			document.getElementById('kaba_piece_boy_').style.display = "none";
			document.getElementById('kaba_piece_en_').style.display = "none";
			document.getElementById('piece_style_').style.display = "";

			document.getElementById('piece_kalinlik').selectedIndex=0;
			for(var kk=1;kk<=4;kk++)
			{
				document.getElementById("true_false_"+kk).src="images/production/false.png";
				document.getElementById("anahtar_"+kk).value = 0;
				document.getElementById("pvc_materials_"+kk).style.display="none";
			}
		}
		else if(document.getElementById('piece_type').value == 4)
		{
			document.getElementById('piece_default_type_').style.display = "none";
			document.getElementById('piece_color_').style.display = "none";
			document.getElementById('piece_kalinlik_').style.display = "none";
			document.getElementById('piece_boy_').style.display = "none";
			document.getElementById('piece_en_').style.display = "none";
			document.getElementById('piece_su_yonu_').style.display = "none";
			document.getElementById('piece_related_name_').style.display = "";
			document.getElementById('piece_price_').style.display = "";
			document.getElementById('piece_name_').style.display = "none";
			document.getElementById('yonga_levha_').style.display = "none";
			document.getElementById('yari_mamul_').style.display = "none";
			document.getElementById('kenar_').style.display = "none";
			document.getElementById('aksesuar_').style.display = "none";
			document.getElementById('hizmet_').style.display = "none";
			document.getElementById('piece_style_').style.display = "none";
		}
	}
	function piece_floor_no()
	{
		<cfif get_design.PROCESS_ID eq 1>
		if(document.getElementById('piece_package_no').value == '')
		{
			document.getElementById('piece_package_floor_no_').style.display = "none";
			document.getElementById('piece_package_rota_').style.display = "none";
			document.getElementById('piece_package_floor_no').value = '';
			document.getElementById('piece_package_rota').value = '';
		}
		else
		{
			document.getElementById('piece_package_floor_no_').style.display = "";
			document.getElementById('piece_package_rota_').style.display = "";
		}
		</cfif>
	}
	function hesapla()
	{
		var main_row_name = <cfoutput>'#main_setup_name#'</cfoutput>;
		
		if(document.getElementById('default_type').value > 0)
		{
			/*var piece_default_name = 
			wrk_query("SELECT PIECE_DEFAULT_ID, PIECE_DEFAULT_NAME FROM EZGI_DESIGN_PIECE_DEFAULTS WHERE PIECE_DEFAULT_ID = "+document.getElementById('default_type').value,"dsn3");*/
			
			var listParam = document.getElementById('default_type').value;
			var piece_default_name = wrk_safe_query('get_piece_default_name_default_id_ezgi','dsn3',0,listParam)
			
			if(piece_default_name.recordcount != 0)
			{
				main_row_name = main_row_name +' '+ piece_default_name.PIECE_DEFAULT_NAME;
				if(document.getElementById('piece_type').value == 3)
					main_row_name = main_row_name +' M';
			}
		}
		document.getElementById('design_name_piece_row').value = main_row_name;
	}
	function set_thickness(color_id_)
	{
		default_thickness = <cfoutput>#attributes.default_thickness#</cfoutput>;
		/*var thickness_names = 
		wrk_query("SELECT THICKNESS_ID, THICKNESS_VALUE, THICKNESS_NAME, UNIT FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EP WHERE LIST_ORDER_NO = 1 AND COLOR_ID = "+color_id_+"ORDER BY THICKNESS_NAME","dsn3");*/

		var listParam = 1+ "*" + color_id_;
		var thickness_names = wrk_safe_query('get_thickness_color_id_ezgi','dsn3',0,listParam)
		
		var option_count = document.getElementById('piece_kalinlik').options.length; 
		for(x=option_count;x>=0;x--)
			document.getElementById('piece_kalinlik').options[x] = null;
		if(thickness_names.recordcount != 0)
		{	
			document.getElementById('piece_kalinlik').options[0] = new Option('Seçiniz','');
			for(var xx=0;xx<thickness_names.recordcount;xx++)
			{
				document.getElementById('piece_kalinlik').options[xx+1]=new Option(thickness_names.THICKNESS_NAME[xx],thickness_names.THICKNESS_ID[xx],thickness_names.UNIT[xx]);
				if(thickness_names.THICKNESS_ID[xx] == default_thickness)
				{
					document.getElementById('piece_kalinlik').selectedIndex=xx+1;
				}
			}
		}
		else
			document.getElementById('piece_kalinlik').options[0] = new Option('Seçiniz','');
		thickness_=document.getElementById('piece_kalinlik').value;
		set_product(thickness_);
		set_pvc(thickness_);
	}
	function set_product(thickness_)
	{
		default_thickness = <cfoutput>#attributes.default_thickness#</cfoutput>;
		if(document.getElementById('color_type').value >0 && thickness_ >0)
		{
			/*var product_names = 
			wrk_query("SELECT THICKNESS_ID, UNIT, STOCK_ID, PRODUCT_NAME FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EP WHERE LIST_ORDER_NO = 1 AND COLOR_ID = "+document.getElementById('color_type').value+" AND THICKNESS_ID ="+thickness_,"dsn3");*/
			
			var listParam = 1+ "*" + document.getElementById('color_type').value + "*" + thickness_;
			var product_names = wrk_safe_query('get_thickness_color_id_thickness_id_ezgi','dsn3',0,listParam)
		}
		else if(document.getElementById('color_type').value >0 && thickness_ <=0)
		{
			/*var product_names = 
			wrk_query("SELECT THICKNESS_ID, UNIT, STOCK_ID, PRODUCT_NAME FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EP WHERE LIST_ORDER_NO = 1 AND COLOR_ID = "+document.getElementById('color_type').value,"dsn3");*/
			
			var listParam = document.getElementById('color_type').value;
			var product_names = wrk_safe_query('get_thickness_color_id_ezgi','dsn3',0,listParam)
		}
		var option_count = document.getElementById('piece_yonga_levha').options.length; 
		for(x=option_count;x>=0;x--)
			document.getElementById('piece_yonga_levha').options[x] = null;
		if(product_names.recordcount != 0)
		{	
			document.getElementById('piece_yonga_levha').options[0] = new Option('Seçiniz','');
			for(var xx=0;xx<product_names.recordcount;xx++)
				document.getElementById('piece_yonga_levha').options[xx+1]=new Option(product_names.PRODUCT_NAME[xx],product_names.STOCK_ID[xx],product_names.UNIT[xx],product_names.THICKNESS_ID[xx]);
				if(product_names.THICKNESS_ID[xx] == default_thickness)
				{
					document.getElementById('piece_yonga_levha').selectedIndex=xx+1;
				}
		}
		else
		{
			document.getElementById('piece_yonga_levha').options[0] = new Option('Kayıt Yok','');	
		}
		set_pvc(thickness_);
	}
	
	function set_pvc(thickness_)
	{
		if(document.getElementById('color_type').value >0 && thickness_ >0)
		{
			/*var pvc_name = 
			wrk_query("SELECT THICKNESS_ID, UNIT, STOCK_ID, PRODUCT_NAME FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EP WHERE LIST_ORDER_NO = 3 AND COLOR_ID = "+document.getElementById('color_type').value+" AND THICKNESS_ID ="+thickness_,"dsn3");*/
			
			listParam = 3 + "*" + document.getElementById('color_type').value + "*" + thickness_;
			var pvc_name = wrk_safe_query('get_thickness_color_id_thickness_id_ezgi','dsn3',0,listParam)
		}
		else if(document.getElementById('color_type').value >0 && thickness_ <=0)
		{
			/*var pvc_name = 
			wrk_query("SELECT THICKNESS_ID, UNIT, STOCK_ID, PRODUCT_NAME FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EP WHERE LIST_ORDER_NO = 3","dsn3");*/
			
			listParam = 3 ;
			var pvc_name = wrk_safe_query('get_thickness_ezgi','dsn3',0,listParam)
		}
		for (i = 1; i <= 4; i++)
		{
			var option_count_pvc = document.getElementById('pvc_materials_'+i).options.length; 
			for(x=option_count_pvc;x>=0;x--)
				document.getElementById('pvc_materials_'+i).options[x] = null;
			if(pvc_name.recordcount != 0)
			{	
				document.getElementById('pvc_materials_'+i).options[0] = new Option('Seçiniz','');
				for(var xx=0;xx<pvc_name.recordcount;xx++)
				{
					document.getElementById('pvc_materials_'+i).options[xx+1]=new Option(pvc_name.PRODUCT_NAME[xx],pvc_name.STOCK_ID[xx],pvc_name.UNIT[xx],pvc_name.THICKNESS_ID[xx]);
					document.getElementById('pvc_materials_'+i).selectedIndex=xx+1;
				}
			}
			else
			{
				if(document.getElementById('piece_type').value != 3)
				{
					document.getElementById('pvc_materials_'+i).options[0] = new Option('Kayıt Yok','');	
					document.getElementById("true_false_"+i).src="images/production/false.png";
					document.getElementById("anahtar_"+i).value = 0;
					document.getElementById("pvc_materials_"+i).style.display="none";
				}
			}
		}
	}
	
	function change_image(kenar_id)
	{
		if(document.getElementById("anahtar_"+kenar_id).value == 0)
		{
			document.getElementById("true_false_"+kenar_id).src="images/production/true.png";
			document.getElementById("anahtar_"+kenar_id).value = 1;
			document.getElementById("pvc_materials_"+kenar_id).style.display="";
			if(document.getElementById("piece_type").value == 3 && (kenar_id == 1 || kenar_id == 2))
				document.getElementById('piece_boy__').style.display = "";
			if(document.getElementById("piece_type").value == 3 && (kenar_id == 3 || kenar_id == 4))
				document.getElementById('piece_en__').style.display = "";
		}
		else
		{
			document.getElementById("true_false_"+kenar_id).src="images/production/false.png";
			document.getElementById("anahtar_"+kenar_id).value = 0;
			document.getElementById("pvc_materials_"+kenar_id).style.display="none";
			if(document.getElementById("piece_type").value == 3 && kenar_id == 1)
			{
				if(document.getElementById("anahtar_2").value == 0)
				document.getElementById('piece_boy__').style.display = "none";
			}
			if(document.getElementById("piece_type").value == 3 && kenar_id == 2)
			{
				if(document.getElementById("anahtar_1").value == 0)
				document.getElementById('piece_boy__').style.display = "none";
			}
			if(document.getElementById("piece_type").value == 3 && kenar_id == 3)
			{
				if(document.getElementById("anahtar_4").value == 0)
				document.getElementById('piece_en__').style.display = "none";
			}
			if(document.getElementById("piece_type").value == 3 && kenar_id == 4)
			{
				if(document.getElementById("anahtar_3").value == 0)
				document.getElementById('piece_en__').style.display = "none";
			}
		}
	}
	function change_trim_type_(trim_type)
	{
		if(trim_type == 1)
		document.getElementById("trim_rate_display_").style.display="";
		else
		document.getElementById("trim_rate_display_").style.display="none";
	}
	function CopyProducts()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_piece_row_calc&design_piece_row_id=#attributes.design_piece_row_id#'</cfoutput>,'small');
	}
	function openProducts(type)
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_ezgi_stocks&ezgi_secim_type='+type+'&price_cat=-2&list_order_no=3,4&add_product_cost=1&module_name=product&var_=#var_#&is_action=1&startdate=&price_lists='</cfoutput>,'page');
	}
	function add_row(stockid,stockprop,sirano,product_id,product_name,manufact_code,tax,tax_purchase,add_unit,product_unit_id,money,is_serial_no,discount1,discount2,discount3,discount4,spect_main_id,amount,barcod)
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.className = 'color-row';
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.upd_piece_main_row.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>';
		<cfif x_barcode_control eq 1>
			newCell=newRow.insertCell(newRow.cells.length);
			newCell.innerHTML = '<input type="text" id="barcode' + row_count +'" name="barcode' + row_count +'" value="'+barcod+'" style="width:59px; text-align:right;border-style:none">';
		</cfif>
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="Hidden" name="stock_id'+row_count+'" value="' + stockid + '">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="product_id'+row_count+'" value="'+product_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="unit_id'+row_count+'" value="'+product_unit_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="product_name' + row_count + '" style="width:98%;height:25px;border-style:none" value="'+product_name+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="'+commaSplit(amount,4)+'" style="width:60px;height:25px; text-align:right;border-style:none">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="unit' + row_count +'" name="unit' + row_count +'" value="'+add_unit+'" style="width:30px;height:25px; text-align:left;border-style:none">';
		
		<cfif get_design_main_row.MAIN_PROTOTIP_TYPE eq 4>
			newCell=newRow.insertCell(newRow.cells.length);
			newCell.innerHTML =''
		</cfif>
	}
	
	function sil(sy)
	{
	
		var element=eval("upd_piece_main_row.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";		
	} 
	
	function add_row_hzm()
	{
		row_count_hzm++;
		var newRow_hzm;
		var newCell_hzm;
		newRow_hzm = document.getElementById("new_row_hzm").insertRow(document.getElementById("new_row_hzm").rows.length);
		newRow_hzm.setAttribute("name","frm_row_hzm" + row_count_hzm);
		newRow_hzm.setAttribute("id","frm_row_hzm" + row_count_hzm);
		newRow_hzm.setAttribute("NAME","frm_row_hzm" + row_count_hzm);
		newRow_hzm.setAttribute("ID","frm_row_hzm" + row_count_hzm);
		
		document.upd_piece_main_row.record_num_hzm.value = row_count_hzm;
		
		newCell_hzm = newRow_hzm.insertCell(newRow_hzm.cells.length);
		newCell_hzm.innerHTML = '<a style="cursor:pointer" onclick="sil_hzm(' + row_count_hzm + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='51.Sil'>" border="0"></a>';	
			
		newCell_hzm=newRow_hzm.insertCell(newRow_hzm.cells.length);
		newCell_hzm.setAttribute('nowrap','nowrap');
		newCell_hzm.innerHTML = '<input type="hidden" value="1" id="row_kontrol_hzm' + row_count_hzm +'" name="row_kontrol_hzm' + row_count_hzm +'"><input type="text" name="urun_hzm' + row_count_hzm +'" id="urun_hzm'+ row_count_hzm +'" style="width:94%; height:25px;border-style:none"><input type="hidden" name="pid_hzm' + row_count_hzm +'" id="pid_hzm'+ row_count_hzm +'"><input type="hidden" name="stock_id_hzm' + row_count_hzm +'" id="stock_id_hzm' + row_count_hzm +'">&nbsp;&nbsp;<a style="cursor:pointer" href"javascript://" onClick="pencere_ac_hzm('+ row_count_hzm +');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>';
		
		newCell_hzm=newRow_hzm.insertCell(newRow_hzm.cells.length);
		newCell_hzm.innerHTML = '<input type="text" id="quantity_hzm' + row_count_hzm +'" name="quantity_hzm' + row_count_hzm +'" value="<cfoutput>#TlFormat(1,4)#</cfoutput>" style="width:60px; height:25px; text-align:right;border-style:none">';
	}
	function pencere_ac_hzm(no_hzm)
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=5&product_id=upd_piece_main_row.pid_hzm" + no_hzm +"&field_id=upd_piece_main_row.stock_id_hzm" + no_hzm +"&field_name=upd_piece_main_row.urun_hzm" + no_hzm,'list');
	}
	function sil_hzm(sy_hzm)
	{
		
		var element_hzm=eval("upd_piece_main_row.row_kontrol_hzm"+sy_hzm);
		element_hzm.value=0;
		var element_hzm=eval("frm_row_hzm"+sy_hzm);
		element_hzm.style.display="none";		
	} 
	
	function add_row_yrm()
	{
		row_count_yrm++;
		var newRow_yrm;
		var newCell_yrm;
		newRow_yrm = document.getElementById("new_row_yrm").insertRow(document.getElementById("new_row_yrm").rows.length);
		newRow_yrm.setAttribute("name","frm_row_yrm" + row_count_yrm);
		newRow_yrm.setAttribute("id","frm_row_yrm" + row_count_yrm);
		newRow_yrm.setAttribute("NAME","frm_row_yrm" + row_count_yrm);
		newRow_yrm.setAttribute("ID","frm_row_yrm" + row_count_yrm);
		
		document.upd_piece_main_row.record_num_yrm.value = row_count_yrm;
		
		newCell_yrm = newRow_yrm.insertCell(newRow_yrm.cells.length);
		newCell_yrm.innerHTML = '<a style="cursor:pointer" onclick="sil_yrm(' + row_count_yrm + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>';	
			
		newCell_yrm=newRow_yrm.insertCell(newRow_yrm.cells.length);
		newCell_yrm.setAttribute('nowrap','nowrap');
		newCell_yrm.innerHTML = '<select name="piece_yari_mamul'+row_count_yrm+'" id="piece_yari_mamul'+row_count_yrm+'" style="width:100%;height:30px;border-style:none" class="form-group"><cfif get_montage_product.recordcount><cfoutput query="get_montage_product"><option value="#PIECE_ROW_ID#" >#PIECE_NAME#</option></cfoutput></cfif></select><input type="hidden" value="1" id="row_kontrol_yrm' + row_count_yrm +'" name="row_kontrol_yrm' + row_count_yrm +'">';
		
		newCell_yrm=newRow_yrm.insertCell(newRow_yrm.cells.length);
		newCell_yrm.innerHTML = '<input type="text" id="quantity_yrm' + row_count_yrm +'" name="quantity_yrm' + row_count_yrm +'" value="<cfoutput>#TlFormat(1,4)#</cfoutput>" style="width:60px;height:25px; text-align:right; border-style:none" class="form-group">';
	}
	function pencere_ac_yrm(no_yrm)
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=5&product_id=upd_piece_main_row.pid_yrm" + no_yrm +"&field_id=upd_piece_main_row.stock_id_yrm" + no_yrm +"&field_name=upd_piece_main_row.urun_yrm" + no_yrm,'list');
	}
	function sil_yrm(sy_yrm)
	{
	
		var element_yrm=eval("upd_piece_main_row.row_kontrol_yrm"+sy_yrm);
		element_yrm.value=0;
		var element_yrm=eval("frm_row_yrm"+sy_yrm); 
		element_yrm.style.display="none";		
	} 
	function add_piece_images()
	{
		<cfif get_design_piece_image.recordcount>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.form_upd_ezgi_popup_image&id=#attributes.design_piece_row_id#&type=brand&detail=#get_upd_piece.PIECE_NAME#&table=EZGI_DESIGN_PIECE_IMAGES</cfoutput>','small');
		<cfelse>
			windowopen('<cfoutput>#request.self#?fuseaction=prod.form_add_ezgi_popup_image&id=#attributes.design_piece_row_id#&type=brand&detail=#get_upd_piece.PIECE_NAME#&table=EZGI_DESIGN_PIECE_IMAGES</cfoutput>','small');
		</cfif>
	}
	function kontrol()
	{
		<cfif get_ortak_piece.recordcount>
			ortak_sor=confirm('Güncelleme İşlemi Tüm Ortak Parçalara Uygulanacaktır?');
			if (ortak_sor == true)
				return true;
			else
				return false;
		</cfif>
		if(document.getElementById("piece_amount").value <=0)
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='57635.Miktar'> !");
			document.getElementById('piece_amount').focus();
			return false;
		}
		if(document.getElementById("piece_type").value == 1 || document.getElementById("piece_type").value == 2 || document.getElementById("piece_type").value == 3)
		{
			if(document.getElementById("default_type").value == "")
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='832.Örnek Parça'> !");
				document.getElementById('default_type').focus();
				return false;
			}
			if(document.getElementById("design_name_piece_row").value == "" || document.getElementById("design_name_piece_row").value <=0)
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='399.Parça Adı'>!");
				document.getElementById('design_name_piece_row').focus();
				return false;
			}
			if(document.getElementById("record_num").value > 0)

			{
				sayi = document.getElementById("record_num").value;
				for (i = 1; i <= sayi; i++)
				{
					if(document.getElementById("quantity"+i).value <=0 && document.getElementById("row_kontrol"+i).value == 1)
					{
						alert(i+'. <cf_get_lang dictionary_id='93.Satırdaki Aksesuarın Miktarı Sıfırdan Büyük Olmalıdır'> !');
						document.getElementById("quantity"+i).focus();
						return false;
					}
					if(document.getElementById("stock_id"+i).value <=0 && document.getElementById("row_kontrol"+i).value == 1)
					{
						alert(i+'. <cf_get_lang dictionary_id='183.Satırdaki Aksesuar Seçilmemiştir'> !');
						document.getElementById("urun"+i).focus();
						return false;
					}
				}
			}
			if(document.getElementById("record_num_hzm").value > 0)
			{
				sayi = document.getElementById("record_num_hzm").value;
				for (i = 1; i <= sayi; i++)
				{
					if(document.getElementById("quantity_hzm"+i).value <=0 && document.getElementById("row_kontrol_hzm"+i).value == 1)
					{
						alert(i+'. <cf_get_lang dictionary_id='184.Satırdaki Hizmet Giderinin Miktarı Sıfırdan Büyük Olmalıdır'> !');
						document.getElementById("quantity_hzm"+i).focus();
						return false;
					}
					if(document.getElementById("stock_id_hzm"+i).value <=0 && document.getElementById("row_kontrol_hzm"+i).value == 1)
					{
						alert(i+'. <cf_get_lang dictionary_id='185.Satırdaki Hizmet Gideri Seçilmemiştir'> !');
						document.getElementById("urun_hzm"+i).focus();
						return false;
					}
				}
			}
		}
		if(document.getElementById("piece_type").value == 1 || document.getElementById("piece_type").value == 3)
		{
			if(document.getElementById("color_type").value == 0)
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='29765.Renk Düzenle'> !");
				document.getElementById('color_type').focus();
				return false;
			}
			if(document.getElementById("anahtar_1").value == 1 && document.getElementById("pvc_materials_1").value <=0)
			{
				alert("<cf_get_lang dictionary_id='94.1.Sırada PVC Seçildiğinde Mutlaka Satır Seçilmelidir'> !");
				document.getElementById('pvc_materials_1').focus();

				return false;
			}
			if(document.getElementById("anahtar_2").value == 1 && document.getElementById("pvc_materials_2").value <=0)
			{
				alert("<cf_get_lang dictionary_id='95.2.Sırada PVC Seçildiğinde Mutlaka Satır Seçilmelidir'> !");
				document.getElementById('pvc_materials_2').focus();
				return false;
			}
			if(document.getElementById("anahtar_3").value == 1 && document.getElementById("pvc_materials_3").value <=0)
			{
				alert("<cf_get_lang dictionary_id='96.3.Sırada PVC Seçildiğinde Mutlaka Satır Seçilmelidir'> !");
				document.getElementById('pvc_materials_3').focus();
				return false;
			}
			if(document.getElementById("anahtar_4").value == 1 && document.getElementById("pvc_materials_4").value <=0)
			{
				alert("<cf_get_lang dictionary_id='97.4.Sırada PVC Seçildiğinde Mutlaka Satır Seçilmelidir'> !");
				document.getElementById('pvc_materials_4').focus();
				return false;
			}
			if(document.getElementById("anahtar_1").value == 1 || document.getElementById("anahtar_2").value == 1)
			{
				if(document.getElementById("piece_boy").value == '0,0' || document.getElementById("piece_boy").value <= 0 || document.getElementById("piece_boy").value == '')
				{
					alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='99.Boy'> !");
					document.getElementById('piece_boy').focus();
					return false;
				}
			}
			if (document.getElementById("anahtar_3").value == 1 || document.getElementById("anahtar_4").value == 1)
			{
				if(document.getElementById("piece_en").value == '0,0' || document.getElementById("piece_en").value <= 0 || document.getElementById("piece_en").value == '')
				{
					alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='98.En'> !");
					document.getElementById('piece_en').focus();
					return false;
				}
			}
		}
		if(document.getElementById("piece_type").value == 1)
		{
			if(document.getElementById("piece_boy").value <= 0)
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='99.Boy'> !");
				document.getElementById('piece_boy').focus();
				return false;
			}
			if(document.getElementById("piece_en").value <= 0)
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='98.En'> !");
				document.getElementById('piece_en').focus();
				return false;
			}
			if(document.getElementById("piece_kalinlik").value <= 0)
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='75.Kalınlık'> !");
				document.getElementById('piece_kalinlik').focus();
				return false;
			}
			if(document.getElementById("piece_yonga_levha").value <= 0)
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='62.Yonga Levha'> !");
				document.getElementById('piece_yonga_levha').focus();
				return false;
			}
			
		}
		if(document.getElementById("piece_type").value == 4)
		{
			if(document.getElementById("related_product_name").value <= 0)
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id ='399.Parça Adı'>!");
				document.getElementById('related_product_name').focus();
				return false;
			}
		}
		if(document.getElementById("piece_type").value == 3)
		{
			if(document.getElementById('piece_package_no').value <= 0)
			{
			 	alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='400.Paket No'> !");
				document.getElementById("piece_package_no").focus();
				return false;
			}
			else
			{
				if(document.getElementById("record_num_yrm").value > 0)
				{
					sayi = document.getElementById("record_num_yrm").value;
					control_double_id = '';
					for (i = 1; i <= sayi; i++)
					{
						if(document.getElementById("quantity_yrm"+i).value <=0 && document.getElementById("row_kontrol_yrm"+i).value == 1)
						{
							alert(i+'. <cf_get_lang dictionary_id='186.Satırdaki Montaj Edilecek Ürünün Miktarı Sıfırdan Büyük Olmalıdır'> !');
							document.getElementById("quantity_yrm"+i).focus();
							return false;
						}
						if(document.getElementById("piece_yari_mamul"+i).value <=0 && document.getElementById("row_kontrol_yrm"+i).value == 1)
						{
							alert(i+'. <cf_get_lang dictionary_id='187.Satırdaki Montaj Edilecek Ürün Seçilmemiştir'>!');
							document.getElementById("piece_yari_mamul"+i).focus();
							return false;
						}
					}
				}
			}
		}
	}
	function style_change(style_id)
	{
		<cfif get_style.recordcount>
			<cfoutput query="get_style">
				ezgi_style_id = #EZGI_PIECE_STYLE_ID#;
				boy_fark = #BOY_FARK#;
				en_fark = #EN_FARK#;
				if(ezgi_style_id==style_id)
				{
					document.getElementById('boy_fark').value = boy_fark;
					document.getElementById('en_fark').value = en_fark;
				}
			</cfoutput>
		</cfif>
	}
	function add_ezgi_row(stockid,stockprop,sirano,product_id,product_name,manufact_code,tax,tax_purchase,add_unit,product_unit_id,money,is_serial_no,discount1,discount2,discount3,discount4,spect_main_id,amount)
	{
		document.getElementById('related_product_id').value = product_id;
		document.getElementById('related_stock_id').value = stockid;
		document.getElementById('related_product_name').value = product_name;
		document.getElementById('unit').value = add_unit;
		document.getElementById('piece_amount').value = commaSplit(parseFloat(amount),4);
	}
	function options_info()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_product_tree_creative_piece_options_info&piece_row_id=#attributes.design_piece_row_id#</cfoutput>','small');	
	}
	function pvc_search(srch)
	{
		if(document.getElementById('keyw_'+srch).value==1)
		{
			td_close();
		}
		else
		{
			td_close();
			document.getElementById('td2_pvc_search_'+srch).colSpan = "1";
			document.getElementById('td2_pvc_search_'+srch).style.width="79%";
			document.getElementById('td1_pvc_search_'+srch).style.display="";
			document.getElementById('keyw_'+srch).value = 1;
			srch_up = srch-1;
			if(srch>1 && (document.getElementById('search_'+srch_up).value != '' || document.getElementById('search_'+srch_up).value != ' '))
			{
				document.getElementById('search_'+srch).value = document.getElementById('search_'+srch_up).value;
				pvc_search_value(srch);
			}
		}
	}
	function pvc_search_value(srch_value)
	{
		keyw=document.getElementById('search_'+srch_value).value;
		if(keyw !='' && document.getElementById('piece_kalinlik').value >0)
		{
			if(keyw =='?')
			{
				/*var pvc_name = 
			wrk_query("SELECT THICKNESS_ID, UNIT, STOCK_ID, PRODUCT_NAME FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EP WHERE LIST_ORDER_NO = 3 AND THICKNESS_ID ="+document.getElementById('piece_kalinlik').value+" ORDER BY PRODUCT_NAME","dsn3");*/
				
				listParam = 3 + "*" + document.getElementById('piece_kalinlik').value;
				var pvc_name = wrk_safe_query('get_thickness_color_id_thickness_id_ezgi','dsn3',0,listParam)
			}
			else
			{
				/*var pvc_name = 
			wrk_query("SELECT THICKNESS_ID, UNIT, STOCK_ID, PRODUCT_NAME FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EP WHERE LIST_ORDER_NO = 3 AND PRODUCT_NAME LIKE '%"+keyw+"%' AND THICKNESS_ID ="+document.getElementById('piece_kalinlik').value+" ORDER BY PRODUCT_NAME","dsn3");*/
			
				listParam = 3 + "*" + keyw + "*" + document.getElementById('piece_kalinlik').value;
				var pvc_name = wrk_safe_query('get_thickness_product_name_thickness_id_ezgi','dsn3',0,listParam)
			}
		}
		else if(keyw !='' && document.getElementById('piece_kalinlik').value <=0)
		{
			/*var pvc_name = 
			wrk_query("SELECT THICKNESS_ID, UNIT, STOCK_ID, PRODUCT_NAME FROM EZGI_DESIGN_PRODUCT_PROPERTIES_UST AS EP WHERE LIST_ORDER_NO = 3 AND PRODUCT_NAME LIKE '%"+keyw+"%' ORDER BY PRODUCT_NAME","dsn3");*/
			
			listParam = 3 + "*" + keyw;
			var pvc_name = wrk_safe_query('get_thickness_product_name_ezgi','dsn3',0,listParam)
		}
		i=srch_value;
		var option_count_pvc = document.getElementById('pvc_materials_'+i).options.length; 
		for(x=option_count_pvc;x>=0;x--)
			document.getElementById('pvc_materials_'+i).options[x] = null;
		if(pvc_name.recordcount != 0)
		{	
			document.getElementById('pvc_materials_'+i).options[0] = new Option('Seçiniz','');
			for(var xx=0;xx<pvc_name.recordcount;xx++)
			{
				document.getElementById('pvc_materials_'+i).options[xx+1]=new Option(pvc_name.PRODUCT_NAME[xx],pvc_name.STOCK_ID[xx],pvc_name.UNIT[xx],pvc_name.THICKNESS_ID[xx]);
					document.getElementById('pvc_materials_'+i).selectedIndex=xx+1;
			}
		}
		else
		{
			if(document.getElementById('piece_type').value != 3)
			{
				document.getElementById('pvc_materials_'+i).options[0] = new Option('Kayıt Yok','');	
				document.getElementById("true_false_"+i).src="images/production/false.png";
				document.getElementById("anahtar_"+i).value = 0;
					document.getElementById("pvc_materials_"+i).style.display="none";
			}
		}
	}
	function td_close()
	{
		for (i = 1; i <= 4; i++)
		{
			document.getElementById('td2_pvc_search_'+i).colSpan = "2";
			document.getElementById('td2_pvc_search_'+i).style.width="100%";
			document.getElementById('td1_pvc_search_'+i).style.display="none";
			document.getElementById('keyw_'+i).value = 0;	
		}
	}

</script>