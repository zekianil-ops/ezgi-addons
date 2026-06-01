<!---
    File: list_ezgi_connect_telephone.cfm
    Folder: Add_Ons\ezgi\e_connect\display
    Author: Ezgi Yazılım
    Date: 01/12/2022
    Description:
--->
<cfquery name="get_connect" datasource="#dsn3#">
	SELECT        
    	CONNECT_ID, 
        CONNECT_NUMBER, 
        CONNECT_DATE, 
        BRANCH_ID,
        (SELECT BRANCH_NAME FROM #dsn_alias#.BRANCH WHERE BRANCH_ID = EZGI_CONNECT.BRANCH_ID) AS BRANCH_NAME,  
        CONNECT_EMPLOYEE_ID, 
        CONNECT_HEAD
	FROM            
    	EZGI_CONNECT
	WHERE        
    	CONNECT_TEL = '#attributes.tel#' AND 
        CONNECT_ID <> #attributes.id#
</cfquery>
<cfsavecontent  variable="baslik">
	<cf_get_lang dictionary_id='64689.Durum Sorgula / Güncelle'>
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box title="#baslik#" uidrop="1" hide_table_column="1">
    	<cf_grid_list sort="1">
            <thead>
                <tr style="height:30px">
                    <th width="20px" style="text-align:center;" ><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th width="90px" style="text-align:center;"><cf_get_lang dictionary_id='57880.Belge No'></th>
                    <th width="150px" style="text-align:center;"><cf_get_lang dictionary_id='58820.Başlık'></th>
                    <th style="text-align:left;" ><cf_get_lang dictionary_id="56987.Satış Yapan"></th>
                    <th width="150px" style="text-align:center;"><cf_get_lang dictionary_id='57453.Şube'></th>
                    <th width="20px" style="text-align:center;"><cf_get_lang dictionary_id='57474.Yazdır'></th>
                </tr>
            </thead>
            <tbody>
                <cfif get_connect.recordcount>
                <cfoutput query="get_connect">
                    <tr id="frm_row_exit#currentrow#">
                        <td style="text-align:right;">#currentrow#</td>
                        <td style="text-align:center;">#CONNECT_NUMBER#</td>
                        <td style="text-align:left;">#CONNECT_HEAD#</td>
                        <td style="text-align:left;">#get_emp_info(CONNECT_EMPLOYEE_ID,0,0)#</td>
                        <td style="text-align:left;">#BRANCH_NAME#</td>
                        <td style="text-align:center;">
                        	<a href="#request.self#?fuseaction=objects.popup_print_files&iid=#get_connect.CONNECT_ID#&print_type=77"><i class="fa fa-print"></i></a>                                
                        </td>
                    </tr>
                </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="6"><cf_get_lang dictionary_id='58486.Kayıt Bulunamdı'></td>
                    </tr>
                </cfif>
           </tbody>
        </cf_grid_list>
    </cf_box>
</div>