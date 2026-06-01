<!---
    File: ajax_ezgi_optimization_display.cfm
    Folder: AddOns\ezgi\e_production\query
    Author: Ezgi Yazılım
    Date: 12/12/2025
    Description: Optimizasyon Simulasyon (AJAX)
--->
<cfparam name="attributes.optimization_id" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.sheet_no" default="">

<cfif isdefined('attributes.optimization_id') and len(attributes.optimization_id) and isNumeric(attributes.optimization_id)>
	<!--- Optimizasyon bilgilerini al (kerf payı için) --->
	<cfquery name="get_optimization_info" datasource="#dsn3#">
		SELECT 
			CIRCLE_TESTRE_THICKNESS
		FROM 
			EZGI_IFLOW_OPTIMIZATION
		WHERE 
			OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
	</cfquery>
	
	<cfif get_optimization_info.recordcount and isDefined('get_optimization_info.CIRCLE_TESTRE_THICKNESS') and len(get_optimization_info.CIRCLE_TESTRE_THICKNESS) and isNumeric(get_optimization_info.CIRCLE_TESTRE_THICKNESS)>
		<cfset kerfAllowance = get_optimization_info.CIRCLE_TESTRE_THICKNESS>
	<cfelse>
		<cfset kerfAllowance = 0>
	</cfif>
	
	<!--- Sheet bilgilerini al --->
	<cfquery name="get_sheet_info" datasource="#dsn3#">
		SELECT TOP 1
			EOR.OPTIMIZATION_RESULT_ID,
			EOR.SHEET_NUMBER,
			EOR.SHEET_GROUP_NUMBER,
			EOR.USED_AREA,
			EOR.FIRE_AREA,
			EOR.FIRE_PERCENT,
			ISNULL(S.PRODUCT_NAME, 'Bilinmeyen Malzeme') AS PRODUCT_NAME
		FROM 
			EZGI_IFLOW_OPTIMIZATION_RESULTS AS EOR WITH (NOLOCK)
			LEFT OUTER JOIN STOCKS AS S WITH (NOLOCK) ON EOR.STOCK_ID = S.STOCK_ID
		WHERE 
			EOR.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			AND EOR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
			AND EOR.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_no#">
		ORDER BY 
			EOR.SHEET_NUMBER
	</cfquery>
	
	<cfif get_sheet_info.recordcount>
		<!--- Bu sheet grubuna ait tüm sheet'leri al --->
		<cfquery name="get_all_sheets" datasource="#dsn3#">
			SELECT 
				EOR.SHEET_NUMBER,
				EOR.USED_AREA,
				EOR.FIRE_AREA,
				EOR.FIRE_PERCENT
			FROM 
				EZGI_IFLOW_OPTIMIZATION_RESULTS AS EOR WITH (NOLOCK)
			WHERE 
				EOR.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
				AND EOR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
				AND EOR.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_no#">
			ORDER BY 
				EOR.SHEET_NUMBER
		</cfquery>
		
		<!--- İlk sheet'in parçalarını al (tüm sheet'ler aynı yerleşime sahip) --->
		<cfquery name="get_first_sheet_id" datasource="#dsn3#">
			SELECT TOP 1
				OPTIMIZATION_RESULT_ID
			FROM 
				EZGI_IFLOW_OPTIMIZATION_RESULTS
			WHERE 
				OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
				AND STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
				AND SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_no#">
			ORDER BY 
				SHEET_NUMBER
		</cfquery>
		
		<!--- Bu sheet grubundaki tüm parçaların toplam alanını hesapla (detay tablosundaki mantık) --->
		<cfquery name="get_total_used_amount" datasource="#dsn3#">
			SELECT 
				SUM(OERR.WIDTH * OERR.HEIGHT / 1000000) AS TOTAL_USED_AMOUNT
			FROM     
				EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS OERR WITH (NOLOCK) INNER JOIN
				EZGI_IFLOW_OPTIMIZATION_RESULTS AS OER ON OERR.OPTIMIZATION_RESULT_ID = OER.OPTIMIZATION_RESULT_ID
			WHERE  
				OER.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
				AND OER.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
				AND OER.SHEET_GROUP_NUMBER = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sheet_no#">
		</cfquery>
		
		<cfif get_first_sheet_id.recordcount>
			<cfquery name="get_pieces" datasource="#dsn3#">
				SELECT 
					EORR.PIECE_NAME,
					EORR.LOT_NO,
					EORR.P_ORDER_NO,
					EORR.X_POINT,
					EORR.Y_POINT,
					EORR.WIDTH,
					EORR.HEIGHT,
					ISNULL(EPR.IS_FLOW_DIRECTION, 0) AS IS_FLOW_DIRECTION
				FROM 
					EZGI_IFLOW_OPTIMIZATION_RESULTS_ROW AS EORR WITH (NOLOCK)
					LEFT OUTER JOIN EZGI_DESIGN_PIECE_ROWS AS EPR WITH (NOLOCK) 
						ON EORR.PIECE_NAME = EPR.PIECE_NAME
				WHERE 
					EORR.OPTIMIZATION_RESULT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_first_sheet_id.OPTIMIZATION_RESULT_ID#">
				ORDER BY 
					EORR.Y_POINT,
					EORR.X_POINT
			</cfquery>
		<cfelse>
			<cfset get_pieces.recordcount = 0>
		</cfif>
		
		<!--- Malzeme ölçülerini veritabanından al --->
		<cfquery name="get_material_dimensions" datasource="#dsn3#">
			SELECT 
				S.STOCK_ID,
				PU.DIMENTION
			FROM 
				STOCKS AS S INNER JOIN
				PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
			WHERE 
				S.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
		</cfquery>
		
	<!--- Malzeme için ayarları al (testere payı ve traşlama payı) --->
	<cfquery name="get_material_settings" datasource="#dsn3#">
		SELECT 
			ER.STOCK_ID AS SELECTED_STOCK_ID,
			ER.WORKSTATION_ID,
			ISNULL(W.STATION_NAME, 'Bilinmeyen İstasyon') AS STATION_NAME,
			ISNULL(W.CIRCLE_TESTRE_THICKNESS, -1) AS CIRCLE_TESTRE_THICKNESS,
			ISNULL(W.OUTER_EDGE_TRIMMING_ALLOWANCE, -1) AS OUTER_EDGE_TRIMMING_ALLOWANCE,
			ISNULL(W.CUTTING_METHOD,2) AS CUTTING_METHOD,
			ISNULL(W.CUTTING_STARTING_DIRECTION,1) AS CUTTING_STARTING_DIRECTION,
			ISNULL(W.MAXIMUM_NUMBER_OF_CUTS,1) AS MAXIMUM_NUMBER_OF_CUTS
		FROM 
			EZGI_IFLOW_OPTIMIZATION_MATERIAL AS E INNER JOIN
			EZGI_IFLOW_OPTIMIZATION_MATERIAL_ROW AS ER ON E.OPTIMIZATION_MATERIAL_ID = ER.OPTIMIZATION_MATERIAL_ID LEFT OUTER JOIN
			WORKSTATIONS AS W ON ER.WORKSTATION_ID = W.STATION_ID
		WHERE 
			E.OPTIMIZATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.optimization_id#">
			AND ER.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#">
	</cfquery>
		
		<!--- Sheet boyutları (mm) - dinamik olarak hesapla --->
		<cfif get_material_dimensions.recordcount and ListLen(get_material_dimensions.DIMENTION, '*') gte 2>
			<cfif isNumeric(ListGetAt(get_material_dimensions.DIMENTION, 1, '*'))>
				<cfset sheetWidth = val(ListGetAt(get_material_dimensions.DIMENTION, 1, '*'))>
			<cfelse>
				<cfset sheetWidth = 2100>
			</cfif>
			<cfif isNumeric(ListGetAt(get_material_dimensions.DIMENTION, 2, '*'))>
				<cfset sheetHeight = val(ListGetAt(get_material_dimensions.DIMENTION, 2, '*'))>
			<cfelse>
				<cfset sheetHeight = 2800>
			</cfif>
		<cfelse>
			<!--- Fallback değerler --->
			<cfset sheetWidth = 2100>
			<cfset sheetHeight = 2800>
		</cfif>
		
		<!--- Dış kenar traşlama payını hesaba kat --->
		<cfif get_material_settings.recordcount and isNumeric(get_material_settings.OUTER_EDGE_TRIMMING_ALLOWANCE) and val(get_material_settings.OUTER_EDGE_TRIMMING_ALLOWANCE) gt 0>
			<cfset trimAllowance = val(get_material_settings.OUTER_EDGE_TRIMMING_ALLOWANCE)>
			<cfset sheetWidth = sheetWidth - (2 * trimAllowance)>
			<cfset sheetHeight = sheetHeight - (2 * trimAllowance)>
			<cfif sheetWidth lte 0>
				<cfset sheetWidth = 1>
			</cfif>
			<cfif sheetHeight lte 0>
				<cfset sheetHeight = 1>
			</cfif>
		</cfif>
		
		<!--- SVG ölçeklendirme (pencereye tam sığdırmak için - max-width ve max-height kullan) --->
					<!--- Container genişliği ve yüksekliği --->
					<cfset containerMaxWidth = 1500>
					<cfset containerMaxHeight = 600>
		
		<!--- Aspect ratio hesapla --->
		<cfset sheetAspectRatio = sheetWidth / sheetHeight>
		<cfset containerAspectRatio = containerMaxWidth / containerMaxHeight>
		
		<!--- Hangi boyut sınırlayıcı olacak? --->
		<cfif sheetAspectRatio gt containerAspectRatio>
			<!--- Genişlik sınırlayıcı --->
			<cfset svgDisplayWidth = containerMaxWidth>
			<cfset svgDisplayHeight = containerMaxWidth / sheetAspectRatio>
		<cfelse>
			<!--- Yükseklik sınırlayıcı --->
			<cfset svgDisplayHeight = containerMaxHeight>
			<cfset svgDisplayWidth = containerMaxHeight * sheetAspectRatio>
		</cfif>
		
		<cf_box>
			<cfsavecontent variable="optimization_display_title">Kesim Şablonu Simulasyonu</cfsavecontent>
			<cf_box title="#optimization_display_title#">
				<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
					<cfoutput>
						<div style="margin-bottom:15px;">
							<button class="btn btn-default" onclick="optimization_display_close()" style="margin-right:10px; background-color:##ff6600; color:##ffffff; border-color:##ff6600;">
								Kapat
							</button>
							<strong>Malzeme:</strong> #get_sheet_info.PRODUCT_NAME# | 
							<strong>Şablon No:</strong> #attributes.sheet_no# | 
							<strong>Sheet Sayısı:</strong> #get_all_sheets.recordcount# | 
							<strong>Fire Oranı:</strong> #numberFormat(get_sheet_info.FIRE_PERCENT, "9.99")#%
						</div>
						
						<div style="display:flex; gap:15px; width:100%;">
							<!--- Sol taraf: Parça listesi tablosu (gruplanmış) --->
							<div style="width:600px; flex-shrink:0;">
								<!--- Parçaları grupla --->
								<cfif get_pieces.recordcount>
									<cfset groupedPieces = {}>
									<cfloop query="get_pieces">
										<cfset pieceKey = "#PIECE_NAME#_#WIDTH#_#HEIGHT#_#LOT_NO#_#P_ORDER_NO#">
										<cfif not structKeyExists(groupedPieces, pieceKey)>
											<cfset groupedPieces[pieceKey] = {
												PIECE_NAME = PIECE_NAME,
												LOT_NO = LOT_NO,
												P_ORDER_NO = P_ORDER_NO,
												WIDTH = WIDTH,
												HEIGHT = HEIGHT,
												QUANTITY = 1
											}>
										<cfelse>
											<cfset groupedPieces[pieceKey].QUANTITY = groupedPieces[pieceKey].QUANTITY + 1>
										</cfif>
									</cfloop>
									
									<cfset pieceArray = []>
									<cfloop collection="#groupedPieces#" item="key">
										<cfset arrayAppend(pieceArray, groupedPieces[key])>
									</cfloop>
								<cfelse>
									<cfset pieceArray = []>
								</cfif>
								
								<table class="table table-bordered table-striped" style="margin-bottom:0;">
									<thead>
										<tr style="height:30px;">
											<th style="text-align:center; width:20px; padding:5px; font-size:12px;">Sıra</th>
											<th style="text-align:center; width:50px; padding:5px; font-size:12px;">Lot No</th>
											<th style="text-align:center; width:50px; padding:5px; font-size:12px;">Emir No</th>
											<th style="text-align:center; padding:5px; font-size:12px;">Parça Adı</th>
											<th style="text-align:center; width:50px; padding:5px; font-size:12px;">Boyu</th>
											<th style="text-align:center; width:50px; padding:5px; font-size:12px;">Eni</th>
											<th style="text-align:center; width:40px; padding:5px; font-size:12px;">Miktar</th>
										</tr>
									</thead>
									<tbody style="font-size:10px;">
										<cfif arrayLen(pieceArray) gt 0>
											<cfloop from="1" to="#arrayLen(pieceArray)#" index="i">
												<cfset piece = pieceArray[i]>
												<tr style="height:25px;">
													<td style="text-align:center; padding:3px; vertical-align:middle; font-size:10px;">#i#</td>
													<td style="text-align:center; padding:3px; vertical-align:middle; font-size:10px;">#piece.LOT_NO#</td>
													<td style="text-align:center; padding:3px; vertical-align:middle; font-size:10px;">#piece.P_ORDER_NO#</td>
													<td style="text-align:left; padding:3px 5px; vertical-align:middle; font-size:10px;">#piece.PIECE_NAME#</td>
													<td style="text-align:center; padding:3px; vertical-align:middle; font-size:10px;">#numberFormat(piece.HEIGHT, "9")# mm</td>
													<td style="text-align:center; padding:3px; vertical-align:middle; font-size:10px;">#numberFormat(piece.WIDTH, "9")# mm</td>
													<td style="text-align:center; padding:3px; vertical-align:middle; font-weight:bold; font-size:10px;">#piece.QUANTITY#</td>
												</tr>
											</cfloop>
										<cfelse>
											<tr>
												<td colspan="7" style="text-align:center; color:##999; padding:10px; font-size:10px;">Parça bulunamadı</td>
											</tr>
										</cfif>
									</tbody>
								</table>
							</div>
							
							<!--- Sağ taraf: Sheet görseli --->
							<div style="flex:1; min-width:0;">
								<div id="sheet_container" style="overflow:auto; max-width:100%; max-height:650px; width:100%; border:1px solid ##ddd; padding:10px; background-color:##f9f9f9; display:flex; justify-content:center; align-items:center; position:relative;">
							<svg id="sheet_svg" xmlns="http://www.w3.org/2000/svg" width="#svgDisplayWidth#" height="#svgDisplayHeight#" style="background-color:##f5f5f5; display:block; max-width:100%; max-height:100%; cursor:grab;" viewBox="0 0 #sheetWidth# #sheetHeight#" preserveAspectRatio="xMidYMid meet">
								<g id="sheet_group">
								<!--- Sheet arka planı (zoom olacak) --->
								<rect x="0" y="0" width="#sheetWidth#" height="#sheetHeight#" fill="##e8e8e8" />
								
								<!--- Sheet başlığı --->
								<text x="20" y="25" font-size="20" font-weight="bold" fill="##333">
									#get_sheet_info.PRODUCT_NAME# / Şablon #attributes.sheet_no#
								</text>
								
								<!--- Sheet boyut bilgisi --->
								<text x="20" y="50" font-size="14" fill="##666">
									#sheetWidth# mm x #sheetHeight# mm
								</text>
								
								<!--- Her parça için dikdörtgen çiz --->
								<cfif get_pieces.recordcount>
									<cfloop query="get_pieces">
										<!--- Parça rengi (hash ile rastgele ama tutarlı renk) --->
										<cfset pieceHashStr = hash(PIECE_NAME)>
										<!--- Hash string'ini sayıya çevir (hex'den decimal'e, sadece ilk 6 karakter - integer sınırını aşmamak için) --->
										<cfset pieceHashNum = inputBaseN(left(pieceHashStr, 6), 16)>
										<!--- RGB değerlerini hesapla (0-255 arası) --->
										<cfset r = int((pieceHashNum mod 200) + 55)>
										<cfset g = int(((pieceHashNum * 2) mod 200) + 55)>
										<cfset b = int(((pieceHashNum * 3) mod 200) + 55)>
										<cfset pieceColor = "rgb(#r#,#g#,#b#)">
										
							<!--- Parça grubu (sürüklenebilir) --->
							<g id="piece_#currentRow#" class="draggable-piece" data-piece-x="#X_POINT#" data-piece-y="#Y_POINT#" data-piece-width="#WIDTH#" data-piece-height="#HEIGHT#" data-piece-color="#pieceColor#" data-piece-rotation="0" data-flow-direction="#IS_FLOW_DIRECTION#" transform="translate(#X_POINT#, #Y_POINT#)" style="cursor:move;">
									<!--- Dikdörtgen --->
									<rect 
										id="piece_rect_#currentRow#"
										x="0" 
										y="0" 
										width="#WIDTH#" 
										height="#HEIGHT#" 
										fill="#pieceColor#" 
										stroke="##000" 
										stroke-width="2" 
										opacity="0.7" />
									
									<!--- Desen yönü oku (sadece boyuna - dikey) --->
									<!--- IS_FLOW_DIRECTION: 0=Başlangıçtan Bitişe, 1=Bitişten Başlangıca --->
									<cfset arrowSize = 40>
									<cfset arrowHeadSize = 12>
									<cfset arrowOffset = 10>
									<cfset arrowShaftWidth = 4>
									<!--- Her zaman dikey ok göster (boyuna paralel) --->
									<cfif IS_FLOW_DIRECTION eq 1>
										<!--- Yukarıdan Aşağı ok --->
										<!--- Ok gövdesi (dikey çizgi) --->
										<line data-arrow="true" x1="#WIDTH/2#" y1="#arrowOffset#" x2="#WIDTH/2#" y2="#arrowOffset + arrowSize - arrowHeadSize#" 
											stroke="##000" 
											stroke-width="#arrowShaftWidth#" 
											stroke-linecap="round" />
										<!--- Ok başı (aşağı bakan üçgen) --->
										<path data-arrow="true" d="M #WIDTH/2# #arrowOffset + arrowSize# L #WIDTH/2 - arrowHeadSize# #arrowOffset + arrowSize - arrowHeadSize# L #WIDTH/2 + arrowHeadSize# #arrowOffset + arrowSize - arrowHeadSize# Z" 
											fill="##000" 
											stroke="##000" 
											stroke-width="1" />
									<cfelse>
										<!--- Aşağıdan Yukarı ok --->
										<!--- Ok gövdesi (dikey çizgi) --->
										<line data-arrow="true" x1="#WIDTH/2#" y1="#arrowOffset + arrowHeadSize#" x2="#WIDTH/2#" y2="#arrowOffset + arrowSize#" 
											stroke="##000" 
											stroke-width="#arrowShaftWidth#" 
											stroke-linecap="round" />
										<!--- Ok başı (yukarı bakan üçgen) --->
										<path data-arrow="true" d="M #WIDTH/2# #arrowOffset# L #WIDTH/2 - arrowHeadSize# #arrowOffset + arrowHeadSize# L #WIDTH/2 + arrowHeadSize# #arrowOffset + arrowHeadSize# Z" 
											fill="##000" 
											stroke="##000" 
											stroke-width="1" />
									</cfif>
									
									<!--- Emir No ve Parça Adı (uzun kenara paralel) --->
									<cfif WIDTH gt 80 and HEIGHT gt 50>
										<!--- Uzun kenar kontrolü: Genişlik > Yükseklik ise yatay, değilse dikey --->
										<cfif WIDTH gt HEIGHT>
											<!--- Yatay parça: Metin yatay yazılır --->
											<cfif len(P_ORDER_NO)>
												<text 
													x="#WIDTH/2#" 
													y="#HEIGHT/2 - 10#" 
													font-size="16" 
													fill="##000" 
													font-weight="bold"
													text-anchor="middle"
													dominant-baseline="middle">
													#P_ORDER_NO#
												</text>
												<!--- Parça Adı (Emir No'nun altında) --->
												<cfif len(PIECE_NAME)>
													<text 
														x="#WIDTH/2#" 
														y="#HEIGHT/2 + 10#" 
														font-size="16" 
														fill="##000" 
														font-weight="bold"
														text-anchor="middle"
														dominant-baseline="middle">
														#left(PIECE_NAME, 20)#
													</text>
												</cfif>
											<cfelse>
												<!--- Emir No yoksa sadece Parça Adı --->
												<cfif len(PIECE_NAME)>
													<text 
														x="#WIDTH/2#" 
														y="#HEIGHT/2#" 
														font-size="16" 
														fill="##000" 
														font-weight="bold"
														text-anchor="middle"
														dominant-baseline="middle">
														#left(PIECE_NAME, 20)#
													</text>
												</cfif>
											</cfif>
										<cfelse>
											<!--- Dikey parça: Metin dikey yazılır (90 derece döndürülmüş) --->
											<cfif len(P_ORDER_NO)>
												<text 
													x="#WIDTH/2 - 10#" 
													y="#HEIGHT/2#" 
													font-size="16" 
													fill="##000" 
													font-weight="bold"
													text-anchor="middle"
													dominant-baseline="middle"
													transform="rotate(-90, #WIDTH/2 - 10#, #HEIGHT/2#)">
													#P_ORDER_NO#
												</text>
												<!--- Parça Adı (Emir No'nun yanında, dikey) --->
												<cfif len(PIECE_NAME)>
													<text 
														x="#WIDTH/2 + 10#" 
														y="#HEIGHT/2#" 
														font-size="16" 
														fill="##000" 
														font-weight="bold"
														text-anchor="middle"
														dominant-baseline="middle"
														transform="rotate(-90, #WIDTH/2 + 10#, #HEIGHT/2#)">
														#left(PIECE_NAME, 20)#
													</text>
												</cfif>
											<cfelse>
												<!--- Emir No yoksa sadece Parça Adı --->
												<cfif len(PIECE_NAME)>
													<text 
														x="#WIDTH/2#" 
														y="#HEIGHT/2#" 
														font-size="16" 
														fill="##000" 
														font-weight="bold"
														text-anchor="middle"
														dominant-baseline="middle"
														transform="rotate(-90, #WIDTH/2#, #HEIGHT/2#)">
														#left(PIECE_NAME, 20)#
													</text>
												</cfif>
											</cfif>
										</cfif>
									</cfif>
									
									<!--- Ölçüler (sadece yeterince büyük parçalarda) --->
									<cfif WIDTH gt 100 and HEIGHT gt 50>
										<!--- Genişlik --->
										<text 
											x="#(WIDTH/2 - 20)#" 
											y="-5" 
											font-size="10" 
											fill="##333">
											#numberFormat(WIDTH, "9")# mm
										</text>
										
										<!--- Yükseklik (dikey) --->
										<text 
											x="-5" 
											y="#(HEIGHT/2)#" 
											font-size="10" 
											fill="##333"
											transform="rotate(-90, -5, #(HEIGHT/2)#)">
											#numberFormat(HEIGHT, "9")# mm
										</text>
									</cfif>
								</g>
									</cfloop>
								<cfelse>
									<text x="100" y="150" font-size="16" fill="##999">
										Bu sheet için parça bulunamadı
									</text>
								</cfif>
								</g>
							</svg>
								</div>
							</div>
						</div>
						<script type="text/javascript">
							(function() {
								var svg = document.getElementById('sheet_svg');
								var group = document.getElementById('sheet_group');
								var container = document.getElementById('sheet_container');
								
								if (!svg || !group) return;
								
							var sheetWidth = <cfoutput>#sheetWidth#</cfoutput>;
							var sheetHeight = <cfoutput>#sheetHeight#</cfoutput>;
							var kerfAllowance = <cfoutput>#kerfAllowance#</cfoutput>; // Kerf payı (mm)
							
							// Parça döndürme fonksiyonu
							function rotatePiece(piece) {
								// Önceki pozisyonu kaydet
								savePiecePosition(piece);
								
								var currentRotation = parseFloat(piece.getAttribute('data-piece-rotation')) || 0;
								var newRotation = (currentRotation + 90) % 360;
								
								// Mevcut pozisyon ve boyutlar
								var pieceX = parseFloat(piece.getAttribute('data-piece-x'));
								var pieceY = parseFloat(piece.getAttribute('data-piece-y'));
								var pieceWidth = parseFloat(piece.getAttribute('data-piece-width'));
								var pieceHeight = parseFloat(piece.getAttribute('data-piece-height'));
								
								// 90 veya 270 derece döndürülmüşse genişlik ve yükseklik yer değiştirir
								var newWidth, newHeight;
								if (newRotation === 90 || newRotation === 270) {
									newWidth = pieceHeight;
									newHeight = pieceWidth;
								} else {
									newWidth = pieceWidth;
									newHeight = pieceHeight;
								}
								
								// Döndürme sonrası sol üst köşeyi korumak için pozisyon ayarlaması
								// Döndürme merkezi parçanın ortası olacak
								var centerX = pieceWidth / 2;
								var centerY = pieceHeight / 2;
								
								// Döndürme sonrası yeni merkez pozisyonu
								var newCenterX = newWidth / 2;
								var newCenterY = newHeight / 2;
								
								// Sol üst köşeyi korumak için yeni pozisyonu hesapla
								// Eski merkez pozisyonu: pieceX + centerX, pieceY + centerY
								// Yeni sol üst köşe: (pieceX + centerX) - newCenterX, (pieceY + centerY) - newCenterY
								var newX = pieceX + centerX - newCenterX;
								var newY = pieceY + centerY - newCenterY;
								
								// Yeni boyutları kaydet
								piece.setAttribute('data-piece-width', newWidth);
								piece.setAttribute('data-piece-height', newHeight);
								piece.setAttribute('data-piece-rotation', newRotation);
								piece.setAttribute('data-piece-x', newX);
								piece.setAttribute('data-piece-y', newY);
								
								// Transform'u güncelle (translate + rotate)
								// Döndürme merkezi parçanın ortası (local koordinat sisteminde)
								piece.setAttribute('transform', 'translate(' + newX + ', ' + newY + ') rotate(' + newRotation + ' ' + newCenterX + ' ' + newCenterY + ')');
								
								// Ok'u güncelle (döndürme açısına göre)
								updatePieceArrow(piece, newRotation);
								
								// Yeni pozisyonu kaydet
								savePiecePosition(piece);
							}
							
							// Parça ok'unu güncelle (sadece boyuna - dikey)
							function updatePieceArrow(piece, rotation) {
								var flowDirection = parseInt(piece.getAttribute('data-flow-direction')) || 0;
								var pieceWidth = parseFloat(piece.getAttribute('data-piece-width'));
								var pieceHeight = parseFloat(piece.getAttribute('data-piece-height'));
								
								// Mevcut ok elemanlarını bul ve kaldır
								var existingArrows = piece.querySelectorAll('[data-arrow="true"]');
								for (var i = 0; i < existingArrows.length; i++) {
									existingArrows[i].remove();
								}
								
								var arrowSize = 40;
								var arrowHeadSize = 12;
								var arrowOffset = 10;
								var arrowShaftWidth = 4;
								
								// Her zaman dikey ok göster (boyuna paralel)
								// Ok'un x pozisyonu parçanın ortası (local koordinat sisteminde)
								var centerX = pieceWidth / 2;
								var rect = piece.querySelector('rect');
								
								if (flowDirection === 1) {
									// Yukarıdan Aşağı ok
									// Ok gövdesi (dikey çizgi)
									var line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
									line.setAttribute('x1', centerX);
									line.setAttribute('y1', arrowOffset);
									line.setAttribute('x2', centerX);
									line.setAttribute('y2', arrowOffset + arrowSize - arrowHeadSize);
									line.setAttribute('stroke', '##000');
									line.setAttribute('stroke-width', arrowShaftWidth);
									line.setAttribute('stroke-linecap', 'round');
									line.setAttribute('data-arrow', 'true');
									
									// Ok başı (aşağı bakan üçgen)
									var arrowPath = 'M ' + centerX + ' ' + (arrowOffset + arrowSize) + ' L ' + (centerX - arrowHeadSize) + ' ' + (arrowOffset + arrowSize - arrowHeadSize) + ' L ' + (centerX + arrowHeadSize) + ' ' + (arrowOffset + arrowSize - arrowHeadSize) + ' Z';
									var arrow = document.createElementNS('http://www.w3.org/2000/svg', 'path');
									arrow.setAttribute('d', arrowPath);
									arrow.setAttribute('fill', '##000');
									arrow.setAttribute('stroke', '##000');
									arrow.setAttribute('stroke-width', '1');
									arrow.setAttribute('data-arrow', 'true');
									
									// Ok'u rect'ten hemen sonra ekle (transform'un ok'a da uygulanması için)
									if (rect) {
										// Rect'ten sonraki ilk elemanı bul
										var nextSibling = rect.nextSibling;
										if (nextSibling) {
											piece.insertBefore(line, nextSibling);
											piece.insertBefore(arrow, line.nextSibling);
										} else {
											piece.appendChild(line);
											piece.appendChild(arrow);
										}
									} else {
										piece.appendChild(line);
										piece.appendChild(arrow);
									}
								} else {
									// Aşağıdan Yukarı ok
									// Ok gövdesi (dikey çizgi)
									var line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
									line.setAttribute('x1', centerX);
									line.setAttribute('y1', arrowOffset + arrowHeadSize);
									line.setAttribute('x2', centerX);
									line.setAttribute('y2', arrowOffset + arrowSize);
									line.setAttribute('stroke', '##000');
									line.setAttribute('stroke-width', arrowShaftWidth);
									line.setAttribute('stroke-linecap', 'round');
									line.setAttribute('data-arrow', 'true');
									
									// Ok başı (yukarı bakan üçgen)
									var arrowPath = 'M ' + centerX + ' ' + arrowOffset + ' L ' + (centerX - arrowHeadSize) + ' ' + (arrowOffset + arrowHeadSize) + ' L ' + (centerX + arrowHeadSize) + ' ' + (arrowOffset + arrowHeadSize) + ' Z';
									var arrow = document.createElementNS('http://www.w3.org/2000/svg', 'path');
									arrow.setAttribute('d', arrowPath);
									arrow.setAttribute('fill', '##000');
									arrow.setAttribute('stroke', '##000');
									arrow.setAttribute('stroke-width', '1');
									arrow.setAttribute('data-arrow', 'true');
									
									// Ok'u rect'ten hemen sonra ekle (transform'un ok'a da uygulanması için)
									if (rect) {
										// Rect'ten sonraki ilk elemanı bul
										var nextSibling = rect.nextSibling;
										if (nextSibling) {
											piece.insertBefore(line, nextSibling);
											piece.insertBefore(arrow, line.nextSibling);
										} else {
											piece.appendChild(line);
											piece.appendChild(arrow);
										}
									} else {
										piece.appendChild(line);
										piece.appendChild(arrow);
									}
								}
							}
								
								// Başlangıç viewBox değerleri
								var initialViewBox = {
									x: 0,
									y: 0,
									width: sheetWidth,
									height: sheetHeight
								};
								
								// Mevcut zoom seviyesi (başlangıç viewBox genişliği / mevcut viewBox genişliği)
								// Başlangıçta 1 (zoom yok)
								var currentScale = 1;
								var minScale = 0.1;
								var maxScale = 5;
								var scaleStep = 0.1;
								
							var isDragging = false;
							var isDraggingPiece = false;
							var draggedPiece = null;
							var startX = 0;
							var startY = 0;
							var startTranslateX = 0;
							var startTranslateY = 0;
							var pieceStartX = 0;
							var pieceStartY = 0;
							
							// Parça pozisyon geçmişi (undo için)
							var pieceHistory = {}; // pieceId -> [{x, y, rotation, width, height}, ...]
							var lastModifiedPiece = null; // Son değiştirilen parça
							
							// Parça pozisyonunu geçmişe ekle
							function savePiecePosition(piece) {
								var pieceId = piece.getAttribute('id');
								if (!pieceHistory[pieceId]) {
									pieceHistory[pieceId] = [];
								}
								
								var currentX = parseFloat(piece.getAttribute('data-piece-x'));
								var currentY = parseFloat(piece.getAttribute('data-piece-y'));
								var currentRotation = parseFloat(piece.getAttribute('data-piece-rotation')) || 0;
								var currentWidth = parseFloat(piece.getAttribute('data-piece-width'));
								var currentHeight = parseFloat(piece.getAttribute('data-piece-height'));
								
								// Son pozisyon ile aynıysa ekleme
								var history = pieceHistory[pieceId];
								if (history.length > 0) {
									var lastPos = history[history.length - 1];
									if (lastPos.x === currentX && lastPos.y === currentY && 
										lastPos.rotation === currentRotation &&
										lastPos.width === currentWidth && lastPos.height === currentHeight) {
										return; // Aynı pozisyon, ekleme
									}
								}
								
								// Yeni pozisyonu ekle
								pieceHistory[pieceId].push({
									x: currentX,
									y: currentY,
									rotation: currentRotation,
									width: currentWidth,
									height: currentHeight
								});
								
								// Maksimum 50 pozisyon tut (performans için)
								if (pieceHistory[pieceId].length > 50) {
									pieceHistory[pieceId].shift();
								}
							}
							
							// Parça pozisyonunu geri al (undo)
							function undoPiecePosition(piece) {
								if (!piece) return false;
								
								var pieceId = piece.getAttribute('id');
								if (!pieceId || !pieceHistory[pieceId] || pieceHistory[pieceId].length === 0) {
									return false; // Geçmiş yok
								}
								
								// En az 2 pozisyon olmalı (başlangıç + en az 1 değişiklik)
								if (pieceHistory[pieceId].length < 2) {
									return false; // Geri alınacak pozisyon yok
								}
								
								// Son pozisyonu kaldır (şu anki pozisyon)
								pieceHistory[pieceId].pop();
								
								// Önceki pozisyonu al
								var prevPos = pieceHistory[pieceId][pieceHistory[pieceId].length - 1];
								
								// Pozisyonu geri yükle
								piece.setAttribute('data-piece-x', prevPos.x);
								piece.setAttribute('data-piece-y', prevPos.y);
								piece.setAttribute('data-piece-rotation', prevPos.rotation);
								piece.setAttribute('data-piece-width', prevPos.width);
								piece.setAttribute('data-piece-height', prevPos.height);
								
								// Transform'u güncelle
								var centerX = prevPos.width / 2;
								var centerY = prevPos.height / 2;
								
								if (prevPos.rotation === 0) {
									piece.setAttribute('transform', 'translate(' + prevPos.x + ', ' + prevPos.y + ')');
								} else {
									piece.setAttribute('transform', 'translate(' + prevPos.x + ', ' + prevPos.y + ') rotate(' + prevPos.rotation + ' ' + centerX + ' ' + centerY + ')');
								}
								
								// Sınır kontrolü
								var isOutOfBounds = !checkBounds(piece, prevPos.x, prevPos.y);
								updatePieceColor(piece, isOutOfBounds);
								
								return true;
							}
								
								// Mouse wheel ile zoom
								svg.addEventListener('wheel', function(e) {
									e.preventDefault();
									
									// Mevcut viewBox değerlerini al
									var currentViewBox = svg.viewBox.baseVal;
									var viewBoxX = currentViewBox.x;
									var viewBoxY = currentViewBox.y;
									var viewBoxWidth = currentViewBox.width;
									var viewBoxHeight = currentViewBox.height;
									
									// Mevcut zoom seviyesini hesapla (başlangıç genişliği / mevcut genişlik)
									currentScale = initialViewBox.width / viewBoxWidth;
									
									// Zoom yönü ve miktarı
									var delta = e.deltaY > 0 ? -scaleStep : scaleStep;
									var newScale = Math.max(minScale, Math.min(maxScale, currentScale + delta));
									
									// Zoom merkezi (mouse pozisyonu) - viewBox koordinatlarında
									var rect = svg.getBoundingClientRect();
									var mouseX = e.clientX - rect.left;
									var mouseY = e.clientY - rect.top;
									
									// Mouse pozisyonunu viewBox koordinatlarına çevir
									var mouseViewBoxX = viewBoxX + (mouseX / rect.width) * viewBoxWidth;
									var mouseViewBoxY = viewBoxY + (mouseY / rect.height) * viewBoxHeight;
									
									// Yeni viewBox boyutlarını hesapla (zoom'a göre)
									var scaleChange = newScale / currentScale;
									var newViewBoxWidth = viewBoxWidth / scaleChange;
									var newViewBoxHeight = viewBoxHeight / scaleChange;
									
									// Zoom merkezini koru - viewBox'ı mouse pozisyonuna göre kaydır
									var newViewBoxX = mouseViewBoxX - (mouseX / rect.width) * newViewBoxWidth;
									var newViewBoxY = mouseViewBoxY - (mouseY / rect.height) * newViewBoxHeight;
									
									// ViewBox'ı güncelle
									svg.setAttribute('viewBox', newViewBoxX + ' ' + newViewBoxY + ' ' + newViewBoxWidth + ' ' + newViewBoxHeight);
									
									currentScale = newScale;
								}, { passive: false });
								
							// Mouse down - pan veya parça sürükleme başlat
							svg.addEventListener('mousedown', function(e) {
								if (e.button === 0) { // Sol mouse tuşu
									// Parça üzerinde mi tıklandı?
									var target = e.target;
									var pieceGroup = target.closest('.draggable-piece');
									
									if (pieceGroup) {
										// Parça sürükleme başlamadan önce mevcut pozisyonu kaydet
										savePiecePosition(pieceGroup);
										lastModifiedPiece = pieceGroup;
										
										// Parça sürükleme
										isDraggingPiece = true;
										draggedPiece = pieceGroup;
										var transform = pieceGroup.getAttribute('transform');
										// Transform'dan translate değerlerini al (rotate varsa da çalışır)
										var translateMatch = transform.match(/translate\(([^,]+),\s*([^)]+)\)/);
										if (translateMatch) {
											pieceStartX = parseFloat(translateMatch[1]);
											pieceStartY = parseFloat(translateMatch[2]);
										}
										startX = e.clientX;
										startY = e.clientY;
										pieceGroup.style.cursor = 'grabbing';
										e.stopPropagation();
									} else {
										// Pan (sheet sürükleme)
										isDragging = true;
										startX = e.clientX;
										startY = e.clientY;
										svg.style.cursor = 'grabbing';
									}
								} else if (e.button === 2) { // Sağ mouse tuşu - döndürme
									var target = e.target;
									var pieceGroup = target.closest('.draggable-piece');
									if (pieceGroup) {
										e.preventDefault();
										lastModifiedPiece = pieceGroup;
										rotatePiece(pieceGroup);
									}
								}
							});
							
							// Sağ tıklama menüsünü engelle
							svg.addEventListener('contextmenu', function(e) {
								var target = e.target;
								var pieceGroup = target.closest('.draggable-piece');
								if (pieceGroup) {
									e.preventDefault();
								}
							});
								
						// Çarpışma kontrolü fonksiyonu (kerf payı ile)
						function checkCollision(piece, newX, newY, kerfAllowance) {
							var pieceWidth = parseFloat(piece.getAttribute('data-piece-width'));
							var pieceHeight = parseFloat(piece.getAttribute('data-piece-height'));
							var pieceId = piece.getAttribute('id');
							
							// Kerf payı değeri (mm) - parçalar arasında minimum mesafe
							var minDistance = parseFloat(kerfAllowance) || 0;
							
							// Tüm parçaları kontrol et
							var allPieces = svg.querySelectorAll('.draggable-piece');
							for (var i = 0; i < allPieces.length; i++) {
								var otherPiece = allPieces[i];
								if (otherPiece.getAttribute('id') === pieceId) continue;
								
								var otherX = parseFloat(otherPiece.getAttribute('data-piece-x'));
								var otherY = parseFloat(otherPiece.getAttribute('data-piece-y'));
								var otherWidth = parseFloat(otherPiece.getAttribute('data-piece-width'));
								var otherHeight = parseFloat(otherPiece.getAttribute('data-piece-height'));
								
								// Kerf payı ile çarpışma kontrolü
								// Parçalar arasında minimum kerf payı kadar mesafe olmalı
								// Çarpışma YOK ise:
								// - newX + pieceWidth + minDistance <= otherX (yeni parça diğerinin solunda, mesafe var)
								// - newX >= otherX + otherWidth + minDistance (yeni parça diğerinin sağında, mesafe var)
								// - newY + pieceHeight + minDistance <= otherY (yeni parça diğerinin üstünde, mesafe var)
								// - newY >= otherY + otherHeight + minDistance (yeni parça diğerinin altında, mesafe var)
								
								// Yatay çakışma kontrolü (kerf payı ile)
								var noHorizontalOverlap = (newX + pieceWidth + minDistance <= otherX) || (newX >= otherX + otherWidth + minDistance);
								
								// Dikey çakışma kontrolü (kerf payı ile)
								var noVerticalOverlap = (newY + pieceHeight + minDistance <= otherY) || (newY >= otherY + otherHeight + minDistance);
								
								// Eğer hem yatay hem dikey çakışma yoksa, çarpışma yok
								// Aksi halde çarpışma var
								if (!noHorizontalOverlap && !noVerticalOverlap) {
									return true; // Çarpışma var (kerf payı dahil)
								}
							}
							return false; // Çarpışma yok
						}
							
							// Sınır kontrolü fonksiyonu
							function checkBounds(piece, newX, newY) {
								var pieceWidth = parseFloat(piece.getAttribute('data-piece-width'));
								var pieceHeight = parseFloat(piece.getAttribute('data-piece-height'));
								
								// Sheet sınırları dışında mı?
								if (newX < 0 || newY < 0 || 
									newX + pieceWidth > sheetWidth || 
									newY + pieceHeight > sheetHeight) {
									return false; // Sınırlar dışında
								}
								return true; // Sınırlar içinde
							}
							
							// Parça rengini güncelle
							function updatePieceColor(piece, isOutOfBounds) {
								var rect = piece.querySelector('rect');
								var originalColor = piece.getAttribute('data-piece-color');
								
								if (isOutOfBounds) {
									rect.setAttribute('fill', '##ff0000'); // Kırmızı
									rect.setAttribute('opacity', '0.8');
								} else {
									rect.setAttribute('fill', originalColor);
									rect.setAttribute('opacity', '0.7');
								}
							}
							
							// Mouse move - pan veya parça sürükleme
							svg.addEventListener('mousemove', function(e) {
								if (isDraggingPiece && draggedPiece) {
									// Parça sürükleme
									var rect = svg.getBoundingClientRect();
									var currentViewBox = svg.viewBox.baseVal;
									var viewBoxWidth = currentViewBox.width;
									var viewBoxHeight = currentViewBox.height;
									
									// Mouse hareketini viewBox koordinatlarına çevir
									var dx = (e.clientX - startX) * (viewBoxWidth / rect.width);
									var dy = (e.clientY - startY) * (viewBoxHeight / rect.height);
									
									// Parça pozisyonunu güncelle
									var newX = pieceStartX + dx;
									var newY = pieceStartY + dy;
									
									var pieceWidth = parseFloat(draggedPiece.getAttribute('data-piece-width'));
									var pieceHeight = parseFloat(draggedPiece.getAttribute('data-piece-height'));
									
								// Sınır kontrolü
								var isOutOfBounds = !checkBounds(draggedPiece, newX, newY);
								
								// Çarpışma kontrolü (kerf payı ile) - her zaman kontrol et
								var hasCollision = checkCollision(draggedPiece, newX, newY, kerfAllowance);
								
								// Çarpışma varsa pozisyonu güncelleme
								if (!hasCollision) {
									// Sheet sınırları içinde tut (ama sınırlar dışına çıkabilir - kırmızı olacak)
									newX = Math.max(-pieceWidth * 0.5, Math.min(sheetWidth - pieceWidth * 0.5, newX));
									newY = Math.max(-pieceHeight * 0.5, Math.min(sheetHeight - pieceHeight * 0.5, newY));
									
									// Döndürme açısını al
									var rotation = parseFloat(draggedPiece.getAttribute('data-piece-rotation')) || 0;
									var centerX = pieceWidth / 2;
									var centerY = pieceHeight / 2;
									
									// Transform'u güncelle (translate + rotate)
									if (rotation === 0) {
										draggedPiece.setAttribute('transform', 'translate(' + newX + ', ' + newY + ')');
									} else {
										draggedPiece.setAttribute('transform', 'translate(' + newX + ', ' + newY + ') rotate(' + rotation + ' ' + centerX + ' ' + centerY + ')');
									}
									
									draggedPiece.setAttribute('data-piece-x', newX);
									draggedPiece.setAttribute('data-piece-y', newY);
									
									// Son değiştirilen parçayı güncelle
									lastModifiedPiece = draggedPiece;
									
									// Renk güncelle
									updatePieceColor(draggedPiece, isOutOfBounds);
								}
								} else if (isDragging) {
									// Pan (sheet sürükleme)
									var rect = svg.getBoundingClientRect();
									var currentViewBox = svg.viewBox.baseVal;
									var viewBoxWidth = currentViewBox.width;
									var viewBoxHeight = currentViewBox.height;
									
									// Pan miktarını viewBox koordinatlarına çevir
									var dx = (e.clientX - startX) * (viewBoxWidth / rect.width);
									var dy = (e.clientY - startY) * (viewBoxHeight / rect.height);
									
									// ViewBox'ı kaydır
									var newViewBoxX = currentViewBox.x - dx;
									var newViewBoxY = currentViewBox.y - dy;
									svg.setAttribute('viewBox', newViewBoxX + ' ' + newViewBoxY + ' ' + viewBoxWidth + ' ' + viewBoxHeight);
									
									startX = e.clientX;
									startY = e.clientY;
								}
							});
								
							// Mouse up - pan veya parça sürükleme bitir
							svg.addEventListener('mouseup', function(e) {
								if (e.button === 0) {
									if (isDraggingPiece && draggedPiece) {
										// Parça sürükleme bittiğinde pozisyonu kaydet
										savePiecePosition(draggedPiece);
										isDraggingPiece = false;
										draggedPiece.style.cursor = 'move';
										draggedPiece = null;
									} else {
										isDragging = false;
										svg.style.cursor = 'grab';
									}
								}
							});
							
							// Mouse leave - pan veya parça sürükleme bitir
							svg.addEventListener('mouseleave', function(e) {
								if (isDraggingPiece && draggedPiece) {
									isDraggingPiece = false;
									draggedPiece.style.cursor = 'move';
									draggedPiece = null;
								}
								isDragging = false;
								svg.style.cursor = 'grab';
							});
								
								
							// Çift tıklama ile reset
							svg.addEventListener('dblclick', function(e) {
								currentScale = 1;
								svg.setAttribute('viewBox', '0 0 ' + sheetWidth + ' ' + sheetHeight);
							});
							
							// Ctrl+Z ile undo (parça pozisyonunu geri al)
							document.addEventListener('keydown', function(e) {
								if (e.ctrlKey && (e.key === 'z' || e.key === 'Z') && !e.shiftKey) {
									e.preventDefault();
									e.stopPropagation();
									
									// Son değiştirilen parçayı geri al
									if (lastModifiedPiece && lastModifiedPiece.parentNode) {
										var success = undoPiecePosition(lastModifiedPiece);
										if (!success) {
											// Undo başarısız, tüm parçaları kontrol et
											var allPieces = svg.querySelectorAll('.draggable-piece');
											for (var i = allPieces.length - 1; i >= 0; i--) {
												if (undoPiecePosition(allPieces[i])) {
													lastModifiedPiece = allPieces[i];
													break;
												}
											}
										}
									} else {
										// Son değiştirilen parça yoksa, tüm parçaları kontrol et
										var allPieces = svg.querySelectorAll('.draggable-piece');
										for (var i = allPieces.length - 1; i >= 0; i--) {
											if (undoPiecePosition(allPieces[i])) {
												lastModifiedPiece = allPieces[i];
												break;
											}
										}
									}
								}
							}, true); // Capture phase'de dinle
							
							// SVG hazır olduğunda tüm parçaların başlangıç pozisyonlarını kaydet
							setTimeout(function() {
								var allPieces = svg.querySelectorAll('.draggable-piece');
								for (var i = 0; i < allPieces.length; i++) {
									savePiecePosition(allPieces[i]);
								}
							}, 100);
						})();
					</script>
						
					<!--- İstatistikler (detay tablosundaki mantıkla hesapla) --->
					<cfset sheetCount = get_all_sheets.recordcount>
					<cfif isDefined("get_total_used_amount") and get_total_used_amount.recordcount and isNumeric(get_total_used_amount.TOTAL_USED_AMOUNT)>
						<cfset totalUsedAmount = get_total_used_amount.TOTAL_USED_AMOUNT>
					<cfelse>
						<cfset totalUsedAmount = 0>
					</cfif>
					<!--- Tek levha alanı m² cinsinden (TAM plaka boyutu, trim düşülmeden) --->
					<cfif get_material_dimensions.recordcount and ListLen(get_material_dimensions.DIMENTION, '*') gte 2>
						<cfset fullSheetWidth = val(ListGetAt(get_material_dimensions.DIMENTION, 1, '*'))>
						<cfset fullSheetHeight = val(ListGetAt(get_material_dimensions.DIMENTION, 2, '*'))>
					<cfelse>
						<cfset fullSheetWidth = 2100>
						<cfset fullSheetHeight = 2800>
					</cfif>
					<cfset singleSheetArea = (fullSheetWidth * fullSheetHeight) / 1000000>
					<!--- Fire alanı: (singleSheetArea * SHEET_COUNT) - TOTAL_USED_AMOUNT --->
					<cfset totalFireArea = (singleSheetArea * sheetCount) - totalUsedAmount>
					<!--- Fire oranı: Fire / (singleSheetArea * SHEET_COUNT) * 100 --->
					<cfset totalSheetArea = singleSheetArea * sheetCount>
					<cfif totalSheetArea gt 0>
						<cfset firePercent = (totalFireArea / totalSheetArea) * 100>
					<cfelse>
						<cfset firePercent = 0>
					</cfif>
					<!--- Toplam Kesim Uzunluğu Hesapla (mm → metre) --->
					<cfset totalCuttingLength = 0>
					<cfif get_pieces.recordcount>
						<cfloop query="get_pieces">
							<cfset totalCuttingLength = totalCuttingLength + (2 * (WIDTH + HEIGHT))>
						</cfloop>
					</cfif>
					<cfset totalCuttingLengthMeter = totalCuttingLength / 1000>
					<!--- İstatistikler ve İstasyon Bilgileri Tablosu --->
					<div style="margin-top:15px;">
						<cf_grid_list>
							<thead>
								<tr style="background-color:##e8e8e8;">
									<th style="width:200px; text-align:left; padding:8px;">Bilgi</th>
									<th style="text-align:right; padding:8px;">Değer</th>
								</tr>
							</thead>
							<tbody>
								<!--- İstasyon Bilgileri --->
								<cfif get_material_settings.recordcount>
									<tr>
										<td style="padding:6px; background-color:##f9f9f9;"><strong>İstasyon Adı</strong></td>
										<td style="text-align:right; padding:6px; background-color:##f9f9f9;">#get_material_settings.STATION_NAME#</td>
									</tr>
									<tr>
										<td style="padding:6px;"><strong>Daire Testere Kalınlığı</strong></td>
										<td style="text-align:right; padding:6px;">
											<cfif isNumeric(get_material_settings.CIRCLE_TESTRE_THICKNESS) and val(get_material_settings.CIRCLE_TESTRE_THICKNESS) gt 0>
												#numberFormat(get_material_settings.CIRCLE_TESTRE_THICKNESS, "9.99")# mm
											<cfelse>
												-
											</cfif>
										</td>
									</tr>
								<tr>
									<td style="padding:6px; background-color:##f9f9f9;"><strong>Dış Kenar Traşlama Payı</strong></td>
									<td style="text-align:right; padding:6px; background-color:##f9f9f9;">
										<cfif isNumeric(get_material_settings.OUTER_EDGE_TRIMMING_ALLOWANCE) and val(get_material_settings.OUTER_EDGE_TRIMMING_ALLOWANCE) gt 0>
											#numberFormat(get_material_settings.OUTER_EDGE_TRIMMING_ALLOWANCE, "9.99")# mm
										<cfelse>
											-
										</cfif>
									</td>
								</tr>
								<tr>
									<td style="padding:6px;"><strong>Kesim Yöntemi</strong></td>
									<td style="text-align:right; padding:6px;">
										<cfif isNumeric(get_material_settings.CUTTING_METHOD) and val(get_material_settings.CUTTING_METHOD) EQ 1>
											Saf Giyotin
										<cfelseif isNumeric(get_material_settings.CUTTING_METHOD) and val(get_material_settings.CUTTING_METHOD) EQ 2>
											Hibrit
										<cfelse>
											-
										</cfif>
									</td>
								</tr>
								<tr>
									<td style="padding:6px; background-color:##f9f9f9;"><strong>Kesim Başlama Yönü</strong></td>
									<td style="text-align:right; padding:6px; background-color:##f9f9f9;">
										<cfif isNumeric(get_material_settings.CUTTING_STARTING_DIRECTION) and val(get_material_settings.CUTTING_STARTING_DIRECTION) EQ 1>
											Plaka Yatay Kesim
										<cfelseif isNumeric(get_material_settings.CUTTING_STARTING_DIRECTION) and val(get_material_settings.CUTTING_STARTING_DIRECTION) EQ 2>
											Plaka Dikey Kesim
										<cfelse>
											-
										</cfif>
									</td>
								</tr>
								<tr>
									<td style="padding:6px;"><strong>Maximum Plaka Kat</strong></td>
									<td style="text-align:right; padding:6px;">
										<cfif isNumeric(get_material_settings.MAXIMUM_NUMBER_OF_CUTS) and val(get_material_settings.MAXIMUM_NUMBER_OF_CUTS) gt 0>
											#val(get_material_settings.MAXIMUM_NUMBER_OF_CUTS)#
										<cfelse>
											-
										</cfif>
									</td>
								</tr>
							</cfif>
								<!--- Ayırıcı Satır --->
								<tr>
									<td colspan="2" style="height:5px; background-color:##ddd;"></td>
								</tr>
								<!--- Alan İstatistikleri --->
								<tr>
									<td style="padding:6px;"><strong>Plakadaki Kesim Uzunluğu</strong></td>
									<td style="text-align:right; padding:6px;">#numberFormat(totalCuttingLengthMeter, "9.99")# m</td>
								</tr>
								<tr>
									<td style="padding:6px; background-color:##f9f9f9;"><strong>Toplam Kesim Uzunluğu</strong></td>
									<td style="text-align:right; padding:6px; background-color:##f9f9f9;">#numberFormat(totalCuttingLengthMeter * get_all_sheets.recordcount, "9.99")# m</td>
								</tr>
								<tr>
									<td style="padding:6px;"><strong>Katlı Kesim Uzunluğu</strong></td>
									<td style="text-align:right; padding:6px;">
										<cfif get_material_settings.recordcount and isNumeric(get_material_settings.MAXIMUM_NUMBER_OF_CUTS) and val(get_material_settings.MAXIMUM_NUMBER_OF_CUTS) gt 0>
											#numberFormat(totalCuttingLengthMeter * ceiling(get_all_sheets.recordcount / val(get_material_settings.MAXIMUM_NUMBER_OF_CUTS)), "9.99")# m
										<cfelse>
											#numberFormat(totalCuttingLengthMeter * get_all_sheets.recordcount, "9.99")# m
										</cfif>
									</td>
								</tr>
								<tr>
									<td style="padding:6px; background-color:##f9f9f9;"><strong>Kullanılan Alan</strong></td>
									<td style="text-align:right; padding:6px; background-color:##f9f9f9;">#numberFormat(totalUsedAmount, "9.99")# m²</td>
								</tr>
								<tr>
									<td style="padding:6px; background-color:##f9f9f9;"><strong>Fire Alanı</strong></td>
									<td style="text-align:right; padding:6px; background-color:##f9f9f9;">#numberFormat(totalFireArea, "9.99")# m²</td>
								</tr>
								<tr>
									<td style="padding:6px;"><strong>Fire Oranı</strong></td>
									<td style="text-align:right; padding:6px;">#numberFormat(firePercent, "9.99")#%</td>
								</tr>
								<!--- Ayırıcı Satır --->
								<tr>
									<td colspan="2" style="height:5px; background-color:##ddd;"></td>
								</tr>
								<!--- Sayısal Bilgiler --->
								<tr>
									<td style="padding:6px; background-color:##f9f9f9;"><strong>Parça Sayısı</strong></td>
									<td style="text-align:right; padding:6px; background-color:##f9f9f9;">#get_pieces.recordcount#</td>
								</tr>
								<tr>
									<td style="padding:6px;"><strong>Sheet Sayısı (Aynı Yerleşim)</strong></td>
									<td style="text-align:right; padding:6px;">#get_all_sheets.recordcount#</td>
								</tr>
								<tr>
									<td style="padding:6px; background-color:##f9f9f9;"><strong>Katlı Kesim Adedi</strong></td>
									<td style="text-align:right; padding:6px; background-color:##f9f9f9;">
										<cfif get_material_settings.recordcount and isNumeric(get_material_settings.MAXIMUM_NUMBER_OF_CUTS) and val(get_material_settings.MAXIMUM_NUMBER_OF_CUTS) gt 0>
											#ceiling(get_all_sheets.recordcount / val(get_material_settings.MAXIMUM_NUMBER_OF_CUTS))#
										<cfelse>
											#get_all_sheets.recordcount#
										</cfif>
									</td>
								</tr>
							</tbody>
						</cf_grid_list>
					</div>
					</cfoutput>
				</div>
			</cf_box>
		</cf_box>
	<cfelse>
		<cf_box>
			<cf_box title="Hata">
				<div class="col col-12">
					<p style="color:red;">Sheet bilgileri bulunamadı.</p>
				</div>
			</cf_box>
		</cf_box>
	</cfif>
<cfelse>
	<cf_box>
		<cf_box title="Hata">
			<div class="col col-12">
				<p style="color:red;">Geçersiz optimizasyon ID.</p>
			</div>
		</cf_box>
	</cf_box>
</cfif>
