import 'dart:convert';

class SocketCompanyResponseModel {
  String? the1;
  String? sym;
  String? exg;
  String? inst;
  String? high;
  String? low;
  String? cls;
  String? open;
  String? chg;
  String? pctChg;
  String? prvCls;
  String? tovr;
  String? vol;
  String? trades;
  String? cur;
  String? ltp;
  String? ltq;
  String? ltd;
  String? ltt;
  String? bap;
  String? baq;
  String? bbp;
  String? bbq;
  String? taq;
  String? tbq;
  String? h52;
  String? l52;
  String? per;
  String? pbr;
  String? eps;
  String? yld;
  String? deci;
  String? isinCode;
  String? mktCap;
  String? pctYtd;
  String? cit;
  String? civ;
  String? cot;
  String? cov;
  String? beta;
  String? min;
  String? max;
  String? vwap;
  String? fVal;
  String? oInt;
  String? stkP;
  String? lstShares;
  String? opint;
  String? symStat;
  String? cvwap;
  String? twap;
  String? pctChgW;
  String? pctChgM;
  String? pctChg3M;
  String? pctChgY;
  String? avgVol30D;
  String? avgTovr30D;
  String? chgY;
  String? avgVolume3M;
  String? prevT;
  String? prevD;
  String? sus;
  String? avgTxVal30D;
  String? lutt;
  String? tTick;

  SocketCompanyResponseModel({
    this.the1,
    this.sym,
    this.exg,
    this.inst,
    this.high,
    this.low,
    this.cls,
    this.open,
    this.chg,
    this.pctChg,
    this.prvCls,
    this.tovr,
    this.vol,
    this.trades,
    this.cur,
    this.ltp,
    this.ltq,
    this.ltd,
    this.ltt,
    this.bap,
    this.baq,
    this.bbp,
    this.bbq,
    this.taq,
    this.tbq,
    this.h52,
    this.l52,
    this.per,
    this.pbr,
    this.eps,
    this.yld,
    this.deci,
    this.isinCode,
    this.mktCap,
    this.pctYtd,
    this.cit,
    this.civ,
    this.cot,
    this.cov,
    this.beta,
    this.min,
    this.max,
    this.vwap,
    this.fVal,
    this.oInt,
    this.stkP,
    this.lstShares,
    this.opint,
    this.symStat,
    this.cvwap,
    this.twap,
    this.pctChgW,
    this.pctChgM,
    this.pctChg3M,
    this.pctChgY,
    this.avgVol30D,
    this.avgTovr30D,
    this.chgY,
    this.avgVolume3M,
    this.prevT,
    this.prevD,
    this.sus,
    this.avgTxVal30D,
    this.lutt,
    this.tTick,
  });

  factory SocketCompanyResponseModel.fromJson(String str) =>
      SocketCompanyResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SocketCompanyResponseModel.fromMap(Map<String, dynamic> json) =>
      SocketCompanyResponseModel(
        the1: json["1"]?.toString(),
        sym: json["sym"]?.toString(),
        exg: json["exg"]?.toString(),
        inst: json["inst"]?.toString(),
        high: json["high"]?.toString(),
        low: json["low"]?.toString(),
        cls: json["cls"]?.toString(),
        open: json["open"]?.toString(),
        chg: json["chg"]?.toString(),
        pctChg: json["pctChg"]?.toString(),
        prvCls: json["prvCls"]?.toString(),
        tovr: json["tovr"]?.toString(),
        vol: json["vol"]?.toString(),
        trades: json["trades"]?.toString(),
        cur: json["cur"]?.toString(),
        ltp: json["ltp"]?.toString(),
        ltq: json["ltq"]?.toString(),
        ltd: json["ltd"]?.toString(),
        ltt: json["ltt"]?.toString(),
        bap: json["bap"]?.toString(),
        baq: json["baq"]?.toString(),
        bbp: json["bbp"]?.toString(),
        bbq: json["bbq"]?.toString(),
        taq: json["taq"]?.toString(),
        tbq: json["tbq"]?.toString(),
        h52: json["h52"]?.toString(),
        l52: json["l52"]?.toString(),
        per: json["per"]?.toString(),
        pbr: json["pbr"]?.toString(),
        eps: json["eps"]?.toString(),
        yld: json["yld"]?.toString(),
        deci: json["deci"]?.toString(),
        isinCode: json["ISINCode"]?.toString(),
        mktCap: json["mktCap"]?.toString(),
        pctYtd: json["pctYtd"]?.toString(),
        cit: json["cit"]?.toString(),
        civ: json["civ"]?.toString(),
        cot: json["cot"]?.toString(),
        cov: json["cov"]?.toString(),
        beta: json["beta"]?.toString(),
        min: json["min"]?.toString(),
        max: json["max"]?.toString(),
        vwap: json["vwap"]?.toString(),
        fVal: json["fVal"]?.toString(),
        oInt: json["oInt"]?.toString(),
        stkP: json["stkP"]?.toString(),
        lstShares: json["lstShares"]?.toString(),
        opint: json["opint"]?.toString(),
        symStat: json["symStat"]?.toString(),
        cvwap: json["cvwap"]?.toString(),
        twap: json["twap"]?.toString(),
        pctChgW: json["pctChgW"]?.toString(),
        pctChgM: json["pctChgM"]?.toString(),
        pctChg3M: json["pctChg3M"]?.toString(),
        pctChgY: json["pctChgY"]?.toString(),
        avgVol30D: json["avgVol30D"]?.toString(),
        avgTovr30D: json["avgTovr30D"]?.toString(),
        chgY: json["chgY"]?.toString(),
        avgVolume3M: json["avgVolume3M"]?.toString(),
        prevT: json["prevT"]?.toString(),
        prevD: json["prevD"]?.toString(),
        sus: json["sus"]?.toString(),
        avgTxVal30D: json["avgTxVal30D"]?.toString(),
        lutt: json["lutt"]?.toString(),
        tTick: json["tTick"]?.toString(),
      );

  Map<String, dynamic> toMap() => {
        "1": the1,
        "sym": sym,
        "exg": exg,
        "inst": inst,
        "high": high,
        "low": low,
        "cls": cls,
        "open": open,
        "chg": chg,
        "pctChg": pctChg,
        "prvCls": prvCls,
        "tovr": tovr,
        "vol": vol,
        "trades": trades,
        "cur": cur,
        "ltp": ltp,
        "ltq": ltq,
        "ltd": ltd,
        "ltt": ltt,
        "bap": bap,
        "baq": baq,
        "bbp": bbp,
        "bbq": bbq,
        "taq": taq,
        "tbq": tbq,
        "h52": h52,
        "l52": l52,
        "per": per,
        "pbr": pbr,
        "eps": eps,
        "yld": yld,
        "deci": deci,
        "ISINCode": isinCode,
        "mktCap": mktCap,
        "pctYtd": pctYtd,
        "cit": cit,
        "civ": civ,
        "cot": cot,
        "cov": cov,
        "beta": beta,
        "min": min,
        "max": max,
        "vwap": vwap,
        "fVal": fVal,
        "oInt": oInt,
        "stkP": stkP,
        "lstShares": lstShares,
        "opint": opint,
        "symStat": symStat,
        "cvwap": cvwap,
        "twap": twap,
        "pctChgW": pctChgW,
        "pctChgM": pctChgM,
        "pctChg3M": pctChg3M,
        "pctChgY": pctChgY,
        "avgVol30D": avgVol30D,
        "avgTovr30D": avgTovr30D,
        "chgY": chgY,
        "avgVolume3M": avgVolume3M,
        "prevT": prevT,
        "prevD": prevD,
        "sus": sus,
        "avgTxVal30D": avgTxVal30D,
        "lutt": lutt,
        "tTick": tTick,
      };
}
