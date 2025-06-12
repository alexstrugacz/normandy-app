class Job {
  String? id;
  String? lname;
  String? jobCity;
  DateTime? jobCompletionDate;
  DateTime? dateSold;
  DateTime? realityLetterSent;
  DateTime? jobStateDate;
  DateTime? finalInspection;
  DateTime? substantialCompleted;
  String? jobId;
  String? limbo;
  String? contingency;
  String? jobDescription;
  String? finalPrice;
  int? jobCost;
  String? jobNumber;

  Job({
    this.id,
    this.lname,
    this.jobCity,
    this.jobCompletionDate,
    this.dateSold,
    this.realityLetterSent,
    this.jobId,
    this.jobStateDate,
    this.substantialCompleted,
    this.finalInspection,
    this.limbo,
    this.contingency,
    this.jobDescription,
    this.finalPrice,
    this.jobCost,
    this.jobNumber,
  });    

  factory Job.fromJson(Map<String, dynamic> json) {
    try {
      String? asString(dynamic v) => v?.toString(); // Converts Any to String or null
      // as String? throws an error if the conversion fails
      return Job(
        id: asString(json['_id']),
        lname: asString(json['lname']),
        jobCity: asString(json['jobCity']),
        jobCompletionDate: json['jobCompletionDate'] != null && json['jobCompletionDate'] is String
            ? DateTime.tryParse(json['jobCompletionDate'])
            : null,
        dateSold: json['dateSold'] != null && json['dateSold'] is String
            ? DateTime.tryParse(json['dateSold'])
            : null,
        realityLetterSent: json['realityLetterSent'] != null && json['realityLetterSent'] is String
            ? DateTime.tryParse(json['realityLetterSent'])
            : null,
        jobStateDate: json['jobStateDate'] != null && json['jobStateDate'] is String
            ? DateTime.tryParse(json['jobStateDate'])
            : null,
        finalInspection: json['finalInspection'] != null && json['finalInspection'] is String
            ? DateTime.tryParse(json['finalInspection'])
            : null,
        substantialCompleted: json['substantialCompleted'] != null && json['substantialCompleted'] is String
            ? DateTime.tryParse(json['substantialCompleted'])
            : null,
        jobId: asString(json['jobId']),
        limbo: json['limbo'] == true ? "Yes" : "No",
        contingency: json['contingency'] == true ? "Yes" : "No",
        jobDescription: asString(json['jobDescription']),
        finalPrice: asString(json['finalPrice']),
        jobCost: json['jobCost'] as int?,
        jobNumber: asString(json['jobNumber']),
      );
    } catch (e) {
      throw FormatException('Error parsing Job: $e');
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'lname': lname,
        'jobCity': jobCity,
        'jobCompletionDate': jobCompletionDate,
        'dateSold': dateSold,
        'realityLetterSent': realityLetterSent,
        'jobId': jobId,
        'limbo': limbo,
        'contingency': contingency,
        'jobDescription': jobDescription,
        'jobStateDate': jobStateDate,
        'finalInspection': finalInspection,
        'substantialCompleted': substantialCompleted,
        'finalPrice': finalPrice,
        'jobCost': jobCost,
        'jobNumber': jobNumber
      };
    } catch (e) {
      throw FormatException('Error serializing Job: $e');
    }
  }
}