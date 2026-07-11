import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/create_ticket_request.dart';
import '../models/ticket_receipt_model.dart';

abstract interface class TicketsRemoteDatasource {
  Future<TicketReceiptModel> create(CreateTicketRequest request);
}

class TicketsRemoteDatasourceImpl implements TicketsRemoteDatasource {
  const TicketsRemoteDatasourceImpl({required this.client});

  final DioClient client;

  @override
  Future<TicketReceiptModel> create(CreateTicketRequest request) async {
    try {
      final response = await client.instance.post<Map<String, dynamic>>(
        '/tickets',
        data: request.toJson(),
      );
      final data = response.data;
      if (data == null) {
        throw ServerException('Empty response from server');
      }
      return TicketReceiptModel.fromJson(data);
    } on DioException catch (e) {
      final type = e.type;
      if (type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.connectionError ||
          type == DioExceptionType.receiveTimeout) {
        throw NetworkException(e.message ?? 'Network error');
      }
      final body = e.response?.data;
      final message = body is Map<String, dynamic>
          ? (body['message']?.toString() ?? e.message ?? 'Server error')
          : (e.message ?? 'Server error');
      throw ServerException(message, statusCode: e.response?.statusCode);
    }
  }
}
