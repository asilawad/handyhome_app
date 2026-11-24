import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Answers every API request from JSON files in `assets/mock/`, so the app
/// runs without the old backend. Repositories and cubits are unchanged: they
/// still call Dio, and this interceptor returns the response the real server
/// used to send.
///
/// Changes made while the app is open (new orders, addresses, reviews) are
/// kept in memory until the app restarts.
class MockApiInterceptor extends Interceptor {
  static const _delay = Duration(milliseconds: 350);

  static List<Map<String, dynamic>>? _categories;
  static List<Map<String, dynamic>>? _services;
  static List<Map<String, dynamic>>? _orders;
  static List<Map<String, dynamic>>? _locations;
  static Map<String, dynamic>? _notifications;
  static Map<String, dynamic>? _user;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      await (_loading ??= _load());
      await Future.delayed(_delay);
      final body = _route(options);
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: body),
      );
    } catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  // ------------------------------------------------------------------ load

  /// One shared load, so parallel requests all wait for every file.
  static Future<void>? _loading;

  static Future<void> _load() async {
    _categories = await _list('categories');
    _services = await _list('services');
    _orders = await _list('orders');
    _locations = await _list('locations');
    _notifications = await _json('notifications') as Map<String, dynamic>;
    _user = await _json('user') as Map<String, dynamic>;
  }

  static Future<dynamic> _json(String name) async =>
      jsonDecode(await rootBundle.loadString('assets/mock/$name.json'));

  static Future<List<Map<String, dynamic>>> _list(String name) async =>
      (await _json(name) as List).cast<Map<String, dynamic>>();

  // ----------------------------------------------------------------- route

  dynamic _route(RequestOptions o) {
    final method = o.method.toUpperCase();
    final path = o.uri.path;
    final data = o.data is Map ? Map<String, dynamic>.from(o.data) : {};
    Match? m;

    // auth: any email and password are accepted in demo mode
    if (path.startsWith('/api/auth/')) {
      if (path.endsWith('/login/')) {
        return {'refresh': 'demo-refresh', 'access': 'demo-access'};
      }
      if (path.contains('verify-reset-password-code')) {
        return {'detail': 'تم التحقق من الرمز', 'token': 'demo-token'};
      }
      return {'detail': 'تمت العملية بنجاح'};
    }

    // home and services
    if (path == '/api/services/categories/') {
      return _categories!.map(_categoryJson).toList();
    }
    if ((m = RegExp(r'^/api/services/category/(\d+)/services/$')
            .firstMatch(path)) !=
        null) {
      final id = int.parse(m!.group(1)!);
      final cat = _categories!.firstWhere((c) => c['id'] == id,
          orElse: () => _categories!.first);
      return {
        'detail': {
          'name': cat['name'],
          'icon': cat['icon'],
          'services': _servicesOf(id).map(_serviceJson).toList(),
        }
      };
    }
    if ((m = RegExp(r'^/api/services/(\d+)/detail/$').firstMatch(path)) !=
        null) {
      return _serviceJson(_service(int.parse(m!.group(1)!)));
    }
    if (path == '/api/services/latest-add/') {
      return _services!.reversed.take(6).map(_serviceJson).toList();
    }
    if (path == '/api/services/') {
      final q = (o.queryParameters['q'] ?? '').toString().trim();
      return _services!
          .where((s) => q.isEmpty || s['name'].toString().contains(q))
          .map(_serviceJson)
          .toList();
    }

    // orders
    if (path == '/api/orders/all-order/') return _orders!.reversed.toList();
    if (path == '/api/orders/active-order/') {
      return _orders!.reversed
          .where((o) =>
              o['order_status'] == 'قيد المراجعة' ||
              o['order_status'] == 'قيد التنفيذ')
          .toList();
    }
    if (path == '/api/orders/' && method == 'POST') {
      final service = _service(data['service'] ?? 1);
      final order = {
        'id': 100 + _orders!.length,
        'order_status': 'قيد المراجعة',
        'quantity': data['quantity'] ?? 1,
        'total_price': data['total_price'] ?? service['price_from'],
        'date_order': data['date_order'] ?? '',
        'time_order': data['time_order'] ?? '',
        'create_at': DateTime.now().toIso8601String().substring(0, 10),
        'update_at': DateTime.now().toIso8601String().substring(0, 10),
        'create_by': 1,
        'service': service['id'],
        'service_name': service['name'],
      };
      _orders!.add(order);
      return order;
    }
    if (path == '/api/reviews/' && method == 'POST') {
      final service = _service(data['service'] ?? 1);
      (service['reviews'] as List).insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'user': {
          'first_name': _user!['first_name'],
          'last_name': _user!['last_name'],
          'image': _user!['image'],
        },
        'review': data['review'] ?? 5,
        'comment': data['comment'] ?? '',
        'create_at': DateTime.now().toIso8601String().substring(0, 10),
        'update_at': DateTime.now().toIso8601String().substring(0, 10),
      });
      return {'detail': 'تم التقييم بنجاح'};
    }

    // notifications
    if (path == '/api/orders/unread-notification/') {
      return _notifications!['unread'];
    }
    if (path == '/api/orders/read-notification/') {
      return _notifications!['read'];
    }
    if (path == '/api/orders/notification/change/') {
      final unread = _notifications!['unread'] as List;
      (_notifications!['read'] as List).insertAll(0, unread);
      unread.clear();
      return {'detail': 'success'};
    }

    // profile
    if (path == '/api/users/user-data/') return _user;
    if (path == '/api/users/edit-user/') {
      _user!['first_name'] = data['first_name'] ?? _user!['first_name'];
      _user!['last_name'] = data['last_name'] ?? _user!['last_name'];
      return {'detail': 'تم تعديل البيانات بنجاح'};
    }
    if (path == '/api/users/create-custom-service/') {
      return {
        'detail': {
          'status': 'تم إنشاء طلب خدمة مخصصة بنجاح',
          'services': {
            'id': 1,
            'name': data['name'] ?? '',
            'descriptions': data['descriptions'] ?? '',
            'request_date': data['request_date'] ?? '',
            'request_time': data['request_time'] ?? '',
            'request_by': 1,
            'category': data['category'] ?? 1,
            'location': data['location'] ?? 1,
          },
          'order_status': 'قيد المراجعة',
        }
      };
    }
    if (path == '/api/users/create-service-provider/') {
      return {
        'id': 1,
        'name': data['name'] ?? '',
        'phone_number': data['phone_number'] ?? '',
        'location': data['location'] ?? '',
        'year_experience': data['year_experience'] ?? 0,
        'summary_experience': data['summary_experience'] ?? '',
        'additional': data['additional'] ?? '',
        'user': 1,
        'category': data['category'] ?? 1,
      };
    }
    if (path == '/api/users/location/') {
      if (method == 'POST') {
        _locations!.add({
          ...data,
          'id': _locations!.fold<int>(0, (a, l) => l['id'] > a ? l['id'] : a) +
              1,
          'user': 1,
        });
        return {'detail': 'تم الاضافة بنجاح'};
      }
      return _locations!.map(_locationJson).toList();
    }
    if ((m = RegExp(r'^/api/users/location/(\d+)/$').firstMatch(path)) !=
        null) {
      final id = int.parse(m!.group(1)!);
      if (method == 'DELETE') {
        _locations!.removeWhere((l) => l['id'] == id);
      } else {
        final i = _locations!.indexWhere((l) => l['id'] == id);
        if (i != -1) _locations![i] = {..._locations![i], ...data};
      }
      return {'detail': 'تم بنجاح'};
    }

    // verify password, change email, verify new email and anything else
    return {'detail': 'تمت العملية بنجاح'};
  }

  // --------------------------------------------------------------- helpers

  static Map<String, dynamic> _service(dynamic id) => _services!.firstWhere(
      (s) => s['id'] == id,
      orElse: () => _services!.first);

  static List<Map<String, dynamic>> _servicesOf(int categoryId) =>
      _services!.where((s) => s['category_id'] == categoryId).toList();

  static Map<String, dynamic> _categoryJson(Map<String, dynamic> c) => {
        'name': c['name'],
        'icon': c['icon'],
        'count_services': _servicesOf(c['id']).length,
        'category_services': '/api/services/category/${c['id']}/services/',
      };

  /// `detail` is the URL of the details endpoint, as the real API sent it.
  static Map<String, dynamic> _serviceJson(Map<String, dynamic> s) => {
        ...s,
        'detail': '/api/services/${s['id']}/detail/',
      };

  static Map<String, dynamic> _locationJson(Map<String, dynamic> l) => {
        ...l,
        'detail': '/api/users/location/${l['id']}/',
      };
}
