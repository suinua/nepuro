import 'dart:mirrors';
import 'dart:io';

import 'package:nepuro/src/http/arrayManager.dart';
import 'package:nepuro/src/http/classManager.dart';
import 'package:nepuro/src/http/model/AnnotatedFunc.dart';
import 'package:nepuro/src/http/model/NecessaryField.dart';
import 'package:nepuro/src/http/model/Route.dart';

class RouteFunc {
  Route metadata;
  MethodMirror method;

  RouteFunc(this.metadata, this.method);

  bool isNeedOfBody() {
    return getBodyTypeList().isNotEmpty;
  }

  bool isNotNeedOfBody() {
    return getBodyTypeList().isEmpty;
  }

  dynamic toBodyType(Map body) {
    ClassMirror bodyType = getBodyType();
    List<String> fieldNemeList = getClassFieldNames(bodyType);
    List arguments = sortFromList(fieldNemeList, body).values.toList();

    return bodyType.newInstance(bodyType.owner.simpleName, arguments).reflectee;
  }

  List<ParameterMirror> getBodyTypeList() {
    return this
        .method
        .parameters
        .where((parameter) => parameter.metadata.first.reflectee.type == "body")
        .toList();
  }

  ClassMirror getBodyType() {
    return getBodyTypeList().first.type;
  }

  //necessaryField
  bool isNeedOfNecessaryField() {
    return getNecessaryFieldList().isNotEmpty;
  }

  bool isNotNeedOfNecessaryField() {
    return getNecessaryFieldList().isEmpty;
  }

  List<NecessaryField> getNecessaryFieldList() {
    List<InstanceMirror> mockNecessaryFieldList = this
        .method
        .metadata
        .where((metadata) => metadata.reflectee.runtimeType == NecessaryField)
        .toList();

    List<NecessaryField> necessaryFieldList = new List();
    mockNecessaryFieldList.forEach((necessaryField) {
      necessaryFieldList.add(necessaryField.reflectee);
    });
    return necessaryFieldList;
  }

  Map getField() {
    return getNecessaryFieldList().first.field;
  }

  bool isCorrectBody(Map requestBody) {
    bool result = true;
    
    //requestBodyのほうがnecessaryFieldより短いのならば
    //requestBoydは正しくない
    if (requestBody.length < getField().length) {
      result = false;
    
    } else {
      getField().forEach((key, type) {
        if (!(requestBody.containsKey(key) &&
            requestBody[key].runtimeType == type)) {
          result = false;
        }
      });
      getClassField(getBodyType()).forEach((fieldName, fieldType) {
        if (!(requestBody[fieldName].runtimeType == fieldType) && requestBody[fieldName] != null) {
          result = false;
        }
      });
    }
    return result;
  }

  //path
  bool isNeedOfPath() {
    return getPathTypeList().isNotEmpty;
  }

  bool isNotNeedOfPath() {
    return getPathTypeList().isEmpty;
  }

  List<ParameterMirror> getPathTypeList() {
    return this
        .method
        .parameters
        .where((parameter) => parameter.metadata.first.reflectee.type == "path")
        .toList();
  }

  toPathType(dynamic path) {
    Type pathType = getPathTypeList().first.type.reflectedType;
    switch (pathType) {
      case String:
        path.toString();
        break;
      case int:
        int.parse(path);
        break;
      default:
        //例外処理で「Stringかintのみ対応しています」
        path;
    }
  }
}

class RouteFuncData {
  List<RouteFunc> getAll() {
    List<RouteFunc> routeDataList = new List();
    List<AnnotatedFunc> annotationDataList = AnnotatedFuncData().getOf(Route);
    for (AnnotatedFunc annotationData in annotationDataList) {
      routeDataList
          .add(RouteFunc(annotationData.metadata, annotationData.method));
    }
    return routeDataList;
  }

  RouteFunc getMatch(HttpRequest request, List<RouteFunc> routeList) {
    _isMatchRoute(RouteFunc route) {
      //methodが一致していれば
      if (request.method == route.metadata.method) {
        //variablePathが無い && パスが完全一致する
        if (route.isNotNeedOfPath() &&
            route.metadata.path == request.uri.path) {
          return true;
        }

        //variablePathがあり &&　正規表現と一致する
        if (RegExp("\^${route.metadata.path}/.((?!/).)*\$")
                .hasMatch(request.uri.path) &&
            route.isNeedOfPath()) {
          return true;
        }
      }

      return false;
    }

    var matchRoute = routeList.where((route) => _isMatchRoute(route)).toList();
    return matchRoute.isEmpty ? null : matchRoute.first;
  }
}
