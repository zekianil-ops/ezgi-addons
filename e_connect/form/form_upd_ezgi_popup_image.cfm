<!---
    File: form_upd_ezgi_popup_image.cfm
    Folder: Add_Ons\ezgi\e_connect\form
    Author: Ezgi Yazılım
    Date: 01/10/2025
    Description:
--->

<cf_xml_page_edit fuseact="product.form_add_popup_image">
<cfset getComponent = createObject('component','cfc.wrk_images')>
<cfquery name="get_image" datasource="#dsn3#">
    	SELECT
        	CONNECT_ROW_ID,
            PATH,
     		PATH_SERVER_ID,
          	PRD_IMG_NAME,
          	IMAGE_SIZE,
         	IS_INTERNET,
          	LANGUAGE_ID,
           	UPDATE_DATE,
          	UPDATE_EMP,
        	UPDATE_IP,
        	IS_EXTERNAL_LINK,
         	VIDEO_LINK,
           	VIDEO_PATH,
        	DETAIL
    	FROM
        	EZGI_CONNECT_ROW_IMAGES
      	WHERE
        	CONNECT_ROW_ID = #attributes.id#	
</cfquery>
<cfset image_name = "#get_image.prd_img_name#">
<cfset getLanguage = getComponent.GET_LANGUAGE()>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="up_pic"><cf_get_lang dictionary_id='923.Resim Güncelle'></cfsavecontent>
	<cf_box title="#up_pic#">
    	<cfform name="gonderform" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_image&image_action_id=#attributes.id#&image_type=#attributes.type#" method="post" enctype="multipart/form-data">
        	<cfif attributes.type eq "content">
                <input type="hidden" name="process_id" id="process_id" value="<cfoutput>#get_image.CONTENT_ID#</cfoutput>">
                <input type="hidden" name="up_type" id="up_type" value="img">
            </cfif>
            <cf_box_elements>
            	<div class="col col-6 col-md-6 col-sm-9 col-xs-12" type="column" index="1" sort="true">
                	<cfif attributes.type eq "product">
                		<div class="form-group" id="is_internet">
                        	<label class="col col-4 col-xs-12"></label>
                            <div class="col col-8 col-xs-12">
                                <input type="checkbox" name="is_internet" id="is_internet" checked value="1"><cf_get_lang dictionary_id='58079.İnternet'>
                            </div>
                        </div>
                   	</cfif>
                    <cfif attributes.type eq "lift_offer">
                        <cfinput name="lift_default_id" type="hidden" value="#attributes.lift_default_id#">
                    </cfif>
                    <div class="form-group" id="language_id">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58996.Dil'></label>
                     	<div class="col col-8 col-xs-12">
                          	<select name="language_id" id="language_id" style="width:60px; height:20px">
								<cfoutput query="getLanguage">
                                    <option value="#language_short#" <cfif get_image.language_id is language_short> selected</cfif>>#language_set#</option>
                                </cfoutput>
                            </select>
                   		</div>
               		</div>
                    <div class="form-group" id="image_name">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='50608.İmaj Adı'>*</label>
                     	<div class="col col-8 col-xs-12">
                          	<cfsavecontent variable="message"><cf_get_lang dictionary_id='63587.girilmesi zorunlu alan'>:<cf_get_lang dictionary_id='50608.İmaj Adı'>!</cfsavecontent>
                    		<cfinput type="text" name="image_name" id="image_name" required="yes" message="#message#" style="width:200px;" maxlength="250" value="#image_name#">
                   		</div>
               		</div>
                    <div class="form-group" id="image_file">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58080.Resim'> *</label>
                     	<div class="col col-8 col-xs-12">
                          	<input type="File" name="image_file" id="image_file" onfocus="select_radio(1)" style="width:200px;">
                   		</div>
               		</div>
                    <div class="form-group" id="image_file">
                    	<label class="col col-4 col-xs-12"></label>
                     	<div class="col col-8 col-xs-12">
                          	<cfoutput>#get_image.path#</cfoutput>
                   		</div>
               		</div>
                    <div class="form-group" id="image_url_link">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="29761.URL"> *</label>
                     	<div class="col col-5 col-xs-12">
                          	<input type="text" name="image_url_link" id="image_url_link" value="<cfif isdefined("get_image.VIDEO_PATH") and len(get_image.VIDEO_PATH)><cfoutput>#get_image.VIDEO_PATH#</cfoutput></cfif>" onfocus="select_radio(2)" style="width:200px;">
                   		</div>
                        <div class="col col-3 col-xs-12">
                          	<input type="checkbox" name="video_link" id="video_link" <cfif GET_IMAGE.VIDEO_LINK eq 1>checked="checked"</cfif>>
                          	<label><cf_get_lang dictionary_id="33506.Video Link"></label>
                   		</div>
               		</div>
                    <div class="form-group" id="detail">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                     	<div class="col col-8 col-xs-12">
                          	<textarea name="detail" id="detail" style="width:200px;height:60px;" ><cfoutput>#get_image.detail#</cfoutput></textarea>
                   		</div>
               		</div>
					<div class="form-group" id="detail">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57713.Boyut'></label>
                     	<div class="col col-3 col-xs-12">
                          	<input type="radio" name="size" id="size" value="0" <cfif get_image.image_size eq 0> checked</cfif>><cf_get_lang dictionary_id='57927.Küçük'>
                       	</div>
                        <div class="col col-3 col-xs-12">
                            <input type="radio" name="size" id="size" value="1" <cfif get_image.image_size eq 1> checked</cfif>><cf_get_lang dictionary_id='57928.Orta'>
                       	</div>
                        <div class="col col-2 col-xs-12">
                            <input type="radio" name="size" id="size" value="2" <cfif get_image.image_size eq 2> checked</cfif>><cf_get_lang_main no='517.Büyük'>
                   		</div>
               		</div>
               	</div>
            </cf_box_elements>
          	<cf_box_footer>
             	<cf_record_info 
                	query_name="get_image"
                  	record_emp="RECORD_EMP" 
                  	record_date="record_date"
                   	update_emp="UPDATE_EMP"
              		update_date="update_date">
             	<cf_workcube_buttons 
                 	is_upd='1' 
                  	add_function='upd_control()'
                 	del_function_for_submit='del_control()'>

      		</cf_box_footer>
      	</cfform>
 	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('upload_status').style.display = 'none';
	function go()
	{	   
	   if(control())
		   document.gonderform.submit();
	}
	
	function upd_control()
	{	
		if(document.getElementById('image_file_type1').checked == true)
		{
			var obj =  document.getElementById('image_file').value;
			if ((obj != "") && (!((obj.substring(obj.lastIndexOf('.')+1,obj.lastIndexOf('.') + 4).toLowerCase() == 'jpg')   || (obj.substring(obj.lastIndexOf('.')+1,obj.lastIndexOf('.') + 4).toLowerCase() == 'gif') || (obj.substring(obj.lastIndexOf('.')+1,obj.lastIndexOf('.') + 4).toLowerCase() == 'png')))){
				alert("<cf_get_lang dictionary_id='239.Lütfen bir resim dosyası (gif, jpg veya png) giriniz!'>");        
				return false;
			}
			<cfif  GET_IMAGE.IS_EXTERNAL_LINK eq 1>
			if(obj == "")
			{
				alert("<cf_get_lang dictionary_id='56.Dosya Seçiniz'> !");
				return false;
			}
			</cfif>
			document.getElementById('upload_status').style.display = '';
			return true;
		}
		else if(document.getElementById('image_file_type2').checked ==true)
		{
			if(trim(document.getElementById('image_url_link').value) =="")
			{
				alert("<cf_get_lang dictionary_id='29936.URL Giriniz'> !");
				return false;
			}
		}
	}
	function del_control()
	{
		sor=confirm('<cf_get_lang dictionary_id='57533.Silmek İstediğinizden Emin Misiniz?'>');
		if(sor==true)
			window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_del_ezgi_image&image_action_id=#attributes.id#&image_type=#attributes.type#</cfoutput>";
		else
			return false;
	}
	function select_radio(selected)
	{
		if(selected == 1)
		document.getElementById('image_url_link').value='';
		
		document.getElementById('image_file_type'+selected).checked = true;
	}
</script>
