class charges_obj {
  num total,
      brokerage,
      gst,
      stt,
      stamp_duty,
      transaction,
      clearing,
      others,
      sebi_turnover,
      demat_transaction;
    var  financial_year;
  bool dataSuccessOrError;

  charges_obj(
      this.total,
      this.brokerage,
      this.gst,
      this.stt,
      this.stamp_duty,
      this.transaction,
      this.clearing,
      this.others,
      this.sebi_turnover,
      this.demat_transaction,
      this.financial_year,
      this.dataSuccessOrError);
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> charge = Map<String, dynamic>();
    charge["total"] = total;
    charge["brokerage"] = brokerage;
    charge["gst"] = gst;
    charge["stt"] = stt;
    charge["stamp_duty"] = stamp_duty;
    charge["transaction"] = transaction;
    charge["clearing"] = clearing;
    charge["others"] = others;
    charge["sebi_turnover"] = sebi_turnover;
    charge["demat_transaction"] = demat_transaction;
    charge["financial_year"] = financial_year;
    charge["dataSuccessOrError"] = dataSuccessOrError;
    return charge;
  }
}

class jsoncharges {
  charges_obj fromJson(Map<String, dynamic> charge) {
    final charges_obj obj = charges_obj(
        charge["total"],
        charge["brokerage"],
        charge["gst"],
        charge["stt"],
        charge["stamp_duty"],
        charge["transaction"],
        charge["clearing"],
        charge["others"],
        charge["sebi_turnover"],
        charge["demat_transaction"],
        charge["financial_year"],
        charge["dataSuccessOrError"]);
    return obj;
  }
}

class defaultchargeObj {
  get defaultChargeObj => charges_obj(
      0.0,
      0.0,
    0.0,
    0.0,
    0.0,
    0.0, 
    0.0,
    0.0,
    0.0,
    0.0,
    "wait...",
      false);
}
