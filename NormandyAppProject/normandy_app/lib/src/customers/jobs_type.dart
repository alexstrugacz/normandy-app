

class Job {
  String? id;
  bool? isMaster;
  String? jobNumber;
  String? jobAddress;
  String? jobCity;
  String? jobDescription;
  int? shareDesigner1;
  int? shareDesigner2;
  String? designFee;
  int? salePrice;
  String? letterAfterSale;
  bool? autoSchedule;
  bool? contingency;
  int? bondBalance;
  bool? limbo;
  DateTime? dateSold;
  DateTime? jobCompletionDate;
  DateTime? jobStateDate;
  String? substantialCompleted;
  String? finalInspection;
  int? finalPrice;
  String? customerId;
  String? designerId;
  String? designerId2;
  String? superId;
  String? jobStateId;
  String? jobSubId;
  String? jobtypeId;
  String? lname;
  String? lname2;
  String? jobStateName;

  Job({
    this.id,
    this.isMaster,
    this.jobNumber,
    this.jobAddress,
    this.jobCity,
    this.jobDescription,
    this.shareDesigner1,
    this.shareDesigner2,
    this.designFee,
    this.salePrice,
    this.letterAfterSale,
    this.autoSchedule,
    this.contingency,
    this.bondBalance,
    this.limbo,
    this.dateSold,
    this.jobCompletionDate,
    this.jobStateDate,
    this.substantialCompleted,
    this.finalInspection,
    this.finalPrice,
    this.customerId,
    this.designerId,
    this.designerId2,
    this.superId,
    this.jobStateId,
    this.jobSubId,
    this.jobtypeId,
    this.lname,
    this.lname2,
    this.jobStateName
  });    

  factory Job.fromJson(Map<String, dynamic> json) {
    try {
      return Job(
        id: json['id'] as String?,
        isMaster: json['isMaster'] as bool?,
        jobNumber: json['jobNumber'] as String?,
        jobAddress: json['jobAddress'] as String?,
        jobCity: json['jobCity'] as String?,
        jobDescription: json['jobDescription'] as String?,
        shareDesigner1: json['shareDesigner1'] as int?,
        shareDesigner2: json['shareDesigner2'] as int?,
        designFee: json['designFee'] as String?,
        salePrice: json['salePrice'] as int?,
        letterAfterSale: json['letterAfterSale'] as String?,
        autoSchedule: json['autoSchedule'] as bool?,
        contingency: json['contingency'] as bool?,
        bondBalance: json['bondBalance'] as int?,
        limbo: json['limbo'] as bool?,
        dateSold: json['dateSold'] != null && json['dateSold'] is String
            ? DateTime.tryParse(json['dateSold'])
            : null,
        jobCompletionDate: json['jobCompletionDate'] != null && json['jobCompletionDate'] is String
            ? DateTime.tryParse(json['jobCompletionDate'])
            : null,
        jobStateDate: json['jobStateDate'] != null && json['jobStateDate'] is String
            ? DateTime.tryParse(json['jobStateDate'])
            : null,
        substantialCompleted: json['substantialCompleted'] as String?,
        finalInspection: json['finalInspection'] as String?,
        finalPrice: json['finalPrice'] as int?,
        customerId: json['customerId'] as String?,
        designerId: json['designerId'] as String?,
        designerId2: json['designerId2'] as String?,
        superId: json['superId'] as String?,
        jobStateId: json['jobStateId'] as String?,
        jobSubId: json['jobSubId'] as String?,
        jobtypeId: json['jobtypeId'] as String?,
        lname: json['lname'] as String?,
        lname2: json['lname2'] as String?,
        jobStateName: json['jobStateName'] as String?
      );
    } catch (e) {
      throw FormatException('Error parsing Job: $e');
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'isMaster': isMaster,
        'jobNumber': jobNumber,
        'jobAddress': jobAddress,
        'jobCity': jobCity,
        'jobDescription': jobDescription,
        'shareDesigner1': shareDesigner1,
        'shareDesigner2': shareDesigner2,
        'designFee': designFee,
        'salePrice': salePrice,
        'letterAfterSale': letterAfterSale,
        'autoSchedule': autoSchedule,
        'contingency': contingency,
        'bondBalance': bondBalance,
        'limbo': limbo,
        'dateSold': dateSold,
        'jobCompletionDate': jobCompletionDate,
        'jobStateDate': jobStateDate,
        'substantialCompleted': substantialCompleted,
        'finalInspection': finalInspection,
        'finalPrice': finalPrice,
        'customerId': customerId,
        'designerId': designerId,
        'designerId2': designerId2,
        'superId': superId,
        'jobStateId': jobStateId,
        'jobSubId': jobSubId,
        'jobtypeId': jobtypeId,
        'lname': lname,
        'lname2': lname2,
        'jobStateName': jobStateName
      };
    } catch (e) {
      throw FormatException('Error serializing Job: $e');
    }
  }
}