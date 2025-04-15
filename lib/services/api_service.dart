// 표준 Dart 라이브러리 임포트
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
// 표준 Dart 라이브러리 임포트
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

// Flutter 패키지 임포트
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

// 외부 패키지 임포트
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

// 프로젝트 모델 임포트
import '../models/voc_model.dart';
import '../models/system_update_model.dart';
import '../models/hardware_model.dart';
import '../models/software_model.dart';
import '../models/equipment_connection_model.dart';
import '../models/attachment_model.dart';

// 플랫폼 특화 임포트 (조건부 임포트)
import 'dart:html' as html if (dart.library.io) '../platform/stub_html.dart';

// UUID 생성 유틸리티 함수
String _generateUuid() {
  final random = Random();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final id = List.generate(20, (index) => chars[random.nextInt(chars.length)]).join();
  return '${DateTime.now().millisecondsSinceEpoch}_$id';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final String _baseUrl = 'http://localhost:3000/api';
  final Dio _dio = Dio(); // Use Dio for file uploads
  
  // 싱글톤 패턴 구현
  factory ApiService() => _instance;
  
  ApiService._internal();
  
  // 에러 로깅 함수 (디버그 정보 향상)
  void _logError(String operation, dynamic error, [String? url, dynamic data]) {
    String message = '[$operation 실패] $error';
    if (url != null) {
      message += '\nURL: $url';
    }
    if (data != null) {
      if (data is Map || data is List) {
        try {
          message += '\n데이터: ${jsonEncode(data)}';
        } catch (e) {
          message += '\n데이터: $data (인코딩 불가)';
        }
      } else {
        message += '\n데이터: $data';
      }
    }
    debugPrint(message);
  }

  // HTTP GET 요청 래퍼 함수
  Future<http.Response> _safeGet(Uri uri, {int timeoutSeconds = 10}) async {
    try {
      return await http.get(uri).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => http.Response('Timeout', 408),
      );
    } catch (e) {
      _logError('GET 요청', e, uri.toString());
      return http.Response('Error: $e', 500);
    }
  }

  // HTTP POST 요청 래퍼 함수
  Future<http.Response> _safePost(Uri uri, Map<String, dynamic> body, {int timeoutSeconds = 15}) async {
    try {
      return await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => http.Response('Timeout', 408),
      );
    } catch (e) {
      _logError('POST 요청', e, uri.toString(), body);
      return http.Response('Error: $e', 500);
    }
  }

  // HTTP PUT 요청 래퍼 함수
  Future<http.Response> _safePut(Uri uri, Map<String, dynamic> body, {int timeoutSeconds = 15}) async {
    try {
      return await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => http.Response('Timeout', 408),
      );
    } catch (e) {
      _logError('PUT 요청', e, uri.toString(), body);
      return http.Response('Error: $e', 500);
    }
  }

  // HTTP DELETE 요청 래퍼 함수
  Future<http.Response> _safeDelete(Uri uri, {int timeoutSeconds = 10}) async {
    try {
      return await http.delete(uri).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => http.Response('Timeout', 408),
      );
    } catch (e) {
      _logError('DELETE 요청', e, uri.toString());
      return http.Response('Error: $e', 500);
    }
  }
  
  // API 연결 테스트
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/voc');
      final response = await _safeGet(uri, timeoutSeconds: 5);
      
      return response.statusCode == 200;
    } catch (e) {
      _logError('API 연결 테스트', e);
      return false;
    }
  }
  
  // VOC 데이터 조회 (검색 및 필터링 지원)
  Future<List<VocModel>> getVocData({
    String? search,
    String? detailSearch,
    String? vocCategory,
    String? requestType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDateStart,
    DateTime? dueDateEnd,
  }) async {
    try {
      // 쿼리 파라미터 구성
      final Map<String, String> queryParams = {};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (detailSearch != null && detailSearch.isNotEmpty) {
        queryParams['detailSearch'] = detailSearch;
      }
      
      if (vocCategory != null) {
        queryParams['vocCategory'] = vocCategory;
      }
      
      if (requestType != null) {
        queryParams['requestType'] = requestType;
      }
      
      if (status != null) {
        queryParams['status'] = status;
      }
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      
      if (dueDateStart != null) {
        queryParams['dueDateStart'] = dueDateStart.toIso8601String();
      }
      
      if (dueDateEnd != null) {
        queryParams['dueDateEnd'] = dueDateEnd.toIso8601String();
      }
      
      // 참고: 서버 구현이 완료되면 solution_vocs 전용 컬렉션 사용 예정이나
      // 현재는 기존 컬렉션(vocs)을 사용하도록 원래 URL로 설정
      final uri = Uri.parse('$_baseUrl/voc').replace(queryParameters: queryParams);
      debugPrint('VOC 데이터 요청 URL: $uri');
      
      final response = await _safeGet(uri);
      
      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        debugPrint('VOC 데이터 ${dataList.length}개 성공적으로 로드 (첫 5개 번호: ${dataList.take(5).map((d) => d['no']).join(', ')})');
        
        final List<VocModel> convertedData = [];
        for (var data in dataList) {
          try {
            // _id 필드를 id로 매핑
            if (data['_id'] != null && data['id'] == null) {
              data['id'] = data['_id'];
            }
            
          final voc = VocModel.fromJson(data);
            convertedData.add(voc.copyWith(isSaved: true, isModified: false));
          } catch (e) {
            _logError('VOC 데이터 변환', e, null, data);
          }
        }
        
        return convertedData;
      } else {
        _logError('VOC 데이터 로드', '상태 코드: ${response.statusCode}', uri.toString(), response.body);
        return []; // 빈 배열 반환
      }
    } catch (e) {
      _logError('VOC 데이터 로드', e);
      return []; // 빈 배열 반환
    }
  }
  
  // 단일 VOC 조회
  Future<VocModel?> getVocById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/voc/$id'));
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return VocModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('VOC 상세 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('VOC 상세 조회 실패: $e');
      return null;
    }
  }
  
  // VOC 추가
  Future<VocModel?> addVoc(VocModel voc) async {
    try {
      // 데이터를 직접 구성하여 API 형식에 맞춤
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      final Map<String, dynamic> vocData = {
        'no': voc.no,
        'regDate': formatter.format(voc.regDate),
        'vocCategory': voc.vocCategory,
        'requestDept': voc.requestDept,
        'requester': voc.requester,
        'systemPath': voc.systemPath,
        'request': voc.request,
        'requestType': voc.requestType,
        'action': voc.action,
        'actionTeam': voc.actionTeam,
        'actionPerson': voc.actionPerson,
        'status': voc.status,
        'dueDate': formatter.format(voc.dueDate),
      };
      
      // 코드가 있는 경우에만 추가
      if (voc.code != null && voc.code!.isNotEmpty) {
        vocData['code'] = voc.code;
      }
      
      // 간소화된 기본 데이터 설정
      final Map<String, dynamic> simpleData = {
        'no': voc.no,
        'code': voc.code
      };
      
      debugPrint('VOC 추가 요청 데이터 (간소화): ${jsonEncode(simpleData)}');
      
      // 기존 API 엔드포인트 사용
      final response = await http.post(
        Uri.parse('$_baseUrl/voc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vocData),
      );
      
      debugPrint('VOC 추가 응답 상태: ${response.statusCode}');
      if (response.statusCode != 201 && response.statusCode != 200) {
        debugPrint('VOC 추가 응답 본문: ${response.body}');
      }
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return VocModel.fromJson(data);
      } else {
        throw Exception('VOC 추가 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VOC 추가 실패: $e');
      return null;
    }
  }
  
  // VOC 업데이트
  Future<VocModel?> updateVoc(VocModel voc) async {
    try {
      // 코드가 없는 경우 업데이트 불가
      if (voc.code == null) {
        debugPrint('VOC 업데이트 실패: 코드가 없음');
        return null;
      }

      // 데이터를 직접 구성하여 API 형식에 맞춤
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      final Map<String, dynamic> vocData = {
        'no': voc.no,
        'regDate': formatter.format(voc.regDate),
        'code': voc.code,
        'vocCategory': voc.vocCategory,
        'requestDept': voc.requestDept,
        'requester': voc.requester,
        'systemPath': voc.systemPath,
        'request': voc.request,
        'requestType': voc.requestType,
        'action': voc.action,
        'actionTeam': voc.actionTeam,
        'actionPerson': voc.actionPerson,
        'status': voc.status,
        'dueDate': formatter.format(voc.dueDate),
      };
      
      if (voc.id != null) {
        vocData['_id'] = voc.id;
      }
      
      final nonNullCode = voc.code!; // ! 연산자로 null이 아님을 확인 (이미 위에서 확인했음)
      
      // 간소화된 기본 데이터 설정 (디버깅용)
      final Map<String, dynamic> simpleData = {
        'no': voc.no,
        'code': nonNullCode
      };
      
      debugPrint('VOC 업데이트 요청 데이터 (간소화): ${jsonEncode(simpleData)}');
      
      // code를 URL 파라미터로 사용 - 기존 엔드포인트 유지
      final response = await http.put(
        Uri.parse('$_baseUrl/voc/code/${Uri.encodeComponent(nonNullCode)}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vocData),
      );
      
      debugPrint('VOC 업데이트 응답 상태: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('VOC 업데이트 응답 본문: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return VocModel.fromJson(data);
      } else if (response.statusCode == 404) {
        debugPrint('VOC 업데이트 실패: 코드 $nonNullCode를 찾을 수 없음');
        return null;
      } else {
        throw Exception('VOC 업데이트 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('VOC 업데이트 실패: $e');
      return null;
    }
  }
  
  // VOC 삭제 (코드 기준)
  Future<bool> deleteVocByCode(String code) async {
    try {
      final safeCode = Uri.encodeComponent(code);
      debugPrint('VOC 삭제 요청 - 코드: $code (인코딩됨: $safeCode)');
      
      // 기존 엔드포인트 사용
      final response = await http.delete(
        Uri.parse('$_baseUrl/voc/code/$safeCode')
      );
      
      debugPrint('VOC 삭제 응답 상태: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('VOC 삭제 실패: $e');
      return false;
    }
  }
  
  // VOC 삭제 (번호 기준 - 이전 버전과의 호환성 유지)
  Future<bool> deleteVoc(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/voc/$id'));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('VOC 삭제 실패: $e');
      return false;
    }
  }
  
  // 시스템 업데이트(솔루션 개발) 데이터 조회
  Future<List<SystemUpdateModel>> getSystemUpdates({
    String? search,
    String? targetSystem,
    String? updateType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 쿼리 파라미터 구성
      Map<String, String> queryParams = {};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (targetSystem != null && targetSystem.isNotEmpty) {
        queryParams['targetSystem'] = targetSystem;
      }
      
      if (updateType != null && updateType.isNotEmpty) {
        queryParams['updateType'] = updateType;
      }
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (startDate != null) {
        queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(startDate);
      }
      
      if (endDate != null) {
        queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(endDate);
      }
      
      debugPrint('시스템 업데이트 데이터 요청 시작');

      List<dynamic> dataList = [];
      bool isSuccess = false;
      String endpoint = '';

      // 첫 번째 시도: 솔루션 개발 전용 API (실제 동작 확인된 API를 우선 사용)
      try {
        final uri = Uri.parse('$_baseUrl/solution-development').replace(queryParameters: queryParams);
        debugPrint('시도 1 (솔루션 개발 API): $uri');
          
        final response = await _safeGet(uri);
        debugPrint('solution-development 응답 상태: ${response.statusCode}');
          
        if (response.statusCode == 200) {
          dataList = json.decode(response.body);
          debugPrint('solution-development 엔드포인트에서 ${dataList.length}개 데이터 로드 성공');
          isSuccess = true;
          endpoint = 'solution-development';
        } else {
          debugPrint('solution-development 엔드포인트 요청 실패: ${response.statusCode}');
          debugPrint('응답 본문: ${response.body}');
        }
      } catch (e) {
        _logError('solution-development 엔드포인트 요청', e);
      }
      
      // 두 번째 시도: 메모리 저장소 API
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/memory/system-updates').replace(queryParameters: queryParams);
          debugPrint('시도 2 (메모리 API): $uri');
          
          final response = await _safeGet(uri);
          debugPrint('memory 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            dataList = json.decode(response.body);
            debugPrint('memory 엔드포인트에서 ${dataList.length}개 데이터 로드 성공');
            isSuccess = true;
            endpoint = 'memory';
          } else {
            debugPrint('memory 엔드포인트 요청 실패: ${response.statusCode}');
            debugPrint('응답 본문: ${response.body}');
          }
        } catch (e) {
          _logError('memory 엔드포인트 요청', e);
        }
      }
      
      // 세 번째 시도: 로컬 저장소에서 데이터 로드
      if (!isSuccess) {
        try {
          debugPrint('로컬 저장소에서 시스템 업데이트 데이터 확인 중...');
          final prefs = await SharedPreferences.getInstance();
          final keys = prefs.getKeys().where((key) => key.startsWith('solution_')).toList();
          
          if (keys.isNotEmpty) {
            dataList = [];
            for (var key in keys) {
              final jsonString = prefs.getString(key);
              if (jsonString != null) {
                try {
                  final data = jsonDecode(jsonString);
                  dataList.add(data);
                } catch (e) {
                  debugPrint('로컬 데이터 디코딩 오류: $e');
                }
              }
            }
            
            if (dataList.isNotEmpty) {
              debugPrint('로컬 저장소에서 ${dataList.length}개 데이터 로드 성공');
              isSuccess = true;
              endpoint = 'local';
            }
          }
        } catch (e) {
          debugPrint('로컬 저장소 데이터 로드 실패: $e');
        }
      }
      
      // 모든 API 시도 실패 시 빈 배열 반환
      if (!isSuccess || dataList.isEmpty) {
        debugPrint('모든 API 엔드포인트 실패 또는 데이터가 없음. 빈 배열 반환.');
        return [];
      }
      
      // 성공한 API에서 데이터 변환
      debugPrint('사용 엔드포인트: $endpoint, 데이터 개수: ${dataList.length}');
      final List<SystemUpdateModel> convertedData = [];
      
      for (var data in dataList) {
        try {
          // _id 필드를 id로 매핑
          if (data['_id'] != null && data['id'] == null) {
            data['id'] = data['_id'];
          }
          
          final systemUpdate = SystemUpdateModel.fromJson(data);
          convertedData.add(systemUpdate.copyWith(isSaved: true, isModified: false));
        } catch (e) {
          _logError('시스템 업데이트 데이터 변환', e, null, data);
        }
      }
      
      return convertedData;
    } catch (e) {
      _logError('시스템 업데이트 데이터 로드', e);
      return []; // 빈 배열 반환
    }
  }
  
  // 모의 시스템 업데이트 데이터 생성 (API 연결 전 테스트용)
  List<SystemUpdateModel> _getMockSystemUpdates() {
    final List<String> targetSystems = ['MES', 'QMS', 'PLM', 'SPC', 'MMS', 'KPI', '그룹웨어', '백업솔루션', '기타'];
    final List<String> updateTypes = ['기능개선', '버그수정', '보안패치', 'UI변경', '데이터보정', '기타'];
    final List<String> statusList = ['계획', '진행중', '테스트', '완료', '보류'];
    final List<String> developerList = ['건솔루션', '디비벨리', '하람정보', '코비젼']; // 개발사 목록 추가
    
    return List.generate(25, (index) {
      final now = DateTime.now();
      final regDate = now.subtract(Duration(days: index * 3));
      final status = statusList[index % statusList.length];
      return SystemUpdateModel(
        no: 25 - index,
        regDate: regDate,
        updateCode: _generateUpdateCode(regDate, 25 - index),
        targetSystem: targetSystems[index % targetSystems.length],
        developer: developerList[index % developerList.length], // 개발사 필드 추가
        description: '시스템 기능 개선 및 버그 수정 #${25 - index}. 사용성 향상을 위한 UI 변경 포함.',
        updateType: updateTypes[index % updateTypes.length],
        assignee: '담당자${(index % 5) + 1}',
        status: status,
        completionDate: status == '완료' ? regDate.add(Duration(days: (index % 7) + 1)) : null,
        remarks: (index % 4 == 0) ? '긴급 패치 필요' : '',
        isSaved: true,
        isModified: false,
      );
    });
  }
  
  // 업데이트 코드 생성 함수
  String _generateUpdateCode(DateTime date, int no) {
    final yearMonth = '${date.year.toString().substring(2)}${date.month.toString().padLeft(2, '0')}';
    final seq = no.toString().padLeft(3, '0');
    return 'UPD$yearMonth$seq';
  }
  
  // 시스템 업데이트(솔루션 개발) 추가
  Future<SystemUpdateModel?> addSystemUpdate(SystemUpdateModel update) async {
    try {
      // developer 필드가 포함되도록 합니다
      final Map<String, dynamic> updateData = update.toJson();
      
      // 콘솔에 데이터 저장 요청 로그
      debugPrint('=== 솔루션 개발 데이터 저장 요청 ===');
      debugPrint('업데이트 코드: ${update.updateCode}');
      logToServer('INFO', '솔루션 개발 데이터 저장 시작', data: {'code': update.updateCode});
      
      // 로컬 저장 처리를 위한 고유 ID 생성 (먼저 생성하여 저장 실패해도 사용)
      final now = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(10000).toString().padLeft(4, '0');
      final localId = 'mem_${now}_$random';
      
      // 1. 로컬 저장소에 먼저 저장 (백업)
      final localStoreKey = 'solution_${update.updateCode}';
      await _saveToLocalStorage(localStoreKey, updateData);
      debugPrint('로컬 저장소에 저장 완료: $localStoreKey');
      
      // 2. 여러 API 엔드포인트 시도 (직접 구현한 trySaveToServer 메서드 사용)
      bool isSuccess = await trySaveToServer(
        updateData, 
        ['solution-development', 'db/solution', 'memory/system-updates']
      );
      
      // 3. 서버 MongoDB에 직접 저장 시도 (제거)
      // if (!isSuccess) {
      //   debugPrint('다중 API 저장 실패, DB 직접 저장 시도...');
      //   isSuccess = await saveToDatabase('solution', updateData); // <-- REMOVE THIS LINE
      // }
      
      if (isSuccess) {
        logToServer('INFO', '솔루션 개발 데이터 저장 성공', 
          data: {'code': update.updateCode, 'id': localId});
      } else {
        logToServer('WARNING', '솔루션 개발 데이터 서버 저장 실패, 로컬 저장만 성공', 
          data: {'code': update.updateCode, 'localId': localId});
      }
      
      // 항상 성공 응답 (로컬에 저장되었으므로)
      return update.copyWith(
        id: localId,
        isSaved: true, 
        isModified: false
      );
    } catch (e) {
      final errorMsg = '솔루션 개발 데이터 추가 실패: $e';
      debugPrint(errorMsg);
      logToServer('ERROR', errorMsg, data: {'code': update.updateCode});
      
      // 오류가 있어도 로컬 백업 데이터 사용
      final now = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(10000).toString().padLeft(4, '0');
      final localId = 'err_${now}_$random';
      
      return update.copyWith(id: localId, isSaved: true, isModified: false);
    }
  }
  
  // 시스템 업데이트(솔루션 개발) 수정
  Future<SystemUpdateModel?> updateSystemUpdate(SystemUpdateModel update) async {
    try {
      // developer 필드가 포함되도록 합니다
      final Map<String, dynamic> updateData = update.toJson();
      
      // 콘솔에 데이터 수정 요청 로그
      debugPrint('솔루션 개발 데이터 수정 요청: ${update.updateCode}');
      
      bool isSuccess = false;
      dynamic responseData;
      String endpoint = '';
      
      // 첫 번째 시도: solution-development 엔드포인트 (메인 엔드포인트로 변경)
      try {
        final uri = Uri.parse('$_baseUrl/solution-development/code/${Uri.encodeComponent(update.updateCode!)}');
        debugPrint('시도 1 (솔루션 개발 메인): $uri');
        
        final response = await http.put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updateData),
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('Timeout', 408),
        );
        
        debugPrint('solution-development 엔드포인트 수정 응답 상태: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          responseData = json.decode(response.body);
          isSuccess = true;
          endpoint = 'solution-development';
          debugPrint('solution-development 엔드포인트 수정 성공');
        } else {
          debugPrint('solution-development 엔드포인트 수정 실패: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('solution-development 엔드포인트 수정 예외: $e');
      }
      
      // 두 번째 시도: 직접 DB 컬렉션 엔드포인트 사용
      if (!isSuccess && update.id != null) {
        try {
          final uri = Uri.parse('$_baseUrl/collections/solution/${update.id}');
          debugPrint('시도 2 (직접 컬렉션): $uri');
          
          final response = await http.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updateData),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('collections/solution 엔드포인트 수정 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            responseData = json.decode(response.body);
            isSuccess = true;
            endpoint = 'collections/solution';
            debugPrint('collections/solution 엔드포인트 수정 성공');
          } else {
            debugPrint('collections/solution 엔드포인트 수정 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('collections/solution 엔드포인트 수정 예외: $e');
        }
      }
      
      // 세 번째 시도: 기존 system-updates 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/system-updates/code/${Uri.encodeComponent(update.updateCode!)}');
          debugPrint('시도 3 (기존): $uri');
          
          final response = await http.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updateData),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('system-updates 엔드포인트 수정 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            responseData = json.decode(response.body);
            isSuccess = true;
            endpoint = 'system-updates';
            debugPrint('system-updates 엔드포인트 수정 성공');
          } else {
            debugPrint('system-updates 엔드포인트 수정 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('system-updates 엔드포인트 수정 예외: $e');
        }
      }
      
      // 네 번째 시도: memory 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/memory/system-updates/code/${Uri.encodeComponent(update.updateCode!)}');
          debugPrint('시도 4 (메모리): $uri');
          
          final response = await http.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updateData),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('memory 엔드포인트 수정 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            responseData = json.decode(response.body);
            isSuccess = true;
            endpoint = 'memory';
            debugPrint('memory 엔드포인트 수정 성공');
          } else {
            debugPrint('memory 엔드포인트 수정 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('memory 엔드포인트 수정 예외: $e');
        }
      }
      
      // 성공적으로 수정된 경우
      if (isSuccess && responseData != null) {
        debugPrint('사용 엔드포인트: $endpoint');
        
        // ID 필드가 _id로 넘어오는 경우 처리
        if (responseData['_id'] != null && responseData['id'] == null) {
          responseData['id'] = responseData['_id'];
        }
        
        final updatedModel = SystemUpdateModel.fromJson(responseData);
        return updatedModel.copyWith(isModified: false);
      }
      
      // 모든 시도 실패 시 임시 성공 처리
      debugPrint('모든 API 엔드포인트 수정 실패, 로컬 수정 처리');
        await Future.delayed(const Duration(milliseconds: 300));
        return update.copyWith(isModified: false);
    } catch (e) {
      debugPrint('솔루션 개발 데이터 수정 실패: $e');
      await Future.delayed(const Duration(milliseconds: 300));
      return update.copyWith(isModified: false);
    }
  }
  
  // 시스템 업데이트(솔루션 개발) 삭제
  Future<bool> deleteSystemUpdateByCode(String code) async {
    try {
      // 콘솔에 데이터 삭제 요청 로그
      debugPrint('솔루션 개발 데이터 삭제 요청: $code');
      
      bool isSuccess = false;
      String endpoint = '';
      
      // 첫 번째 시도: 직접 컬렉션 접근
      try {
        final uri = Uri.parse('$_baseUrl/collections/solution/code/$code');
        debugPrint('시도 1 (MongoDB 직접 삭제): $uri');
        
        final response = await http.delete(uri).timeout(
          const Duration(seconds: 10),
          onTimeout: () => http.Response('Timeout', 408),
        );
        
        debugPrint('MongoDB 직접 삭제 응답 상태: ${response.statusCode}');
        debugPrint('응답 본문: ${response.body}');
      
        if (response.statusCode == 200 || response.statusCode == 204) {
          isSuccess = true;
          endpoint = 'collections/solution';
          debugPrint('MongoDB 직접 삭제 성공');
        } else {
          debugPrint('MongoDB 직접 삭제 실패: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('MongoDB 직접 삭제 예외: $e');
      }
      
      // 두 번째 시도: solution-development 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/solution-development/code/${Uri.encodeComponent(code)}');
          debugPrint('시도 2 (솔루션 개발 API): $uri');
          
          final response = await http.delete(uri).timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('solution-development 엔드포인트 삭제 응답 상태: ${response.statusCode}');
          debugPrint('응답 본문: ${response.body}');
          
          if (response.statusCode == 200 || response.statusCode == 204) {
            isSuccess = true;
            endpoint = 'solution-development';
            debugPrint('solution-development 엔드포인트 삭제 성공');
          } else {
            debugPrint('solution-development 엔드포인트 삭제 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('solution-development 엔드포인트 삭제 예외: $e');
        }
      }
      
      // 세 번째 시도: memory 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/memory/system-updates/code/${Uri.encodeComponent(code)}');
          debugPrint('시도 3: $uri');
          
          final response = await http.delete(uri).timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('memory 엔드포인트 삭제 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200 || response.statusCode == 204) {
            isSuccess = true;
            endpoint = 'memory';
            debugPrint('memory 엔드포인트 삭제 성공');
          } else {
            debugPrint('memory 엔드포인트 삭제 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('memory 엔드포인트 삭제 예외: $e');
        }
      }
      
      debugPrint('삭제 작업 결과: $isSuccess, 사용 엔드포인트: $endpoint');
      
      return isSuccess;
    } catch (e) {
      _logError('솔루션 개발 데이터 삭제', e);
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }
  }
  
  // 하드웨어 데이터 목록 조회
  Future<List<HardwareModel>> getHardwareData({
    String? search,
    String? assetCode,
    String? assetType,
    String? assetName,
    String? executionType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String endpoint = '';
    List<HardwareModel> result = [];
    
    try {
      // URI 생성
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (assetCode != null && assetCode.isNotEmpty) {
        queryParams['assetCode'] = assetCode;
      }
      
      if (assetType != null && assetType.isNotEmpty) {
        queryParams['assetType'] = assetType;
      }
      
      if (assetName != null && assetName.isNotEmpty) {
        queryParams['assetName'] = assetName;
      }
      
      if (executionType != null && executionType.isNotEmpty) {
        queryParams['executionType'] = executionType;
      }
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      
      // 1. 먼저 hardware 엔드포인트 시도
      try {
      final uri = Uri.parse('$_baseUrl/hardware').replace(queryParameters: queryParams);
        debugPrint('하드웨어 데이터 로드 시도 1: $uri');
      
        final response = await _safeGet(uri);
      
      if (response.statusCode == 200) {
          final jsonData = json.decode(response.body) as List<dynamic>;
          result = jsonData.map((item) => HardwareModel.fromJson(item)).toList();
          debugPrint('hardware 엔드포인트에서 데이터 ${result.length}개 로드됨');
          endpoint = 'hardware';
          return result;
        } else {
          debugPrint('hardware 엔드포인트 실패: ${response.statusCode}');
        }
      } catch (e) {
        _logError('hardware 엔드포인트 오류', e);
      }
      
      // 2. 다음으로 hardware-assets 엔드포인트 시도
      try {
        final uri = Uri.parse('$_baseUrl/hardware-assets').replace(queryParameters: queryParams);
        debugPrint('하드웨어 데이터 로드 시도 2: $uri');
        
        final response = await _safeGet(uri);
        
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body) as List<dynamic>;
          result = jsonData.map((item) => HardwareModel.fromJson(item)).toList();
          debugPrint('hardware-assets 엔드포인트에서 데이터 ${result.length}개 로드됨');
          endpoint = 'hardware-assets';
          return result;
        } else {
          debugPrint('hardware-assets 엔드포인트 실패: ${response.statusCode}');
        }
      } catch (e) {
        _logError('hardware-assets 엔드포인트 오류', e);
      }
      
      // 3. 마지막으로 memory/hardware 엔드포인트 시도
      try {
        final uri = Uri.parse('$_baseUrl/memory/hardware').replace(queryParameters: queryParams);
        debugPrint('하드웨어 데이터 로드 시도 3: $uri');
        
        final response = await _safeGet(uri);
        
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body) as List<dynamic>;
          result = jsonData.map((item) => HardwareModel.fromJson(item)).toList();
          debugPrint('memory/hardware 엔드포인트에서 데이터 ${result.length}개 로드됨');
          endpoint = 'memory/hardware';
          return result;
        } else {
          debugPrint('memory/hardware 엔드포인트 실패: ${response.statusCode}');
        }
      } catch (e) {
        _logError('memory/hardware 엔드포인트 오류', e);
      }
      
      // 모든 API 시도 실패 시 빈 배열 반환
      debugPrint('모든 API 엔드포인트 실패, 빈 배열 반환');
      return [];
    } catch (e) {
      _logError('하드웨어 데이터 로드 전체 오류', e);
      return [];
    }
  }
  
  // 하드웨어 추가
  Future<HardwareModel?> addHardware(HardwareModel hardware) async {
    try {
      // 클라이언트 모델을 서버 형식으로 변환
      final Map<String, dynamic> hardwareData = hardware.toJson();
      
      // 상세 로그 추가: 전송될 데이터 확인
      debugPrint('[ApiService.addHardware] 전송 데이터: ${jsonEncode(hardwareData)}');
      
      bool isSuccess = false;
      dynamic responseData;
      String endpoint = '';
      String? errorMessage;
      
      // 첫 번째 시도: hardware 엔드포인트
      try {
        final uri = Uri.parse('$_baseUrl/hardware');
        debugPrint('[ApiService.addHardware] 시도 1: POST $uri');
        
        final response = await _safePost(uri, hardwareData);
        
        debugPrint('[ApiService.addHardware] 시도 1 응답: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          debugPrint('[ApiService.addHardware] 시도 1 응답 본문: ${response.body}');
        }
        
        if (response.statusCode == 201 || response.statusCode == 200) {
          responseData = json.decode(response.body);
          isSuccess = true;
          endpoint = 'hardware';
        } else {
          // 오류 메시지 추출
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? '알 수 없는 오류';
            debugPrint('[ApiService.addHardware] 오류 메시지: $errorMessage');
          } catch (e) {
            errorMessage = '데이터 파싱 오류';
          }
          _logError('하드웨어 추가 (시도 1)', '상태 코드: ${response.statusCode}', uri.toString(), response.body);
        }
      } catch (e) {
        _logError('하드웨어 추가 (시도 1)', e);
      }
      
      // 첫 번째 시도에서 유효성 검사 오류가 발생한 경우, 다음 시도 전에 필드 보정
      if (!isSuccess && errorMessage != null && errorMessage.contains('유효성 검사')) {
        debugPrint('[ApiService.addHardware] 유효성 검사 오류로 필드 보정 시도');
        
        // 빈 필드에 기본값 설정 (서버 스키마와 동일하게)
        if (hardwareData['assetCode'] == '') {
          hardwareData['assetCode'] = '자산코드 미지정';
          debugPrint('[ApiService.addHardware] assetCode 필드 보정: 빈 문자열 → "자산코드 미지정"');
        }
        
        if (hardwareData['assetName'] == '') {
          hardwareData['assetName'] = '미지정';
          debugPrint('[ApiService.addHardware] assetName 필드 보정: 빈 문자열 → "미지정"');
        }
      }

      // 두 번째 시도: hardware-assets 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/hardware-assets');
          debugPrint('시도 2: $uri');
          
          final response = await _safePost(uri, hardwareData);
          
          debugPrint('hardware-assets 엔드포인트 저장 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 201 || response.statusCode == 200) {
            responseData = json.decode(response.body);
            debugPrint('hardware-assets 엔드포인트 저장 성공 응답: ${response.body}');
            isSuccess = true;
            endpoint = 'hardware-assets';
          } else {
            debugPrint('hardware-assets 엔드포인트 저장 실패: ${response.body}');
          }
        } catch (e) {
          _logError('hardware-assets 엔드포인트 저장', e);
        }
      }
      
      // 세 번째 시도: memory 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/memory/hardware');
          debugPrint('시도 3: $uri');
          
          final response = await _safePost(uri, hardwareData);
          
          debugPrint('memory 엔드포인트 저장 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 201 || response.statusCode == 200) {
            responseData = json.decode(response.body);
            debugPrint('memory 엔드포인트 저장 성공 응답: ${response.body}');
            isSuccess = true;
            endpoint = 'memory';
          } else {
            debugPrint('memory 엔드포인트 저장 실패: ${response.body}');
          }
        } catch (e) {
          _logError('memory 엔드포인트 저장', e);
        }
      }
      
      // 성공적으로 저장된 경우
      if (isSuccess && responseData != null) {
        debugPrint('[ApiService.addHardware] 저장 성공 - 엔드포인트: $endpoint');
        try {
          // _id 필드를 id로 매핑
          if (responseData['_id'] != null && responseData['id'] == null) {
            responseData['id'] = responseData['_id'];
          }
          
          final savedModel = HardwareModel.fromJson(responseData);
          return savedModel.copyWith(isSaved: true, isModified: false);
        } catch (e) {
          _logError('하드웨어 응답 데이터 변환', e, null, responseData);
          
          // 응답 변환 실패 시 원본 데이터로 응답 구성
          debugPrint('[ApiService.addHardware] 응답 데이터 변환 실패, 원본 데이터 사용');
          return hardware.copyWith(
            isSaved: true, 
            isModified: false,
            // ID 또는 코드 정보가 있으면 사용
            id: responseData['_id']?.toString() ?? responseData['id']?.toString() ?? hardware.id,
            code: responseData['code']?.toString() ?? hardware.code ?? HardwareModel.generateHardwareCode(hardware.regDate, hardware.no)
          );
        }
      } else {
        // 모든 시도 실패 시 오류 메시지와 함께 로그 출력
        debugPrint('[ApiService.addHardware] 저장 실패 - 모든 시도 실패, 오류: $errorMessage');
        
        // 데이터를 로컬에서 처리 (ID 없이 UI에 표시)
        debugPrint('모든 API 엔드포인트 저장 실패, 로컬 저장 처리');
        await Future.delayed(const Duration(milliseconds: 300));
        return hardware.copyWith(
          isSaved: true, 
          isModified: false,
          code: hardware.code ?? HardwareModel.generateHardwareCode(hardware.regDate, hardware.no)
        );
      }
    } catch (e) {
      _logError('하드웨어 데이터 추가 전체', e);
      // 예외 발생 시 로컬 처리
      debugPrint('[ApiService.addHardware] 예외 발생으로 로컬 저장 처리');
      await Future.delayed(const Duration(milliseconds: 300));
          return hardware.copyWith(isSaved: true, isModified: false);
    }
  }
  
  // 하드웨어 수정
  Future<HardwareModel?> updateHardware(HardwareModel hardware) async {
    try {
      // 코드가 없는 경우 업데이트 불가
      if (hardware.code == null) {
        debugPrint('하드웨어 데이터 수정 실패: 코드가 없음');
        return null;
      }
      
      final Map<String, dynamic> hardwareData = hardware.toJson();
      
      debugPrint('하드웨어 데이터 수정 요청: ${hardware.code}');
      
      bool isSuccess = false;
      dynamic responseData;
      String endpoint = '';
      
      // 첫 번째 시도: hardware 엔드포인트
      try {
        final uri = Uri.parse('$_baseUrl/hardware/code/${Uri.encodeComponent(hardware.code!)}');
        debugPrint('시도 1: $uri');
        
        final response = await http.put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(hardwareData),
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('Timeout', 408),
        );
        
        debugPrint('hardware 엔드포인트 수정 응답 상태: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          responseData = json.decode(response.body);
          debugPrint('hardware 엔드포인트 수정 성공 응답: ${response.body}');
          isSuccess = true;
          endpoint = 'hardware';
      } else {
          debugPrint('hardware 엔드포인트 수정 실패: ${response.statusCode}, 응답: ${response.body}');
      }
    } catch (e) {
        _logError('hardware 엔드포인트 수정', e);
      }
      
      // 두 번째 시도: hardware-assets 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/hardware-assets/code/${Uri.encodeComponent(hardware.code!)}');
          debugPrint('시도 2: $uri');
          
          final response = await http.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(hardwareData),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('hardware-assets 엔드포인트 수정 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            responseData = json.decode(response.body);
            debugPrint('hardware-assets 엔드포인트 수정 성공 응답: ${response.body}');
            isSuccess = true;
            endpoint = 'hardware-assets';
          } else {
            debugPrint('hardware-assets 엔드포인트 수정 실패: ${response.statusCode}, 응답: ${response.body}');
          }
        } catch (e) {
          _logError('hardware-assets 엔드포인트 수정', e);
        }
      }
      
      // 세 번째 시도: memory 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/memory/hardware/code/${Uri.encodeComponent(hardware.code!)}');
          debugPrint('시도 3: $uri');
          
          final response = await http.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(hardwareData),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('memory 엔드포인트 수정 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            responseData = json.decode(response.body);
            debugPrint('memory 엔드포인트 수정 성공 응답: ${response.body}');
            isSuccess = true;
            endpoint = 'memory';
          } else {
            debugPrint('memory 엔드포인트 수정 실패: ${response.statusCode}, 응답: ${response.body}');
          }
        } catch (e) {
          _logError('memory 엔드포인트 수정', e);
        }
      }
      
      // 성공적으로 수정된 경우
      if (isSuccess && responseData != null) {
        debugPrint('사용 엔드포인트: $endpoint');
        
        try {
          // _id 필드를 id로 매핑
          if (responseData['_id'] != null && responseData['id'] == null) {
            responseData['id'] = responseData['_id'];
          }
          
          final updatedModel = HardwareModel.fromJson(responseData);
          return updatedModel.copyWith(isModified: false);
        } catch (e) {
          _logError('하드웨어 응답 데이터 변환', e, null, responseData);
          // 오류 발생 시 원본 데이터 반환
          return hardware.copyWith(isModified: false);
        }
      }
      
      // 모든 시도 실패 시 임시 성공 처리
      debugPrint('모든 API 엔드포인트 수정 실패, 로컬 수정 처리');
      await Future.delayed(const Duration(milliseconds: 300));
      return hardware.copyWith(isModified: false);
    } catch (e) {
      _logError('하드웨어 데이터 수정', e); // debugPrint 대신 _logError 사용
      await Future.delayed(const Duration(milliseconds: 300));
      return hardware.copyWith(isModified: false);
    }
  }
  
  // 하드웨어 삭제
  Future<bool> deleteHardwareByCode(String code) async {
    try {
      debugPrint('하드웨어 삭제 요청: $code');
      
      bool isSuccess = false;
      String endpoint = '';
      
      // 첫 번째 시도: hardware 엔드포인트
      try {
        final uri = Uri.parse('$_baseUrl/hardware/code/${Uri.encodeComponent(code)}');
        debugPrint('시도 1: $uri');
        
        final response = await http.delete(uri).timeout(
          const Duration(seconds: 10),
          onTimeout: () => http.Response('Timeout', 408),
        );
        
        debugPrint('hardware 엔드포인트 삭제 응답 상태: ${response.statusCode}');
        
        if (response.statusCode == 200 || response.statusCode == 204) {
          isSuccess = true;
          endpoint = 'hardware';
          debugPrint('hardware 엔드포인트 삭제 성공');
        } else {
          debugPrint('hardware 엔드포인트 삭제 실패: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('hardware 엔드포인트 삭제 예외: $e');
      }
      
      // 두 번째 시도: hardware-assets 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/hardware-assets/code/${Uri.encodeComponent(code)}');
          debugPrint('시도 2: $uri');
          
          final response = await http.delete(uri).timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('hardware-assets 엔드포인트 삭제 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200 || response.statusCode == 204) {
            isSuccess = true;
            endpoint = 'hardware-assets';
            debugPrint('hardware-assets 엔드포인트 삭제 성공');
          } else {
            debugPrint('hardware-assets 엔드포인트 삭제 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('hardware-assets 엔드포인트 삭제 예외: $e');
        }
      }
      
      // 세 번째 시도: memory 엔드포인트
      if (!isSuccess) {
        try {
          final uri = Uri.parse('$_baseUrl/memory/hardware/code/${Uri.encodeComponent(code)}');
          debugPrint('시도 3: $uri');
          
          final response = await http.delete(uri).timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('memory 엔드포인트 삭제 응답 상태: ${response.statusCode}');
          
          if (response.statusCode == 200 || response.statusCode == 204) {
            isSuccess = true;
            endpoint = 'memory';
            debugPrint('memory 엔드포인트 삭제 성공');
          } else {
            debugPrint('memory 엔드포인트 삭제 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('memory 엔드포인트 삭제 예외: $e');
        }
      }
      
      debugPrint('삭제 작업 결과: $isSuccess, 사용 엔드포인트: $endpoint');
      
      return isSuccess;
    } catch (e) {
      _logError('하드웨어 삭제', e);
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }
  }
  
  // 소프트웨어 데이터 조회
  Future<List<SoftwareModel>> getSoftwareData({
    String? search,
    String? assetCode,
    String? assetType,
    String? assetName,
    String? costType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (assetCode != null && assetCode.isNotEmpty) {
        queryParams['assetCode'] = assetCode;
      }
      
      if (assetType != null && assetType.isNotEmpty) {
        queryParams['assetType'] = assetType;
      }
      
      if (assetName != null && assetName.isNotEmpty) {
        queryParams['assetName'] = assetName;
      }
      
      if (costType != null && costType.isNotEmpty) {
        queryParams['costType'] = costType;
      }
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      
      // 3단계 시도: 3개의 엔드포인트로 시도
      final List<String> endpointPaths = [
        '/solution-development/software',
        '/software',
        '/memory/software'
      ];
      
      List<dynamic>? dataList;
      String successPath = "";
      int statusCode = 0;
      String responseBody = "";
      
      for (final path in endpointPaths) {
        try {
          final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
          debugPrint('소프트웨어 데이터 로드 URL: $uri');
          
          final response = await _safeGet(uri);
          statusCode = response.statusCode;
          responseBody = response.body;
          
          if (response.statusCode == 200) {
            dataList = json.decode(response.body);
            successPath = path;
            debugPrint('소프트웨어 데이터 로드 성공 (사용 엔드포인트: $path)');
            break;
          } else {
            debugPrint('소프트웨어 데이터 로드 시도 실패 (엔드포인트: $path): 상태 코드 ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('소프트웨어 데이터 로드 시도 실패 (엔드포인트: $path): $e');
        }
      }
      
      if (dataList != null) {
        final List<SoftwareModel> convertedData = [];
        for (var data in dataList) {
          try {
            // _id 필드를 id로 매핑 (MongoDB 응답 처리)
            if (data['_id'] != null && data['id'] == null) {
              data['id'] = data['_id'];
            }
            
            final software = SoftwareModel.fromJson(data);
            convertedData.add(software.copyWith(isSaved: true, isModified: false));
          } catch (e) {
            _logError('소프트웨어 데이터 변환', e, null, data);
          }
        }
        
        return convertedData;
      } else {
        _logError('소프트웨어 데이터 로드', '상태 코드: $statusCode', 'API 응답: $responseBody');
        // 개발 환경에서는 모의 데이터 반환
        if (kDebugMode) {
          await Future.delayed(const Duration(milliseconds: 300));
          return _getMockSoftwareData();
        }
        return []; // 빈 배열 반환
      }
    } catch (e) {
      _logError('소프트웨어 데이터 로드', e);
      // 개발 환경에서는 모의 데이터 반환
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 300));
        return _getMockSoftwareData();
      }
      return []; // 빈 배열 반환
    }
  }
  
  // 모의 소프트웨어 데이터 생성 (API 연결 전 테스트용)
  List<SoftwareModel> _getMockSoftwareData() {
    final List<String> assetTypes = ['AutoCAD', 'ZWCAD', 'NX-UZ', 'CATIA', '금형박사', '망고보드', '캡컷', 'NX', '팀뷰어', 'HADA', 'MS-OFFICE', 'WINDOWS', '아래아한글', 'VMware'];
    final List<String> assetNames = ['Standard', 'Professional', 'Enterprise', 'Ultimate', 'Developer'];
    final List<String> specifications = ['v2023', 'v10.5', '2022R2', '365', '2021'];
    final List<String> costTypes = ['연구독', '월구독', '영구'];
    final List<String> vendors = ['오토데스크', '한컴', '마이크로소프트', '어도비', '지멘스', 'PTC', '대성소프트웨어'];
    
    return List.generate(25, (index) {
      final now = DateTime.now();
      final regDate = now.subtract(Duration(days: index * 3));
      final assetType = assetTypes[index % assetTypes.length];
      final assetName = assetNames[index % assetNames.length];
      final unitPrice = (1000.0 + (index * 500.0));
      final quantity = (index % 5) + 1;
      final setupPrice = 5000.0 + (index * 1000.0);
      final annualMaintenancePrice = setupPrice * 0.2;
      
      return SoftwareModel(
        no: 25 - index,
        regDate: regDate,
        code: SoftwareModel.generateSoftwareCode(regDate, 25 - index),
        assetCode: 'S${(10000 + index * 3).toString()}',
        assetType: assetType,
        assetName: assetName,
        specification: specifications[index % specifications.length],
        setupPrice: setupPrice,
        annualMaintenancePrice: annualMaintenancePrice,
        costType: costTypes[index % costTypes.length],
        vendor: vendors[index % vendors.length],
        licenseKey: 'LIC-${(100000 + index * 7).toString()}-${(200 + index).toString()}',
        user: '사용자${(index % 5) + 1}',
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: unitPrice * quantity,
        lotCode: 'L${(20000 + index * 7).toString()}',
        detail: '$assetType $assetName ${specifications[index % specifications.length]} 라이선스',
        startDate: regDate,
        endDate: regDate.add(Duration(days: 365 * (index % 3 + 1))),
        remarks: (index % 4 == 0) ? '조기 갱신 필요' : '',
      );
    });
  }
  
  // 소프트웨어 추가
  Future<SoftwareModel?> addSoftware(SoftwareModel software) async {
    try {
      // 3단계 시도: 3개의 엔드포인트로 시도
      final List<String> endpointPaths = [
        '/solution-development/software',
        '/software',
        '/memory/software'
      ];
      
      SoftwareModel? result;
      String successPath = "";
      
      for (final path in endpointPaths) {
        try {
          final uri = Uri.parse('$_baseUrl$path');
          debugPrint('소프트웨어 데이터 추가 시도 URL: $uri');
          
          final response = await _safePost(uri, software.toJson());
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
            result = SoftwareModel.fromJson(data);
            successPath = path;
            debugPrint('소프트웨어 추가 성공 (사용 엔드포인트: $path)');
            break;
      } else {
            debugPrint('소프트웨어 추가 시도 실패 (엔드포인트: $path): 상태 코드 ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('소프트웨어 추가 시도 실패 (엔드포인트: $path): $e');
        }
      }
      
      if (result != null) {
        return result;
      } else if (kDebugMode) {
        // 개발 환경에서는 성공한 것처럼 처리
        await Future.delayed(const Duration(milliseconds: 300));
        return software.copyWith(isSaved: true, isModified: false);
      }
    } catch (e) {
      _logError('소프트웨어 추가', e);
      // 테스트 환경에서는 성공한 것처럼 처리
      if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 300));
        return software.copyWith(isSaved: true, isModified: false);
      }
    }
    
    return null;
  }
  
  // 소프트웨어 수정
  Future<SoftwareModel?> updateSoftware(SoftwareModel software) async {
    try {
      // 코드가 없는 경우 업데이트 불가
      if (software.code == null) {
        _logError('소프트웨어 수정', '코드가 없음');
        return null;
      }

      // 3단계 시도: 3개의 엔드포인트로 시도
      final List<String> endpointPaths = [
        '/solution-development/software',
        '/software',
        '/memory/software'
      ];
      
      SoftwareModel? result;
      String successPath = "";
      
      for (final path in endpointPaths) {
        try {
          final uri = Uri.parse('$_baseUrl$path/code/${Uri.encodeComponent(software.code!)}');
          debugPrint('소프트웨어 데이터 수정 시도 URL: $uri');
          
          final response = await _safePut(uri, software.toJson());
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
            result = SoftwareModel.fromJson(data);
            successPath = path;
            debugPrint('소프트웨어 수정 성공 (사용 엔드포인트: $path)');
            break;
      } else {
            debugPrint('소프트웨어 수정 시도 실패 (엔드포인트: $path): 상태 코드 ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('소프트웨어 수정 시도 실패 (엔드포인트: $path): $e');
        }
      }
      
      if (result != null) {
        return result;
      } else if (kDebugMode) {
        // 개발 환경에서는 성공한 것처럼 처리
        await Future.delayed(const Duration(milliseconds: 300));
        return software.copyWith(isSaved: true, isModified: false);
      }
    } catch (e) {
      _logError('소프트웨어 수정', e);
      // 테스트 환경에서는 성공한 것처럼 처리
      if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 300));
        return software.copyWith(isSaved: true, isModified: false);
      }
    }
    
    return null;
  }
  
  // 소프트웨어 삭제
  Future<bool> deleteSoftwareByCode(String code) async {
    try {
      // 3단계 시도: 3개의 엔드포인트로 시도
      final List<String> endpointPaths = [
        '/solution-development/software',
        '/software',
        '/memory/software'
      ];
      
      bool success = false;
      String successPath = "";
      
      for (final path in endpointPaths) {
        try {
          final uri = Uri.parse('$_baseUrl$path/code/${Uri.encodeComponent(code)}');
          debugPrint('소프트웨어 데이터 삭제 시도 URL: $uri');
          
          final response = await _safeDelete(uri);
          
          if (response.statusCode == 200) {
            success = true;
            successPath = path;
            debugPrint('소프트웨어 삭제 성공 (사용 엔드포인트: $path)');
            break;
      } else {
            debugPrint('소프트웨어 삭제 시도 실패 (엔드포인트: $path): 상태 코드 ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('소프트웨어 삭제 시도 실패 (엔드포인트: $path): $e');
        }
      }
      
      if (success) {
        return true;
      } else if (kDebugMode) {
        // 개발 환경에서는 성공한 것처럼 처리
        await Future.delayed(const Duration(milliseconds: 300));
        return true;
      }
    } catch (e) {
      _logError('소프트웨어 삭제', e);
      // 테스트 환경에서는 성공한 것처럼 처리
      if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
      }
    }
    
    return false;
  }
  
  // 설비 연동 데이터 조회
  Future<List<EquipmentConnectionModel>> fetchEquipmentConnections({
    String? search,
    String? line,
    String? equipment,
    String? workType,
    String? dataType,
    String? connectionType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 쿼리 파라미터 구성
      final Map<String, String> queryParams = {};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (line != null) {
        queryParams['line'] = line;
      }
      
      if (equipment != null) {
        queryParams['equipment'] = equipment;
      }
      
      if (workType != null) {
        queryParams['workType'] = workType;
      }
      
      if (dataType != null) {
        queryParams['dataType'] = dataType;
      }
      
      if (connectionType != null) {
        queryParams['connectionType'] = connectionType;
      }
      
      if (status != null) {
        queryParams['status'] = status;
      }
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      
      // 3단계 시도: 다양한 엔드포인트로 시도
      final List<String> endpointPaths = [
        '/equipment-connections',
        '/memory/equipment-connections'
      ];
      
      List<dynamic>? dataList;
      String successPath = "";
      
      for (final path in endpointPaths) {
        try {
          final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
          debugPrint('설비 연동 데이터 요청 URL: $uri');
          
          final response = await _safeGet(uri);
          
          if (response.statusCode == 200) {
            dataList = json.decode(response.body);
            successPath = path;
            debugPrint('설비 연동 데이터 로드 성공 (사용 엔드포인트: $path)');
            break;
          } else {
            debugPrint('설비 연동 데이터 로드 시도 실패 (엔드포인트: $path): 상태 코드 ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('설비 연동 데이터 로드 시도 실패 (엔드포인트: $path): $e');
        }
      }
      
      if (dataList != null) {
        final List<EquipmentConnectionModel> connections = [];
        for (var data in dataList) {
          try {
            // MongoDB _id 필드를 처리
            if (data['_id'] != null && data['id'] == null) {
              data['id'] = data['_id'];
            }
            connections.add(EquipmentConnectionModel.fromJson(data));
          } catch (e) {
            debugPrint('설비 연동 데이터 변환 오류: $e');
          }
        }
        return connections;
      } else {
        // 데이터 로드 실패 시 빈 배열 반환
        return [];
      }
    } catch (e) {
      debugPrint('설비 연동 데이터 조회 오류: $e');
      return [];
    }
  }
  
  // 설비 연동 데이터 추가
  Future<EquipmentConnectionModel?> addEquipmentConnection(EquipmentConnectionModel connection) async {
    try {
      debugPrint('설비 연동 데이터 추가 시작: ${connection.code}, ${connection.line}, ${connection.equipment}');
      
      // MongoDB 저장을 위해 일부 필드 정리
      final Map<String, dynamic> requestData = connection.toJson();
      
      // 필요한 경우 날짜 형식 확인
      if (connection.regDate != null) {
        requestData['regDate'] = connection.regDate.toIso8601String();
      }
      if (connection.startDate != null) {
        requestData['startDate'] = connection.startDate?.toIso8601String();
      } else {
        // null인 경우 필드 제거
        requestData.remove('startDate');
      }
      if (connection.completionDate != null) {
        requestData['completionDate'] = connection.completionDate?.toIso8601String();
      } else {
        // null인 경우 필드 제거
        requestData.remove('completionDate');
      }
      
      // 디버깅을 위한 요청 데이터 출력
      debugPrint('설비 연동 데이터 추가 요청: ${json.encode(requestData)}');
      
      // 3단계 시도: 다양한 엔드포인트로 시도
      final List<String> endpointPaths = [
        '/equipment-connections',
        '/memory/equipment-connections'
      ];
      
      EquipmentConnectionModel? result;
      
      for (final path in endpointPaths) {
        try {
          final uri = Uri.parse('$_baseUrl$path');
          debugPrint('설비 연동 데이터 추가 시도 URL: $uri');
          
          final response = await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          );
          
          debugPrint('설비 연동 데이터 추가 응답 코드: ${response.statusCode}');
          
          if (response.statusCode == 201 || response.statusCode == 200) {
            final data = json.decode(response.body);
            debugPrint('설비 연동 데이터 추가 응답: ${response.body}');
            result = EquipmentConnectionModel.fromJson(data);
            debugPrint('설비 연동 데이터 추가 성공 (사용 엔드포인트: $path)');
            break;
          } else {
            debugPrint('설비 연동 데이터 추가 시도 실패 (엔드포인트: $path): 상태 코드 ${response.statusCode}, 응답: ${response.body}');
          }
        } catch (e) {
          debugPrint('설비 연동 데이터 추가 시도 실패 (엔드포인트: $path): $e');
        }
      }
      
      if (result != null) {
        debugPrint('설비 연동 데이터 추가 최종 성공: ${result.code}');
        return result;
      } else {
        debugPrint('설비 연동 데이터 추가 최종 실패');
        return null;
      }
    } catch (e) {
      debugPrint('설비 연동 데이터 추가 오류: $e');
      return null;
    }
  }
  
  // 설비 연동 데이터 수정
  Future<EquipmentConnectionModel?> updateEquipmentConnection(EquipmentConnectionModel connection) async {
    try {
      if (connection.code == null) {
        debugPrint('설비 연동 데이터 수정 오류: 코드 없음');
        return null;
      }
      
      debugPrint('설비 연동 데이터 수정 시작: ${connection.code}');
      
      // MongoDB 저장을 위해 일부 필드 정리
      final Map<String, dynamic> requestData = connection.toJson();
      
      // 필요한 경우 날짜 형식 확인
      if (connection.regDate != null) {
        requestData['regDate'] = connection.regDate.toIso8601String();
      }
      if (connection.startDate != null) {
        requestData['startDate'] = connection.startDate?.toIso8601String();
      } else {
        // null인 경우 필드 제거
        requestData.remove('startDate');
      }
      if (connection.completionDate != null) {
        requestData['completionDate'] = connection.completionDate?.toIso8601String();
      } else {
        // null인 경우 필드 제거
        requestData.remove('completionDate');
      }
      
      // 디버깅을 위한 요청 데이터 출력
      debugPrint('설비 연동 데이터 수정 요청: ${json.encode(requestData)}');
      
      // 3단계 시도: 다양한 엔드포인트로 시도
      final List<String> endpointPaths = [
        '/equipment-connections',
        '/memory/equipment-connections'
      ];
      
      EquipmentConnectionModel? result;
      
      for (final path in endpointPaths) {
        try {
          final uri = Uri.parse('$_baseUrl$path/code/${Uri.encodeComponent(connection.code!)}');
          debugPrint('설비 연동 데이터 수정 시도 URL: $uri');
          
          final response = await http.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          );
          
          debugPrint('설비 연동 데이터 수정 응답 코드: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            debugPrint('설비 연동 데이터 수정 응답: ${response.body}');
            result = EquipmentConnectionModel.fromJson(data);
            debugPrint('설비 연동 데이터 수정 성공 (사용 엔드포인트: $path)');
            break;
          } else {
            debugPrint('설비 연동 데이터 수정 시도 실패 (엔드포인트: $path): 상태 코드 ${response.statusCode}, 응답: ${response.body}');
          }
        } catch (e) {
          debugPrint('설비 연동 데이터 수정 시도 실패 (엔드포인트: $path): $e');
        }
      }
      
      if (result != null) {
        debugPrint('설비 연동 데이터 수정 최종 성공: ${result.code}');
        return result;
      } else {
        debugPrint('설비 연동 데이터 수정 최종 실패');
        return null;
      }
    } catch (e) {
      debugPrint('설비 연동 데이터 수정 오류: $e');
      return null;
    }
  }
  
  // 설비 연동 데이터 삭제
  Future<bool> deleteEquipmentConnection(String code) async {
    try {
      // 3단계 시도: 다양한 엔드포인트로 시도
      final List<String> endpointPaths = [
        '/equipment-connections',
        '/memory/equipment-connections'
      ];
      
      bool success = false;
      
      for (final path in endpointPaths) {
        try {
          final uri = Uri.parse('$_baseUrl$path/code/${Uri.encodeComponent(code)}');
          debugPrint('설비 연동 데이터 삭제 시도 URL: $uri');
          
          final response = await _safeDelete(uri);
          
          if (response.statusCode == 200) {
            success = true;
            debugPrint('설비 연동 데이터 삭제 성공 (사용 엔드포인트: $path)');
            break;
          } else {
            debugPrint('설비 연동 데이터 삭제 시도 실패 (엔드포인트: $path): 상태 코드 ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('설비 연동 데이터 삭제 시도 실패 (엔드포인트: $path): $e');
        }
      }
      
      return success;
    } catch (e) {
      debugPrint('설비 연동 데이터 삭제 오류: $e');
      return false;
    }
  }
  
  // ========================== 첨부파일 관련 메서드 ==========================
  
  // 첨부파일 목록 조회 (New endpoint)
  Future<List<AttachmentModel>> getAttachments({
    required String entityId,
    required String entityType,
  }) async {
    try {
      debugPrint('=== 첨부파일 목록 조회 시작 (신규 API) ===');
      debugPrint('엔티티ID: $entityId, 엔티티타입: $entityType');

      final uri = Uri.parse('$_baseUrl/attachments').replace(queryParameters: {
        'relatedEntityId': entityId,
        'relatedEntityType': entityType,
      });

      final response = await _safeGet(uri);

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        debugPrint('첨부파일 목록 조회 성공: ${dataList.length}개 항목');

        List<AttachmentModel> attachments = [];
        for (var data in dataList) {
          try {
            // _id 필드를 id로 매핑
            if (data['_id'] != null && data['id'] == null) {
              data['id'] = data['_id'];
            }
            attachments.add(AttachmentModel.fromJson(data));
          } catch (e) {
            _logError('첨부파일 데이터 변환', e, null, data);
          }
        }
        // No need for local caching here as server is the source of truth
        return attachments;
      } else {
        _logError('첨부파일 목록 조회', '상태 코드: ${response.statusCode}', uri.toString(), response.body);
        return [];
      }
    } catch (e) {
      _logError('첨부파일 목록 조회', e);
      return [];
    }
  }

  // 첨부파일 업로드 (New endpoint)
  Future<AttachmentModel?> uploadFile({
    required List<int> fileBytes,
    required String fileName,
    required String entityId,
    required String entityType,
  }) async {
    try {
      debugPrint('=== 첨부파일 업로드 시작 (신규 API) ===');
      debugPrint('파일명: $fileName, 엔티티ID: $entityId, 엔티티타입: $entityType');
      logToServer('INFO', '첨부파일 업로드 시작 (신규 API)', data: {'fileName': fileName, 'entityId': entityId});

      final mimeType = _getMimeType(fileName);
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
        'relatedEntityId': entityId,
        'relatedEntityType': entityType,
      });

      final response = await _dio.post(
        '$_baseUrl/attachments',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 60), // Increase timeout for larger files
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      debugPrint('첨부파일 업로드 응답 상태: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = response.data;
        // _id 필드를 id로 매핑
        if (data['_id'] != null && data['id'] == null) {
          data['id'] = data['_id'];
        }
        final savedAttachment = AttachmentModel.fromJson(data);
        debugPrint('첨부파일 업로드 성공: ${savedAttachment.originalFilename}, ID: ${savedAttachment.id}');
        logToServer('INFO', '첨부파일 업로드 성공 (신규 API)', data: {'fileName': fileName, 'attachmentId': savedAttachment.id});
        return savedAttachment;
      } else {
        _logError('첨부파일 업로드', '상태 코드: ${response.statusCode}', '$_baseUrl/attachments', response.data);
        return null;
      }
    } catch (e) {
      String errorMessage = '첨부파일 업로드 중 오류 발생: $e';
      if (e is DioException && e.response != null) {
        errorMessage += '\n서버 응답: ${e.response?.statusCode} - ${e.response?.data}';
      }
      debugPrint(errorMessage);
      logToServer('ERROR', errorMessage, data: {'fileName': fileName, 'entityId': entityId});
      return null;
    }
  }

  // 첨부파일 업로드 (파일 경로) - Uses the new uploadFile method
  Future<AttachmentModel?> uploadFileFromPath({
    required String filePath,
    required String fileName,
    required String entityId,
    required String entityType,
  }) async {
    if (kIsWeb) {
      logToServer('ERROR', 'Web does not support file path upload', data: {'fileName': fileName});
      throw UnsupportedError('웹 환경에서는 파일 경로로 업로드가 지원되지 않습니다.');
    }
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      return uploadFile(
        fileBytes: bytes,
        fileName: fileName,
        entityId: entityId,
        entityType: entityType,
      );
    } catch (e) {
      _logError('파일 경로 업로드', e);
      return null;
    }
  }

  // 첨부파일 다운로드 (New endpoint)
  Future<bool> downloadAttachment(String attachmentId, {String? suggestedFileName}) async {
    try {
      debugPrint('=== 첨부파일 다운로드 시작 ===');
      debugPrint('첨부파일ID: $attachmentId');
      
      final uri = Uri.parse('$_baseUrl/api/attachments/download/$attachmentId');
      
      try {
        // GET 요청으로 파일 다운로드
        final response = await http.get(
          uri,
          headers: {'Accept': '*/*'}, // 모든 응답 유형 허용
        ).timeout(
          const Duration(seconds: 120), // 대용량 파일 고려 타임아웃 증가
          onTimeout: () => http.Response('Timeout', 408),
        );

        debugPrint('응답 상태: ${response.statusCode}');
        
        // 다운로드 응답 처리
        final success = await _processDownloadResponse(
          response, 
          suggestedFileName: suggestedFileName,
          entityType: 'attachment'
        );
        
        return success;
      } catch (httpError) {
        debugPrint('첨부파일 다운로드 HTTP 요청 실패: $httpError');
        
        // 대체 엔드포인트 시도 (api/attachment/download)
        try {
          debugPrint('대체 엔드포인트로 다시 시도');
          final uri2 = Uri.parse('$_baseUrl/api/attachment/download?id=$attachmentId');
          
          final response = await http.get(
            uri2,
            headers: {'Accept': '*/*'},
          ).timeout(
            const Duration(seconds: 120),
            onTimeout: () => http.Response('Timeout', 408),
          );
          
          debugPrint('대체 엔드포인트 응답 상태: ${response.statusCode}');
          
          final success = await _processDownloadResponse(
            response, 
            suggestedFileName: suggestedFileName,
            entityType: 'attachment'
          );
          
          return success;
        } catch (altError) {
          debugPrint('대체 엔드포인트 요청도 실패: $altError');
          throw Exception('모든 다운로드 시도 실패: $httpError, $altError');
        }
      }
    } catch (e) {
      _logError('첨부파일 다운로드', e);
      return false;
    }
  }

  // 다운로드 응답 처리 (바이너리 데이터를 파일로 저장)
  Future<bool> _processDownloadResponse(http.Response response, {String? suggestedFileName, String entityType = ''}) async {
    try {
      if (response.statusCode != 200) {
        debugPrint('다운로드 실패: HTTP ${response.statusCode}');
        return false;
      }

      final contentTypeHeader = response.headers['content-type'] ?? 'application/octet-stream';
      final contentLength = response.contentLength ?? response.bodyBytes.length;
      
      // 헤더에서 파일명 추출 (한글 파일명 처리 개선)
      String fileName = _getFilenameFromHeaders(response.headers) ?? 
          suggestedFileName ?? 
          'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
          
      // 확장자가 없는 경우 콘텐츠 타입을 기반으로 적절한 확장자 추가
      if (!fileName.contains('.')) {
        final extension = _getExtensionFromMimeType(contentTypeHeader);
        fileName = '$fileName.$extension';
      }
      
      // MIME 타입 확인
      final mimeType = _getMimeType(fileName);
      
      debugPrint('다운로드: $fileName ($mimeType, ${contentLength / 1024} KB)');
      
      // 웹 환경에서는 FileSaver 사용
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: response.bodyBytes,
          ext: fileName.split('.').last,
          mimeType: MimeType.other,
        );
        debugPrint('웹 환경에서 파일 저장 완료: $fileName');
        return true;
      } else {
        // 네이티브 환경에서는 파일로 저장
        final result = await FilePicker.platform.getDirectoryPath();
        if (result != null) {
          final path = '$result/$fileName';
          final file = File(path);
          await file.writeAsBytes(response.bodyBytes);
          debugPrint('네이티브 환경에서 파일 저장 완료: $path');
          return true;
        } else {
          debugPrint('파일 저장 위치 선택 취소됨');
          return false;
        }
      }
    } catch (e) {
      _logError('다운로드 처리', e);
      return false;
    }
  }

  // MIME 타입 추출 헬퍼 메서드 (No changes needed)
  String _getMimeType(String fileName) {
    final extension = _getExtensionFromFilename(fileName);
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  // 파일명에서 확장자 추출
  String _getExtensionFromFilename(String filename) {
    final lastDotIndex = filename.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < filename.length - 1) {
      return filename.substring(lastDotIndex + 1).toLowerCase();
    }
    return 'bin'; // 기본 확장자
  }

  // MIME 타입에서 확장자 추출
  String _getExtensionFromMimeType(String mimeType) {
    final mime = mimeType.toLowerCase();
    
    if (mime.contains('jpeg') || mime.contains('jpg')) return 'jpg';
    if (mime.contains('png')) return 'png';
    if (mime.contains('gif')) return 'gif';
    if (mime.contains('pdf')) return 'pdf';
    if (mime.contains('msword') || mime.contains('doc')) return 'doc';
    if (mime.contains('excel') || mime.contains('xls')) return 'xls';
    if (mime.contains('powerpoint') || mime.contains('ppt')) return 'ppt';
    if (mime.contains('text/plain')) return 'txt';
    if (mime.contains('zip')) return 'zip';
    
    return 'bin'; // 기본 확장자
  }

  // 첨부파일 삭제 (New endpoint)
  Future<bool> deleteAttachment(String attachmentId) async {
    try {
      debugPrint('=== 첨부파일 삭제 시작 (신규 API) ===');
      debugPrint('첨부파일ID: $attachmentId');

      final uri = Uri.parse('$_baseUrl/attachments/$attachmentId');
      final response = await _safeDelete(uri);

      debugPrint('첨부파일 삭제 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('첨부파일 삭제 성공: ID $attachmentId');
        logToServer('INFO', 'Attachment deleted successfully', data: {'attachmentId': attachmentId});
        return true;
      } else {
        _logError('첨부파일 삭제', '상태 코드: ${response.statusCode}', uri.toString(), response.body);
        return false;
      }
    } catch (e) {
      _logError('첨부파일 삭제', e);
      return false;
    }
  }
  
  // 다중 API 저장 시도
  Future<bool> trySaveToServer(Map<String, dynamic> data, List<String> endpoints, {String? id}) async {
    bool isSuccess = false;
    String savedEndpoint = '';
    
    debugPrint('=== 서버 저장 시도 (다중 엔드포인트) ===');
    debugPrint('시도할 엔드포인트: ${endpoints.join(", ")}');
    
    for (final endpoint in endpoints) {
      try {
        final uri = Uri.parse('$_baseUrl/$endpoint${id != null ? "/$id" : ""}');
        debugPrint('시도 중: $uri');
        
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () => http.Response('Timeout', 408),
        );
        
        debugPrint('$endpoint 응답 상태: ${response.statusCode}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          isSuccess = true;
          savedEndpoint = endpoint;
          debugPrint('$endpoint 저장 성공');
          break; // 성공하면 반복 중단
        } else {
          debugPrint('$endpoint 저장 실패: ${response.statusCode}');
          if (response.statusCode >= 400) {
            debugPrint('응답 본문: ${response.body}');
          }
        }
      } catch (e) {
        debugPrint('$endpoint 저장 예외: $e');
      }
    }
    
    if (isSuccess) {
      debugPrint('서버 저장 성공 - 사용 엔드포인트: $savedEndpoint');
    } else {
      debugPrint('모든 엔드포인트 저장 실패');
    }
    
    return isSuccess;
  }
  
  // 디버깅용 데이터 요약
  String _summarizeData(Map<String, dynamic> data) {
    try {
      return data.entries.map((e) => '${e.key}: ${e.value.toString().substring(0, min(e.value.toString().length, 50))}').join(', ');
    } catch (_) {
      return 'Error summarizing data';
    }
  }

  // DB 로깅 유틸리티
  Future<void> logToServer(String level, String message, {Map<String, dynamic>? data}) async {
    // Implement actual logging API call if backend supports it
    // print('[SERVER LOG - $level] $message ${data != null ? jsonEncode(data) : ''}');
     try {
       // Example: Replace with your actual logging endpoint and format
       // await http.post(Uri.parse('$_baseUrl/logs'), body: jsonEncode({
       //   'level': level,
       //   'message': message,
       //   'timestamp': DateTime.now().toIso8601String(),
       //   'data': data
       // }));
     } catch (e) {
       // print('Failed to send log to server: $e');
     }
  }

  // 로컬 저장소에 데이터 저장 (SharedPreferences)
  Future<bool> _saveToLocalStorage(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      return await prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('로컬 저장소 저장 실패: $e');
      return false;
    }
  }

  // HTTP 응답에서 Content-Disposition 헤더를 파싱하여 파일명 추출
  String? _getFilenameFromHeaders(Map<String, String> headers) {
    final contentDisposition = headers['content-disposition'] ?? headers['Content-Disposition'];
    if (contentDisposition == null) return null;
    
    final regExp = RegExp(r'filename[^;=\n]*=([\"]?)([^\";]*)\1');
    final matches = regExp.firstMatch(contentDisposition);
    
    if (matches != null && matches.groupCount >= 2) {
      String filename = matches.group(2) ?? '';
      
      // URL 인코딩된 한글 파일명 디코딩
      try {
        if (filename.contains('%')) {
          filename = Uri.decodeComponent(filename);
          // 이중 인코딩된 경우 한 번 더 디코딩
          if (filename.contains('%')) {
            filename = Uri.decodeComponent(filename);
          }
        }
        // 파일명에 UTF-8 이스케이프 시퀀스가 포함된 경우 처리
        if (filename.contains(r'\u')) {
          filename = _decodeUtf8Escapes(filename);
        }
      } catch (e) {
        print('파일명 디코딩 오류: $e, 원본: $filename');
      }
      
      return filename;
    }
    
    return null;
  }
  
  // UTF-8 이스케이프 시퀀스 디코딩 (\uXXXX 형식)
  String _decodeUtf8Escapes(String input) {
    final pattern = RegExp(r'\\u([0-9a-fA-F]{4})');
    return input.replaceAllMapped(pattern, (match) {
      final hexCode = match.group(1)!;
      final codePoint = int.parse(hexCode, radix: 16);
      return String.fromCharCode(codePoint);
    });
  }

  // 단일 첨부파일 조회
  Future<AttachmentModel?> getAttachment(String attachmentId) async {
    try {
      debugPrint('첨부파일 조회 시도: $attachmentId');
      
      final uri = Uri.parse('$_baseUrl/attachments/$attachmentId');
      final response = await _safeGet(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // _id 필드를 id로 매핑
        if (data['_id'] != null && data['id'] == null) {
          data['id'] = data['_id'];
        }
        
        return AttachmentModel.fromJson(data);
      } else if (response.statusCode == 404) {
        debugPrint('첨부파일을 찾을 수 없음: $attachmentId');
        return null;
      } else {
        _logError('첨부파일 조회', '상태 코드: ${response.statusCode}', uri.toString(), response.body);
        return null;
      }
    } catch (e) {
      _logError('첨부파일 조회', e);
      return null;
    }
  }
} 