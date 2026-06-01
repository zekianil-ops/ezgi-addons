<!---
    File: add_ezgi_serve_iade.cfm
    Folder: Add_Ons\ezgi\e-shipping\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfset default_fire_process_type = 112>
<cfset default_sayim_process_type = 115>
<cfquery name="get_process_cat_sayim" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_sayim_process_type# AND 
        SPCF.FUSE_NAME = 'sales.popup_add_ezgi_serve_iade' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat_sayim.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='29632.Sayım Fişi'> <cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		<!---history.back();	--->
	</script>
    <cfabort>
</cfif>

<cfquery name="get_process_cat_fire" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_fire_process_type# AND 
        SPCF.FUSE_NAME = 'sales.popup_add_ezgi_serve_iade' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat_fire.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='29629.Fire Fişi'> <cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		<!---history.back();	--->
	</script>
    <cfabort>
</cfif>

<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
        SELECT 
            D.DEPARTMENT_HEAD,
            D.BRANCH_ID,
            SL.DEPARTMENT_ID,
            SL.LOCATION_ID,
            SL.STATUS,
            SL.COMMENT
        FROM 
            STOCKS_LOCATION SL,
            DEPARTMENT D,
            BRANCH B
        WHERE
            D.BRANCH_ID IN (
            					SELECT DISTINCT 
                                	BRANCH_ID
								FROM     
                                	EMPLOYEE_POSITION_BRANCHES
								WHERE  
                                	POSITION_CODE = #session.ep.POSITION_CODE#
            				) AND
            SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
            SL.STATUS = 1 AND
            D.BRANCH_ID = B.BRANCH_ID
</cfquery>
<cfquery name="get_fis_row" datasource="#dsn2#">
	SELECT 
    	SF.DEPARTMENT_IN,
        SF.LOCATION_IN,
    	SF.FIS_ID,
        SF.FIS_NUMBER, 
        SFR.STOCK_ID, 
        SFR.AMOUNT, 
        SFR.UNIT, 
        SFR.UNIT_ID,
        S.PRODUCT_CODE, 
        S.PRODUCT_NAME, 
        SFR.STOCK_FIS_ROW_ID, 
        SFR.WRK_ROW_ID
	FROM    
    	STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
        STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
        #dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
	WHERE  
    	SF.FIS_ID = #attributes.action_id#
</cfquery>
<cfset stock_id_list = ListDeleteDuplicates(ValueList(get_fis_row.STOCK_ID))>
<cfquery name="get_add_control" datasource="#dsn2#">
	SELECT 
    	SF.DEPARTMENT_IN,
        SF.LOCATION_IN,
    	SF.FIS_ID,
        SF.FIS_NUMBER, 
        SFR.STOCK_ID, 
        SFR.AMOUNT, 
        SFR.UNIT, 
        SFR.UNIT_ID,
        S.PRODUCT_CODE, 
        S.PRODUCT_NAME, 
        SFR.STOCK_FIS_ROW_ID, 
        SFR.WRK_ROW_ID
	FROM    
    	STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
        STOCK_FIS_ROW AS SFR WITH (NOLOCK) ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
        #dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID
	WHERE  
    	SF.REF_NO = '#get_fis_row.FIS_NUMBER#' AND
        SFR.STOCK_ID IN (#stock_id_list#)
</cfquery>
<cfif get_add_control.recordcount>
	<cfoutput query="get_add_control">
    	<cfset 'CONTROL_#STOCK_ID#' = 1>
    </cfoutput>
</cfif>
<cfset attributes.department_out_id = '#get_fis_row.DEPARTMENT_IN#-#get_fis_row.LOCATION_IN#'>
<cfset attributes.department_in_id = '#get_fis_row.DEPARTMENT_IN#-#get_fis_row.LOCATION_IN#'>
<cfif get_fis_row.recordcount>
	<cfset row_id_list = ValueList(get_fis_row.STOCK_FIS_ROW_ID)>
	<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='57318.Satış İade'></cfsavecontent>
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box title="#ezgi_header#">
        	<cfform name="update_form" action="#request.self#?fuseaction=sales.emptypopup_add_ezgi_serve_iade" method="post"> 
                <cfinput type="hidden" name="row_id_list" value="#row_id_list#">
                <cfinput id="sayim_process_cat_id" type="hidden" name="sayim_process_cat_id" value="#get_process_cat_sayim.process_cat_id#">
  				<cfinput id="fire_process_cat_id" type="hidden" name="fire_process_cat_id" value="#get_process_cat_fire.process_cat_id#">
                <cfinput id="fis_number" type="hidden" name="fis_number" value="#get_fis_row.fis_number#">
                <cf_basket id="upd_form">
                    <div class="row">
                            <div class="col col-12 uniqueRow">
                                <div class="row formContent">
                                    <cf_box_elements>
                                        <div class="col col-6 col-xs-12" type="column" index="1" sort="true">
                                            <div class="form-group" id="item-dep_in">
                                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29428.Çıkış Depo'></label>
                                                <div class="col col-8 col-xs-12">
                                                    <select name="department_out_id" id="department_out_id" style="width:120px">
                                                        <cfoutput query="get_all_location" group="department_id">
                                                            <option disabled="disabled" value="#department_id#">#department_head#</option>
                                                            <cfoutput>
                                                            <option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_out_id,'-')# and location_id is #ListGetAt(attributes.department_out_id,2,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                                                            </cfoutput> 
                                                        </cfoutput>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col col-6 col-xs-12" type="column" index="2" sort="true">
                                            <div class="form-group" id="item-dep_out">
                                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36506.Giriş Depo'></label>
                                                <div class="col col-8 col-xs-12">
                                                    <select name="department_in_id" id="department_in_id" style="width:120px">
                                                        <cfoutput query="get_all_location" group="department_id">
                                                            <option disabled="disabled" value="#department_id#">#department_head#</option>
                                                            <cfoutput>
                                                            <option value="#department_id#-#location_id#" <cfif department_id is #ListFirst(attributes.department_in_id,'-')# and location_id is #ListGetAt(attributes.department_in_id,2,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                                                            </cfoutput> 
                                                        </cfoutput>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>
                                    </cf_box_elements>
                                    <cf_box_footer>
                                        <div class="col col-12 col-xs-12">
                                         	<cf_workcube_buttons 
                                                    is_upd='1' 
                                                    add_function='kontrol()'
                                                    is_delete='0'>
                                        </div>
                                    </cf_box_footer>
                                </div>
                            </div>
                    </div>
                </cf_basket>
        
        
                <div class="col col-6">
                    <cf_box title="Fireler">
                        <cf_grid_list sort="1">
                            <thead>
                                <tr>
                                    <th width="20"  height="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                    <th width="100"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                                    <th><cf_get_lang dictionary_id='57564.Ürünler'></th>
                                    <th width="50"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                    <th width="30"><cf_get_lang dictionary_id='57636.Birim'></th>
                                    <th width="20"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfoutput query="get_fis_row">
                                    <tr>
                                        <td style="text-align:right; height:30px">#currentrow#</td>
                                        <td style="text-align:center">#PRODUCT_CODE#</td> 
                                        <td style="text-align:left">#PRODUCT_NAME#</td> 
                                        <td style="text-align:right">
                                        	<input type="text" style="text-align:right" name="amount_row_#get_fis_row.STOCK_FIS_ROW_ID#" id="amount_row_#get_fis_row.STOCK_FIS_ROW_ID#" value="#AmountFormat(get_fis_row.AMOUNT)#" onChange="conrol_amount(#get_fis_row.STOCK_FIS_ROW_ID#,this.value)">
                                        </td>
                                        <td style="text-align:left">#UNIT#</td> 
                                        <td style="text-align:center">
                                        	<cfif isdefined('CONTROL_#STOCK_ID#')>
                                            	<input type="checkbox" name="select_row_#STOCK_FIS_ROW_ID#" id="select_row_#STOCK_FIS_ROW_ID#" value="#STOCK_ID#" disabled>
                                            <cfelse>
                                            	<input type="checkbox" name="select_row_#STOCK_FIS_ROW_ID#" id="select_row_#STOCK_FIS_ROW_ID#" value="#STOCK_ID#" onclick="add_row(#STOCK_FIS_ROW_ID#);">
                                            </cfif>
                                        </td>
                                    </tr>
                                </cfoutput>
                            </tbody>
                        </cf_grid_list>
                    </cf_box>
                </div>
                <div class="col col-6">
                    <cf_box title="Girişler">
                    <cf_grid_list sort="1">
                        <thead>
                            <tr>
                                <th width="20" height="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                <th width="100"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                                <th><cf_get_lang dictionary_id='57564.Ürünler'></th>
                                <th width="50"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                <th width="20"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfset renk = 'whitesmoke'>
                            <cfoutput query="get_fis_row">
                                    <cfif renk eq 'white'>
                                        <cfset renk = 'whitesmoke'>
                                    <cfelse>
                                        <cfset renk = 'white'>
                                    </cfif>
                                    <cfquery name="get_piece_all_info" datasource="#dsn3#">
                                        SELECT 
                                            EDP.PIECE_ROW_ID,
                                            S.STOCK_ID, 
                                            P.PRODUCT_CODE, 
                                            P.PRODUCT_NAME, 
                                            EDP.PIECE_TYPE,
                                            EDP.PIECE_AMOUNT AS AMOUNT
                                        FROM     
                                            #dsn1_alias#.STOCKS AS S WITH (NOLOCK) INNER JOIN
                                            #dsn1_alias#.PRODUCT AS P WITH (NOLOCK) ON P.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
                                            EZGI_DESIGN_PIECE AS EDP WITH (NOLOCK) ON S.STOCK_ID = EDP.PIECE_RELATED_ID INNER JOIN
                                            EZGI_DESIGN_PACKAGE_ROW AS EPA WITH (NOLOCK) ON EDP.DESIGN_PACKAGE_ROW_ID = EPA.PACKAGE_ROW_ID
                                          WHERE  
                                            EPA.PACKAGE_RELATED_ID = #get_fis_row.STOCK_ID# AND
                                            ISNULL(P.IS_EXTRANET,0) = 1
                                        ORDER BY 
                                            EDP.PIECE_CODE
                                    </cfquery>
                                    <cfif not get_piece_all_info.recordcount>
                                    	<script type="text/javascript">
											alert("Extranet İşaretli Parça ve Hammadde Ürün Bulunamadı Kontrol Ediniz!");
											window.close()
										</script>
										<cfabort>
                                    </cfif>
                                    <cfquery name="get_piece_info" dbtype="query">
                                        SELECT * FROM get_piece_all_info WHERE PIECE_TYPE <> 4
                                    </cfquery>
                                    <cfquery name="get_piece_raw_info" dbtype="query">
                                        SELECT * FROM get_piece_all_info WHERE PIECE_TYPE = 4
                                    </cfquery>
                                    <cfif get_piece_info.recordcount>
                                        <cfset PIECE_ROW_ID_list = ValueList(get_piece_info.PIECE_ROW_ID)>
                                        <cfquery name="get_material_info" datasource="#dsn3#">
                                            SELECT 
                                                EDP.PIECE_ROW_ID,
                                                S.STOCK_ID, 
                                                P.PRODUCT_CODE, 
                                                P.PRODUCT_NAME, 
                                                EDP.AMOUNT
                                            FROM     
                                                #dsn1_alias#.STOCKS AS S INNER JOIN
                                                #dsn1_alias#.PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
                                                EZGI_DESIGN_PIECE_ROW AS EDP ON S.STOCK_ID = EDP.STOCK_ID
                                            WHERE  
                                                EDP.PIECE_ROW_ID IN (#PIECE_ROW_ID_list#) AND
                                                EDP.PIECE_ROW_ROW_TYPE = 2  AND
                                                ISNULL(P.IS_EXTRANET,0) = 1
                                        </cfquery>
                                        <cfquery name="get_all_material_info_group" dbtype="query">
                                                SELECT
                                                    STOCK_ID, 
                                                    PRODUCT_CODE, 
                                                    PRODUCT_NAME, 
                                                    AMOUNT
                                                FROM
                                                    get_material_info
                                                UNION ALL
                                                SELECT 
                                                    STOCK_ID, 
                                                    PRODUCT_CODE, 
                                                    PRODUCT_NAME, 
                                                    AMOUNT
                                                FROM
                                                    get_piece_raw_info
                                        </cfquery>
                                        <cfif get_all_material_info_group.recordcount>
                                            <cfquery name="get_all_material_info" dbtype="query">
                                                SELECT
                                                    STOCK_ID, 
                                                    PRODUCT_CODE, 
                                                    PRODUCT_NAME,
                                                    SUM(AMOUNT) AS AMOUNT
                                                FROM
                                                    get_all_material_info_group
                                                GROUP BY
                                                    STOCK_ID, 
                                                    PRODUCT_CODE, 
                                                    PRODUCT_NAME	
                                            </cfquery>
                                        <cfelse>
                                            <cfset get_all_material_info = queryNew("")>
                                        </cfif>
                                    </cfif>
                                    <cfquery name="get_all" dbtype="query">
                                        <cfif get_piece_info.recordcount>
                                            SELECT
                                                3 AS TYPE,
                                                STOCK_ID, 
                                                PRODUCT_CODE, 
                                                PRODUCT_NAME,
                                                AMOUNT
                                            FROM
                                                get_piece_info
                                            <cfif isdefined('get_all_material_info') and get_all_material_info.recordcount>
                                                UNION ALL
                                                SELECT
                                                    4 AS TYPE,
                                                    STOCK_ID, 
                                                    PRODUCT_CODE, 
                                                    PRODUCT_NAME,
                                                    AMOUNT
                                                FROM
                                                    get_all_material_info	
                                            </cfif>
                                        <cfelse>
                                            <cfif get_piece_raw_info.recordcount>
                                                SELECT
                                                    4 AS TYPE,
                                                    STOCK_ID, 
                                                    PRODUCT_CODE, 
                                                    PRODUCT_NAME,
                                                    AMOUNT
                                                FROM
                                                    get_piece_raw_info
                                            </cfif>
                                        </cfif>
                                    </cfquery>
                                    <input type="hidden" id="row_#get_fis_row.STOCK_FIS_ROW_ID#" name="row_#STOCK_FIS_ROW_ID#" value="#get_all.recordcount#">
                                    <cfloop query="get_all">
                                    	<input type="hidden" name="amount_kok_#get_fis_row.STOCK_FIS_ROW_ID#_#get_all.currentrow#" id="amount_kok_#get_fis_row.STOCK_FIS_ROW_ID#_#get_all.currentrow#" value="#get_all.AMOUNT#">
                                        <tr id="tr_#get_fis_row.STOCK_FIS_ROW_ID#_#get_all.currentrow#" style="display:none; background-color:#renk#">
                                            <td style="text-align:right; height:30px">#get_all.currentrow#</td>
                                            <td style="text-align:center">#get_all.PRODUCT_CODE#</td> 
                                            <td style="text-align:left">#get_all.PRODUCT_NAME#</td> 
                                            <td style="text-align:right">
                                                <input type="text" style="text-align:right" name="amount_row_#get_fis_row.STOCK_FIS_ROW_ID#_#get_all.currentrow#" id="amount_row_#get_fis_row.STOCK_FIS_ROW_ID#_#get_all.currentrow#" value="#AmountFormat(get_fis_row.AMOUNT*get_all.AMOUNT)#">
                                            </td>
                                            <td style="text-align:center">
                                                <input type="checkbox" name="select_row_#get_fis_row.STOCK_FIS_ROW_ID#_#get_all.currentrow#" id="select_row_#get_fis_row.STOCK_FIS_ROW_ID#_#get_all.currentrow#" value="#get_all.STOCK_ID#">
                                            </td>
                                        </tr>
                                    </cfloop>
                            </cfoutput>
                        </tbody>
                    </cf_grid_list>
                    </cf_box>
                </div>
      		</cfform>
      	</cf_box>		
	</div>
</cfif>
<script type="text/javascript">
	function conrol_amount(sfrow_id,amount)
	{
		dongu=document.getElementById('row_'+sfrow_id).value;
		if(dongu>0)
		{
			for(var cl_ind=1; cl_ind <= dongu; cl_ind++)
			{
				kok_amount = document.getElementById('amount_kok_'+sfrow_id+'_'+cl_ind).value;
				document.getElementById('amount_row_'+sfrow_id+'_'+cl_ind).value = commaSplit(kok_amount*parseFloat(filterNum(amount,2)),2);
			}
		}	
	}
	function add_row(sfrow_id)
	{
		if(document.getElementById('select_row_'+sfrow_id).checked==true)
		{
			dongu=document.getElementById('row_'+sfrow_id).value;
			if(dongu>0)
			{
				for(var cl_ind=1; cl_ind <= dongu; cl_ind++)
				{
					document.getElementById('tr_'+sfrow_id+'_'+cl_ind).style.display='';
				}
			}
		}
		else
		{
			dongu=document.getElementById('row_'+sfrow_id).value;
			if(dongu>0)
			{
				for(var cl_ind=1; cl_ind <= dongu; cl_ind++)
				{
					document.getElementById('tr_'+sfrow_id+'_'+cl_ind).style.display='none';
					document.getElementById('select_row_'+sfrow_id+'_'+cl_ind).checked=false;
				}
			}
		}
	}
	function kontrol()
	{
		return true;	
	}
</script>