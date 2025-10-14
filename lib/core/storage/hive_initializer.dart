import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:temple_app/features/drawer/pooja_booking/data/booking_model.dart';
import 'package:temple_app/features/drawer/saved_members/data/member_model.dart';
import 'package:temple_app/features/drawer/store_order/data/order_model.dart';
import 'package:temple_app/features/home/data/models/god_category_model.dart';
import 'package:temple_app/features/home/data/models/profile_model.dart';
import 'package:temple_app/features/home/data/models/song_model.dart';

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

    // Home
    if (!Hive.isAdapterRegistered(GodCategoryAdapter().typeId)) {
      Hive.registerAdapter(GodCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(ProfileAdapter().typeId)) {
      Hive.registerAdapter(ProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(SongAdapter().typeId)) {
      Hive.registerAdapter(SongAdapter());
    }

    // Drawer - Pooja Booking
    if (!Hive.isAdapterRegistered(BookingAdapter().typeId)) {
      Hive.registerAdapter(BookingAdapter());
    }
    if (!Hive.isAdapterRegistered(UserDetailsAdapter().typeId)) {
      Hive.registerAdapter(UserDetailsAdapter());
    } 
    if (!Hive.isAdapterRegistered(OrderLineAdapter().typeId)) {
      Hive.registerAdapter(OrderLineAdapter());
    }
    if (!Hive.isAdapterRegistered(PoojaDetailsAdapter().typeId)) {
      Hive.registerAdapter(PoojaDetailsAdapter());
    }
    if (!Hive.isAdapterRegistered(SpecialPoojaDateDetailsAdapter().typeId)) {
      Hive.registerAdapter(SpecialPoojaDateDetailsAdapter());
    }
    if (!Hive.isAdapterRegistered(UserListDetailsAdapter().typeId)) {
      Hive.registerAdapter(UserListDetailsAdapter());
    }
    if (!Hive.isAdapterRegistered(UserAttributeDetailsAdapter().typeId)) {
      Hive.registerAdapter(UserAttributeDetailsAdapter());
    }
    // Drawer - Members
    if (!Hive.isAdapterRegistered(MemberModelAdapter().typeId)) {
      Hive.registerAdapter(MemberModelAdapter());
    }
    if (!Hive.isAdapterRegistered(MemberAttributeAdapter().typeId)) {
      Hive.registerAdapter(MemberAttributeAdapter());
    }
    // Drawer - Store Orders
    if (!Hive.isAdapterRegistered(StoreOrderAdapter().typeId)) {
      Hive.registerAdapter(StoreOrderAdapter());
    }
    if (!Hive.isAdapterRegistered(StoreOrderResponseAdapter().typeId)) {
      Hive.registerAdapter(StoreOrderResponseAdapter());
    }
    if (!Hive.isAdapterRegistered(ShippingAddressAdapter().typeId)) {
      Hive.registerAdapter(ShippingAddressAdapter());
    }
    if (!Hive.isAdapterRegistered(ProductVariantAdapter().typeId)) {
      Hive.registerAdapter(ProductVariantAdapter());
    }
    if (!Hive.isAdapterRegistered(ProductAdapter().typeId)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(OrderAdapter().typeId)) {
      Hive.registerAdapter(OrderAdapter());
    }
  
    



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
final godCategoryBoxProvider = FutureProvider<Box<GodCategory>>(
  (ref) async => Hive.openBox<GodCategory>('godCategoryBox'),
);

final profileBoxProvider = FutureProvider<Box<Profile>>(
  (ref) async => Hive.openBox<Profile>('profileBox'),
);

final songBoxProvider = FutureProvider<Box<Song>>(
  (ref) async => Hive.openBox<Song>('songBox'),
);

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
