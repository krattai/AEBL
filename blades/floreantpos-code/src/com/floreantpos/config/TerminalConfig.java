/**
 * ************************************************************************
 * * The contents of this file are subject to the MRPL 1.2
 * * (the  "License"),  being   the  Mozilla   Public  License
 * * Version 1.1  with a permitted attribution clause; you may not  use this
 * * file except in compliance with the License. You  may  obtain  a copy of
 * * the License at http://www.floreantpos.org/license.html
 * * Software distributed under the License  is  distributed  on  an "AS IS"
 * * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * * License for the specific  language  governing  rights  and  limitations
 * * under the License.
 * * The Original Code is FLOREANT POS.
 * * The Initial Developer of the Original Code is OROCUBE LLC
 * * All portions are Copyright (C) 2015 OROCUBE LLC
 * * All Rights Reserved.
 * ************************************************************************
 */
package com.floreantpos.config;

import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.lang.StringUtils;

import com.floreantpos.model.PaymentStatusFilter;
import com.floreantpos.ui.views.SwitchboardView;
import com.floreantpos.util.PasswordHasher;

public class TerminalConfig {
	private static final String USE_SETTLEMENT_PROMPT = "UseSettlementPrompt"; //$NON-NLS-1$

	private static final String SHOW_GUEST_SELECTION = "show_guest_selection"; //$NON-NLS-1$

	private static final String ORDER_TYPE_FILTER = "order_type_filter"; //$NON-NLS-1$

	private static final String PS_FILTER = "ps_filter"; //$NON-NLS-1$

	private static final String SHOW_TABLE_SELECTION = "show_table_selection"; //$NON-NLS-1$

	private static final String REGULAR_MODE = "regular_mode"; //$NON-NLS-1$

	private static final String KITCHEN_MODE = "kitchen_mode"; //$NON-NLS-1$

	private static final String CASHIER_MODE = "cashier_mode"; //$NON-NLS-1$

	private static final String SHOW_DB_CONFIGURATION = "show_db_configuration"; //$NON-NLS-1$

	private static final String UI_DEFAULT_FONT = "ui_default_font"; //$NON-NLS-1$

	private static final String AUTO_LOGOFF_TIME = "AUTO_LOGOFF_TIME"; //$NON-NLS-1$

	private static final String AUTO_LOGOFF_ENABLE = "AUTO_LOGOFF_ENABLE"; //$NON-NLS-1$

	private static final String DEFAULT_PASS_LEN = "DEFAULT_PASS_LEN"; //$NON-NLS-1$

	private static final String TOUCH_FONT_SIZE = "TOUCH_FONT_SIZE";//$NON-NLS-1$

	private static final String SCREEN_COMPONENT_SIZE_RATIO = "SCREEN_COMPONENT_SIZE_RATIO";//$NON-NLS-1$

	private static final String TOUCH_BUTTON_HEIGHT = "TOUCH_BUTTON_HEIGHT";//$NON-NLS-1$

	private static final String FLOOR_BUTTON_WIDTH = "FLOOR_BUTTON_WIDTH";//$NON-NLS-1$

	private static final String FLOOR_BUTTON_HEIGHT = "FLOOR_BUTTON_HEIGHT";//$NON-NLS-1$

	private static final String FLOOR_BUTTON_FONT_SIZE = "FLOOR_BUTTON_FONT_SIZE";//$NON-NLS-1$

	private static final String ADMIN_PASSWORD = "admin_pass";//$NON-NLS-1$

	private static final String SHOW_BARCODE_ON_RECEIPT = "show_barcode_on_receipt";//$NON-NLS-1$

	private static final String GROUP_KITCHEN_ITEMS_ON_RECEIPT = "group_kitchen_items_on_receipt";//$NON-NLS-1$

	private static final String ENABLE_MULTI_CURRENCY = "enable_multi_currency";//$NON-NLS-1$

	private static final String DEFAULT_VIEW = "default_view";//$NON-NLS-1$

	private static final String ACTIVE_CUSTOMER_DISPLAY = "active_customer_display";//$NON-NLS-1$

	private static final String ACTIVE_SCALE_DISPLAY = "active_scale_display";//$NON-NLS-1$

	private static final String ACTIVE_CALLER_ID_DEVICE = "active_caller_id_device";//$NON-NLS-1$

	private static final String CALLER_ID_DEVICE = "caller_id_device";//$NON-NLS-1$

	static final String TERMINAL_ID = "terminal_id"; //$NON-NLS-1$
	static final String FULLSCREEN_MODE = "fullscreen_mode"; //$NON-NLS-1$

	private static boolean multiple_order_supported = true;

	private static PropertiesConfiguration config = AppConfig.getConfig();

	public static int getTerminalId() {
		return config.getInt(TERMINAL_ID, -1);
	}

	public static void setTerminalId(int id) {
		config.setProperty(TERMINAL_ID, id);
	}

	public static boolean isFullscreenMode() {
		return config.getBoolean(FULLSCREEN_MODE, false);
	}

	public static void setFullscreenMode(boolean fullscreen) {
		config.setProperty(FULLSCREEN_MODE, fullscreen);
	}

	public static String getAdminPassword() {
		return config.getString(ADMIN_PASSWORD, PasswordHasher.hashPassword("1111")); //$NON-NLS-1$
	}

	public static void setAdminPassword(String password) {
		config.setProperty(ADMIN_PASSWORD, PasswordHasher.hashPassword(password));
	}

	public static boolean matchAdminPassword(String password) {
		return getAdminPassword().equals(PasswordHasher.hashPassword(password));
	}

	public static void setTouchScreenButtonHeight(int height) {
		config.setProperty(TOUCH_BUTTON_HEIGHT, height);
	}

	public static int getTouchScreenButtonHeight() {
		return config.getInt(TOUCH_BUTTON_HEIGHT, 80);
	}

	public static void setFloorButtonWidth(int width) {
		config.setProperty(FLOOR_BUTTON_WIDTH, width);
	}

	public static int getFloorButtonWidth() {
		return config.getInt(FLOOR_BUTTON_WIDTH, 55);
	}

	public static void setFloorButtonHeight(int height) {
		config.setProperty(FLOOR_BUTTON_HEIGHT, height);
	}

	public static int getFloorButtonHeight() {
		return config.getInt(FLOOR_BUTTON_HEIGHT, 90);
	}

	public static void setFloorButtonFontSize(int size) {
		config.setProperty(FLOOR_BUTTON_FONT_SIZE, size);
	}

	public static int getFloorButtonFontSize() {
		return config.getInt(FLOOR_BUTTON_FONT_SIZE, 30);
	}

	public static void setMenuItemButtonHeight(int height) {
		config.setProperty("menu_button_height", height);
	}

	public static int getMenuItemButtonHeight() {
		return config.getInt("menu_button_height", 80);
	}

	public static void setMenuItemButtonWidth(int width) {
		config.setProperty("menu_button_width", width);
	}

	public static int getMenuItemButtonWidth() {
		return config.getInt("menu_button_width", 80);
	}

	public static void setTouchScreenFontSize(int size) {
		config.setProperty(TOUCH_FONT_SIZE, size);
	}

	public static int getTouchScreenFontSize() {
		return config.getInt(TOUCH_FONT_SIZE, 12);
	}

	public static void setScreenScaleFactor(double size) {
		config.setProperty(SCREEN_COMPONENT_SIZE_RATIO, size);
	}

	public static double getScreenScaleFactor() {
		return config.getDouble(SCREEN_COMPONENT_SIZE_RATIO, 1);
	}

	public static void setDefaultPassLen(int defaultPassLen) {
		config.setProperty(DEFAULT_PASS_LEN, defaultPassLen);
	}

	public static int getDefaultPassLen() {
		return config.getInt(DEFAULT_PASS_LEN, 4);
	}

	public static boolean isAutoLogoffEnable() {
		return config.getBoolean(AUTO_LOGOFF_ENABLE, true);
	}

	public static void setAutoLogoffEnable(boolean enable) {
		config.setProperty(AUTO_LOGOFF_ENABLE, enable);
	}

	public static void setAutoLogoffTime(int time) {
		config.setProperty(AUTO_LOGOFF_TIME, time);
	}

	public static int getAutoLogoffTime() {
		return config.getInt(AUTO_LOGOFF_TIME, 60);
	}

	public static String getUiDefaultFont() {
		return config.getString(UI_DEFAULT_FONT);
	}

	public static void setUiDefaultFont(String fontName) {
		config.setProperty(UI_DEFAULT_FONT, fontName);
	}

	public static String getDefaultView() {
		return config.getString(DEFAULT_VIEW, SwitchboardView.VIEW_NAME);
	}

	public static void setDefaultView(String viewName) {
		config.setProperty(DEFAULT_VIEW, viewName);
	}

	public static void setShowDbConfigureButton(boolean show) {
		config.setProperty(SHOW_DB_CONFIGURATION, show);
	}

	public static boolean isShowDbConfigureButton() {
		return config.getBoolean(SHOW_DB_CONFIGURATION, true);
	}

	public static void setShowBarcodeOnReceipt(boolean show) {
		config.setProperty(SHOW_BARCODE_ON_RECEIPT, show);
	}

	public static boolean isShowBarcodeOnReceipt() {
		return config.getBoolean(SHOW_BARCODE_ON_RECEIPT, false);
	}

	public static void setEnabledCallerIdDevice(boolean show) {
		config.setProperty(ACTIVE_CALLER_ID_DEVICE, show);
	}

	public static boolean isEanbledCallerIdDevice() {
		return config.getBoolean(ACTIVE_CALLER_ID_DEVICE, false);
	}

	public static void setGroupKitchenReceiptItems(boolean group) {
		config.setProperty(GROUP_KITCHEN_ITEMS_ON_RECEIPT, group);
	}

	public static boolean isGroupKitchenReceiptItems() {
		return config.getBoolean(GROUP_KITCHEN_ITEMS_ON_RECEIPT, false);
	}

	public static boolean isEnabledMultiCurrency() {
		return config.getBoolean(ENABLE_MULTI_CURRENCY, false);
	}

	public static void setEnabledMultiCurrency(boolean enable) {
		config.setProperty(ENABLE_MULTI_CURRENCY, enable);
	}

	public static boolean isMultipleOrderSupported() {
		return multiple_order_supported;
	}

	public static void setCustomerDisplay(boolean show) {
		config.setProperty(ACTIVE_CUSTOMER_DISPLAY, show);
	}

	public static boolean isActiveCustomerDisplay() {
		return config.getBoolean(ACTIVE_CUSTOMER_DISPLAY, false);
	}

	public static void setScaleDisplay(boolean show) {
		config.setProperty(ACTIVE_SCALE_DISPLAY, show);
	}

	public static boolean isActiveScaleDisplay() {
		return config.getBoolean(ACTIVE_SCALE_DISPLAY, false);
	}

	public static boolean isCashierMode() {
		return false; //config.getBoolean(CASHIER_MODE, false);
	}

	public static void setCashierMode(boolean cashierMode) {
		config.setProperty(CASHIER_MODE, cashierMode);
	}

	public static boolean isRegularMode() {
		return config.getBoolean(REGULAR_MODE, false);
	}

	public static void setRegularMode(boolean regularMode) {
		config.setProperty(REGULAR_MODE, regularMode);
	}

	public static boolean isKitchenMode() {
		return config.getBoolean(KITCHEN_MODE, false);
	}

	public static void setKitchenMode(boolean kitchenMode) {
		config.setProperty(KITCHEN_MODE, kitchenMode);
	}

	public static boolean isUseTranslatedName() {
		return config.getBoolean("use_translated_name", false); //$NON-NLS-1$
	}

	public static void setUseTranslatedName(boolean useTranslatedName) {
		config.setProperty("use_translated_name", useTranslatedName); //$NON-NLS-1$
	}

	public static String getOrderTypeFilter() {
		return config.getString(ORDER_TYPE_FILTER, "ALL");
	}

	public static void setOrderTypeFilter(String filter) {
		config.setProperty(ORDER_TYPE_FILTER, filter);
	}

	public static String getCallerIdDevice() {
		return config.getString(CALLER_ID_DEVICE, "NONE");
	}

	public static void setCallerIdDevice(String device) {
		config.setProperty(CALLER_ID_DEVICE, device);
	}

	public static PaymentStatusFilter getPaymentStatusFilter() {
		return PaymentStatusFilter.fromString(config.getString(PS_FILTER));
	}

	public static void setPaymentStatusFilter(String filter) {
		config.setProperty(PS_FILTER, filter);
	}

	public static void setShouldShowTableSelection(boolean showTableSelection) {
		config.setProperty(SHOW_TABLE_SELECTION, Boolean.valueOf(showTableSelection));
	}

	public static boolean isShouldShowTableSelection() {
		return config.getBoolean(SHOW_TABLE_SELECTION, Boolean.TRUE);
	}

	public static void setShouldShowGuestSelection(boolean showGuestSelection) {
		config.setProperty(SHOW_GUEST_SELECTION, Boolean.valueOf(showGuestSelection));
	}

	public static boolean isShouldShowGuestSelection() {
		return config.getBoolean(SHOW_GUEST_SELECTION, Boolean.TRUE);
	}

	public static void setUseSettlementPrompt(boolean settlementPrompt) {
		config.setProperty(USE_SETTLEMENT_PROMPT, Boolean.valueOf(settlementPrompt));
	}

	public static boolean isUseSettlementPrompt() {
		return config.getBoolean(USE_SETTLEMENT_PROMPT, Boolean.FALSE);
	}

	public static void setMiscItemDefaultTaxId(int id) {
		config.setProperty("mistitemdefaulttaxid", id); //$NON-NLS-1$
	}

	public static int getMiscItemDefaultTaxId() {
		return config.getInt("mistitemdefaulttaxid", -1); //$NON-NLS-1$
	}

	public static void setDrawerPortName(String drawerPortName) {
		config.setProperty("drawerPortName", drawerPortName); //$NON-NLS-1$
	}

	public static String getDrawerPortName() {
		return config.getString("drawerPortName", "COM1"); //$NON-NLS-1$ //$NON-NLS-2$
	}

	public static void setCustomerDisplayPort(String customerDisplayPort) {
		config.setProperty("customerDisplayPort", customerDisplayPort); //$NON-NLS-1$
	}

	public static String getCustomerDisplayPort() {
		return config.getString("customerDisplayPort", "COM1"); //$NON-NLS-1$ //$NON-NLS-2$
	}

	public static void setCustomerDisplayMessage(String customerDisplayMessage) {
		config.setProperty("customerDisplayMessage", customerDisplayMessage); //$NON-NLS-1$
	}

	public static String getCustomerDisplayMessage() {
		return config.getString("customerDisplayMessage", "12345678912345678912"); //$NON-NLS-1$ //$NON-NLS-2$
	}

	public static String getScaleActivationValue() {
		return config.getString("wd", ""); //$NON-NLS-1$ //$NON-NLS-2$
	}

	public static void setScalePort(String scalePort) {
		config.setProperty("scaleDisplayPort", scalePort); //$NON-NLS-1$
	}

	public static String getScalePort() {
		return config.getString("scalePort", "COM7"); //$NON-NLS-1$ //$NON-NLS-2$
	}

	public static void setScaleDisplayMessage(String scaleDisplayMessage) {
		config.setProperty("scaleDisplayMessage", scaleDisplayMessage); //$NON-NLS-1$
	}

	public static String getScaleDisplayMessage() {
		return config.getString("scaleDisplayMessage", "1234"); //$NON-NLS-1$ //$NON-NLS-2$
	}

	public static void setDrawerControlCodes(String controlCode) {
		config.setProperty("controlCode", controlCode); //$NON-NLS-1$
	}

	public static String getDrawerControlCodes() {
		return config.getString("controlCode", "27,112,0,25,250"); //$NON-NLS-1$ //$NON-NLS-2$
	}

	public static String getDefaultDrawerControlCodes() {
		return "27,112,0,25,250"; //$NON-NLS-1$
	}

	public static String getDrawerPullReportHiddenColumns() {
		return config.getString("drawerPullReportColumns", "");
	}

	public static void setDrawerPullReportHiddenColumns(String value) {
		config.setProperty("drawerPullReportColumns", value);
	}

	public static String getTicketListViewHiddenColumns() {
		return config.getString("listViewColumns", "");
	}

	public static void setTicketListViewHiddenColumns(String value) {
		config.setProperty("listViewColumns", value);
	}

	public static char[] getDrawerControlCodesArray() {
		String drawerControlCodes = getDefaultDrawerControlCodes();
		if (StringUtils.isEmpty(drawerControlCodes)) {
			drawerControlCodes = getDefaultDrawerControlCodes();
		}

		String[] split = drawerControlCodes.split(","); //$NON-NLS-1$
		char[] codes = new char[split.length];
		for (int i = 0; i < split.length; i++) {
			try {
				codes[i] = (char) Integer.parseInt(split[i]);
			} catch (Exception x) {
				codes[i] = '0';
			}
		}
		return codes;
	}
}
