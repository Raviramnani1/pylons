// Mocks generated by Mockito 5.3.2 from annotations
// in pylons_wallet/test/widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:dartz/dartz.dart' as _i2;
import 'package:fixnum/fixnum.dart' as _i11;
import 'package:mobx/mobx.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:pylons_wallet/ipc/models/sdk_ipc_response.dart' as _i3;
import 'package:pylons_wallet/model/common.dart';
import 'package:pylons_wallet/modules/cosmos.tx.v1beta1/module/client/cosmos/base/abci/v1beta1/abci.pb.dart'
    as _i4;
import 'package:pylons_wallet/modules/Pylonstech.pylons.pylons/module/export.dart'
    as _i10;
import 'package:pylons_wallet/services/data_stores/remote_data_store.dart'
    as _i12;
import 'package:pylons_wallet/stores/wallet_store.dart' as _i6;
import 'package:pylons_wallet/utils/failure/failure.dart' as _i8;
import 'package:transaction_signing_gateway/transaction_signing_gateway.dart'
    as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeEither_0<L, R> extends _i1.SmartFake implements _i2.Either<L, R> {
  _FakeEither_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSdkIpcResponse_1<T> extends _i1.SmartFake
    implements _i3.SdkIpcResponse<T> {
  _FakeSdkIpcResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTxResponse_2 extends _i1.SmartFake implements _i4.TxResponse {
  _FakeTxResponse_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeObservable_3<T> extends _i1.SmartFake implements _i5.Observable<T> {
  _FakeObservable_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [WalletsStore].
///
/// See the documentation for Mockito's code generation for more information.
class MockWalletsStore extends _i1.Mock implements _i6.WalletsStore {
  MockWalletsStore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<_i2.Either<_i8.Failure, _i9.AccountPublicInfo>> importAlanWallet(
    String? mnemonic,
    String? userName,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #importAlanWallet,
          [
            mnemonic,
            userName,
          ],
        ),
        returnValue:
            _i7.Future<_i2.Either<_i8.Failure, _i9.AccountPublicInfo>>.value(
                _FakeEither_0<_i8.Failure, _i9.AccountPublicInfo>(
          this,
          Invocation.method(
            #importAlanWallet,
            [
              mnemonic,
              userName,
            ],
          ),
        )),
      ) as _i7.Future<_i2.Either<_i8.Failure, _i9.AccountPublicInfo>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<String>> createCookbook(
          Map<dynamic, dynamic>? json) =>
      (super.noSuchMethod(
        Invocation.method(
          #createCookbook,
          [json],
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<String>>.value(
            _FakeSdkIpcResponse_1<String>(
          this,
          Invocation.method(
            #createCookbook,
            [json],
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<String>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> createRecipe(
          Map<dynamic, dynamic>? json) =>
      (super.noSuchMethod(
        Invocation.method(
          #createRecipe,
          [json],
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #createRecipe,
            [json],
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<_i10.Execution>> executeRecipe(
          Map<dynamic, dynamic>? json) =>
      (super.noSuchMethod(
        Invocation.method(
          #executeRecipe,
          [json],
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<_i10.Execution>>.value(
            _FakeSdkIpcResponse_1<_i10.Execution>(
          this,
          Invocation.method(
            #executeRecipe,
            [json],
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<_i10.Execution>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> createTrade(
          Map<dynamic, dynamic>? json) =>
      (super.noSuchMethod(
        Invocation.method(
          #createTrade,
          [json],
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #createTrade,
            [json],
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> fulfillTrade(
          Map<dynamic, dynamic>? json) =>
      (super.noSuchMethod(
        Invocation.method(
          #fulfillTrade,
          [json],
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #fulfillTrade,
            [json],
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i4.TxResponse> getTxs(String? txHash) => (super.noSuchMethod(
        Invocation.method(
          #getTxs,
          [txHash],
        ),
        returnValue: _i7.Future<_i4.TxResponse>.value(_FakeTxResponse_2(
          this,
          Invocation.method(
            #getTxs,
            [txHash],
          ),
        )),
      ) as _i7.Future<_i4.TxResponse>);
  @override
  _i7.Future<_i10.Cookbook?> getCookbookById(String? cookbookID) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCookbookById,
          [cookbookID],
        ),
        returnValue: _i7.Future<_i10.Cookbook?>.value(),
      ) as _i7.Future<_i10.Cookbook?>);
  @override
  _i7.Future<List<_i10.Cookbook>> getCookbooksByCreator(String? creator) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCookbooksByCreator,
          [creator],
        ),
        returnValue: _i7.Future<List<_i10.Cookbook>>.value(<_i10.Cookbook>[]),
      ) as _i7.Future<List<_i10.Cookbook>>);
  @override
  _i7.Future<_i10.Trade?> getTradeByID(_i11.Int64? ID) => (super.noSuchMethod(
        Invocation.method(
          #getTradeByID,
          [ID],
        ),
        returnValue: _i7.Future<_i10.Trade?>.value(),
      ) as _i7.Future<_i10.Trade?>);
  @override
  _i7.Future<List<_i10.Trade>> getTrades(Address? creator) =>
      (super.noSuchMethod(
        Invocation.method(
          #getTrades,
          [creator],
        ),
        returnValue: _i7.Future<List<_i10.Trade>>.value(<_i10.Trade>[]),
      ) as _i7.Future<List<_i10.Trade>>);
  @override
  _i7.Future<_i2.Either<_i8.Failure, _i10.Recipe>> getRecipe(
    String? cookbookID,
    String? recipeID,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getRecipe,
          [
            cookbookID,
            recipeID,
          ],
        ),
        returnValue: _i7.Future<_i2.Either<_i8.Failure, _i10.Recipe>>.value(
            _FakeEither_0<_i8.Failure, _i10.Recipe>(
          this,
          Invocation.method(
            #getRecipe,
            [
              cookbookID,
              recipeID,
            ],
          ),
        )),
      ) as _i7.Future<_i2.Either<_i8.Failure, _i10.Recipe>>);
  @override
  _i7.Future<_i10.Item?> getItem(
    String? cookbookID,
    String? itemID,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getItem,
          [
            cookbookID,
            itemID,
          ],
        ),
        returnValue: _i7.Future<_i10.Item?>.value(),
      ) as _i7.Future<_i10.Item?>);
  @override
  _i7.Future<List<_i10.Item>> getItemsByOwner(Address? owner) =>
      (super.noSuchMethod(
        Invocation.method(
          #getItemsByOwner,
          [owner],
        ),
        returnValue: _i7.Future<List<_i10.Item>>.value(<_i10.Item>[]),
      ) as _i7.Future<List<_i10.Item>>);
  @override
  _i7.Future<String> getAccountNameByAddress(String? address) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAccountNameByAddress,
          [address],
        ),
        returnValue: _i7.Future<String>.value(''),
      ) as _i7.Future<String>);
  @override
  _i7.Future<String> getAccountAddressByName(String? username) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAccountAddressByName,
          [username],
        ),
        returnValue: _i7.Future<String>.value(''),
      ) as _i7.Future<String>);
  @override
  _i7.Future<List<_i10.Execution>> getRecipeExecutions(
    String? cookbookID,
    String? recipeID,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getRecipeExecutions,
          [
            cookbookID,
            recipeID,
          ],
        ),
        returnValue: _i7.Future<List<_i10.Execution>>.value(<_i10.Execution>[]),
      ) as _i7.Future<List<_i10.Execution>>);
  @override
  _i7.Future<_i2.Either<_i8.Failure, int>> getFaucetCoin(
          {String? denom = r''}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFaucetCoin,
          [],
          {#denom: denom},
        ),
        returnValue: _i7.Future<_i2.Either<_i8.Failure, int>>.value(
            _FakeEither_0<_i8.Failure, int>(
          this,
          Invocation.method(
            #getFaucetCoin,
            [],
            {#denom: denom},
          ),
        )),
      ) as _i7.Future<_i2.Either<_i8.Failure, int>>);
  @override
  _i7.Future<bool> isAccountExists(String? username) => (super.noSuchMethod(
        Invocation.method(
          #isAccountExists,
          [username],
        ),
        returnValue: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> updateRecipe(
          Map<dynamic, dynamic>? jsonMap) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateRecipe,
          [jsonMap],
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #updateRecipe,
            [jsonMap],
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<
      _i2.Either<_i8.Failure, _i9.AccountPublicInfo>> importPylonsAccount(
          {required String? mnemonic}) =>
      (super.noSuchMethod(
        Invocation.method(
          #importPylonsAccount,
          [],
          {#mnemonic: mnemonic},
        ),
        returnValue:
            _i7.Future<_i2.Either<_i8.Failure, _i9.AccountPublicInfo>>.value(
                _FakeEither_0<_i8.Failure, _i9.AccountPublicInfo>(
          this,
          Invocation.method(
            #importPylonsAccount,
            [],
            {#mnemonic: mnemonic},
          ),
        )),
      ) as _i7.Future<_i2.Either<_i8.Failure, _i9.AccountPublicInfo>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> updateCookbook(
          Map<dynamic, dynamic>? jsonMap) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateCookbook,
          [jsonMap],
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #updateCookbook,
            [jsonMap],
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> getProfile() => (super.noSuchMethod(
        Invocation.method(
          #getProfile,
          [],
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #getProfile,
            [],
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<String> signPureMessage(String? message) => (super.noSuchMethod(
        Invocation.method(
          #signPureMessage,
          [message],
        ),
        returnValue: _i7.Future<String>.value(''),
      ) as _i7.Future<String>);
  @override
  _i7.Future<List<_i10.Recipe>> getRecipesByCookbookID(String? cookbookID) =>
      (super.noSuchMethod(
        Invocation.method(
          #getRecipesByCookbookID,
          [cookbookID],
        ),
        returnValue: _i7.Future<List<_i10.Recipe>>.value(<_i10.Recipe>[]),
      ) as _i7.Future<List<_i10.Recipe>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> getAllRecipesByCookbookId(
          {required String? cookbookId}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAllRecipesByCookbookId,
          [],
          {#cookbookId: cookbookId},
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #getAllRecipesByCookbookId,
            [],
            {#cookbookId: cookbookId},
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> getCookbookByIdForSDK(
          {required String? cookbookId}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCookbookByIdForSDK,
          [],
          {#cookbookId: cookbookId},
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #getCookbookByIdForSDK,
            [],
            {#cookbookId: cookbookId},
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i5.Observable<bool> getStateUpdatedFlag() => (super.noSuchMethod(
        Invocation.method(
          #getStateUpdatedFlag,
          [],
        ),
        returnValue: _FakeObservable_3<bool>(
          this,
          Invocation.method(
            #getStateUpdatedFlag,
            [],
          ),
        ),
      ) as _i5.Observable<bool>);
  @override
  void setStateUpdatedFlag({required bool? flag}) => super.noSuchMethod(
        Invocation.method(
          #setStateUpdatedFlag,
          [],
          {#flag: flag},
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> getExecutionByRecipeId({
    required String? cookbookId,
    required String? recipeId,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getExecutionByRecipeId,
          [],
          {
            #cookbookId: cookbookId,
            #recipeId: recipeId,
          },
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #getExecutionByRecipeId,
            [],
            {
              #cookbookId: cookbookId,
              #recipeId: recipeId,
            },
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> getRecipeByIdForSDK({
    required String? cookbookId,
    required String? recipeId,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getRecipeByIdForSDK,
          [],
          {
            #cookbookId: cookbookId,
            #recipeId: recipeId,
          },
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #getRecipeByIdForSDK,
            [],
            {
              #cookbookId: cookbookId,
              #recipeId: recipeId,
            },
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> getItemByIdForSDK({
    required String? cookBookId,
    required String? itemId,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getItemByIdForSDK,
          [],
          {
            #cookBookId: cookBookId,
            #itemId: itemId,
          },
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #getItemByIdForSDK,
            [],
            {
              #cookBookId: cookBookId,
              #itemId: itemId,
            },
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> getItemListByOwner(
          {required Address? owner}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getItemListByOwner,
          [],
          {#owner: owner},
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #getItemListByOwner,
            [],
            {#owner: owner},
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> getExecutionBasedOnId(
          {required String? id}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getExecutionBasedOnId,
          [],
          {#id: id},
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #getExecutionBasedOnId,
            [],
            {#id: id},
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<_i3.SdkIpcResponse<dynamic>> getTradesForSDK(
          {required Address? creator}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getTradesForSDK,
          [],
          {#creator: creator},
        ),
        returnValue: _i7.Future<_i3.SdkIpcResponse<dynamic>>.value(
            _FakeSdkIpcResponse_1<dynamic>(
          this,
          Invocation.method(
            #getTradesForSDK,
            [],
            {#creator: creator},
          ),
        )),
      ) as _i7.Future<_i3.SdkIpcResponse<dynamic>>);
  @override
  _i7.Future<bool> deleteAccounts() => (super.noSuchMethod(
        Invocation.method(
          #deleteAccounts,
          [],
        ),
        returnValue: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  _i7.Future<_i2.Either<_i8.Failure, String>>
      sendGoogleInAppPurchaseCoinsRequest(
              _i12.GoogleInAppPurchaseModel? googleInAppPurchaseModel) =>
          (super.noSuchMethod(
            Invocation.method(
              #sendGoogleInAppPurchaseCoinsRequest,
              [googleInAppPurchaseModel],
            ),
            returnValue: _i7.Future<_i2.Either<_i8.Failure, String>>.value(
                _FakeEither_0<_i8.Failure, String>(
              this,
              Invocation.method(
                #sendGoogleInAppPurchaseCoinsRequest,
                [googleInAppPurchaseModel],
              ),
            )),
          ) as _i7.Future<_i2.Either<_i8.Failure, String>>);
  @override
  _i7.Future<_i2.Either<_i8.Failure, String>>
      sendAppleInAppPurchaseCoinsRequest(
              _i12.AppleInAppPurchaseModel? appleInAppPurchaseModel) =>
          (super.noSuchMethod(
            Invocation.method(
              #sendAppleInAppPurchaseCoinsRequest,
              [appleInAppPurchaseModel],
            ),
            returnValue: _i7.Future<_i2.Either<_i8.Failure, String>>.value(
                _FakeEither_0<_i8.Failure, String>(
              this,
              Invocation.method(
                #sendAppleInAppPurchaseCoinsRequest,
                [appleInAppPurchaseModel],
              ),
            )),
          ) as _i7.Future<_i2.Either<_i8.Failure, String>>);
}
