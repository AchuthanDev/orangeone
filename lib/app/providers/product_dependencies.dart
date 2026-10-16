import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:orange_one/core/errors/app_failure.dart';
import 'package:orange_one/core/network/json_rpc_client.dart';
import 'package:orange_one/features/authentication/presentation/providers/auth_providers.dart';
import 'package:orange_one/features/home/data/data_sources/product_remote_data_source.dart';
import 'package:orange_one/features/home/data/repositories/odoo_product_repository.dart';
import 'package:orange_one/features/home/presentation/providers/product_providers.dart';
import 'package:orange_one/features/products/data/data_sources/product_details_remote_data_source.dart';
import 'package:orange_one/features/products/data/repositories/odoo_product_details_repository.dart';
import 'package:orange_one/features/products/presentation/providers/product_details_providers.dart';

final Override productDetailsRepositoryOverride =
    productDetailsRepositoryProvider.overrideWith((ref) {
      final auth = ref.watch(sessionControllerProvider);
      final session = auth.hasError || auth.isLoading ? null : auth.value;
      if (session == null) throw invalidSession;
      final cancel = CancelToken();
      ref.onDispose(cancel.cancel);
      return OdooProductDetailsRepository(
        ProductDetailsRemoteDataSource(
          ref.watch(jsonRpcClientProvider),
          origin: session.backendOrigin,
          token: session.accessToken,
          cancelToken: cancel,
        ),
        onSessionRejected: () async {
          if (ref.mounted &&
              identical(ref.read(sessionControllerProvider).value, session)) {
            await ref.read(sessionControllerProvider.notifier).signOut();
          }
        },
      );
    });

/// Cross-feature composition belongs to app, not either feature's internals.
final Override productRepositoryOverride = productRepositoryProvider
    .overrideWith((ref) {
      final auth = ref.watch(sessionControllerProvider);
      final session = auth.hasError || auth.isLoading ? null : auth.value;
      if (session == null) throw invalidSession;
      final cancel = CancelToken();
      ref.onDispose(cancel.cancel);
      return OdooProductRepository(
        ProductRemoteDataSource(
          ref.watch(jsonRpcClientProvider),
          origin: session.backendOrigin,
          accessToken: session.accessToken,
          cancelToken: cancel,
        ),
        onSessionRejected: () async {
          if (!ref.mounted) return;
          final current = ref.read(sessionControllerProvider).value;
          if (identical(current, session)) {
            await ref.read(sessionControllerProvider.notifier).signOut();
          }
        },
      );
    });
