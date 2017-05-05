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
package com.floreantpos.ui.views.payment;

import java.awt.BorderLayout;
import java.awt.Font;
import java.io.IOException;
import java.io.StringReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonNumber;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.swing.BorderFactory;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingConstants;

import net.miginfocom.swing.MigLayout;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;

import com.floreantpos.Messages;
import com.floreantpos.POSConstants;
import com.floreantpos.PosException;
import com.floreantpos.config.CardConfig;
import com.floreantpos.config.TerminalConfig;
import com.floreantpos.extension.InginicoPlugin;
import com.floreantpos.extension.PaymentGatewayPlugin;
import com.floreantpos.main.Application;
import com.floreantpos.model.CardReader;
import com.floreantpos.model.CashTransaction;
import com.floreantpos.model.Discount;
import com.floreantpos.model.GiftCertificateTransaction;
import com.floreantpos.model.Gratuity;
import com.floreantpos.model.PaymentType;
import com.floreantpos.model.PosTransaction;
import com.floreantpos.model.Restaurant;
import com.floreantpos.model.Ticket;
import com.floreantpos.model.TicketDiscount;
import com.floreantpos.model.TicketItem;
import com.floreantpos.model.UserPermission;
import com.floreantpos.report.ReceiptPrintService;
import com.floreantpos.services.PosTransactionService;
import com.floreantpos.swing.PosScrollPane;
import com.floreantpos.swing.PosUIManager;
import com.floreantpos.ui.dialog.DiscountSelectionDialog;
import com.floreantpos.ui.dialog.POSDialog;
import com.floreantpos.ui.dialog.POSMessageDialog;
import com.floreantpos.ui.dialog.TransactionCompletionDialog;
import com.floreantpos.ui.ticket.TicketViewerTable;
import com.floreantpos.ui.views.order.OrderController;
import com.floreantpos.ui.views.order.OrderView;
import com.floreantpos.util.CurrencyUtil;
import com.floreantpos.util.DrawerUtil;
import com.floreantpos.util.NumberUtil;
import com.floreantpos.util.POSUtil;

//TODO: REVISE CODE
public class SettleTicketDialog extends POSDialog implements CardInputListener {
	public static final String LOYALTY_DISCOUNT_PERCENTAGE = "loyalty_discount_percentage"; //$NON-NLS-1$
	public static final String LOYALTY_POINT = "loyalty_point"; //$NON-NLS-1$
	public static final String LOYALTY_COUPON = "loyalty_coupon"; //$NON-NLS-1$
	public static final String LOYALTY_DISCOUNT = "loyalty_discount"; //$NON-NLS-1$
	public static final String LOYALTY_ID = "loyalty_id"; //$NON-NLS-1$

	private PaymentView paymentView;
	private TicketViewerTable ticketViewerTable;
	private javax.swing.JScrollPane ticketScrollPane;
	private Ticket ticket;
	private double tenderAmount;
	private PaymentType paymentType;
	private String cardName;
	private JTextField tfSubtotal;
	private JTextField tfDiscount;
	private JTextField tfDeliveryCharge;
	private JTextField tfTax;
	private JTextField tfTotal;
	private JTextField tfGratuity;

	//FIXME: change static modifier
	public static PosPaymentWaitDialog waitDialog = new PosPaymentWaitDialog();

	public SettleTicketDialog() {

	}

	public SettleTicketDialog(Ticket ticket) {
		super();
		this.ticket = ticket;

		if (ticket.getOrderType().isConsolidateItemsInReceipt()) {
			consolidateTicketItems();
		}

		setTitle(Messages.getString("SettleTicketDialog.6")); //$NON-NLS-1$
		getContentPane().setLayout(new BorderLayout());

		JPanel centerPanel = new JPanel(new BorderLayout(5, 5));
		centerPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 0));

		ticketViewerTable = new TicketViewerTable(ticket);
		ticketScrollPane = new PosScrollPane(ticketViewerTable);

		centerPanel.add(createTicketInfoPanel(), BorderLayout.NORTH);
		centerPanel.add(ticketScrollPane, BorderLayout.CENTER);
		centerPanel.add(createTotalViewerPanel(), BorderLayout.SOUTH);

		paymentView = new PaymentView(this);
		paymentView.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

		getContentPane().add(centerPanel, BorderLayout.CENTER);
		getContentPane().add(paymentView, BorderLayout.EAST);

		paymentView.updateView();
		paymentView.setDefaultFocus();
		updateView();
	}

	private void consolidateTicketItems() {
		List<TicketItem> ticketItems = ticket.getTicketItems();

		Map<String, List<TicketItem>> itemMap = new LinkedHashMap<String, List<TicketItem>>();

		for (Iterator iterator = ticketItems.iterator(); iterator.hasNext();) {
			TicketItem newItem = (TicketItem) iterator.next();

			List<TicketItem> itemListInMap = itemMap.get(newItem.getItemId().toString());

			if (itemListInMap == null) {
				List<TicketItem> list = new ArrayList<TicketItem>();
				list.add(newItem);

				itemMap.put(newItem.getItemId().toString(), list);
			}
			else {
				boolean merged = false;
				for (TicketItem itemInMap : itemListInMap) {
					if (itemInMap.isMergable(newItem, false)) {
						itemInMap.merge(newItem);
						merged = true;
						break;
					}
				}

				if (!merged) {
					itemListInMap.add(newItem);
				}
			}
		}

		ticket.getTicketItems().clear();
		Collection<List<TicketItem>> values = itemMap.values();
		for (List<TicketItem> list : values) {
			if (list != null) {
				ticket.getTicketItems().addAll(list);
			}
		}
		List<TicketItem> ticketItemList = ticket.getTicketItems();
		if (ticket.getOrderType().isAllowSeatBasedOrder()) {
			Collections.sort(ticketItemList, new Comparator<TicketItem>() {

				@Override
				public int compare(TicketItem o1, TicketItem o2) {
					return o1.getId() - o2.getId();
				}
			});
			Collections.sort(ticketItemList, new Comparator<TicketItem>() {

				@Override
				public int compare(TicketItem o1, TicketItem o2) {
					return o1.getSeatNumber() - o2.getSeatNumber();
				}

			});
		}
		ticket.calculatePrice();
	}

	public void updateView() {
		if (ticket == null) {
			tfSubtotal.setText(""); //$NON-NLS-1$
			tfDiscount.setText(""); //$NON-NLS-1$
			tfDeliveryCharge.setText(""); //$NON-NLS-1$
			tfTax.setText(""); //$NON-NLS-1$
			tfTotal.setText(""); //$NON-NLS-1$
			tfGratuity.setText(""); //$NON-NLS-1$
			return;
		}
		tfSubtotal.setText(NumberUtil.formatNumber(ticket.getSubtotalAmount()));
		tfDiscount.setText(NumberUtil.formatNumber(ticket.getDiscountAmount()));
		tfDeliveryCharge.setText(NumberUtil.formatNumber(ticket.getDeliveryCharge()));

		if (Application.getInstance().isPriceIncludesTax()) {
			tfTax.setText(Messages.getString("TicketView.35")); //$NON-NLS-1$
		}
		else {
			tfTax.setText(NumberUtil.formatNumber(ticket.getTaxAmount()));
		}
		if (ticket.getGratuity() != null) {
			tfGratuity.setText(NumberUtil.formatNumber(ticket.getGratuity().getAmount()));
		}
		else {
			tfGratuity.setText("0.00"); //$NON-NLS-1$
		}
		tfTotal.setText(NumberUtil.formatNumber(ticket.getTotalAmount()));
	}

	private JPanel createTicketInfoPanel() {

		JLabel lblTicket = new javax.swing.JLabel();
		lblTicket.setText(Messages.getString("SettleTicketDialog.0")); //$NON-NLS-1$

		JLabel labelTicketNumber = new JLabel();
		labelTicketNumber.setText("[" + String.valueOf(ticket.getId()) + "]"); //$NON-NLS-1$ //$NON-NLS-2$

		JLabel lblTable = new javax.swing.JLabel();
		lblTable.setText(", " + Messages.getString("SettleTicketDialog.3")); //$NON-NLS-1$ //$NON-NLS-2$

		JLabel labelTableNumber = new JLabel();
		labelTableNumber.setText("[" + getTableNumbers(ticket.getTableNumbers()) + "]"); //$NON-NLS-1$ //$NON-NLS-2$

		if (ticket.getTableNumbers().isEmpty()) {
			labelTableNumber.setVisible(false);
			lblTable.setVisible(false);
		}

		JLabel lblCustomer = new javax.swing.JLabel();
		lblCustomer.setText(", " + Messages.getString("SettleTicketDialog.10") + ": "); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

		JLabel labelCustomer = new JLabel();
		labelCustomer.setText(ticket.getProperty(Ticket.CUSTOMER_NAME));

		if (ticket.getProperty(Ticket.CUSTOMER_NAME) == null) {
			labelCustomer.setVisible(false);
			lblCustomer.setVisible(false);
		}

		JPanel ticketInfoPanel = new com.floreantpos.swing.TransparentPanel(new MigLayout("hidemode 3,insets 0", "[]0[]0[]0[]0[]0[]", "[]")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

		ticketInfoPanel.add(lblTicket);
		ticketInfoPanel.add(labelTicketNumber);
		ticketInfoPanel.add(lblTable);
		ticketInfoPanel.add(labelTableNumber);
		ticketInfoPanel.add(lblCustomer);
		ticketInfoPanel.add(labelCustomer);

		return ticketInfoPanel;
	}

	private String getTableNumbers(List<Integer> numbers) {

		String tableNumbers = ""; //$NON-NLS-1$

		for (Iterator iterator = numbers.iterator(); iterator.hasNext();) {
			Integer n = (Integer) iterator.next();
			tableNumbers += n;

			if (iterator.hasNext()) {
				tableNumbers += ", "; //$NON-NLS-1$
			}
		}
		return tableNumbers;
	}

	private JPanel createTotalViewerPanel() {

		JLabel lblSubtotal = new javax.swing.JLabel();
		lblSubtotal.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		lblSubtotal.setText(com.floreantpos.POSConstants.SUBTOTAL + ":" + " " + CurrencyUtil.getCurrencySymbol()); //$NON-NLS-1$ //$NON-NLS-2$

		tfSubtotal = new javax.swing.JTextField(10);
		tfSubtotal.setHorizontalAlignment(SwingConstants.TRAILING);
		tfSubtotal.setEditable(false);

		JLabel lblDiscount = new javax.swing.JLabel();
		lblDiscount.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		lblDiscount.setText(Messages.getString("TicketView.9") + " " + CurrencyUtil.getCurrencySymbol()); //$NON-NLS-1$ //$NON-NLS-2$

		tfDiscount = new javax.swing.JTextField(10);
		//	tfDiscount.setFont(tfDiscount.getFont().deriveFont(Font.PLAIN, 16));
		tfDiscount.setHorizontalAlignment(SwingConstants.TRAILING);
		tfDiscount.setEditable(false);
		tfDiscount.setText(ticket.getDiscountAmount().toString());

		JLabel lblDeliveryCharge = new javax.swing.JLabel();
		lblDeliveryCharge.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		lblDeliveryCharge.setText("Delivery Charge:" + " " + CurrencyUtil.getCurrencySymbol()); //$NON-NLS-1$ //$NON-NLS-2$

		tfDeliveryCharge = new javax.swing.JTextField(10);
		tfDeliveryCharge.setHorizontalAlignment(SwingConstants.TRAILING);
		tfDeliveryCharge.setEditable(false);

		JLabel lblTax = new javax.swing.JLabel();
		lblTax.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		lblTax.setText(com.floreantpos.POSConstants.TAX + ":" + " " + CurrencyUtil.getCurrencySymbol()); //$NON-NLS-1$ //$NON-NLS-2$

		tfTax = new javax.swing.JTextField(10);
		//	tfTax.setFont(tfTax.getFont().deriveFont(Font.PLAIN, 16));
		tfTax.setEditable(false);
		tfTax.setHorizontalAlignment(SwingConstants.TRAILING);

		JLabel lblGratuity = new javax.swing.JLabel();
		lblGratuity.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		lblGratuity.setText(Messages.getString("SettleTicketDialog.5") + ":" + " " + CurrencyUtil.getCurrencySymbol()); //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$

		tfGratuity = new javax.swing.JTextField(10);
		tfGratuity.setEditable(false);
		tfGratuity.setHorizontalAlignment(SwingConstants.TRAILING);

		JLabel lblTotal = new javax.swing.JLabel();
		lblTotal.setFont(lblTotal.getFont().deriveFont(Font.BOLD, PosUIManager.getFontSize(18)));
		lblTotal.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		lblTotal.setText(com.floreantpos.POSConstants.TOTAL + ":" + " " + CurrencyUtil.getCurrencySymbol()); //$NON-NLS-1$ //$NON-NLS-2$

		tfTotal = new javax.swing.JTextField(10);
		tfTotal.setFont(tfTotal.getFont().deriveFont(Font.BOLD, PosUIManager.getFontSize(18)));
		tfTotal.setHorizontalAlignment(SwingConstants.TRAILING);
		tfTotal.setEditable(false);

		JPanel ticketAmountPanel = new com.floreantpos.swing.TransparentPanel(new MigLayout("hidemode 3,ins 2 2 3 2,alignx trailing,fill", "[grow]2[]", "")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

		ticketAmountPanel.add(lblSubtotal, "growx,aligny center"); //$NON-NLS-1$
		ticketAmountPanel.add(tfSubtotal, "growx,aligny center"); //$NON-NLS-1$
		ticketAmountPanel.add(lblDiscount, "newline,growx,aligny center"); //$NON-NLS-1$ //$NON-NLS-2$
		ticketAmountPanel.add(tfDiscount, "growx,aligny center"); //$NON-NLS-1$
		ticketAmountPanel.add(lblTax, "newline,growx,aligny center"); //$NON-NLS-1$
		ticketAmountPanel.add(tfTax, "growx,aligny center"); //$NON-NLS-1$
		if (ticket.getOrderType().isDelivery() && !ticket.isCustomerWillPickup()) {
			ticketAmountPanel.add(lblDeliveryCharge, "newline,growx,aligny center"); //$NON-NLS-1$
			ticketAmountPanel.add(tfDeliveryCharge, "growx,aligny center"); //$NON-NLS-1$
		}
		ticketAmountPanel.add(lblGratuity, "newline,growx,aligny center"); //$NON-NLS-1$
		ticketAmountPanel.add(tfGratuity, "growx,aligny center"); //$NON-NLS-1$
		ticketAmountPanel.add(lblTotal, "newline,growx,aligny center"); //$NON-NLS-1$
		ticketAmountPanel.add(tfTotal, "growx,aligny center"); //$NON-NLS-1$

		return ticketAmountPanel;
	}

	private void updateModel() {
		if (ticket == null) {
			return;
		}
		ticket.calculatePrice();
	}

	public void doApplyCoupon() {// GEN-FIRST:event_btnApplyCoupondoApplyCoupon
		try {
			if (ticket == null)
				return;

			if (!Application.getCurrentUser().hasPermission(UserPermission.ADD_DISCOUNT)) {
				POSMessageDialog.showError(Application.getPosWindow(), Messages.getString("SettleTicketDialog.7")); //$NON-NLS-1$
				return;
			}

			DiscountSelectionDialog dialog = new DiscountSelectionDialog(ticket);
			dialog.open();

			if (dialog.isCanceled()) {
				return;
			}

			updateModel();
			ticketViewerTable.repaint();
			ticketViewerTable.updateView();
			updateView();

			OrderController.saveOrder(ticket);
			paymentView.updateView();
			OrderView.getInstance().setCurrentTicket(ticket);
		} catch (Exception e) {
			POSMessageDialog.showError(this, com.floreantpos.POSConstants.ERROR_MESSAGE, e);
		}
	}

	public void doSetGratuity() {
		if (ticket == null)
			return;

		GratuityInputDialog d = new GratuityInputDialog();
		d.pack();
		d.setResizable(false);
		d.open();

		if (d.isCanceled()) {
			return;
		}

		double gratuityAmount = d.getGratuityAmount();
		Gratuity gratuity = ticket.createGratuity();
		gratuity.setAmount(gratuityAmount);

		ticket.setGratuity(gratuity);
		ticket.calculatePrice();
		OrderController.saveOrder(ticket);
		paymentView.updateView();
		updateView();
	}

	public void doSettle(PaymentType paymentType) {
		try {
			if (ticket == null)
				return;
			this.paymentType = paymentType;
			tenderAmount = paymentView.getTenderedAmount();

			/*if (ticket.getOrderType().isBarTab()) { //fix
				doSettleBarTabTicket(ticket);
				return;
			}*/

			cardName = paymentType.getDisplayString();
			PosTransaction transaction = null;

			switch (paymentType) {
				case CASH:
					if (!confirmPayment()) {
						return;
					}

					transaction = paymentType.createTransaction();
					transaction.setTicket(ticket);
					transaction.setCaptured(true);
					setTransactionAmounts(transaction);

					settleTicket(transaction);
					break;

				case CUSTOM_PAYMENT:

					CustomPaymentSelectionDialog customPaymentDialog = new CustomPaymentSelectionDialog();
					customPaymentDialog.setTitle(Messages.getString("SettleTicketDialog.8")); //$NON-NLS-1$
					customPaymentDialog.pack();
					customPaymentDialog.open();

					if (customPaymentDialog.isCanceled())
						return;

					if (!confirmPayment()) {
						return;
					}

					transaction = paymentType.createTransaction();
					transaction.setCustomPaymentFieldName(customPaymentDialog.getPaymentFieldName());
					transaction.setCustomPaymentName(customPaymentDialog.getPaymentName());
					transaction.setCustomPaymentRef(customPaymentDialog.getPaymentRef());
					transaction.setTicket(ticket);
					transaction.setCaptured(true);
					setTransactionAmounts(transaction);

					settleTicket(transaction);
					break;

				case CREDIT_CARD:
				case CREDIT_VISA:
				case CREDIT_MASTER_CARD:
				case CREDIT_AMEX:
				case CREDIT_DISCOVERY:
					payUsingCard(cardName, tenderAmount);
					break;

				case DEBIT_VISA:
				case DEBIT_MASTER_CARD:
					payUsingCard(cardName, tenderAmount);
					break;

				case GIFT_CERTIFICATE:
					GiftCertDialog giftCertDialog = new GiftCertDialog(this);
					giftCertDialog.pack();
					giftCertDialog.open();

					if (giftCertDialog.isCanceled())
						return;

					transaction = new GiftCertificateTransaction();
					transaction.setPaymentType(PaymentType.GIFT_CERTIFICATE.name());
					transaction.setTicket(ticket);
					transaction.setCaptured(true);
					setTransactionAmounts(transaction);

					double giftCertFaceValue = giftCertDialog.getGiftCertFaceValue();
					double giftCertCashBackAmount = 0;
					transaction.setTenderAmount(giftCertFaceValue);

					if (giftCertFaceValue >= ticket.getDueAmount()) {
						transaction.setAmount(ticket.getDueAmount());
						giftCertCashBackAmount = giftCertFaceValue - ticket.getDueAmount();
					}
					else {
						transaction.setAmount(giftCertFaceValue);
					}

					transaction.setGiftCertNumber(giftCertDialog.getGiftCertNumber());
					transaction.setGiftCertFaceValue(giftCertFaceValue);
					transaction.setGiftCertPaidAmount(transaction.getAmount());
					transaction.setGiftCertCashBackAmount(giftCertCashBackAmount);

					settleTicket(transaction);
					break;

				default:
					break;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private boolean confirmPayment() {
		if (!TerminalConfig.isUseSettlementPrompt()) {
			return true;
		}

		ConfirmPayDialog confirmPayDialog = new ConfirmPayDialog();
		confirmPayDialog.setAmount(tenderAmount);
		confirmPayDialog.open();

		if (confirmPayDialog.isCanceled()) {
			return false;
		}

		return true;
	}

	public void doSettleBarTabTicket(Ticket ticket) {
		try {
			String msg = "Do you want to settle ticket?"; //$NON-NLS-1$
			int option1 = POSMessageDialog.showYesNoQuestionDialog(null, msg, Messages.getString("NewBarTabAction.4")); //$NON-NLS-1$
			if (option1 != JOptionPane.YES_OPTION) {
				return;
			}
			else {
				for (PosTransaction barTabTransaction : ticket.getTransactions()) {
					barTabTransaction.setAmount(ticket.getDueAmount());
					barTabTransaction.setTenderAmount(ticket.getDueAmount());
					barTabTransaction.setAuthorizable(true);
					settleTicket(barTabTransaction);
				}
			}
		} catch (Exception e) {
			POSMessageDialog.showError(Application.getPosWindow(), e.getMessage(), e);
		}
	}

	public void settleTicket(PosTransaction transaction) {
		try {
			final double dueAmount = ticket.getDueAmount();

			confirmLoyaltyDiscount(ticket);

			PosTransactionService transactionService = PosTransactionService.getInstance();
			transactionService.settleTicket(ticket, transaction);

			//FIXME
			printTicket(ticket, transaction);

			showTransactionCompleteMsg(dueAmount, transaction.getTenderAmount(), ticket, transaction);

			if (ticket.getDueAmount() > 0.0) {
				int option = JOptionPane.showConfirmDialog(Application.getPosWindow(), POSConstants.CONFIRM_PARTIAL_PAYMENT, POSConstants.MDS_POS,
						JOptionPane.YES_NO_OPTION);

				if (option != JOptionPane.YES_OPTION) {

					setCanceled(false);
					dispose();
				}

				setTicket(ticket);
			}
			else {
				setCanceled(false);
				dispose();
			}
		} catch (UnknownHostException e) {
			POSMessageDialog.showError(Application.getPosWindow(), Messages.getString("SettleTicketDialog.12")); //$NON-NLS-1$
		} catch (Exception e) {
			POSMessageDialog.showError(this, POSConstants.ERROR_MESSAGE, e);
		}
	}

	public static void showTransactionCompleteMsg(final double dueAmount, final double tenderedAmount, Ticket ticket, PosTransaction transaction) {
		TransactionCompletionDialog dialog = new TransactionCompletionDialog(transaction);
		dialog.setCompletedTransaction(transaction);
		dialog.setTenderedAmount(tenderedAmount);
		dialog.setTotalAmount(dueAmount);
		dialog.setPaidAmount(transaction.getAmount());
		dialog.setDueAmount(ticket.getDueAmount());
		if (tenderedAmount > transaction.getAmount()) {
			dialog.setChangeAmount(tenderedAmount - transaction.getAmount());
		}
		else {
			dialog.setChangeAmount(0);
		}

		dialog.updateView();
		dialog.pack();
		dialog.open();
	}

	public void confirmLoyaltyDiscount(Ticket ticket) throws IOException, MalformedURLException {
		try {
			if (ticket.hasProperty(LOYALTY_ID)) {
				String url = buildLoyaltyApiURL(ticket, ticket.getProperty(LOYALTY_ID));
				url += "&paid=1"; //$NON-NLS-1$

				IOUtils.toString(new URL(url).openStream());
			}
		} catch (Exception e) {
			POSMessageDialog.showError(Application.getPosWindow(), e.getMessage(), e);
		}
	}

	public static void printTicket(Ticket ticket, PosTransaction transaction) {
		try {
			if (ticket.getOrderType().isShouldPrintToKitchen()) {
				if (ticket.needsKitchenPrint()) {
					ReceiptPrintService.printToKitchen(ticket);
				}
			}

			ReceiptPrintService.printTransaction(transaction);

			if (transaction instanceof CashTransaction) {
				DrawerUtil.kickDrawer();
			}
		} catch (Exception ee) {
			POSMessageDialog.showError(Application.getPosWindow(), com.floreantpos.POSConstants.PRINT_ERROR, ee);
		}
	}

	private void payUsingCard(String cardName, final double tenderedAmount) throws Exception {
		try {
			//		if (!CardConfig.getMerchantGateway().isCardTypeSupported(cardName)) {
			//			POSMessageDialog.showError(Application.getPosWindow(), "<html>Card <b>" + cardName + "</b> not supported.</html>");
			//			return;
			//		}

			PaymentGatewayPlugin paymentGateway = CardConfig.getPaymentGateway();

			if (paymentGateway instanceof InginicoPlugin) {
				waitDialog.setVisible(true);
				if (!waitDialog.isCanceled()) {
					dispose();
				}
				return;
			}
			if (!paymentGateway.shouldShowCardInputProcessor()) {

				PosTransaction transaction = paymentType.createTransaction();
				transaction.setTicket(ticket);

				if (!confirmPayment()) {
					return;
				}

				//transaction.setCardType(cardName);
				transaction.setCaptured(false);
				transaction.setCardMerchantGateway(paymentGateway.getName());

				setTransactionAmounts(transaction);

				if (ticket.getOrderType().isPreAuthCreditCard()) {
					paymentGateway.getProcessor().preAuth(transaction);
				}
				else {
					paymentGateway.getProcessor().chargeAmount(transaction);
				}

				settleTicket(transaction);

				return;
			}

			CardReader cardReader = CardConfig.getCardReader();
			switch (cardReader) {
				case SWIPE:
					SwipeCardDialog swipeCardDialog = new SwipeCardDialog(this);
					swipeCardDialog.pack();
					swipeCardDialog.open();
					break;

				case MANUAL:
					ManualCardEntryDialog dialog = new ManualCardEntryDialog(this);
					dialog.pack();
					dialog.open();
					break;

				case EXTERNAL_TERMINAL:
					AuthorizationCodeDialog authorizationCodeDialog = new AuthorizationCodeDialog(this);
					authorizationCodeDialog.pack();
					authorizationCodeDialog.open();
					break;

				default:
					break;
			}
		} catch (Exception e) {
			POSMessageDialog.showError(this, e.getMessage(), e);
		}

	}

	@Override
	public void open() {
		super.open();
	}

	@Override
	public void cardInputted(CardInputProcessor inputter, PaymentType selectedPaymentType) {
		//authorize only, do not capture
		PaymentProcessWaitDialog waitDialog = new PaymentProcessWaitDialog(this);
		try {

			waitDialog.setVisible(true);

			PosTransaction transaction = paymentType.createTransaction();
			transaction.setTicket(ticket);

			PaymentGatewayPlugin paymentGateway = CardConfig.getPaymentGateway();
			CardProcessor cardProcessor = paymentGateway.getProcessor();

			if (inputter instanceof SwipeCardDialog) {

				SwipeCardDialog swipeCardDialog = (SwipeCardDialog) inputter;
				String cardString = swipeCardDialog.getCardString();

				if (StringUtils.isEmpty(cardString) || cardString.length() < 16) {
					throw new RuntimeException(Messages.getString("SettleTicketDialog.16")); //$NON-NLS-1$
				}

				if (!confirmPayment()) {
					return;
				}
				transaction.setCardType(paymentType.getDisplayString());
				transaction.setCardTrack(cardString);
				transaction.setCaptured(false);
				transaction.setCardMerchantGateway(paymentGateway.getName());
				transaction.setCardReader(CardReader.SWIPE.name());
				setTransactionAmounts(transaction);

				if (ticket.getOrderType().isPreAuthCreditCard()) {//OK
					cardProcessor.preAuth(transaction);
				}
				else {
					cardProcessor.chargeAmount(transaction);
				}

				settleTicket(transaction);
			}
			else if (inputter instanceof ManualCardEntryDialog) {

				ManualCardEntryDialog mDialog = (ManualCardEntryDialog) inputter;

				transaction.setCaptured(false);
				transaction.setCardMerchantGateway(paymentGateway.getName());
				transaction.setCardReader(CardReader.MANUAL.name());
				transaction.setCardNumber(mDialog.getCardNumber());
				transaction.setCardExpMonth(mDialog.getExpMonth());
				transaction.setCardExpYear(mDialog.getExpYear());
				setTransactionAmounts(transaction);

				cardProcessor.preAuth(transaction);

				settleTicket(transaction);
			}
			else if (inputter instanceof AuthorizationCodeDialog) {

				PosTransaction selectedTransaction = selectedPaymentType.createTransaction();
				selectedTransaction.setTicket(ticket);

				AuthorizationCodeDialog authDialog = (AuthorizationCodeDialog) inputter;
				String authorizationCode = authDialog.getAuthorizationCode();
				if (StringUtils.isEmpty(authorizationCode)) {
					throw new PosException(Messages.getString("SettleTicketDialog.17")); //$NON-NLS-1$
				}

				selectedTransaction.setCardType(selectedPaymentType.getDisplayString());
				selectedTransaction.setCaptured(false);
				selectedTransaction.setCardReader(CardReader.EXTERNAL_TERMINAL.name());
				selectedTransaction.setCardAuthCode(authorizationCode);
				setTransactionAmounts(selectedTransaction);

				settleTicket(selectedTransaction);
			}
		} catch (Exception e) {
			e.printStackTrace();
			POSMessageDialog.showError(Application.getPosWindow(), e.getMessage());
		} finally {
			waitDialog.setVisible(false);
		}
	}

	private void setTransactionAmounts(PosTransaction transaction) {
		transaction.setTenderAmount(tenderAmount);

		if (tenderAmount >= ticket.getDueAmount()) {
			transaction.setAmount(ticket.getDueAmount());
		}
		else {
			transaction.setAmount(tenderAmount);
		}
	}

	public boolean hasMyKalaId() {
		if (ticket == null)
			return false;

		if (ticket.hasProperty(LOYALTY_ID)) {
			return true;
		}

		return false;
	}

	public void submitMyKalaDiscount() {
		if (ticket.hasProperty(LOYALTY_ID)) {
			POSMessageDialog.showError(Application.getPosWindow(), Messages.getString("SettleTicketDialog.18")); //$NON-NLS-1$
			return;
		}

		try {
			String loyaltyid = JOptionPane.showInputDialog(Messages.getString("SettleTicketDialog.19")); //$NON-NLS-1$

			if (StringUtils.isEmpty(loyaltyid)) {
				return;
			}

			ticket.addProperty(LOYALTY_ID, loyaltyid);

			String transactionURL = buildLoyaltyApiURL(ticket, loyaltyid);

			String string = IOUtils.toString(new URL(transactionURL).openStream());

			JsonReader reader = Json.createReader(new StringReader(string));
			JsonObject object = reader.readObject();
			JsonArray jsonArray = (JsonArray) object.get("discounts"); //$NON-NLS-1$
			for (int i = 0; i < jsonArray.size(); i++) {
				JsonObject jsonObject = (JsonObject) jsonArray.get(i);
				addCoupon(ticket, jsonObject);
			}

			updateModel();

			OrderController.saveOrder(ticket);

			POSMessageDialog.showMessage(Application.getPosWindow(), Messages.getString("SettleTicketDialog.21")); //$NON-NLS-1$
			paymentView.updateView();
		} catch (Exception e) {
			POSMessageDialog.showError(Application.getPosWindow(), Messages.getString("SettleTicketDialog.22"), e); //$NON-NLS-1$
		}
	}

	public String buildLoyaltyApiURL(Ticket ticket, String loyaltyid) {
		Restaurant restaurant = Application.getInstance().getRestaurant();

		String transactionURL = "http://cloud.floreantpos.org/tri2/kala_api?"; //$NON-NLS-1$
		transactionURL += "kala_id=" + loyaltyid; //$NON-NLS-1$
		transactionURL += "&store_id=" + restaurant.getUniqueId(); //$NON-NLS-1$
		transactionURL += "&store_name=" + POSUtil.encodeURLString(restaurant.getName()); //$NON-NLS-1$
		transactionURL += "&store_zip=" + restaurant.getZipCode(); //$NON-NLS-1$
		transactionURL += "&terminal=" + ticket.getTerminal().getId(); //$NON-NLS-1$
		transactionURL += "&server=" + POSUtil.encodeURLString(ticket.getOwner().getFirstName() + " " + ticket.getOwner().getLastName()); //$NON-NLS-1$ //$NON-NLS-2$
		transactionURL += "&" + ticket.toURLForm(); //$NON-NLS-1$

		return transactionURL;
	}

	private void addCoupon(Ticket ticket, JsonObject jsonObject) {
		Set<String> keys = jsonObject.keySet();
		for (String key : keys) {
			JsonNumber jsonNumber = jsonObject.getJsonNumber(key);
			double doubleValue = jsonNumber.doubleValue();

			TicketDiscount coupon = new TicketDiscount();
			coupon.setName(key);
			coupon.setType(Discount.FIXED_PER_ORDER);
			coupon.setValue(doubleValue);

			ticket.addTodiscounts(coupon);
		}
	}

	public Ticket getTicket() {
		return ticket;
	}

	public void setTicket(Ticket ticket) {
		this.ticket = ticket;
		paymentView.updateView();
	}
}
