import 'package:welangflood/src/constants/api_constants.dart';
import 'package:welangflood/src/features/screens/entri/widgets/data_survei.dart';
import 'package:welangflood/src/services/api_service.dart';

class SurveyResult {
  final bool success;
  final String message;

  SurveyResult({required this.success, required this.message});
}

class SurveyService {
  static Future<SurveyResult> submitSurvey(Survei survei, {String? fotoPath}) async {
    final response = await ApiService.postMultipart(
      ApiConstants.entry,
      survei.toFormFields(),
      filePath: fotoPath,
      fileFieldName: 'foto',
    );

    return SurveyResult(
      success: response['status'] == 'success',
      message: response['message'] ?? 'Terjadi kesalahan',
    );
  }

  static Future<List<Survei>> getSurveys({String? start, String? end}) async {
    final response = await ApiService.get(
      ApiConstants.surveys,
      queryParams: {
        // Fixed: use null-aware map entries
        if (start != null) 'start': start,
        if (end != null) 'end': end,
      },
    );

    if (response['status'] == 'success') {
      final List<dynamic> raw = response['data']['surveys'] ?? [];
      return raw.map((e) => Survei.fromJson(e as Map<String, dynamic>)).toList();
    }

    return [];
  }
}