import 'job.dart';
import 'worker.dart';

class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final String status;
  final DateTime createdAt;
  final Job? job;
  final Worker? worker;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.status,
    required this.createdAt,
    this.job,
    this.worker,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      jobId: json['job_id'],
      workerId: json['worker_id'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
      worker: json['worker'] != null ? Worker.fromJson(json['worker']) : null,
    );
  }
}
