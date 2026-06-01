<!---
    File: form_add_ezgi_popup_image.cfm
    Folder: Add_Ons\ezgi\e_connect\form
    Author: Ezgi Yazılım
    Date: 01/10/2025
    Description:
--->

<cfset getComponent = createObject('component','cfc.wrk_images')>
<cfparam name="attributes.detail" default="">
<cfset form_title="Hızlı Sepet SSH İçin Resim Ekle">
<cfset getLanguage = getComponent.GET_LANGUAGE(stocksId:attributes.Id)>
<cfsavecontent variable="right_"><div id="upload_status"><font face="Verdana, Arial, Helvetica, sans-serif" size="2"><b><cf_get_lang dictionary_id='201.İmaj Upload Ediliyor'>!!</b></font></div></cfsavecontent>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#form_title#">
    	<cfform name="gonderform" action="#request.self#?fuseaction=sales.emptypopup_add_ezgi_image&type=#attributes.type#" method="post" enctype="multipart/form-data">
        	<input type="hidden" name="image_action_id" id="image_action_id" value="<cfoutput>#attributes.id#</cfoutput>">
        	<input type="hidden" name="image_type" id="image_type" value="<cfoutput>#attributes.type#</cfoutput>">
            <cf_box_elements>
            	<div class="col col-6 col-md-6 col-sm-9 col-xs-12" type="column" index="1" sort="true">
                	<cfif attributes.type eq "product">
                		<div class="form-group" id="is_internet">
                        	<label class="col col-4 col-xs-12"></label>
                            <div class="col col-8 col-xs-12">
                                <input type="checkbox" name="is_internet" id="is_internet" checked value="1"><cf_get_lang dictionary_id='667.İnternet'>
                            </div>
                        </div>
                   	</cfif>
                    <cfif attributes.type eq "lift_offer">
                        <cfinput name="lift_default_id" type="hidden" value="#attributes.lift_default_id#">
                    </cfif>
                    <div class="form-group" id="language_id">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58996.Dil'>*</label>
                     	<div class="col col-8 col-xs-12">
                          	<select name="language_id" id="language_id" style="width:60px; height:20px">
								<cfoutput query="getLanguage">
                                    <option value="#language_short#">#language_set#</option>
                                </cfoutput>
                            </select>
                   		</div>
               		</div>
                    <div class="form-group" id="image_name">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='50608.İmaj Adı'>*</label>
                     	<div class="col col-8 col-xs-12">
                          	<cfsavecontent variable="message"><cf_get_lang dictionary_id='63587.girilmesi zorunlu alan'>:<cf_get_lang dictionary_id='50608.İmaj Adı'> !</cfsavecontent>
                    		<cfinput type="text" name="image_name" id="image_name" required="yes" message="#message#" style="width:200px;" maxlength="250" value="#attributes.detail#">
                   		</div>
               		</div>
                    <div class="form-group" id="image_file">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58080.Resim'> *</label>
                     	<div class="col col-8 col-xs-12">
                          	<input type="File" name="image_file" id="image_file" onfocus="select_radio(1)" style="width:200px;"/>
                   		</div>
               		</div>
                    <div class="form-group" id="image_url_link">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="29761.URL"> *</label>
                     	<div class="col col-5 col-xs-12">
                          	<input type="text" name="image_url_link" id="image_url_link" onfocus="select_radio(2)">
                   		</div>
                        <div class="col col-3 col-xs-12">
                          	<input type="checkbox" name="video_link" id="video_link">
                          	<label><cf_get_lang dictionary_id="33506.Video Link"></label>
                   		</div>
               		</div>
                    <cfif attributes.type eq "product">
                		<cfif is_stock_picture><!--- Sadece urun altindan ekleniyorsa stoklar gelsin --->
							<div class="form-group" id="stock_id">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58206.Main'></label>
                                <div class="col col-8 col-xs-12">
                                    <select name="stock_id" id="stock_id" style="width:200px; height:70px;" multiple>
										<cfoutput query="getStocks">
                                            <option value="#stock_id#">#stock_code#-#property#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                            </div>
                        </cfif>
                  	</cfif>
                    <div class="form-group" id="detail">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                     	<div class="col col-8 col-xs-12">
                          	<textarea name="detail" id="detail" style="width:200px;height:60px;"></textarea>
                   		</div>
               		</div>
                    <div class="form-group" id="detail">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57713.Boyut'></label>
                     	<div class="col col-3 col-xs-12">
                          	<input type="radio" name="size" id="size0" value="0"><cf_get_lang dictionary_id='57927.Küçük'>
                       	</div>
                        <div class="col col-3 col-xs-12">
                            <input type="radio" name="size" id="size1" value="1"><cf_get_lang dictionary_id='57928.Orta'>
                       	</div>
                        <div class="col col-2 col-xs-12">
                            <input type="radio" name="size" id="size2" value="2"><cf_get_lang_main no='517.Büyük'>
                   		</div>
               		</div>
                    <cfset session.imPath = "#upload_folder#sales#dir_seperator#">
					<cfset session.module = "connect_row">
        		</div>
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12">
                    <cf_workcube_buttons is_upd='0'  add_function='kontrol()'> 
                </div>
            </cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	document.getElementById('upload_status').style.display = 'none';
	function control()
	{
		if(document.getElementById('size0').checked == false && document.getElementById('size1').checked == false && document.getElementById('size2').checked == false)
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'>: <cf_get_lang dictionary_id='57713.Boyut'>");
			return false;
		}
        x = (100 - document.getElementById('detail').value.length);
		if ( x < 0 )
		{ 
			alert ("Açıklama Alanı Uzun !"+ ((-1) * x) +"");
			return false;
		}
		return true;
	}
	function select_radio(selected)
	{
		document.getElementById('image_file_type'+selected).checked = true;
	}

</script>
