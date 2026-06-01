<!---
    File: add_ezgi_fast_count.cfm
    Folder: Add_Ons\ezgi\e_wm\query
    Author: Ezgi Yazılım
    Date: 01/12/2025
    Description: Raf Doğrulama Kayıt
---> 
<cfset attributes.row_info_id = ''>
<cfif len(attributes.add_other_shelf)>
	<cfquery name="get_serial" datasource="#dsn3#">
    	SELECT 
        	E.SERIAL_NO, 
            E.STOCK_ID, 
            E.SPECT_ID, 
            E.PALET_BARCODE, 
            E.PRODUCT_NAME, 
            E.SHELF_CODE,
            E.PACKING_ID
		FROM     
      		EZGI_WM_IS_SERIAL_NO_LIVE INNER JOIN
          	EZGI_WM_SERIAL_NO_LAST_STATUS AS E ON EZGI_WM_IS_SERIAL_NO_LIVE.SERIAL_NO = E.SERIAL_NO
		WHERE  
        	E.SHELF_CODE = '#attributes.add_other_shelf#'
		ORDER BY 
        	E.PALET_BARCODE, 
            E.SERIAL_NO
    </cfquery>
	<cfif get_serial.recordcount>
    	<cfif attributes.ROW_COUNT_SEVK neq get_serial.recordcount>
        	<cfoutput>#attributes.ROW_COUNT_SEVK#</cfoutput>
            <cfdump var="#get_serial#">
            Sayım Anındaki Raf Durumu ile Şu anki Durum Atasında Fark Var.
            <cfabort>
        </cfif>
    	<cftransaction>
            <cfquery name="get_shelf_info" datasource="#dsn2#">
                SELECT        
                    PRODUCT_PLACE_ID, 
                    PLACE_CAT_ID, 
                    SHELF_CODE, 
                    PLACE_STATUS, 
                    DEPO
                FROM            
                    #dsn3_alias#.EZGI_PRODUCT_PLACE
                WHERE        
                    SHELF_CODE = '#attributes.add_other_shelf#'
            </cfquery>
            <cfif not get_shelf_info.recordcount>
                <cfdump var="#get_shelf_info#">
                Bu Şirkette <cfoutput>#attributes.add_other_shelf#</cfoutput> Kodlu Raf Bulunamamıştır.
                <cfabort>
            </cfif>
            <cfif not listlen(get_shelf_info.DEPO,'-') eq 2>
                <cfdump var="#get_shelf_info#">
                <cfoutput>#attributes.add_other_shelf#</cfoutput> Rafının Depo Bilgileri Eksik.
                <cfabort>
            </cfif>
            <cfquery name="get_paper_no" datasource="#dsn2#">
                SELECT
                    MAX(PROCESS_NUMBER) PROCESS_NUMBER
                FROM
                    #dsn3_alias#.EZGI_WM_FAST_COUNT
            </cfquery>
            <cfif get_paper_no.recordcount and len(get_paper_no.PROCESS_NUMBER)>
                <cfset paper_no = get_paper_no.PROCESS_NUMBER*1+1> 
            <cfelse>
                <cfset paper_no = 100000>
            </cfif>
            <cfquery name="add_count_fis" datasource="#dsn2#">
                INSERT INTO 
                    #dsn3_alias#.EZGI_WM_FAST_COUNT
                    (
                        PROCESS_DATE, 
                        PROCESS_NUMBER, 
                        PRODUCT_PLACE_ID, 
                        COUNT_TIME, 
                        DEPARTMENT_ID, 
                        LOCATION_ID, 
                        STATUS, 
                        RECORD_EMP, 
                        RECORD_IP, 
                        RECORD_DATE
                    )
                VALUES        
                    (
                        #now()#,
                        #paper_no#,
                        #get_shelf_info.PRODUCT_PLACE_ID#,
                        0,
                        #ListGetAt(get_shelf_info.DEPO,1,'-')#,
                        #ListGetAt(get_shelf_info.DEPO,2,'-')#,
                        1,
                        #session.ep.userid#,                    
                        '#cgi.remote_addr#',
                        #now()#
                    )
            </cfquery>
            <cfquery name="get_max" datasource="#dsn2#">
            	SELECT MAX(EZGI_WM_FAST_COUNT_ID) AS MAX_ID FROM #dsn3_alias#.EZGI_WM_FAST_COUNT
            </cfquery>
            <cfset sira_no = 1>
            <cfloop query="get_serial">
            	<cfset serial_buldu = 0>
            	<cfif isdefined('attributes.ROW_COUNT_CONTENT') and attributes.ROW_COUNT_CONTENT gt 0>
                    <cfloop from="1" to="#attributes.ROW_COUNT_CONTENT#" index="i">
                    	<cfif Evaluate('attributes.SERIAL_NO#i#') eq get_serial.SERIAL_NO>
                        	<cfset serial_buldu = 1>
                        </cfif>
                    </cfloop>
                </cfif>
               	<cfquery name="add_count_row" datasource="#dsn2#">
                	INSERT INTO 
                    	#dsn3_alias#.EZGI_WM_FAST_COUNT_SERIAL_ROW
                      	(
                        	EZGI_WM_FAST_COUNT_ID, 
                            SERIAL_NO, 
                            STOCK_ID, 
                            PACKING_ID, 
                            SPECT_ID, 
                            CONTROL_DATE, 
                            CONTROL_EMP, 
                            IS_LOST_ITEM
                      	)
					VALUES        
                    	(
                        	#get_max.MAX_ID#,
                            '#get_serial.SERIAL_NO#',
                            #get_serial.STOCK_ID#,
                            <cfif len(get_serial.PACKING_ID) and get_serial.PACKING_ID gt 0>#get_serial.PACKING_ID#<cfelse>NULL</cfif>,
                            <cfif len(get_serial.SPECT_ID) and get_serial.SPECT_ID gt 0>#get_serial.SPECT_ID#<cfelse>NULL</cfif>,
                            #now()#,
                            #session.ep.userid#,
                            #serial_buldu#
                     	)
                </cfquery> 
                <cfif serial_buldu eq 0>
					<cfif sira_no eq 1>
                        <cfset attributes.row_info_id = '#sira_no#-#get_serial.SERIAL_NO#'>
                    <cfelse>
                        <cfset attributes.row_info_id = '#attributes.row_info_id#,#sira_no#-#get_serial.SERIAL_NO#'>
                    </cfif>
                    <cfset sira_no = sira_no+1>
                </cfif>
            </cfloop>
            <cfif ListLen(attributes.row_info_id)> <!---Eğer Rafta Okutulamayan Seri No Varsa Fire Fişi Yap--->
				<cfset attributes.fast_count = 1> <!---Bir sonraki Include da yapacağı eylem için --->
                <cfset dep_out = get_shelf_info.DEPO>
                <cfinclude template="add_ezgi_package_between_store_warehouse.cfm">
                <cfquery name="upd_count_fis" datasource="#dsn2#">
                	UPDATE 
                    	#dsn3_alias#.EZGI_WM_FAST_COUNT
                	SET
                    	PERIOD_ID = #session.ep.period_id#,
                        STOCK_FIS_ID = #get_ship.FIS_ID#,
                     	STOCK_FIS_NUMBER = '#get_ship.FIS_NUMBER#',
                      	REFERANS_NO = '#attributes.ezg_row_id#'
                 	WHERE
                    	EZGI_WM_FAST_COUNT_ID = #get_max.MAX_ID#
              	</cfquery>       
            </cfif>
     	</cftransaction>   
	<cfelse>
    	Raftaki Ürün Yoktur.
        <cfabort>
	</cfif>
<cfelse>
	Raf Bilgisi Boştur
	<cfabort>
</cfif>
<script type="text/javascript">
  	alert("Düzenleme Tamamlanmıştır!");
	window.location ="<cfoutput>#request.self#?fuseaction=stock.list_ezgi_fast_count</cfoutput>";
</script>