import 'dart:async';
import 'dart:io';

import 'package:agritechv2/models/Address.dart';
import 'package:agritechv2/models/transaction/TransactionSchedule.dart';
import 'package:agritechv2/models/transaction/TransactionStatus.dart';
import 'package:agritechv2/models/transaction/TransactionType.dart';
import 'package:agritechv2/repository/transaction_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/transaction/OrderItems.dart';
import '../../models/transaction/PaymentMethod.dart';
import '../../models/transaction/ShippingFee.dart';
import '../../models/transaction/TransactionDetails.dart';
import '../../models/transaction/Transactions.dart';
import '../../utils/Constants.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepostory _transactionRepostory;
  TransactionsBloc({required TransactionRepostory transactionRepostory})
      : _transactionRepostory = transactionRepostory,
        super(TransactionsInitial()) {
    on<TransactionsEvent>((event, emit) {});

    on<SubmitTransactionEvent>(_onSubmitTransaction);
    on<GetTransactionsByStatus>(_onGetTransactionsByStatus);
    on<CancelTransactionEvent>(_onCancelTransaction);
    on<AddGcashPayment>(_onGcashPayment);
  }

  Future<void> _onSubmitTransaction(
      SubmitTransactionEvent event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoadingState());
    try {
      await _transactionRepostory.submitTransaction(event.transactions);
      Future.delayed(const Duration(seconds: 2));
      var id = event.transactions.id;
      emit(TransactionsSuccessState<String>(id));
    } catch (e) {
      emit(TransactionsFailedState(e.toString()));
      emit(TransactionsInitial());
    }
  }

  Future<void> _onGetTransactionsByStatus(
      GetTransactionsByStatus event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoadingState());
    try {
      List<Transactions> results = await _transactionRepostory
          .getTransactionsByStatus(event.status, event.customerID);
      Future.delayed(const Duration(seconds: 2));
      print("results : ${results}");
      emit(TransactionsSuccessState<List<Transactions>>(results));
    } catch (e) {
      emit(TransactionsFailedState(e.toString()));
    }
  }

  Future<void> _onCancelTransaction(
      CancelTransactionEvent event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoadingState());
    try {
      await _transactionRepostory.cancelTrancsaction(
          event.transactionID, event.name, event.message);
      Future.delayed(const Duration(seconds: 1));
      emit(const TransactionsSuccessState<String>("Cancel confirmed!"));
    } catch (e) {
      emit(TransactionsFailedState(e.toString()));
    }
  }

  Future<void> _onGcashPayment(
      AddGcashPayment event, Emitter<TransactionsState> emit) async {
    try {
      emit(TransactionsLoadingState());
      print(event.transactionID);

      final result =
          await _transactionRepostory.uploadTransactionAttachment(event.file);
      print("Uploaded");
      if (result != null) {
        PaymentDetails details = PaymentDetails(
            createdAt: DateTime.now(),
            confirmedBy: event.customerName,
            reference: '',
            attachmentURL: result);
        event.payment.details = details;
        event.payment.status = PaymentStatus.PAID;
        print(event.transactionID);
        await _transactionRepostory
            .gcashPayment(event.transactionID, event.payment)
            .then((_) {
          emit(const TransactionsSuccessState<String>("Payment confirmed!"));
          print("success");
        }).catchError((err) {
          print(err);
          if (!emit.isDone) {
            emit(TransactionsFailedState(err.toString()));
          }
        });
      } else {
        print("error");
        emit(
            const TransactionsFailedState("Failed to upload transaction file"));
      }
    } catch (e) {
      print(e);
      emit(TransactionsFailedState(e.toString()));
    }
  }
}
