<!---
    File: add_ezgi_private_product_tree_creative_main_row.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 

<cfscript>
   // getComponent = createObject('component','v16.objects.cfc.upgrade_notes');
    //get_release_version = getComponent.GET_RELEASE_VERSION();
	release_date = dateformat(dateadd('d',-360,now()),'yyyy-mm-dd H:m:s');
    new_release_date = dateformat(Now(),'yyyy-mm-dd H:m:s');
</cfscript>
<style>.fa-angle-down{cursor:pointer;}.activeTr{background:#f5f5f5;}.flagTrue{color:green;}.flagFalse{color:red;}.flagWarning{color:orange;}</style>
<link rel="stylesheet" href="/css/assets/template/codemirror/codemirror.css">
<script type="text/javascript" src="/JS/codemirror/codemirror.js"></script>
<script type="text/javascript" src="/JS/codemirror/simplescrollbars.js"></script>
<script type="text/javascript" src="/JS/codemirror/sql.js"></script>
<cfif len(attributes.SELECT_PRODUCTION)>
	<!---<cftransaction>--->
    
	<cfquery name="ADD_MAIN_INFO" datasource="#DSN3#">
    	INSERT INTO 
        	EZGI_DESIGN_MAIN_ROW
      	(
        	DESIGN_ID,
        	OFFER_ROW_ID,
            WRK_ROW_RELATION_ID,  
            DESIGN_MAIN_NAME, 
            DESIGN_MAIN_COLOR_ID, 
            MAIN_ROW_SETUP_ID, 
            DESIGN_MAIN_RELATED_ID, 
            OLCU1, 
            OLCU2,  
            DESIGN_MAIN_CODE,
            KARMA_KOLI_MIKTAR,
            MAIN_PROTOTIP_ID,
            MAIN_PROTOTIP_TYPE
       	)
    	SELECT  
        	#attributes.DESIGN_ID#,      
        	ORR.OFFER_ROW_ID, 
            ORR.WRK_ROW_ID, 
            E.DESIGN_MAIN_NAME, 
            E.DESIGN_MAIN_COLOR_ID, 
            E.MAIN_ROW_SETUP_ID, 
            E.DESIGN_MAIN_RELATED_ID, 
            E.OLCU1, 
            E.OLCU2, 
            E.DESIGN_MAIN_CODE, 
         	ORR.QUANTITY,
            E.DESIGN_MAIN_ROW_ID,
            ISNULL(E.MAIN_PROTOTIP_TYPE,0) MAIN_PROTOTIP_TYPE
		FROM            
        	OFFER_ROW AS ORR WITH (NOLOCK) INNER JOIN
        	EZGI_DESIGN_MAIN_ROW AS E WITH (NOLOCK) ON ORR.STOCK_ID = E.DESIGN_MAIN_RELATED_ID
		WHERE        
        	ORR.OFFER_ROW_ID IN (#attributes.SELECT_PRODUCTION#) AND 
            E.OFFER_ROW_ID IS NULL
    </cfquery>
    <cfquery name="get_main_info" datasource="#dsn3#">
    	SELECT * FROM EZGI_DESIGN_MAIN_ROW WITH (NOLOCK) WHERE OFFER_ROW_ID IN (#attributes.SELECT_PRODUCTION#)
    </cfquery>
    <br>
    <div class="row" type="row">
        <div id="listTable" class="col col-12 mt-3">
            <div class="col col-12 release_info">
                <div class="before-release col col-12">
                    <div class="col col-12 col-md-12 col-xs-12 pl-0 pr-0">
                        <div class="col col-12 release_info">
                            <div class="before-release col col-12">
                                <div class="col-md-12 mt-3">
                                    <p><i class="fa fa-2x fa-bookmark-o"></i> : <cf_get_lang dictionary_id = "52128.Çalıştırmaya hazır"></p> 
                                    <p><i class="fa fa-2x fa-bookmark flagTrue"></i> : <cf_get_lang dictionary_id = "52131.Başarılı bir şekilde çalıştırıldı"></p> 
                                    <p><i class="fa fa-2x fa-bookmark flagWarning"></i> : <cf_get_lang dictionary_id = "40137.Çalışıyor"></p> 
                                    <p><i class="fa fa-2x fa-bookmark flagFalse"></i> : <cf_get_lang dictionary_id = "52151.Çalıştırılamadı"></p>
                                </div>
                            </div>
                        </div>
                        <div class="col col-12 col-md-12 mt-3">
                            <table class="workDevList">
                                <thead>
                                    <tr>
                                        <th><cf_get_lang dictionary_id='58577.Sıra'></th>
                                        <th><cf_get_lang dictionary_id='58530.Aktarım Türü'></th>
                                        <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody>
                                	<cfif get_main_info.recordcount>
                                    	<cfoutput query="get_main_info">
                                        	<tr>
                                                <td style="text-align:right;" nowrap="nowrap">#currentrow#&nbsp;</td>
                                                <td style="text-align:left;" nowrap="nowrap">&nbsp;
                                                 	<cfif MAIN_PROTOTIP_TYPE eq 0><cf_get_lang dictionary_id='58156.Diğer'></cfif>
                                                   	<cfif MAIN_PROTOTIP_TYPE eq 1><cf_get_lang dictionary_id='802.Kapı'></cfif>
                                                   	<cfif MAIN_PROTOTIP_TYPE eq 2><cf_get_lang dictionary_id='803.Mutfak'></cfif>
                                                  	<cfif MAIN_PROTOTIP_TYPE eq 3><cf_get_lang dictionary_id='58937.Transfer İşlemi'></cfif>
                                                </td>
                                                
                                                <td style="text-align:left;" nowrap="nowrap">&nbsp;#DESIGN_MAIN_NAME#</td>
												<td><i id="line_#DESIGN_MAIN_ROW_ID#" class="fa fa-2x fa-bookmark-o"></i></td>
                                           	</tr> 
                                       	</cfoutput>
                                   	</cfif>	
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>                
        </div>
    </div>
    <cfquery  name="get_design_defults" datasource="#dsn3#">
    	SELECT DEFAULT_TRIM_AMOUNT, DEFAULT_TRIM_TYPE, DEFAULT_MAIN_OPERATION_TYPE_ID, DEFAULT_PACKAGE_OPERATION_TYPE_ID FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
    </cfquery>
    <cfset attributes.piece_trim_type = 1>
    <cfset attributes.trim_type = get_design_defults.DEFAULT_TRIM_TYPE>
 	<cfset attributes.trim_rate = TlFormat(get_design_defults.DEFAULT_TRIM_AMOUNT,1)>
    <cfset attributes.package_piece_select = 1>
    <cfset attributes.main = 1>
    <cfset attributes.collect_add = 1>
    <cfloop query="get_main_info">
    	<cfquery name="add_main_rota" datasource="#dsn3#">
        	INSERT INTO 
            	EZGI_DESIGN_PIECE_ROTA
             	(
                	OPERATION_TYPE_ID, 
                    SIRA, 
                    AMOUNT, 
                    MAIN_ROW_ID
              	)
			SELECT     
            	OPERATION_TYPE_ID, 
                SIRA, 
                AMOUNT, 
                #get_main_info.DESIGN_MAIN_ROW_ID#
			FROM        
            	EZGI_DESIGN_PIECE_ROTA
			WHERE     
            	(
                	MAIN_ROW_ID =
                      			(
                                	SELECT     
                                    	MAIN_PROTOTIP_ID
                       				FROM        
                                    	EZGI_DESIGN_MAIN_ROW
                       				WHERE     
                                    	DESIGN_MAIN_ROW_ID = #get_main_info.DESIGN_MAIN_ROW_ID#
                               	)
              	)
        </cfquery>
    	<cfset hata_id = 0>	
    	<script type="text/javascript">
			tr_line = <cfoutput>#DESIGN_MAIN_ROW_ID#</cfoutput>;
			document.getElementById('line_'+tr_line).className = "fa fa-2x fa-bookmark flagWarning";
		</script>
    	<cfif get_main_info.MAIN_PROTOTIP_TYPE eq 0 or get_main_info.MAIN_PROTOTIP_TYPE eq 1> <!---Aktarım Tipi Diğer Standart Ürünler ve Kapı ise--->
			<cfset attributes.DESIGN_MAIN_ROW_ID = get_main_info.DESIGN_MAIN_ROW_ID>
            <cfset attributes.sid = get_main_info.MAIN_PROTOTIP_ID>
            <cfquery name="get_package_content" datasource="#dsn3#">
                SELECT
                    DISTINCT
                    EDP.PIECE_ROW_ID,        
                    EDP.PIECE_TYPE,
                    EDP.PACKAGE_IS_MASTER,	
                    EDP.PACKAGE_PARTNER_ID
                FROM            
                    EZGI_DESIGN_PIECE AS EDP WITH (NOLOCK)
                WHERE 
                    EDP.DESIGN_MAIN_ROW_ID = #attributes.sid# AND
                    EDP.PIECE_TYPE IN (1,2,3,4) AND
                    EDP.PIECE_STATUS = 1
                ORDER BY
                    EDP.PIECE_TYPE
            </cfquery>
            <cfset attributes.PIECE_ROW_ID_LIST = ValueList(get_package_content.PIECE_ROW_ID)>
            <cfloop query="get_package_content">
                <cfset 'PIECE_TYPE_#PIECE_ROW_ID#' = PIECE_TYPE>
                <cfset 'attributes.a_#PIECE_ROW_ID#' = 1>
                <cfif PIECE_TYPE eq 3>
                    <cfquery name="get_sub_pieces" datasource="#dsn3#">
                        SELECT RELATED_PIECE_ROW_ID FROM EZGI_DESIGN_PIECE_ROW WITH (NOLOCK) WHERE PIECE_ROW_ID = #PIECE_ROW_ID# AND RELATED_PIECE_ROW_ID IS NOT NULL
                    </cfquery>
                    <cfset 'PIECE_SUB_ID_#PIECE_ROW_ID#' = ValueList(get_sub_pieces.RELATED_PIECE_ROW_ID)>
                <cfelse>
                    <cfset 'PIECE_SUB_ID_#PIECE_ROW_ID#' = 0>
                </cfif>
                <cfif PACKAGE_IS_MASTER gt 0>
                    <cfset 'PIECE_ORTAK_#PIECE_ROW_ID#' = 'M'>                                 
                <cfelse>
                    <cfif PACKAGE_PARTNER_ID gt 0>
                         <cfset 'PIECE_ORTAK_#PIECE_ROW_ID#' = 'O'> 
                    <cfelse>
                          <cfset 'PIECE_ORTAK_#PIECE_ROW_ID#' = ''>                                   	 
                    </cfif>
                </cfif>
            </cfloop>
			<cfset workcube_select = 1>	
            <cfinclude template="cpy_ezgi_product_tree_creative_package_row.cfm">
            <cfif get_main_info.MAIN_PROTOTIP_TYPE eq 1><!---Kapı İse--->
            	<cfinclude template="upd_ezgi_product_tree_creative_package_prototip_row.cfm">	
         	<cfelseif get_main_info.MAIN_PROTOTIP_TYPE eq 0><!---Diğer İse--->
        		<cfinclude template="add_ezgi_product_tree_creative_package_demonte_row.cfm">
            </cfif>
        <cfelseif get_main_info.MAIN_PROTOTIP_TYPE eq 2><!---Mutfak İse--->
        	<cfinclude template="add_ezgi_product_tree_creative_package_kitchen_row.cfm">	
        <cfelseif get_main_info.MAIN_PROTOTIP_TYPE eq 3><!---Projeli İşler İse--->
        
        </cfif>
        <script type="text/javascript">
			tr_line = <cfoutput>#DESIGN_MAIN_ROW_ID#</cfoutput>;
			<cfif hata_id eq 0>
				document.getElementById('line_'+tr_line).className = "fa fa-2x fa-bookmark flagTrue";
			<cfelse>
				document.getElementById('line_'+tr_line).className = "fa fa-2x fa-bookmark flagFalse";
			</cfif>
		</script>
    </cfloop>
    <!---</cftransaction>--->
    <script type="text/javascript">
   		alert('<cf_get_lang dictionary_id='264.Özel Tasarıma Transfer Başarıyla Tamamlandı!'>')
      	wrk_opener_reload();
     	window.close();
  	</script>
</cfif>