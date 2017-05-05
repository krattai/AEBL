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
package com.floreantpos.actions;

import java.awt.Component;
import java.awt.event.ActionEvent;
import java.util.Calendar;

import javax.swing.AbstractAction;
import javax.swing.JOptionPane;

import org.apache.commons.lang.StringUtils;

import com.floreantpos.ITicketList;
import com.floreantpos.Messages;
import com.floreantpos.PosException;
import com.floreantpos.config.CardConfig;
import com.floreantpos.extension.PaymentGatewayPlugin;
import com.floreantpos.main.Application;
import com.floreantpos.model.CardReader;
import com.floreantpos.model.OrderType;
import com.floreantpos.model.PaymentType;
import com.floreantpos.model.PosTransaction;
import com.floreantpos.model.Ticket;
import com.floreantpos.model.dao.TicketDAO;
import com.floreantpos.services.PosTransactionService;
import com.floreantpos.ui.dialog.POSMessageDialog;
import com.floreantpos.ui.dialog.PaymentTypeSelectionDialog;
import com.floreantpos.ui.views.order.OrderView;
import com.floreantpos.ui.views.order.RootView;
import com.floreantpos.ui.views.payment.AuthorizationCodeDialog;
import com.floreantpos.ui.views.payment.CardInputListener;
import com.floreantpos.ui.views.payment.CardInputProcessor;
import com.floreantpos.ui.views.payment.CardProcessor;
import com.floreantpos.ui.views.payment.ManualCardEntryDialog;
import com.floreantpos.ui.views.payment.PaymentProcessWaitDialog;
import com.floreantpos.ui.views.payment.SwipeCardDialog;
import com.floreantpos.util.CurrencyUtil;

public class NewBarTabAction extends AbstractAction implements CardInputListener {
	private Component parentComponent;
	private PaymentType selectedPaymentType;
	private OrderType orderType;

	public NewBarTabAction(OrderType orderType, Component parentComponent) {
		this.orderType = orderType;
		this.parentComponent = parentComponent;
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		PaymentTypeSelectionDialog paymentTypeSelectionDialog = new PaymentTypeSelectionDialog();
		paymentTypeSelectionDialog.setCashButtonVisible(false);
		paymentTypeSelectionDialog.pack();
		paymentTypeSelectionDialog.setLocationRelativeTo(parentComponent);
		paymentTypeSelectionDialog.setVisible(true);

		if (paymentTypeSelectionDialog.isCanceled()) {
			return;
		}

		selectedPaymentType = paymentTypeSelectionDialog.getSelectedPaymentType();

		String symbol = CurrencyUtil.getCurrencySymbol();
		String message = symbol + CardConfig.getBartabLimit() + Messages.getString("NewBarTabAction.3"); //$NON-NLS-1$

		int option = POSMessageDialog.showYesNoQuestionDialog(parentComponent, message, Messages.getString("NewBarTabAction.4")); //$NON-NLS-1$
		if (option != JOptionPane.YES_OPTION) {
			return;
		}

		SwipeCardDialog dialog = new SwipeCardDialog(this);
		dialog.setTitle(Messages.getString("NewBarTabAction.0")); //$NON-NLS-1$
		dialog.pack();
		dialog.open();
	}

	private Ticket createTicket() {
		Ticket ticket = new Ticket();

		Application application = Application.getInstance();
		ticket.setPriceIncludesTax(application.isPriceIncludesTax());
		ticket.setOrderType(orderType);
		ticket.setTerminal(application.getTerminal());
		ticket.setOwner(Application.getCurrentUser());
		ticket.setShift(application.getCurrentShift());

		Calendar currentTime = Calendar.getInstance();
		ticket.setCreateDate(currentTime.getTime());
		ticket.setCreationHour(currentTime.get(Calendar.HOUR_OF_DAY));

		return ticket;
	}

	@Override
	public void cardInputted(CardInputProcessor inputter, PaymentType paymentType) {
		PaymentProcessWaitDialog waitDialog = new PaymentProcessWaitDialog(Application.getPosWindow());
		try {

			waitDialog.setVisible(true);

			PosTransaction transaction = selectedPaymentType.createTransaction();

			Ticket ticket = createTicket();
			transaction.setTicket(ticket);
			transaction.setAuthorizable(false);
			transaction.setTenderAmount(CardConfig.getBartabLimit());

			PaymentGatewayPlugin paymentGateway = CardConfig.getPaymentGateway();
			CardProcessor cardProcessor = paymentGateway.getProcessor();

			if (inputter instanceof SwipeCardDialog) {

				SwipeCardDialog swipeCardDialog = (SwipeCardDialog) inputter;
				String cardString = swipeCardDialog.getCardString();

				if (StringUtils.isEmpty(cardString) || cardString.length() < 16) {
					throw new RuntimeException(Messages.getString("SettleTicketDialog.16")); //$NON-NLS-1$
				}

				transaction.setCardType(paymentType.getDisplayString());
				transaction.setCardTrack(cardString);
				transaction.setCaptured(false);
				transaction.setCardMerchantGateway(paymentGateway.getName());
				transaction.setCardReader(CardReader.SWIPE.name());


				if (ticket.getOrderType().isPreAuthCreditCard()) {
					cardProcessor.preAuth(transaction);
				}
				else {
					cardProcessor.chargeAmount(transaction);
				}

				saveTicket(transaction);

			}
			else if (inputter instanceof ManualCardEntryDialog) {

				ManualCardEntryDialog mDialog = (ManualCardEntryDialog) inputter;

				transaction.setCaptured(false);
				transaction.setCardMerchantGateway(paymentGateway.getName());
				transaction.setCardReader(CardReader.MANUAL.name());
				transaction.setCardNumber(mDialog.getCardNumber());
				transaction.setCardExpMonth(mDialog.getExpMonth());
				transaction.setCardExpYear(mDialog.getExpYear());

				cardProcessor.preAuth(transaction);

				saveTicket(transaction);
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

				saveTicket(selectedTransaction);
			}
		} catch (Exception e) {
			e.printStackTrace();
			POSMessageDialog.showError(Application.getPosWindow(), e.getMessage());
		} finally {
			waitDialog.setVisible(false);
		}
	}

	private void saveTicket(PosTransaction transaction) {
		try {
			PosTransactionService transactionService = PosTransactionService.getInstance();
			transactionService.settleBarTabTicket(transaction.getTicket(), transaction, false);

			POSMessageDialog.showMessage(Messages.getString("NewBarTabAction.5") + transaction.getTicket().getId()); //$NON-NLS-1$
			if (parentComponent instanceof ITicketList) {
				((ITicketList) parentComponent).updateTicketList();
			}

			doEditTicket(transaction.getTicket());
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void doEditTicket(Ticket ticket) {
		Ticket ticketToEdit = TicketDAO.getInstance().loadFullTicket(ticket.getId());

		OrderView.getInstance().setCurrentTicket(ticketToEdit);
		RootView.getInstance().showView(OrderView.VIEW_NAME);
		OrderView.getInstance().getTicketView().getTxtSearchItem().requestFocus();
	}
}
