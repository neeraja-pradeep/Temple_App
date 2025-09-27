import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// 📦 Models
import 'package:temple_app/features/shop/cart/data/model/cart_model.dart';
import 'package:temple_app/features/shop/data/model/category/store_category.dart';
import 'package:temple_app/features/shop/data/model/product/product_category.dart';
import 'package:temple_app/features/pooja/data/models/malayalam_date_model.dart';
import 'package:temple_app/features/pooja/data/models/pooja_category_model.dart';
import 'package:temple_app/features/pooja/data/models/pooja_model.dart';
import 'package:temple_app/features/shop/delivery/data/model/address_model.dart';
import 'package:temple_app/features/special/data/special_pooja_model.dart';

/// 🏗 Hive Initializer Class
class HiveInitializer {
  static Future<void> init() async {
    // ✅ Register Adapters only once

    // Cart
    if (!Hive.isAdapterRegistered(CartItemAdapter().typeId)) {
      Hive.registerAdapter(CartItemAdapter());
    }

    // Store Category
    if (!Hive.isAdapterRegistered(StoreCategoryAdapter().typeId)) {
      Hive.registerAdapter(StoreCategoryAdapter());
    }

    // Product List Section
    if (!Hive.isAdapterRegistered(CategoryProductModelAdapter().typeId)) {
      Hive.registerAdapter(CategoryProductModelAdapter());
    }
    if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(VariantModelAdapter().typeId)) {
      Hive.registerAdapter(VariantModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AddressModelAdapter().typeId)) {
      Hive.registerAdapter(AddressModelAdapter());
    }
    /////////////////////////////////////////////////////////////////////////
    if (!Hive.isAdapterRegistered(SpecialPoojaAdapter().typeId)) {
      Hive.registerAdapter(SpecialPoojaAdapter());
    }
    if (!Hive.isAdapterRegistered(SpecialPoojaDateAdapter().typeId)) {
      Hive.registerAdapter(SpecialPoojaDateAdapter());
    }
    if (!Hive.isAdapterRegistered(PoojaCategoryAdapter().typeId)) {
      Hive.registerAdapter(PoojaCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(PoojaAdapter().typeId)) {
      Hive.registerAdapter(PoojaAdapter());
    }
    if (!Hive.isAdapterRegistered(MalayalamDateModelAdapter().typeId)) {
      Hive.registerAdapter(MalayalamDateModelAdapter());
    }
  }
}

// 🔑 Providers for Hive Boxes
final cartBoxProvider = FutureProvider<Box<CartItem>>(
  (ref) async => Hive.openBox<CartItem>('cartBox'),
);

final storeCategoryBoxProvider = FutureProvider<Box<StoreCategory>>(
  (ref) async => Hive.openBox<StoreCategory>('storeCategory'),
);

final productBoxProvider = FutureProvider<Box<CategoryProductModel>>(
  (ref) async => Hive.openBox<CategoryProductModel>('productBox'),
);

final categoryBoxProvider = FutureProvider<Box<CategoryModel>>(
  (ref) async => Hive.openBox<CategoryModel>('categoryBox'),
);

final variantBoxProvider = FutureProvider<Box<VariantModel>>(
  (ref) async => Hive.openBox<VariantModel>('variantBox'),
);
final addressBoxProvider = FutureProvider<Box<AddressModel>>(
  (ref) async => Hive.openBox<AddressModel>('addressBox'),
);