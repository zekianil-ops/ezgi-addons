<cfparam name="attributes.form_is_submitted" default="0">
<cfparam name="attributes.acc_branch_id" default="">
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.report_type" default="">
<cfparam name="attributes.keyword1" default="">
<cfparam name="attributes.keyword2" default="">
<cfset sifir =0>
<cfinclude template="../query/get_branch_list.cfm">
<!---Şirketin Dönemlerini Çekiyoruz--->
<cfquery name="get_period" datasource="#dsn#">
    SELECT     
        PERIOD_YEAR
    FROM         
        SETUP_PERIOD
    WHERE     
        OUR_COMPANY_ID = #session.ep.company_id# AND
        PERIOD_YEAR > 2011
  	ORDER BY
      	PERIOD_YEAR desc
</cfquery>
<cfset yil = valuelist(get_period.PERIOD_YEAR)>
<cfquery name="get_period_date" datasource="#dsn#">
	SELECT     
    	PERIOD_DATE
	FROM         
    	SETUP_PERIOD
	WHERE     
    	PERIOD_ID = #session.ep.period_id#
</cfquery>
<cfif attributes.report_type neq 10> <!---Detaylı Mizan Değilse--->
    <cfquery name="get_account_name" datasource="#dsn2#">
        SELECT     
            ACCOUNT_ID, 
            ACCOUNT_CODE, 
            ACCOUNT_NAME
        FROM         
            ACCOUNT_PLAN
        WHERE     
            ACCOUNT_CODE IN
                            (
                            SELECT DISTINCT 
                                LEFT(ACCOUNT_CODE, 3) AS ACCOUNT_CODE
                            FROM          
                                ACCOUNT_PLAN AS ACCOUNT_PLAN_1
                            )
    </cfquery>
    <cfif get_account_name.recordcount>
        <cfoutput query="get_account_name">
            <cfset 'BAKIYE_#ACCOUNT_CODE#' = 0>
        </cfoutput>
    </cfif> 
<cfelse>
	<cfquery name="get_account_name" datasource="#dsn2#">
        SELECT     
            ACCOUNT_ID, 
            ACCOUNT_CODE, 
            ACCOUNT_NAME,
            SUB_ACCOUNT
        FROM         
            ACCOUNT_PLAN
       	WHERE
        	1=1
			<cfif len(attributes.keyword1)>
                AND ACCOUNT_CODE >= '#attributes.keyword1#'  
            </cfif>
          	<cfif len(attributes.keyword2)>
            	AND ACCOUNT_CODE <= '#attributes.keyword2#'  
          	</cfif> 
      	ORDER BY
        	ACCOUNT_CODE
  	</cfquery>
    <cfif get_account_name.recordcount>
        <cfoutput query="get_account_name">
            <cfset 'BAKIYE_#ACCOUNT_ID#' = 0>
        </cfoutput>
    </cfif> 
</cfif>
<cfset period_date_lock = get_period_date.PERIOD_DATE>
<cfquery name="get_money" datasource="#dsn2#">
	SELECT MONEY FROM SETUP_MONEY WHERE MONEY_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="1">
</cfquery>
<cfset money_list=valuelist(get_money.money)>
<cfif not(isdefined('attributes.is_excel') and attributes.is_excel eq 1)>
	<!-- sil -->
	<table width="100%" border="0" align="center" cellpadding="1" cellspacing="1"> 
    	<tr>
            <td class="headbold" height="35">
            	<a href="javascript:gizle_goster(gizli);" >
            		<cfif listfind(attributes.report_type,1)>
                    	&nbsp;Bilanço Tablosu
                    <cfelseif listfind(attributes.report_type,2)>
                    	&nbsp;Stok Girişleri
            		<cfelseif listfind(attributes.report_type,3)>
                    	&nbsp;Gelir Tablosu
                    <cfelseif listfind(attributes.report_type,4)>
                    	&nbsp;Bilanço Dikey Analiz
                    <cfelseif listfind(attributes.report_type,5)>
                    	&nbsp;Bilanço Trend Analiz
                    <cfelseif listfind(attributes.report_type,6)>
                    	&nbsp;Gelir Tablosu Dikey Analiz
                   	<cfelseif listfind(attributes.report_type,7)>
                    	&nbsp;Gelir Tablosu Trend Analiz
                  	<cfelseif listfind(attributes.report_type,8)>
                    	&nbsp;Rasyo Analiz      
					<cfelseif listfind(attributes.report_type,9)>
                    	&nbsp;Mizan Analiz 
                   	<cfelseif listfind(attributes.report_type,10)>
                    	&nbsp;Detaylı Mizan Analiz 
                    </cfif>
            	</a>
            </td>
            <!-- sil --><cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'><!-- sil -->
        </tr>
		<tr class="color-border">
			<td colspan="2">
			<table width="100%" border="0" align="center" cellpadding="1" cellspacing="1" class="color-list">
				<cfform name="form" action="#request.self#?fuseaction=report.list_ezgi_bilanco_analist" method="post">
				<input type="hidden" name="form_is_submitted" value="1">
                <input type="hidden" name="report_type" value="<cfoutput>#attributes.report_type#</cfoutput>">
				<tr valign="top">
					<td style="width:200">
						&nbsp;Listeleme Aralığı
                        <select name="list_type" style="width:150px; height:20px"  onchange="show_check_date()">
                        	<option value="1"<cfif isdefined('attributes.list_type') and attributes.list_type eq 1>selected</cfif>>Yıllık</option>
                        	<option value="2"<cfif isdefined('attributes.list_type') and attributes.list_type eq 2>selected</cfif>>Üç Aylık</option>
                            <option value="3"<cfif isdefined('attributes.list_type') and attributes.list_type eq 3>selected</cfif>>Aylık</option>
                        </select>
					</td>
                    <td style="width:200px">
                    	&nbsp;Sadece Fark Getir
						<input type="checkbox" name="is_total" value="1" <cfif isdefined('attributes.is_total')>checked</cfif>>
                    </td>
                    <cfif attributes.report_type eq 10>
                        <td style="width:240px">
                        <cfoutput>
                            &nbsp;Hesap Aralığı
                            <input type="text" value="#attributes.keyword1#" name="keyword1" style="text-align:left; width:70px" />&nbsp;&nbsp;
                            <input type="text" value="#attributes.keyword2#" name="keyword2" style="text-align:left; width:70px" />
                       	</cfoutput>
                        </td>
                    </cfif>
                    <td></td>
                    <td rowspan="2" style="width:200px">
                    	<select multiple="multiple" name="acc_branch_id" style="width:175px;height:60px;">
							<optgroup label="<cf_get_lang_main no='41.Şube'>"></optgroup>
							<cfoutput query="get_branchs">
								<option value="#BRANCH_ID#" <cfif isdefined('attributes.acc_branch_id') and listfind(attributes.acc_branch_id,BRANCH_ID)>selected</cfif>>#BRANCH_NAME#</option>
							</cfoutput>
						</select>
                    </td>
					<td style="text-align:right; width:150px">&nbsp;Başlangıç Yılı&nbsp;
						<select name="date1" style="width:70px; height:20px">
                        	<cfoutput query="get_period">
                            	<option value="#PERIOD_YEAR#" <cfif isdefined('attributes.date1') and attributes.date1 eq PERIOD_YEAR>selected</cfif>>#PERIOD_YEAR#</option>
                            </cfoutput>
                        </select>
                  	</td>
                    <td style="text-align:right; width:200px;<cfif isdefined('attributes.list_type') and attributes.list_type eq 3>display:none</cfif>" id="check_type_">
                        &nbsp;Bitiş Yılı&nbsp;
						<select name="date2" style="width:70px; height:20px">
                        	<cfoutput query="get_period">
                            	<option value="#PERIOD_YEAR#"  <cfif isdefined('attributes.date2') and attributes.date2 eq PERIOD_YEAR>selected</cfif>>#PERIOD_YEAR#</option>
                            </cfoutput>
                        </select>
					</td>
					<td width="3%" nowrap="nowrap">
						<cfsavecontent variable="message"><cf_get_lang_main no ='499.Çalıştır'></cfsavecontent>
						<cf_workcube_buttons add_function='tarih_kontrolu()' is_upd='0' is_cancel='0' insert_info='#message#' insert_alert=''>
					</td>	
				</tr>
                <tr valign="top">
                	<cfif listfind(attributes.report_type,3) or listfind(attributes.report_type,6) or listfind(attributes.report_type,7) or listfind(attributes.report_type,9) or listfind(attributes.report_type,10)>
                        <td width="250">
                            &nbsp;Yansıtma Hesapları Kapama Fişi Getirme
                            <input type="checkbox" name="is_closed_card" value="1" <cfif isdefined('attributes.is_closed_card')>checked</cfif>>
                        </td>
                  	</cfif>      
                    <td>
                    	&nbsp;Çalışmamış Hesapları Getirme
						<input type="checkbox" name="is_zero" value="1" <cfif isdefined('attributes.is_zero')>checked</cfif>>
                    </td>
                </tr>
				</cfform>
			</table>
			</td>
		</tr>
	</table>
	<!-- sil -->
</cfif>
<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
	<cfset function_td_type = 0>
<cfelse>
	<cfset function_td_type = 2>
</cfif>
<cfset yil_basi = "01/01/#session.ep.period_year#">
<cfif attributes.form_is_submitted>
	<cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
		<cfset satir_sonu = chr(13)&chr(10)>
		<cfset tr_kapat_ = satir_sonu>
		<cfset filename = "#createuuid()#">
		<cfheader name="Expires" value="#Now()#">
		<cfcontent type="text/vnd.plain;charset=ISO-8859-9">
		<cfheader name="Content-Disposition" value="attachment; filename=#filename#.csv">
	</cfif>
	<cfif get_period.recordcount>
    	<cfswitch expression="#list_type#" >
				<cfcase value="1">
                	<cfset period_col=0>
                	<cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
						<cfset 'period_time1_1_#i#' =  "01/01/#i#">
                        <cfset 'period_time2_1_#i#' =  "31/12/#i#">
                        <cfset 'period_header_1_#i#' = '#i# Yılı'>
                        <cfset period_col=period_col+2>
                  	</cfloop>
                    <cfset sene1 = attributes.date1>
                    <cfset sene2 = attributes.date2>
                    <cfset period_say = 1> 
                </cfcase>
                <cfcase value="2">
                	<cfset period_col=0>
                	<cfloop from="#attributes.date1#" to="#attributes.date2#" index="i">
						
                        <cfset 'period_time2_1_#i#' =  "31/03/#i#">
                        <cfset 'period_time2_2_#i#' =  "30/06/#i#">
                        <cfset 'period_time2_3_#i#' =  "30/09/#i#">
                        <cfset 'period_time2_4_#i#' =  "31/12/#i#">
                        <cfif attributes.list_type neq 1 and isdefined('is_total') and len(is_total)>
                            <cfset 'period_time1_1_#i#' =  "01/01/#i#">
                            <cfset 'period_time1_2_#i#' =  "01/04/#i#">
                            <cfset 'period_time1_3_#i#' =  "01/07/#i#">
                            <cfset 'period_time1_4_#i#' =  "01/10/#i#">
                      	<cfelse>  
							<cfset 'period_time1_1_#i#' =  "01/01/#i#">
                            <cfset 'period_time1_2_#i#' =  "01/01/#i#">
                            <cfset 'period_time1_3_#i#' =  "01/01/#i#">
                            <cfset 'period_time1_4_#i#' =  "01/01/#i#">
						</cfif>
						<cfset 'period_header_1_#i#' = 'Mar/#i#'>
                        <cfset 'period_header_2_#i#' = 'Haz/#i#'>
                        <cfset 'period_header_3_#i#' = 'Eyl/#i#'>
                        <cfset 'period_header_4_#i#' = 'Ara/#i#'>
                        
                        <cfset 'period_flu_1_#i#' =  Dateformat("31/03/#i#", 'dd/mm/yyyy')>
                       	<cfset 'period_flu_2_#i#' =  Dateformat("30/06/#i#", 'dd/mm/yyyy')>
                        <cfset 'period_flu_3_#i#' =  Dateformat("30/09/#i#", 'dd/mm/yyyy')>
                        <cfset 'period_flu_4_#i#' =  Dateformat("31/12/#i#", 'dd/mm/yyyy')>
                        <cfset period_col= period_col+5>
                  	</cfloop> 
                    <cfset sene1 = attributes.date1>
                    <cfset sene2 = attributes.date2>
                    <cfset period_say = 4>
                </cfcase>
				<cfcase value="3">
                    <cfloop from="1" to="12" index="ay">
                    	<cfif len(ay) eq 1>
                        	<cfset m_ay = '0#ay#'> 
                        <cfelse>
                        	<cfset m_ay = ay> 
                        </cfif>
                    	<cfset 'period_time2_#ay#_#date1#' =  "01/#m_ay#/#date1#">
                        <cfset bu_ay = Evaluate('period_time2_#ay#_#date1#')>
                        <cf_date tarih="bu_ay">
                        <cfset ayin_son_gunu = DaysInMonth(bu_ay)>
                        <cfif len(ayin_son_gunu) eq 1>
                        	<cfset m_ayin_son_gunu = '0#ayin_son_gunu#'> 
                        <cfelse>
                        	<cfset m_ayin_son_gunu = ayin_son_gunu> 
                        </cfif>
                        <cfset 'period_time2_#ay#_#date1#' =  "#m_ayin_son_gunu#/#m_ay#/#date1#">
                        <cfif attributes.list_type neq 1 and isdefined('is_total') and len(is_total)>
                        	<cfset 'period_time1_#ay#_#date1#' =  "01/#m_ay#/#date1#">
                       	<cfelse> 
                        	<cfset 'period_time1_#ay#_#date1#' =  "01/01/#date1#">
                        </cfif>
                        <cfset 'period_flu_#ay#_#date1#' =  Dateformat("#m_ayin_son_gunu#/#m_ay#/#date1#", 'dd/mm/yyyy')>
                    </cfloop>
    
                    <cfset 'period_header_1_#date1#' = 'Ocak'>
                    <cfset 'period_header_2_#date1#' = 'Şubat'>
                    <cfset 'period_header_3_#date1#' = 'Mart'>
                    <cfset 'period_header_4_#date1#' = 'Nisan'>
                    <cfset 'period_header_5_#date1#' = 'Mayıs'>
                    <cfset 'period_header_6_#date1#' = 'Haziran'>
                    <cfset 'period_header_7_#date1#' = 'Temmuz'>
                    <cfset 'period_header_8_#date1#' = 'Ağustos'>
                    <cfset 'period_header_9_#date1#' = 'Eylül'>
                    <cfset 'period_header_10_#date1#' = 'Ekim'>
                    <cfset 'period_header_11_#date1#' = 'Kasım'>
                    <cfset 'period_header_12_#date1#' = 'Aralık'>
                    
                    <cfset period_col=13>
                    <cfset sene1 = attributes.date1>
                    <cfset sene2 = attributes.date1>
                    <cfset period_say = 12>
                </cfcase>
		</cfswitch>
        <cfset period_col= period_col+2>
        <cfloop from="#sene1#" to="#sene2#" index="ii">
        	<cfloop from="1" to="#period_say#" index="i">
            	<cfset start_date = evaluate('period_time1_#i#_#ii#')>
                <cfset finish_date = evaluate('period_time2_#i#_#ii#')>
                <cf_date tarih ="start_date">
                <cf_date tarih ="finish_date">
            	<cfset new_dsn2 = '#dsn#_#ii#_#session.ep.company_id#'>
                <cfif attributes.report_type neq 10> <!---Detaylı Mizan Değilse--->
                    <cfquery name="get_mizan" datasource="#new_dsn2#">
                        SELECT
                            ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC - ACCOUNT_ACCOUNT_REMAINDER.ALACAK),2) AS BAKIYE, 
                            ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC),2) AS BORC,
                            ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.ALACAK),2) AS ALACAK, 
                            ACCOUNT_PLAN.ACCOUNT_CODE,
                            ACCOUNT_PLAN.ACCOUNT_NAME,
                            ACCOUNT_PLAN.ACCOUNT_ID
                        FROM
                            (
                            SELECT
                                0 AS ALACAK,
                                SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2)) AS BORC,
                                ACCOUNT_CARD_ROWS.ACCOUNT_ID		
                            FROM
                                ACCOUNT_CARD_ROWS,ACCOUNT_CARD
                            WHERE
                                BA = 0 AND ACCOUNT_CARD.CARD_ID=ACCOUNT_CARD_ROWS.CARD_ID
                                AND (ACCOUNT_CARD.CARD_TYPE <> 19)
                                <cfif attributes.list_type neq 1 and isdefined('is_total') and len(is_total)>
                                    AND (ACCOUNT_CARD.CARD_TYPE <> 10)
                                </cfif>
                                AND ACTION_DATE >= #start_date#
                                AND ACTION_DATE <= #finish_date#
                                <cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                    AND (ACCOUNT_CARD_ROWS.ACC_BRANCH_ID IN (#attributes.acc_branch_id#))
                                </cfif>
                                <cfif isdefined('attributes.is_closed_card') and len(attributes.is_closed_card)>
                                    AND (ISNULL(ACCOUNT_CARD.ACTION_TYPE,0) <> 172)
                                </cfif>
                            GROUP BY
                                ACCOUNT_CARD_ROWS.ACCOUNT_ID
                            <cfif isdefined('attributes.is_zero') and len(attributes.is_zero)>
                            HAVING 
                                SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2))<> Round(#sifir#,2)
                            </cfif>
                            UNION ALL
                            SELECT
                                SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2)) AS ALACAK,
                                0 AS BORC,
                                ACCOUNT_CARD_ROWS.ACCOUNT_ID		
                            FROM
                                ACCOUNT_CARD_ROWS,ACCOUNT_CARD
                            WHERE
                                BA = 1 AND ACCOUNT_CARD.CARD_ID=ACCOUNT_CARD_ROWS.CARD_ID
                                AND (ACCOUNT_CARD.CARD_TYPE <> 19)
                                <cfif attributes.list_type neq 1 and isdefined('is_total') and len(is_total)>
                                    AND (ACCOUNT_CARD.CARD_TYPE <> 10)
                                </cfif>
                             	AND ACTION_DATE >= #start_date#
                                AND ACTION_DATE <= #finish_date#
                                <cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                    AND (ACCOUNT_CARD_ROWS.ACC_BRANCH_ID IN (#attributes.acc_branch_id#) )
                                </cfif>
                                <cfif isdefined('attributes.is_closed_card') and len(attributes.is_closed_card)>
                                    AND (ISNULL(ACCOUNT_CARD.ACTION_TYPE,0) <> 172)
                                </cfif>
                            GROUP BY
                                ACCOUNT_CARD_ROWS.ACCOUNT_ID
                            <cfif isdefined('attributes.is_zero') and len(attributes.is_zero)>     
                            HAVING 
                                SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2))<>Round(#sifir#,2)
                            </cfif>
                            
                           )
                            AS ACCOUNT_ACCOUNT_REMAINDER,
                            ACCOUNT_PLAN
                        WHERE
                            (ACCOUNT_PLAN.ACCOUNT_CODE = LEFT(ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID,3))
                        GROUP BY
                            ACCOUNT_PLAN.ACCOUNT_CODE, 
                            ACCOUNT_PLAN.ACCOUNT_NAME,
                            ACCOUNT_PLAN.ACCOUNT_ID
                        ORDER BY 
                            ACCOUNT_PLAN.ACCOUNT_CODE
                    </cfquery>
                    <cfif get_mizan.recordcount>
						<cfoutput query="get_mizan">
                            <cfset 'BAKIYE_#i#_#ii#_#ACCOUNT_CODE#' = BAKIYE>
                            <cfif isdefined('TOPLAM_#i#_#ii#')>
                                <cfset 'TOPLAM_#i#_#ii#' = Evaluate('TOPLAM_#i#_#ii#')+BAKIYE>
                            <cfelse>
                                <cfset 'TOPLAM_#i#_#ii#' = BAKIYE>
                            </cfif>
                        </cfoutput>
                    </cfif>
                <cfelse><!---Detaylı Mizan İse--->
                 	<cfquery name="get_mizan" datasource="#new_dsn2#">
                		SELECT     
                        	SUM(BAKIYE) AS BAKIYE, 
                            SUM(BORC) AS BORC, 
                            SUM(ALACAK) AS ALACAK, 
                            ACCOUNT_CODE, 
                            ACCOUNT_NAME, 
                            ACCOUNT_ID, 
                            SUB_ACCOUNT
						FROM         
                        	(
                            	SELECT     
                                	ACCOUNT_PLAN.SUB_ACCOUNT, 
                                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC - ACCOUNT_ACCOUNT_REMAINDER.ALACAK), 2) AS BAKIYE, 
                                  	ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC), 2) AS BORC, 
                                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.ALACAK), 2) AS ALACAK, 
                              		ACCOUNT_PLAN.ACCOUNT_CODE, 
                                    ACCOUNT_PLAN.ACCOUNT_NAME, 
                                    ACCOUNT_PLAN.ACCOUNT_ID
                       			FROM          

                                	(
                                    	SELECT     
                                        	0 AS ALACAK, 
                                        	SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT, 2)) AS BORC, 
                                        	ACCOUNT_CARD_ROWS.ACCOUNT_ID
                                     	FROM          
                                        	ACCOUNT_CARD_ROWS INNER JOIN
                                      		ACCOUNT_CARD ON ACCOUNT_CARD_ROWS.CARD_ID = ACCOUNT_CARD.CARD_ID
                                     	WHERE      
                                        	ACCOUNT_CARD_ROWS.BA = 0 AND 
                                            ACCOUNT_CARD.ACTION_DATE >= #start_date# AND
                                            ACCOUNT_CARD.ACTION_DATE <= #finish_date#
                                            <cfif len(attributes.keyword1)>
                                            	AND ACCOUNT_CARD_ROWS.ACCOUNT_ID >= '#attributes.keyword1#'  
                                            </cfif>
                                            <cfif len(attributes.keyword2)>
                                            	AND ACCOUNT_CARD_ROWS.ACCOUNT_ID <= '#attributes.keyword2#'  
                                            </cfif> 
                                        	<cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                                AND (ACCOUNT_CARD_ROWS.ACC_BRANCH_ID IN (#attributes.acc_branch_id#) )
                                            </cfif>
                                            <cfif isdefined('attributes.is_closed_card') and len(attributes.is_closed_card)>
                                                AND (ISNULL(ACCOUNT_CARD.ACTION_TYPE,0) <> 172)
                                            </cfif>
                                 		GROUP BY 
                                        	ACCOUNT_CARD_ROWS.ACCOUNT_ID
                                      	<cfif isdefined('attributes.is_zero') and len(attributes.is_zero)> 
                                            HAVING      
                                                SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT, 2)) <> 0
                                      	</cfif>
                                      	UNION ALL
                                     	SELECT     
                                        	SUM(ROUND(ACCOUNT_CARD_ROWS_1.AMOUNT, 2)) AS ALACAK, 
                                            0 AS BORC, 
                                            ACCOUNT_CARD_ROWS_1.ACCOUNT_ID
                                     	FROM         
                                        	ACCOUNT_CARD_ROWS AS ACCOUNT_CARD_ROWS_1 INNER JOIN
                                   			ACCOUNT_CARD AS ACCOUNT_CARD_1 ON ACCOUNT_CARD_ROWS_1.CARD_ID = ACCOUNT_CARD_1.CARD_ID
                                     	WHERE     
                                        	ACCOUNT_CARD_ROWS_1.BA = 1 AND 
                                            ACCOUNT_CARD_1.ACTION_DATE >= #start_date# AND
                                            ACCOUNT_CARD_1.ACTION_DATE <= #finish_date#
                                            <cfif len(attributes.keyword1)>
                                            	AND ACCOUNT_CARD_ROWS_1.ACCOUNT_ID >= '#attributes.keyword1#'  
                                            </cfif>
                                            <cfif len(attributes.keyword2)>
                                            	AND ACCOUNT_CARD_ROWS_1.ACCOUNT_ID <= '#attributes.keyword2#'  
                                            </cfif> 
                                            <cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                                AND (ACCOUNT_CARD_ROWS_1.ACC_BRANCH_ID IN (#attributes.acc_branch_id#) )
                                            </cfif>
                                            <cfif isdefined('attributes.is_closed_card') and len(attributes.is_closed_card)>
                                                AND (ISNULL(ACCOUNT_CARD_1.ACTION_TYPE,0) <> 172)
                                            </cfif>
                                    	GROUP BY 
                                        	ACCOUNT_CARD_ROWS_1.ACCOUNT_ID
                                      	<cfif isdefined('attributes.is_zero') and len(attributes.is_zero)> 
                                            HAVING      
                                                SUM(ROUND(ACCOUNT_CARD_ROWS_1.AMOUNT, 2)) <> 0
                                      	</cfif>
                                 	) AS ACCOUNT_ACCOUNT_REMAINDER CROSS JOIN
                                  	ACCOUNT_PLAN
                      			 WHERE     
                                 	(
                                    CHARINDEX('.', ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID) > 0 AND 
                                    ACCOUNT_PLAN.SUB_ACCOUNT = 1 AND 
                                   	ACCOUNT_PLAN.ACCOUNT_CODE = LEFT(ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID,LEN(ACCOUNT_PLAN.ACCOUNT_CODE))
                                    <cfif len(attributes.keyword1)>
                                   		AND ACCOUNT_PLAN.ACCOUNT_CODE >= '#attributes.keyword1#'  
                                   	</cfif>
                                  	<cfif len(attributes.keyword2)>
                                     	AND ACCOUNT_PLAN.ACCOUNT_CODE <= '#attributes.keyword2#'  
                                  	</cfif> 
                                   	) 
                                    OR
                                    (
                                    CHARINDEX('.', ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID) = 0 AND 
                                    ACCOUNT_PLAN.ACCOUNT_CODE = LEFT(ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID,LEN(ACCOUNT_PLAN.ACCOUNT_CODE))
                                    <cfif len(attributes.keyword1)>
                                   		AND ACCOUNT_PLAN.ACCOUNT_CODE >= '#attributes.keyword1#'  
                                   	</cfif>
                                  	<cfif len(attributes.keyword2)>
                                     	AND ACCOUNT_PLAN.ACCOUNT_CODE <= '#attributes.keyword2#'  
                                  	</cfif> 
                                    ) 
                                    OR
                                   	(
                                   	LEN(ACCOUNT_PLAN.ACCOUNT_CODE) < 3 AND 
                                    ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID LIKE ACCOUNT_PLAN.ACCOUNT_CODE + '%' 
                                    <cfif len(attributes.keyword1)>
                                   		AND ACCOUNT_PLAN.ACCOUNT_CODE >= '#attributes.keyword1#'  
                                   	</cfif>
                                  	<cfif len(attributes.keyword2)>
                                     	AND ACCOUNT_PLAN.ACCOUNT_CODE <= '#attributes.keyword2#'  
                                  	</cfif> 
                                    )
                                    OR
                                    (
                                  	ACCOUNT_PLAN.ACCOUNT_CODE = ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID
                                    <cfif len(attributes.keyword1)>
                                   		AND ACCOUNT_PLAN.ACCOUNT_CODE >= '#attributes.keyword1#'  
                                   	</cfif>
                                  	<cfif len(attributes.keyword2)>
                                     	AND ACCOUNT_PLAN.ACCOUNT_CODE <= '#attributes.keyword2#'  
                                  	</cfif> 
                                    )
                       			GROUP BY ACCOUNT_PLAN.ACCOUNT_CODE, 
                                    ACCOUNT_PLAN.ACCOUNT_NAME, 
                                    ACCOUNT_PLAN.ACCOUNT_ID, 
                                    ACCOUNT_PLAN.SUB_ACCOUNT
                      		) AS T1
						GROUP BY 
                        	ACCOUNT_CODE, 
                            ACCOUNT_NAME, 
                            ACCOUNT_ID, 
                            SUB_ACCOUNT
						ORDER BY 
                        	ACCOUNT_CODE
                	</cfquery>
                    
                    <cfif get_mizan.recordcount>
						<cfoutput query="get_mizan">
                            <cfset 'BAKIYE_#i#_#ii#_#ACCOUNT_ID#' = BAKIYE>
                            <cfif isdefined('TOPLAM_#i#_#ii#')>
                                <cfset 'TOPLAM_#i#_#ii#' = Evaluate('TOPLAM_#i#_#ii#')+BAKIYE>
                            <cfelse>
                                <cfset 'TOPLAM_#i#_#ii#' = BAKIYE>
                            </cfif>
                        </cfoutput>
                    </cfif>
                </cfif>
           	</cfloop>
        </cfloop>
        <cfset last_donem = attributes.date1 - 1>
        <cfquery name="check_period" dbtype="query">
            SELECT     
                PERIOD_YEAR
            FROM         
                get_period
            WHERE     
                PERIOD_YEAR = #last_donem#
      	</cfquery>          
        <cfif listfind(attributes.report_type,3) or listfind(attributes.report_type,6) or listfind(attributes.report_type,7)>
        	<cfif not check_period.recordcount>
            	<script language="JavaScript">
					alert("Önceki Dönem Bilançosu İçin Girdiğiniz Tarihi Kontrol Edin !");
					/*history.back();*/
				</script>
          	<cfelse>  
				<cfset donem_basi = "01/01/#last_donem#">
                <cf_date tarih="donem_basi">
                <cfset donem_sonu = "31/12/#last_donem#">
                <cf_date tarih="donem_sonu">
                <cfset donem_dsn2 = '#dsn#_#last_donem#_#session.ep.company_id#'>
                <cfquery name="get_acilis_fisi" datasource="#donem_dsn2#">
                    SELECT
                        ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC - ACCOUNT_ACCOUNT_REMAINDER.ALACAK),2) AS BAKIYE, 
                        ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC),2) AS BORC,
                        ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.ALACAK),2) AS ALACAK, 
                        ACCOUNT_PLAN.ACCOUNT_CODE,
                        ACCOUNT_PLAN.ACCOUNT_NAME,
                        ACCOUNT_PLAN.ACCOUNT_ID
                    FROM
                        (
                        SELECT
                            0 AS ALACAK,
                            SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2)) AS BORC,
                            ACCOUNT_CARD_ROWS.ACCOUNT_ID		
                        FROM
                            ACCOUNT_CARD_ROWS,ACCOUNT_CARD
                        WHERE
                            BA = 0 AND ACCOUNT_CARD.CARD_ID=ACCOUNT_CARD_ROWS.CARD_ID
                            AND (ACCOUNT_CARD.CARD_TYPE <> 19)
                            AND ACTION_DATE BETWEEN #donem_basi# AND #donem_sonu#
                            <cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                 AND (ACCOUNT_CARD_ROWS.ACC_BRANCH_ID IN (#attributes.acc_branch_id#))
                            </cfif>
                        GROUP BY
                            ACCOUNT_CARD_ROWS.ACCOUNT_ID
                            <cfif isdefined('attributes.is_zero') and len(attributes.is_zero)>
                            HAVING SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2))<>0
                            </cfif>
                        UNION ALL
                        SELECT
                            SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2)) AS ALACAK,
                            0 AS BORC,
                            ACCOUNT_CARD_ROWS.ACCOUNT_ID		
                        FROM
                            ACCOUNT_CARD_ROWS,ACCOUNT_CARD
                        WHERE
                            BA = 1 AND ACCOUNT_CARD.CARD_ID=ACCOUNT_CARD_ROWS.CARD_ID
                            AND (ACCOUNT_CARD.CARD_TYPE <> 19)
                            AND ACTION_DATE BETWEEN #donem_basi# AND #donem_sonu#
                            <cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                AND (ACCOUNT_CARD_ROWS.ACC_BRANCH_ID IN (#attributes.acc_branch_id#) )
                            </cfif>
                        GROUP BY
                            ACCOUNT_CARD_ROWS.ACCOUNT_ID
                            <cfif isdefined('attributes.is_zero') and len(attributes.is_zero)>
                            HAVING SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2))<>0
                            </cfif>
                                
                        )
                        AS ACCOUNT_ACCOUNT_REMAINDER,
                        ACCOUNT_PLAN
                    WHERE
                       (ACCOUNT_PLAN.ACCOUNT_CODE = LEFT(ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID,3))
                    GROUP BY
                        ACCOUNT_PLAN.ACCOUNT_CODE, 
                        ACCOUNT_PLAN.ACCOUNT_NAME,
                        ACCOUNT_PLAN.ACCOUNT_ID
                    ORDER BY 
                        ACCOUNT_PLAN.ACCOUNT_CODE
                </cfquery>
            </cfif>
        <cfelse>
        	<cfset donem_basi = "01/01/#attributes.date1#">
            <cf_date tarih="donem_basi">
			<cfset donem_dsn2 = '#dsn#_#sene1#_#session.ep.company_id#'>
            <cfif attributes.report_type neq 10> <!---Detaylı Mizan Değilse--->
                <cfquery name="get_acilis_fisi" datasource="#donem_dsn2#">
                    SELECT
                        ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC - ACCOUNT_ACCOUNT_REMAINDER.ALACAK),2) AS BAKIYE, 
                        ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC),2) AS BORC,
                        ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.ALACAK),2) AS ALACAK, 
                        ACCOUNT_PLAN.ACCOUNT_CODE,
                        ACCOUNT_PLAN.ACCOUNT_NAME,
                        ACCOUNT_PLAN.ACCOUNT_ID
                    FROM
                        (
                        SELECT
                            0 AS ALACAK,
                            SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2)) AS BORC,
                            ACCOUNT_CARD_ROWS.ACCOUNT_ID		
                        FROM
                            ACCOUNT_CARD_ROWS,ACCOUNT_CARD
                        WHERE
                            BA = 0 AND ACCOUNT_CARD.CARD_ID=ACCOUNT_CARD_ROWS.CARD_ID
                            AND (ACCOUNT_CARD.CARD_TYPE = 10)
                            AND ACTION_DATE = #donem_basi#
                            <cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                 AND (ACCOUNT_CARD_ROWS.ACC_BRANCH_ID IN (#attributes.acc_branch_id#))
                            </cfif>
                        GROUP BY
                            ACCOUNT_CARD_ROWS.ACCOUNT_ID
                            <cfif isdefined('attributes.is_zero') and len(attributes.is_zero)>
                            HAVING SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2))<>0
                            </cfif>
                        UNION ALL
                        SELECT
                            SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2)) AS ALACAK,
                            0 AS BORC,
                            ACCOUNT_CARD_ROWS.ACCOUNT_ID		
                        FROM
                            ACCOUNT_CARD_ROWS,ACCOUNT_CARD
                        WHERE
                            BA = 1 AND ACCOUNT_CARD.CARD_ID=ACCOUNT_CARD_ROWS.CARD_ID
                            AND (ACCOUNT_CARD.CARD_TYPE = 10)
                            AND ACTION_DATE = #donem_basi#
                            <cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                AND (ACCOUNT_CARD_ROWS.ACC_BRANCH_ID IN (#attributes.acc_branch_id#) )
                            </cfif>
                        GROUP BY
                            ACCOUNT_CARD_ROWS.ACCOUNT_ID
                            <cfif isdefined('attributes.is_zero') and len(attributes.is_zero)>
                            HAVING SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT,2))<>0
                            </cfif>
                                
                        )
                        AS ACCOUNT_ACCOUNT_REMAINDER,
                        ACCOUNT_PLAN
                    WHERE
                       (ACCOUNT_PLAN.ACCOUNT_CODE = LEFT(ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID,3))
                    GROUP BY
                        ACCOUNT_PLAN.ACCOUNT_CODE, 
                        ACCOUNT_PLAN.ACCOUNT_NAME,
                        ACCOUNT_PLAN.ACCOUNT_ID
                    ORDER BY 
                        ACCOUNT_PLAN.ACCOUNT_CODE
                </cfquery>
            <cfelse>
            	<cfquery name="get_acilis_fisi" datasource="#donem_dsn2#">
                		SELECT     
                        	SUM(BAKIYE) AS BAKIYE, 
                            SUM(BORC) AS BORC, 
                            SUM(ALACAK) AS ALACAK, 
                            ACCOUNT_CODE, 
                            ACCOUNT_NAME, 
                            ACCOUNT_ID, 
                            SUB_ACCOUNT
						FROM         
                        	(
                            	SELECT     
                                	ACCOUNT_PLAN.SUB_ACCOUNT, 
                                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC - ACCOUNT_ACCOUNT_REMAINDER.ALACAK), 2) AS BAKIYE, 
                                  	ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.BORC), 2) AS BORC, 
                                    ROUND(SUM(ACCOUNT_ACCOUNT_REMAINDER.ALACAK), 2) AS ALACAK, 
                              		ACCOUNT_PLAN.ACCOUNT_CODE, 
                                    ACCOUNT_PLAN.ACCOUNT_NAME, 
                                    ACCOUNT_PLAN.ACCOUNT_ID
                       			FROM          
                                	(
                                    	SELECT     
                                        	0 AS ALACAK, 
                                        	SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT, 2)) AS BORC, 
                                        	ACCOUNT_CARD_ROWS.ACCOUNT_ID
                                     	FROM          
                                        	ACCOUNT_CARD_ROWS INNER JOIN
                                      		ACCOUNT_CARD ON ACCOUNT_CARD_ROWS.CARD_ID = ACCOUNT_CARD.CARD_ID
                                     	WHERE      
                                        	ACCOUNT_CARD_ROWS.BA = 0 AND 
                                            ACCOUNT_CARD.CARD_TYPE = 10 AND
                             				ACCOUNT_CARD.ACTION_DATE = #donem_basi#
                                            <cfif len(attributes.keyword1)>
                                            	AND ACCOUNT_CARD_ROWS.ACCOUNT_ID >= '#attributes.keyword1#'  
                                            </cfif>
                                            <cfif len(attributes.keyword2)>
                                            	AND ACCOUNT_CARD_ROWS.ACCOUNT_ID <= '#attributes.keyword2#'  
                                            </cfif> 
                                        	<cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                                AND (ACCOUNT_CARD_ROWS.ACC_BRANCH_ID IN (#attributes.acc_branch_id#) )
                                            </cfif>
                                            <cfif isdefined('attributes.is_closed_card') and len(attributes.is_closed_card)>
                                                AND (ISNULL(ACCOUNT_CARD.ACTION_TYPE,0) <> 172)
                                            </cfif>
                                 		GROUP BY 
                                        	ACCOUNT_CARD_ROWS.ACCOUNT_ID
                                      	<cfif isdefined('attributes.is_zero') and len(attributes.is_zero)> 
                                            HAVING      
                                                SUM(ROUND(ACCOUNT_CARD_ROWS.AMOUNT, 2)) <> 0
                                      	</cfif>
                                      	UNION ALL
                                     	SELECT     
                                        	SUM(ROUND(ACCOUNT_CARD_ROWS_1.AMOUNT, 2)) AS ALACAK, 
                                            0 AS BORC, 
                                            ACCOUNT_CARD_ROWS_1.ACCOUNT_ID
                                     	FROM         
                                        	ACCOUNT_CARD_ROWS AS ACCOUNT_CARD_ROWS_1 INNER JOIN
                                   			ACCOUNT_CARD AS ACCOUNT_CARD_1 ON ACCOUNT_CARD_ROWS_1.CARD_ID = ACCOUNT_CARD_1.CARD_ID
                                     	WHERE     
                                        	ACCOUNT_CARD_ROWS_1.BA = 1 AND 
                                            ACCOUNT_CARD_1.CARD_TYPE = 10 AND
                             				ACCOUNT_CARD_1.ACTION_DATE = #donem_basi#
                                            <cfif len(attributes.keyword1)>
                                            	AND ACCOUNT_CARD_ROWS_1.ACCOUNT_ID >= '#attributes.keyword1#'  
                                            </cfif>
                                            <cfif len(attributes.keyword2)>
                                            	AND ACCOUNT_CARD_ROWS_1.ACCOUNT_ID <= '#attributes.keyword2#'  
                                            </cfif> 
                                            <cfif isdefined('attributes.acc_branch_id') and len(attributes.acc_branch_id)>
                                                AND (ACCOUNT_CARD_ROWS_1.ACC_BRANCH_ID IN (#attributes.acc_branch_id#) )
                                            </cfif>
                                            <cfif isdefined('attributes.is_closed_card') and len(attributes.is_closed_card)>
                                                AND (ISNULL(ACCOUNT_CARD_1.ACTION_TYPE,0) <> 172)
                                            </cfif>
                                    	GROUP BY 
                                        	ACCOUNT_CARD_ROWS_1.ACCOUNT_ID
                                      	<cfif isdefined('attributes.is_zero') and len(attributes.is_zero)> 
                                            HAVING      
                                                SUM(ROUND(ACCOUNT_CARD_ROWS_1.AMOUNT, 2)) <> 0
                                      	</cfif>
                                 	) AS ACCOUNT_ACCOUNT_REMAINDER CROSS JOIN
                                  	ACCOUNT_PLAN
                      			 WHERE     
                                 	(
                                    CHARINDEX('.', ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID) > 0 AND 
                                    ACCOUNT_PLAN.SUB_ACCOUNT = 1 AND 
                                   	ACCOUNT_PLAN.ACCOUNT_CODE = LEFT(ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID,LEN(ACCOUNT_PLAN.ACCOUNT_CODE))
                                    <cfif len(attributes.keyword1)>
                                   		AND ACCOUNT_PLAN.ACCOUNT_CODE >= '#attributes.keyword1#'  
                                   	</cfif>
                                  	<cfif len(attributes.keyword2)>
                                     	AND ACCOUNT_PLAN.ACCOUNT_CODE <= '#attributes.keyword2#'  
                                  	</cfif> 
                                   	) 
                                    OR
                                    (
                                    CHARINDEX('.', ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID) = 0 AND 
                                    ACCOUNT_PLAN.ACCOUNT_CODE = LEFT(ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID,LEN(ACCOUNT_PLAN.ACCOUNT_CODE))
                                    <cfif len(attributes.keyword1)>
                                   		AND ACCOUNT_PLAN.ACCOUNT_CODE >= '#attributes.keyword1#'  
                                   	</cfif>
                                  	<cfif len(attributes.keyword2)>
                                     	AND ACCOUNT_PLAN.ACCOUNT_CODE <= '#attributes.keyword2#'  
                                  	</cfif> 
                                    ) 
                                    OR
                                   	(
                                   	LEN(ACCOUNT_PLAN.ACCOUNT_CODE) < 3 AND 
                                    ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID LIKE ACCOUNT_PLAN.ACCOUNT_CODE + '%' 
                                    <cfif len(attributes.keyword1)>
                                   		AND ACCOUNT_PLAN.ACCOUNT_CODE >= '#attributes.keyword1#'  
                                   	</cfif>
                                  	<cfif len(attributes.keyword2)>
                                     	AND ACCOUNT_PLAN.ACCOUNT_CODE <= '#attributes.keyword2#'  
                                  	</cfif> 
                                    )
                                    OR
                                    (
                                  	ACCOUNT_PLAN.ACCOUNT_CODE = ACCOUNT_ACCOUNT_REMAINDER.ACCOUNT_ID
                                    <cfif len(attributes.keyword1)>
                                   		AND ACCOUNT_PLAN.ACCOUNT_CODE >= '#attributes.keyword1#'  
                                   	</cfif>
                                  	<cfif len(attributes.keyword2)>
                                     	AND ACCOUNT_PLAN.ACCOUNT_CODE <= '#attributes.keyword2#'  
                                  	</cfif> 
                                    )
                       			GROUP BY ACCOUNT_PLAN.ACCOUNT_CODE, 
                                    ACCOUNT_PLAN.ACCOUNT_NAME, 
                                    ACCOUNT_PLAN.ACCOUNT_ID, 
                                    ACCOUNT_PLAN.SUB_ACCOUNT
                      		) AS T1
						GROUP BY 
                        	ACCOUNT_CODE, 
                            ACCOUNT_NAME, 
                            ACCOUNT_ID, 
                            SUB_ACCOUNT
						ORDER BY 
                        	ACCOUNT_CODE
                </cfquery>
            </cfif>
        </cfif>
        <cfif check_period.recordcount>
			<cfif get_acilis_fisi.recordcount>
                <cfoutput query="get_acilis_fisi">
                	<cfif attributes.report_type neq 10> <!---Detaylı Mizan Değilse--->
                    	<cfset 'BAKIYE_#ACCOUNT_CODE#' = BAKIYE>
                    <cfelse>
                    	<cfset 'BAKIYE_#ACCOUNT_ID#' = BAKIYE>
                    </cfif>
                    <cfif isdefined('TOPLAM_')>
                      	<cfset TOPLAM_ = TOPLAM_ + BAKIYE>
                   	<cfelse>
                     	<cfset TOPLAM_ = BAKIYE>
                  	</cfif>
                </cfoutput>
            </cfif> 
		<cfelse>
        	<cfloop query="get_account_name">
            	<cfif attributes.report_type neq 10> <!---Detaylı Mizan Değilse--->
            		<cfset 'BAKIYE_#ACCOUNT_CODE#' = 0>
              	<cfelse>
                   <cfset 'BAKIYE_#ACCOUNT_ID#' = 0> 
                </cfif>
            </cfloop>
        </cfif>
        <cfloop query="get_account_name">
           	<cfloop from="#sene1#" to="#sene2#" index="ii">
              	<cfloop from="1" to="#period_say#" index="i">
                	<cfif attributes.report_type neq 10> <!---Detaylı Mizan Değilse--->
						<cfif isdefined('BAKIYE_#i#_#ii#_#get_account_name.ACCOUNT_CODE#') and 'BAKIYE_#i#_#ii#_#get_account_name.ACCOUNT_CODE#' neq 0>
                            <cfset 'SIFIR_#get_account_name.ACCOUNT_CODE#' = 1> 
                        <cfelse>
                            <cfset 'BAKIYE_#i#_#ii#_#get_account_name.ACCOUNT_CODE#' = 0>
                        </cfif>
                    <cfelse>
                    	<cfif isdefined('BAKIYE_#i#_#ii#_#get_account_name.ACCOUNT_ID#') and 'BAKIYE_#i#_#ii#_#get_account_name.ACCOUNT_ID#' neq 0>
                            <cfset 'SIFIR_#get_account_name.ACCOUNT_ID#' = 1> 
                        <cfelse>
                            <cfset 'BAKIYE_#i#_#ii#_#get_account_name.ACCOUNT_ID#' = 0>
                        </cfif>
                    </cfif>
                </cfloop>
            </cfloop>
            <cfif attributes.report_type neq 10> <!---Detaylı Mizan Değilse--->
				<cfset 'ACCOUNT_NAME_#ACCOUNT_CODE#' = ACCOUNT_NAME>
                <cfset 'ACCOUNT_ID_#ACCOUNT_CODE#' = ACCOUNT_ID>
            <CFELSE>
            	<cfset 'ACCOUNT_NAME_#ACCOUNT_ID#' = ACCOUNT_NAME>
                <cfset 'ACCOUNT_CODE_#ACCOUNT_ID#' = ACCOUNT_CODE>
            </cfif>
        </cfloop>
       	<cfif isdefined('attributes.report_type')>
        	<cfif listfind(attributes.report_type,1)> 
              	<cfinclude template="yeminli_rapor_bilanco.cfm">
            </cfif>
        	<cfif listfind(attributes.report_type,9)> 
              	<cfinclude template="yeminli_rapor_bilanco.cfm">
            </cfif>     
          	<cfif listfind(attributes.report_type,2)>      
       			<cfinclude template="yeminli_rapor_stok.cfm">
           	</cfif>     
        	<cfif listfind(attributes.report_type,3)> 
				<cfinclude template="yeminli_rapor_gelir.cfm">
       		</cfif>
            <cfif listfind(attributes.report_type,4)> 
				<cfinclude template="yeminli_rapor_bilanco.cfm">
       		</cfif>
            <cfif listfind(attributes.report_type,5)> 
				<cfinclude template="yeminli_rapor_bilanco.cfm">
       		</cfif>
            <cfif listfind(attributes.report_type,6)> 
				<cfinclude template="yeminli_rapor_gelir.cfm">
       		</cfif>
            <cfif listfind(attributes.report_type,7)> 
				<cfinclude template="yeminli_rapor_gelir.cfm">
       		</cfif>
            <cfif listfind(attributes.report_type,8)> 
				<cfinclude template="yeminli_rapor_rasyo.cfm">
       		</cfif>
            <cfif listfind(attributes.report_type,10)> 
				<cfinclude template="detay_mizan.cfm">
       		</cfif>
        </cfif>    
	<cfelse>
		<cfif not(isdefined('attributes.is_excel') and attributes.is_excel eq 1)>
			<table cellpadding="1" cellspacing="1" border="0" width="98%" align="center" class="color-border">
				<tr class="color-list" height="20">
					<td class="txtbold"><cf_get_lang_main no ='72.Kayıt Yok'>!</td>
				</tr>				
			</table>
		</cfif>
	</cfif>
</cfif>
<cfif not(isdefined('attributes.is_excel') and attributes.is_excel eq 1)>
	<br>
	<script type="text/javascript">
	function show_check_date()
	{
		if(document.getElementById('list_type').value == 3)//Aylık Seçilmişse
			document.getElementById('check_type_').style.display = 'none';
		else
			document.getElementById('check_type_').style.display = '';
	}
	function tarih_kontrolu()
	{
		if( document.form.date1.value>document.form.date2.value && document.form.list_type.value != 3)
		{
		alert("Başlangıç Tarihi Bitiş Tarihinden Büyük Olamaz!");
		return false;
		}
		if( document.form.date2.value-document.form.date1.value>=5 && document.form.list_type.value == 1)
		{
		alert("Yıllık Raporda Fark 5 Yıldan Fazla Olamaz!");
		return false;
		}
		if( document.form.date2.value-document.form.date1.alue>=2 && document.form.list_type.value == 2)
		{
		alert("Üç Aylık Rapor 2 Yıldan Fazla Alınamaz!");
		return false;
		}
	}
	</script>
</cfif>