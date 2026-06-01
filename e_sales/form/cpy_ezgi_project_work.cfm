<cfset module_name="project">
<cfparam name="attributes.import_type" default="1">
<cfquery name="get_transfer_control" datasource="#dsn#">
	SELECT WORK_ID FROM PRO_WORKS WHERE PROJECT_ID = #attributes.main_project_id#
</cfquery>
<cfif get_transfer_control.recordcount>
	<script type="text/javascript">
     	alert("Projeye Daha Önce Transfer Yapılmıştır. İkinci Kez veya İlave Transfer Yapılamaz!");
  		window.close()
 	</script>
	<cfabort>
</cfif>
<cfquery name="GET_PROCURRENCY" datasource="#DSN#">
	SELECT
		PTR.PROCESS_ID,
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%project.works%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfquery name="process" datasource="#DSN#">
	SELECT PROCESS_ID,WORK_CAT_ID FROM PRO_WORK_CAT
</cfquery>
<cfif not ((isdefined("attributes.project_id") and len(attributes.project_id)) or (isdefined("attributes.uploaded_file") and len(attributes.uploaded_file)))>
    <cf_popup_box title="#getLang('project',319)#">
    <cfform name="search_project" id="search_project" enctype="multipart/form-data" method="post" action="">
        <table>
            <tr valign="top">
                <td>
                    <table border="0" cellpadding="2" cellspacing="2">
                        <tr id="form_ul_project" style="display:">
                        	<td width="120">Aktarım Türü</td>
                        	<td width="220">
                                <select name="import_type" id="import_type" style="width:200px; height:20px" onchange="project_gizle()">
                                	<option value="1" <cfif attributes.import_type eq 1>selected</cfif>>Proje Aktarım</option>
                                    <option value="2" <cfif attributes.import_type eq 2>selected</cfif>>Sonuç Aktarım</option>
                                </select>
                            </td>
                       	</tr>
                        <tr id="project_row">
                            <td>
                                <input type="hidden" name="is_page" id="is_page" value="" checked="checked">
                                <input type="hidden" name="main_project_id" id="main_project_id" value="<cfoutput>#url.main_project_id#</cfoutput>">
                                <cf_get_lang_main no='4.Proje'>
                            </td>
                            <td nowrap>
                                <input type="hidden" name="project_id" id="project_id" value="">
                                <input type="text" name="project_head" id="project_head" value="" onchange="delete_1();" onfocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','list_works','3','250');"  autocomplete="off" style="width:200px;" />
                                <a href="javascript://" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_list_projects&project_head=search_project.project_head&project_id=search_project.project_id</cfoutput>');"><img src="/images/plus_thin.gif" title="<cf_get_lang dictionary_id='58797.Proje Seçiniz'>" align="absmiddle" border="0"></a>
                            </td>
                        </tr>
                        <tr>
                            <td><cf_get_lang_main no='56.Belge'></td>
                            <td><input type="file" name="uploaded_file" id="uploaded_file" style="width:210px;" onfocus=""></td>
                        </tr>
                    </table>
                </td>
                <td>
                    <table>
                        <tr id="form_ul_help_file_work" >
                            <td>
                               
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <cf_popup_box_footer>
        	<cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol_1()'>
      	</cf_popup_box_footer>
    </cfform>
    </cf_popup_box>
	<script type="text/javascript">
		function kontrol_1()
		{
			if(document.getElementById('import_type').value==1)
			{
				if(document.getElementById('project_id').value == "" || document.getElementById('project_head').value== "")
				{
					alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='4.Proje'>");
					return false;
				}
			}
			if(document.getElementById('uploaded_file').value == "")
			{
				alert("<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no='279.Dosya'>");
				return false;
			}
			else
				return true;
		}
		function delete_1()
		{
			document.getElementById('project_id').value='';
		}
		function project_gizle()
		{
			if(document.getElementById('import_type').value==1)
				document.getElementById('project_row').style.display='';
			else
				document.getElementById('project_row').style.display='none';	
		}
	</script>
<cfelseif isdefined("attributes.uploaded_file") and len(attributes.uploaded_file)>
	<cfset upload_folder = "#upload_folder#temp#dir_seperator#">
    <cfif attributes.import_type eq 1><!--- Proje Aktarımı Yapılacaksa--->
    
        <cftry>
            <cffile action = "upload" 
                    fileField = "uploaded_file" 
                    destination = "#upload_folder#"
                    nameConflict = "MakeUnique"  
                    mode="777">
            <cfif cffile.serverfileext eq 'xlsm' or cffile.serverfileext eq 'xlsx'>
            
            <cfelse>
                <script type="text/javascript">
                    alert("<cfoutput>#getLang('main',2947)# XLSM</cfoutput>.");
                    history.back();
                </script>
                <cfabort>
            </cfif>
            <cfset file_name = "#createUUID()#.#cffile.serverfileext#">	
            <cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#">	
            <cfset file_size = cffile.filesize>
            <cfcatch type="Any">
                    <cfoutput>#cfcatch.detail#</cfoutput>
                <cfabort>
            </cfcatch>  
        </cftry>
    
        <cftry>
            <cfspreadsheet action="read" src="#upload_folder##file_name#" query="project_works_row" sheetname ="IMPORT" rows="2-10000">
            <cfcatch>
                <script type="text/javascript">
                    alert("<cfoutput>#getLang('ehesap',1112)#</cfoutput>.");
                    history.back();
                </script>
                <cfabort>
            </cfcatch>
        </cftry>
        <cfif not project_works_row.recordcount>
            <script type="text/javascript">
                alert("IMPORT sekmesinde Kayıt Yoktur");
                window.close()
            </script>
            <cfabort>
        </cfif>
        <cfset pro_work_id_list = ''>
        <cfloop query="project_works_row">
            <cfif not len(col_1)>
                <script type="text/javascript">
                    alert("<cfoutput>#currentrow#.Satır 1.Kolon Boştur.</cfoutput>");
                    window.close()
                </script>
                <cfabort>
            <cfelse>
                <cfquery name="get_special_id" datasource="#dsn#">
                    SELECT     
                        SPECIAL_DEFINITION, 
                        SPECIAL_DEFINITION_ID
                    FROM      
                        SETUP_SPECIAL_DEFINITION
                    WHERE     
                        SPECIAL_DEFINITION_TYPE = 7 AND
                        SPECIAL_DEFINITION = '#col_1#'
                </cfquery>
                <cfif not get_special_id.recordcount>
                    <script type="text/javascript">
                        alert("<cfoutput>#currentrow#.Satır 1.Kolondaki #col_1# bilgisi Özel Tanımlar Dosyasında Tanımlı Değildir.</cfoutput>");
                        window.close()
                    </script>
                    <cfabort>
                </cfif>
                <cfquery name="get_old_pro_work" datasource="#dsn#">
                    SELECT     
                        WORK_ID 
                    FROM      
                        PRO_WORKS
                    WHERE     
                        PROJECT_ID = #attributes.main_project_id# AND 
                        SPECIAL_DEFINITION_ID = #get_special_id.SPECIAL_DEFINITION_ID#
                </cfquery>
                <cfif get_old_pro_work.recordcount>
                    <script type="text/javascript">
                        alert("<cfoutput>#currentrow#.Satır 1.Kolondaki #col_1# Özel Tanımı ile Daha Önce Transfer Yapılmış Satır Mevcut.</cfoutput>");
                        window.close()
                    </script>
                    <cfabort>
                </cfif>
                <cfquery name="get_pro_work" datasource="#dsn#">
                    SELECT     
                        WORK_ID 
                    FROM      
                        PRO_WORKS
                    WHERE     
                        PROJECT_ID = #attributes.project_id# AND 
                        SPECIAL_DEFINITION_ID = #get_special_id.SPECIAL_DEFINITION_ID#
                </cfquery>
                <cfif not get_pro_work.recordcount>
                    <script type="text/javascript">
                        alert("<cfoutput>#currentrow#.Satır 1.Kolondaki #col_1# Özel Tanımı ile İş Tanımı Yapılmamış.</cfoutput>");
                        window.close()
                    </script>
                    <cfabort>
                </cfif>
            </cfif>
            <cfif not len(col_2) or not isnumeric(col_2)>
                <script type="text/javascript">
                    alert("<cfoutput>#currentrow#.Satır 2.Kolon Boş veya Alfa Nümerik Bilgi İçermektedir.</cfoutput>");
                    window.close()
                </script>
                <cfabort>
            </cfif>
            <cfif not len(col_3) or not isnumeric(col_3)>
                <script type="text/javascript">
                    alert("<cfoutput>#currentrow#.Satır 3.Kolon Boş veya Alfa Nümerik Bilgi İçermektedir.</cfoutput>");
                    window.close()
                </script>
                <cfabort>
            </cfif>
            <cfset pro_work_id_list = ListAppend(pro_work_id_list,get_pro_work.WORK_ID)>
            <cfset 'work_id_#currentrow#' = col_1>
            <cfset 'miktar_#currentrow#' = col_2>
            <cfset 'fiyat_#currentrow#' = col_3>
        </cfloop>
        
        <cfquery name="GET_PRO_PROJECTS" datasource="#DSN#">
            SELECT PROJECT_HEAD, TARGET_FINISH,TARGET_START,TARGET_FINISH,PARTNER_ID,COMPANY_ID FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.main_project_id#
        </cfquery>
        <cfscript>
            sdate=date_add('h', session.ep.time_zone, GET_PRO_PROJECTS.target_start);
            fdate=date_add('h', session.ep.time_zone, GET_PRO_PROJECTS.target_finish);
        </cfscript>	
        
        <cfinclude template="/V16/PROJECT/query/get_priority.cfm">
        <cfinclude template="/V16/PROJECT/query/get_pro_work_cat.cfm">
        <cfset project_stage_list = "">
        <cfif listlen(project_stage_list)>
            <cfset project_stage_list = listsort(project_stage_list,'numeric','ASC',',')>
            <cfquery name="get_currency_name" datasource="#dsn#">
                SELECT PROCESS_ROW_ID,STAGE FROM PROCESS_TYPE_ROWS WHERE PROCESS_ROW_ID IN (#project_stage_list#) ORDER BY PROCESS_ROW_ID
            </cfquery>
        </cfif>
    
        <table width="98%" align="center">
            <tr>
                <td height="35" class="headbold" colspan="6">
                    <cf_get_lang no='93.Is'> <cf_get_lang_main no='64.Kopyala'>(<cf_get_lang_main no='4.Proje'> : <cfoutput>#GET_PRO_PROJECTS.project_head#</cfoutput>)
                </td>
            </tr>
        </table>
        <table cellspacing="1" cellpadding="2" border="0" width="98%" class="color-border" align="center">
            <cfform name="cpy_project_work" method="post" action="#request.self#?fuseaction=project.emptypopup_cpy_ezgi_project_work">
                <tr class="color-header" height="22">
                    <td class="form-title" style="width:30px;">
                    	<input type="hidden" name="import_type" value="<cfoutput>#attributes.import_type#</cfoutput>">
                        <input type="hidden" name="main_project_id" id="main_project_id" value="<cfoutput>#attributes.main_project_id#</cfoutput>">
                        <input type="hidden" name="project_id" id="project_id" value="<cfoutput>#attributes.project_id#</cfoutput>">
                        <input type="hidden" name="record_num" id="record_num" value="<cfoutput>#ListLen(pro_work_id_list)#</cfoutput>">
                        <input type="hidden" name="p_sdate" id="p_sdate" value="<cfoutput>#dateformat(get_pro_projects.target_start,dateformat_style)#</cfoutput>">
                        <input type="hidden" name="p_fdate" id="p_fdate" value="<cfoutput>#dateformat(get_pro_projects.target_finish,dateformat_style)#</cfoutput>">
                        <cfif ListLen(pro_work_id_list)><input type="checkbox" name="all_work" id="all_work" value="1" onclick="hepsini_sec();" checked></cfif>
                    </td>
                    <td class="form-title" style="width:20px;"><cf_get_lang_main no='75.No'></td>
                    <td class="form-title"><cf_get_lang_main no='68.Başlık'></td>
                    <td class="form-title" style="width:170px;"><cf_get_lang_main no='157.Görevli'></td>
                    <td class="form-title" style="width:100px;"><cf_get_lang_main no='73.Öncelik'></td>
                    <td class="form-title" style="width:70px;"><cf_get_lang_main no='223.Miktar'></td>
                    <td class="form-title" style="width:90px;"><cf_get_lang_main no='226.Birim Fiyat'></td>
                    <td class="form-title" style="width:100px;"><cf_get_lang_main no='70.Aşama'></td>
                    <td class="form-title" style="width:150px;"><cf_get_lang_main no='74.Kategori'></td>
                </tr>
                <cfif ListLen(pro_work_id_list)>
                    <cfset uzunluk = Listlen(pro_work_id_list)>
                    <cfloop from="1" to="#uzunluk#" index="crow">
                        <cfset w_id = ListGetAt(pro_work_id_list,crow)>
                        <cfquery name="GET_PRO_WORKS" datasource="#DSN#">
                            SELECT
                                 CASE 
                                    WHEN IS_MILESTONE = 1 THEN WORK_ID
                                    WHEN IS_MILESTONE <> 1 THEN ISNULL(MILESTONE_WORK_ID,0)
                                END AS NEW_WORK_ID,
                                CASE 
                                    WHEN IS_MILESTONE = 1 THEN 0
                                    WHEN IS_MILESTONE <> 1 THEN 1
                                END AS TYPE,
                                *
                            FROM
                                PRO_WORKS
                            WHERE
                                PROJECT_ID = #attributes.project_id# AND
                                WORK_ID = #w_id#
                        </cfquery>
                        <cfif get_pro_works.recordcount>
                            <cfoutput query="get_pro_works">
                                <input type="hidden" name="work_h_start#crow#" id="work_h_start#crow#" value="#dateformat(sdate,dateformat_style)#" >
                                <input type="hidden" name="work_h_finish#crow#" id="work_h_finish#crow#" value="#dateformat(fdate,dateformat_style)#">
                                <tr id="frm_row#crow#" onmouseover="this.className='color-light';" onmouseout="this.className='color-row';" class="color-row">
                                    <td style="width:20px;">
                                    	<input type="hidden" name="special_defination_id#crow#" id="special_defination_id#crow#" value="#SPECIAL_DEFINITION_ID#">
                                        <input type="hidden" name="work_id#crow#" id="work_id#crow#" value="#work_id#">
                                        <input type="hidden" name="related_work_id#crow#" id="related_work_id#crow#" value="#related_work_id#">
                                        <input type="hidden" name="our_company_id#crow#" id="our_company_id#crow#" value="#our_company_id#" />
                                        <input type="checkbox" name="work_select#crow#" id="work_select#crow#" checked>
                                        <input type="hidden" name="purchase_contract_amount#crow#" id="purchase_contract_amount#crow#" value="#purchase_contract_amount#">
                                        
                                        <input type="hidden" name="sale_contract_amount#crow#" id="sale_contract_amount#crow#" value="#sale_contract_amount#">
                                        <input type="hidden" name="workgroup_id_#crow#" id="workgroup_id#crow#" value="#workgroup_id#">
                                    </td>
                                    <td>#crow#</td>
                                    <td><input type="text" class="boxtext" name="work_head#crow#" id="work_head#crow#" <cfif type eq 0>style="color:red;font-weight:bold;width:250px;"<cfelse>style="width:100%;"</cfif> maxlength="100" value='<cfif type eq 0>(M) #work_head#<cfelse>&nbsp;&nbsp;&nbsp;#work_head#</cfif>'></td>
                                    <td>
                                        <cfif get_pro_works.project_emp_id neq 0 and len(get_pro_works.project_emp_id)>
                                            <cfset person="#get_emp_info(get_pro_works.project_emp_id,0,0)#">
                                        <cfelseif get_pro_works.outsrc_partner_id neq 0 and len(get_pro_works.outsrc_partner_id)>
                                            <cfset person="#get_par_info(get_pro_works.outsrc_partner_id,0,0,0)#">
                                        <cfelse>
                                            <cfset person="">
                                        </cfif>
                                        <input type="hidden" name="task_company_id#crow#" id="task_company_id#crow#" value="#get_pro_works.outsrc_cmp_id#">
                                        <input type="hidden" name="task_partner_id#crow#" id="task_partner_id#crow#" value="#get_pro_works.outsrc_partner_id#">
                                        <input type="hidden" name="project_emp_id#crow#" id="project_emp_id#crow#" value="#get_pro_works.project_emp_id#">
    
                                        <input type="text" class="boxtext" name="responsable_name#crow#" id="responsable_name#crow#" value="#person#" onfocus="AutoComplete_Create('responsable_name#crow#','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'1,2,3\'','EMPLOYEE_ID,COMPANY_ID,PARTNER_ID','project_emp_id#crow#,task_company_id#crow#,task_partner_id#crow#','cpy_project_work',3,'150')" style="width:140px;">
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_list_positions&field_partner=cpy_project_work.task_partner_id#crow#&field_comp_id=cpy_project_work.task_company_id#crow#&field_emp_id=cpy_project_work.project_emp_id#crow#&field_name=cpy_project_work.responsable_name#crow#&field_comp_name=cpy_project_work.responsable_name#crow#&select_list=1,7','list');"><img src="/images/plus_thin.gif" title="<cf_get_lang no='81.Görevli Seç'>" align="absmiddle" border="0"></a>
                                    </td>
                                    <td>
                                        <select name="priority_cat#crow#" id="priority_cat#crow#" style="width:100px;">
                                            <cfloop query="get_cats">
                                                <option value="#priority_id#" <cfif get_pro_works.work_priority_id is priority_id>selected</cfif>>#priority#</option>
                                            </cfloop>
                                        </select>
                                    </td>
                                    <td style="text-align:right">
                                        <input type="text" name="miktar_#crow#" value="#TlFormat(Evaluate('miktar_#crow#'))#" style="width:70px; text-align:right">
                                    </td>
                                    <td style="text-align:right">
                                        <input type="text" name="fiyat_#crow#" value="#TlFormat(Evaluate('fiyat_#crow#'))#" style="width:90px; text-align:right">
                                    </td>
                                    <td>
                                        <!---<cfif xml_is_stage_cat>--->
                                            <cfquery name="process_" dbtype="query">
                                                SELECT PROCESS_ID FROM process WHERE WORK_CAT_ID = #get_pro_works.work_cat_id#
                                            </cfquery>
                                            <cfif process_.recordcount and len(process_.PROCESS_ID)>
                                                <cfquery name="get_procurrency_" dbtype="query">
                                                    SELECT * FROM get_procurrency WHERE PROCESS_ROW_ID IN (#process_.PROCESS_ID#)
                                                </cfquery>
                                            </cfif>
                                        <!---</cfif>--->
                                        <select name="work_currency_id#crow#" id="work_currency_id#crow#" style="width:120px; height:17px;">
                                            <option value=""><cf_get_lang_main no='70.Asama'></option>
                                            <cfif isdefined("get_procurrency_")>
                                                <cfloop query="get_procurrency_">
                                                    <option value="#PROCESS_ROW_ID#" <cfif get_pro_works.work_currency_id eq PROCESS_ROW_ID>selected</cfif>>#STAGE#</option>
                                                </cfloop>
                                            <cfelse>
                                                <cfloop query="get_procurrency">
                                                    <option value="#PROCESS_ROW_ID#" <cfif get_pro_works.work_currency_id eq PROCESS_ROW_ID>selected</cfif>>#STAGE#</option>
                                                </cfloop>
                                            </cfif>
                                        </select>
                                    </td> 
                                    <td><select name="pro_work_cat#crow#" id="pro_work_cat#crow#" style="width:140px;">
                                            <cfloop query="get_work_cat">
                                                <option value="#work_cat_id#"<cfif get_pro_works.work_cat_id eq work_cat_id>selected</cfif>>#work_cat#</option>
                                            </cfloop>
                                        </select>			
                                    </td>
    
                                </tr>
                            </cfoutput>
                        </cfif>
                    </cfloop>
                    <tr class="color-row">
                        <td colspan="9"><cf_workcube_buttons is_upd='0' add_function='kontrol()'></td>
                    </tr>  
                <cfelse>
                    <tr class="color-row">
                        <td colspan="9"><cf_get_lang_main no='72.Kayıt Yok'> !</td>
                    </tr>
                </cfif>
            </cfform>
        </table>
 		<script type="text/javascript">
			function kontrol()
			{
				debugger;
				row_count = document.cpy_project_work.record_num.value;
				if(row_count == 0)
				{
					alert("<cf_get_lang no ='318.Seçilen Projede İş Kaydı Bulunmamaktadır'> !");
					return false;
				}
				if(row_count != 0)
				{
					for(i=1;i<=row_count;i++)
					{	
						deger_work_select = eval("document.cpy_project_work.work_select"+i);
						deger_work_head = eval("document.cpy_project_work.work_head"+i);
						deger_work_currency = eval("document.cpy_project_work.work_currency_id"+i);	
						if(deger_work_select.checked==true)
						{
							if(deger_work_head.value == "")
							{
								alert (i + ".<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no ='1408.Başlık'>");
								return false;
							}
			
							if (deger_work_currency.value == "")
							{
								alert (i + ".<cf_get_lang_main no='59.Eksik Veri'> : <cf_get_lang_main no ='70.Aşama'>");
								return false;
							}
							kontrol_++;			
						}						
					}
					document.getElementById("cpy_project_work").submit();
					return true;
				}
				
			}
			function hepsini_sec()
			{	
				if (document.cpy_project_work.all_work.checked)
				{
					<cfoutput query="get_pro_works">
					  document.cpy_project_work.work_select#crow#.checked = true;
					</cfoutput>
				}

				else
				{
					<cfoutput query="get_pro_works">
					  document.cpy_project_work.work_select#crow#.checked = false;
					</cfoutput>
				}
			}
		</script>
 	<cfelse><!--- Sonuç Aktarımı Yapılacaksa--->
    	<cftry>
            <cffile action = "upload" 
                    fileField = "uploaded_file" 
                    destination = "#upload_folder#"
                    nameConflict = "MakeUnique"  
                    mode="777">
            <cfif cffile.serverfileext eq 'xlsx' or cffile.serverfileext eq 'xlsm'>
            <cfelse>
                <script type="text/javascript">
                    alert("<cfoutput>#getLang('main',2947)# XLSX - XLSM</cfoutput>.");
                    history.back();
                </script>
                <cfabort>
            </cfif>
            <cfset file_name = "#createUUID()#.#cffile.serverfileext#">	
            <cffile action="rename" source="#upload_folder##cffile.serverfile#" destination="#upload_folder##file_name#">	
            <cfset file_size = cffile.filesize>
            <cfcatch type="Any">
                    <cfoutput>#cfcatch.detail#</cfoutput>
                <cfabort>
            </cfcatch>  
        </cftry>
    
        <cftry>
            <cfspreadsheet action="read" src="#upload_folder##file_name#" query="project_works_row_1" rows="2-10000">
            <cfcatch>
                <script type="text/javascript">
                    alert("<cfoutput>#getLang('ehesap',1112)#</cfoutput>.");
                    history.back();
                </script>
                <cfabort>
            </cfcatch>
        </cftry>
        <cfif not project_works_row_1.recordcount>
            <script type="text/javascript">
                alert("Sonuç Aktarım Dosyasında Kayıt Yoktur");
                window.close()
            </script>
            <cfabort>
        </cfif>
        <cfquery name="project_works_row" dbtype="query">
        	SELECT * FROM  project_works_row_1 ORDER BY col_1
        </cfquery>
        <cfset pro_work_id_list = ''>
        <!---<cfdump var="#project_works_row#">--->
        <cfloop query="project_works_row">
            <cfif not len(col_1)>
                <script type="text/javascript">
                    alert("<cfoutput>#currentrow#.Satır 1.Kolon Boştur.</cfoutput>");
                    window.close()
                </script>
                <cfabort>
            <cfelse>
                <cfquery name="get_special_id" datasource="#dsn#">
                    SELECT     
                        SPECIAL_DEFINITION, 
                        SPECIAL_DEFINITION_ID
                    FROM      
                        SETUP_SPECIAL_DEFINITION
                    WHERE     
                        SPECIAL_DEFINITION_TYPE = 7 AND
                        SPECIAL_DEFINITION = '#col_1#'
                </cfquery>
                <cfif not get_special_id.recordcount>
                    <script type="text/javascript">
                        alert("<cfoutput>#currentrow#.Satır 1.Kolondaki #col_1# bilgisi Özel Tanımlar Dosyasında Tanımlı Değildir.</cfoutput>");
                        window.close()

                    </script>
                    <cfabort>
                </cfif>
                <cfquery name="get_pro_work" datasource="#dsn#">
                    SELECT     
                        WORK_ID
                    FROM      
                        PRO_WORKS
                    WHERE     
                        PROJECT_ID = #attributes.main_project_id# AND 
                        SPECIAL_DEFINITION_ID = #get_special_id.SPECIAL_DEFINITION_ID#
                </cfquery>
                <cfif not get_pro_work.recordcount>
                    <script type="text/javascript">
                        alert("<cfoutput>#currentrow#.Satır 1.Kolondaki #col_1# Özel Tanımı ile İş Tanımı Yapılmamış.</cfoutput>");
                        window.close()
                    </script>
                    <cfabort>
                </cfif>

            </cfif>
            <cfif not len(col_2) or col_2 lte 0 or not isnumeric(col_2)>
                <script type="text/javascript">
                    alert("<cfoutput>#currentrow#.Satır 2.Kolon Boş veya Negatiftir.</cfoutput>");
                    window.close()
                </script>
                <cfabort>
            </cfif>
            <cfset 'miktar_#currentrow#' = col_2>
            <cfset pro_work_id_list = ListAppend(pro_work_id_list,get_pro_work.WORK_ID)>
        </cfloop>
        <cfquery name="GET_PRO_PROJECTS" datasource="#DSN#">
            SELECT PROJECT_HEAD, TARGET_FINISH,TARGET_START,TARGET_FINISH,PARTNER_ID,COMPANY_ID FROM PRO_PROJECTS WHERE PROJECT_ID = #attributes.main_project_id#
        </cfquery>
        <table width="98%" align="center">
            <tr>
                <td height="35" class="headbold" colspan="6">
                    <cf_get_lang no='93.Is'> <cf_get_lang_main no='64.Kopyala'>(<cf_get_lang_main no='4.Proje'> : <cfoutput>#GET_PRO_PROJECTS.project_head#</cfoutput>)
                </td>
            </tr>
        </table>
        <table cellspacing="1" cellpadding="2" border="0" width="98%" class="color-border" align="center">
            <cfform name="cpy_project_work" method="post" action="#request.self#?fuseaction=project.emptypopup_cpy_ezgi_project_work">
            	<thead>
                <tr class="color-header" height="22">
                    <th class="form-title" style="width:30px;">
                    	<input type="hidden" name="pro_work_id_list" value="<cfoutput>#pro_work_id_list#</cfoutput>">
                    	<input type="hidden" name="import_type" value="<cfoutput>#attributes.import_type#</cfoutput>">
                        <input type="hidden" name="main_project_id" id="main_project_id" value="<cfoutput>#attributes.main_project_id#</cfoutput>">
                        <input type="hidden" name="project_id" id="project_id" value="<cfoutput>#attributes.project_id#</cfoutput>">
                        <input type="hidden" name="record_num" id="record_num" value="<cfoutput>#ListLen(pro_work_id_list)#</cfoutput>">
                        <input type="hidden" name="p_sdate" id="p_sdate" value="<cfoutput>#dateformat(get_pro_projects.target_start,dateformat_style)#</cfoutput>">
                        <input type="hidden" name="p_fdate" id="p_fdate" value="<cfoutput>#dateformat(get_pro_projects.target_finish,dateformat_style)#</cfoutput>">
                        <cfif ListLen(pro_work_id_list)><input type="checkbox" name="all_work" id="all_work" value="1" onclick="hepsini_sec();" checked></cfif>
                    </th>
                    <th class="form-title" style="width:20px;"><cf_get_lang_main no='75.No'></th>
                    <th class="form-title"><cf_get_lang_main no='68.Başlık'></th>
                    <th class="form-title" style="width:190px;"><cf_get_lang_main no='157.Görevli'></th>
                    <th class="form-title" style="width:90px;">Toplam <cf_get_lang_main no='223.Miktar'></th>
                    <th class="form-title" style="width:120px;">Hakedilen Miktar</th>
                    <th class="form-title" style="width:120px;"><cf_get_lang_main no='226.Birim Fiyat'></th>
                    <th class="form-title" style="width:120px;">Hakediş Tutarı</th>
                    <th class="form-title" style="width:80px;">Oran (%)</th>
                </tr>
                </thead>
                <cfif ListLen(pro_work_id_list)>
                 	<cfquery name="GET_PRO_WORKS" datasource="#DSN#">
                            SELECT
                                *
                            FROM
                                PRO_WORKS
                            WHERE
                                PROJECT_ID = #attributes.main_project_id# AND
                                WORK_ID IN (#pro_work_id_list#)
                          	ORDER BY
                            	WORK_HEAD
                  	</cfquery>
                    <!---<cfdump var="#GET_PRO_WORKS#">--->

                	<cfif get_pro_works.recordcount>
                      	<cfoutput query="get_pro_works">
                                <tr id="frm_row#currentrow#" onmouseover="this.className='color-light';" onmouseout="this.className='color-row';" class="color-row">
                                    <td style="width:20px;"><input type="checkbox" name="work_select#currentrow#" id="work_select#currentrow#" checked></td>
                                    <td>#currentrow#</td>
                                    <td>&nbsp;&nbsp;&nbsp;#work_head#</td>
                                    <td></td>
                                   	<td style="text-align:right">#TlFormat(AVERAGE_AMOUNT)#</td>
                                    <td style="text-align:right">
                                        <input type="text" name="miktar_#currentrow#" value="#TlFormat(Evaluate('miktar_#currentrow#'))#" style="width:70px; text-align:right;<cfif Evaluate('miktar_#currentrow#') gt AVERAGE_AMOUNT>color:red</cfif>">
                                    </td>
                                    <td style="text-align:right">#TlFormat(SALE_CONTRACT_AMOUNT,2)#</td>
                                    <td style="text-align:right"><cfif isdefined('miktar_#currentrow#')>#TlFormat(Evaluate('miktar_#currentrow#')*SALE_CONTRACT_AMOUNT,2)#<cfelse>0</cfif></td>
                                    <td style="text-align:center"><cfif isdefined('miktar_#currentrow#')>#TlFormat((Evaluate('miktar_#currentrow#')/AVERAGE_AMOUNT)*100,0)#<cfelse>0</cfif></td>
                                    <cfif isdefined('miktar_#currentrow#')>
                                    	<cfinput type="hidden" name="oran_#currentrow#" value="#TlFormat((Evaluate('miktar_#currentrow#')/AVERAGE_AMOUNT)*100,0)#">
                                    <cfelse>
                                    	<cfinput type="hidden" name="oran_#currentrow#" value="0">
                                    </cfif>
                                </tr>
                     	</cfoutput>
                  	</cfif>
                    
                    <tr class="color-row">
                        <td colspan="9"><cf_workcube_buttons is_upd='0' add_function='kontrol()'></td>
                    </tr>  
                <cfelse>
                    <tr class="color-row">
                        <td colspan="9"><cf_get_lang_main no='72.Kayıt Yok'> !</td>
                    </tr>
                </cfif>
            </cfform>
        </table>
        <script type="text/javascript">
			function kontrol()
			{
				debugger;
				row_count = document.cpy_project_work.record_num.value;
				if(row_count == 0)
				{
					alert("<cf_get_lang no ='318.Seçilen Projede İş Kaydı Bulunmamaktadır'> !");
					return false;
				}
				if(row_count != 0)
				{
					document.getElementById("cpy_project_work").submit();
					return true;
				}
				
			}
			function hepsini_sec()
			{	
				if (document.cpy_project_work.all_work.checked)
				{
					<cfoutput query="get_pro_works">
					  document.cpy_project_work.work_select#currentrow#.checked = true;
					</cfoutput>
				}
				else
				{
					<cfoutput query="get_pro_works">
					  document.cpy_project_work.work_select#currentrow#.checked = false;
					</cfoutput>
				}
			}
		</script>
    </cfif>
</cfif>
