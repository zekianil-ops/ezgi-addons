<br>
<cf_box title="#getLang('','Veri Aktarım',60009)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfform name="form_locations_poses" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_row_file_import_locations" method="post" enctype="multipart/form-data">
    	<cfinput type="hidden" name="ezgi_id" id="ezgi_id" value="#attributes.ezgi_id#">
        <cf_box_elements>
            <div class="col col-6 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='57468.Belge'> *</label>
                <div class="col col-8 col-xs-12">
                    <div class="form-group" id="form_ul_uploaded_file">
                        <cfinput type="file" name="uploaded_file" required="yes" message="#getLang('','Belge Seçiniz',47469)#">
                    </div>
                </div>
            </div>
            <div class="col col-6 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                <b><cf_get_lang dictionary_id='58594.Format'></b><br/>
                Dosya uzantısı xls olmalı. Sekme adı IMPORT olmalıdır.<br />
                IMPORT işlemi neticesinde bu ekranda daha önce yer alan kayıtlar silinerek yerine yüklenen dokümandaki veriler gelecektir.<br/>
                Aktarım işlemi dosyanın 2. satırından itibaren başlar bu yüzden birinci satırda alan isimleri olmalıdır .<br /><br />
                Belgede toplam 4 alan olacaktır. Alan adları aşağıdaki gibi sütun başlığı olarak Excel dokümanına yazılmalıdır. Alanlar zorunlu olup sırası ile;<br/>
                1- <b>Tip</b><br />
                2- <b>Konum</b><br />
                3- <b>Daire</b><br />
                4- <b>Mekan</b><br />
            </div>
        </cf_box_elements>
        <cf_box_footer>
            <cf_workcube_buttons add_function="ekle_form_action(2)">
        </cf_box_footer>  
    </cfform>   
</cf_box>