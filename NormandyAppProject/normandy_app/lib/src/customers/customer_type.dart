class Customer {
  // lname1, fname1, lname2, fname2, city, status
  final String id;
  final String lname1;
  final String fname1;
  final String lname2;
  final String fname2;
  final String city;
  final String status;
  final int customerId;
  final String mlCustomerName;
  final String address;
  final String state;
  final int zip;
  final int zip4;
  final String homePhone1;
  final String homePhone2;
  final String workPhone1;
  final String workPhone2;
  final String cellPhone1;
  final String cellPhone2;
  final String email;
  final String email2;
  final String fax;
  final bool useAsReference;
  final int referrals;
  final bool newsletter;
  final String moved;
  final String customerNotes;
  final String censusTract;
  final DateTime dateCreated;
  final String newsletterMethod;
  final bool usMail;
  final bool emailEnabled;
  final bool calls;
  final bool holidayCards;
  final String county;
  final String taxId;
  final String customerContactID;
  final DateTime lastCalled;
  final int currHomeEstimate;
  final DateTime currHomeEstimateDate;
  final int lastSoldJobNumber;
  final String lastSoldJobId;
  final DateTime lastSoldJobDate;
  final String lastSoldJobDesignerName;
  final bool noNewProjects;
  final String odUrl;
  final String spUrl;
  final String spFolderId;
  final String spFolderName;
  final String spParentId;

  Customer({
    required this.id,
    required this.lname1,
    required this.fname1,
    required this.lname2,
    required this.fname2,
    required this.city,
    required this.status,
    required this.customerId,
    required this.mlCustomerName,
    required this.address,
    required this.state,
    required this.zip,
    required this.zip4,
    required this.homePhone1,
    required this.homePhone2,
    required this.workPhone1,
    required this.workPhone2,
    required this.cellPhone1,
    required this.cellPhone2,
    required this.email,
    required this.email2,
    required this.fax,
    required this.useAsReference,
    required this.referrals,
    required this.newsletter,
    required this.moved,
    required this.customerNotes,
    required this.censusTract,
    required this.dateCreated,
    required this.newsletterMethod,
    required this.usMail,
    required this.emailEnabled,
    required this.calls,
    required this.holidayCards,
    required this.county,
    required this.taxId,
    required this.customerContactID,
    required this.lastCalled,
    required this.currHomeEstimate,
    required this.currHomeEstimateDate,
    required this.lastSoldJobNumber,
    required this.lastSoldJobId,
    required this.lastSoldJobDate,
    required this.lastSoldJobDesignerName,
    required this.noNewProjects,
    required this.odUrl,
    required this.spUrl,
    required this.spFolderId,
    required this.spFolderName,
    required this.spParentId,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? '',
      lname1: json['lname1'] ?? '',
      fname1: json['fname1'] ?? '',
      lname2: json['lname2'] ?? '',
      fname2: json['fname2'] ?? '',
      city: json['city'] ?? '',
      status: json['status'] ?? '',
      customerId: json['customerId'] ?? 0,
      mlCustomerName: json['mlCustomerName'] ?? '',
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      zip: json['zip'] ?? 0,
      zip4: json['zip4'] ?? 0,
      homePhone1: json['homePhone1'] ?? '',
      homePhone2: json['homePhone2'] ?? '',
      workPhone1: json['workPhone1'] ?? '',
      workPhone2: json['workPhone2'] ?? '',
      cellPhone1: json['cellPhone1'] ?? '',
      cellPhone2: json['cellPhone2'] ?? '',
      email: json['email'] ?? '',
      email2: json['email2'] ?? '',
      fax: json['fax'] ?? '',
      useAsReference: json['useAsReference'] ?? false,
      referrals: json['referrals'] ?? 0,
      newsletter: json['newsletter'] ?? false,
      moved: json['moved'] ?? '',
      customerNotes: json['customerNotes'] ?? '',
      censusTract: json['censusTract'] ?? '',
      dateCreated: json['dateCreated'] != null ? DateTime.parse(json['dateCreated']) : DateTime.now(),
      newsletterMethod: json['newsletterMethod'] ?? '',
      usMail: json['usMail'] ?? false,
      emailEnabled: json['emailEnabled'] ?? false,
      calls: json['calls'] ?? false,
      holidayCards: json['holidayCards'] ?? false,
      county: json['county'] ?? '',
      taxId: json['taxId'] ?? '',
      customerContactID: json['customerContactID'] ?? '',
      lastCalled: json['lastCalled'] != null ? DateTime.parse(json['lastCalled']) : DateTime.now(),
      currHomeEstimate: json['currHomeEstimate'] ?? 0,
      currHomeEstimateDate: json['currHomeEstimateDate'] != null ? DateTime.parse(json['currHomeEstimateDate']) : DateTime.now(),
      lastSoldJobNumber: json['lastSoldJobNumber'] ?? 0,
      lastSoldJobId: json['lastSoldJobId'] ?? '',
      lastSoldJobDate: json['lastSoldJobDate'] != null ? DateTime.parse(json['lastSoldJobDate']) : DateTime.now(),
      lastSoldJobDesignerName: json['lastSoldJobDesignerName'] ?? '',
      noNewProjects: json['noNewProjects'] ?? false,
      odUrl: json['odUrl'] ?? '',
      spUrl: json['spUrl'] ?? '',
      spFolderId: json['spFolderId'] ?? '',
      spFolderName: json['spFolderName'] ?? '',
      spParentId: json['spParentId'] ?? '',
    );
  }
}