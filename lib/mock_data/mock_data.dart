import 'package:shopkeeper/core/enums/debt_type.dart';
import 'package:shopkeeper/core/enums/message_role.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/enums/risk_category.dart';
import 'package:shopkeeper/features/ai_chat/domain/entities/chat_message.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';

class MockData {
  static final List<User> users = [
    const User(
      id: 'u001',
      shopId: 'shop_001',
      name: 'Willson Fouotsa',
      email: 'owner@shopkeeper.cm',
      role: UserRole.owner,
      isActive: true,
    ),
    const User(
      id: 'u004',
      shopId: 'pending',
      name: 'New Owner',
      email: 'newowner@shopkeeper.cm',
      role: UserRole.owner,
      isActive: true,
    ),
    const User(
      id: 'u002',
      shopId: 'shop_001',
      name: 'Marie Ngono',
      email: 'marie@shopkeeper.cm',
      role: UserRole.staff,
      isActive: true,
    ),
    const User(
      id: 'u003',
      shopId: 'shop_001',
      name: 'Jean Mballa',
      email: 'jean@shopkeeper.cm',
      role: UserRole.staff,
      isActive: true,
    ),
  ];

  static final List<Customer> customers = [
    const Customer(
      id: 'c001',
      shopId: 'shop_001',
      name: 'Jean-Pierre Foka',
      phone: '677001122',
      totalDebt: 25000,
      riskCategory: RiskCategory.high,
      lastPurchaseDaysAgo: 3,
    ),
    const Customer(
      id: 'c002',
      shopId: 'shop_001',
      name: 'Amina Bello',
      phone: '699334455',
      totalDebt: 12500,
      riskCategory: RiskCategory.medium,
      lastPurchaseDaysAgo: 7,
    ),
    const Customer(
      id: 'c003',
      shopId: 'shop_001',
      name: 'Rodrigue Njike',
      phone: '655778899',
      totalDebt: 8000,
      riskCategory: RiskCategory.low,
      lastPurchaseDaysAgo: 1,
    ),
    const Customer(
      id: 'c004',
      shopId: 'shop_001',
      name: 'Christelle Mba',
      phone: '677223344',
      totalDebt: 3200,
      riskCategory: RiskCategory.newCustomer,
      lastPurchaseDaysAgo: 0,
    ),
    const Customer(
      id: 'c005',
      shopId: 'shop_001',
      name: 'Paul Tchamba',
      phone: '699001122',
      totalDebt: 40300,
      riskCategory: RiskCategory.high,
      lastPurchaseDaysAgo: 14,
    ),
  ];

  static final List<DebtRecord> jeanPierreDebts = [
    DebtRecord(
      id: 'dr001',
      customerId: 'c001',
      type: DebtType.credit,
      amount: 10000,
      balanceAfter: 10000,
      note: 'Coca Cola carton x3',
      recordedAt: DateTime.now().subtract(const Duration(days: 21)),
    ),
    DebtRecord(
      id: 'dr002',
      customerId: 'c001',
      type: DebtType.credit,
      amount: 8000,
      balanceAfter: 18000,
      note: 'Indomie carton',
      recordedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    DebtRecord(
      id: 'dr003',
      customerId: 'c001',
      type: DebtType.payment,
      amount: 5000,
      balanceAfter: 13000,
      note: 'Partial payment',
      recordedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    DebtRecord(
      id: 'dr004',
      customerId: 'c001',
      type: DebtType.credit,
      amount: 12000,
      balanceAfter: 25000,
      note: 'Mineral Water + Fanta bulk',
      recordedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final List<ChatMessage> chatMessages = [
    ChatMessage(
      id: 'm1',
      role: MessageRole.user,
      text: 'How much did I make this week compared to last week?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      id: 'm2',
      role: MessageRole.assistant,
      text:
          'This week you made 187,500 FCFA from 43 transactions, up 14% from last week. Beverages led at 60% of revenue.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      id: 'm3',
      role: MessageRole.user,
      text: 'Who owes me the most money?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      id: 'm4',
      role: MessageRole.assistant,
      text:
          'Paul Tchamba has the highest balance at 40,300 FCFA with no purchase in 14 days. Jean-Pierre Foka owes 25,000 FCFA and is flagged High Risk.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];
}
