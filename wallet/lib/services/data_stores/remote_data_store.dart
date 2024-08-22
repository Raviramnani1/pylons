import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:alan/proto/cosmos/bank/v1beta1/export.dart' as bank;
import 'package:cosmos_utils/cosmos_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:protobuf/protobuf.dart';
import 'package:pylons_wallet/ipc/handler/handler_factory.dart';
import 'package:pylons_wallet/model/amount.dart';
import 'package:pylons_wallet/model/balance.dart';
import 'package:pylons_wallet/model/event.dart';
import 'package:pylons_wallet/model/execution_list_by_recipe_response.dart';
import 'package:pylons_wallet/model/export.dart';
import 'package:pylons_wallet/model/nft.dart';
import 'package:pylons_wallet/model/nft_ownership_history.dart';
import 'package:pylons_wallet/model/notification_message.dart';
import 'package:pylons_wallet/model/pylon_items.dart';
import 'package:pylons_wallet/model/stripe_get_login_based_address.dart';
import 'package:pylons_wallet/model/transaction.dart';
import 'package:pylons_wallet/model/wallet_creation_model.dart';
import 'package:pylons_wallet/modules/Pylonstech.pylons.pylons/module/export.dart' as pylons;
import 'package:pylons_wallet/modules/cosmos.tx.v1beta1/module/export.dart' as cosmos_tx;
import 'package:pylons_wallet/pages/detailed_asset_view/widgets/create_trade_bottom_sheet.dart';
import 'package:pylons_wallet/pages/home/currency_screen/model/ibc_coins.dart';
import 'package:pylons_wallet/pages/home/currency_screen/model/ibc_trace_model.dart';
import 'package:pylons_wallet/services/third_party_services/analytics_helper.dart';
import 'package:pylons_wallet/services/third_party_services/firestore_helper.dart';
import 'package:pylons_wallet/services/third_party_services/store_payment_service.dart';
import 'package:pylons_wallet/stores/models/transaction_response.dart';
import 'package:pylons_wallet/utils/base_env.dart';
import 'package:pylons_wallet/utils/constants.dart';
import 'package:pylons_wallet/utils/custom_transaction_signing_gateaway/custom_transaction_signing_gateway.dart';
import 'package:pylons_wallet/utils/dependency_injection/dependency_injection.dart';
import 'package:pylons_wallet/utils/enums.dart';
import 'package:pylons_wallet/utils/extension.dart';
import 'package:pylons_wallet/utils/failure/failure.dart';
import 'package:retry/retry.dart';
import 'package:transaction_signing_gateway/model/account_lookup_key.dart';
import 'package:transaction_signing_gateway/transaction_signing_gateway.dart';

import '../../generated/locale_keys.g.dart';
import '../../model/common.dart';
import '../../model/update_recipe_model.dart';
import '../../modules/Pylonstech.pylons.pylons/module/client/pylons/tx.pb.dart';
import '../../utils/types.dart';
import 'package:pylons_wallet/utils/constants.dart' as constants;

abstract class RemoteDataStore {
  /// This method is used to generate the stripe registration token
  /// Input: [Address] the address of the account
  /// Output : [StripeGenerateRegistrationTokenResponse] contains token of the account
  /// else will through error
  Future<StripeGenerateRegistrationTokenResponse> generateStripeRegistrationToken({required String address});

  /// This method is used to generate the stripe registration token
  /// Input: [Address] the address of the account
  /// Output : [StripeGenerateUpdateTokenResponse] contains token of the account
  /// else will through error
  Future<StripeGenerateUpdateTokenResponse> generateUpdateToken({required String address});

  /// This method is used to update the user stripe account
  /// Input: [StripeUpdateAccountRequest] the request parameters that are required for the update
  /// Output : [StripeUpdateAccountResponse] contains token of the account
  /// else will through error
  Future<StripeUpdateAccountResponse> updateStripeAccount({required StripeUpdateAccountRequest req});

  /// This method is used to get the account link and account id based on update token
  /// Input: [StripeUpdateAccountRequest] the request parameters that are required for the update
  /// Output : [StripeUpdateAccountResponse] contains account id and account link  of the user stripe account
  /// else will through error
  Future<StripeUpdateAccountResponse> getAccountLinkBasedOnUpdateToken({required StripeUpdateAccountRequest req});

  /// This method is used to get the account link and account id based on update token
  /// Input: [StripeUpdateAccountRequest] the request parameters that are required for the update
  /// Output : [StripeUpdateAccountResponse] contains account id and account link  of the user stripe account
  /// else will through error
  Future<StripeRegisterAccountResponse> registerAccount({required StripeRegisterAccountRequest req});

  /// This method is used to get the account link or onboarding link if the account is not set up but user exists in system
  /// Input: [StripeGetLoginBasedOnAddressRequest] the request parameters that are required for the login link
  /// Output : [StripeGetLoginBasedOnAddressResponse] contains the response for the login link
  /// else will through error
  Future<StripeGetLoginBasedOnAddressResponse> getLoginLinkBasedOnAddress({required StripeGetLoginBasedOnAddressRequest req});

  /// This method will return the ibc coin info
  /// Input: [ibcHash] hash of the ibc coin
  /// Output: [IBCTraceModel] contains info regarding the ibc trace
  Future<IBCTraceModel> getIBCHashTrace({required String ibcHash});

  /// This method will return whether the user account exists or not
  /// Input: [address] the address of the user
  /// Output: [bool] tells whether the stripe account exists or not
  Future<bool> doesStripeAccountExists({required String address});

  /// This method returns the user balance based on the address
  /// Input : [walletAddress]  is the address of the wallet
  /// Output: [List][Balance] the balance of the user
  Future<List<Balance>> getBalance(String walletAddress);

  /// This method will return the transaction history against user address
  /// Input: [address] the address of the user
  /// Output: returns [List][TransactionHistory] if success
  /// else will through error
  Future<List<TransactionHistory>> getTransactionHistory({required String address});

  /// This method will return list of notification messages
  /// Input: [walletAddress] of the user ,[limit] the maximum number of records to show at a time
  /// and [offset] is the last item's position
  /// Output: if successful will return [List][NotificationMessage] the list of the NotificationMessage
  /// else will throw error
  Future<List<NotificationMessage>> getAllNotificationMessages({required String walletAddress, required int limit, required int offset});

  /// This method will update the recipe in the chain
  /// Input: [updateRecipeModel] contains the info regarding the recipe update
  /// Output: if successful will return [String] the hash of the transaction
  /// else will through error
  Future<String> updateRecipe({required UpdateRecipeModel updateRecipeModel});

  /// This method is used to get likes count of NFT
  /// Input: [recipeId],[cookBookID] and [walletAddress] of the given NFT
  /// Output : [int] will contain the likes count of the NFT
  Future<int> getLikesCount({required RecipeId recipeId, required CookbookId cookBookID});

  /// This method is used to get history of nft owners
  /// Input: [itemId] and [cookBookID] of the NFT
  /// Output : [List][NftOwnershipHistory] will contain the list of NftOwnershipHistory data if success
  /// else will throw error
  Future<List<NftOwnershipHistory>> getNftOwnershipHistory({required String itemId, required String cookBookId});

  /// This method is used to get history of nft owners
  /// Input: [cookBookId] and [recipeId] of the NFT
  /// Output : [List][NftOwnershipHistory] will contain the list of NftOwnershipHistory data if success
  /// else will throw error
  Future<List<NftOwnershipHistory>> getNftOwnershipHistoryByCookbookIdAndRecipeId({
    required CookbookId cookBookId,
    required RecipeId recipeId,
  });

  /// This method is used to get views count of NFT
  /// Input: [recipeId],[cookBookID] and [walletAddress] of the given NFT
  /// Output : [int] will contain the views count of the NFT
  Future<int> getViewsCount({required RecipeId recipeId, required CookbookId cookBookID});

  /// This method is used to increment a view for an NFT when a user view an NFT
  /// Input: [recipeId],[cookBookID] and [walletAddress] of the given NFT
  Future<void> countAView({
    required RecipeId recipeId,
    required CookbookId cookBookID,
    required Address walletAddress,
  });

  /// This method is used get the like status of the NFT ; if it is Liked by me or not
  /// Input: [recipeId],[cookBookID] and [walletAddress] of the given NFT
  /// Output : [bool] will be the status for NFT if it is Liked or not
  Future<bool> ifLikedByMe({
    required RecipeId recipeId,
    required CookbookId cookBookID,
    required Address walletAddress,
  });

  /// This method is used to update the like status of an NFT; it will toggle the like button
  /// Input: [recipeId],[cookBookID] and [walletAddress] of the given NFT
  Future<void> updateLikeStatus({
    required RecipeId recipeId,
    required CookbookId cookBookID,
    required Address walletAddress,
  });

  /// This method is used get the recipe object based on CookbookId and RecipeId
  /// Input: [recipeId] and [cookBookId] of the given Recipe
  /// Output : [pylons.Recipe] will be the recipe object based on CookbookId and RecipeId
  Future<pylons.Recipe> getRecipe({required CookbookId cookBookId, required RecipeId recipeId});

  /// This method is used get the username based on the wallet address
  /// Input: [address] wll be the public address of the user's wallet
  /// Output : [String] will be the username as per the provided wallet address
  Future<String> getUsername({required Address address});

  /// This method is used get the list of recipes object based on [cookBookId]
  /// Input: [cookBookId] of the given Recipe
  /// Output : [pylons.Recipe] will be the list of recipes object based on CookbookId
  Future<List<pylons.Recipe>> getRecipesBasedOnCookBookId({required String cookBookId});

  /// This method is used get the cookbook object based on [cookBookId]
  /// Input: [cookBookId] of the given Cookbook
  /// Output : [pylons.Cookbook] will be the cookbook object based on CookbookId
  Future<pylons.Cookbook> getCookbookBasedOnId({required String cookBookId});

  /// This method is used get the wallet address based on the username
  /// Input: [username] wll be the username
  /// Output : [String] will be the public wallet's address based on the given username
  Future<String> getAddressBasedOnUsername(String username);

  /// This method is used get the list of executions based on [cookBookId] and [recipeId]
  /// Input: [cookBookId] and [recipeId] of the given Recipe
  /// Output : [ExecutionListByRecipeResponse] will be the list of recipes executions
  Future<ExecutionListByRecipeResponse> getExecutionsByRecipeId({required String cookBookId, required String recipeId});

  /// This method is used get the item based on [cookBookId] and [itemId]
  /// Input: [cookBookId] and [itemId] of the given Recipe
  /// Output : [pylons.Item] will be the item object
  Future<pylons.Item> getItem({required String cookBookId, required String itemId});

  /// This method is used get the list if items based on [owner]
  /// Input: [owner] will be the owner name to get the list of his items
  /// Output : [pylons.Item] will be the list of items based on their owner
  Future<List<pylons.Item>> getListItemByOwner({required Address owner});

  /// This method is used get the execution based on its [id]
  /// Input: [id] will be the execution id
  /// Output : [pylons.Execution] will be the execution based on [id]
  Future<pylons.Execution> getExecutionBasedOnId({required String id});

  /// This method is used get the list of trades based on its [creator]
  /// Input: [creator] will be the creator name to get trades
  /// Output : [pylons.Trade] will be the the list of trades based on its [creator]
  Future<List<pylons.Trade>> getTradesBasedOnCreator({required Address creator});

  /// This method is used get the list of cookbooks based on its wallet [address]
  /// Input: [address] will the public address of user's wallet
  /// Output : [pylons.Trade] will be the the list of trades based on its [creator]
  Future<List<pylons.Cookbook>> getCookbooksByCreator({required String address});

  /// This method is used get the trade based on its [id]
  /// Input: [id] will the the trade id to get complete trade
  /// Output : [pylons.Trade] will be the trade based on its [id]
  Future<pylons.Trade> getTradeByID({required Int64 id});

  Future<String> sendGoogleInAppPurchaseCoinsRequest(GoogleInAppPurchaseModel googleInAppPurchaseModel);

  /// This method will send apple in app purchase request to the chain
  /// Input: [AppleInAppPurchaseModel] contains the input data for the api.
  /// Output: if successful will return the [String] hash of the transaction
  /// else will throw the error
  Future<String> sendAppleInAppPurchaseCoinsRequest(AppleInAppPurchaseModel googleInAppPurchaseModel);

  /// This method will get the products For Sale from the underling store
  /// Input: [itemId] the id of the item
  /// Output: if successful will return [ProductDetails] the details of the product else will throw error
  Future<ProductDetails> getProductsForSale({required String itemId});

  /// This method will buy the product based on its detail
  /// Input: [productDetails] the details of item to bought
  /// Output: if successful will return [bool] tells whether the operation initiated the dialog or not
  /// else will throw error
  Future<bool> buyProduct(ProductDetails productDetails);

  /// This method will initializes the in app purchase
  /// Output: if successful will return [bool] tells whether device support in app purchase or not
  /// else will throw error
  Future<bool> isInAppPurchaseAvailable();

  /// This method will get the firebase app check token
  /// Output: [String] returns app check token if successful else will throw error
  Future<String> getAppCheckToken();

  /// This method will update fcm token against an address.
  /// Input: [address] the address whose fcm needs to be updated, [fcmToken] the user fcm token , [appCheckToken] the firebase app check token
  /// Output: [bool] returns true if successful else will throw error.
  Future<bool> updateFcmToken({required String address, required String fcmToken, required String appCheckToken});

  /// This method will mark notification as read.
  /// Input: [List][id] the list containing ids of notifications which needed to be mark as read, [appCheckToken] the firebase app check token
  /// Output: [bool] returns true if successful else will throw error.
  Future<bool> markNotificationAsRead({required List<String> idsList, required String appCheckToken});

  /// This method will create dynamic link for the user invite
  /// Input : [address] the address against which the invite link to be generated
  /// Output: [String] return the generated dynamic link else will throw error
  Future<String> createDynamicLinkForUserInvite({required String address});

  /// This method will create dynamic link for the nft share recipe
  /// Input : [address] the address & [NFT] against which the invite link to be generated
  /// Output: [String] return the generated dynamic link else will throw error
  Future<String> createDynamicLinkForRecipeNftShare({required String address, required NFT nft});

  /// This method will create dynamic link for the nft share trade
  /// Input : [address] the address & [tradeId] against which the invite link to be generated
  /// Output: [String] return the generated dynamic link else will throw error
  Future<String> createDynamicLinkForTradeNftShare({required String address, required String tradeId});

  /// This method will create dynamic link for the nft share purchase
  /// Input : [address] the address & [itemId] the id of the item& [cookbookId] against which the invite link to be generated
  /// Output: [String] return the generated dynamic link else will throw error
  Future<String> createDynamicLinkForItemNftShare({required String address, required String itemId, required String cookbookId});

  /// This method will create User account based on account public info
  /// Input: [publicInfo] contains info related to user chain address, [walletCreationModel] contains user entered data, [appCheckToken] the app specific token, [referralToken] the invitee user address
  /// Output: if successful will give [TransactionResponse] else will throw error
  Future<TransactionResponse> createAccount({
    required AccountPublicInfo publicInfo,
    required WalletCreationModel walletCreationModel,
    required String appCheckToken,
    required String referralToken,
  });

  /// This method will save users feedback to firebase based on its wallet address
  /// Input : [walletAddress], [subject] and [feedback] the address against which the feedbacks needs to be stored
  /// Output : [bool] It will return true if the saving feedback is successful otherwise false
  Future<bool> saveUserFeedback({required String walletAddress, required String subject, required String feedback});

  /// This method will set the app level user identifier in the analytics
  /// Input: [address] the address of the user
  /// Output: [bool] return true if successful
  Future<bool> setUpUserIdentifierInAnalytics({required String address});

  /// This method will log the purchase item in the analytics
  /// Input: [recipeId] the id of the NFT, [author] the author of the NFT, [purchasePrice] the price of the NFT, [recipeName] the name of the recipe
  /// Output: [bool] return true if successful
  Future<bool> logPurchaseItem({
    required RecipeId recipeId,
    required String recipeName,
    required String author,
    required double purchasePrice,
  });

  /// Get a tuple of the native Cosmos TX struct and (if it exists) the TxResponse struct.
  /// Input: [hash] hash of the transaction to query.
  /// Output: [Tuple2] of the [cosmos_tx.Tx] and (if it exists) the [cosmos_tx.TxResponse].
  Future<Tuple2<cosmos_tx.Tx, cosmos_tx.TxResponse?>> getTx({required String hash});

  Future<bool> logAddToCart({
    required RecipeId recipeId,
    required String recipeName,
    required String author,
    required double purchasePrice,
    required String currency,
  });

  Future<void> logUserJourney({required String screenName});

  Future<TransactionResponse> setUserName({
    required String username,
    required String address,
    required AccountPublicInfo publicInfo,
  });

  Future<String> enableDisableRecipe({
    required CookbookId cookBookId,
    required RecipeId recipeId,
    required bool enabled,
    required Address creatorAddress,
  });

  Future<TransactionResponse> cancelTrade({required TradeId tradeId, required Address address});

  Future<TransactionResponse> createTrade({required pylons.MsgCreateTrade msgCreateTrade});

  Future<List<PylonItems>> getPylonItem({required Address address});

  /// This method will create dynamic link for the event share recipe
  /// Input : [address] the address & [Event] against which the invite link to be generated
  /// Output: [String] return the generated dynamic link else will throw error
  Future<String> createDynamicLinkForRecipeEventShare({required String address, required Events events});
}

class RemoteDataStoreImp implements RemoteDataStore {
  final timeOutDuration = const Duration(seconds: 10);

  RemoteDataStoreImp({
    required this.dynamicLinksGenerator,
    required this.httpClient,
    required this.firebaseHelper,
    required this.analyticsHelper,
    required this.storePaymentService,
    required this.firebaseAppCheck,
    required this.onLogError,
  });

  @override
  Future<void> updateLikeStatus({
    required RecipeId recipeId,
    required CookbookId cookBookID,
    required Address walletAddress,
  }) async {
    final baseApiUrl = getBaseEnv().baseMongoUrl;
    final body = {userIdKey: walletAddress};

    final uri = Uri.parse("$baseApiUrl/api/actions/likes/$cookBookID/$recipeId");

    final response = await httpClient.post(uri, body: body).timeout(
          timeOutDuration,
        );

    if (response.statusCode == API_SUCCESS_CODE) {
      final recipeMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (recipeMap[kDataKey] == null) {
        throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
      }
      return;
    }

    if (response.statusCode == API_ERROR_CODE) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
  }

  @override
  Future<int> getLikesCount({required RecipeId recipeId, required CookbookId cookBookID}) async {
    final baseApiUrl = GetIt.I.get<BaseEnv>().baseMongoUrl;

    final uri = Uri.parse("$baseApiUrl/api/actions/likes/$cookBookID/$recipeId");

    log("$baseApiUrl/api/actions/likes/$cookBookID/$recipeId");

    final response = await httpClient.get(uri).timeout(
          timeOutDuration,
        );

    if (response.statusCode == API_SUCCESS_CODE) {
      final recipeMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (recipeMap[kDataKey] == null) {
        throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
      }

      final totalLikes = recipeMap[kDataKey][kTotalLikesKey] as int;

      return totalLikes;
    }

    if (response.statusCode == API_ERROR_CODE) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
    return 0;
  }

  @override
  Future<void> countAView({
    required RecipeId recipeId,
    required CookbookId cookBookID,
    required Address walletAddress,
  }) async {
    final baseApiUrl = GetIt.I.get<BaseEnv>().baseMongoUrl;

    final body = {userIdKey: walletAddress.toString()};

    final uri = Uri.parse("$baseApiUrl/api/actions/views/$cookBookID/$recipeId");

    final response = await httpClient.post(uri, body: body).timeout(
          timeOutDuration,
        );

    if (response.statusCode == API_SUCCESS_CODE) {
      final recipeMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (recipeMap[kDataKey] == null) {
        throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
      }
      return;
    }

    if (response.statusCode == API_ERROR_CODE) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
  }

  @override
  Future<int> getViewsCount({required RecipeId recipeId, required CookbookId cookBookID}) async {
    final baseApiUrl = GetIt.I.get<BaseEnv>().baseMongoUrl;

    final uri = Uri.parse("$baseApiUrl/api/actions/views/$cookBookID/$recipeId");

    final response = await httpClient.get(uri).timeout(
          timeOutDuration,
        );

    if (response.statusCode == API_SUCCESS_CODE) {
      final recipeMap = jsonDecode(response.body) as Map<String, dynamic>;
      if (recipeMap[kDataKey] == null) {
        throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
      }

      final totalViews = recipeMap[kDataKey][kTotalViewsKey] as int;

      return totalViews;
    }

    if (response.statusCode == API_ERROR_CODE) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }

    return 0;
  }

  @override
  Future<bool> ifLikedByMe({
    required RecipeId recipeId,
    required CookbookId cookBookID,
    required Address walletAddress,
  }) async {
    final baseApiUrl = GetIt.I.get<BaseEnv>().baseMongoUrl;

    final uri = Uri.parse("$baseApiUrl/api/actions/likes/$walletAddress/$cookBookID/$recipeId");

    final response = await httpClient.get(uri).timeout(
          timeOutDuration,
        );

    if (response.statusCode == API_SUCCESS_CODE) {
      final recipeMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (recipeMap[kDataKey] == null) {
        throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
      }

      final ifLikedByMe = recipeMap[kDataKey][kLikedKey] as bool;

      return ifLikedByMe;
    }

    if (response.statusCode == API_ERROR_CODE) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
    return false;
  }

  @override
  Future<StripeGenerateRegistrationTokenResponse> generateStripeRegistrationToken({required String address}) async {
    final baseEnv = getBaseEnv();
    final response = await httpClient.get(Uri.parse("${baseEnv.baseStripeUrl}/generate-registration-token?address=$address")).timeout(
          timeOutDuration,
        );

    log(response.body, name: "Stripe | generateStripeRegistrationToken");

    if (response.statusCode == API_SUCCESS_CODE) {
      return StripeGenerateRegistrationTokenResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    }

    if (response.statusCode == API_ERROR_CODE && response.body == 'account already exists\n') {
      throw const AccountAlreadyExistsFailure('Account Already exists');
    }

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<StripeGenerateUpdateTokenResponse> generateUpdateToken({required String address}) async {
    final baseEnv = getBaseEnv();
    final response = await httpClient
        .get(
          Uri.parse("${baseEnv.baseStripeUrl}/generate-update-token?address=$address"),
        )
        .timeout(timeOutDuration);

    if (response.statusCode == API_SUCCESS_CODE) {
      return StripeGenerateUpdateTokenResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    }

    log(response.body, name: "Stripe | generateUpdateToken");

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<StripeUpdateAccountResponse> updateStripeAccount({required StripeUpdateAccountRequest req}) async {
    final baseEnv = getBaseEnv();
    final response = await httpClient
        .post(
            Uri.parse(
              "${baseEnv.baseStripeUrl}/update-account",
            ),
            body: jsonEncode(req.toJson()))
        .timeout(
          timeOutDuration,
        );

    if (response.statusCode == API_SUCCESS_CODE) {
      return StripeUpdateAccountResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    }

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<StripeUpdateAccountResponse> getAccountLinkBasedOnUpdateToken({required StripeUpdateAccountRequest req}) async {
    final baseEnv = getBaseEnv();
    final response = await httpClient
        .post(
            Uri.parse(
              "${baseEnv.baseStripeUrl}/newLink",
            ),
            body: jsonEncode(req.toJson()))
        .timeout(
          timeOutDuration,
        );

    log(response.body, name: "Stripe | getAccountLinkBasedOnUpdateToken");

    if (response.statusCode == API_SUCCESS_CODE) {
      return StripeUpdateAccountResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    }

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<IBCTraceModel> getIBCHashTrace({required String ibcHash}) async {
    final baseEnv = getBaseEnv();
    final response = await httpClient
        .get(Uri.parse(
          "${baseEnv.denomTraceUrl}/ibc/apps/transfer/v1/denom_traces/$ibcHash",
        ))
        .timeout(timeOutDuration);

    if (response.statusCode == API_SUCCESS_CODE) {
      return IBCTraceModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>, ibcHash);
    }

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<StripeGetLoginBasedOnAddressResponse> getLoginLinkBasedOnAddress({required StripeGetLoginBasedOnAddressRequest req}) async {
    final baseEnv = getBaseEnv();
    final response = await httpClient
        .post(
            Uri.parse(
              "${baseEnv.baseStripeUrl}/address-based-link",
            ),
            body: jsonEncode(req))
        .timeout(timeOutDuration);

    log(response.body, name: "Stripe | getLoginLinkBasedOnAddress");
    if (response.statusCode == API_SUCCESS_CODE) {
      return StripeGetLoginBasedOnAddressResponse.from(json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    }

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<StripeRegisterAccountResponse> registerAccount({required StripeRegisterAccountRequest req}) async {
    final baseEnv = getBaseEnv();
    final response = await httpClient
        .post(
            Uri.parse(
              "${baseEnv.baseStripeUrl}/register-account",
            ),
            body: jsonEncode(req.toJson()))
        .timeout(timeOutDuration);

    log(response.body, name: "Stripe | registerAccount");
    if (response.statusCode == API_SUCCESS_CODE) {
      return StripeRegisterAccountResponse.from(json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    }

    if (response.statusCode == API_ERROR_CODE && response.body == 'account already setup\n') {
      throw const AccountAlreadyExistsFailure('Account Already exists');
    }

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<bool> doesStripeAccountExists({required String address}) async {
    final baseEnv = getBaseEnv();
    final response = await httpClient
        .get(Uri.parse(
          "${baseEnv.baseStripeUrl}/accountExists?address=$address",
        ))
        .timeout(timeOutDuration);

    log(response.body, name: "Stripe | doesStripeAccountExists");
    if (response.statusCode == API_SUCCESS_CODE) {
      return jsonDecode(response.body)['accountExists'] as bool;
    }

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<List<Balance>> getBalance(String walletAddress) async {
    final bank.QueryClient bankQueryClient = getBankQueryClient();

    final queryAllBalancesRequest = bank.QueryAllBalancesRequest.create()..address = walletAddress;

    final response = await bankQueryClient.allBalances(queryAllBalancesRequest);

    final balances = <Balance>[];
    if (response.balances.isEmpty || response.balances.indexWhere((element) => element.denom == 'upylon') == -1) {
      balances.add(Balance(denom: "upylon", amount: Amount(Decimal.zero)));
    }

    if (response.balances.indexWhere((element) => element.denom == 'ustripeusd') == -1) {
      balances.add(Balance(denom: "ustripeusd", amount: Amount(Decimal.zero)));
    }

    final futureIBCHashList = <Future<IBCTraceModel>>[];

    for (final balance in response.balances) {
      if (balance.denom.contains("ibc")) {
        futureIBCHashList.add(getIBCHashTrace(ibcHash: balance.denom.replaceAll("ibc/", '')));
        continue;
      }

      balances.add(Balance(denom: balance.denom, amount: Amount(Decimal.parse(balance.amount))));
    }

    final ibcHashResults = await Future.wait(futureIBCHashList);

    for (final ibcHashResult in ibcHashResults) {
      final relatedBalance = response.balances.firstWhere((element) => element.denom == "ibc/${ibcHashResult.ibcHash}");
      balances.add(Balance(denom: ibcHashResult.denomTrace.baseDenom.name, amount: Amount(Decimal.parse(relatedBalance.amount))));
    }

    return balances;
  }

  @override
  Future<List<TransactionHistory>> getTransactionHistory({required String address}) async {
    final baseEnv = getBaseEnv();
    final transactionList = <TransactionHistory>[];

    final transactionUri = '${baseEnv.baseApiUrl}/pylons/tx?address=%27$address%27';

    final transactionResponse = await httpClient.get(Uri.parse(transactionUri)).timeout(timeOutDuration);

    final transactionMap = jsonDecode(transactionResponse.body);

    if (transactionMap == null || transactionResponse.body.length == 2) return transactionList;
    transactionList.addAll((transactionMap as List<dynamic>)
        .map(
          (e) => TransactionHistory.fromJson(e as Map<String, dynamic>),
        )
        .toList());

    return transactionList;
  }

  @override
  Future<List<NotificationMessage>> getAllNotificationMessages({required String walletAddress, required int limit, required int offset}) async {
    final baseApiUrl = getBaseEnv().baseMongoUrl;

    final uri = Uri.parse("$baseApiUrl/api/notifications/getAllNotifications/$walletAddress/$limit/$offset");

    final notificationResponse = await httpClient.get(uri).timeout(timeOutDuration);

    if (notificationResponse.statusCode != API_SUCCESS_CODE) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
    final List<NotificationMessage> messageList = [];

    final notificationMap = jsonDecode(notificationResponse.body);

    if (notificationMap == null) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
    notificationMap[kDataKey][kResultKey].map((e) {
      final msg = NotificationMessage.fromJson(e as Map<String, dynamic>);
      messageList.add(msg);
    }).toList();

    return messageList;
  }

  @override
  Future<List<NftOwnershipHistory>> getNftOwnershipHistory({required String itemId, required String cookBookId}) async {
    final baseApiUrl = getBaseEnv().baseApiUrl;
    final uri = Uri.parse("$baseApiUrl/pylons/item_history/$cookBookId/$itemId");
    final List<NftOwnershipHistory> historyList = [];

    final historyResponse = await httpClient.get(uri).timeout(timeOutDuration);

    if (historyResponse.statusCode != API_SUCCESS_CODE) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
    final historyMap = jsonDecode(historyResponse.body);

    if (historyMap == null) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
    historyMap[kHistory].map((e) {
      final nft = NftOwnershipHistory.fromJson(e as Map<String, dynamic>);
      historyList.add(nft);
    }).toList();

    final reverseOrder = historyList.reversed.toList();

    return reverseOrder.toList();
  }

  @override
  Future<List<NftOwnershipHistory>> getNftOwnershipHistoryByCookbookIdAndRecipeId({
    required CookbookId cookBookId,
    required RecipeId recipeId,
  }) async {
    final baseApiUrl = getBaseEnv().baseApiUrl;
    // ignore: noop_primitive_operations
    final uri = Uri.parse("$baseApiUrl/pylons/get_recipe_history/${cookBookId.toString()}/${recipeId.toString()}");

    final List<NftOwnershipHistory> historyList = [];

    final historyResponse = await httpClient.get(uri).timeout(timeOutDuration);

    if (historyResponse.statusCode != API_SUCCESS_CODE) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
    final historyMap = jsonDecode(historyResponse.body);

    if (historyMap == null) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }
    historyMap[kHistory].map((e) {
      final nft = NftOwnershipHistory.fromCookBookAndRecipeJson(e as Map<String, dynamic>);
      historyList.add(nft);
    }).toList();

    final reverseOrder = historyList.reversed.toList();
    return reverseOrder.toList();
  }

  Future<String> _signAndBroadcast(GeneratedMessage message) async {
    final unsignedTransaction = UnsignedAlanTransaction(messages: [message]);

    final customTransactionSigningGateway = getCustomTransactionSigningGateway();
    final transactionSigningGateway = getTransactionSigningGateway();

    final walletsResultEither = await customTransactionSigningGateway.getWalletsList();

    if (walletsResultEither.isLeft()) {
      onLogError(walletsResultEither.getLeft().toString(), fatal: true);
      throw const TransactionSigningFailure(
        message: SOMETHING_WRONG_FETCHING_WALLETS,
        type: HandlerFactory.ERR_FETCHING_WALLETS,
      );
    }

    final accountsList = walletsResultEither.getOrElse(() => []);
    if (accountsList.isEmpty) {
      throw TransactionSigningFailure(
        message: LocaleKeys.no_profile_found.tr(),
        type: HandlerFactory.ERR_PROFILE_DOES_NOT_EXIST,
      );
    }
    final info = accountsList.last;
    final walletLookupKey = createWalletLookUp(info);

    final signedTransaction = await transactionSigningGateway.signTransaction(
      transaction: unsignedTransaction,
      accountLookupKey: walletLookupKey,
    );

    if (signedTransaction.isLeft()) {
      onLogError(signedTransaction.getLeft().toString(), fatal: true);
      throw TransactionSigningFailure(
        message: LocaleKeys.something_wrong_signing_transaction.tr(),
        type: HandlerFactory.ERR_SIG_TRANSACTION,
      );
    }

    final response = await customTransactionSigningGateway.broadcastTransaction(
      walletLookupKey: walletLookupKey,
      transaction: signedTransaction.toOption().toNullable()!,
    );

    if (response.isLeft()) {
      onLogError(response.getLeft().toString(), fatal: true);
      throw TransactionSigningFailure(
        message: response.swap().toOption().toNullable().toString(),
        type: HandlerFactory.ERR_SOMETHING_WENT_WRONG,
      );
    }

    return response.getOrElse(() => TransactionResponse.initial()).hash;
  }

  AccountLookupKey createWalletLookUp(AccountPublicInfo info) {
    final walletLookupKey = AccountLookupKey(
      chainId: info.chainId,
      password: '',
      accountId: info.accountId,
    );
    return walletLookupKey;
  }

  @override
  Future<String> updateRecipe({required UpdateRecipeModel updateRecipeModel}) {
    final recipeProto3Json = updateRecipeModel.recipe.toProto3Json()! as Map;
    recipeProto3Json.remove(kCreatedAtCamelCase);
    recipeProto3Json.remove(kUpdatedAtCamelCase);
    final msgUpdateRecipe = pylons.MsgUpdateRecipe.create()..mergeFromProto3Json(recipeProto3Json);
    msgUpdateRecipe.enabled = updateRecipeModel.enabledStatus;
    msgUpdateRecipe.creator = updateRecipeModel.publicAddress;
    msgUpdateRecipe.coinInputs.first.coins.first.amount = updateRecipeModel.nftPrice;
    msgUpdateRecipe.coinInputs.first.coins.first.denom = updateRecipeModel.denom;
    msgUpdateRecipe.version = msgUpdateRecipe.version.incrementRecipeVersion();
    return _signAndBroadcast(msgUpdateRecipe);
  }

  @override
  Future<pylons.Recipe> getRecipe({required CookbookId cookBookId, required RecipeId recipeId}) async {
    try {
      const retry = RetryOptions();
      final response = await retry.retry(
        () async {
          final pylons.QueryClient queryClient = getQueryClient();
          final request = pylons.QueryGetRecipeRequest.create()
            ..cookbookId = cookBookId.toString()
            ..id = recipeId.toString();

          final response = await queryClient.recipe(request);
          return response;
        },
        retryIf: (_) => true,
      );

      if (response.hasRecipe()) {
        return response.recipe;
      }
      throw RecipeNotFoundFailure(LocaleKeys.recipe_not_found.tr());
    } catch (_) {
      throw RecipeNotFoundFailure(LocaleKeys.recipe_not_found.tr());
    }
  }

  @override
  Future<String> getUsername({required Address address}) async {
    final pylons.QueryClient queryClient = getQueryClient();

    final request = pylons.QueryGetUsernameByAddressRequest.create()..address = address.toString();

    final response = await queryClient.usernameByAddress(request);

    if (response.hasUsername()) {
      return response.username.value;
    }
    throw RecipeNotFoundFailure(LocaleKeys.username_not_found.tr());
  }

  @override
  Future<Tuple2<cosmos_tx.Tx, cosmos_tx.TxResponse?>> getTx({required String hash}) async {
    final cosmos_tx.ServiceClient serviceClient = cosmos_tx.ServiceClient(sl.get<BaseEnv>().networkInfo.gRPCChannel);
    final request = cosmos_tx.GetTxRequest.create()..hash = hash;
    final response = await serviceClient.getTx(request);

    if (response.hasTx()) {
      if (response.hasTxResponse()) {
        return Tuple2(response.tx, response.txResponse);
      } else {
        return Tuple2(response.tx, null);
      }
    }

    throw TxNotFoundFailure(LocaleKeys.tx_not_found.tr());
  }

  @override
  Future<List<pylons.Recipe>> getRecipesBasedOnCookBookId({required String cookBookId}) async {
    final pylons.QueryClient queryClient = getQueryClient();
    final request = pylons.QueryListRecipesByCookbookRequest.create()..cookbookId = cookBookId;

    final response = await queryClient.listRecipesByCookbook(request);

    return response.recipes;
  }

  @override
  Future<pylons.Cookbook> getCookbookBasedOnId({required String cookBookId}) async {
    try {
      const retry = RetryOptions();

      final response = await retry.retry(
        () async {
          final pylons.QueryClient queryClient = getQueryClient();
          final request = pylons.QueryGetCookbookRequest.create()..id = cookBookId;

          final response = await queryClient.cookbook(request);
          return response;
        },
        retryIf: (_) => true,
      );

      if (response.hasCookbook()) {
        return response.cookbook;
      }

      throw CookBookNotFoundFailure(LocaleKeys.cookbook_not_found.tr());
    } catch (_) {
      throw CookBookNotFoundFailure(LocaleKeys.cookbook_not_found.tr());
    }
  }

  @override
  Future<String> getAddressBasedOnUsername(String username) async {
    final pylons.QueryClient queryClient = getQueryClient();

    final request = pylons.QueryGetAddressByUsernameRequest.create()..username = username;

    final response = await queryClient.addressByUsername(request);

    if (response.hasAddress()) {
      return response.address.value;
    }

    throw RecipeNotFoundFailure(LocaleKeys.username_not_found.tr());
  }

  @override
  Future<ExecutionListByRecipeResponse> getExecutionsByRecipeId({required String cookBookId, required String recipeId}) async {
    final pylons.QueryClient queryClient = getQueryClient();
    final queryExecutionListByRecipe = pylons.QueryListExecutionsByRecipeRequest()
      ..cookbookId = cookBookId
      ..recipeId = recipeId;
    final response = await queryClient.listExecutionsByRecipe(queryExecutionListByRecipe);

    return ExecutionListByRecipeResponse(completedExecutions: response.completedExecutions, pendingExecutions: response.pendingExecutions);
  }

  @override
  Future<pylons.Item> getItem({required String cookBookId, required String itemId}) async {
    final pylons.QueryClient queryClient = getQueryClient();
    final queryGetItemRequest = pylons.QueryGetItemRequest()
      ..cookbookId = cookBookId
      ..id = itemId;

    final response = await queryClient.item(queryGetItemRequest);

    if (response.hasItem()) {
      return response.item;
    }

    throw ItemNotFoundFailure(LocaleKeys.item_not_found.tr());
  }

  @override
  Future<List<pylons.Item>> getListItemByOwner({required Address owner}) async {
    final pylons.QueryClient queryClient = getQueryClient();
    final queryListItemByOwner = pylons.QueryListItemByOwnerRequest()..owner = owner.toString();

    final response = await queryClient.listItemByOwner(queryListItemByOwner);

    return response.items;
  }

  @override
  Future<pylons.Execution> getExecutionBasedOnId({required String id}) async {
    final pylons.QueryClient queryClient = getQueryClient();
    final queryExecutionById = pylons.QueryGetExecutionRequest()..id = id;

    final response = await queryClient.execution(queryExecutionById);

    if (response.hasExecution()) {
      return response.execution;
    }

    throw ItemNotFoundFailure(LocaleKeys.execution_not_found.tr());
  }

  @override
  Future<bool> updateFcmToken({required String address, required String fcmToken, required String appCheckToken}) async {
    final baseApiUrl = getBaseEnv().baseMongoUrl;

    final uri = Uri.parse("$baseApiUrl/api/fcmtoken/update/$address/$fcmToken");

    final response = await httpClient.post(uri, headers: {
      FIREBASE_APP_CHECK_HEADER: appCheckToken,
    }).timeout(
      timeOutDuration,
    );

    if (response.statusCode == API_SUCCESS_CODE) {
      return true;
    }

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<bool> markNotificationAsRead({required List<String> idsList, required String appCheckToken}) async {
    final baseApiUrl = getBaseEnv().baseMongoUrl;

    final uri = Uri.parse("$baseApiUrl/api/notifications/markread");

    final response = await httpClient.post(uri, headers: {FIREBASE_APP_CHECK_HEADER: appCheckToken, 'Content-type': 'application/json'}, body: jsonEncode({kNotificationsIds: idsList}));

    if (response.statusCode == API_SUCCESS_CODE) {
      final historyMap = jsonDecode(response.body);
      if (historyMap[kMessageKey] == kSuccessKey) {
        return true;
      }
      return false;
    }

    throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
  }

  @override
  Future<List<pylons.Trade>> getTradesBasedOnCreator({required Address creator}) async {
    final pylons.QueryClient queryClient = getQueryClient();
    final request = pylons.QueryListTradesByCreatorRequest.create()..creator = creator.toString();

    final response = await queryClient.listTradesByCreator(request);

    if (response.trades.isNotEmpty) {
      return response.trades;
    }

    throw TradeNotFoundFailure(LocaleKeys.trade_not_found.tr());
  }

  @override
  Future<String> getAppCheckToken() async {
    final String? token = await firebaseAppCheck.getToken();

    if (token == null || token.isEmpty) {
      throw const AppCheckTokenFailure(HandlerFactory.ERR_SOMETHING_WENT_WRONG);
    }

    return token;
  }

  pylons.QueryClient getQueryClient() {
    return pylons.QueryClient(sl.get<BaseEnv>().networkInfo.gRPCChannel);
  }

  @override
  Future<List<pylons.Cookbook>> getCookbooksByCreator({required String address}) async {
    final pylons.QueryClient queryClient = getQueryClient();
    final request = pylons.QueryListCookbooksByCreatorRequest.create()..creator = address;

    final response = await queryClient.listCookbooksByCreator(request);
    return response.cookbooks;
  }

  @override
  Future<pylons.Trade> getTradeByID({required Int64 id}) async {
    final pylons.QueryClient queryClient = getQueryClient();

    final request = pylons.QueryGetTradeRequest.create()..id = id;
    final response = await queryClient.trade(request);

    if (response.hasTrade()) {
      return response.trade;
    }

    throw TradeNotFoundFailure(LocaleKeys.trade_not_found.tr());
  }

  @override
  Future<String> sendGoogleInAppPurchaseCoinsRequest(GoogleInAppPurchaseModel googleInAppPurchaseModel) async {
    final msgGoogleInAPPPurchase = pylons.MsgGoogleInAppPurchaseGetCoins()..mergeFromProto3Json(googleInAppPurchaseModel.toJson());

    final customTransactionSigningGateway = getCustomTransactionSigningGateway();

    final walletsResultEither = await customTransactionSigningGateway.getWalletsList();
    if (walletsResultEither.isLeft()) {
      onLogError(walletsResultEither.getLeft().message, fatal: true);
      throw const TransactionSigningFailure(
        message: SOMETHING_WRONG_FETCHING_WALLETS,
        type: HandlerFactory.ERR_FETCHING_WALLETS,
      );
    }

    final accountsList = walletsResultEither.getOrElse(() => []);
    if (accountsList.isEmpty) {
      throw TransactionSigningFailure(
        message: LocaleKeys.no_profile_found.tr(),
        type: HandlerFactory.ERR_PROFILE_DOES_NOT_EXIST,
      );
    }
    final info = accountsList.last;

    msgGoogleInAPPPurchase.creator = info.publicAddress;

    return _signAndBroadcast(msgGoogleInAPPPurchase);
  }

  @override
  Future<String> sendAppleInAppPurchaseCoinsRequest(AppleInAppPurchaseModel appleInAppPurchaseModel) {
    final msgAppleInAppPurchases = pylons.MsgAppleIap()..mergeFromProto3Json(appleInAppPurchaseModel.toJson());

    return _signAndBroadcast(msgAppleInAppPurchases);
  }

  @override
  Future<ProductDetails> getProductsForSale({required String itemId}) {
    return storePaymentService.getProductsForSale(itemId: itemId);
  }

  @override
  Future<bool> buyProduct(ProductDetails productDetails) {
    return storePaymentService.buyProduct(productDetails);
  }

  @override
  Future<bool> isInAppPurchaseAvailable() {
    return storePaymentService.isInAppPurchaseAvailable();
  }

  @override
  Future<String> createDynamicLinkForUserInvite({required String address}) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://wallet.pylons.tech/invite/$address"),
      uriPrefix: "https://pylons.page.link/",
      androidParameters: const AndroidParameters(packageName: "tech.pylons.wallet"),
      iosParameters: const IOSParameters(
        bundleId: "xyz.pylons.wallet",
      ),
    );

    final link = await dynamicLinksGenerator.buildLink(dynamicLinkParams);
    return link.toString();
  }

  @override
  Future<String> createDynamicLinkForRecipeNftShare({required String address, required NFT nft}) async {
    final updateText = nft.ibcCoins.getAbbrev() == constants.kPYLN_ABBREVATION
        ? "\$${nft.ibcCoins.pylnToCredit(nft.ibcCoins.getCoinWithProperDenomination(nft.price))}"
        : "${nft.ibcCoins.getCoinWithProperDenomination(nft.price)} ${nft.ibcCoins.getAbbrev()}";

    final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse("$bigDipperBaseLink?recipe_id=${nft.recipeID}&cookbook_id=${nft.cookbookID}&address=$address"),
        uriPrefix: kDeepLink,
        androidParameters: AndroidParameters(
          packageName: packageName,
          fallbackUrl: Uri.parse("$bigDipperBaseLink?recipe_id=${nft.recipeID}&cookbook_id=${nft.cookbookID}&address=$address"),
        ),
        iosParameters: IOSParameters(
          bundleId: bundleId,
          fallbackUrl: Uri.parse("$bigDipperBaseLink?recipe_id=${nft.recipeID}&cookbook_id=${nft.cookbookID}&address=$address"),
        ),
        navigationInfoParameters: const NavigationInfoParameters(forcedRedirectEnabled: true),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: nft.name,
          imageUrl: Uri.parse(nft.url),
          description: '${nft.description}  Price:${nft.price == "0" ? LocaleKeys.free.tr() : updateText}',
        ));

    final link = await dynamicLinksGenerator.buildShortLink(
      dynamicLinkParams,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );
    return link.shortUrl.toString();
  }

  Uri getUri(NFT nft) {
    if (nft.assetType == AssetType.Image) return Uri.parse(nft.url);
    return Uri.parse(nft.thumbnailUrl);
  }

  @override
  Future<TransactionResponse> createAccount({
    required AccountPublicInfo publicInfo,
    required WalletCreationModel walletCreationModel,
    required String appCheckToken,
    required String referralToken,
  }) async {
    final customTransactionSigningGateway = getCustomTransactionSigningGateway();
    final walletLookupKey = createWalletLookUp(publicInfo);

    final msgObj = pylons.MsgCreateAccount(
      creator: walletCreationModel.creatorAddress.toString(),
      token: appCheckToken,
      referralAddress: referralToken,
    );

    final unsignedTransaction = UnsignedAlanTransaction(messages: [msgObj]);

    final result = await customTransactionSigningGateway.signTransaction(transaction: unsignedTransaction, walletLookupKey: walletLookupKey).mapError<dynamic>((error) {
      throw error;
    }).flatMap(
      (signed) => customTransactionSigningGateway.broadcastTransaction(
        walletLookupKey: walletLookupKey,
        transaction: signed,
      ),
    );

    if (result.isLeft()) {
      throw result.getLeft().toString();
    }

    return result.getOrElse(() => TransactionResponse.initial());
  }

  @override
  Future<String> enableDisableRecipe({
    required CookbookId cookBookId,
    required RecipeId recipeId,
    required bool enabled,
    required Address creatorAddress,
  }) async {
    final recipe = await getRecipe(cookBookId: cookBookId, recipeId: recipeId);

    final recipeProto3Json = recipe.toProto3Json()! as Map;
    recipeProto3Json.remove(kCreatedAtCamelCase);
    recipeProto3Json.remove(kUpdatedAtCamelCase);

    final msgUpdateRecipe = pylons.MsgUpdateRecipe.create()..mergeFromProto3Json(recipeProto3Json);
    msgUpdateRecipe.enabled = enabled;
    msgUpdateRecipe.version = msgUpdateRecipe.version.incrementRecipeVersion();
    msgUpdateRecipe.creator = creatorAddress.toString();

    return _signAndBroadcast(msgUpdateRecipe);
  }

  Future<String> stampTicket({
    required CookbookId cookBookId,
    required RecipeId recipeId,
    required Address creatorAddress,
  }) async {
    final recipe = await getRecipe(cookBookId: cookBookId, recipeId: recipeId);

    final recipeProto3Json = recipe.toProto3Json()! as Map;
    recipeProto3Json.remove(kCreatedAtCamelCase);
    recipeProto3Json.remove(kUpdatedAtCamelCase);
    recipeProto3Json.putIfAbsent("isStamped", true)

    final msgUpdateRecipe = pylons.MsgUpdateRecipe.create()..mergeFromProto3Json(recipeProto3Json);
    msgUpdateRecipe.version = msgUpdateRecipe.version.incrementRecipeVersion();
    msgUpdateRecipe.creator = creatorAddress.toString();

    return _signAndBroadcast(msgUpdateRecipe);
  }

  @override
  Future<String> createDynamicLinkForItemNftShare({
    required String address,
    required String itemId,
    required String cookbookId,
  }) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("$bigDipperBaseLink?item_id=$itemId&cookbook_id=$cookbookId&address=$address"),
      uriPrefix: kDeepLink,
      androidParameters: AndroidParameters(packageName: packageName, fallbackUrl: Uri.parse("$bigDipperBaseLink?item_id=$itemId&cookbook_id=$cookbookId&address=$address")),
      iosParameters: const IOSParameters(bundleId: bundleId),
    );

    final link = await dynamicLinksGenerator.buildLink(dynamicLinkParams);
    return link.toString();
  }

  @override
  Future<String> createDynamicLinkForTradeNftShare({required String address, required String tradeId}) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("$bigDipperBaseLink?trade_id=$tradeId&address=$address"),
      uriPrefix: kDeepLink,
      androidParameters: AndroidParameters(packageName: packageName, fallbackUrl: Uri.parse("$bigDipperBaseLink?trade_id=$tradeId&address=$address")),
      iosParameters: const IOSParameters(bundleId: bundleId),
    );

    final link = await dynamicLinksGenerator.buildShortLink(dynamicLinkParams);
    return link.shortUrl.toString();
  }

  @override
  Future<bool> saveUserFeedback({required String walletAddress, required String subject, required String feedback}) {
    return firebaseHelper.saveUserFeedback(walletAddress: walletAddress, subject: subject, feedback: feedback);
  }

  @override
  Future<bool> setUpUserIdentifierInAnalytics({required String address}) async {
    await analyticsHelper.setUserId(address: address);
    return true;
  }

  @override
  Future<TransactionResponse> setUserName({
    required String username,
    required String address,
    required AccountPublicInfo publicInfo,
  }) async {
    final msgObj = MsgSetUsername(creator: address, username: username);

    final txHash = await _signAndBroadcast(msgObj);
    return TransactionResponse(hash: txHash);
  }

  @override
  Future<bool> logPurchaseItem({
    required RecipeId recipeId,
    required String recipeName,
    required String author,
    required double purchasePrice,
  }) async {
    await analyticsHelper.logPurchaseItem(
      recipeId: recipeId.toString(),
      recipeName: recipeName,
      author: author,
      purchasePrice: purchasePrice,
    );
    return true;
  }

  @override
  Future<bool> logAddToCart({
    required RecipeId recipeId,
    required String recipeName,
    required String author,
    required double purchasePrice,
    required String currency,
  }) async {
    await analyticsHelper.logAddToCart(
      recipeId: recipeId.toString(),
      recipeName: recipeName,
      author: author,
      purchasePrice: purchasePrice,
      currency: currency,
    );
    return true;
  }

  @override
  Future<TransactionResponse> cancelTrade({required TradeId tradeId, required Address address}) async {
    final msgObj = MsgCancelTrade(creator: address.toString(), id: tradeId.id);
    final txHash = await _signAndBroadcast(msgObj);
    return TransactionResponse(hash: txHash);
  }

  @override
  Future<TransactionResponse> createTrade({required pylons.MsgCreateTrade msgCreateTrade}) async {
    final txHash = await _signAndBroadcast(msgCreateTrade);
    return TransactionResponse(hash: txHash);
  }

  @override
  Future<void> logUserJourney({required String screenName}) async {
    await analyticsHelper.logUserJourney(screenName: screenName);
  }

  bank.QueryClient getBankQueryClient() {
    return bank.QueryClient(sl.get<BaseEnv>().networkInfo.gRPCChannel);
  }

  CustomTransactionSigningGateway getCustomTransactionSigningGateway() {
    return sl.get<CustomTransactionSigningGateway>();
  }

  TransactionSigningGateway getTransactionSigningGateway() {
    return sl.get<TransactionSigningGateway>();
  }

  BaseEnv getBaseEnv() {
    return sl.get<BaseEnv>();
  }

  final http.Client httpClient;
  final StorePaymentService storePaymentService;
  final FirebaseAppCheck firebaseAppCheck;
  final FirebaseDynamicLinks dynamicLinksGenerator;
  final FirestoreHelper firebaseHelper;
  final AnalyticsHelper analyticsHelper;
  final OnLogError onLogError;

  @override
  Future<List<PylonItems>> getPylonItem({required Address address}) async {
    final baseApiUrl = getBaseEnv().baseApiUrl;

    final uri = Uri.parse("$baseApiUrl/pylons/items/${address.id}");

    final pylonItemsResponse = await httpClient.get(uri).timeout(timeOutDuration);

    if (pylonItemsResponse.statusCode != API_SUCCESS_CODE) {
      throw HandlerFactory.ERR_SOMETHING_WENT_WRONG;
    }

    final pylonItemsMap = jsonDecode(pylonItemsResponse.body);

    final List<PylonItems> pylonListItems = [];

    pylonItemsMap["items"].map((data) {
      final pylonItems = PylonItems.fromJson(data as Map<String, dynamic>);
      pylonListItems.add(pylonItems);
    }).toList();

    return pylonListItems.toList();
  }

  @override
  Future<String> createDynamicLinkForRecipeEventShare({required String address, required Events events}) async {
    final updateText = events.denom.getAbbrev() == constants.kPYLN_ABBREVATION
        ? "\$${events.denom.pylnToCredit(events.denom.getCoinWithProperDenomination(events.price))}"
        : "${events.denom.getCoinWithProperDenomination(events.price)} ${events.denom.getAbbrev()}";

    final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse("$bigDipperBaseLink?recipe_id=${events.recipeID}&cookbook_id=${events.cookbookID}&address=$address"),
        uriPrefix: kDeepLink,
        androidParameters: AndroidParameters(
          packageName: packageName,
          fallbackUrl: Uri.parse("$bigDipperBaseLink?recipe_id=${events.recipeID}&cookbook_id=${events.cookbookID}&address=$address"),
        ),
        iosParameters: IOSParameters(
          bundleId: bundleId,
          fallbackUrl: Uri.parse("$bigDipperBaseLink?recipe_id=${events.recipeID}&cookbook_id=${events.cookbookID}&address=$address"),
        ),
        navigationInfoParameters: const NavigationInfoParameters(forcedRedirectEnabled: true),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: events.eventName,
          imageUrl: Uri.parse(events.thumbnail),
          description: '${events.description}  Price:${events.price == "0" ? LocaleKeys.free.tr() : updateText}',
        ));

    final link = await dynamicLinksGenerator.buildShortLink(
      dynamicLinkParams,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );
    return link.shortUrl.toString();
  }
}

class AppleInAppPurchaseModel {
  String productID;
  String purchaseID;
  String receiptData;
  String creator;

  AppleInAppPurchaseModel({
    required this.productID,
    required this.purchaseID,
    required this.receiptData,
    required this.creator,
  });

  AppleInAppPurchaseModel.fromJson(Map<String, dynamic> json)
      : productID = json['productId'] as String,
        purchaseID = json['purchaseId'] as String,
        receiptData = json['receiptDataBase64'] as String,
        creator = json['creator'] as String;

  Map<String, String> toJson() => {"productId": productID, "purchaseId": purchaseID, "receiptDataBase64": receiptData, "creator": creator};
}

class GoogleInAppPurchaseModel {
  String productID;
  String purchaseToken;
  Map receiptData;
  String signature;
  String creator;

  GoogleInAppPurchaseModel({
    required this.productID,
    required this.purchaseToken,
    required this.receiptData,
    required this.signature,
    required this.creator,
  });

  GoogleInAppPurchaseModel.fromJson(Map<String, dynamic> json)
      : productID = json['product_id'] as String,
        purchaseToken = json['purchase_token'] as String,
        receiptData = json['receipt_data_base64'] as Map,
        signature = json['signature'] as String,
        creator = json['creator'] as String;

  Map<String, String> toJson() => {"product_id": productID, "purchase_token": purchaseToken, "receipt_data_base64": getReceiptDataInBase64(), "signature": signature, "creator": creator};

  Map<String, dynamic> toJsonLocalRetry() => {"product_id": productID, "purchase_token": purchaseToken, "receipt_data_base64": receiptData, "signature": signature, "creator": creator};

  String getReceiptDataInBase64() {
    return base64Url.encode(utf8.encode(jsonEncode(receiptData)));
  }
}
