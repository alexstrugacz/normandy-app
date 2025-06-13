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
      String? asString(dynamic v) => v?.toString();
      return ServiceOrder(
        id: asString(json['_id']),
        dateOfRequest: json['dateOfRequest'] != null && json['dateOfRequest'] is String
            ? DateTime.tryParse(json['dateOfRequest'])
            : null,
        dateClosed: json['dateClosed'] != null && json['dateClosed'] is String
            ? DateTime.tryParse(json['dateClosed'])
            : null,
        description: asString(json['description']),
        solution: asString(json['solution']),
        tookCall: asString(json['tookCall']),
        customerId: asString(json['customerId']),
        name: asString(json['name']),
        address: asString(json['address']),
        city: asString(json['city']),
        homePhone: asString(json['homePhone']),
        workPhone: asString(json['workPhone']),
        projectId: asString(json['projectId']),
        dateJobCompleted: json['dateJobCompleted'] != null && json['dateJobCompleted'] is String
            ? DateTime.tryParse(json['dateJobCompleted'])
            : null,
        serviceHandler: json['serviceHandler'] != null
          ? (json['serviceHandler'] as List)
              .map((e) => ServiceHandler.fromJson(e))
              .toList()
          : null,
        tookCallName: asString(json['tookCallName'])
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