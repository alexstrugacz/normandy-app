


class ServiceHandler {
  String? id;
  String? customServiceHandler;
  bool? customOptionMode;
  DateTime? dateAssigned;

  ServiceHandler({
    this.id,
    this.customServiceHandler,
    this.customOptionMode,
    this.dateAssigned
  });

  factory ServiceHandler.fromJson(Map<String, dynamic> json) {
    try {
      return ServiceHandler(
        id: json['id'] as String?,
        customServiceHandler: json['customServiceHandler'] as String?,
        customOptionMode: json['customOptionMode'] as bool?,
        dateAssigned: json['dateAssigned'] != null && json['dateAssigned'] is String
            ? DateTime.tryParse(json['dateAssigned'])
            : null
      );
    } catch (e) {
      throw FormatException('Error parsing ServiceHandler: $e');
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'customServiceHandler': customServiceHandler,
        'customOptionMode': customOptionMode,
        'dateAssigned': dateAssigned
      };
    } catch (e) {
      throw FormatException('Error serializing ServiceHandler: $e');
    }
  }
}

class ServiceOrder {
  String? id;
  DateTime? dateOfRequest;
  DateTime? dateClosed;
  String? description;
  String? solution;
  String? tookCall;
  String? customerId;
  String? name;
  String? address;
  String? city;
  String? homePhone;
  String? workPhone;
  String? projectId;
  DateTime? dateJobCompleted;
  List<ServiceHandler>? serviceHandler;
  String? tookCallName;

  ServiceOrder({
    this.id,
    this.dateOfRequest,
    this.dateClosed,
    this.description,
    this.solution,
    this.tookCall,
    this.customerId,
    this.name,
    this.address,
    this.city,
    this.homePhone,
    this.workPhone,
    this.projectId,
    this.dateJobCompleted,
    this.serviceHandler,
    this.tookCallName
  });    

  factory ServiceOrder.fromJson(Map<String, dynamic> json) {
    try {
      return ServiceOrder(
        id: json['id'] as String?,
        dateOfRequest: json['dateOfRequest'] != null && json['dateOfRequest'] is String
            ? DateTime.tryParse(json['dateOfRequest'])
            : null,
        dateClosed: json['dateClosed'] != null && json['dateClosed'] is String
            ? DateTime.tryParse(json['dateClosed'])
            : null,
        description: json['description'] as String?,
        solution: json['solution'] as String?,
        tookCall: json['tookCall'] as String?,
        customerId: json['customerId'] as String?,
        name: json['name'] as String?,
        address: json['address'] as String?,
        city: json['city'] as String?,
        homePhone: json['homePhone'] as String?,
        workPhone: json['workPhone'] as String?,
        projectId: json['projectId'] as String?,
        dateJobCompleted: json['dateJobCompleted'] != null && json['dateJobCompleted'] is String
            ? DateTime.tryParse(json['dateJobCompleted'])
            : null,
        serviceHandler: json['serviceHandler'] != null
          ? (json['serviceHandler'] as List)
              .map((e) => ServiceHandler.fromJson(e))
              .toList()
          : null,
        tookCallName: json['tookCallName'] as String?
      );
    } catch (e) {
      throw FormatException('Error parsing ServiceOrder: $e');
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'dateOfRequest': dateOfRequest,
        'dateClosed': dateClosed,
        'description': description,
        'solution': solution,
        'tookCall': tookCall,
        'customerId': customerId,
        'name': name,
        'address': address,
        'city': city,
        'homePhone': homePhone,
        'workPhone': workPhone,
        'projectId': projectId,
        'dateJobCompleted': dateJobCompleted,
        'serviceHandler': dateJobCompleted,
        'tookCallName': tookCallName
      };
    } catch (e) {
      throw FormatException('Error serializing ServiceOrder: $e');
    }
  }
}