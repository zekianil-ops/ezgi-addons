<!---
    File: list_ezgi_shift.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.modal_id" default="">
<cfquery name="get_shift" datasource="#DSN#">
	SELECT     	
    	S.SHIFT_NAME,
		S.SHIFT_ID,
      	B.BRANCH_NAME
	FROM      	
    	SETUP_SHIFTS AS S INNER JOIN
    	BRANCH AS B ON S.BRANCH_ID = B.BRANCH_ID
	WHERE     	
    	B.COMPANY_ID = #session.ep.COMPANY_ID# AND 
        S.IS_PRODUCTION=1
		<cfif len(attributes.keyword)>
        	AND S.SHIFT_NAME LIKE '%#attributes.keyword#%'
      	</cfif> 
	ORDER BY 	
    	S.SHIFT_NAME
</cfquery>
<cfset url_str = "">
<cfif isdefined('attributes.field_id') and len(attributes.field_id)>
	<cfset url_str = "#url_str#&field_id=#attributes.field_id#">
</cfif>
<cfif isdefined('attributes.field_name') and len(attributes.field_name)>
	<cfset url_str = "#url_str#&field_name=#attributes.field_name#">
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.totalrecords" default="#get_shift.recordCount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfsavecontent variable="ezgi_head">
	<cf_get_lang dictionary_id='53062.Vardiyalar'>
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_head#" scroll="1" collapsable="1" resize="1" >
		<cf_wrk_alphabet keyword="url_str">
		<cfform name="search_shift" method="post" action="#request.self#?fuseaction=prod.popup_list_ezgi_shift&#url_str#">
        	<cf_box_search more="0">      
				<div class="form-group" id="item-keyword">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" placeholder="#message#" value="#attributes.keyword#" maxlength="50">
				</div>
              	<div class="form-group">
					<cf_wrk_search_button button_type="4">
				</div>
			</cf_box_search> 
      	</cfform>
        <cf_flat_list>
        	<thead>
				<tr>
                	<th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th width="200"><cf_get_lang dictionary_id='57453.Şube'></th>
                    <th><cf_get_lang dictionary_id='53062.Vardiyalar'></th>
              	</tr>
          	</thead>
            <tbody>
            	<cfif get_shift.recordcount>
                	<cfoutput query="get_shift">
                    	<tr>
                        	<td style=" height:20px; text-align:right">#currentrow#</td>
                            <td>#BRANCH_NAME#</td>
                            <td><a href="javascript://" onClick="add_shift('#SHIFT_ID#','#SHIFT_NAME#');" class="tableyazi">#SHIFT_NAME#</a>	</td>
                    	</tr>
                  	</cfoutput>
              	</cfif>        
            </tbody>
       	</cf_flat_list>
   		<cfif attributes.totalrecords gt attributes.maxrows>
			<cfif len(attributes.keyword)>
				<cfset url_str = '#url_str#&keyword=#attributes.keyword#'>
			</cfif>
			<cf_paging page="#attributes.page#"
				maxrows="#attributes.maxrows#"
				totalrecords="#attributes.totalrecords#"
				startrow="#attributes.startrow#"
				adres="objects.#fusebox.fuseaction##url_str#">
		</cfif>
	</cf_box>
</div>
<script type="text/javascript">
	$(document).ready(function(){$( "#keyword" ).focus();});
	function add_shift(field_id,field_name)
	{
		<cfif isdefined("attributes.field_id")>
			opener.document.all.<cfoutput>#attributes.field_id#</cfoutput>.value = field_id;
		</cfif>
		<cfif isdefined("attributes.field_name")>
			opener.document.all.<cfoutput>#attributes.field_name#</cfoutput>.value = field_name;
		</cfif>
		<cfif isdefined("attributes.call_function")>
			try{opener.<cfoutput>#attributes.call_function#</cfoutput>;}
				catch(e){};
		</cfif>
		window.close();
	}
</script>