import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/entities/deal_entity.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/use_cases/get_deals_use_case.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/use_cases/toggle_deal_wishlist_use_case.dart';
import 'dart:async';

part 'deals_event.dart';
part 'deals_state.dart';

class DealsBloc extends Bloc<DealsEvent, DealsState> {
  final GetDealsUseCase getDealsUseCase;
  final ToggleDealWishlistUseCase toggleWishlistUseCase;
  StreamSubscription? _dealsSubscription;

  DealsBloc({
    required this.getDealsUseCase,
    required this.toggleWishlistUseCase,
  }) : super(DealsInitial()) {
    print('DealsBloc: Constructor called');
    
    on<LoadDeals>((event, emit) {
      print('DealsBloc: LoadDeals event received for userId: ${event.userId}');
      emit(DealsLoading());
      _dealsSubscription?.cancel();
      _dealsSubscription = getDealsUseCase(event.userId).listen(
        (deals) {
          print('DealsBloc: Received ${deals.length} deals from use case');
          add(UpdateDeals(deals));
        },
        onError: (error) {
          print('DealsBloc: Error loading deals: $error');
          emit(DealsError(error.toString()));
        },
      );
    });

    on<UpdateDeals>((event, emit) {
      print('DealsBloc: UpdateDeals event received with ${event.deals.length} deals');
      emit(DealsLoaded(event.deals));
    });

    on<ToggleDealWishlist>((event, emit) async {
      print('DealsBloc: ToggleDealWishlist event received');
      try {
        await toggleWishlistUseCase(event.dealId, event.userId, event.isAdding);
        print('DealsBloc: Wishlist toggled successfully');
      } catch (e) {
        print('DealsBloc: Error toggling wishlist: $e');
        emit(DealsError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _dealsSubscription?.cancel();
    return super.close();
  }
}
