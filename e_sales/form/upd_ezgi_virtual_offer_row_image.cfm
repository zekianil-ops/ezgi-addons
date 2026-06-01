<cfquery name="get_image_default" datasource="#dsn#">
	SELECT        
   		EZGI_LIFT_IMAGE_DEFAULT_ID, 
     	EZGI_LIFT_IMAGE_NAME, 
     	EZGI_LIFT_IMAGE_WIDTH, 
      	EZGI_LIFT_IMAGE_HEIGHT, 
      	EZGI_LIFT_IMAGE_ZORUNLU
  	FROM            
  		EZGI_LIFT_IMAGE_DEFAULT
	ORDER BY 
    	EZGI_LIFT_IMAGE_NAME
</cfquery>
<cfquery name="get_image" datasource="#dsn#">
	SELECT   
    	ELID.EZGI_LIFT_IMAGE_DEFAULT_ID,     
    	ELOR.PRODUCT_ID,
        PI.PRODUCT_IMAGEID, 
        PI.PATH
	FROM            
    	EZGI_LIFT_IMAGE_DEFAULT AS ELID INNER JOIN
     	#dsn1_alias#.PRODUCT_IMAGES AS PI ON ELID.EZGI_LIFT_IMAGE_DETAIL = PI.DETAIL RIGHT OUTER JOIN
      	EZGI_LIFT_ORDER_ROW AS ELOR ON PI.PRODUCT_ID = ELOR.PRODUCT_ID
	WHERE        
    	ELOR.EZGI_ID = #attributes.order_row_id#
</cfquery>
<cfif get_image.recordcount>
	<cfoutput query="get_image">
		<cfset 'PRODUCT_ID_#EZGI_LIFT_IMAGE_DEFAULT_ID#' = PRODUCT_ID>
        <cfset 'PRODUCT_IMAGEID_#EZGI_LIFT_IMAGE_DEFAULT_ID#' = PRODUCT_IMAGEID>
        <cfset 'PATH_#EZGI_LIFT_IMAGE_DEFAULT_ID#' = PATH>
    </cfoutput>
</cfif>
<cfquery name="get_order_row_name" datasource="#dsn#">
	SELECT PRODUCT_CODE_2 FROM EZGI_LIFT_ORDER_ROW WHERE ORDER_ROW_ID = #attributes.order_row_id#
</cfquery>

<cfif not get_image_default.recordcount>
	<script type="text/javascript">
		alert("İlk Olarak Default Resim Ekleme Ayarlarını Giriniz!");
		window.close()
	</script>
    <cfabort>
</cfif>
<table class="dph">
	<tr> 
		<td class="dpht">Resimler</td>
        <td style="text-align:right"><strong></strong></td>
	</tr>
</table>    
<table id="kontrol_listesi" width="100%">
	<tr>
		<td>
        	<cf_medium_list>
                <thead>
                    <tr height="20px">
                        <th>Resim Adı</th>
                        <th style="width:100px">Ölçüsü</th>
                        <th style="width:30px"></th>
                        <th style="width:250px">Dosya Adı</th>
                    </tr>
    			</thead>
                <tbody>
					<cfoutput query="get_image_default">
                        <tr height="20px">
                            <td>#EZGI_LIFT_IMAGE_NAME# <cfif EZGI_LIFT_IMAGE_ZORUNLU eq 1>*</cfif></td>
                            <td style="text-align:center">(#EZGI_LIFT_IMAGE_WIDTH# * #EZGI_LIFT_IMAGE_HEIGHT#)</td>
                            <td style="text-align:center">
                                <cfif isdefined('PRODUCT_ID_#EZGI_LIFT_IMAGE_DEFAULT_ID#')>
                               		<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=product.list_product&event=det&pid=#Evaluate('PRODUCT_ID_#EZGI_LIFT_IMAGE_DEFAULT_ID#')#','longpage');">
                                    	<img src="images/photo.gif" title="Resim Güncelle" border="0" />
                                 	</a>
                                <cfelse>
                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.form_add_ezgi_popup_image&id=#attributes.order_row_id#&type=lift_offer&detail=#get_order_row_name.PRODUCT_CODE_2#&table=EZGI_LIFT_IMAGES&lift_default_id=#EZGI_LIFT_IMAGE_DEFAULT_ID#','small');">
                                        <img src="images/photo.gif" title="Resim Ekle" border="0" />
                                    </a>
                                </cfif>
                            </td>
                            <td>
                           		<cfif isdefined('PATH_#EZGI_LIFT_IMAGE_DEFAULT_ID#')>
                            		#Evaluate('PATH_#EZGI_LIFT_IMAGE_DEFAULT_ID#')#
                             	</cfif>
                          	</td>
                        </tr>
                    </cfoutput>
            	</tbody>
                <tfoot>
                    <tr class="color-list">
                        <td colspan="4" style="text-align:right"></td>
                    </tr>
             	</tfoot>
         	</cf_medium_list>
      	</td>
  	</tr>
</table>
