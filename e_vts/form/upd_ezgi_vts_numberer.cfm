<!---
    File: upd_ezgi_vts_numberer.cfm
    Folder: Add_Ons\ezgi\e-vts\form
    Author: Ezgi Yazılım
    Date: 01/12/2022
    Description:
---><
cfset update_type = 0>
<cfif len(attributes.p_order_id)>
	<cfquery name="get_package" datasource="#dsn3#"><!---İş Emrinden Yukarıya Doğru İlişkili İş emirlerini Buluyorum--->
    	SELECT 
        	PO_1.P_ORDER_ID AS P_ORDER_ID_1, 
            PO_2.P_ORDER_ID AS P_ORDER_ID_2, 
            PO_3.P_ORDER_ID AS P_ORDER_ID_3, 
            PO_4.P_ORDER_ID AS P_ORDER_ID_4
		FROM     
        	PRODUCTION_ORDERS AS PO_1 LEFT OUTER JOIN
            PRODUCTION_ORDERS AS PO_2 LEFT OUTER JOIN
            PRODUCTION_ORDERS AS PO_4 RIGHT OUTER JOIN
            PRODUCTION_ORDERS AS PO_3 ON PO_4.P_ORDER_ID = PO_3.PO_RELATED_ID ON PO_2.PO_RELATED_ID = PO_3.P_ORDER_ID ON PO_1.PO_RELATED_ID = PO_2.P_ORDER_ID RIGHT OUTER JOIN
            PRODUCTION_ORDERS AS PO_0 ON PO_1.P_ORDER_ID = PO_0.PO_RELATED_ID
		WHERE  
        	PO_0.P_ORDER_ID = #attributes.p_order_id#
  	</cfquery>
    <cfif get_package.recordcount>
    	<cfset p_order_id_list = ''>
    	<cfloop from="1" to="4" index="i">
        	<cfif len(Evaluate('get_package.P_ORDER_ID_#i#'))>
    			<cfset p_order_id_list = ListAppend(p_order_id_list,Evaluate('get_package.P_ORDER_ID_#i#'))>
			</cfif>
		</cfloop>
    </cfif> 
    <cfif ListLen(p_order_id_list)>
    	<cfquery name="get_package_id" datasource="#dsn3#"><!---İş Emirlerinden Paket İşemrine Ulaşmaya Çalışıyorum--->
        	SELECT 
            	PO.P_ORDER_ID
			FROM     
            	PRODUCTION_ORDERS AS PO INNER JOIN
                EZGI_DESIGN_DEFAULTS AS E ON PO.STATION_ID = E.DEFAULT_PACKAGE_WORKSTATION_ID
			WHERE  
            	PO.P_ORDER_ID IN (#p_order_id_list#)
        </cfquery>
        <cfif get_package_id.recordcount and len(get_package_id.P_ORDER_ID)>
        	<cfquery name="get_sub_piece" datasource="#dsn3#"><!---Paket İş emrinden 4 seviye aşağıya alt iş emirlerini buluyorum--->
            	SELECT 
                	PO_1.P_ORDER_ID AS P_ORDER_ID_1, 
                    PO_2.P_ORDER_ID AS P_ORDER_ID_2, 
                    PO_3.P_ORDER_ID AS P_ORDER_ID_3, 
                    PO_4.P_ORDER_ID AS P_ORDER_ID_4
				FROM     
                	PRODUCTION_ORDERS AS PO_4 RIGHT OUTER JOIN
                  	PRODUCTION_ORDERS AS PO_3 ON PO_4.PO_RELATED_ID = PO_3.P_ORDER_ID RIGHT OUTER JOIN
                  	PRODUCTION_ORDERS AS PO_2 ON PO_3.PO_RELATED_ID = PO_2.P_ORDER_ID RIGHT OUTER JOIN
                  	PRODUCTION_ORDERS AS PO_1 ON PO_2.PO_RELATED_ID = PO_1.P_ORDER_ID RIGHT OUTER JOIN
                  	PRODUCTION_ORDERS AS PO_0 ON PO_1.PO_RELATED_ID = PO_0.P_ORDER_ID
				WHERE  
                	PO_0.P_ORDER_ID = #get_package_id.P_ORDER_ID#
            </cfquery>
            <cfif get_sub_piece.recordcount>
				<cfset piece_p_order_id_list = ''>
              	<cfloop query="get_sub_piece">
                    <cfloop from="1" to="4" index="i">
                        <cfif len(Evaluate('get_sub_piece.P_ORDER_ID_#i#'))>
                            <cfset piece_p_order_id_list = ListAppend(piece_p_order_id_list,Evaluate('get_sub_piece.P_ORDER_ID_#i#'))>
                        </cfif>
                    </cfloop>
             	</cfloop>
                <cfset piece_p_order_id_list = ListDeleteDuplicates(piece_p_order_id_list,',')>
               	<cfif Listlen(piece_p_order_id_list)>
                 	<cfquery name="get_vts_number" datasource="#dsn3#"><!---Pakete ilişkili Alt İş emirlerinden hehangi birisine VTS Number verilip verilmediği yada birden fazla verildiği kontrol ediliyor --->
                     	SELECT 
                        	EZGI_VTS_NUMBER
						FROM     
                        	PRODUCTION_ORDERS
						WHERE  
                         	P_ORDER_ID IN (#piece_p_order_id_list#)
						GROUP BY 
                        	EZGI_VTS_NUMBER
						HAVING 
                         	NOT (EZGI_VTS_NUMBER IS NULL)
                   	</cfquery>
                    <cfif get_vts_number.recordcount gt 1>
                    	Birden Fazla Takip No Bulundu
                    	<cfdump var="#get_vts_number#">
                    	<cfabort>
                    </cfif>
                    <cfif get_vts_number.recordcount eq 1> <!---Eğer Numarayı Yakaldıysa İlgili İşemrine Güncelle--->
                    	<cfquery name="upd_p_order" datasource="#dsn3#">
                        	UPDATE 
                            	PRODUCTION_ORDERS
							SET          
                            	EZGI_VTS_NUMBER = #get_vts_number.EZGI_VTS_NUMBER#
							WHERE  
                            	P_ORDER_ID = #attributes.p_order_id#
                        </cfquery>
                        <cfset update_type = 1>
                    <cfelse> <!---Eğer Yakalayamadıysa--->
                    	<cflock timeout="90">
                        	<cftransaction>
                                <cfquery name="get_station_numberer" datasource="#dsn3#">
                                    SELECT 
                                        EZGI_VTS_SETUP_ID, 
                                        EZGI_VTS_DEPARTMENT_ID, 
                                        EZGI_VTS_NUMBER_OPERATION_ID, 
                                        EZGI_VTS_NUMBERER_OPERATION_ID, 
                                        EZGI_VTS_NUMBER_MAX, 
                                        EZGI_VTS_NUMER
                                    FROM     
                                        EZGI_VTS_SETUP
                                    WHERE  
                                        EZGI_VTS_DEPARTMENT_ID = (SELECT DEPARTMENT FROM WORKSTATIONS WHERE STATION_ID = (SELECT STATION_ID FROM PRODUCTION_ORDERS WHERE P_ORDER_ID =#attributes.p_order_id#))
                                </cfquery>
                                <cfif get_station_numberer.recordcount and len(get_station_numberer.EZGI_VTS_NUMBER_OPERATION_ID) and len(get_station_numberer.EZGI_VTS_NUMBERER_OPERATION_ID)>
                                    <cfset number_operation_id = get_station_numberer.EZGI_VTS_NUMBER_OPERATION_ID>
                                    <cfset numberer_operation_id = get_station_numberer.EZGI_VTS_NUMBERER_OPERATION_ID>
                                    <cfset maxnumber = get_station_numberer.EZGI_VTS_NUMBER_MAX>
                                    <cfset thisnumber = get_station_numberer.EZGI_VTS_NUMER+1>
                                    <cfif thisnumber gt maxnumber>
                                        <cfset thisnumber = 1>
                                    </cfif>
                                    <cfquery name="upd_station_numberer" datasource="#dsn3#">
                                     	UPDATE
                                        	EZGI_VTS_SETUP
                                     	SET
                                       		EZGI_VTS_NUMER = #thisnumber#
                                       	WHERE
                                        	EZGI_VTS_SETUP_ID = #get_station_numberer.EZGI_VTS_SETUP_ID# 		
                                  	</cfquery>
                                    <cfquery name="upd_p_order" datasource="#dsn3#">
                                        UPDATE 
                                            PRODUCTION_ORDERS
                                        SET          
                                            EZGI_VTS_NUMBER = #thisnumber#
                                        WHERE  
                                            P_ORDER_ID = #get_package_id.P_ORDER_ID#
                                    </cfquery>
                                    <cfquery name="upd_p_order" datasource="#dsn3#">
                                        UPDATE 
                                            PRODUCTION_ORDERS
                                        SET          
                                            EZGI_VTS_NUMBER = #thisnumber#
                                        WHERE  
                                            P_ORDER_ID = #attributes.p_order_id#
                                    </cfquery>
                                <cfelse>
                                    <cfset number_operation_id = 0>
                                    <cfset numberer_operation_id = 0>
                                </cfif>
                         	</cftransaction>
                      	</cflock>
                    	<cfset update_type = 2>
                    </cfif>
             	</cfif>
            </cfif> 
        </cfif>
    </cfif>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfoutput>
	<cf_box scroll="0">
    	<cfif update_type eq 0>
    		<span style="color:red; font-size:36px">Sorunlardan Dolayı Numara Verilemedi.</span>
    	<cfelseif update_type eq 1>
        	<div class="col col-12" style="text-align:center; height:120px; font-weight:bold">
            	<span style="color:green; font-size:85px">#get_vts_number.EZGI_VTS_NUMBER#</span>
          	</div>  
            <div class="col col-12" style="text-align:center; height:70px; font-weight:bold">
            	<span style="color:green; font-size:36px">Paket Numarası Atandı</span>
            </div>
       	<cfelseif update_type eq 2>
        	<div class="col col-12" style="text-align:center; height:120px; font-weight:bold">
            	<span style="color:orange; font-size:85px">#thisnumber#</span>
          	</div>  
            <div class="col col-12" style="text-align:center; height:70px; font-weight:bold">
            	<span style="color:orange; font-size:36px">Yeni Paket Numarası Atandı</span>
            </div> 
        </cfif>
   </cf_box> 
   </cfoutput>
</div>
<script language="javascript">
	setTimeout(function(){wrk_opener_reload();window.close();}, 2000);
</script>