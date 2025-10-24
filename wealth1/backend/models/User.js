const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const PlaidSchema = new mongoose.Schema({
  accessToken: { type: String, required: true },
  itemID: { type: String, required: true },
  institutionName: { type: String },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }
}, { timestamps: true });

const BankAccountSchema = new mongoose.Schema({
  plaidAccountId: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  type: { type: String, required: true },
  subtype: { type: String, required: true },
  currentBalance: { type: Number, required: true },
  availableBalance: { type: Number },
  currency: { type: String, default: 'USD' }
});

const BudgetSchema = new mongoose.Schema({
  budgetType: { type: String, required: false },
  budgetName: { type: String, required: false },
  budgetAmount: { type: Number, required: false },
  allocatedAmount: { type: Number, required: false },
  category: { type: String, required: true },
  budgetSubCategory: { type: String, required: false },
  remaining: {
    type: Number,
    default: function () {
      return !isNaN(this.budgetAmount - this.allocatedAmount)
        ? this.budgetAmount - this.allocatedAmount
        : 0;
    }
  },
  startDate: { type: Date, default: Date.now },
  spendHistory: [
    {
      date: { type: Date, default: Date.now },
      allocatedAmount: { type: Number, required: true }
    }
  ]
});

const ExpenseSchema = new mongoose.Schema({
  plaidTransactionId: { type: String, unique: true, sparse: true },
  category: { type: String, required: true },
  amount: { type: Number, required: true },
  description: { type: String },
  date: { type: Date, default: Date.now },
  bankAccount: { type: String },
  isRecurring: { type: Boolean, default: false },
  recurrenceInterval: {
    type: String,
    enum: ['daily', 'weekly', 'monthly', 'yearly'],
    default: null
  },
  nextOccurrence: { type: Date },
  chartConfig: {
    chartType: { type: String, default: 'line' }, 
    lineColor: { type: String, default: '#000000' }
  }
});

const IncomeSchema = new mongoose.Schema({
  name: { type: String, required: true },
  type: {
    type: String,
    required: true,
    enum: ['Monthly', 'Weekly', 'Annually', 'monthly', 'weekly', 'annually', 'Monthly Income']
  },
  amount: { type: Number, required: true },
  paymentDate: { type: Date, default: Date.now },
  description: { type: String },
  plaidTransactionId: { type: String }
}, { timestamps: true });

const CategoryEntrySchema = new mongoose.Schema({
  category: { type: String, required: true },
  amount: { type: Number, required: true }
});

const CashFlowSchema = new mongoose.Schema({
  month: { type: String, required: true },
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  
  incomeBreakdown: { type: [CategoryEntrySchema], default: [] },
  expenseBreakdown: { type: [CategoryEntrySchema], default: [] },
  
  totalIncome: { type: Number, default: 0 },
  totalExpenses: { type: Number, default: 0 },
  netCashFlow: { type: Number, default: 0 },
  
  income: { type: Number, required: true, default: 0 },
  expenses: { type: Number, required: true, default: 0 },
  cashflow: { 
    type: Number, 
    default: function () { return this.income - this.expenses; } 
  },
  
  lastUpdated: { type: Date, default: Date.now }
});

CashFlowSchema.pre('save', function(next) {
  if (this.month && (this.incomeBreakdown.length > 0 || this.expenseBreakdown.length > 0)) {
    this.totalIncome = this.incomeBreakdown.reduce((sum, entry) => sum + entry.amount, 0);
    this.totalExpenses = this.expenseBreakdown.reduce((sum, entry) => sum + entry.amount, 0);
    this.netCashFlow = this.totalIncome - this.totalExpenses;
  } else {
    this.totalIncome = this.income;
    this.totalExpenses = this.expenses;
    this.netCashFlow = this.cashflow || (this.income - this.expenses);
    if (this.incomeBreakdown.length === 0) {
      this.incomeBreakdown.push({ category: 'Total Income', amount: this.income });
    }
    if (this.expenseBreakdown.length === 0) {
      this.expenseBreakdown.push({ category: 'Total Expenses', amount: this.expenses });
    }
  }
  this.lastUpdated = Date.now();
  next();
});


const AssetLiabilitySchema = new mongoose.Schema({
  type: { type: String, required: true },
  name: { type: String, required: true },
  amount: { type: Number, required: true },
  percentage: { type: String, default: "0%" }
});

const HistoricalTrendSchema = new mongoose.Schema({
  year: { type: Number, required: true },
  value: { type: Number, required: true }
});

const NetWorthSchema = new mongoose.Schema({
  totalNetWorth: { type: Number, default: 0 },
  totalAssets: { type: Number, default: 0 },
  totalLiabilities: { type: Number, default: 0 },
  assets: { type: [AssetLiabilitySchema], default: [] },
  liabilities: { type: [AssetLiabilitySchema], default: [] },
  historicalTrend: { type: [HistoricalTrendSchema], default: [] }
});

const TransactionSchema = new mongoose.Schema({
  plaidTransactionId: { type: String, unique: true },
  title: { type: String, required: true },
  amount: { type: Number, required: true },
  date: { type: Date, default: Date.now },
  isPositive: { type: Boolean, default: true },
  category: { type: String, default: 'General' },
  bankAccount: { type: String }
});

const InvestmentItemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  amount: { type: Number, required: true },
  quantity: { type: Number, required: true }
}, { _id: true }); // ensure each item gets its own _id

const InvestmentSchema = new mongoose.Schema({
  totalInvestments: { type: Number, default: 0 },
  investmentTypes: [{
    investmentType: { type: String },
    amount: { type: Number, default: 0 }
  }],
  crypto: { type: [InvestmentItemSchema], default: [] },
  stocks: { type: [InvestmentItemSchema], default: [] }
}, { _id: true });

// --- Updated User Schema ---
const userSchema = new mongoose.Schema({
  fullName: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true },
  profilePicture: { type: String },
  phoneNumber: { type: String, required: false, unique: true },
  dateOfBirth: { type: Date },
  password: { type: String, required: true, select: false },
  plaidAccessToken: { type: String },
  plaid: [PlaidSchema],
  bankAccounts: [BankAccountSchema],
  budgets: [BudgetSchema],
  expenses: [ExpenseSchema],
  incomes: [IncomeSchema],
  cashFlows: [CashFlowSchema],
  netWorth: [NetWorthSchema],
  transactions: [TransactionSchema],
  investments: [InvestmentSchema],
  // New Categories field added
  categories: [
    {
      categoryName: { type: String, required: true },
      description: { type: String, default: '' }
    }
  ]
}, { timestamps: true });

userSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

userSchema.methods.comparePassword = async function(password) {
  return await bcrypt.compare(password, this.password);
};

userSchema.methods.getJWTToken = function() {
  return jwt.sign({ id: this._id, email: this.email }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || '7d'
  });
};

const User = mongoose.model('User', userSchema);
module.exports = User;
