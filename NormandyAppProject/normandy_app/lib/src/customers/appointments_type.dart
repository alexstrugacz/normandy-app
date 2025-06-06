class Appointment {
  String? id;
  int? leadIdOld;
  String? customerId;
  String? leadSourceId;
  String? leadSource2Id;
  String? projectDescription;
  String? referredById;
  DateTime? dateOfRequest;
  String? timeSet;
  DateTime? dateRun;
  String? dateRunTxt;
  String? designerId;
  String? designerId2;
  String? designerInTrainingId;
  bool? soldJob;
  DateTime? dateSoldJob;
  String? takenById;
  String? jobId;
  bool? confirmationLetterSent;
  String? firstContactId;
  int? yearBuilt;
  DateTime? goBack;
  String? goBackScheduled;
  String? lname;
  String? city;
  String? designerName;
  String? designerName2;
  double? estimatedJobValue;
  int? qualityOfAppointment;
  String? thankYouSent;
  String? referredBy;

  Appointment({
    this.id,
    this.leadIdOld,
    this.customerId,
    this.leadSourceId,
    this.leadSource2Id,
    this.projectDescription,
    this.referredById,
    this.dateOfRequest,
    this.timeSet,
    this.dateRun,
    this.dateRunTxt,
    this.designerId,
    this.designerId2,
    this.designerInTrainingId,
    this.soldJob,
    this.dateSoldJob,
    this.takenById,
    this.jobId,
    this.confirmationLetterSent,
    this.firstContactId,
    this.yearBuilt,
    this.goBack,
    this.goBackScheduled,
    this.lname,
    this.city,
    this.designerName,
    this.designerName2,
    this.estimatedJobValue,
    this.qualityOfAppointment,
    this.thankYouSent,
    this.referredBy,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    try {
      String? asString(dynamic v) => v?.toString();
      return Appointment(
        id: asString(json['id']),
        leadIdOld: json['leadIdOld'] as int?,
        customerId: asString(json['customerId']),
        leadSourceId: asString(json['leadSourceId']),
        leadSource2Id: asString(json['leadSource2Id']),
        projectDescription: asString(json['projectDescription']),
        referredById: asString(json['referredById']),
        dateOfRequest: json['dateOfRequest'] != null && json['dateOfRequest'] is String
            ? DateTime.tryParse(json['dateOfRequest'])
            : null,
        timeSet: asString(json['timeSet']),
        dateRun: json['dateRun'] != null && json['dateRun'] is String
            ? DateTime.tryParse(json['dateRun'])
            : null,
        dateRunTxt: asString(json['dateRunTxt']),
        designerId: asString(json['designerId']),
        designerId2: asString(json['designerId2']),
        designerInTrainingId: asString(json['designerInTrainingId']),
        soldJob: json['soldJob'] is bool ? json['soldJob'] as bool? : null,
        dateSoldJob: json['dateSoldJob'] != null && json['dateSoldJob'] is String
            ? DateTime.tryParse(json['dateSoldJob'])
            : null,
        takenById: asString(json['takenById']),
        jobId: asString(json['jobId']),
        confirmationLetterSent: json['confirmationLetterSent'] is bool
            ? json['confirmationLetterSent'] as bool?
            : null,
        firstContactId: asString(json['firstContactId']),
        yearBuilt: json['yearBuilt'] as int?,
        goBack: json['goBack'] != null && json['goBack'] is String
            ? DateTime.tryParse(json['goBack'])
            : null,
        goBackScheduled: asString(json['goBackScheduled']),
        lname: asString(json['lname']),
        city: asString(json['city']),
        designerName: asString(json['designerName']),
        designerName2: asString(json['designerName2']),
        estimatedJobValue: json['estimatedJobValue'] is num
            ? (json['estimatedJobValue'] as num).toDouble()
            : null,
        qualityOfAppointment: json['qualityOfAppointment'] as int?,
        thankYouSent: asString(json['thankYouSent']),
        referredBy: asString(json['referredBy']),
      );
    } catch (e) {
      throw FormatException('Error parsing Appointment: $e');
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'leadIdOld': leadIdOld,
        'customerId': customerId,
        'leadSourceId': leadSourceId,
        'leadSource2Id': leadSource2Id,
        'projectDescription': projectDescription,
        'referredById': referredById,
        'dateOfRequest': dateOfRequest?.toIso8601String(),
        'timeSet': timeSet,
        'dateRun': dateRun?.toIso8601String(),
        'dateRunTxt': dateRunTxt,
        'designerId': designerId,
        'designerId2': designerId2,
        'designerInTrainingId': designerInTrainingId,
        'soldJob': soldJob,
        'dateSoldJob': dateSoldJob?.toIso8601String(),
        'takenById': takenById,
        'jobId': jobId,
        'confirmationLetterSent': confirmationLetterSent,
        'firstContactId': firstContactId,
        'yearBuilt': yearBuilt,
        'goBack': goBack?.toIso8601String(),
        'goBackScheduled': goBackScheduled,
        'lname': lname,
        'city': city,
        'designerName': designerName,
        'designerName2': designerName2,
        'estimatedJobValue': estimatedJobValue,
        'qualityOfAppointment': qualityOfAppointment,
        'thankYouSent': thankYouSent,
        'referredBy': referredBy,
      };
    } catch (e) {
      throw FormatException('Error serializing Appointment: $e');
    }
  }
}