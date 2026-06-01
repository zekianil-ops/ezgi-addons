<!---
    File: list_ezgi_pieces.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.keyword" default="">
<cfscript>
	url_str = '&form_submitted=1';
	if (isdefined('attributes.field_id')) url_str = '#url_str#&field_id=#attributes.field_id#';
	if (isdefined('attributes.field_name')) url_str = '#url_str#&field_name=#attributes.field_name#';
</cfscript>
<cfif isdefined("attributes.form_submitted")>
	<cfquery name="get_list" datasource="#DSN3#">
    	SELECT     
        	EDP.PIECE_ROW_ID, 
            EDP.PIECE_TYPE, 
            EDP.PIECE_NAME, 
            EDP.PIECE_CODE, 
            EDP.PIECE_RELATED_ID, 
            EDP.PIECE_DETAIL, 
            EDP.BOYU, 
            EDP.ENI, 
            EC.COLOR_NAME, 
            ET.THICKNESS_VALUE,
            EDM.DESIGN_MAIN_NAME, 
            EDM.DESIGN_MAIN_ROW_ID
		FROM        
       		EZGI_DESIGN_PIECE_ROWS AS EDP INNER JOIN
        	EZGI_DESIGN_MAIN_ROW AS EDM ON EDP.DESIGN_MAIN_ROW_ID = EDM.DESIGN_MAIN_ROW_ID LEFT OUTER JOIN
        	EZGI_THICKNESS AS ET ON EDP.KALINLIK = ET.THICKNESS_ID LEFT OUTER JOIN
        	EZGI_COLORS AS EC ON EDP.PIECE_COLOR_ID = EC.COLOR_ID
		WHERE     
        	EDM.MAIN_PROTOTIP_ID IS NULL AND  
        	EDP.PIECE_TYPE < 4 AND 
            EDP.PIECE_STATUS = 1
			<cfif len(attributes.keyword)> 
				AND EDP.PIECE_NAME LIKE '%#attributes.keyword#%'
			</cfif>
      	ORDER BY
        	PIECE_NAME
    </cfquery>
<cfelse>
	<cfset get_list.recordcount = 0>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfparam name="attributes.totalrecords" default='#get_list.recordcount#'>
<cfsavecontent variable="message"><cf_get_lang dictionary_id="399.Parça Adı"></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#message#" hide_table_column="1" collapsable="0">
		<cfform name="search_form" id="search_form" method="post" action="#request.self#?fuseaction=prod.popup_list_ezgi_pieces#url_str#">
			<input type="hidden" name="form_submitted" id="form_submitted" value="">
			<cfsavecontent  variable="filtre">
				<cf_get_lang dictionary_id='57460.Filtre'>
			</cfsavecontent>
    		<cf_box_search>
                <div class="form-group">
                    <cfinput type="text" name="keyword"  placeholder="#filtre#" value="#attributes.keyword#" maxlength="255">
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
		<cf_grid_list>
			<thead>
				<tr>
					<th width="20"><cf_get_lang dictionary_id="58577.Sıra"></th>
                    <th><cf_get_lang dictionary_id="399.Parça Adı"></th>
                    <th><cf_get_lang dictionary_id="110.Modül Adı"></th>
                    <th width="130"><cf_get_lang dictionary_id="199.Renk"></th>
                    <th width="50"><cf_get_lang dictionary_id="75.Kalınlık"></th>
                    <th width="50"><cf_get_lang dictionary_id="98.En"></th>
                    <th width="50"><cf_get_lang dictionary_id="99.Boy"></th>
				</tr>
			</thead>
			<tbody>
				<cfif get_list.recordcount>
					<cfoutput query="get_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
						<tr>
							<td style="text-align:right">#currentrow#</td>
							<td>
                            	<a href="javascript://" onClick="piece_rows('#PIECE_ROW_ID#','#PIECE_NAME#');" class="tableyazi">#PIECE_NAME#</a>
                            </td>
                            <td>#DESIGN_MAIN_NAME#</td>
                            <td style="text-align:center">#COLOR_NAME#</td>
                            <td style="text-align:center">#THICKNESS_VALUE#</td>
                            <td style="text-align:center">#ENI#</td>
                            <td style="text-align:center">#BOYU#</td>
						</td>
					</cfoutput>
				<cfelse>
					<tr>
						<td colspan="7"><cfif isdefined("attributes.form_submitted")><cf_get_lang dictionary_id="58486.Kayıt Bulunamadı"> !<cfelse><cf_get_lang_main no='289.Filtre Ediniz '> !</cfif></td>
					</tr>
				</cfif>
			</tbody>
		</cf_grid_list>
		
		<cfif attributes.totalrecords gt attributes.maxrows>
			<cfif len(attributes.keyword)>
				<cfset url_str = "#url_str#&keyword=#attributes.keyword#">
			</cfif>
			
			<cf_paging page="#attributes.page#"
			maxrows="#attributes.maxrows#"
			totalrecords="#attributes.totalrecords#"
			startrow="#attributes.startrow#"
			adres="prod.popup_list_ezgi_pieces#url_str#">
				
		</cfif>
	</cf_box>
</div>
<script type="text/javascript">
	$(document).ready(function(){

    $( "#keyword" ).focus();

});
	function piece_rows(id,name)
	{
		window.opener.document.<cfoutput>#field_id#</cfoutput>.value = id;
		window.opener.document.<cfoutput>#field_name#</cfoutput>.value = name;
		window.close();
	}
</script>
