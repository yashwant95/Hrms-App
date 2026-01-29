import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/glass_card.dart';
import '../../config/theme.dart';
import 'providers/attendance_provider.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceProvider);
    final notifier = ref.read(attendanceProvider.notifier);
    final todayStatus = state.todayStatus;

    final bool isCheckedIn = todayStatus != null && todayStatus['attendance'] != null;
    final bool isCheckedOut = isCheckedIn && todayStatus!['attendance']['checkOut'] != null;
    
    // Parse times
    String checkInTime = '--:--';
    String checkOutTime = '--:--';
    
    if (isCheckedIn) {
      final ci = DateTime.parse(todayStatus!['attendance']['checkIn']).toLocal();
      checkInTime = DateFormat('hh:mm a').format(ci);
    }
    
    if (isCheckedOut) {
      final co = DateTime.parse(todayStatus!['attendance']['checkOut']).toLocal();
      checkOutTime = DateFormat('hh:mm a').format(co);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
        children: [
          // Map Placeholder (Top Half)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Stack(
                children: [
                  const Center(child: Text('Map View Placeholder')),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.danger),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '123, Tech Park, Silicon Valley, CA',
                              style: TextStyle(color: Colors.grey[800]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Area (Bottom Half)
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(DateTime.now()),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('EEEE, MMM d yyyy').format(DateTime.now()),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  
                  // Punch Button
                  GestureDetector(
                    onTap: () {
                      if (isCheckedOut) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Attendance completed for today!')),
                         );
                         return;
                      }
                      if (isCheckedIn) {
                        notifier.checkOut();
                      } else {
                        notifier.checkIn();
                      }
                    },
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isCheckedOut 
                            ? [Colors.grey, Colors.blueGrey]
                            : isCheckedIn 
                              ? [Colors.orange, Colors.deepOrange] 
                              : [AppTheme.primary, AppTheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isCheckedOut ? Colors.grey : (isCheckedIn ? Colors.orange : AppTheme.primary)).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCheckedOut ? Icons.check_circle : (isCheckedIn ? Icons.logout : Icons.fingerprint),
                            size: 64, 
                            color: Colors.white
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isCheckedOut ? 'COMPLETED' : (isCheckedIn ? 'PUNCH OUT' : 'PUNCH IN'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey),
                          const SizedBox(height: 4),
                          Text(checkInTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text('Check In', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.access_time_filled, color: Colors.grey),
                          const SizedBox(height: 4),
                          Text(checkOutTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text('Check Out', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const Column(
                        children: [
                          Icon(Icons.timer, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('00h 00m', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Working Hrs', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
