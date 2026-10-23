class PlanDetails {
  final int id;
  final String planname;
  final double amount;
  List<Tenures> tenure;
  List<Features> feature;

  PlanDetails({
    required this.id,
    required this.planname,
    this.tenure = const [],
    this.feature = const [],
    required this.amount,
    
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) {
    return PlanDetails(
      id: json['id'] ?? '2',
      planname: json['planname'] ?? 'Unkown',
      amount: json['amount'],
      tenure: json['tenure'] != null
          ? (json['tenure'] as List<dynamic>)
              .map((tenureJson) =>
                  Tenures.fromJson(tenureJson as Map<String, dynamic>))
              .toList()
          : [],
      feature: json['features'] != null
          ? (json['features'] as List<dynamic>)
              .map((featureJson) =>
                  Features.fromJson(featureJson as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class Tenures {
  final int id;
  final String tenureName;
  final int months;
  final int discount;

  Tenures({
    required this.id,
    required this.tenureName,
    required this.months,
    required this.discount,
  });

  factory Tenures.fromJson(Map<String, dynamic> json) {
    return Tenures(
        id: json['id'],
        tenureName: json['tenure_name'],
        months: json['months'],
        discount: json['discount']);
  }
}

class Features {
  final int id;
  final int? featureId;
  String featureName;
  final bool active;
  bool isActiveForPlan;

  Features({
    required this.id,
    this.featureId,
    this.featureName = 'Unknown',
    required this.active,
    this.isActiveForPlan = false,
  });

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
        id: json['id'],
        featureName: json['features'] ?? 'Unknown',
        active: json['active'] ?? false);
  }

  factory Features.fromPlanJson(Map<String, dynamic> json) {
    return Features(
        id: json['id'],
        featureId: json['featureId'],
        isActiveForPlan: false,
        active: json['active'] ?? false);
  }
}
