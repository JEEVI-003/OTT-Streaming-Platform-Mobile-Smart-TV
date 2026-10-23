import 'package:flutter/material.dart';
import 'package:ott_project/plan_and_payment/plan_details.dart';
import 'package:ott_project/service/plan_api_service.dart';

class FeatureList extends StatelessWidget {
  final int planId;
  const FeatureList({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Features>>(
        future: PlanService.fetchFeaturesByPlanId(planId),
        builder: (context, snapshot) {
          print('Connection state: ${snapshot.connectionState}');
          print('Snapshot data: ${snapshot.data}');
          print('Snapshot error: ${snapshot.error}');
          print('Feature data:$snapshot.data');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error in features'),
            );
          } else if (snapshot.data!.isEmpty && !snapshot.hasData) {
            return Center(
              child: Text('No feature available'),
            );
          } else {
            print(
                'Fetched Features: ${snapshot.data!.map((f) => '${f.id}: ${f.featureName}').toList()}');
            return Wrap(
              runSpacing: 5.0,
              spacing: 6.0,
              children: snapshot.data!.map((feature) {
                String formatFeatureName(String featureName) {
                  List<String> words = featureName.split(' ');
                  StringBuffer formattedText = StringBuffer();

                  for (int i = 0; i < words.length; i++) {
                    if (words[i].length <= 4) {
                      // If it's the first word or the current word is short, keep it on the same line.
                      if (formattedText.isNotEmpty) {
                        formattedText.write(
                            ' '); // Add space between short words on the same line.
                      }
                      formattedText.write(words[i] + '');
                    } else {
                      // If the word is long, move it to the next line.
                      formattedText.write('\n' + words[i]);
                    }
                  }

                  return formattedText.toString().trim();
                }

                double opacity = feature.isActiveForPlan ? 1.0 : 0.3;
                return FractionallySizedBox(
                  widthFactor: 0.20,
                  child: Padding(
                    padding: EdgeInsets.only(),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        height: 59,
                        width: 30,
                        child: Text(formatFeatureName(feature.featureName),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: feature.featureName.split(' ').length,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
            //   ],
            // );
          }
        });
  }
}
