<!---
    File: add_ezgi_revision_tracing.cfm
    Folder: Add_Ons\ezgi\e_sales\form
    Author: Ezgi Yazılım
    Date: 01/05/2026
    Description:
--->
<cfquery name="get_history" datasource="#dsn3#">
	SELECT 
    	EVH.BOY, 
        EVH.EN, 
        EVH.DERINLIK, 
        EVH.YON, 
        EVH.UPDATE_EMP, 
        EVH.UPDATE_IP, 
        EVH.UPDATE_DATE, 
        EVH.IS_CONFIRM, 
        EVHR.STOCK_ID, 
        EVHR.QUESTION_ID, 
        EVHR.PIECE_TYPE, 
        EVHR.PIECE_ROW_ID, 
        EVH.EZGI_ID, 
     	EVHR.MAIN_UNIT, 
        EVHR.PRODUCT_NAME, 
        EVHR.IS_AMOUNT_CHANGE, 
        EVHR.DESIGN_EN, 
        EVHR.DESIGN_BOY, 
        EVHR.AMOUNT, 
        EVOD.STOCK_ID AS NEW_STOCK_ID, 
        EVOD.PRODUCT_NAME AS NEW_PRODUCT_NAME, 
   		EVOR.BOY AS NEW_BOY, 
        EVOR.EN AS NEW_EN, 
        EVOR.DERINLIK AS NEW_DERINLIK, 
        EVOR.YON AS NEW_YON, 
        EVOD.DESIGN_EN AS NEW_DESIGN_EN, 
        EVOD.DESIGN_BOY AS NEW_DESIGN_BOY, 
    	EVOD.AMOUNT AS NEW_AMOUNT,
        EVOR.PRODUCT_ID,
        EDPR.PIECE_NAME,
        EDPR.PIECE_AMOUNT
	FROM     
    	EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY AS EVH INNER JOIN
        EZGI_VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ROW AS EVHR ON EVH.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID = EVHR.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID INNER JOIN
        EZGI_VIRTUAL_OFFER_ROW_DETAIL AS EVOD ON EVHR.EZGI_ID = EVOD.EZGI_ID AND EVHR.PIECE_ROW_ID = EVOD.PIECE_ROW_ID AND EVHR.PIECE_TYPE = EVOD.PIECE_TYPE AND EVHR.QUESTION_ID = EVOD.QUESTION_ID 	INNER JOIN
      	EZGI_VIRTUAL_OFFER_ROW AS EVOR ON EVOD.EZGI_ID = EVOR.EZGI_ID LEFT OUTER JOIN
    	EZGI_DESIGN_PIECE_ROWS AS EDPR ON EVHR.PIECE_ROW_ID = EDPR.PIECE_ROW_ID

	WHERE  
    	EVH.VIRTUAL_OFFER_ROW_DETAIL_HISTORY_ID = #attributes.history_id# 
</cfquery>
<cfset question_id_list = ValueList(get_history.QUESTION_ID)>
<cfif ListLen(question_id_list)>
	<cfquery name="get_questions" datasource="#dsn#">
    	SELECT QUESTION_ID, QUESTION_NAME FROM SETUP_ALTERNATIVE_QUESTIONS WHERE QUESTION_ID IN (#question_id_list#)
    </cfquery>
    <cfoutput query="get_questions">
    	<cfset 'QUESTION_NAME_#QUESTION_ID#' = QUESTION_NAME>
    </cfoutput>
</cfif>
<cfquery name="get_image" datasource="#dsn1#">
	SELECT PRODUCT_IMAGEID, PATH FROM PRODUCT_IMAGES WHERE PRODUCT_ID = #get_history.PRODUCT_ID# AND IMAGE_SIZE = 0 
</cfquery>
<cfquery name="get_special_images" datasource="#dsn3#">
  	SELECT TOP (1) FILE_NAME FROM EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE WHERE EZGI_ID = #get_history.ezgi_id# AND FILE_TYPE_ID = 5
</cfquery>
<cfquery name="get_ana_row" dbtype="query">
	SELECT * FROM get_history WHERE PIECE_TYPE = 0
</cfquery>
<cfquery name="get_detail_row" dbtype="query">
	SELECT * FROM get_history WHERE PIECE_TYPE <> 0
</cfquery>

<cfsavecontent variable="title_">
	<cfoutput>#get_ana_row.PRODUCT_NAME#</cfoutput>
</cfsavecontent>
<div class="col col-12">
    <cf_box title="#title_#">
        <cfform name="addSpecAll" id="addSpecAll" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_revision_tracing">
            <cfinput name="history_id" value="#attributes.history_id#" type="hidden">
            <div class="col col-12">
                <div class="col col-3" style="border:1px solid #ccc; height:182px; padding:0; box-sizing:border-box; overflow:hidden;">
                    <div style="height:20px; line-height:20px; background-color:#ddd; text-align:center;">Müşteri Resmi</div>
                    <table style="height:100%; width:100%;">
                            <tr>
                                <td id="spect_image_preview_cell" style="width:100%; height:160px; vertical-align:middle; text-align:center;" >
                                    
                                    <div style="width:100%; height:160px; display:flex; align-items:center; justify-content:center; flex-direction:column;">
                                        <cfif len(get_special_images.FILE_NAME)>
                                            <cfoutput>
                                                <img src="/documents/temp/#get_special_images.FILE_NAME#" style="max-height:160px; max-width:160px; vertical-align:middle">
                                            </cfoutput>
                                        </cfif>
                                    </div>
                                </td>
                            </tr>
                    </table>
                </div>
                <div class="col col-6" style="border:1px solid #ccc; height:182px; padding:0; box-sizing:border-box; overflow:hidden;">
                    <div style="height:20px; line-height:20px; background-color:#ddd; text-align:center;">Ölçüler</div>
                    <div class="col col-12">
                        <cf_flat_list>
                                <thead>
                                    <tr>
                                        <th style="width:33%; text-align:left">Başlık</th>
                                        <th style="width:33%; text-align:right">Önceki Değer</th>
                                        <th style="width:33%; text-align:right">Değişen Değer</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfoutput>
                                    <tr>
                                        <td style="text-align:left; font-weight:bold">Yön</td>
                                        <td style="text-align:right;">
                                            <cfif get_history.yon eq 1><cf_get_lang dictionary_id="82.Sağ"></cfif>
                                            <cfif get_history.yon eq 2><cf_get_lang dictionary_id="85.Sol"></cfif>
                                            <cfif get_history.yon eq 3><cf_get_lang dictionary_id="1297.Dışa Sağ"></cfif>
                                            <cfif get_history.yon eq 4><cf_get_lang dictionary_id="1298.Dışa Sol"></cfif>
                                        </td>
                                        <td style="text-align:right; <cfif get_detail_row.NEW_YON neq get_detail_row.YON>background-color:mistyrose</cfif>">
                                            <cfif get_history.new_yon eq 1><cf_get_lang dictionary_id="82.Sağ"></cfif>
                                            <cfif get_history.new_yon eq 2><cf_get_lang dictionary_id="85.Sol"></cfif>
                                            <cfif get_history.new_yon eq 3><cf_get_lang dictionary_id="1297.Dışa Sağ"></cfif>
                                            <cfif get_history.new_yon eq 4><cf_get_lang dictionary_id="1298.Dışa Sol"></cfif>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="text-align:left; font-weight:bold">Yükseklik (mm)</td>
                                        <td style="text-align:right;">#get_history.BOY#</td>
                                        <td style="text-align:right; <cfif get_detail_row.NEW_BOY neq get_detail_row.BOY>background-color:mistyrose</cfif>">#get_history.NEW_BOY#</td>
                                    </tr>
                                    <tr>
                                        <td style="text-align:left; font-weight:bold">Genişlik (mm)</td>
                                        <td style="text-align:right;">#get_history.EN#</td>
                                        <td style="text-align:right; <cfif get_detail_row.NEW_EN neq get_detail_row.EN>background-color:mistyrose</cfif>">#get_history.NEW_EN#</td>
                                    </tr>
                                    <tr>
                                        <td style="text-align:left; font-weight:bold">Derinlik (mm)</td>
                                        <td style="text-align:right;">#get_history.DERINLIK#</td>
                                        <td style="text-align:right; <cfif get_detail_row.NEW_DERINLIK neq get_detail_row.DERINLIK>background-color:mistyrose</cfif>">#get_history.NEW_DERINLIK#</td>
                                    </tr>
                                    </cfoutput>
                                </tbody>
                        </cf_flat_list>
                    </div>
                </div>
                <div class="col col-3" style="border:1px solid #ccc; height:182px; padding:0; box-sizing:border-box; overflow:hidden;">
                    <div style="height:20px; line-height:20px; background-color:#ddd; text-align:center;">Ürün Resmi</div>
                    <table style="width:100%;">
                            <tr>
                                <td style="height:160px; width:100%; text-align:center; vertical-align:middle;">
                                    <div style="width:100%; height:160px; display:flex; align-items:center; justify-content:center;">
                                        <cfif len(get_image.PATH)>
                                            <cfoutput>
                                                <img src="/documents/product/#get_image.PATH#" style="max-height:160px; max-width:160px; vertical-align:middle">
                                            </cfoutput>
                                        </cfif>
                                    </div>
                                </td>
                            </tr>
                    </table>
                </div>
            </div>
        </cfform>
 		<div class="col col-12">
            <table style="width:100%;">
            	<tr>
                 	<td>
                     	<cf_grid_list>
                        	<thead>
								<tr>
								    <th style="width:30px" rowspan="2"><cf_get_lang_main no='1165.Sıra'></th>
								    <th rowspan="2"><cf_get_lang_main no='809.Ürün Adı'></th>
								    <th style="width:120px" rowspan="2"><cf_get_lang dictionary_id="36454.Alternatif Sorusu"></th>
								    <th style="height:15px" colspan="3">Önceki Değerler</th>
								    <th colspan="3">Değişen Değerler</th>
                              	</tr>
								<tr>
									<th style="width:200px; text-align:center" nowrap>Seçilen Ürün</th>    
								    <th style="width:120px; text-align:center" nowrap><cf_get_lang_main no='2902.Boy'>-<cf_get_lang_main no='2901.En'>(mm)</th>
								    <th style="width:60px"><cf_get_lang_main no='223.Miktar'></th>
								    
								    <th style="width:200px; text-align:center" nowrap>Seçilen Ürün</th>    
								    <th style="width:120px; text-align:center" nowrap><cf_get_lang_main no='2902.Boy'>-<cf_get_lang_main no='2901.En'>(mm)</th>
								    <th style="width:60px"><cf_get_lang_main no='223.Miktar'></th>
								</tr>
                        	</thead>
                       		<tbody>
								<cfif get_detail_row.recordcount>
									<cfoutput query="get_detail_row">
								    	<tr>
								        	<td style="text-align:right; font-weight:bold">#get_detail_row.currentrow#</td>
								            
								            <td style="text-align:left">#get_detail_row.PIECE_NAME#</td>
								            <td style="text-align:left">
								            	<cfif isdefined('QUESTION_NAME_#get_detail_row.QUESTION_ID#')>
								            		#Evaluate('QUESTION_NAME_#get_detail_row.QUESTION_ID#')#
								            	</cfif>
								            </td>
								            <td style="text-align:left" nowrap>
								            	<cfif isdefined('QUESTION_NAME_#get_detail_row.QUESTION_ID#')>
								                	#get_detail_row.PRODUCT_NAME#
								                </cfif>
								            </td>
								            <td style="text-align:center" nowrap="nowrap">
								           		#get_detail_row.DESIGN_BOY# - #get_detail_row.DESIGN_EN#
								            </td>
								            <td style="text-align:right">#TlFormat(get_detail_row.amount,4)#</td>
                                            
                                            <td style="text-align:left; <cfif get_detail_row.NEW_STOCK_ID neq get_detail_row.STOCK_ID>background-color:mistyrose</cfif>" nowrap>
								            	<cfif isdefined('QUESTION_NAME_#get_detail_row.QUESTION_ID#')>
								                	#get_detail_row.NEW_PRODUCT_NAME#
								                </cfif>
								            </td>
								            <td style="text-align:center; <cfif (get_detail_row.NEW_DESIGN_BOY neq get_detail_row.DESIGN_BOY) or (get_detail_row.NEW_DESIGN_EN neq get_detail_row.DESIGN_EN)>background-color:mistyrose</cfif>" nowrap="nowrap">
								           		#get_detail_row.NEW_DESIGN_BOY# - #get_detail_row.NEW_DESIGN_EN#
								            </td>
								            <td style="text-align:right; <cfif get_detail_row.new_amount neq get_detail_row.amount>background-color:mistyrose</cfif>">#TlFormat(get_detail_row.new_amount,4)#</td>
								        </tr>
								    </cfoutput>
								</cfif>
                         	</tbody>
                      		<tfoot>
                          		<tr>
                                 	<td colspan="9" style=" text-align:right">
                                    	<button name="vazgec" id="vazgec" style="background-color:orange; border:none; height:25px; width:90px; color:white" onClick="window.close();">Vazgeç</button>
                                        <button name="talep_red" id="talep_red" style="background-color:red; border:none; height:25px; width:90px; color:white" onClick="control(1);">Red</button>
                                        <button name="talep_kabul" id="talep_kabul" style="background-color:green; border:none; height:25px; width:90px; color:white" onClick="control(2);">Kabul</button>
                                 	</td>
                             	</tr>
                          	</tfoot>
                      	</cf_grid_list>
                  	</td>
               	</tr>
            </table>
        </div>
	</cf_box>
</div>
<script type="text/javascript">
	function control(type)
	{
		document.getElementById('vazgec').disabled = true;
		document.getElementById('talep_red').disabled = true;
		document.getElementById('talep_kabul').disabled = true;
		if(type == 1)
		{
			sor=confirm('Revizyon Talebini Redderiyorum. Onaylıyor musun?');
			if(sor==true)
			{
				document.getElementById("addSpecAll").action = "<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_revision_tracing&onay=0</cfoutput>";
				document.getElementById("addSpecAll").submit();
				return true;
			}
			else
			{
				document.getElementById('vazgec').disabled = false;
				document.getElementById('talep_red').disabled = false;
				document.getElementById('talep_kabul').disabled = false;	
			}
		}
		else if(type == 2)
		{
			sor=confirm('Revizyon talebini Kabul Ediyorum. Onaylıyor musun?');
			if(sor==true)
			{
				document.getElementById("addSpecAll").action = "<cfoutput>#request.self#?fuseaction=prod.emptypopup_add_ezgi_revision_tracing&onay=1</cfoutput>";
				document.getElementById("addSpecAll").submit();
				return true;
			}
			else
			{
				document.getElementById('vazgec').disabled = false;
				document.getElementById('talep_red').disabled = false;
				document.getElementById('talep_kabul').disabled = false;	
			}
		}
	}
</script>