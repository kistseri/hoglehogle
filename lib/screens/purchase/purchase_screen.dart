import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/services/purchase/verify_receipt_service.dart';
import 'package:hoho_hanja/widgets/dialog/show_parental_dialog.dart';
import 'package:hoho_hanja/widgets/parental_gate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:intl/intl.dart';

import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/product_data.dart';
import 'package:hoho_hanja/screens/purchase/purchase_widgets/purchase_header.dart';
import 'package:hoho_hanja/screens/purchase/purchase_widgets/toggle_button.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';
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

    final Map<String, ProductDetails> productDetailsMap = {
      for (var product in response.productDetails) product.id: product
    };

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

  // 시안(360 폭) 기준 크기. 배율 하나로만 키우거나 줄이고, 태블릿에서는 시안 폭으로 가운데 정렬
  static const double _gap = 16; // 카드 사이·바깥 여백
  static const double _cardH = 208; // 카드 높이 (폭 156 : 높이 208 = 0.75)

  @override
  Widget build(BuildContext context) {
    final sc = DesignScale.fromContext(context);
    double d(num v) => sc.d(v);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      // 밝은 배경이라 상태바 아이콘을 어둡게
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: sc.y(DesignAppBar.height),
              bottom: 0,
              child: Column(
                children: [
                  PurchaseHeader(scale: sc),
                  Expanded(
                    child: products.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: primaryColor))
                        : Center(
                            child: SizedBox(
                              width: d(DesignScale.designWidth),
                              child: GridView.builder(
                                padding: EdgeInsets.fromLTRB(d(_gap), 0, d(_gap), d(_gap)),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: d(_gap),
                                  crossAxisSpacing: d(_gap),
                                  mainAxisExtent: d(_cardH),
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) => _productCard(sc, index),
                              ),
                            ),
                          ),
                  ),
                  // 아래 안내 (안드로이드 내비게이션 바·홈 표시줄 위까지)
                  ToggleButton(scale: sc),
                ],
              ),
            ),
            // 앱바 (다른 화면과 같은 시안 좌표·크기)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: DesignAppBar(scale: sc, inset: (sc.dw - sc.maxContentWidth) / 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(DesignScale sc, int index) {
    double d(num v) => sc.d(v);
    final data = productController.productData![index];
    final color = Color(int.parse(data.color));

    return GestureDetector(
      onTap: () => confirmPurchase(products[index]),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(d(45)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(d(12)),
              child: Text(
                '다이아 ${data.dia}개',
                style: TextStyle(color: color, fontSize: d(18), fontWeight: FontWeight.bold, fontFamily: 'BMJUA'),
              ),
            ),
            Image.asset(
              'assets/images/icon/dia_${data.dia}.png',
              width: d(100),
              height: d(100),
              fit: BoxFit.contain,
            ),
            Padding(
              padding: EdgeInsets.all(d(8)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: d(24), vertical: d(4)),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(d(15))),
                child: Text(
                  '${_formatPrice(data.price)}원',
                  style:
                      TextStyle(color: mFontWhite, fontSize: d(14), fontWeight: FontWeight.bold, fontFamily: 'BMJUA'),
                ),
              ),
            ),
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
