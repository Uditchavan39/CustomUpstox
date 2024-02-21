import 'package:intl/intl.dart';

class secrets {
  get apiSecret => '';
  get apiKey => '';
  get redirectUri => '';

//--------------------------------Assumptions made :- change values for different results---------------------
  get yearStart => 22; // collect data from financial year 2020 and after that
  get yearEnd => 23; // financial year=yearStart+yearEnd=2021
  String date = DateFormat('yy').format(DateTime.now());
  get currentyear => date;
}
