<!---
    File: list_ezgi_operations.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfparam name="attributes.status" default="2">
<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.is_filter" default="1">
<cfif attributes.is_filter>
	<cfquery name="operations" datasource="#dsn3#">
    	SELECT        
        	OPERATION_TYPE_ID, 
            OPERATION_CODE, 
            OPERATION_TYPE
		FROM            
        	OPERATION_TYPES
		WHERE  
        	1=1
            <cfif len(attributes.keyword)>    
        		AND (OPERATION_CODE LIKE N'#attributes.keyword#%' OR OPERATION_TYPE LIKE N'#attributes.keyword#%')
          	</cfif>
          	<cfif attributes.status eq 3>
          		AND ISNULL(OPERATION_STATUS,0) = 0
         	<cfelseif attributes.status eq 2>
          		AND ISNULL(OPERATION_STATUS,0) = 1
       		</cfif>
      	ORDER BY
        	OPERATION_CODE
	</cfquery>
<cfelse>
	<cfset operations.recordcount = 0>
</cfif>
<cfparam name="attributes.maxrows" default="#SESSION.EP.MAXROWS#">
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.totalrecords" default=#operations.recordcount#>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfsavecontent variable="message"><cf_get_lang dictionary_id="36376.Operasyonlar"></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#message#" hide_table_column="1" collapsable="0">
    	<cfform name="operations_search" action="#request.self#?fuseaction=prod.popup_list_ezgi_operations" method="post">
			<input type="hidden" name="is_filter" id="is_filter" value="1">
            <cf_box_search>
				<cfsavecontent  variable="filtre">
					<cf_get_lang dictionary_id='57460.Filtre'>
				</cfsavecontent>
                <div class="form-group">
                    <cfinput type="text" name="keyword"  placeholder="#filtre#" value="#attributes.keyword#" maxlength="255">
                </div>
                <div class="form-group small">
                	<select name="status" id="status" style="width:65px;">
                  		<option value="1" <cfif attributes.status eq 1>selected</cfif>><cf_get_lang dictionary_id="57708.Tümü"></option>
                   		<option value="2" <cfif attributes.status eq 2>selected</cfif>><cf_get_lang dictionary_id="57493.Aktif"></option>
                   		<option value="3" <cfif attributes.status eq 3>selected</cfif>><cf_get_lang dictionary_id="57494.Pasif"></option>
                	</select>
              	</div>
                <div class="form-group small">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id="34135.Sayı_Hatası_Mesaj"></cfsavecontent>
					<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" onKeyUp="isNumber(this)" validate="integer" range="1,999" message="#message#" maxlength="3">
				</div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4">
                </div>
    		</cf_box_search>
		</cfform>
		<cf_form_list>
			<thead>
				<tr>
					<th><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th width="20%"><cf_get_lang dictionary_id="58585.Kod"></th>
                    <th width="70%"><cf_get_lang dictionary_id="29419.Operasyon"></th>
				</tr>
			</thead>
			<tbody>
				<cfif operations.recordcount>
                    <cfoutput query="operations" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
                        <form name="product#currentrow#" method="post" action="">
                            <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">     
                                <td style="text-align:right; width:30px">#currentrow#</td>      
                                <td style="text-align:center; width:60px">#operation_code#</td>
                                <cfscript>temp_operation_type=replace(operation_type,'"','','all');</cfscript>
                                <cfscript>temp_operation_code=replace(operation_code,'"','','all');</cfscript>
                                <cfset temp_operation_name = '#operation_code# - #operation_type#'>
                                <td style="cursor:pointer" onClick="javascript:opener.add_row(#operation_type_id#,'#temp_operation_name#');" class="tableyazi">#operation_type#</td> 
                            </tr>
                      </form>
                    </cfoutput> 
                <cfelse>
                    <tr> 
                        <td colspan="6">
                            <cfif attributes.is_filter>
                                <cf_get_lang dictionary_id="58486.Kayıt Bulunamadı">!
                            <cfelse>
                                <cf_get_lang dictionary_id="57701.Filtre Ediniz">!
                            </cfif>
                        </td>
                    </tr>
                </cfif>
            </tbody>
       	</cf_form_list>
		<cfif attributes.totalrecords gt attributes.maxrows>
        	<cfset url_str = "prod.popup_list_ezgi_operations">
			<cfif len(attributes.keyword)>
				<cfset url_str = "#url_str#&keyword=#attributes.keyword#">
			</cfif>
			<cfif len(attributes.status)>
	        	<cfset url_str = "#url_str#&status=#attributes.status#">
	        </cfif>
			<cf_paging page="#attributes.page#"
			maxrows="#attributes.maxrows#"
			totalrecords="#attributes.totalrecords#"
			startrow="#attributes.startrow#"
			adres="#url_str#">
				
		</cfif>
	</cf_box>
</div>
<script type="text/javascript">
	$(document).ready(function(){

    $( "#keyword" ).focus();

});
	function input_control()
	{
		return true;	
	}
</script>
