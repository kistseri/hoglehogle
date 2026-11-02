import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/services/purchase/verify_receipt_service.dart';
import 'package:hoho_hanja/widgets/dialog/show_parental_dialog.dart';
import 'package:hoho_hanja/widgets/parental_gate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:intl/intl.dart';

import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/product_data.dart';
import 'package:hoho_hanja/screens/purchase/purchase_widgets/purchase_header.dart';
import 'package:hoho_hanja/screens/purchase/purchase_widgets/toggle_button.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';
import 'package:logger/logger.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final productController = Get.find<ProductDataController>();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  List<ProductDetails> products = [];
  late StreamSubscription<List<PurchaseDetails>> _purchaseUpdatedSubscription;
  bool _isPendingTransaction = false;

  String currentProblem = '';
  dynamic currentSolution;

  @override
  void initState() {
    super.initState();
    _initializePurchaseFlow();
  }

  Future<void> _initializePurchaseFlow() async {
    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (var tx in transactions) {
        Logger().d("iOS 미완료 결제 정리: ${tx.transactionIdentifier}");
        await SKPaymentQueueWrapper().finishTransaction(tx);
      }
    }
    await _fetchProducts();
    _purchaseUpdatedSubscription = _inAppPurchase.purchaseStream.listen(_handlePurchaseUpdate, onError: (error) {
      Logger().d(error);
    });
  }

  Future<void> _fetchProducts() async {
    Set<String> ids = productController.productData!.map((item) => item.productName).toSet();

    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);

    final Map<String, ProductDetails> productDetailsMap = {for (var product in response.productDetails) product.id: product};

    final List<ProductDetails> orderedProducts =
        ids.map((id) => productDetailsMap[id]).where((product) => product != null).cast<ProductDetails>().toList();

    if (!mounted) return;
    setState(() {
      products = orderedProducts;
    });
  }

  Future<void> _buyProduct(ProductDetails product) async {
    if (_isPendingTransaction) {
      return;
    }
    setState(() {
      _isPendingTransaction = true;
    });

    try {
      await _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
        autoConsume: true,
      );
    } catch (error) {
      setState(() {
        _isPendingTransaction = false;
      });
    }
  }

  Future<void> _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      Logger().d(purchaseDetails.status);
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          setState(() => _isPendingTransaction = true);
          Get.snackbar(
            '결제 대기',
            '대표 계정의 승인을 기다리고 있습니다.',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          Logger().d("구매 완료/복원: ${purchaseDetails.productID}");
          final isVerified = await _verifyPurchase(purchaseDetails);
          await _inAppPurchase.completePurchase(purchaseDetails);
          if (isVerified) {
            Logger().d("결제 처리 완료: ${purchaseDetails.productID}");
            Get.snackbar('구매 완료', '다이아 구매가 완료되었습니다.');
          } else {
            Logger().w("결제 검증 실패: ${purchaseDetails.productID}");
            Get.snackbar('결제 실패', '영수증 검증에 실패했습니다.');
          }
          setState(() => _isPendingTransaction = false);
          break;

        case PurchaseStatus.error:
          Logger().e("결제 오류: ${purchaseDetails.error}");
          Get.snackbar(
            '결제 실패',
            '오류가 발생했습니다: ${purchaseDetails.error?.message}',
            snackPosition: SnackPosition.BOTTOM,
          );
          setState(() => _isPendingTransaction = false);
          break;

        default:
          setState(() => _isPendingTransaction = false);
          break;
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final platform = Platform.isAndroid ? 'google' : 'apple';
      final matchingProduct = products.firstWhere(
        (product) => product.id == purchaseDetails.productID,
        orElse: () => throw Exception(
          'Product not found: ${purchaseDetails.productID}',
        ),
      );
      final statusToSend = (purchaseDetails.status == PurchaseStatus.restored)
          ? 'purchased'
          : purchaseDetails.status.toString().split('.').last;

      bool result = false;
      if (platform == 'google') {
        result = await verifyGoogleReceipt(
          purchaseDetails,
          matchingProduct.price,
        );
      } else if (platform == 'apple') {
        result = await verifyAppleReceipt(
          purchaseDetails,
          matchingProduct.price,
        );

      }
      print('===============result: $result ===============');
      return result;
    } catch (e, st) {
      Logger().e("영수증 검증 중 오류 $e, $st");
      return false;
    }
  }

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: const Color(0xFFFFF8E7),
      body: Center(
        child: Column(
          children: [
            const PurchaseHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(gapHalf),
                child: products.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: gapHalf,
                          crossAxisSpacing: gapHalf,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () => confirmPurchase(product),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(45.r),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(12.r),
                                    child: Text(
                                      '다이아 ${productController.productData![index].dia}개',
                                      style: TextStyle(
                                        color: Color(int.parse(productController.productData![index].color)),
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'BMJUA',
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/icon/dia_${productController.productData![index].dia}.png',
                                    width: 100.w,
                                    height: 100.h,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(gapQuarter),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(productController.productData![index].color)),
                                        borderRadius: BorderRadius.circular(15.r),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 4.sp),
                                        child: Text(
                                          '${_formatPrice(productController.productData![index].price)}원',
                                          style: TextStyle(
                                            color: mFontWhite,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'BMJUA',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const ToggleButton(),
          ],
        ),
      ),
    );
  }

  void confirmPurchase(product) {
    Get.defaultDialog(
      title: '결제',
      middleText: '정말로 결제 하시겠습니까?',
      textConfirm: '확인',
      buttonColor: primaryColor,
      textCancel: '취소',
      barrierDismissible: true,
      onConfirm: () async {
        Get.back();
        if (!Platform.isAndroid) {
          showParentalDialog(context, () async {
            Logger().d('클릭');
            await _buyProduct(product);
          });
        } else {
          await _buyProduct(product);
        }
      },
      onCancel: () {},
    );
  }

  @override
  void dispose() {
    _purchaseUpdatedSubscription.cancel();
    super.dispose();
  }
}
