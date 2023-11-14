import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:muonroi/core/Authorization/setting.api.dart';
import 'package:muonroi/core/authorization/enums/key.dart';
import 'package:muonroi/core/services/api_route.dart';
import 'package:muonroi/features/accounts/data/models/models.account.signin.dart';
import 'package:muonroi/features/user/data/models/user.info.model.dart';
import 'package:muonroi/features/user/data/models/user.single.detail.model.dart';
import 'package:muonroi/features/user/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

class UserService {
  Future<UserInfoResponseModel> getUserInfo(String username) async {
    try {
      var baseEndpoint = await endPoint();
      final response = await baseEndpoint
          .get(sprintf(ApiNetwork.userInfoByUsername, [username]));
      if (response.statusCode == 200) {
        return userInfoResponseModelFromJson(response.data.toString());
      } else {
        throw Exception("Failed to load user info");
      }
    } catch (e) {
      throw Exception("Failed to load user info - $e");
    }
  }

  Future<UserInfoResponseModel> updateUserInfo(SingleUserDetail request) async {
    try {
      var baseEndpoint = await endPoint();
      final response = await baseEndpoint.put(ApiNetwork.updateInfo,
          data: singleUserDetailToJson(request));
      if (response.statusCode == 200) {
        return userInfoResponseModelFromJson(response.data.toString());
      } else {
        throw Exception("Failed to load user info");
      }
    } catch (e) {
      throw Exception("Failed to load user info - $e");
    }
  }

  Future<UserInfoResponseModel> uploadAvatarUser(
      File file, String userGuid) async {
    try {
      await refreshAccessToken();
      var sharedPreferences = await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString(KeyToken.accessToken.name);
      var client = http.Client();
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiNetwork.baseApi}${ApiNetwork.uploadAvatar}'));
      request.files.add(await http.MultipartFile.fromPath('ImageSrc', file.path,
          filename: 'image_$userGuid.jpg'));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';
      var response = await client.send(request);
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var avatarInfo = userInfoResponseModelFromJson(responseBody);
        final sharedPreferences = await SharedPreferences.getInstance();
        var userInfo = accountSignInFromJson(
            sharedPreferences.getString('userLogin') ?? '');
        userInfo.result?.avatar = avatarInfo.result.avatar ?? '';
        sharedPreferences.setString('userLogin', accountSignInToJson(userInfo));

        return avatarInfo;
      } else {
        throw Exception("Failed to load user info");
      }
    } catch (e) {
      throw Exception("Failed to load user info - $e");
    }
  }
}