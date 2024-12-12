import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/services/purchase/verify_receipt_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/product_data.dart';
import 'package:hoho_hanja/screens/purchase/purchase_widgets/purchase_header.dart';
import 'package:hoho_hanja/screens/purchase/purchase_widgets/toggle_button.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final productController = Get.find<ProductDataController>();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final Logger _logger = Logger();

  List<ProductDetails> products = [];
  late StreamSubscription<List<PurchaseDetails>> _purchaseUpdatedSubscription;
  bool _isPendingTransaction = false;

  @override
  void initState() {
    super.initState();
    _initializePurchaseFlow();
  }

  Future<void> _initializePurchaseFlow() async {
    await _fetchProducts();
    _purchaseUpdatedSubscription = _inAppPurchase.purchaseStream
        .listen(_handlePurchaseUpdate, onError: (error) {
      _logger.e('Purchase Stream Error: $error');
    });
  }

  Future<void> _fetchProducts() async {
    Set<String> ids =
        productController.productData!.map((item) => item.productName).toSet();

    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(ids);

    if (!mounted) return;
    setState(() {
      products = response.productDetails;
    });
  }

  Future<void> _buyProduct(ProductDetails product) async {
    if (_isPendingTransaction) {
      _logger.w('Pending transaction exists. Please wait.');
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
      _logger.e('Error during purchase: $error');
      setState(() {
        _isPendingTransaction = false;
      });
    }
  }

  Future<void> _handlePurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        Logger().d('결제 성공!');
        bool isVerified = await _verifyPurchase(purchaseDetails);
        if (isVerified && purchaseDetails.pendingCompletePurchase) {
          await _completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _logger.e('Purchase Error: ${purchaseDetails.error?.message}');
        _logger.e('Purchase Error: ${purchaseDetails.error?.source}');
        if (purchaseDetails.pendingCompletePurchase) {
          await _completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    String platform = Theme.of(context).platform == TargetPlatform.android
        ? 'google'
        : 'apple';

    final matchingProduct = products.firstWhere(
      (product) => product.id == purchaseDetails.productID,
      orElse: () => throw Exception(
          'Product not found for ID: ${purchaseDetails.productID}'),
    );

    await verifyReceiptService(
      purchaseDetails,
      matchingProduct.rawPrice.toInt(),
      platform,
    );

    return true;
  }

  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      await _inAppPurchase.completePurchase(purchaseDetails);
      Logger().d(
          'purchaseDetails ${purchaseDetails.verificationData.localVerificationData}');
    } catch (error) {
    } finally {
      setState(() {
        _isPendingTransaction = false;
      });
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
                            onTap: () => _buyProduct(product),
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
                                        color: Color(int.parse(productController
                                            .productData![index].color)),
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
                                        color: Color(int.parse(productController
                                            .productData![index].color)),
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.sp, vertical: 4.sp),
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

  @override
  void dispose() {
    _purchaseUpdatedSubscription.cancel();
    super.dispose();
  }
}
