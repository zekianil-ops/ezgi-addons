<!---
    File: upd_ezgi_iflow_production_order_verifaction.cfm
    Folder: AddOns\ezgi\e_production\form
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cfquery name="GET_PACKAGE" datasource="#DSN3#">
	SELECT 
    	PO.P_ORDER_ID, 
    	PO.LOT_NO, 
        PO.PRODUCTION_LEVEL, 
        PO.SPEC_MAIN_ID, 
        PO.WRK_ROW_RELATION_ID, 
        EP.PACKAGE_NAME
	FROM     
    	EZGI_IFLOW_PRODUCTION_ORDERS AS E INNER JOIN
        PRODUCTION_ORDERS AS PO ON E.LOT_NO = PO.LOT_NO INNER JOIN
        EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
	WHERE  
    	E.IFLOW_P_ORDER_ID = #attributes.iflow_production_order_id#
</cfquery>
<cfif GET_PACKAGE.recordcount>
	<cfquery name="GET_SPECT_MODUL" datasource="#DSN3#">
        SELECT 
         	SPEC_MAIN_ID,
       		LOT_NO
        FROM     
            PRODUCTION_ORDERS
        WHERE  
       		LOT_NO = '#GET_PACKAGE.LOT_NO#' AND
         	PRODUCTION_LEVEL = '0'
    </cfquery>
     <!---Bu üretiminin speğinden başka bir lot ile üretim var mı --->
    <cfquery name="GET_OTHER_PACKAGE_LOT" datasource="#DSN3#">
    	SELECT 
         	LOT_NO
        FROM     
            PRODUCTION_ORDERS
        WHERE  
          	LOT_NO <> '#GET_SPECT_MODUL.LOT_NO#' AND 
        	SPEC_MAIN_ID = #GET_SPECT_MODUL.SPEC_MAIN_ID# AND
         	PRODUCTION_LEVEL = '0'
    </cfquery>
    <cfquery name="get_old_control" dbtype="query">
    	SELECT
        	SPEC_MAIN_ID
        FROM
        	GET_PACKAGE
      	WHERE
            NOT (WRK_ROW_RELATION_ID IS NULL)
    </cfquery>
	<cfif not get_old_control.recordcount> <!---Eğer Bölme İşlemi Yapılmamışsa--->
		<cfset lotlist = valueList(GET_OTHER_PACKAGE_LOT.LOT_NO)>
        <cfif not listLen(lotlist)>
            <script type="text/javascript">
                alert("Eşitleme yapılacak üretim emri bulunamamışıtır.!");
                window.location.reload()
            </script>
            <cfabort>
        <cfelse>
            <cfset hata = 0>
            <cfloop list="#lotlist#" index="lotno">
                <!--- Aynı spectten Bitmiş üretim emri var mı --->
                <cfquery name="GET_OTHER_PACKAGE_LOT_INNER_SUB" datasource="#dsn3#">
                    SELECT 
                        PO.IS_STAGE
                    FROM     
                        PRODUCTION_ORDERS AS PO INNER JOIN
                        EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
                    WHERE  
                        PO.LOT_NO = '#lotno#'
                    GROUP BY 
                        PO.IS_STAGE
                </cfquery>
                <cfif GET_OTHER_PACKAGE_LOT_INNER_SUB.recordcount gt 1>
                    <cfset hata = 1><!--- Birden Fazla Üretim Sonuç Tipi Var (Başlamış, Bitmiş, Başlamamış gibi)--->
                <cfelse>
                    <cfif GET_OTHER_PACKAGE_LOT_INNER_SUB.IS_STAGE eq 2>
                        <!--- Paketlerin Hepsi Bitmiş ise Aslında bir Şablon Bulundu Şimdi Buna bakarak Benim Üretimim Eşitleme Yapılmış mı--->
                        <cfquery name="get_this_lot_amount" datasource="#dsn3#">
                            SELECT 
                                PO.P_ORDER_ID, 
                                PO.LOT_NO, 
                                PO.PRODUCTION_LEVEL, 
                                PO.SPEC_MAIN_ID, 
                                PO.WRK_ROW_RELATION_ID, 
                                EP.PACKAGE_NAME
                            FROM     
                                PRODUCTION_ORDERS AS PO INNER JOIN
                                EZGI_DESIGN_PACKAGE_ROW AS EP ON PO.SPEC_MAIN_ID = EP.PACKAGE_SPECT_RELATED_ID
                            WHERE  
                                PO.LOT_NO = '#lotno#'
                        </cfquery>
                        <cfif GET_PACKAGE.recordcount neq get_this_lot_amount.recordcount>
                            <cfset hata = 2><!--- Paket Sayıları Eşit Değil Git Eşitle--->
                        <cfelse>
                            <cfset hata = 3><!--- Paket Sayıları Eşit Bölme İşlemi Kapalı--->	
                        </cfif>
                        <cfbreak>
                    <cfelseif GET_OTHER_PACKAGE_LOT_INNER_SUB.IS_STAGE eq 1>
                        <cfset hata = 1><!--- Paketlerin Hepsi Başlamış ise--->
                    </cfif>
                </cfif>
            </cfloop>
        	<cfif hata eq 1>
				<script type="text/javascript">
                    alert("<cfoutput>#lotno# ile Başlayan Üretimin Sonlanması Gerekiyor. Bu Yüzden Eşitleme İşlemi Yapamazsınız</cfoutput> !");
					window.location.reload()
                </script>
                <cfabort>
            </cfif>
        </cfif>
    <cfelse>
    	<script type="text/javascript">
            alert("Bu Üretim Emrinin Paketlerinde Bölünme İşlemi Yapılmış Olduğundan Eşitleme Yapılamaz!");
			window.location.reload()
        </script>
    	<cfabort>
    </cfif>
<cfelse>
	<script type="text/javascript">
     	alert("Bu Üretim Emrine ait Paket Bulunamadı!");
    	window.location.reload()
 	</script>
 	<cfabort>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cfform name="production_order_verification" id="production_order_verification" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_production_order_verifaction">
        <cfinput name="iflow_production_order_id" value="#attributes.iflow_production_order_id#" type="hidden">
        <cfinput name="lot_no" value="#lotno#" type="hidden">
        <cfsavecontent variable="title">Paket Eşitleme Kontrol</cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_grid_list>
                <thead>
                    <tr>
                        <th style="text-align:center; width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th style="text-align:center;">Paket Adı</th>
                        <th style="text-align:center; width:20px"></th>
                    </tr>
                </thead>
                <tbody>
                    <cfif get_this_lot_amount.recordcount>
                        <cfoutput query="get_this_lot_amount">
                        	<tr>
                        		<td style="text-align:right">#currentrow#</td>
                                <td>#PACKAGE_NAME#</td>
                                <td style="text-align:center">
                                	<cfif len(WRK_ROW_RELATION_ID)>
                                    	Bölünmüş
                                    <cfelse>
                                    	Master
                                    </cfif>
                                </td>
                        	</tr>
                        </cfoutput>
                    </cfif>
                </tbody>
            </cf_grid_list>
        	<cf_box_footer>
				<div class="col col-6 col-xs-12">
                	<cfif hata eq 2>
                 		<cf_workcube_buttons is_upd='0' add_function='kontrol()' insert_info='Bölme İşlemine Başla'>
                    </cfif>
            	</div>
       		</cf_box_footer>
        </cf_box>
    </cfform>
</div>
<script language="javascript">
    function kontrol()
    {
        
        return true;
    }
</script>