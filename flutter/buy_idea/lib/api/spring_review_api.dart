import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SpringReviewApi {

  static const String httpUri = '192.168.0.12:8888';

  Future<bool> productReviewRegister(ProductReviewRegisterInfo productReviewRegisterInfo) async {

    Dio dio = Dio();

    final MultipartFile image = MultipartFile.fromFileSync(
        productReviewRegisterInfo.image.path,
      contentType: MediaType('image', 'jpg')
    );

    FormData formData = FormData.fromMap({
      'file' : image,
      'review' : MultipartFile.fromString(
        jsonEncode({
          'productNo' : productReviewRegisterInfo.productNo,
          'writer' : productReviewRegisterInfo.writer,
          'starRating' : productReviewRegisterInfo.starRating,
          'content' : productReviewRegisterInfo.content
        }),
        contentType: MediaType.parse('application/json')
      )
    });

    var response = await dio.post(
      'http://$httpUri/review/register',
      data: formData
    );

    if (response.statusCode == 200) {
      debugPrint('productReviewRegister() 통신 확인');
      return true;
    } else {
      throw Exception('productReviewRegister() 에러 발생');
    }
  }

  Future<List<RequestProductReview>> productReviewList(int productNo, int reviewSize) async {

    var response = await http.get(
      Uri.http(httpUri, '/review/list', {'productNo' : productNo, 'reviewSize' : reviewSize}),
      headers: {'Content-Type' : 'application/json'}
    );

    if(response.statusCode == 200) {
      debugPrint("productReviewList() 통신 확인");
      var data = jsonDecode(utf8.decode(response.bodyBytes)) as List;

      List<RequestProductReview> reviewList = data.map(
              (list) => RequestProductReview.fromJson(list)).toList();

      return reviewList;
    } else {
      throw Exception("productReviewList() 에러 발생");
    }
  }

  Future<List<RequestProductReview>> nextProductReviewList(int productNo, int reviewNo, int reviewSize) async {

    var response = await http.get(
        Uri.http(httpUri, '/review/next-list', {'productNo' : productNo, 'reviewNo' : reviewNo, 'reviewSize' : reviewSize}),
        headers: {'Content-Type' : 'application/json'}
    );

    if(response.statusCode == 200) {
      debugPrint("nextProductReviewList() 통신 확인");
      var data = jsonDecode(utf8.decode(response.bodyBytes)) as List;

      List<RequestProductReview> reviewList = data.map(
              (list) => RequestProductReview.fromJson(list)).toList();

      return reviewList;
    } else {
      throw Exception("nextProductReviewList() 에러 발생");
    }
  }

  Future<RequestProductReviewImage> reviewImage(int reviewNo) async {

    var response = await http.get(
      Uri.http(httpUri, '/review/image/$reviewNo'),
      headers: {'Content-Type' : 'application/json'}
    );

    if(response.statusCode == 200) {
      debugPrint("reviewImage() 통신 확인");

      var data = jsonDecode(utf8.decode(response.bodyBytes));
      RequestProductReviewImage reviewImage = RequestProductReviewImage.fromJson(data);

      return reviewImage;
    } else {
      throw Exception("reviewImage() 에러 발생");
    }
  }
}

class RequestProductReview {
  int reviewNo;
  String writer;
  int starRating;
  String content;
  String regDate;
  String updDate;

  RequestProductReview({
    required this.reviewNo,
    required this.writer,
    required this.starRating,
    required this.content,
    required this.regDate,
    required this.updDate
  });

  factory RequestProductReview.fromJson(Map<String, dynamic> json) {
    return RequestProductReview(
        reviewNo: json['reviewNo'],
        writer: json['writer'],
        starRating: json['starRating'],
        content: json['content'],
        regDate: json['regDate'],
        updDate: json['updDate']
    );
  }
}

class RequestProductReviewImage {
  int reviewImageNo;
  String editedName;

  RequestProductReviewImage({required this.reviewImageNo, required this.editedName});

  factory RequestProductReviewImage.fromJson(Map<String, dynamic> json) {
    return RequestProductReviewImage(
      reviewImageNo: json['reviewImageNo'],
      editedName: json['editedName']
    );
  }
}

class ProductReviewRegisterInfo {
  int productNo;
  String writer;
  int starRating;
  XFile image;
  String content;

  ProductReviewRegisterInfo(
    this.productNo,
    this.writer,
    this.starRating,
    this.image,
    this.content
  );
}