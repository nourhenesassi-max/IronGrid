import 'models/rh_models.dart';

class RhRepository {
  List<RhEmployeeWorkload> getWorkloads() {
    return [
      RhEmployeeWorkload(
        employeeName: 'Ahmed Ben Ali',
        projectName: 'Website Redesign',
        dailyHours: 8,
        weeklyHours: 39.5,
        isOverloaded: false,
        alertMessage: 'Charge normale',
      ),
      RhEmployeeWorkload(
        employeeName: 'Sara Trabelsi',
        projectName: 'HR Portal Update',
        dailyHours: 10,
        weeklyHours: 46,
        isOverloaded: true,
        alertMessage: 'Surcharge détectée',
      ),
      RhEmployeeWorkload(
        employeeName: 'Karim Benali',
        projectName: 'Installation Ligne 4',
        dailyHours: 9.5,
        weeklyHours: 44,
        isOverloaded: true,
        alertMessage: 'Heures élevées',
      ),
    ];
  }
}