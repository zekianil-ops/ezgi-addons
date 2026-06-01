<br>
<cf_box title="#getLang('','Veri Aktarım',60009)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
	<cfform name="form_basket_ship" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_row_file_import" method="post" enctype="multipart/form-data">
    	<cfinput type="hidden" name="virtual_offer_id" id="virtual_offer_id" value="#attributes.virtual_offer_id#">
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
                <div style="line-height: 1.6; margin-top: 10px;">
                    <strong>Dosya Gereksinimleri:</strong><br/>
                    • Dosya Formatı: <code>Excel (.xls)</code><br/>
                    • Sekme Adı: <code>IMPORT</code><br/>
                    • Başlık Satırı: 1. satırda alan isimleri olmalıdır<br/>
                    • Veri Başlangıcı: 2. satırdan itibaren<br/><br/>
                    
                    <strong>Alan Açıklaması (Sırasıyla 7 Alan):</strong><br/>
                    <table style="font-size: 11px; border-collapse: collapse; margin-top: 8px;">
                        <tr style="background: #f5f5f5;">
                            <td style="padding: 4px 8px; border: 1px solid #ddd;"><b>No</b></td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;"><b>Alan Adı</b></td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;"><b>Açıklama</b></td>
                        </tr>
                        <tr>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">1</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">Area</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">Ürünün konulacağı mekan adı (isteğe bağlı)</td>
                        </tr>
                        <tr>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">2</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">Special_Image</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">Resim: 100×100 px (JPG, PNG, GIF, BMP)</td>
                        </tr>
                        <tr style="background: #ffffcc;">
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">3</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;"><b>Product_Name</b></td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;"><b>Müşteri tarafından verilen ürün adı (ZORUNLU)</b></td>
                        </tr>
                        <tr>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">4</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">URL</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">Ürüne ait URL linki (isteğe bağlı)</td>
                        </tr>
                        <tr>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">5</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">Description</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">Ürün açıklaması (isteğe bağlı)</td>
                        </tr>
                        <tr>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">6</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">Dimention</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">Ölçüler: noktalı virgül (;) ile ayırıldı (isteğe bağlı)</td>
                        </tr>
                        <tr style="background: #ffffcc;">
                            <td style="padding: 4px 8px; border: 1px solid #ddd;">7</td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;"><b>Quantity</b></td>
                            <td style="padding: 4px 8px; border: 1px solid #ddd;"><b>Teklif miktarı (ZORUNLU - Sayısal)</b></td>
                        </tr>
                    </table>
                </div>
            </div>
        </cf_box_elements>
        <cf_box_footer>
            <cf_workcube_buttons add_function="ekle_form_action(2)">
        </cf_box_footer>  
    </cfform>   
</cf_box>