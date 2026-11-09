import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/services/purchase/purchase_controller.dart';
import 'package:hoho_hanja/widgets/dialog/show_parental_dialog.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/product_data.dart';
import 'package:hoho_hanja/screens/purchase/purchase_widgets/purchase_header.dart';
import 'package:hoho_hanja/screens/purchase/purchase_widgets/toggle_button.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';
import 'package:logger/logger.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final productController = Get.find<ProductDataController>();
  final purchaseController = ensurePurchaseController();

  // 서버 상품(다이아 수·색) ↔ 스토어 상품(실제 결제·가격)을 product_name == product.id 로 짝지음 (C-09)
  List<StoreProduct> products = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // iOS 미완료 거래를 지급 없이 finish 하던 코드 삭제 (C-01): 전역 리스너가 받아 지급 후 끝냄
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final serverProducts = productController.productData ?? [];
    List<ProductDetails> storeProducts = [];
    try {
      final response =
          await InAppPurchase.instance.queryProductDetails(serverProducts.map((p) => p.productName).toSet());
      storeProducts = response.productDetails;
    } catch (e) {
      Logger().e('스토어 상품 조회 실패: $e');
    }
    for (final p in storeProducts) {
      purchaseController.storePrices[p.id] = p.price;
    }
    if (!mounted) return;
    setState(() {
      products = matchStoreProducts(serverProducts, storeProducts);
      _loaded = true;
    });
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
                        ? Center(
                            child: _loaded
                                ? Text('지금은 구매할 수 있는 상품이 없습니다.',
                                    style: TextStyle(fontSize: d(16), fontFamily: 'BMJUA', color: Colors.black54))
                                : const CircularProgressIndicator(color: primaryColor),
                          )
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
            // 결제 진행 중 표시 (앱바는 위에 두어 뒤로가기는 가능)
            // Positioned는 Stack 바로 아래에 있어야 하므로 Obx를 안쪽에 둠
            Positioned.fill(
              child: Obx(() => purchaseController.busy.value
                  ? const ColoredBox(
                      color: Colors.black26,
                      child: Center(child: CircularProgressIndicator(color: primaryColor)),
                    )
                  : const SizedBox.shrink()),
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
    final data = products[index].data;
    final storeProduct = products[index].store;
    // 서버 색상 값 형식이 다르면 기본색 (C-22)
    final colorValue = int.tryParse(data.color);
    final color = colorValue != null ? Color(colorValue) : primaryColor;

    return GestureDetector(
      onTap: () => confirmPurchase(storeProduct),
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
              // dia_30·40·45·50 외의 개수면 기본 다이아 아이콘 (C-22)
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/icon/diamond.png',
                width: d(100),
                height: d(100),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(d(8)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: d(24), vertical: d(4)),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(d(15))),
                // 스토어 현지화 가격 표시 (스토어 정책, C-23)
                child: Text(
                  storeProduct.price,
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

  bool _confirmOpen = false; // 결제 확인창이 떠 있는지

  void confirmPurchase(ProductDetails product) {
    if (purchaseController.busy.value) {
      failDialog('결제 진행 중', '진행 중인 결제가 끝난 뒤 다시 시도해주세요.');
      return;
    }
    // 상품을 연타해도 확인창은 하나만
    // (Get.isDialogOpen은 잠금해제 창 위에서 상점을 열면 계속 true라 결제창이 안 떴음 → 이 화면이 직접 기억)
    if (_confirmOpen) return;
    _confirmOpen = true;
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
            await purchaseController.buy(product);
          });
        } else {
          await purchaseController.buy(product);
        }
      },
      onCancel: () {},
    ).whenComplete(() => _confirmOpen = false);
  }
}

/// 화면에 보여줄 상품 하나: 서버 상품 정보 + 실제 결제할 스토어 상품
class StoreProduct {
  const StoreProduct(this.data, this.store);
  final ProductData data;
  final ProductDetails store;
}

/// 서버 상품 순서대로, 같은 id의 스토어 상품이 있는 것만 (스토어에 없는 상품은 숨김, C-09)
List<StoreProduct> matchStoreProducts(List<ProductData> serverProducts, List<ProductDetails> storeProducts) {
  final byId = {for (final p in storeProducts) p.id: p};
  return [
    for (final data in serverProducts)
      if (byId[data.productName] != null) StoreProduct(data, byId[data.productName]!),
  ];
}
