<!--- <cfparam name="attributes.page" default="1">
<cfparam name="attributes.maxrows" default= 20>
<cfparam name="attributes.startrow" default= 1> --->

<style>
	.product_card{
		height:300px;
		margin-top:10px;
	}
	.product {
		position: relative;
		width: 100%;
		height: 170px;
		border-radius: 12px;
		overflow: hidden;
		background: linear-gradient(135deg, #f5f7fa 0%, #e8ecf1 100%);
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
		transition: all 0.3s ease;
	}
	.product:hover {
		box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
		transform: translateY(-2px);
	}
	.slider {
		position: relative;
		overflow: hidden;
		width: 100%;
		height: 100%;
		background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
		border-radius: 12px;
		display: flex;
		align-items: center;
		justify-content: center;
	}
	.slider a {
		display: block;
		width: 100%;
		height: 100%;
		position: relative;
	}
	.slider img {
		height: 150px;
		object-fit: contain;
		position: absolute;
		left: 50%;
		top: 50%;
		transform: translate(-50%, -50%);
		max-width: 90%;
		opacity: 0;
		transition: opacity 0.4s ease-in-out, transform 0.4s ease-in-out;
		filter: drop-shadow(0 2px 8px rgba(0, 0, 0, 0.1));
	}
	.slider img.active {
		opacity: 1;
		transform: translate(-50%, -50%) scale(1);
	}
	.slider .no-image-placeholder {
		position: absolute;
		left: 50%;
		top: 50%;
		transform: translate(-50%, -50%);
		width: 80px;
		height: 80px;
		display: flex;
		align-items: center;
		justify-content: center;
		color: #cbd5e0;
		font-size: 48px;
		opacity: 0.5;
	}
	.slider .no-image-placeholder i {
		font-size: 48px;
	}
	.prevBtn,
	.nextBtn {
		position: absolute;
		top: 50%;
		transform: translateY(-50%);
		width: 40px;
		height: 40px;
		font-size: 14px;
		font-weight: 600;
		color: #fff;
		background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
		border: 2px solid rgba(255, 255, 255, 0.3);
		outline: none;
		padding: 0;
		cursor: pointer;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 4px 12px rgba(68, 182, 174, 0.4);
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
		z-index: 10;
		opacity: 0;
		backdrop-filter: blur(10px);
	}
	.prevBtn i,
	.nextBtn i {
		font-size: 14px;
		line-height: 1;
	}
	.product:hover .prevBtn,
	.product:hover .nextBtn {
		opacity: 1;
	}
	.prevBtn:hover,
	.nextBtn:hover {
		background: linear-gradient(135deg, #4a7bc8 0%, #3a9d96 100%);
		box-shadow: 0 6px 16px rgba(68, 182, 174, 0.5);
		transform: translateY(-50%) scale(1.15);
		border-color: rgba(255, 255, 255, 0.5);
	}
	.prevBtn:active,
	.nextBtn:active {
		transform: translateY(-50%) scale(0.95);
	}
	.prevBtn {
		left: 8px;
	}
	.nextBtn {
		right: 8px;
	}
	@media screen and (max-width:1200px){
		.prevBtn,
		.nextBtn {
			width: 32px;
			height: 32px;
		}
		.prevBtn i,
		.nextBtn i {
			font-size: 12px;
		}
		.prevBtn {
			left: 6px;
		}
		.nextBtn {
			right: 6px;
		}
		.tabNavNew{
            height: 75px!important;
            align-items: normal!important;
        }
        .tabNavNew li{
            display:flex!important;
            width:105px!important;
        }
        .tabNavNew li a{
            width: 150px!important;
            text-align: center!important;
            font-size: 17px!important;
            display: flex!important;
            align-content: center!important;
            justify-content: center!important;
            align-items: center!important;
        }
	}
	/* Ürün Ekleme Butonu Modernizasyonu */
	.addBasket {
		position: relative;
		height: 50px;
		text-align: center;
		vertical-align: middle;
		display: flex;
		align-items: center;
		justify-content: center;
	}
	.addBasket a {
		text-decoration: none;
		display: block;
		width: 100%;
		height: 100%;
	}
	.add-to-cart-btn {
		width: 100% !important;
		font-size: 13px !important;
		border-radius: 10px !important;
		font-weight: 600 !important;
		height: 40px !important;
		border: none !important;
		background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%) !important;
		color: white !important;
		box-shadow: 0 3px 10px rgba(68, 182, 174, 0.35) !important;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
		cursor: pointer !important;
		display: flex !important;
		align-items: center !important;
		justify-content: center !important;
		position: relative !important;
		overflow: hidden !important;
		gap: 6px;
	}
	.add-to-cart-btn::before {
		content: '';
		position: absolute;
		top: 0;
		left: -100%;
		width: 100%;
		height: 100%;
		background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
		transition: left 0.5s ease;
	}
	.add-to-cart-btn:hover {
		background: linear-gradient(135deg, #4a7bc8 0%, #3a9d96 100%) !important;
		box-shadow: 0 5px 15px rgba(68, 182, 174, 0.45) !important;
		transform: translateY(-2px) !important;
	}
	.add-to-cart-btn:hover::before {
		left: 100%;
	}
	.add-to-cart-btn:active {
		transform: translateY(0) !important;
		box-shadow: 0 2px 8px rgba(68, 182, 174, 0.3) !important;
	}
	.add-to-cart-btn i {
		font-size: 16px !important;
		transition: transform 0.3s ease;
		z-index: 1;
	}
	.add-to-cart-btn:hover i {
		transform: scale(1.15) rotate(-5deg);
	}
	.add-to-cart-btn .cart-text {
		font-size: 13px !important;
		color: white !important;
		font-weight: 600 !important;
		z-index: 1;
	}
	.add-to-cart-btn .cart-count {
		font-size: 13px !important;
		color: white !important;
		font-weight: 700 !important;
		background: rgba(255, 255, 255, 0.25);
		padding: 3px 10px;
		border-radius: 15px;
		transition: all 0.3s ease;
		z-index: 1;
		border: 1px solid rgba(255, 255, 255, 0.3);
	}
	.add-to-cart-btn:hover .cart-count {
		background: rgba(255, 255, 255, 0.35);
		transform: scale(1.1);
		border-color: rgba(255, 255, 255, 0.5);
	}
	/* Loading state */
	.add-to-cart-btn.loading {
		pointer-events: none;
		opacity: 0.7;
	}
	.add-to-cart-btn.loading i {
		animation: spin 1s linear infinite;
	}
	@keyframes spin {
		from { transform: rotate(0deg); }
		to { transform: rotate(360deg); }
	}
	/* Select Container */
	.select-container {
		height: 50px;
		text-align: center;
		vertical-align: middle;
		display: flex;
		align-items: center;
		justify-content: center;
	}
	.select-container a {
		width: 100%;
		height: 100%;
		display: block;
		text-decoration: none;
	}
	/* Select Butonu Modernizasyonu */
	.select-amount-btn,
	[name="selecting"] {
		width: 100% !important;
		font-size: 12px !important;
		font-weight: 600 !important;
		height: 40px !important;
		border: 2px solid #e9ecef !important;
		background: white !important;
		border-radius: 10px !important;
		transition: all 0.3s ease !important;
		cursor: pointer !important;
		position: relative !important;
		box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08) !important;
	}
	[name="selecting"]:hover {
		border-color: #5f8ee1 !important;
		box-shadow: 0 4px 12px rgba(95, 142, 225, 0.2) !important;
		transform: translateY(-1px) !important;
	}
	.select-amount-btn select,
	[name="selecting"] select,
	.amount-select {
		font-size: 13px !important;
		font-weight: 600 !important;
		height: 100% !important;
		width: 100% !important;
		background-color: transparent !important;
		border: none !important;
		padding: 0 10px !important;
		cursor: pointer !important;
		color: #495057 !important;
		appearance: none !important;
		-webkit-appearance: none !important;
		-moz-appearance: none !important;
		background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%235f8ee1' d='M6 9L1 4h10z'/%3E%3C/svg%3E") !important;
		background-repeat: no-repeat !important;
		background-position: right 10px center !important;
		background-size: 12px !important;
		padding-right: 30px !important;
	}
	.select-amount-btn select:focus,
	[name="selecting"] select:focus,
	.amount-select:focus {
		outline: none !important;
	}
	.select-amount-btn select option,
	[name="selecting"] select option,
	.amount-select option {
		padding: 10px !important;
		font-weight: 500 !important;
	}
	.select-amount-btn select option:hover,
	[name="selecting"] select option:hover,
	.amount-select option:hover {
		background-color: #f8f9fa !important;
	}
	.select-amount-btn select option:checked,
	[name="selecting"] select option:checked,
	.amount-select option:checked {
		background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%) !important;
		color: white !important;
	}

	#tab-list .first-li{
        font-weight: 600;
        border-right: 2px solid rgba(255, 255, 255, 0.2);
        text-align: center;
        width:100px;
        background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
        color: #fff;
        flex:none;
        display: flex;
        align-items: center;
        justify-content: center;
        position:sticky;
        left:0;
        box-shadow: 0 2px 8px rgba(68, 182, 174, 0.3);
        transition: all 0.3s ease;
    }
    #tab-list .first-li:hover {
        box-shadow: 0 4px 12px rgba(68, 182, 174, 0.4);
        transform: translateY(-1px);
    }
    #tab-list .first-li a,a:hover{
        color: #fff;
        text-decoration: none;
    }
    #tab-list .other-li{
        padding:0px;
        font-size:14px;
        transition: all 0.3s ease;
    }
    #tab-list .other-li a{
        width:150px;
        text-align:center;
        padding: 10px 15px;
        display: block;
        border-radius: 8px;
        transition: all 0.3s ease;
        color: #495057;
        font-weight: 500;
    }
    #tab-list .other-li a:hover {
        background-color: #f8f9fa;
        transform: translateY(-2px);
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
    }
    .parent_li{
        background: linear-gradient(135deg, rgba(95, 142, 225, 0.15) 0%, rgba(68, 182, 174, 0.15) 100%);
        border-radius: 8px;
    }
    .parent_li a.active {
        background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
        color: #fff !important;
        font-weight: 600;
        box-shadow: 0 2px 8px rgba(68, 182, 174, 0.3);
    }
    .parent_li a.active:hover {
        box-shadow: 0 4px 12px rgba(68, 182, 174, 0.4);
        transform: translateY(-2px);
    }
    .tabNavNew{
        display: flex!important;
        overflow-x: auto!important;
        overflow-y: hidden!important;
        height: auto!important;
        width: 100%!important;
        flex-wrap: nowrap!important;
        justify-content: flex-start!important;
        align-items: normal!important;
        scrollbar-width: thin;
        scrollbar-color: rgba(95, 142, 225, 0.5) rgba(0, 0, 0, 0.05);
        padding: 8px 0;
    }
    .tabNavNew::-webkit-scrollbar {
        height: 8px;
    }
    .tabNavNew::-webkit-scrollbar-track {
        background: rgba(0, 0, 0, 0.05);
        border-radius: 10px;
    }
    .tabNavNew::-webkit-scrollbar-thumb {
        background: linear-gradient(135deg, rgba(95, 142, 225, 0.6) 0%, rgba(68, 182, 174, 0.6) 100%);
        border-radius: 10px;
        transition: all 0.3s ease;
    }
    .tabNavNew::-webkit-scrollbar-thumb:hover {
        background: linear-gradient(135deg, rgba(95, 142, 225, 0.8) 0%, rgba(68, 182, 174, 0.8) 100%);
    }
    /* Ara Butonu Modernizasyonu */
    #buton {
        background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%) !important;
        border: none !important;
        border-radius: 8px !important;
        color: #fff !important;
        font-weight: 600 !important;
        box-shadow: 0 2px 8px rgba(68, 182, 174, 0.3) !important;
        transition: all 0.3s ease !important;
        cursor: pointer !important;
        text-transform: uppercase !important;
        letter-spacing: 0.5px !important;
    }
    #buton:hover {
        background: linear-gradient(135deg, #4a7bc8 0%, #3a9d96 100%) !important;
        box-shadow: 0 4px 12px rgba(68, 182, 174, 0.4) !important;
        transform: translateY(-2px) !important;
    }
    #buton:active {
        transform: translateY(0) !important;
        box-shadow: 0 2px 6px rgba(68, 182, 174, 0.3) !important;
    }
    /* Scroll Content Modernizasyonu */
    .scrollContent {
        scrollbar-width: thin;
        scrollbar-color: rgba(95, 142, 225, 0.5) rgba(0, 0, 0, 0.05);
    }
    .scrollContent::-webkit-scrollbar {
        height: 8px;
    }
    .scrollContent::-webkit-scrollbar-track {
        background: rgba(0, 0, 0, 0.05);
        border-radius: 10px;
    }
    .scrollContent::-webkit-scrollbar-thumb {
        background: linear-gradient(135deg, rgba(95, 142, 225, 0.6) 0%, rgba(68, 182, 174, 0.6) 100%);
        border-radius: 10px;
        transition: all 0.3s ease;
    }
    .scrollContent::-webkit-scrollbar-thumb:hover {
        background: linear-gradient(135deg, rgba(95, 142, 225, 0.8) 0%, rgba(68, 182, 174, 0.8) 100%);
    }
    /* Checkbox Modernizasyonu */
    .category_checkbox {
        cursor: pointer;
    }
    .checbox-switch input[type="checkbox"]:checked + span {
        background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%) !important;
        box-shadow: 0 2px 6px rgba(68, 182, 174, 0.4) !important;
    }
    .checbox-switch input[type="checkbox"] + span {
        transition: all 0.3s ease !important;
    }
    .checbox-switch input[type="checkbox"]:checked + span:hover {
        box-shadow: 0 4px 10px rgba(68, 182, 174, 0.5) !important;
    }
    /* Kategori Label Modernizasyonu */
    [id^="prop_detail_"] label {
        transition: all 0.3s ease;
        padding: 8px 12px;
        border-radius: 6px;
        cursor: pointer;
    }
    [id^="prop_detail_"]:hover label {
        background-color: rgba(95, 142, 225, 0.05);
    }
    /* Modern Sepet Gösterimi */
    .basket-counter-modern {
        position: relative;
    }
    .modern-basket-display {
        display: flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
        padding: 12px 20px;
        border-radius: 50px;
        box-shadow: 0 4px 15px rgba(68, 182, 174, 0.4);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        cursor: pointer;
        min-width: 60px;
    }
    .modern-basket-display:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(68, 182, 174, 0.5);
        background: linear-gradient(135deg, #4a7bc8 0%, #3a9d96 100%);
    }
    .modern-basket-display:active {
        transform: translateY(0);
        box-shadow: 0 3px 12px rgba(68, 182, 174, 0.4);
    }
    .basket-icon-wrapper {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .modern-basket-display .fa-shopping-basket {
        font-size: 22px;
        color: #fff;
        transition: transform 0.3s ease;
    }
    .modern-basket-display:hover .fa-shopping-basket {
        transform: scale(1.1) rotate(-5deg);
    }
    .basket-badge {
        position: absolute;
        top: -10px;
        right: -14px;
        background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%);
        color: #fff;
        font-size: 13px;
        font-weight: 700;
        padding: 4px 10px;
        border-radius: 14px;
        min-width: 24px;
        text-align: center;
        box-shadow: 0 3px 10px rgba(255, 107, 107, 0.5);
        border: 2.5px solid #fff;
        line-height: 1.2;
        animation: pulse 2s infinite;
        z-index: 10;
    }
    @keyframes pulse {
        0%, 100% {
            transform: scale(1);
        }
        50% {
            transform: scale(1.05);
        }
    }
    .basket-amount-text {
        font-size: 18px;
        font-weight: 700;
        color: #fff;
        letter-spacing: 0.5px;
        text-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
        transition: all 0.3s ease;
    }
    .modern-basket-display:hover .basket-amount-text {
        transform: scale(1.05);
    }
    /* Sepet miktarı 0 olduğunda badge'i gizle */
    .basket-badge:empty {
        display: none;
    }
    /* Responsive */
    @media screen and (max-width: 768px) {
        .modern-basket-display {
            padding: 10px 16px;
            min-width: 100px;
        }
        .modern-basket-display .fa-shopping-basket {
            font-size: 18px;
        }
        .basket-badge {
            font-size: 10px;
            padding: 2px 6px;
        }
    }
    /* Sepet İçi Miktar Gösterimi Modernizasyonu */
    input[name^="quantity"] {
        border: 2px solid #e9ecef !important;
        border-radius: 8px !important;
        padding: 8px 12px !important;
        font-size: 14px !important;
        font-weight: 600 !important;
        color: #495057 !important;
        background: #fff !important;
        transition: all 0.3s ease !important;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05) !important;
    }
    input[name^="quantity"]:focus {
        outline: none !important;
        border-color: #5f8ee1 !important;
        box-shadow: 0 0 0 3px rgba(95, 142, 225, 0.1) !important;
        transform: scale(1.02);
    }
    input[name^="quantity"]:hover {
        border-color: #44b6ae !important;
        box-shadow: 0 2px 8px rgba(68, 182, 174, 0.15) !important;
    }
    /* Sepet Grid Tablosu Modernizasyonu */
    #basket_bar table {
        border-collapse: separate;
        border-spacing: 0;
    }
    #basket_bar table tbody tr {
        transition: all 0.2s ease;
    }
    #basket_bar table tbody tr:hover {
        background-color: rgba(95, 142, 225, 0.03);
        transform: scale(1.001);
    }
    #basket_bar table tbody td {
        padding: 12px 8px !important;
        border-bottom: 1px solid #e9ecef;
    }
    #basket_bar table thead th {
        background: linear-gradient(135deg, #5f8ee1 0%, #44b6ae 100%);
        color: #fff;
        font-weight: 600;
        padding: 12px 8px !important;
        border: none;
        text-align: center;
    }
    #basket_bar table thead th:first-child {
        border-radius: 8px 0 0 0;
    }
    #basket_bar table thead th:last-child {
        border-radius: 0 8px 0 0;
    }
    /* Confirm Animation - Başarı Animasyonu */
    .confirm-animation {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        z-index: 10000;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        pointer-events: none;
    }
    .confirm-animation-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.1);
        backdrop-filter: blur(2px);
        -webkit-backdrop-filter: blur(2px);
        z-index: 9999;
        opacity: 0;
        animation: fadeInOverlay 0.3s ease-out forwards;
    }
    .confirm-animation-box {
        background: rgba(81, 207, 102, 0.85);
        background: linear-gradient(135deg, rgba(81, 207, 102, 0.9) 0%, rgba(64, 192, 87, 0.9) 100%);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-radius: 20px;
        padding: 40px 50px;
        box-shadow: 0 10px 40px rgba(81, 207, 102, 0.3);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-width: 200px;
        animation: scaleIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    }
    .confirm-checkmark {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.15);
        backdrop-filter: blur(5px);
        -webkit-backdrop-filter: blur(5px);
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 20px;
        position: relative;
        animation: checkmarkPulse 0.6s ease-out 0.3s;
    }
    .confirm-checkmark::before {
        content: '';
        position: absolute;
        width: 100%;
        height: 100%;
        border-radius: 50%;
        border: 2px solid rgba(255, 255, 255, 0.25);
        animation: checkmarkCircle 0.6s ease-out forwards;
    }
    .confirm-checkmark i {
        font-size: 50px;
        color: #fff;
        z-index: 1;
        animation: checkmarkIcon 0.5s ease-out 0.2s forwards;
        opacity: 0;
        transform: scale(0);
    }
    .confirm-message {
        color: #fff;
        font-size: 18px;
        font-weight: 600;
        text-align: center;
        animation: fadeInUp 0.5s ease-out 0.4s forwards;
        opacity: 0;
        transform: translateY(10px);
    }
    @keyframes fadeInOverlay {
        from {
            opacity: 0;
        }
        to {
            opacity: 1;
        }
    }
    @keyframes scaleIn {
        from {
            transform: scale(0);
            opacity: 0;
        }
        to {
            transform: scale(1);
            opacity: 1;
        }
    }
    @keyframes checkmarkPulse {
        0% {
            transform: scale(1);
        }
        50% {
            transform: scale(1.1);
        }
        100% {
            transform: scale(1);
        }
    }
    @keyframes checkmarkCircle {
        0% {
            transform: scale(0.8);
            opacity: 1;
        }
        100% {
            transform: scale(1.3);
            opacity: 0;
        }
    }
    @keyframes checkmarkIcon {
        0% {
            transform: scale(0) rotate(-45deg);
            opacity: 0;
        }
        50% {
            transform: scale(1.2) rotate(5deg);
            opacity: 1;
        }
        100% {
            transform: scale(1) rotate(0deg);
            opacity: 1;
        }
    }
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    @keyframes fadeOutConfirm {
        from {
            opacity: 1;
            transform: scale(1);
        }
        to {
            opacity: 0;
            transform: scale(0.8);
        }
    }
    .confirm-animation.fade-out {
        animation: fadeOutConfirm 0.3s ease-in forwards;
    }
    .confirm-animation-overlay.fade-out {
        animation: fadeOutOverlay 0.3s ease-in forwards;
    }
    @keyframes fadeOutOverlay {
        from {
            opacity: 1;
        }
        to {
            opacity: 0;
        }
    }
</style>
<cfinclude template="basket_ezgi_connect_queries.cfm">
<cfset get_property_group_list = ValueList(get_property_group.PROPERTY_ID)>
<cfset url_str = "">
<cfif ListLen(get_property_group_list)>
	<cfset url_str = "#url_str#&property_group_list=#get_property_group_list#">
</cfif>
<cfset checked_id_list =''>
<cfloop list="#get_property_group_list#" index="ii">
	<cfif isdefined('attributes.categori_id_list_#ii#') and len(Evaluate('attributes.categori_id_list_#ii#'))>
		<cfset url_str = "#url_str#&categori_id_list_#ii#=#Evaluate('attributes.categori_id_list_#ii#')#">
        <cfset checked_id_list ="#checked_id_list##Evaluate('attributes.categori_id_list_#ii#')#,">
    </cfif>
</cfloop>
<cfset related_id_list = ''>
<cfset checked_id_list = ListDeleteDuplicates(checked_id_list,',')>
	<cfif ListLen(checked_id_list)>
    <cfquery name="get_related_id" datasource="#dsn#">
        SELECT PROPERTY_DETAIL_ID,VARIATION_ID FROM EZGI_CONNECT_PROPERTY WHERE PROPERTY_DETAIL_ID IN (#checked_id_list#)
    </cfquery>
    <cfset related_id_list = ValueList(get_related_id.VARIATION_ID)>
</cfif>
<cfif isdefined('attributes.is_form_submitted')>
    <cfquery name="get_products" datasource="#dsn3#">
    	WITH CTE1 AS(
			SELECT DISTINCT
				S.PRODUCT_ID, 
				S.STOCK_ID,
				PU.MAIN_UNIT, 
				S.BARCOD, 
				S.PRODUCT_NAME, 
				S.PRODUCT_CODE, 
				S.PRODUCT_CODE_2, 
				S.PROPERTY STOCK_NAME,
				S.TAX,
				S.PRODUCT_CATID, 
				ISNULL(S.BRAND_ID,0) AS BRAND_ID, 
				S.SHORT_CODE_ID,
				S.IS_KARMA
			FROM     
				STOCKS AS S LEFT OUTER JOIN
				<cfloop query="get_property_group">
					(
						SELECT 
							PRODUCT_ID, 
							VARIATION_ID AS CATEGORI_ID
						FROM      
							#dsn1_alias#.PRODUCT_DT_PROPERTIES AS PRODUCT_DT_PROPERTIES_#get_property_group.PROPERTY_ID#
						WHERE   
							VARIATION_ID IN
										(
											SELECT 
												PROPERTY_DETAIL_ID
											FROM      
												#dsn1_alias#.PRODUCT_PROPERTY_DETAIL AS PRODUCT_PROPERTY_DETAIL_#get_property_group.PROPERTY_ID#
											WHERE   
												PRPT_ID = #get_property_group.PROPERTY_ID#
										)
					) AS CATEGORI_#get_property_group.PROPERTY_ID# ON S.PRODUCT_ID = CATEGORI_#get_property_group.PROPERTY_ID#.PRODUCT_ID LEFT OUTER JOIN
				</cfloop>
				#dsn1_alias#.PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
			WHERE
            	<cfif attributes.x_ssh eq 0>  
					S.IS_EXTRANET = 1 AND
                </cfif>
				S.STOCK_STATUS = 1 AND
				S.PRODUCT_STATUS = 1 
                <cfif session.ep.ISBRANCHAUTHORIZATION eq 1 and attributes.x_ssh eq 0>
                	AND S.PRODUCT_ID IN (SELECT PRODUCT_ID FROM #dsn1_alias#.PRODUCT_BRANCH WHERE BRANCH_ID IN (SELECT BRANCH_ID FROM #dsn_alias#.EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE=#session.ep.position_code#))
                </cfif>
                <cfif attributes.sales_type eq 3 and Len(attributes.project_id)>
                	AND S.PRODUCT_ID IN (SELECT PRODUCT_ID FROM #dsn_alias#.EZGI_CONNECT_PROJECT_PRODUCT_ID WHERE PROJECT_ID = #attributes.project_id#)
                </cfif>
				<cfif isdefined('attributes.keyword') and len(attributes.keyword)>
					AND 
						(
							S.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
							S.BARCOD = '#attributes.keyword#'
						)
                  	AND S.PRODUCT_ID IN 
                    					(
                        					SELECT DISTINCT 
                                            	PRODUCT_ID
											FROM     
                                            	#dsn1_alias#.PRODUCT_DT_PROPERTIES
											WHERE  
                                            	VARIATION_ID IN
                      											(
                                                                	SELECT 
                                                                    	PROPERTY_DETAIL_ID
                       												FROM      
                                                                    	#dsn1_alias#.PRODUCT_PROPERTY_DETAIL
                       												WHERE   
                                                                    	PRPT_ID IN (#get_property_group_list#)
                                                              	)
                                         	)
				<cfelse> 
					<cfloop query="get_property_group">
						<cfif isdefined('attributes.categori_id_list_#get_property_group.PROPERTY_ID#') and ListLen(Evaluate('attributes.categori_id_list_#get_property_group.PROPERTY_ID#'))>
							AND CATEGORI_#get_property_group.PROPERTY_ID#.CATEGORI_ID IN (#Evaluate('attributes.categori_id_list_#get_property_group.PROPERTY_ID#')#)
						</cfif>
					</cfloop>
				</cfif>
		),
		CTE2 AS (
			SELECT
				CTE1.*,
				ROW_NUMBER() OVER (
					ORDER BY
						IS_KARMA DESC,
						PRODUCT_CODE_2,
						PRODUCT_NAME
				) AS RowNum,
				(SELECT COUNT(*) FROM CTE1) AS QUERY_COUNT
			FROM
				CTE1
		)
		SELECT
			CTE2.*
		FROM
			CTE2
		WHERE
			RowNum BETWEEN #attributes.startrow# and #attributes.startrow# + (#attributes.maxrows# - 1)
    </cfquery>
    
    <cfset product_id_list = ValueList(get_products.PRODUCT_ID)>
    <cfset stock_id_list = ValueList(get_products.STOCK_ID)>
    <cfif attributes.sales_type eq 3 and Len(attributes.project_id)>
    	<cfquery name="get_project_disc" datasource="#dsn3#">
        	SELECT ISNULL(DISCOUNT_1,0) AS DISCOUNT_1, ISNULL(DISCOUNT_2,0) AS DISCOUNT_2, ISNULL(DISCOUNT_3,0) AS DISCOUNT_3 FROM PROJECT_DISCOUNTS WHERE PROJECT_ID = #attributes.project_id#
        </cfquery>
        <cfif get_project_disc.recordcount>
        	<cfif get_project_disc.DISCOUNT_1 gt 0>
            	<cfset proje_disc1 = get_project_disc.DISCOUNT_1>
            </cfif>
            <cfif get_project_disc.DISCOUNT_2 gt 0>
            	<cfset proje_disc2 = get_project_disc.DISCOUNT_2>
            </cfif>
            <cfif get_project_disc.DISCOUNT_3 gt 0>
            	<cfset proje_disc3 = get_project_disc.DISCOUNT_3>
            </cfif>
        </cfif>
    </cfif>
    <cfif ListLen(product_id_list)>
        <cfquery name="get_images" datasource="#dsn1#">
			SELECT 
				PI.PRODUCT_ID, 
				PI.PRODUCT_IMAGEID, 
				PI.PATH
			FROM     
				PRODUCT_IMAGES AS PI
				JOIN PRODUCT AS P ON P.PRODUCT_ID = PI.PRODUCT_ID
			WHERE   
				PI.PATH IS NOT NULL
				AND P.IS_EXTRANET = 1
                AND P.PRODUCT_ID IN (#product_id_list#)
        </cfquery>
		<cfset product_counter = 0>
		<cfset product_paths = structNew() />
        <cfoutput query="get_images">
			<cfif get_images.PRODUCT_ID eq get_images.PRODUCT_ID[currentRow - 1]>
				<cfset product_counter += 1>
			<cfelse>
				<cfset product_counter = 1>
				<cfset product_paths[PRODUCT_ID] = arrayNew(1) />
			</cfif>
			<cfset product_paths[PRODUCT_ID][product_counter] = PATH />
        </cfoutput>
        <cfif len(get_connect.PRICE_CAT_ID)>
            <cfquery name="GET_PRICE" datasource="#DSN3#">
                SELECT 
                	PRICE_ID,
                	PRODUCT_ID,
                    PRICE, 
                    PRICE_KDV, 
                    IS_KDV, 
                    MONEY
                FROM     
                    PRICE
                WHERE  
                    FINISHDATE IS NULL AND 
                    PRODUCT_ID IN (#product_id_list#) AND 
                    PRICE_CATID = #get_connect.PRICE_CAT_ID#
            </cfquery>
            <cfset price_cat_id=get_connect.PRICE_CAT_ID>
       	<cfelse>
        	<cfquery name="GET_PRICE" datasource="#DSN3#">
                SELECT 
                	PRICE_ID,
                	PRODUCT_ID,
                    PRICE, 
                    PRICE_KDV, 
                    IS_KDV, 
                    MONEY
                FROM     
                    PRICE
                WHERE  
                    FINISHDATE IS NULL AND 
                    PRODUCT_ID IN (#product_id_list#) AND 
                    PRICE_CATID = #attributes.default_pice_cat#
            </cfquery>
            <cfset price_cat_id=attributes.default_pice_cat>
        </cfif>
        <cfif GET_PRICE.recordcount>
        	<cfoutput query="GET_PRICE">
            	<cfset 'PRICE_ID_#PRODUCT_ID#' = PRICE_ID>
				<cfset 'PRICE_#PRODUCT_ID#' = PRICE>
                <cfset 'PRICE_KDV_#PRODUCT_ID#' = PRICE_KDV>
                <cfset 'MONEY_#PRODUCT_ID#' = MONEY>
            </cfoutput>
        </cfif>
        <cfif len(get_connect_defaults_row.IS_PRICE) and get_connect_defaults_row.IS_PRICE eq 1>
        	<cfset price_product_id_list = ValueList(GET_PRICE.product_id)>
            <cfif ListLen(price_product_id_list)>
            	<cfquery name="get_products" dbtype="query">
                	SELECT * FROM get_products WHERE PRODUCT_ID IN (#price_product_id_list#)
                </cfquery>
            <cfelse>
            	<script type="text/javascript">
					alert("Fiyat Listesine Bağlı Olmayan Ürünl Mevcut!");
					window.location ="<cfoutput>#request.self#?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=#attributes.connect_id#</cfoutput>";
				</script>
            </cfif>
        </cfif>
        <!---İskonto Bulma--->
        <!---Müşteri İçin Tanımlanan İskonto Var mı--->
        <cfquery name="get_discount" datasource="#dsn3#">
        	SELECT 
            	PRICE_CAT_EXCEPTION_ID,
            	PRODUCT_CATID, 
                BRAND_ID, 



                PRODUCT_ID, 
                PRICE_CATID, 
                DISCOUNT_RATE DISCOUNT_RATE_1, 
                DISCOUNT_RATE_2, 
                DISCOUNT_RATE_3, 
                PAYMENT_TYPE_ID
			FROM     
            	PRICE_CAT_EXCEPTIONS
			WHERE 
            	<cfif len(get_connect.company_id)> 
            		COMPANY_ID = #get_connect.company_id# AND 
                <cfelseif len(get_connect.consumer_id)>
                	CONSUMER_ID = #get_connect.consumer_id# AND
                </cfif>
                ACT_TYPE = 1 AND
                PRICE_CATID = #get_connect.PRICE_CAT_ID#
        </cfquery>
        
        <cfif get_discount.recordcount>
        	<!---Tüm Kategoriler--->
            <cfquery name="get_all_p_cat" datasource="#dsn1#">
                SELECT PRODUCT_CATID, HIERARCHY FROM PRODUCT_CAT
            </cfquery>
            <cfloop list="#product_id_list#" index="i">
            	<cfset get_disc.recordcount = 0>
                <cfquery name="get_p_info" dbtype="query">
                	SELECT PRODUCT_ID, PRODUCT_CATID, BRAND_ID, SHORT_CODE_ID FROM get_products WHERE PRODUCT_ID = #i#
                </cfquery>
                <cfif len(get_p_info.PRODUCT_ID)>
                	<!---Ürün için--->
                    <cfquery name="get_disc" dbtype="query">
                        SELECT DISCOUNT_RATE_1, DISCOUNT_RATE_2, DISCOUNT_RATE_3 FROM get_discount WHERE PRODUCT_ID = #get_p_info.PRODUCT_ID#
                    </cfquery>
                </cfif>
                
                <cfif not get_disc.recordcount>
                	<!---Marka İçin--->
                	<cfif len(get_p_info.BRAND_ID)>
                        <cfquery name="get_disc" dbtype="query">
                            SELECT DISCOUNT_RATE_1, DISCOUNT_RATE_2, DISCOUNT_RATE_3 FROM get_discount WHERE BRAND_ID = #get_p_info.BRAND_ID#
                        </cfquery>
                    </cfif>
                    <cfif not get_disc.recordcount>
                    	<!---Kategori İçin--->
                    	<cfif len(get_p_info.PRODUCT_CATID)>
                            <cfquery name="get_pcat_id" dbtype="query">
                                SELECT HIERARCHY FROM get_all_p_cat WHERE PRODUCT_CATID = #get_p_info.PRODUCT_CATID#
                            </cfquery>
                            <cfquery name="get_pcat_ids" dbtype="query">
                                SELECT PRODUCT_CATID FROM get_all_p_cat WHERE HIERARCHY LIKE '%#get_pcat_id.HIERARCHY#%'
                            </cfquery>
							<cfif get_pcat_ids.recordcount>
                                <cfquery name="get_disc" dbtype="query">
                                    SELECT DISCOUNT_RATE_1, DISCOUNT_RATE_2, DISCOUNT_RATE_3 FROM get_discount WHERE PRODUCT_CATID IN (#ValueList(get_pcat_ids.PRODUCT_CATID)#)
                                </cfquery>
                            </cfif>
                    	</cfif>
                        <cfif not get_disc.recordcount>
                        	<cfquery name="get_disc" dbtype="query">
                                SELECT DISCOUNT_RATE_1, DISCOUNT_RATE_2, DISCOUNT_RATE_3 FROM get_discount ORDER BY PRICE_CAT_EXCEPTION_ID desc
                            </cfquery>
                        </cfif>
                    </cfif>
                </cfif>
                <cfif get_disc.recordcount>
                	<cfset 'disc1_#i#' = get_disc.DISCOUNT_RATE_1>
                    <cfset 'disc2_#i#' = get_disc.DISCOUNT_RATE_2>
                    <cfset 'disc3_#i#' = get_disc.DISCOUNT_RATE_3>
                </cfif>
            </cfloop>	
        </cfif>
        <!---İskonto Bulma--->
    </cfif>
<cfelse>
	<cfset get_products.recordcount = 0>
</cfif>

<cfparam name="attributes.totalrecords" default='#get_products.recordcount#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

	<cfif x_left_menu neq 1>
		<cf_box>
			<cf_box_elements>
				<div class="col col-12">
					<div class="col col-8 col-xs-12">
						<div class="form-group" id="form_ul_keyword">
							<cfinput type="text" name="keyword" id="keyword" style="width:150px; height:35px" placeholder="Barcod Okutunuz" maxlength="50" value="#attributes.keyword#" onKeyPress="return noenter()" onkeydown="if(event.keyCode==13){event.preventDefault();event.stopPropagation();noenter();return false;}">
						</div>
					</div>
					<div id="qr-reader" style="width:300px"></div>
					<div class="col col-4 col-xs-12">
						<input type="button" id="buton" name="buton" style="width:100%; height:35px; font-size:16px; font-weight:bold; border-color:gainsboro; color:white;margin:0px;" value="Ara" onclick="filtrele();">
					</div>
				</div>
			</cf_box_elements>
		</cf_box>
	</cfif>

	<div id="tab-list" <cfif x_top_menu neq 1> style="display:none;"</cfif>>
		<cfloop query="get_property_group">
			<cfquery name="get_categori" dbtype="query">
				SELECT 
					PROPERTY_DETAIL, 
					PROPERTY_DETAIL_ID,
					PROPERTY_DETAIL_CODE
				FROM
					get_properties
				WHERE
					PROPERTY_ID = #get_property_group.PROPERTY_ID#	
				GROUP BY
					PROPERTY_DETAIL, 
					PROPERTY_DETAIL_ID,
					PROPERTY_DETAIL_CODE
				ORDER BY
					PROPERTY_DETAIL_CODE
			</cfquery>
			<cfset category_counter = currentRow />
			<cfoutput>
				<div>
					<ul class="tabNav tabNavNew scrollContent" style="">
						<li class="first-li"><a href="javascript://" style="color:white!important;">#get_property_group.PROPERTY#</a></li>
						<cfloop query="get_categori">
							<li class="other-li <cfif Listlen(attributes.id_list) and ListFind(attributes.id_list,get_categori.PROPERTY_DETAIL_ID)>parent_li</cfif>" id="prop_detail_li_#get_categori.PROPERTY_DETAIL_ID#" <cfif Listlen(related_id_list) and not ListFind(related_id_list,get_categori.PROPERTY_DETAIL_ID)>style="display:none"</cfif>>
								<a href="javascript://" class="<cfif Listlen(attributes.id_list) and ListFind(attributes.id_list,get_categori.PROPERTY_DETAIL_ID)>active</cfif>" id="prop_detail_li_a_#get_categori.PROPERTY_DETAIL_ID#" onclick="category_change_header(this, #get_categori.PROPERTY_DETAIL_ID#, #category_counter#)">#get_categori.PROPERTY_DETAIL#</a>
							</li>
						</cfloop>
					</ul>
				</div>
			</cfoutput>
		</cfloop>
	</div>
	<div class="col col-3 col-xs-12" <cfif x_left_menu neq 1>style="display:none;"</cfif>>
		<cf_box>
			<cf_box_elements>
				<cfif x_left_menu eq 1>
					<div class="col col-12 col-xs-12">
						<div class="form-group" id="form_ul_keyword">
							<cfinput type="text" name="keyword" id="keyword" style="width:150px; height:20px" placeholder="Barcod Okutunuz" maxlength="50" value="#attributes.keyword#" onKeyPress="return noenter()" onkeydown="if(event.keyCode==13){event.preventDefault();event.stopPropagation();noenter();return false;}">
						</div>
					</div>
					<div id="qr-reader" style="width:300px"></div>
					<div class="col col-12 col-xs-12">
						<input type="button" id="buton" name="buton" style="width:100%; height:35px; font-size:16px; font-weight:bold; border-color:gainsboro; color:white;margin:0px;" value="Ara" onclick="filtrele();">
					</div>
				</cfif>
				<cfloop query="get_property_group">
					<cfquery name="get_categori" dbtype="query">
						SELECT 
							PROPERTY_DETAIL, 
							PROPERTY_DETAIL_ID,
							PROPERTY_DETAIL_CODE
						FROM
							get_properties
						WHERE
							PROPERTY_ID = #get_property_group.PROPERTY_ID#	
						GROUP BY
							PROPERTY_DETAIL, 
							PROPERTY_DETAIL_ID,
							PROPERTY_DETAIL_CODE
						ORDER BY
							PROPERTY_DETAIL_CODE
					</cfquery>
					<div class="col col-12 col-xs-12" <cfif x_left_menu neq 1>style="display:none;"</cfif>>
						<cf_seperator title="#get_property_group.PROPERTY#" id="categori_#get_property_group.PROPERTY_ID#" closeForGrid="1">
						<div id="categori_<cfoutput>#get_property_group.PROPERTY_ID#</cfoutput>" class="col col-12 col-xs-12" style="display:none;">
							<cfoutput query="get_categori">
								<div id="prop_detail_#get_categori.PROPERTY_DETAIL_ID#" <cfif Listlen(related_id_list) and not ListFind(related_id_list,get_categori.PROPERTY_DETAIL_ID)>style="display:none"</cfif>>
									<label class="col col-10 col-xs-12" style="height:20px">#get_categori.PROPERTY_DETAIL#</label>
									<div class="col col-2 col-xs-12">
											<div class="checkbox checbox-switch">
												<label>
													<input type="checkbox" name="catagori_#get_categori.PROPERTY_DETAIL_ID#" id="catagori_#get_categori.PROPERTY_DETAIL_ID#" class="category_checkbox" onchange="catagori_change()" <cfif Listlen(attributes.id_list) and ListFind(attributes.id_list,get_categori.PROPERTY_DETAIL_ID)>checked</cfif> value="1" />
													<span></span>
												</label>
											</div>
									</div>
								</div>
							</cfoutput>
						</div>
					</div>
				</cfloop>
				
			</cf_box_elements>
		</cf_box>
	</div>
<div class="<cfif x_left_menu neq 1>col col-12 col-xs-12<cfelse>col col-9 col-xs-12"</cfif>>
	<cf_box id="product_ezgi_connect">
		<cfif get_products.recordcount>
			<cfloop query="get_products">
				<cfif isdefined('PRICE_#PRODUCT_ID#')>
					<cfset price_id = Evaluate('PRICE_ID_#PRODUCT_ID#')>
					<cfset price = Evaluate('PRICE_#PRODUCT_ID#')>
					<cfset price_kdv = Evaluate('PRICE_KDV_#PRODUCT_ID#')>
					<cfset money = Evaluate('MONEY_#PRODUCT_ID#')>
				<cfelse>
					<cfset price_id = 0>
					<cfset price = 0>
					<cfset price_kdv = 0>
					<cfset money =''>
				</cfif>
				<cfif get_connect_defaults_row.IS_PRICE_KDV eq 1>
					<cfset row_net_other_ = PRICE_KDV> 
				<cfelse>
					<cfset row_net_other_ = price>
				</cfif>
				
				<cfif isdefined('get_disc') and get_disc.recordcount and price gt 0>
					<cfif isdefined('disc1_#product_id#') and Evaluate('disc1_#product_id#') gt 0>
						<cfset row_net_other_ = row_net_other_-(row_net_other_*Evaluate('disc1_#product_id#')/100)>
						<cfset disc1=Evaluate('disc1_#product_id#')>
					<cfelse>
						<cfset disc1=0>	
					</cfif>
					<cfif isdefined('disc2_#product_id#') and Evaluate('disc2_#product_id#') gt 0>
						<cfset row_net_other_ = row_net_other_-(row_net_other_*Evaluate('disc2_#product_id#')/100)>
						<cfset disc2=Evaluate('disc2_#product_id#')>
					<cfelse>
						<cfset disc2=0>	
					</cfif>
					<cfif isdefined('disc3_#product_id#') and Evaluate('disc3_#product_id#') gt 0>
						<cfset row_net_other_ = row_net_other_-(row_net_other_*Evaluate('disc3_#product_id#')/100)>
						<cfset disc3=Evaluate('disc3_#product_id#')>
					<cfelse>
						<cfset disc3=0>	
					</cfif>
				<cfelse>
					<cfset disc1=0>	
					<cfset disc2=0>
					<cfset disc3=0>	
				</cfif>
				<cfoutput>
					<div class="col col-3 col-md-4 col-sm-6 col-xs-12 product_card" type="column" index="1" sort="true">
						<div class="col col-12 col-xs-12" style="text-align:center">
							<div class="product">
								<div class="slider">
									<a style="cursor:pointer;" onclick="windowopen('#request.self#?fuseaction=sales.popup_dsp_ezgi_connect_product_detail#url_str#&disc1=#disc1#&disc2=#disc2#&disc3=#disc3#&price=#price#&money=#money#&net_price=#row_net_other_#&product_id=#PRODUCT_ID#&stock_id=#STOCK_ID#&price_cat_id=#price_cat_id#&connect_id=#attributes.connect_id#&id_list=#attributes.id_list#','list');">
										<cfif structCount(product_paths) and structKeyExists(product_paths,product_id)>
											<cfif arrayLen(product_paths[product_id])>
												<cfloop array="#product_paths[product_id]#" item="item" index="i">
													<img alt="product" src="/documents/product/#item#"/> <!--- style="width:100%;height:#get_connect_defaults.IMAGE_SMALL_HEIGHT#px;" --->
												</cfloop>
											<cfelse>
												<div class="no-image-placeholder">
													<i class="fa fa-image"></i>
												</div>
											</cfif>
										<cfelse>
											<div class="no-image-placeholder">
												<i class="fa fa-image"></i>
											</div>
										</cfif>
									</a>
								</div>
								<cfif structCount(product_paths) and structKeyExists(product_paths,product_id)>
									<cfif arrayLen(product_paths[product_id])>
										<button class="prevBtn" aria-label="Önceki resim">
											<i class="fa fa-chevron-left"></i>
										</button>
										<button class="nextBtn" aria-label="Sonraki resim">
											<i class="fa fa-chevron-right"></i>
										</button>
									</cfif>
								</cfif>
							</div>
							<div class="col col-12 col-xs-12" style="text-align:center">
								<div class="col col-8 col-xs-12 addBasket">
									<a href="javascript://" onclick="add_product(this,'#stock_id#,#price#,#money#,#price_id#,#row_net_other_#,#disc1#,#disc2#,#disc3#');">
										<button type="button" name="trasferring" class="add-to-cart-btn">
											<i class="fa fa-shopping-basket"></i>
											<span class="cart-text">Sepete Ekle</span>
											<cfif isdefined('AMOUNT_#STOCK_ID#')>
												<span class="cart-count">(#Evaluate('AMOUNT_#STOCK_ID#')#)</span>
											</cfif>
										</button>
									</a>
								</div>
								<div class="col col-4 col-xs-12 select-container">
									<a href="javascript://" onclick="select_product('#stock_id#,#price#,#money#,#price_id#,#row_net_other_#,#disc1#,#disc2#,#disc3#');">
										<button type="button" name="selecting" class="select-amount-btn">
											<select name="connect_amount_#STOCK_ID#" id="connect_amount_#STOCK_ID#" class="amount-select" data-product-info="#stock_id#,#price#,#money#,#price_id#,#row_net_other_#,#disc1#,#disc2#,#disc3#" onchange="handleSelectChange(this, '#stock_id#'); event.stopPropagation();" onclick="event.stopPropagation();">
												<option value="0">0</option>
												<option value="1">1</option>
												<option value="2">2</option>
												<option value="3">3</option>
												<option value="4">4</option>
												<option value="5">5</option>
												<option value="6">6</option>
												<option value="7">7</option>
												<option value="8">8</option>
												<option value="9">9</option>
											</select>
										</button>
									</a>
									<input type="hidden" id="is_active_id_#stock_id#" name="is_active_id_#stock_id#" value="0">
									<input type="hidden" id="is_select_value_#stock_id#" name="is_select_value_#stock_id#" value="">
								</div>
							</div>
							<div style="height:100px; width:100%;text-align:center; vertical-align:middle">
								<div>
									<span style="font-size:16px;">#left(PRODUCT_NAME,60)#</span><br />
									<span style="font-size:12px;">#PRODUCT_CODE#</span>
								</div>
								<div>
									<span style="font-size:14px; font-family:Arial, Helvetica, sans-serif">
										<cfif get_connect_defaults_row.IS_PRICE_KDV eq 1>
                                        	<cfset first_price = PRICE_KDV>
                                        	<cfif isdefined('proje_disc1') and proje_disc1 gt 0>
                                            	<cfset PRICE_KDV = PRICE_KDV - (Round(PRICE_KDV*100/proje_disc1)/100)>
                                          	</cfif>
                                            <cfif isdefined('proje_disc2') and proje_disc2 gt 0>
                                            	<cfset PRICE_KDV = PRICE_KDV - (Round(PRICE_KDV*100/proje_disc2)/100)>
                                          	</cfif>
                                            <cfif isdefined('proje_disc3') and proje_disc3 gt 0>
                                            	<cfset PRICE_KDV = PRICE_KDV - (Round(PRICE_KDV*100/proje_disc3)/100)>
                                          	</cfif>
                                            <span style="font-style:italic; color:red"><del>#TlFormat(first_price,2)# #money#</del></span>
											#TlFormat(first_price,2)# #money#
										<cfelse>
											#TlFormat(price,2)# #money#
										</cfif>
									</span>
								</div>
								<cfif isdefined('get_disc') and get_disc.recordcount and price gt 0>
									<div>
										<span style="font-size:9px; height:10px; font-weight:bold">
											Özel Fiyat (#TlFormat(row_net_other_,2)# #money#)
										</span>
									</div>
								</cfif>
							</div>
						</div>
					</div>
				</cfoutput>
			</cfloop>
		</cfif>
	</cf_box>
</div>
    
<!---<script src="AddOns\ezgi\e_connect\form\html5-qrcode-master\minified\html5-qrcode.min.js"></script>--->
<script type="text/javascript">
    // Toast mesajları
    var toastMessages = {
        productAdded: "<cf_get_lang dictionary_id='35458.Ürün Sepete Atıldı'>"
    };
    var id_list = "";
	function filtrele(){
		// beforeunload event'ini geçici olarak devre dışı bırak
		var originalBeforeUnload = window.onbeforeunload;
		window.onbeforeunload = null;
		
		<cfif Listlen(get_property_group_list)>
			<cfloop list="#get_property_group_list#" index="ii">
				categori_id_list_<cfoutput>#ii#</cfoutput> = '';
				<cfquery name="get_categori" dbtype="query">
                   SELECT PROPERTY_DETAIL_ID FROM get_properties WHERE PROPERTY_ID = #ii# GROUP BY PROPERTY_DETAIL_ID
              	</cfquery>
				<cfif get_categori.recordcount>
					<cfoutput query="get_categori">
						i = #PROPERTY_DETAIL_ID#;
						if(eval('document.all.catagori_'+i).checked==true)
						{
							categori_id_list_#ii# += i+',';
							id_list += i+',';
						}
					</cfoutput>
				</cfif>
				categori_id_list_<cfoutput>#ii#</cfoutput> = categori_id_list_<cfoutput>#ii#</cfoutput>.substr(0,categori_id_list_<cfoutput>#ii#</cfoutput>.length-1);
			</cfloop>
		</cfif>
		id_list = id_list.substr(0,id_list.length-1);
		if(list_len(id_list))
		{
            history.pushState("", "title", "<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=<cfoutput>#url.connect_id#</cfoutput>&is_form_submitted=1&keyword="+document.getElementById('keyword').value+"&id_list="+id_list+"<cfloop list="#get_property_group_list#" index="ii">&categori_id_list_<cfoutput>#ii#</cfoutput>="+categori_id_list_<cfoutput>#ii#</cfoutput>+"</cfloop>");
		}
		else
		{
			if(document.getElementById('keyword').value!=''){
                history.pushState("","title","<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=<cfoutput>#url.connect_id#</cfoutput>&is_form_submitted=1&keyword="+document.getElementById('keyword').value)+"&id_list=";
            }
			else
			{
				history.pushState("","title","<cfoutput>#request.self#</cfoutput>?fuseaction=sales.list_ezgi_connect&event=upd&connect_id=<cfoutput>#url.connect_id#</cfoutput>");
			}
		}
        dataTemplate();
		
		// beforeunload event'ini geri yükle (kısa bir gecikme ile)
		setTimeout(function() {
			window.onbeforeunload = originalBeforeUnload;
		}, 200);
	}
	function add_product(el, product_info)
	{
		addProductUrl='';
		select_list='';
		amount_list='';
		product_info_list = '';
		amount_info_list = '';

		// Tüm sayfadaki select elemanlarını kontrol et (AJAX ile yüklenen ürünler dahil)
		var allSelects = document.querySelectorAll('select[id^="connect_amount_"]');
		for(var i = 0; i < allSelects.length; i++) {
			var selectElement = allSelects[i];
			var selectId = selectElement.id;
			var stockid = selectId.replace('connect_amount_', '');
			var selectValue = parseInt(selectElement.value);
			var isActiveElement = document.getElementById('is_active_id_'+stockid);
			var isSelectValueElement = document.getElementById('is_select_value_'+stockid);
			var productInfo = selectElement.getAttribute('data-product-info');
			
			// Aktif ürünleri veya select değeri 0'dan büyük olan ürünleri kontrol et
			var isActive = (isActiveElement && isActiveElement.value == '1');
			var hasSelectValue = (isSelectValueElement && isSelectValueElement.value && isSelectValueElement.value != '');
			
			// Eğer select değeri 0'dan büyükse ve is_select_value yoksa, data-product-info'dan al
			if(selectValue > 0 && !hasSelectValue && productInfo) {
				if(isSelectValueElement) {
					isSelectValueElement.value = productInfo;
				}
				if(isActiveElement) {
					isActiveElement.value = 1;
				}
				hasSelectValue = true;
			}
			
			// Sadece productInfo varsa ekle (is_select_value veya data-product-info)
			var finalProductInfo = '';
			if(hasSelectValue && isSelectValueElement) {
				finalProductInfo = isSelectValueElement.value;
			} else if(productInfo) {
				finalProductInfo = productInfo;
			}
			
			if((isActive || selectValue > 0) && finalProductInfo && finalProductInfo != '') {
				var amount = (selectValue > 0) ? selectValue : 1;
				select_list += stockid+',';    
				amount_list += amount+','; 
			}
		}
		
		if(list_len(select_list))
		{
			select_list = select_list.substr(0,select_list.length-1);
			amount_list = amount_list.substr(0,amount_list.length-1);
			select_list_len = list_len(select_list);
			
			for(var xx=1;xx<=select_list_len;xx++)
			{
				stockid = list_getat(select_list,xx);
				var isSelectValueElement = document.getElementById('is_select_value_'+stockid);
				var selectElement = document.getElementById('connect_amount_'+stockid);
				var productInfo = '';
				
				// Önce is_select_value'yu kontrol et, yoksa data-product-info'dan al
				if(isSelectValueElement && isSelectValueElement.value && isSelectValueElement.value != '') {
					productInfo = isSelectValueElement.value;
				} else if(selectElement) {
					productInfo = selectElement.getAttribute('data-product-info');
				}
				
				if(productInfo) {
					product_info_list += productInfo+'-';
					amount_info_list += document.getElementById('connect_amount_'+stockid).value+'-';
				}
			}
			product_info_list = product_info_list.substr(0,product_info_list.length-1);
			amount_info_list = amount_info_list.substr(0,amount_info_list.length-1);
			if(list_len(product_info_list))
			{
				var addProductUrl = "<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect_row&#url_str#&connect_id=#attributes.connect_id#&price_cat_id=#get_connect.PRICE_CAT_ID#&id_list=#attributes.id_list#</cfoutput>&product_info_list="+product_info_list+"&amount_info_list="+amount_info_list+"&keyword="+document.getElementById('keyword').value;
			}
		}
		else
		{
			stock_id = list_getat(product_info,1);
			price = list_getat(product_info,2);
			money = list_getat(product_info,3);
			price_id = list_getat(product_info,4);
			net_price = list_getat(product_info,5);
			disc1 = list_getat(product_info,6);
			disc2 = list_getat(product_info,7);
			disc3 = list_getat(product_info,8);
			if(price_id.length == 0)
			{
				alert('Fiyatı Olmayan Ürün Sepete Dahil Edilemez');
				return false;
			}
			else
			{
				// Select'ten seçilen miktarı kontrol et
				var selectElement = document.getElementById('connect_amount_'+stock_id);
				var selectedAmount = 1; // Varsayılan miktar
				if(selectElement && selectElement.value && parseInt(selectElement.value) > 0)
				{
					selectedAmount = parseInt(selectElement.value);
				}
				amount_info_list = selectedAmount.toString(); // Success callback'inde kullanmak için
				var addProductUrl = "<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_connect_row&#url_str#&connect_id=#attributes.connect_id#&price_cat_id=#get_connect.PRICE_CAT_ID#&id_list=#attributes.id_list#</cfoutput>&product_info_list="+product_info+"&amount_info_list="+selectedAmount+"&keyword="+document.getElementById('keyword').value;
			}
		}
		var basketCounter = 0;
		// Closure için select_list ve amount_list'i sakla
		var savedSelectList = select_list;
		var savedAmountList = amount_list;
		var savedAmountInfoList = amount_info_list;
		var savedProductInfo = product_info; // Tek ürün durumu için
		
		if(addProductUrl != ''){
			// Scroll pozisyonunu AJAX çağrısından önce kaydet
			var savedScrollPosition = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
			
			$.ajax({
				url: addProductUrl,
				type: "GET",
				data: {},
				cache: false,
				processData: false,
				contentType: false,
				success: function ( response ) {
					// Response'da alert veya mesaj varsa engelle
					if(response && typeof response === 'string') {
						// Script tag'lerini temizle (alert'leri engellemek için)
						var tempDiv = document.createElement('div');
						tempDiv.innerHTML = response;
						var scripts = tempDiv.querySelectorAll('script');
						scripts.forEach(function(script) {
							var scriptContent = script.textContent || script.innerHTML;
							// Alert içeren script'leri engelle
							if(scriptContent.indexOf('alert') !== -1 || scriptContent.indexOf('showToast') !== -1) {
								script.remove();
							}
						});
					}
					
					// Confirm animasyonunu sadece bir kez göster (flag ile kontrol et)
					if(!window.confirmShown) {
						window.confirmShown = true;
						showConfirmAnimation(toastMessages.productAdded);
						setTimeout(function() {
							window.confirmShown = false;
						}, 500);
					}
					
					// Scroll pozisyonunu koru - birden fazla kez kontrol et
					var restoreScroll = function() {
						var currentPos = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
						if(Math.abs(currentPos - savedScrollPosition) > 10) {
							window.scrollTo({
								top: savedScrollPosition,
								behavior: 'auto'
							});
						}
					};
					
					// Hemen scroll pozisyonunu geri yükle
					restoreScroll();
					
					// requestAnimationFrame ile tekrar kontrol et
					requestAnimationFrame(function() {
						restoreScroll();
						// Ekstra koruma için birkaç kez daha kontrol et
						setTimeout(restoreScroll, 10);
						setTimeout(restoreScroll, 50);
						setTimeout(restoreScroll, 100);
					});
					
					var totalAddedAmount = 0;
					
					// Birden fazla ürün eklendiyse, her birini güncelle
					if(savedSelectList && list_len(savedSelectList)) {
						var selectListArray = savedSelectList.split(',');
						var amountListArray = savedAmountList.split(',');
						
						for(var i = 0; i < selectListArray.length; i++) {
							var stockid = selectListArray[i];
							var addedAmount = parseInt(amountListArray[i] || 1);
							totalAddedAmount += addedAmount;
							
							// Stock_id'ye ait select elementini bul, sonra en yakın addBasket butonunu bul
							var selectElement = document.getElementById('connect_amount_'+stockid);
							if(selectElement) {
								// Select box değerini 0'a sıfırla
								selectElement.value = '0';
								
								// Select elementinin parent'ından product_card'ı bul
								var productCard = selectElement.closest('.product_card');
								if(productCard) {
									// product_card içindeki addBasket div'ini ve içindeki link'i bul
									var addBasketLink = productCard.querySelector('.addBasket a');
									if(addBasketLink) {
										var button = $(addBasketLink).find('button');
										var currentCounter = 0;
										
										if(button.find('span').length > 0) {
											var spanText = button.find('span').text();
											currentCounter = parseInt(spanText.replace('(','').replace(')','')) || 0;
										} else {
											$("<span>").css({"font-size": "15px", "color": "white"}).appendTo(button);
										}
										
										var newCounter = currentCounter + addedAmount;
										button.find('span').text('(' + newCounter + ')');
									}
								}
								
								// is_active_id ve is_select_value'yu da sıfırla
								var isActiveElement = document.getElementById('is_active_id_'+stockid);
								if(isActiveElement) {
									isActiveElement.value = '0';
								}
								var isSelectValueElement = document.getElementById('is_select_value_'+stockid);
								if(isSelectValueElement) {
									isSelectValueElement.value = '';
								}
							}
						}
					} else {
						// Tek ürün eklendi, sadece tıklanan butonu güncelle
						if($(el).find("button > span").length > 0){
							basketCounter = parseInt($(el).find("button > span").text().replace('(','').replace(')',''));
						} else {
							$("<span>").css({"font-size": "15px", "color": "white"}).appendTo($(el).find('button'));
						}
						var addedAmount = parseInt((savedAmountInfoList != '') ? savedAmountInfoList : 1);
						totalAddedAmount = addedAmount;
						$(el).find("button > span").text( '(' + (basketCounter + addedAmount) + ')');
						
						// Tek ürün durumunda da select box'ı sıfırla
						var stock_id = list_getat(savedProductInfo,1);
						var selectElement = document.getElementById('connect_amount_'+stock_id);
						if(selectElement) {
							selectElement.value = '0';
						}
						var isActiveElement = document.getElementById('is_active_id_'+stock_id);
						if(isActiveElement) {
							isActiveElement.value = '0';
						}
						var isSelectValueElement = document.getElementById('is_select_value_'+stock_id);
						if(isSelectValueElement) {
							isSelectValueElement.value = '';
						}
					}
					
					// Toplam miktarı güncelle
					var topTotalElement = document.getElementById('topTotalAmount');
					if(topTotalElement) {
						var currentTotal = 0;
						
						// Mevcut toplamı badge'den al
						var badgeElement = topTotalElement.querySelector('.basket-badge');
						if(badgeElement) {
							currentTotal = parseInt(badgeElement.textContent.trim()) || 0;
						} else {
							// Eski format için geriye dönük uyumluluk
							var amountText = topTotalElement.querySelector('.basket-amount-text');
							if(amountText) {
								currentTotal = parseInt(amountText.textContent.trim()) || 0;
							} else {
								var amountSpan = topTotalElement.querySelector('.amountText');
								if(amountSpan) {
									currentTotal = parseInt(amountSpan.textContent.trim()) || 0;
								} else {
									var currentTotalText = topTotalElement.textContent || topTotalElement.innerText || '';
									currentTotal = parseInt(currentTotalText.replace(/[^\d]/g, '')) || 0;
								}
							}
						}
						
						var newTotal = currentTotal + totalAddedAmount;
						
						// Modern sepet gösterimini güncelle - sadece badge ile
						var badgeHtml = '';
						if(newTotal > 0) {
							badgeHtml = '<span class="basket-badge">' + newTotal + '</span>';
						}
						
						topTotalElement.innerHTML = 
							'<div class="basket-icon-wrapper">' +
								'<i class="fa fa-shopping-basket"></i>' +
								badgeHtml +
							'</div>';
						
						// Animasyon efekti ekle
						topTotalElement.style.transform = 'scale(1.1)';
						setTimeout(function() {
							topTotalElement.style.transform = 'scale(1)';
						}, 200);
					}
				},
				beforeSend : function(){
					$(el).find("button > i").removeClass("fa-shopping-basket").addClass("fa-cog fa-spin");
				},
				complete : function () {
					$(el).find("button > i").removeClass("fa-cog fa-spin").addClass("fa-shopping-basket");
				}
			});
		}
		document.getElementById('keyword').focus();
	}
    
    function handleSelectChange(selectElement, stock_id) {
        var selectedValue = parseInt(selectElement.value);
        var productInfo = selectElement.getAttribute('data-product-info');
        
        if(selectedValue > 0 && productInfo) {
            // Ürünü aktif hale getir ve select değerini koru
            var isActiveElement = document.getElementById('is_active_id_'+stock_id);
            var isSelectValueElement = document.getElementById('is_select_value_'+stock_id);
            
            if(isActiveElement) {
                isActiveElement.value = 1;
            }
            if(isSelectValueElement) {
                isSelectValueElement.value = productInfo;
            }
            // Select değerini koru (zaten kullanıcı seçmiş)
        } else if(selectedValue == 0) {
            // Ürünü pasif hale getir
            var isActiveElement = document.getElementById('is_active_id_'+stock_id);
            var isSelectValueElement = document.getElementById('is_select_value_'+stock_id);
            
            if(isActiveElement) {
                isActiveElement.value = 0;
            }
            if(isSelectValueElement) {
                isSelectValueElement.value = '';
            }
        }
    }
    
    function select_product(product_info)
    {
        stock_id=list_getat(product_info,1);
        price=list_getat(product_info,2);
        money=list_getat(product_info,3);
        price_id=list_getat(product_info,4);
        net_price=list_getat(product_info,5);
        disc1=list_getat(product_info,6);
        disc2=list_getat(product_info,7);
        disc3=list_getat(product_info,8);
        if(price_id.length == 0)
        {
            alert('Fiyatı Olmayan Ürün Sepete Dahil Etmek İçin Seçilemez');
            return false;
        }
        else
        {
            if(document.getElementById('is_active_id_'+stock_id).value==0)
            {
                document.getElementById('connect_amount_'+stock_id).style.display = '';
                document.getElementById('connect_amount_'+stock_id).value = 1;
                document.getElementById('is_active_id_'+stock_id).value = 1;
                document.getElementById('is_select_value_'+stock_id).value = product_info;
            }
            else
            {
                
                if(document.getElementById('connect_amount_'+stock_id).value == 0)
                {
                    document.getElementById('connect_amount_'+stock_id).style.display = 'none';
                    document.getElementById('is_active_id_'+stock_id).value = 0;
                    document.getElementById('is_select_value_'+stock_id).value = '';
                }
            }
        }
    }

    function sliderTool(products) {
        products.forEach((product) => {
            const slider = product.querySelector(".slider");
            const images = slider.querySelectorAll("img");
            const prevBtn = product.querySelector(".prevBtn");
            const nextBtn = product.querySelector(".nextBtn");
            let counter = 0;

            if( images.length ){

                images[counter].classList.add("active");

                prevBtn.addEventListener("click", function(event) {
                    event.preventDefault();
                    prevSlide();
                });
                nextBtn.addEventListener("click", function(event) {
                    event.preventDefault();
                    nextSlide();
                });

                function prevSlide() {
                    images[counter].classList.remove("active");
                    if (counter === 0) {
                    counter = images.length - 1;
                    } else {
                    counter--;
                    }
                    images[counter].classList.add("active");
                }

                function nextSlide() {
                    images[counter].classList.remove("active");
                    if (counter === images.length - 1) {
                    counter = 0;
                    } else {
                    counter++;
                    }
                    images[counter].classList.add("active");
                }

            }

        });
    }

    /* var products = document.querySelectorAll(".product"),
        showProductCount = products.length,
        showProductCountMax = <cfoutput>#get_products.recordCount ? get_products.QUERY_COUNT : 0#</cfoutput>;

    sliderTool(products); */

    var page = 1,
        startrow = 1,
        maxrows = <cfoutput>#attributes.maxrows#</cfoutput>,
        oldHeight = 0,
        pageEnd = false;

    window.onscroll = function(){
        
        var winScroll = Math.round(document.body.scrollTop || document.documentElement.scrollTop);
        var height = Math.round(document.documentElement.scrollHeight - document.documentElement.clientHeight);
        if((winScroll == height) && (oldHeight != height)){
            if(showProductCountMax > showProductCount) dataTemplate(true);
        }
        
    }

    function dataTemplate(scrool = false) {
        startrow = (scrool) ? (((page - 1) * maxrows) + 1) : startrow;

        $.ajax({
            url: "/index.cfm"+ document.location.search.replace("event=upd","event=get") +"&isAjax=1&startrow="+startrow+"&maxrows="+maxrows,
            type: "GET",
            data: {},
            cache: false,
            processData: false,
            contentType: false,
            success: function ( response ) {
                $("#product_ezgi_connect").find("#divPageLoad").remove();
                if(scrool) $("#product_ezgi_connect").append(response);
                else $("#product_ezgi_connect").html(response);
                var products = document.querySelectorAll(".product");
                showProductCount = products.length;
                sliderTool(products);
            },
            beforeSend : function(){
                $("#product_ezgi_connect").append(
                    '<div id="divPageLoad"><div class="col col-12" style="text-align:center;"><?xml version="1.0" encoding="utf-8"?><svg width="32px" height="32px" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid" class="uil-ring-alt"><rect x="0" y="0" width="100" height="100" fill="none" class="bk"></rect><circle cx="50" cy="50" r="40" stroke="rgba(255,255,255,0)" fill="none" stroke-width="10" stroke-linecap="round"></circle><circle cx="50" cy="50" r="40" stroke="#ff8a00" fill="none" stroke-width="6" stroke-linecap="round"><animate attributeName="stroke-dashoffset" dur="2s" repeatCount="indefinite" from="0" to="502"></animate><animate attributeName="stroke-dasharray" dur="2s" repeatCount="indefinite" values="150.6 100.4;1 250;150.6 100.4"></animate></circle></svg></td></tr>'
                );
                oldHeight = Math.round(document.documentElement.scrollHeight - document.documentElement.clientHeight);
            },
            complete : function () {
                page++;
            }
        });
    }

    dataTemplate();

	function catagori_change()
	{
		<cfif get_properties.recordcount>
			checked_id_list='';
			prop_det_id_list='';
			<cfoutput query="get_properties">
				prop_det_id = #PROPERTY_DETAIL_ID#;
				prop_det_id_list += prop_det_id+',';
				if(document.getElementById('catagori_'+prop_det_id).checked==true)
				{
					checked_id_list += prop_det_id+',';
					document.getElementById('prop_detail_li_a_'+prop_det_id).classList.add('active');
					document.getElementById('prop_detail_li_'+prop_det_id).classList.add('parent_li');
				}else{
					document.getElementById('prop_detail_li_a_'+prop_det_id).classList.remove('active');
					document.getElementById('prop_detail_li_'+prop_det_id).classList.remove('parent_li');
				}
			</cfoutput>
			prop_det_id_list = prop_det_id_list.substr(0,prop_det_id_list.length-1);
			checked_id_list = checked_id_list.substr(0,checked_id_list.length-1);//sondaki virgülden kurtariyoruz.
		</cfif>
		related_id_list='0,';
		if(list_len(checked_id_list))
		{
			/*var property_detail_sql = "SELECT PROPERTY_DETAIL_ID,VARIATION_ID FROM EZGI_CONNECT_PROPERTY WHERE PROPERTY_DETAIL_ID IN ("+checked_id_list+")";*/
			/*var get_property_detail = wrk_query(property_detail_sql,'dsn');*/
			
			var listParam = checked_id_list;
			var get_property_detail = wrk_safe_query('get_property_checked_id_list_ezgi','dsn',0,listParam)
			
			if(get_property_detail.recordcount != 0)
			{
				for(var xx=0;xx<get_property_detail.recordcount;xx++)
				{
					related_id_list += get_property_detail.VARIATION_ID[xx]+',';
				}
				related_id_list = related_id_list.substr(0,related_id_list.length-1);
			}
			if(list_len(prop_det_id_list))
			{
				for(var x=1;x<list_len(prop_det_id_list);x++)
				{
					cont_prop_det_id = list_getat(prop_det_id_list,x);
					if(list_find(related_id_list,cont_prop_det_id))
					{
						document.getElementById('prop_detail_'+cont_prop_det_id).style.display = '';	
						document.getElementById('prop_detail_li_'+cont_prop_det_id).style.display = '';	

					}
					else
					{
						document.getElementById('prop_detail_'+cont_prop_det_id).style.display = 'none';
						document.getElementById('prop_detail_li_'+cont_prop_det_id).style.display = 'none';
					}
				}
			}
		}
		else
		{
			if(list_len(prop_det_id_list))
			{
				for(var x=1;x<list_len(prop_det_id_list);x++)
				{
					cont_prop_det_id = list_getat(prop_det_id_list,x);
					document.getElementById('prop_detail_'+cont_prop_det_id).style.display = '';	
					document.getElementById('prop_detail_li_'+cont_prop_det_id).style.display = '';
					
				}
			}
		}
	}
	function category_change_header(element, prop_det_id, group_index) {
        if($("#catagori_"+prop_det_id+"").is(":checked")) $("#catagori_"+prop_det_id+"").prop("checked",false);
        else $("#catagori_"+prop_det_id+"").prop("checked",true);
        
        $(element).toggleClass('active');
        var parentLi = $(element).closest('li');
        $(parentLi).toggleClass('parent_li');

		catagori_change();
		var checkedCount = $(".category_checkbox:checked").length;
        if( group_index == 2 || group_index == 3 || checkedCount == 0 ){
            var button = document.getElementById('buton');
            if (button) {
                button.click();
            }
        }

    }
	// Confirm Animation Fonksiyonu - Başarı Animasyonu
	function showConfirmAnimation(message) {
		message = message || 'Ürün Sepete Eklendi';
		
		// Mevcut scroll pozisyonunu kaydet
		var scrollPosition = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
		
		// Mevcut animasyonları kaldır
		var existingAnimations = document.querySelectorAll('.confirm-animation, .confirm-animation-overlay');
		existingAnimations.forEach(function(anim) {
			anim.remove();
		});
		
		// Overlay oluştur
		var overlay = document.createElement('div');
		overlay.className = 'confirm-animation-overlay';
		
		// Animasyon kutusu oluştur
		var animationBox = document.createElement('div');
		animationBox.className = 'confirm-animation';
		animationBox.innerHTML = 
			'<div class="confirm-animation-box">' +
				'<div class="confirm-checkmark">' +
					'<i class="fa fa-check"></i>' +
				'</div>' +
				'<div class="confirm-message">' + message + '</div>' +
			'</div>';
		
		// Body'ye ekle
		document.body.appendChild(overlay);
		document.body.appendChild(animationBox);
		
		// Scroll pozisyonunu koru
		requestAnimationFrame(function() {
			window.scrollTo({
				top: scrollPosition,
				behavior: 'auto'
			});
		});
		
		// 2 saniye sonra otomatik kaldır
		setTimeout(function() {
			if(animationBox && animationBox.parentElement) {
				animationBox.classList.add('fade-out');
				if(overlay && overlay.parentElement) {
					overlay.classList.add('fade-out');
				}
				setTimeout(function() {
					if(animationBox && animationBox.parentElement) {
						animationBox.remove();
					}
					if(overlay && overlay.parentElement) {
						overlay.remove();
					}
				}, 300);
			}
		}, 2000);
	}
	
	function noenter() 
	{
		if(window.event && window.event.keyCode == 13)
		{
			// Form submit'i engelle
			if(window.event.preventDefault) {
				window.event.preventDefault();
			}
			window.event.returnValue = false;
			window.event.cancelBubble = true;
			
			// beforeunload event'ini geçici olarak devre dışı bırak
			var originalBeforeUnload = window.onbeforeunload;
			window.onbeforeunload = null;
			
			// Filtreleme işlemini yap
			filtrele();
			
			// Keyword alanını temizle
			document.getElementById('keyword').value='';
			
			// beforeunload event'ini geri yükle (kısa bir gecikme ile)
			setTimeout(function() {
				window.onbeforeunload = originalBeforeUnload;
			}, 100);
			
			return false;
		}
		return true;
	}
</script>
</script>