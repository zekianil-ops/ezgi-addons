<!---
    File: add_ezgi_virtual_offer_special.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="get_special_row" datasource="#dsn3#" maxrows="20">
    SELECT 
      SP.*,
      (SELECT VIRTUAL_OFFER_NUMBER FROM EZGI_VIRTUAL_OFFER WHERE VIRTUAL_OFFER_ID = SP.VIRTUAL_OFFER_ID) AS VIRTUAL_OFFER_NUMBER
    FROM 
      EZGI_VIRTUAL_OFFER_SPECIAL_ROW AS SP
   WHERE 
       ROW_ID = #attributes.row_id# AND
        TYPE = '#attributes.type#'
       <cfif isdefined('attributes.measure_type') and len(attributes.measure_type)>
          AND MEASURE_TYPE= #attributes.measure_type#
        </cfif>
       <cfif isdefined('attributes.measure') and len(attributes.measure)>
           AND MEASURE = #measure#
        </cfif>
     ORDER BY
      SPECIAL_ROW_ID DESC
</cfquery>
<div class="col col-12 col-xs-12">
  <cf_box>
      <cfform name="add_default_main" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_virtual_offer_special">
          <cfinput name="type" id="type" type="hidden" value="#attributes.type#">
          <cfinput name="measure_type" id="measure_type" type="hidden" value="#attributes.measure_type#">
          <cfinput name="measure" id="measure" type="hidden" value="#attributes.measure#">
          <cfinput name="row_id" id="row_id" type="hidden" value="#attributes.row_id#">
          <cf_box_elements>
              <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                  <div class="form-group" id="item-new_field">
                      <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="801.Sanal Teklif">*</label>
                      <div class="col col-8 col-xs-12">
                          <div class="input-group">
                              <input type="hidden" name="task_v_offer_id" id="task_v_offer_id" value="">
                              <input type="text" name="task_v_offer_number" id="task_v_offer_number" value="">
                              <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_list_ezgi_virtual_offers&field_id=add_default_main.task_v_offer_id&field_name=add_default_main.task_v_offer_number&select_list=1');">
                              </span>
                             </div>
                      </div>
                  </div>
                    <div class="form-group" id="item-sira">
                      <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="57629.Açıklama"></label>
                       <div class="col col-8 col-xs-12">
                           <textarea name="detail" id="detail" style="width:150px;height:50px;"></textarea>
                       </div>
                     </div>
               </div> 
          </cf_box_elements>
          <cf_box_footer>
              <div class="col col-12">
                  <cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
              </div>
          </cf_box_footer>
      </cfform>
    </cf_box>
</div>
<div class="col col-12 col-xs-12">
  <cf_box title='İlişkili Sanal Teklifler'>
      <cf_grid_list sort="0">
            <thead>
              <tr>
                    <th style="text-align:center; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                   <th style="text-align:center;"><cf_get_lang dictionary_id="801.Sanal Teklif"></th>
                  <th style="text-align:center;"><cf_get_lang dictionary_id="57629.Açıklama">></th>
              </tr>
           </thead>
             <tbody name="new_row" id="new_row">
              <cfif get_special_row.recordcount>
                   <cfoutput query="get_special_row">
                        <tr name="frm_row#currentrow#" id="frm_row#currentrow#">
                            <td style="text-align:right">#currentrow#&nbsp;</td>
                          <td style="text-align:center">#VIRTUAL_OFFER_NUMBER#</td>
                          <td style="text-align:center">#DETAIL#</td>
                        </tr>
                    </cfoutput>
                </cfif>
           </tbody>
      </cf_grid_list>
    <cf_box>
</div>
<script type="text/javascript">
  document.getElementById('default_type').focus();
  function kontrol()
  {
      if(document.getElementById("task_v_offer_id"").value == "")
      {
          alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id="801.Sanal Teklif"> !");
          document.getElementById('default_type').focus();
          return false;
      }
  }
</script>