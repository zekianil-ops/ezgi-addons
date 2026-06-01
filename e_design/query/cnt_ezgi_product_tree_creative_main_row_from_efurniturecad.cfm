<!---
    File: cnt_ezgi_product_tree_creative_main_row_from_efurniturecad.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/04/2025
    Description: Özel ve Mobilya Tasarıma Autocad Dosyası Transfer İşlemi
---> 
<cfset montaj = 0>

<cfquery name="GET_PIECE_DEFAULT_ID" datasource="#dsn3#">
  	SELECT 
    	PIECE_DEFAULT_ID,
    	PIECE_DEFAULT_CODE, 
        PIECE_DEFAULT_NAME, 
        ISNULL(STATUS,0) AS STATUS 
   	FROM 
    	EZGI_DESIGN_PIECE_DEFAULTS 
   	WHERE 
    	PIECE_DEFAULT_ID IN (#attributes.parca_1#,#attributes.parca_2#,#attributes.parca_3#)
</cfquery>

<cfif not GET_PIECE_DEFAULT_ID.recordcount eq 3>
    <script type="text/javascript">
        alert("Default Parça ID leri Tanımlı değil veya eksik!");
        window.history.go(-1);
    </script>
    <cfabort>
</cfif>
<cfloop query="GET_PIECE_DEFAULT_ID">
    <cfif GET_PIECE_DEFAULT_ID.STATUS eq 0>
        <script type="text/javascript">
            alert("Default Kullanınlan <cfoutput>#PIECE_DEFAULT_CODE#</cfoutput> Parça Koduna ait Default Parça Pasif Edilmiştir. Lütfen Aktif Default Parça Kullanın!");
            window.history.go(-1);
        </script>
        <cfabort>
    </cfif>
</cfloop>
<!---Default Parça Tanımlarından alınacak ID ler--->

<cfquery name="package_row_control" datasource="#dsn3#">
	SELECT PACKAGE_ROW_ID,PACKAGE_NUMBER FROM EZGI_DESIGN_PACKAGE_ROW WHERE DESIGN_MAIN_ROW_ID = #attributes.DESIGN_MAIN_ROW_ID#
</cfquery>

<cfset Last_Row = 0>
<cfset Last_Operation_Row = 0>

<cfquery name="parca_listesi" dbtype="query">
  	SELECT * FROM get_efurniturecad_row WHERE TIP = '1' OR TIP = '2' OR TIP = '3' OR TIP = '4' ORDER BY PIECE_NUMBER
</cfquery>
<!---Parça No Kontrolü - Parça Nolar sıralı ve eksik olmamalı---> 
<cfloop from="1" to="#parca_listesi.recordcount#" index="i">
	<cfquery name="parca_listesi_control" dbtype="query">
        SELECT * FROM parca_listesi WHERE PIECE_NUMBER = '#i#'
    </cfquery>
    <cfif not parca_listesi_control.recordcount>
    	<script type="text/javascript">
			alert("Dosyada <cfoutput>#i#</cfoutput> Sıra Numarası Mevcut Değildir. Dosyayı Düzenleyiniz!");
			window.history.go(-1);
		</script>
   		<cfabort>	
    </cfif>
	<cfif parca_listesi_control.recordcount gt 1>
    	<script type="text/javascript">
			alert("Dosyadaki <cfoutput>#parca_listesi_control.TIP# ve #parca_listesi_control.PIECE_NUMBER# Sıra Numarası Hatalıdır. Dosyayı Düzenleyiniz</cfoutput>!");
			window.history.go(-1);
		</script>
   		<cfabort>	
    </cfif>
</cfloop>

<!---1-YONGA LEVHA veya 3 Montajlı 2-Genel Reçete--->
<cfquery name="kesim_listesi" dbtype="query">
  	SELECT * FROM get_efurniturecad_row WHERE TIP = '1' OR TIP = '2' OR TIP = '3' ORDER BY TIP, PIECE_NUMBER
</cfquery>
<cfif kesim_listesi.recordcount>
	<cfset operations = queryNew("Last_Row, Piece_Id, Operation_Type_Id, Amount, Number","integer, integer, integer, Decimal, integer") />
    <cfset materials = queryNew("Last_Row, Piece_Id, Stock_Id, Amount, Type","integer, integer, integer, Decimal, integer") />
	<!---Sıra Numarası Birden Fazla Kullanıldı mı--->
	<cfquery name="kesim_listesi_group" dbtype="query">
    	SELECT PIECE_NUMBER FROM kesim_listesi GROUP BY PIECE_NUMBER HAVING COUNT(*)>1
    </cfquery>
    <cfif kesim_listesi_group.recordcount>
    	<cfset again_number = ValueList(kesim_listesi_group.PIECE_NUMBER)>
    	<script type="text/javascript">
			alert("Dosyadaki <cfoutput>#again_number#</cfoutput> Sıra Numarası birden fazla kullanılmıştır. Dosyayı Düzenleyiniz!");
			window.history.go(-1);
		</script>
   		<cfabort>
    </cfif>

	<cfoutput query="kesim_listesi">
    	<cfset Last_Row = kesim_listesi.PIECE_NUMBER>
        <cfset 'PIECE_ROW_ID_#Last_Row#' = Evaluate('attributes.parca_#kesim_listesi.TIP#')>
        <cfset 'PIECE_TYPE_#Last_Row#' = kesim_listesi.TIP> <!---Parça Tipi 1 2 3 Seçiliyor--->
     	<cfset 'YON_#Last_Row#' = kesim_listesi.FLOWING_SIDE>
        <cfset 'POZ_ID_#Last_Row#' = 1> <!---Paket No Seçiliyor--->
        
        <!---Parça Tipi 3 ise Tek Paket Açmak Zorunlu--->
        <cfif kesim_listesi.TIP eq 3>
        	<cfif not package_row_control.recordcount gt 0>
            	<script type="text/javascript">
					alert("Parça Tipi #kesim_listesi.TIP# ve #Last_Row# Parça Nolu Satırdaki Montajlı Parça İçin Tasarımda Mutlaka Bir Paket Açılması Gerekir.!");
					window.history.go(-1);
				</script>
				<cfabort>
            </cfif> 
        </cfif>
        
        
    	<!---Parça No Zorunlu--->
    	<cfif not len(kesim_listesi.PIECE_NUMBER)>
        	<script type="text/javascript">
				alert("Parça Tipi #kesim_listesi.TIP# ve #Last_Row# Parça Nolu Satırda Parça No Belirtilmemiş!");
				window.history.go(-1);
			</script>
            <cfabort>
        <cfelse>
        	<cfif not isnumeric(kesim_listesi.PIECE_NUMBER)>
        		<script type="text/javascript">
					alert("Parça Tipi #kesim_listesi.TIP# ve #Last_Row# Parça Nolu Satırda Parça No Bilgisi Sayısal Bilgi Olmalıdır.!");
					window.history.go(-1);
				</script>
				<cfabort>
        	<cfelse>
            	<cfset 'PIECE_ID_#Last_Row#' = kesim_listesi.PIECE_NUMBER>
            </cfif>
        </cfif>
        
        <!---Miktar Zorunlu--->
        <cfif not len(kesim_listesi.PIECE_AMOUNT)>
          	<script type="text/javascript">
				alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Miktar Girilmemiş!");
				window.history.go(-1);
			</script>
            <cfabort>
        </cfif>
        <cfif not isnumeric(kesim_listesi.PIECE_AMOUNT)>
           	<script type="text/javascript">
				alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Miktar Alanı Sayısal Değer Olmalıdır!");
				window.history.go(-1);
			</script>
            <cfabort>
        </cfif>
        <cfset 'PIECE_AMOUNT_#Last_Row#' = kesim_listesi.PIECE_AMOUNT> <!---Parça Miktarı Exceldeki PIECE_AMOUNT Alandan Alınıyor--->
        
        <!---Parça Adı Zorunlu--->
        <cfif not len(kesim_listesi.PIECE_NAME)>
          	<script type="text/javascript">
				alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Parça Adı Girilmemiş!");
				window.history.go(-1);
			</script>
            <cfabort>
        </cfif>
        <cfset 'PIECE_NAME_#Last_Row#' = kesim_listesi.PIECE_NAME> <!---Örnek Parça Adı Exceldeki PIECE_NAME Alınıyor--->
        
        <!---Renk Zorunlu--->
        <cfif not len(kesim_listesi.COLOR_NAME)>
          	<script type="text/javascript">
				alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Yonga Levha İçin Default Renk Tanımlanmamış.!");
				window.history.go(-1);
			</script>
            <cfabort>
        </cfif>
        <cfquery name="get_default_color" datasource="#dsn3#">
        	SELECT 
            	COLOR_ID, 
                COLOR_NAME, 
                ISNULL(IS_ACTIVE,0) AS IS_ACTIVE, 
                RELATED_STOCK_ID, 
                PROP_CODE
			FROM     
            	EZGI_COLORS
			WHERE  
            	COLOR_NAME = '#kesim_listesi.COLOR_NAME#'
        </cfquery>
        <cfif not get_default_color.recordcount>
         	<script type="text/javascript">
				alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırdaki #kesim_listesi.COLOR_NAME# Yonga Levha İçin Default Renk Bulunamdı!");
				window.history.go(-1);
			</script>
            <cfabort>
       	<cfelse>
        	<cfif get_default_color.IS_ACTIVE eq 0>
            	<script type="text/javascript">
					alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Parçaya ait #kesim_listesi.COLOR_NAME# Adlı Default Renk Pasif Edilmiştir. Lütfen Aktif Renk Kullanın!");
					window.history.go(-1);
				</script>
            	<cfabort>
            </cfif>
       	</cfif>
        <cfset 'COLOR_ID_#Last_Row#' = get_default_color.COLOR_ID> <!---Parça Renk ID Sorgudan Alınıyor--->
        
        <!---Paket Kontrol--->
        <cfif kesim_listesi.PACKAGE_NUMBER neq 0 and len(kesim_listesi.PACKAGE_NUMBER)>
            <cfquery name="get_package_row" dbtype="query">
                SELECT PACKAGE_ROW_ID FROM package_row_control WHERE PACKAGE_NUMBER = '#kesim_listesi.PACKAGE_NUMBER#'
            </cfquery>
            <cfif get_package_row.recordcount eq 1>
            	<cfset 'PACKAGE_ROW_ID_#Last_Row#' = #get_package_row.PACKAGE_ROW_ID#>
			<cfelseif get_package_row.recordcount gt 1>
            	<script type="text/javascript">
                    alert("Paket No #kesim_listesi.PACKAGE_NUMBER# ve  #Last_Row#  Parça Nolu Satırda Birden Fazla Bulundu.!");
                    window.history.go(-1);
                </script>
                <cfabort>
            <cfelse>
            	<script type="text/javascript">
                    alert("Paket No #kesim_listesi.PACKAGE_NUMBER# ve  #Last_Row#  Parça Nolu Satırda Paket Açılmamış.!");
                    window.history.go(-1);
                </script>
                <cfabort>
            </cfif>
        <cfelse>
        	<cfset 'PACKAGE_ROW_ID_#Last_Row#' =''>
        </cfif>
        <!---Paket Kontrol--->
        
        <!---PVC Kontrol--->
		<cfset pvc_varmi = 0>
        <cfif len(kesim_listesi._LENGTH_EDGE_STOCK_NAME) and kesim_listesi._LENGTH_EDGE_STOCK_NAME neq '----'>
        	<cfset pvc_varmi = 1>
        </cfif>
        <cfif len(kesim_listesi._LENGTH_EDGE_STOCK_NAME1) and kesim_listesi._LENGTH_EDGE_STOCK_NAME1 neq '----'>
        	<cfset pvc_varmi = 1>
        </cfif>
        <cfif len(kesim_listesi._SHORT_EDGE_STOCK_NAME) and kesim_listesi._SHORT_EDGE_STOCK_NAME neq '----'>
        	<cfset pvc_varmi = 1>
        </cfif>
        <cfif len(kesim_listesi._SHORT_EDGE_STOCK_NAME1) and kesim_listesi._SHORT_EDGE_STOCK_NAME1 neq '----'>
        	<cfset pvc_varmi = 1>
        </cfif>
        
        <!---Kalınlık 1 de Zorunlu 3 de PVC varsa Zorunlu--->
        <cfif kesim_listesi.TIP eq 1 or (kesim_listesi.TIP eq 3 and pvc_varmi eq 1) >
			<cfif not len(kesim_listesi.PIECE_DEPTH)>
                <script type="text/javascript">
                    alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Yonga Levha İçin Kalınlık Tanımlanmamış.!");
                    window.history.go(-1);
                </script>
                <cfabort>
            </cfif>
            <cfquery name="get_default_thickness" datasource="#dsn3#">
                SELECT 
                    THICKNESS_ID
                FROM     
                    EZGI_THICKNESS
                WHERE  
                    ISNULL(IS_ACTIVE,0) = 1 AND 
                    THICKNESS_VALUE = '#kesim_listesi.PIECE_DEPTH#'
            </cfquery>
            <cfif not get_default_thickness.recordcount>
                <script type="text/javascript">
                    alert("Parça Tipi #kesim_listesi.TIP# ve  #PIECE_NUMBER#  Parça Nolu Satırdaki #kesim_listesi.PIECE_DEPTH# Yonga Levha İçin Kalınlık Bulunamamıştır!");
                    window.history.go(-1);
                </script>
                <cfabort>
            </cfif>
            <cfset 'KALINLIK_#Last_Row#' = get_default_thickness.THICKNESS_ID> <!---Parça Kalınlık Excel PIECE_DEPTH Alınıyor--->
            <cfif kesim_listesi.TIP eq 1>

                <!---Yonga Levha 1 de Zorunlu--->
                <cfquery name="get_yonga_levha" datasource="#dsn3#">
                    SELECT 
                        STOCK_ID, 
                        PRODUCT_NAME
                    FROM     
                        EZGI_DESIGN_PRODUCT_PROPERTIES_UST
                    WHERE  
                        COLOR_ID = #get_default_color.COLOR_ID# AND 
                        THICKNESS_ID = #get_default_thickness.THICKNESS_ID# AND 
                        KALINLIK_ETKISI_ID IS NULL
                </cfquery>
                <cfif not get_yonga_levha.recordcount>
                    <script type="text/javascript">
                        alert("Parça Tipi #kesim_listesi.TIP# ve  #PIECE_NUMBER#  Parça Nolu Satırdaki #kesim_listesi.COLOR_NAME# Renk ve #kesim_listesi.PIECE_DEPTH# Kalınlık Yonga Levha İçin Bulunanmamıştır!");
                        window.history.go(-1);
                    </script>
                    <cfabort>
                </cfif>
                <cfset 'YONGA_LEVHA_ID_#Last_Row#' = get_yonga_levha.STOCK_ID> <!---Parça YONGA_LEVHA_ID Sorgudan Alınıyor--->
            <cfelse>
            
            </cfif>
        <cfelse>
        	<cfset 'KALINLIK_#Last_Row#' = 0>
        </cfif>
        <cfset uzun_kenar = 0>
        <cfset kisa_kenar = 0>   
        <cfif kesim_listesi.TIP neq 2>
			<!---Kenar1 Bilgisi Tespit Ediliyor--->
            <cfif len(kesim_listesi._LENGTH_EDGE_STOCK_NAME) and kesim_listesi._LENGTH_EDGE_STOCK_NAME neq '----'>
                <cfset uzun_kenar = 1>
                <cfquery name="get_pvc_stock_id_1" datasource="#dsn3#">
                    SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_NAME = '#Trim(kesim_listesi._LENGTH_EDGE_STOCK_NAME)#'
                </cfquery>
                <cfif not get_pvc_stock_id_1.recordcount>
                    <script type="text/javascript">
                        alert("<cf_get_lang dictionary_id='644.Geçersiz Bilgi'> ! #PIECE_NUMBER#. <cf_get_lang dictionary_id='58508.Satır'> #kesim_listesi._LENGTH_EDGE_STOCK_NAME#  <cf_get_lang dictionary_id='948.PVC Birim Adını Kontrol Ediniz'>.");
                        history.back();
                    </script>
                    <cfabort>
                <cfelse> 
                    <cfquery name="get_pvc" datasource="#dsn3#">
                        SELECT 
                            STOCK_ID, 
                            PRODUCT_NAME
                        FROM     
                            EZGI_DESIGN_PRODUCT_PROPERTIES_UST
                        WHERE  
                            THICKNESS_ID = #get_default_thickness.THICKNESS_ID# AND 
                            STOCK_ID = #get_pvc_stock_id_1.STOCK_ID#
                    </cfquery>
                    <cfif not get_pvc.recordcount>
                        <script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='644.Geçersiz Bilgi'> ! #PIECE_NUMBER#. <cf_get_lang dictionary_id='58508.Satır'> #kesim_listesi._LENGTH_EDGE_STOCK_NAME# için #kesim_listesi.PIECE_DEPTH# Kalınlıkta PVC Tanımı Yoktur.");
                            history.back();
                        </script>
                        <cfabort>
                    <cfelse>
                        <cfset 'KENAR1_#Last_Row#' = get_pvc_stock_id_1.STOCK_ID>
                    </cfif>
                </cfif>
            <cfelse>
                <cfset 'KENAR1_#Last_Row#' = 0>
            </cfif>   
            
            <!---Kenar2 Bilgisi Tespit Ediliyor--->
            <cfif len(kesim_listesi._LENGTH_EDGE_STOCK_NAME1) and kesim_listesi._LENGTH_EDGE_STOCK_NAME1 neq '----'>
                <cfset uzun_kenar = 1>
                <cfquery name="get_pvc_stock_id_2" datasource="#dsn3#">
                    SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_NAME = '#Trim(kesim_listesi._LENGTH_EDGE_STOCK_NAME1)#'
                </cfquery>
                <cfif not get_pvc_stock_id_2.recordcount>
                    <script type="text/javascript">
                        alert("<cf_get_lang dictionary_id='644.Geçersiz Bilgi'> ! #PIECE_NUMBER#. <cf_get_lang dictionary_id='58508.Satır'> #kesim_listesi._LENGTH_EDGE_STOCK_NAME1#  <cf_get_lang dictionary_id='948.PVC Birim Adını Kontrol Ediniz'>.");
                        history.back();
                    </script>
                    <cfabort>
                <cfelse> 
                    <cfquery name="get_pvc" datasource="#dsn3#">
                        SELECT 
                            STOCK_ID, 
                            PRODUCT_NAME
                        FROM     
                            EZGI_DESIGN_PRODUCT_PROPERTIES_UST
                        WHERE  
                            THICKNESS_ID = #get_default_thickness.THICKNESS_ID# AND 
                            STOCK_ID = #get_pvc_stock_id_2.STOCK_ID#
                    </cfquery>
                    <cfif not get_pvc.recordcount>
                        <script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='644.Geçersiz Bilgi'> ! #PIECE_NUMBER#. <cf_get_lang dictionary_id='58508.Satır'> #kesim_listesi._LENGTH_EDGE_STOCK_NAME1# için #kesim_listesi.PIECE_DEPTH# Kalınlıkta PVC Tanımı Yoktur.");
                            history.back();
                        </script>
                        <cfabort>
                    <cfelse>
                        <cfset 'KENAR2_#Last_Row#' = get_pvc_stock_id_2.STOCK_ID>
                    </cfif>
                </cfif>
            <cfelse>
                <cfset 'KENAR2_#Last_Row#' = 0>
            </cfif>  
            
            <!---Kenar3 Bilgisi Tespit Ediliyor--->
            <cfif len(kesim_listesi._SHORT_EDGE_STOCK_NAME) and kesim_listesi._SHORT_EDGE_STOCK_NAME neq '----'>
                <cfset kisa_kenar = 1>
                <cfquery name="get_pvc_stock_id_3" datasource="#dsn3#">
                    SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_NAME = '#Trim(kesim_listesi._SHORT_EDGE_STOCK_NAME)#'
                </cfquery>
                <cfif not get_pvc_stock_id_3.recordcount>
                    <script type="text/javascript">
                        alert("<cf_get_lang dictionary_id='644.Geçersiz Bilgi'> ! #PIECE_NUMBER#. <cf_get_lang dictionary_id='58508.Satır'> #kesim_listesi._SHORT_EDGE_STOCK_NAME#  <cf_get_lang dictionary_id='948.PVC Birim Adını Kontrol Ediniz'>.");
                        history.back();
                    </script>
                    <cfabort>
                <cfelse> 
                    <cfquery name="get_pvc" datasource="#dsn3#">
                        SELECT 
                            STOCK_ID, 
                            PRODUCT_NAME
                        FROM     
                            EZGI_DESIGN_PRODUCT_PROPERTIES_UST
                        WHERE  
                            THICKNESS_ID = #get_default_thickness.THICKNESS_ID# AND 
                            STOCK_ID = #get_pvc_stock_id_3.STOCK_ID#
                    </cfquery>
                    <cfif not get_pvc.recordcount>
                        <script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='644.Geçersiz Bilgi'> ! #PIECE_NUMBER#. <cf_get_lang dictionary_id='58508.Satır'> #kesim_listesi._SHORT_EDGE_STOCK_NAME# için #kesim_listesi.PIECE_DEPTH# Kalınlıkta PVC Tanımı Yoktur.");
                            history.back();
                        </script>
                        <cfabort>
                    <cfelse>
                        <cfset 'KENAR3_#Last_Row#' = get_pvc_stock_id_3.STOCK_ID>
                    </cfif>
                </cfif>
            <cfelse>
                <cfset 'KENAR3_#Last_Row#' = 0>
            </cfif> 
            
            <!---Kenar4 Bilgisi Tespit Ediliyor--->
            <cfif len(kesim_listesi._SHORT_EDGE_STOCK_NAME1) and kesim_listesi._SHORT_EDGE_STOCK_NAME1 neq '----'>
                <cfset kisa_kenar = 1>
                <cfquery name="get_pvc_stock_id_4" datasource="#dsn3#">
                    SELECT STOCK_ID FROM STOCKS WHERE PRODUCT_NAME = '#Trim(kesim_listesi._SHORT_EDGE_STOCK_NAME1)#'
                </cfquery>
                <cfif not get_pvc_stock_id_4.recordcount>
                    <script type="text/javascript">
                        alert("<cf_get_lang dictionary_id='644.Geçersiz Bilgi'> ! #PIECE_NUMBER#. <cf_get_lang dictionary_id='58508.Satır'> #kesim_listesi._SHORT_EDGE_STOCK_NAME1#  <cf_get_lang dictionary_id='948.PVC Birim Adını Kontrol Ediniz'>.");
                        history.back();
                    </script>
                    <cfabort>
                <cfelse> 
                    <cfquery name="get_pvc" datasource="#dsn3#">
                        SELECT 
                            STOCK_ID, 
                            PRODUCT_NAME
                        FROM     
                            EZGI_DESIGN_PRODUCT_PROPERTIES_UST
                        WHERE  
                            THICKNESS_ID = #get_default_thickness.THICKNESS_ID# AND 
                            STOCK_ID = #get_pvc_stock_id_4.STOCK_ID#
                    </cfquery>
                    <cfif not get_pvc.recordcount>
                        <script type="text/javascript">
                            alert("<cf_get_lang dictionary_id='644.Geçersiz Bilgi'> ! #PIECE_NUMBER#. <cf_get_lang dictionary_id='58508.Satır'> #kesim_listesi._SHORT_EDGE_STOCK_NAME1# için #kesim_listesi.PIECE_DEPTH# Kalınlıkta PVC Tanımı Yoktur.");
                            history.back();
                        </script>
                        <cfabort>
                    <cfelse>
                        <cfset 'KENAR4_#Last_Row#' = get_pvc_stock_id_4.STOCK_ID>
                    </cfif>
                </cfif>
            <cfelse>
                <cfset 'KENAR4_#Last_Row#' = 0>
            </cfif>
       	</cfif> 
        <cfif kesim_listesi.TIP eq 1 or (kesim_listesi.TIP eq 3 and uzun_kenar eq 1) or (kesim_listesi.TIP eq 2 and len(kesim_listesi.PIECE_LENGTH))>
			<!---Boy Bilgisi 1 zorunlu 3 PVC varsa Zorunlu 2 Uzunluk Varsa İşle--->
            <cfif not len(kesim_listesi.PIECE_LENGTH)>
                <script type="text/javascript">
                    alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Boy Bilgisi Boştur.!");
                    window.history.go(-1);
                </script>
                <cfabort>
            <cfelse>
                <cfif not isnumeric(kesim_listesi.PIECE_LENGTH)>
                    <script type="text/javascript">
                        alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Boy Bilgisi Sayısal Bilgi Olmalıdır.!");
                        window.history.go(-1);
                    </script>
                    <cfabort>
                </cfif>
            </cfif>
            <cfset 'BOY_#Last_Row#' = TlFormat(kesim_listesi.PIECE_LENGTH,2)>
        <cfelse>
        	<cfset 'BOY_#Last_Row#' = TlFormat(0,2)>
        </cfif>
        <cfif kesim_listesi.TIP eq 1 or (kesim_listesi.TIP eq 3 and kisa_kenar eq 1)>
			<!---En Bilgisi 1 zorunlu 3 PVC varsa Zorunlu--->
            <cfif not len(kesim_listesi.PIECE_WIDTH)>
                <script type="text/javascript">
                    alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda En Bilgisi Boştur.!");
                    window.history.go(-1);
                </script>
                <cfabort>
            <cfelse>
                <cfif not isnumeric(kesim_listesi.PIECE_WIDTH)>
                    <script type="text/javascript">
                        alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda En Bilgisi Sayısal Bilgi Olmalıdır.!");
                        window.history.go(-1);
                    </script>
                    <cfabort>
                </cfif>
            </cfif> 
            <cfset 'EN_#Last_Row#' = TlFormat(kesim_listesi.PIECE_WIDTH,2)> 
     	<cfelse>
        	<cfset 'EN_#Last_Row#' = TlFormat(0,2)> 
        </cfif>
        <cfif kesim_listesi.TIP eq 1 and len(kesim_listesi.RASER) and kesim_listesi.RASER gt 0>
        	<cfquery name="get_piece_style" datasource="#dsn3#">
            	SELECT * FROM EZGI_DESIGN_PIECE_STYLE WHERE EZGI_PIECE_STYLE_ID = #kesim_listesi.RASER#
            </cfquery>
            <cfif not get_piece_style.recordcount>
            	<script type="text/javascript">
                 	alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda  #kesim_listesi.RASER# ID li Ek Ölçü Stil Tablosunda Tanımlı Değildir.!");
              		window.history.go(-1);
            	</script>
           		<cfabort>
            </cfif>
        	<cfif len(kesim_listesi.ADD_WIDTH) or len(kesim_listesi.ADD_LENGTH)>
        		<cfif not isnumeric(kesim_listesi.ADD_WIDTH) or not len(kesim_listesi.ADD_WIDTH)>
            		<script type="text/javascript">
                        alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Ek En Bilgisi Sayısal Bilgi Olmalıdır.!");
                        window.history.go(-1);
                    </script>
                    <cfabort>
                <cfelse>
                	<cfset 'ADD_WIDTH_#Last_Row#' = TlFormat(kesim_listesi.ADD_WIDTH,2)>
                </cfif>
                <cfif not isnumeric(kesim_listesi.ADD_LENGTH) or not len(kesim_listesi.ADD_LENGTH)>
            		<script type="text/javascript">
                        alert("Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Ek Boy Bilgisi Sayısal Bilgi Olmalıdır.!");
                        window.history.go(-1);
                    </script>
                    <cfabort>
                <cfelse>
                	<cfset 'ADD_LENGTH_#Last_Row#' = TlFormat(kesim_listesi.ADD_LENGTH,2)>
                </cfif>
          	<cfelse>
            	<script type="text/javascript">
               		alert(" Parça Tipi #kesim_listesi.TIP# ve  #Last_Row#  Parça Nolu Satırda Ek Ölçü Stili Tanımladığınız Halde Ek En veya Ek Boy Tanımı Boştur.!");
               		window.history.go(-1);
            	</script>
             	<cfabort>
            </cfif>
        <cfelse>
        	<cfset 'ADD_WIDTH_#Last_Row#' = TlFormat(0,2)>
            <cfset 'ADD_LENGTH_#Last_Row#' = TlFormat(0,2)>
            <cfset 'RASER_#Last_Row#' = 0>
        </cfif>
        <!---Detay Mevcutsa İlgili Alanlar Oluşturuluyor--->
       	<cfif len(kesim_listesi.DETAIL)>
         	<cfset 'PIECE_DETAIL_#Last_Row#' = kesim_listesi.DETAIL>
     	<cfelse>
        	<cfset 'PIECE_DETAIL_#Last_Row#' = ''>
        </cfif>
        
        <!---Teknik Resim Mevcutsa İlgili Alanlar Oluşturuluyor--->
       	<cfif len(kesim_listesi.PICTURE)>
         	<cfset 'PICTURE_#Last_Row#' = kesim_listesi.PICTURE>
     	<cfelse>
        	<cfset 'PICTURE_#Last_Row#' = ''>
        </cfif>
        
        <cfinclude template="cnt_ezgi_product_tree_creative_import_piece_operation_efurniturecad.cfm">
   	</cfoutput>
<cfelse>
  	Dikkat : Dosyada Bilgi Mevcut Değildir.
    <cfabort>
</cfif>

<!---4 PAKET İÇİ HAMMADDE--->
<cfquery name="aksesuar_listesi" dbtype="query">
  	SELECT * FROM get_efurniturecad_row WHERE TIP = '4' ORDER BY PIECE_NUMBER
</cfquery>

<cfif aksesuar_listesi.recordcount>
	<cfoutput query="aksesuar_listesi">
    	<cfset Last_Row = Last_Row +1>
       	<cfif len(aksesuar_listesi.WORKCUBE_CODE)><!---Stok Kodu Doluysa--->
        	<cfquery name="GET_STOCK_ID" datasource="#DSN3#">
             	SELECT STOCK_ID,PRODUCT_NAME FROM STOCKS WHERE PRODUCT_CODE = '#aksesuar_listesi.WORKCUBE_CODE#' <!---Önce Stok Kodunu Ara--->
          	</cfquery>
          	<cfif not GET_STOCK_ID.recordcount>
             	<cfquery name="GET_STOCK_ID" datasource="#DSN3#">
                  	SELECT STOCK_ID,PRODUCT_NAME FROM STOCKS WHERE PRODUCT_CODE_2 = '#aksesuar_listesi.WORKCUBE_CODE#' <!---Sonra Özel Kodu Ara--->
           		</cfquery>
                <cfif not GET_STOCK_ID.recordcount>
                	<script type="text/javascript">
						alert("#aksesuar_listesi.WORKCUBE_CODE# Ürün Kodu Stok Dosyasında Bulunamamıştır.");
						window.history.go(-1);
					</script>
					<cfabort>
                </cfif>
        	</cfif>
        <cfelse>
        	<script type="text/javascript">
				alert("Aksesuar Ürün Kodu Dolu olmalıdır");
				window.history.go(-1);
			</script>
			<cfabort>
        </cfif>
        
        <cfif GET_STOCK_ID.recordcount>
         	<cfif GET_STOCK_ID.recordcount gt 1> <!---Stok veya Özel Kod Birden Fazla Tekrarlanmış mı--->
             	<script type="text/javascript">
					alert("Aksesuar #aksesuar_listesi.WORKCUBE_CODE# Ürün Kodu Stok Dosyasında Birden Fazla Bulunmuştur.");
					window.history.go(-1);
				</script>
				<cfabort>
        	<cfelse>
            	<cfset 'STOCK_ID_#Last_Row#' = GET_STOCK_ID.STOCK_ID>
              	<cfset 'PIECE_TYPE_#Last_Row#' = 4> <!---Parça Tipi Hammadde Seçiliyor--->
              	<cfset 'PIECE_NAME_#Last_Row#' = GET_STOCK_ID.PRODUCT_NAME>
           	</cfif>
            <cfset 'POZ_ID_#Last_Row#' = 1>    
      	</cfif>
        <cfif len(aksesuar_listesi.PIECE_AMOUNT) or isnumeric(aksesuar_listesi.PIECE_AMOUNT)>
        	<cfset 'PIECE_AMOUNT_#Last_Row#' = TlFormat(aksesuar_listesi.PIECE_AMOUNT,2)>
        <cfelse>
        	<script type="text/javascript">
				alert("Aksesuar #aksesuar_listesi.WORKCUBE_CODE# Ürün Kodlu ürünün Miktarı Boştur veya Numerik Değildir.");
				window.history.go(-1);
			</script>
			<cfabort>
        </cfif>
    </cfoutput>
</cfif> 

<!---PARÇA İÇİ AKSESUAR--->
<cfquery name="malzeme_listesi" dbtype="query">
  	SELECT * FROM get_efurniturecad_row WHERE TIP = '5' ORDER BY PIECE_NUMBER
</cfquery>
<cfif malzeme_listesi.recordcount>
	<cfset montaj = 1>
    <cfset aksesuar=1>
    <cfset hizmet=0>
	<cfinclude template="add_ezgi_product_tree_creative_import_piece_row_row_efurniturecad.cfm"><!---Aksesuar Tanımlarını Al--->

</cfif>

<!---PARÇA İÇİ HIZMET--->
<cfquery name="malzeme_listesi" dbtype="query">
  	SELECT * FROM get_efurniturecad_row WHERE TIP = '7' ORDER BY PIECE_NUMBER
</cfquery>
<cfif malzeme_listesi.recordcount>
	<cfset montaj = 1>
    <cfset aksesuar=0>
    <cfset hizmet=1>
	<cfinclude template="add_ezgi_product_tree_creative_import_piece_row_row_efurniturecad.cfm"><!---Hizmet Tanımlarını Al--->
</cfif>

<!---MONTAJA PARCA ALT BAĞLAMA--->
<cfquery name="malzeme_listesi" dbtype="query">
  	SELECT * FROM get_efurniturecad_row WHERE TIP = '6' AND COLOR_NAME = 'MONTAJ' ORDER BY PIECE_NUMBER
</cfquery>
<cfquery name="ust_kontrol_listesi" dbtype="query">
  	SELECT * FROM get_efurniturecad_row WHERE TIP = '3' ORDER BY PIECE_NUMBER
</cfquery>
<cfquery name="alt_kontrol_listesi" dbtype="query">
  	SELECT * FROM get_efurniturecad_row WHERE TIP = '1' OR TIP = '2' ORDER BY PIECE_NUMBER
</cfquery>
<cfif malzeme_listesi.recordcount>
	<cfoutput query="malzeme_listesi">
		<cfif ListLen(malzeme_listesi.PIECE_NUMBER,'-') eq 2><!--- Parça No Formatı Kontrol Ediliyor 44-2 olması bekleniyor  --->
            <cfquery name="control_ust_parca_number" dbtype="query">
                SELECT * FROM ust_kontrol_listesi WHERE PIECE_NUMBER = '#ListGetAt(malzeme_listesi.PIECE_NUMBER,1,'-')#' 
            </cfquery>
            <cfif not control_ust_parca_number.recordcount> <!---Üst Parça No Varmı Kontrolü--->
                <script type="text/javascript">
                    alert("Parça Tipi 3 ve #malzeme_listesi.PIECE_NUMBER# Parça Nolu Satırdaki Parça No daki - İşaretinin Solundaki Bilgi Parça Tipi 3 olan Parçaların Numarasında Bulunamadı.");
                    window.history.go(-1);
                </script>
                <cfabort>	
            </cfif>
            <cfif control_ust_parca_number.recordcount gt 1> <!---Üst Parça No Birden Fazla Varmı Kontrolü--->
                <script type="text/javascript">
                    alert("Parça Tipi 3 ve #malzeme_listesi.PIECE_NUMBER# Parça Nolu Satırdaki Parça No daki - İşaretinin Solundaki Bilgi Parça Tipi 3 olan Parçaların Numarası Birden Fazla Bulundu.");
                    window.history.go(-1);
                </script>
                <cfabort>	
            </cfif>
            <cfquery name="control_alt_parca_number" dbtype="query">
                SELECT * FROM alt_kontrol_listesi WHERE PIECE_NUMBER = '#ListGetAt(malzeme_listesi.PIECE_NUMBER,2,'-')#' AND (TIP = '1' OR TIP = '2')
            </cfquery>
            <cfif not control_alt_parca_number.recordcount> <!---Alt Parça No Kontrolü--->
                <script type="text/javascript">
                    alert("Parça Tipi 3 ve #malzeme_listesi.PIECE_NUMBER# Parça Nolu Satırdaki Parça No daki - İşaretinin Sağındaki Bilgi Parça Tipi 1 veya 2 olan Parçaların Numarasında Bulunamadı.");
                    window.history.go(-1);
                </script>
                <cfabort>
            </cfif>
        <cfelse>
            <script type="text/javascript">
                alert("Parça Tipi #kesim_listesi.TIP# ve #malzeme_listesi.PIECE_NUMBER# Parça Nolu Satırdaki Bilgi Uygun Değil Olması Gereken Örnek 25-4 gb.");
                window.history.go(-1);
            </script>
            <cfabort>
        </cfif>
        <cfset temp = QueryAddRow(materials)>
        <cfset Temp = QuerySetCell(materials, "Last_Row", control_ust_parca_number.PIECE_NUMBER)> 
     	<cfset Temp = QuerySetCell(materials, "Piece_Id",control_ust_parca_number.PIECE_NUMBER)> 
        <cfset Temp = QuerySetCell(materials, "Stock_Id",control_alt_parca_number.PIECE_NUMBER)>
         	<cfset Temp = QuerySetCell(materials, "Type",4)> <!---Alt Parça--->
        	<cfif len(malzeme_listesi.PIECE_AMOUNT) or isnumeric(malzeme_listesi.PIECE_AMOUNT)>
             	<cfset Temp = QuerySetCell(materials, "Amount",malzeme_listesi.PIECE_AMOUNT)>
        	<cfelse>
             	<script type="text/javascript">
                	alert("Aksesuar #malzeme_listesi.WORKCUBE_CODE# Ürün Kodlu ürünün Miktarı Boştur veya Numerik Değildir.");
                	window.history.go(-1);
              	</script>
            	<cfabort>
       		</cfif>
    </cfoutput>
</cfif>
