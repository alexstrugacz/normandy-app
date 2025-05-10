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
      return Appointment(
        id: json['id'] as String?,
        leadIdOld: json['leadIdOld'] as int?,
        customerId: json['customerId'] as String?,
        leadSourceId: json['leadSourceId'] as String?,
        leadSource2Id: json['leadSource2Id'] as String?,
        projectDescription: json['projectDescription'] as String?,
        referredById: json['referredById'] as String?,
        dateOfRequest: json['dateOfRequest'] != null && json['dateOfRequest'] is String
            ? DateTime.tryParse(json['dateOfRequest'])
            : null,
        timeSet: json['timeSet'] as String?,
        dateRun: json['dateRun'] != null && json['dateRun'] is String
            ? DateTime.tryParse(json['dateRun'])
            : null,
        dateRunTxt: json['dateRunTxt'] as String?,
        designerId: json['designerId'] as String?,
        designerId2: json['designerId2'] as String?,
        designerInTrainingId: json['designerInTrainingId'] as String?,
        soldJob: json['soldJob'] is bool ? json['soldJob'] as bool? : null,
        dateSoldJob: json['dateSoldJob'] != null && json['dateSoldJob'] is String
            ? DateTime.tryParse(json['dateSoldJob'])
            : null,
        takenById: json['takenById'] as String?,
        jobId: json['jobId'] as String?,
        confirmationLetterSent: json['confirmationLetterSent'] is bool
            ? json['confirmationLetterSent'] as bool?
            : null,
        firstContactId: json['firstContactId'] as String?,
        yearBuilt: json['yearBuilt'] as int?,
        goBack: json['goBack'] != null && json['goBack'] is String
            ? DateTime.tryParse(json['goBack'])
            : null,
        goBackScheduled: json['goBackScheduled'] as String?,
        lname: json['lname'] as String?,
        city: json['city'] as String?,
        designerName: json['designerName'] as String?,
        designerName2: json['designerName2'] as String?,
        estimatedJobValue: json['estimatedJobValue'] is num
            ? (json['estimatedJobValue'] as num).toDouble()
            : null,
        qualityOfAppointment: json['qualityOfAppointment'] as int?,
        thankYouSent: json['thankYouSent'] as String?,
        referredBy: json['referredBy'] as String?,
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