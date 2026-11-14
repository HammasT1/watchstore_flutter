enum OrderStage { confirmed, packed, outForDelivery, delivered }

extension OrderStageLabel on OrderStage {
  String get label => switch (this) {
    OrderStage.confirmed => 'Confirmed',
    OrderStage.packed => 'Packed',
    OrderStage.outForDelivery => 'On the way',
    OrderStage.delivered => 'Delivered',
  };
}

class OrderLine {
  const OrderLine({
    required this.watchId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    return OrderLine(
      watchId: json['watchId'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: json['unitPrice'] as int,
    );
  }

  final String watchId;
  final String name;
  final int quantity;
  final int unitPrice;

  int get total => quantity * unitPrice;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'watchId': watchId,
    'name': name,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };
}

class Order {
  const Order({
    required this.id,
    required this.placedAt,
    required this.lines,
    required this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      placedAt: DateTime.fromMillisecondsSinceEpoch(json['placedAt'] as int),
      lines: (json['lines'] as List<dynamic>)
          .map(
            (dynamic line) => OrderLine.fromJson(line as Map<String, dynamic>),
          )
          .toList(),
      payment: json['payment'] as String,
    );
  }

  final String id;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final String payment;

  int get total =>
      lines.fold<int>(0, (int sum, OrderLine line) => sum + line.total);

  int get itemCount =>
      lines.fold<int>(0, (int sum, OrderLine line) => sum + line.quantity);

  /// Short human-facing reference, e.g. `CV-482913`.
  String get number {
    final String tail = id.length > 6 ? id.substring(id.length - 6) : id;
    return 'CV-$tail';
  }

  /// There is no backend, so delivery progress is simulated from the time
  /// elapsed since the order was placed.
  OrderStage stageAt(DateTime now) {
    final int minutes = now.difference(placedAt).inMinutes;
    if (minutes >= 27) {
      return OrderStage.delivered;
    }
    if (minutes >= 10) {
      return OrderStage.outForDelivery;
    }
    if (minutes >= 2) {
      return OrderStage.packed;
    }
    return OrderStage.confirmed;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'placedAt': placedAt.millisecondsSinceEpoch,
    'lines': lines.map((OrderLine line) => line.toJson()).toList(),
    'payment': payment,
  };
}

const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats as `14 Nov 2026, 3:42 PM`.
String formatOrderDate(DateTime date) {
  final int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final String minute = date.minute.toString().padLeft(2, '0');
  final String period = date.hour < 12 ? 'AM' : 'PM';
  return '${date.day} ${_months[date.month - 1]} ${date.year}, '
      '$hour:$minute $period';
}
