const express = require('express');
const router = express.Router();
const userController = require('../controllers/authController');
const authenticateJWT = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');
const User = require('../models/User');
const { validateExpense } = require('../validations/expenseValidation');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads'),
  filename: (req, file, cb) =>
    cb(null, `${req.user.id}-${Date.now()}-${file.originalname}`)
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    if (!['.png', '.jpg', '.jpeg'].includes(ext)) {
      return cb(new Error('Only images are allowed'));
    }
    cb(null, true);
  }
});

// PROFILE ROUTES
router.get('/:userId/profile/get', authenticateJWT, userController.getProfile);
router.put('/:userId/profile/update', authenticateJWT, upload.single('profilePicture'), userController.updateProfile);
router.post('/:userId/profile/create', authenticateJWT, upload.single('profilePicture'), userController.createProfile);
router.delete('/:userId/profile/delete', authenticateJWT, userController.deleteProfile);

// Authentication Routes
router.post('/signup', userController.signup);
router.post('/signin', userController.signIn);
router.post('/logout', authenticateJWT, userController.logout);
router.post('/validate-token', userController.validateToken);
router.get('/:userId', authenticateJWT, userController.getUserWithDetails);

// Plaid Integration
router.post('/link-token', authenticateJWT, userController.createLinkToken);
router.post('/exchange-token', authenticateJWT, userController.exchangePublicToken);
router.post('/identity', authenticateJWT, userController.getIdentity);
router.get('/:userId/accounts', authenticateJWT, userController.getAccounts);
router.post('/create-identity', authenticateJWT, userController.createIdentity);

// Transactions
router.post('/:userId/transactions', authenticateJWT, userController.createTransaction);
router.get('/:userId/transactions', authenticateJWT, userController.getTransactions);
router.get('/:userId/transactions/:transactionId', authenticateJWT, userController.getTransactionById);
router.put('/:userId/transactions/:transactionId', authenticateJWT, userController.updateTransaction);
router.delete('/:userId/transactions/:transactionId', authenticateJWT, userController.deleteTransaction);

// Budget Management
router.post('/:userId/budget', authenticateJWT, userController.addBudget);
router.put('/:userId/budget/:budgetId', authenticateJWT, userController.updateBudget);
router.delete('/:userId/budget/:budgetId', authenticateJWT, userController.deleteBudget);
router.get('/:userId/budget/:budgetId', authenticateJWT, userController.getBudget);
router.get('/:userId/budgets', authenticateJWT, userController.getAllBudgets);
router.get('/:userId/budgets/grouped', authenticateJWT, userController.getGroupedBudgets);
router.get('/:userId/budgets/category/:category', authenticateJWT, userController.getBudgetsByCategory);
router.get('/:userId/budget/:budgetId/history', authenticateJWT, userController.getBudgetSpendHistory);
router.post('/:userId/budget/sync-plaid', authenticateJWT, userController.syncPlaidBudgets);

router.post('/:userId/categories',authenticateJWT, userController.addCategory);
router.get('/:userId/categories', authenticateJWT, userController.getCategories);

// Expense Management
router.post('/:userId/expense', authenticateJWT, validateExpense, userController.addExpense);
router.get('/:userId/expense/:expenseId', authenticateJWT, userController.getExpense);
router.put('/:userId/expense/:expenseId', authenticateJWT, validateExpense, userController.updateExpense);
router.delete('/:userId/expense/:expenseId', authenticateJWT, userController.deleteExpense);
router.get('/:userId/expenses', authenticateJWT, userController.getAllExpenses);
router.get('/:userId/expenses/month', authenticateJWT, userController.getExpensesByMonth);
router.get('/:userId/expenses/summary', authenticateJWT, userController.getExpenseSummary);
router.get('/:userId/expenses/summary-advanced', authenticateJWT, userController.getAdvancedExpenseSummary);
router.post('/:userId/expense/sync-plaid', authenticateJWT, userController.syncPlaidTransactionToExpense);
router.get('/:userId/expenses/filtered', authenticateJWT, userController.getExpensesFiltered);
router.get('/:userId/expense/:expenseId/chart-config', authenticateJWT, userController.getExpenseChartConfig);
router.put('/:userId/expense/:expenseId/chart-config', authenticateJWT, userController.updateExpenseChartConfig);

// Income Management
router.post('/:userId/income', authenticateJWT, userController.addIncome);
router.put('/:userId/income/:incomeId', authenticateJWT, userController.updateIncome);
router.delete('/:userId/income/:incomeId', authenticateJWT, userController.deleteIncome);
router.get('/:userId/income/:incomeId', authenticateJWT, userController.getIncome);
router.get('/:userId/incomes', authenticateJWT, userController.getAllIncomes);
router.post('/:userId/income/sync-plaid', authenticateJWT, userController.syncPlaidIncomes);
router.get('/:userId/income-summary', authenticateJWT, userController.getIncomeSummary);
router.post('/:userId/income/fix-types', authenticateJWT, userController.fixIncomeTypes);
router.get('/:userId/income-by-category', authenticateJWT, userController.getIncomeByCategory);

// Cash Flow Management
router.post('/:userId/cashflow', authenticateJWT, userController.addCashFlow);
router.put('/:userId/cashflow/:cashFlowId', authenticateJWT, userController.updateCashFlow);
router.delete('/:userId/cashflow/:cashFlowId', authenticateJWT, userController.deleteCashFlow);
router.get('/:userId/cashflows', authenticateJWT, userController.getAllCashFlows);
router.get('/:userId/cashflow-details', authenticateJWT, userController.getCashFlowDetails);
router.get('/:userId/cashflow-summary', authenticateJWT, userController.getCashFlowSummary);
router.post('/:userId/sync-plaid', authenticateJWT, userController.syncPlaidCashFlow);

// Net Worth Management
router.get('/:userId/networth', authenticateJWT, userController.getAllNetWorthData);
router.post('/:userId/networth', authenticateJWT, userController.createNetWorthData);
router.put('/:userId/networth', authenticateJWT, userController.updateNetWorthData);
router.delete('/:userId/networth', authenticateJWT, userController.deleteNetWorthData);
router.post('/:userId/networth/sync-plaid', authenticateJWT, userController.syncPlaidNetWorthData);

// Investment Management
router.get('/:userId/investments', authenticateJWT, userController.getInvestmentData);
router.post('/:userId/investments', authenticateJWT, userController.addInvestmentData);
router.put('/:userId/investments/:investmentId', authenticateJWT, userController.updateInvestmentData);
router.delete('/:userId/investments', authenticateJWT, userController.deleteInvestmentData);
router.delete('/:userId/investments/:investmentId', authenticateJWT, userController.deleteSingleInvestment);
router.post('/:userId/investments/sync-plaid', authenticateJWT, userController.syncPlaidInvestments);
router.get('/:userId/investments/debug', authenticateJWT, userController.debugInvestments);

module.exports = router;
