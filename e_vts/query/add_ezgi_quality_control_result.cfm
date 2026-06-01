<!---
    File: add_ezgi_quality_control_result.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="Get_General_Papers" datasource="#dsn3#">
	SELECT QUALITY_CONTROL_NO, MAX(QUALITY_CONTROL_NUMBER) MAX_NO FROM GENERAL_PAPERS WHERE QUALITY_CONTROL_NUMBER IS NOT NULL GROUP BY QUALITY_CONTROL_NO
</cfquery>
<cfset attributes.q_control_no = '#Get_General_Papers.QUALITY_CONTROL_NO#-#Get_General_Papers.MAX_NO#'>
<cfquery name="get_stock_id" datasource="#dsn3#">
	SELECT STOCK_ID,P_ORDER_NO FROM PRODUCTION_ORDERS WHERE P_ORDER_ID = #attributes.upd_id#
</cfquery>
<cflock name="#CreateUUID()#" timeout="20">
	<cftransaction>
		<cfset basarim = 1>
    	<cfloop list="#attributes.convert_list_#" index="_ind_">
			<cfset control_type_id =  ListGetAt(_ind_,1,'-')>
            <cfset control_row_id =  ListGetAt(_ind_,2,'-')>
      		<cfquery name="get_not_row" datasource="#dsn3#">
        		SELECT        
                	QA.CODE
				FROM            
                	QUALITY_CONTROL_ROW AS QA INNER JOIN
                    QUALITY_CONTROL_TYPE AS QT ON QA.QUALITY_CONTROL_TYPE_ID = QT.TYPE_ID
				WHERE        
                	QT.TYPE_ID = #control_type_id# AND 
                    QA.QUALITY_CONTROL_ROW_ID = #control_row_id#
        	</cfquery>
            <cfif basarim eq 1 and get_not_row.CODE eq 0>
            	<cfset basarim = 0>
            </cfif>
        </cfloop>
		<cfquery name="ADD_ORDER_RESULT_QUALITY" datasource="#DSN3#">
			SET NOCOUNT ON
			INSERT INTO
				ORDER_RESULT_QUALITY
				(
					IS_HORIZONTAL,
					CONTROL_AMOUNT,
					SUCCESS_ID,
					IS_REPROCESS,
					IS_ALL_AMOUNT,
					STOCK_ID,
					RESULT_NO,
					Q_CONTROL_NO,
					RECORD_DATE,
					PROCESS_ID,
					PROCESS_ROW_ID,
					SHIP_WRK_ROW_ID,
					SHIP_PERIOD_ID,
					PROCESS_CAT,
					RECORD_EMP,
					STAGE,
					CONTROLLER_EMP_ID,
                 	PROCESS_RESULT_ROW_ID,
                    SERVICECAT_SUB_AMOUNT,
                    SERVICECAT_SUB_STATUS_ID,
                    SUBSCRIPTION_ID
					<cfif ListFind(attributes.x_qualite_control_confirmation,attributes.operation_type_id)>
						,CONTROL_DETAIL
					</cfif>
				)
			 VALUES
				(
					0,
					#filterNum(attributes.realized_amount_,4)#,
					#attributes.success_id_#,
					0,
					0,
					#get_stock_id.stock_id#,
					'#get_stock_id.P_ORDER_NO#',
					'#attributes.q_control_no#',
					#now()#,
					#attributes.upd_id#,
					#attributes.operation_id_#,
					NULL,
					#session.ep.period_id#,
					-1,
					#session.ep.userid#,
                    #attributes.quality_control_process_stage#,
					#attributes.employee_id_#,
                	#attributes.result_id#,
                    <cfif isdefined('attributes.quality_control_amount') and len(attributes.quality_control_amount)>#attributes.quality_control_amount#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.app_sub_id') and len(attributes.app_sub_id)>#attributes.app_sub_id#<cfelse>NULL</cfif>,
                    <cfif isdefined('attributes.subscription_id') and len(attributes.subscription_id)>#attributes.subscription_id#<cfelse>NULL</cfif>
					<cfif ListFind(attributes.x_qualite_control_confirmation,attributes.operation_type_id)>
						,<cfif len(attributes.qualite_control_detail)>'#attributes.qualite_control_detail#'<cfelse>NULL</cfif>
					</cfif>
				)
			SELECT @@Identity AS MAX_ID      
			SET NOCOUNT OFF
		</cfquery>
		<cfloop list="#attributes.convert_list_#" index="_ind_">
			<cfset attributes.control_type_id =  ListGetAt(_ind_,1,'-')>
            <cfset attributes.control_row_id =  ListGetAt(_ind_,2,'-')>	
            <cfif len(attributes.control_type_id) and len(attributes.control_row_id)>	
				<cfquery name="ADD_ORDER_RESULT_QUALITY_ROW" datasource="#DSN3#">
					INSERT INTO
						ORDER_RESULT_QUALITY_ROW
						(
							QUALITY_DETAIL,
							QUALITY_VALUE,
							CONTROL_TYPE_ID,
							CONTROL_ROW_ID,
							CONTROL_RESULT,
                            CONTROL_RESULT_TEXT,
                            CONTROL_RESULT_DATE,
							OR_Q_ID,
							BRAND,
							MODEL
						)
						VALUES
						(
							NULL,
							#filterNum(attributes.realized_amount_,4)#,
							#attributes.control_type_id#,
							#attributes.control_row_id#,
							#filterNum(attributes.realized_amount_,4)#,
                            NULL,
                            NULL,
							#ADD_ORDER_RESULT_QUALITY.MAX_ID#,
							NULL,
							NULL
						)
				</cfquery>
			</cfif>
        </cfloop>

		<!--- Kalite Kontrol Fotoğraf Ve Video Yükleme --->
        <cfif isdefined('attributes.media_material')>
			<cfset filePath = upload_folder & "production">
            <cffile action="uploadAll" destination="#filePath#"  result="UPLOADALL_RESULTS" NAMECONFLICT="Overwrite"><!--- Tüm dosyaları yükler --->
            <cfif arrayLen(UPLOADALL_RESULTS)>
                <cfloop from="1" to="#arrayLen(UPLOADALL_RESULTS)#" index="i">
                    <cfset file = UPLOADALL_RESULTS[i] />
    
                    <cfset newFileName = createUUID() />
                    <cfset newFullFileName = newFileName & "." & file.SERVERFILEEXT />
                    <cffile action="rename" source="#file.SERVERDIRECTORY#/#file.SERVERFILE#" destination="#filePath#/#newFullFileName#" />
    
                    <cfquery name="Set_Asset" datasource="#dsn3#">
                        INSERT INTO ORDER_RESULT_QUALITY_ASSET
                        (
                            OR_Q_ID
                            ,OR_Q_ASSET_NAME
                            ,OR_Q_ASSET_EXT
                            ,OR_Q_ASSET_ENC_NAME
                            ,OR_Q_ASSET_TYPE
                        )
                        VALUES
                        (
                            #ADD_ORDER_RESULT_QUALITY.MAX_ID#
                            ,'#file.SERVERFILENAME#'
                            ,'#file.SERVERFILEEXT#'
                            ,'#newFileName#'
                            ,'#file.CONTENTTYPE#'
                        )
                    </cfquery>
                </cfloop>
            </cfif>
		</cfif>
		<cfif Get_General_Papers.RecordCount>
			<cfquery name="Upd_General_Papers" datasource="#dsn3#">
				UPDATE
					#dsn3_alias#.GENERAL_PAPERS
				SET
					QUALITY_CONTROL_NUMBER = #Get_General_Papers.Max_No+1#
				WHERE
					QUALITY_CONTROL_NUMBER IS NOT NULL
			</cfquery>
		</cfif>
		<cfif basarim eq 0 and not ListFind(attributes.x_qualite_control_confirmation,attributes.operation_type_id)> <!---Seçeneklerden Birisi Olumsuz İse Bildirim Çalışsın ve Kalite Kontrolcu sayfası değilse--->
			<cf_workcube_process 
				is_upd='1' 
				data_source='#dsn3#' 
				old_process_line='0'
				process_stage='#attributes.quality_control_process_stage#'
				record_member='#session.ep.userid#' 
				record_date='#now()#' 
				action_table='ORDER_RESULT_QUALITY'
				action_column='OR_Q_ID'
				action_id='#ADD_ORDER_RESULT_QUALITY.MAX_ID#'
				action_page='#request.self#?fuseaction=stock.list_quality_controls&event=upd&or_q_id=#ADD_ORDER_RESULT_QUALITY.MAX_ID#' 
				warning_description='Kalite : #attributes.q_control_no#'>
		</cfif>
	</cftransaction>    
</cflock>