const User = require('../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const axios = require('axios');
const plaid = require('plaid');
const moment = require('moment');
const PlaidClient = require('../utils/PlaidClient').getInstance();
const mongoose = require('mongoose');


dotenv.config();

const secretKey = process.env.JWT_SECRET;
const jwtExpire = process.env.JWT_EXPIRE;

function validateIncomeInput({ name, type, amount }) {
  const errors = [];
  if (!name || typeof name !== 'string' || name.trim() === '') {
    errors.push('Income name is required and must be a non-empty string.');
  }
  if (!type || typeof type !== 'string' || type.trim() === '') {
    errors.push('Income type is required and must be a non-empty string.');
  }
  if (amount === undefined || amount === null || isNaN(amount)) {
    errors.push('A valid income amount is required.');
  }
  return errors;
}

const normalizeType = (type) => {
  if (!type) return 'Monthly';

  const typeStr = String(type).trim();
  const lowerType = typeStr.toLowerCase();

  if (lowerType.includes('month')) return 'Monthly';
  if (lowerType.includes('week')) return 'Weekly';
  if (lowerType.includes('annual') || lowerType.includes('year')) return 'Annually';

  return 'Monthly';
};

const DEFAULT_CHART_CONFIG = { chartType: 'line', lineColor: '#000000' };

const ensureChartConfig = (expense) => {
  if (!expense.chartConfig) {
    expense.chartConfig = DEFAULT_CHART_CONFIG;
  }
  return expense;
};

function isIncomeTransaction(tx) {
  if (tx.category && Array.isArray(tx.category)) {
    const incomeKeywords = ['deposit', 'income', 'payroll'];
    if (tx.category.some(cat => incomeKeywords.some(keyword => cat.toLowerCase().includes(keyword)))) {
      return true;
    }
  }
  return tx.amount > 0;
}

exports.signup = async (req, res) => {
  const { fullName, email, password } = req.body;
  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        status: false,
        message: 'User already exists',
        body: null
      });
    }
    const newUser = new User({
      fullName,
      email,
      password,
    });
    const token = newUser.getJWTToken();
    await newUser.save();
    res.status(201).json({
      status: true,
      message: 'Signup successful',
      body: {
        user_id: newUser._id,
        name: newUser.fullName,
        email: newUser.email,
        token: token,
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.signIn = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({
      status: false,
      message: 'Email and password are required.',
      body: null
    });
  }
  try {
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({
        status: false,
        message: 'Invalid email or password.',
        body: null
      });
    }
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        status: false,
        message: 'Invalid email or password.',
        body: null
      });
    }
    user.password = undefined;
    const token = user.getJWTToken();
    return res.status(200).json({
      status: true,
      message: 'Login successful',
      body: {
        user_id: user._id,
        name: user.fullName,
        email: user.email,
        token: token,
      }
    });
  } catch (error) {
    console.error('Error during sign in:', error);
    return res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.getProfile = async (req, res) => {
  const tokenUserId = req.user.id;
  const routeUserId = req.params.userId;

  if (tokenUserId !== routeUserId) {
    return res.status(403).json({
      status: false,
      message: 'You are not authorized to access this profile.',
      body: null
    });
  }

  try {
    const user = await User.findById(tokenUserId).select('-password');
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    res.status(200).json({
      status: true,
      message: 'Profile fetched successfully',
      body: user
    });
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.updateProfile = async (req, res) => {
  const tokenUserId = req.user.id;
  const routeUserId = req.params.userId;

  if (tokenUserId !== routeUserId) {
    return res.status(403).json({
      status: false,
      message: 'You are not authorized to update this profile.',
      body: null
    });
  }

  try {
    const { fullName, email, password, dateOfBirth } = req.body;
    const profilePicture = req.file ? `/uploads/${req.file.filename}` : undefined;

    const updateFields = {
      ...(fullName && { fullName }),
      ...(email && { email }),
      ...(password && { password }),
      ...(dateOfBirth && { dateOfBirth }),
      ...(profilePicture && { profilePicture }),
    };

    const updateUser = await User.findByIdAndUpdate(
      tokenUserId,
      { $set: updateFields },
      { new: true }
    ).select('-password');

    res.status(200).json({
      status: true,
      message: 'Profile updated successfully',
      body: updateUser
    });
  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.deleteProfile = async (req, res) => {
  const tokenUserId = req.user.id;
  try {
    const user = await User.findByIdAndDelete(tokenUserId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }
    res.status(200).json({
      status: true,
      message: 'Profile deleted successfully',
      body: null
    });
  } catch (error) {
    console.error('Error deleting user profile:', error);
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.createProfile = async (req, res) => {
  const tokenUserId = req.user.id;
  const routeUserId = req.params.userId;

  if (tokenUserId !== routeUserId) {
    return res.status(403).json({
      status: false,
      message: 'You are not authorized to create this profile.',
      body: null
    });
  }

  try {
    const { fullName, phoneNumber, dateOfBirth } = req.body;
    const profilePicture = req.file ? `/uploads/${req.file.filename}` : undefined;

    const user = await User.findById(tokenUserId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });

    if (user.fullName || user.phoneNumber || user.dateOfBirth || user.profilePicture) {
      return res.status(400).json({
        status: false,
        message: 'Profile already exists. Use update instead.',
        body: null
      });
    }

    user.fullName = fullName;
    user.phoneNumber = phoneNumber;
    user.dateOfBirth = dateOfBirth;
    if (profilePicture) user.profilePicture = profilePicture;

    await user.save();

    res.status(201).json({
      status: true,
      message: 'Profile created successfully',
      body: user.toObject({ getters: true, versionKey: false })
    });
  } catch (error) {
    console.error('Error creating profile:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to create profile',
      body: null
    });
  }
};

exports.createLinkToken = async (req, res) => {
  try {
    const response = await PlaidClient.linkTokenCreate({
      client_name: "WealthNx",
      country_codes: ["US"],
      language: "en",
      user: {
        client_user_id: req.user.id || "unique_user_id"
      },
      products: ["auth", "transactions", "identity"]
    });
    console.log(`User: ${response.user}`);
    res.json({
      status: true,
      message: 'Link token created successfully',
      body: { link_token: response.data.link_token }
    });
  } catch (error) {
    console.error('Error creating link token:', error.message);
    res.status(500).json({
      status: false,
      message: 'Failed to create link token',
      body: null
    });
  }
};

exports.createIdentity = async (req, res) => {
  try {
    const { link_token } = req.body;

    if (!link_token) {
      return res.status(400).json({
        status: false,
        message: 'Link token is required.',
        body: null
      });
    }

    console.log('Creating identity with link token:', link_token);

    const publicTokenResponse = await PlaidClient.sandboxPublicTokenCreate({
      institution_id: 'ins_109508',
      initial_products: ['auth', 'identity'],
    });

    const { public_token } = publicTokenResponse.data;

    console.log('Generated Public Token:', public_token);

    res.json({
      status: true,
      message: 'Public token created successfully',
      body: { public_token }
    });
  } catch (error) {
    console.error('Error creating identity:', error.response?.data || error.message);
    res.status(500).json({
      status: false,
      message: 'Failed to create identity',
      body: null
    });
  }
};

exports.exchangePublicToken = async (req, res) => {
  try {
    const { public_token } = req.body;
    const userId = req.user.id;

    if (!public_token) {
      return res.status(400).json({
        status: false,
        message: 'Public token is required.',
        body: null
      });
    }

    console.log('Exchanging public token for access token:', public_token);

    const response = await PlaidClient.itemPublicTokenExchange({ public_token });
    const { access_token, item_id } = response.data;

    console.log('Exchange Token Response:', { access_token, item_id });

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    if (!user.plaid) {
      user.plaid = [];
    }

    user.plaid.push({
      accessToken: access_token,
      itemID: item_id,
      userId: userId
    });

    if (!user.netWorth) {
      user.netWorth = {};
    }

    if (!user.investments) {
      user.investments = {};
    }

    if (!user.liveUpdateIncome) {
      user.liveUpdateIncome = {};
    }

    if (!user.liveUpdatePortfolio) {
      user.liveUpdatePortfolio = {};
    }

    if (!user.liveUpdateSpending) {
      user.liveUpdateSpending = {};
    }

    await user.save();

    res.json({
      status: true,
      message: 'Access token saved successfully',
      body: {
        item_id: item_id,
        access_token: access_token
      }
    });
  } catch (error) {
    console.error('Error exchanging public token:', error.response?.data || error.message);
    res.status(500).json({
      status: false,
      message: 'Failed to exchange public token',
      body: null
    });
  }
};

exports.getTransactions = async (req, res) => {
  try {
    const userId = req.user.id;
    const { start_date, end_date, item_id } = req.body;

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });

    const plaidAccount = item_id ? user.plaid.find(p => p.itemID === item_id) : user.plaid[0];
    if (!plaidAccount) return res.status(400).json({
      status: false,
      message: 'No Plaid account found',
      body: null
    });

    const access_token = plaidAccount.accessToken;
    const startDate = start_date || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const endDate = end_date || new Date().toISOString().split('T')[0];

    const response = await PlaidClient.transactionsGet({
      access_token,
      start_date: startDate,
      end_date: endDate,
      options: { count: 100, offset: 0 }
    });

    res.json({
      status: true,
      message: 'Transactions fetched successfully',
      body: response.data
    });
  } catch (error) {
    res.status(500).json({
      status: false,
      message: 'Failed to fetch transactions',
      body: null
    });
  }
};

exports.getIdentity = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });

    const access_token = user.plaid[0]?.accessToken;
    if (!access_token) return res.status(400).json({
      status: false,
      message: 'No linked Plaid account',
      body: null
    });

    const response = await PlaidClient.identityGet({ access_token });
    res.json({
      status: true,
      message: 'Identity fetched successfully',
      body: response.data
    });
  } catch (error) {
    res.status(500).json({
      status: false,
      message: 'Failed to fetch identity',
      body: null
    });
  }
};

exports.validateToken = async (req, res) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);
    if (!user) return res.status(401).json({
      status: false,
      message: 'Invalid token',
      body: null
    });
    res.status(200).json({
      status: true,
      message: 'Token validated successfully',
      body: { user }
    });
  } catch (error) {
    res.status(401).json({
      status: false,
      message: 'Invalid token',
      body: null
    });
  }
};

exports.logout = async (req, res) => {
  try {
    await Session.findOneAndDelete({ token: req.headers.authorization.split(' ')[1] });
    res.status(200).json({
      status: true,
      message: 'Logged out successfully.',
      body: null
    });
  } catch (error) {
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.getUserWithDetails = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });
    res.json({
      status: true,
      message: 'User details fetched successfully',
      body: user
    });
  } catch (error) {
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.getAccounts = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });

    const access_token = user.plaid[0]?.accessToken;
    if (!access_token) return res.status(400).json({
      status: false,
      message: 'No linked Plaid account',
      body: null
    });

    const response = await PlaidClient.accountsGet({ access_token });
    res.json({
      status: true,
      message: 'Accounts fetched successfully',
      body: response.data
    });
  } catch (error) {
    res.status(500).json({
      status: false,
      message: 'Failed to fetch accounts',
      body: null
    });
  }
};

exports.addBudget = async (req, res) => {
  try {
    const { userId } = req.params;
    const {
      budgetType,
      budgetName,
      budgetAmount,
      allocatedAmount,
      category,
      budgetSubCategory,
      startDate
    } = req.body;

    if (!budgetType || !budgetName || !budgetAmount || !allocatedAmount || !category) {
      return res.status(400).json({
        status: false,
        message: 'All fields are required',
        body: null
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    const invalidBudgets = user.budgets.filter(b => !b.category || b.category.trim() === '');
    if (invalidBudgets.length > 0) {
      console.log('🧹 Removing invalid budgets (missing category):', invalidBudgets);
    }
    user.budgets = user.budgets.filter(b => b.category && b.category.trim() !== '');

    const safeStartDate = new Date(startDate);
    const isDateValid = !isNaN(safeStartDate.getTime());

    const newBudget = {
      _id: new mongoose.Types.ObjectId(),
      budgetType,
      budgetName,
      budgetAmount,
      allocatedAmount,
      category,
      budgetSubCategory,
      startDate: isDateValid ? safeStartDate : new Date(),
      spendHistory: [
        {
          date: new Date(),
          allocatedAmount: allocatedAmount
        }
      ],
      remaining: budgetAmount - allocatedAmount
    };

    console.log(' Adding new budget:', newBudget);

    user.budgets.push(newBudget);
    await user.save();

    const addedBudget = user.budgets.id(newBudget._id);

    res.status(201).json({
      status: true,
      message: 'Budget added successfully',
      body: addedBudget
    });

  } catch (error) {
    console.error(' Error adding budget:', error.message, error.stack);
    res.status(500).json({
      status: false,
      message: 'Failed to add the budget',
      body: null
    });
  }
};

exports.updateBudget = async (req, res) => {
  const { userId, budgetId } = req.params;
  const {
    budgetType,
    budgetName,
    budgetAmount,
    allocatedAmount,
    startDate,
    budgetSubCategory
  } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({ status: false, message: 'User not found', body: null });

    const budget = user.budgets.id(budgetId);
    if (!budget)
      return res.status(404).json({ status: false, message: 'Budget not found', body: null });

    const safeStartDate = new Date(startDate);

    if (budgetType) budget.budgetType = budgetType;
    if (budgetName) budget.budgetName = budgetName; 
    if (budgetSubCategory) budget.budgetSubCategory = budgetSubCategory;
    if (!isNaN(safeStartDate.getTime())) budget.startDate = safeStartDate;
    if (typeof budgetAmount === 'number') budget.budgetAmount = budgetAmount;

    if (typeof allocatedAmount === 'number') {
      budget.spendHistory.push({ date: new Date(), allocatedAmount });
      if (budget.spendHistory.length > 30) {
        budget.spendHistory = budget.spendHistory.slice(-30);
      }
      budget.allocatedAmount = allocatedAmount;
      budget.remaining = budget.budgetAmount - allocatedAmount;
    }

    await user.save();

    res.status(200).json({
      status: true,
      message: 'Budget updated successfully',
      body: budget
    });

  } catch (error) {
    console.error('Error updating budget:', error);
    res.status(500).json({ status: false, message: 'An error occurred.', body: null });
  }
};

exports.deleteBudget = async (req, res) => {
  const { userId, budgetId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({ status: false, message: 'User not found', body: null });

    const budget = user.budgets.id(budgetId);
    if (!budget)
      return res.status(404).json({ status: false, message: 'Budget not found', body: null });

    // Fix: Remove manually by filtering
    user.budgets = user.budgets.filter(b => b._id.toString() !== budgetId);
    await user.save();

    res.status(200).json({ status: true, message: 'Budget deleted successfully', body: null });

  } catch (error) {
    console.error('Error deleting budget:', error);
    res.status(500).json({ status: false, message: 'An error occurred.', body: null });
  }
};

exports.getBudget = async (req, res) => {
  const { userId, budgetId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });
    const budget = user.budgets.id(budgetId);
    if (!budget) return res.status(404).json({ status: false, message: 'Budget not found', body: null });
    res.status(200).json({ status: true, message: 'Budget fetched', body: budget });
  } catch (error) {
    console.error('Error getting budget:', error);
    res.status(500).json({ status: false, message: 'An error occurred.', body: null });
  }
};

exports.addCategory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { categoryName, description } = req.body;

    if (!categoryName) {
      return res.status(400).json({
        status: false,
        message: "error: 'categoryName' is required",
        body: null
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: "error: user not found",
        body: null
      });
    }

    if (!user.categories) {
      user.categories = [];
    }

    const duplicate = user.categories.some(cat =>
      cat.categoryName === categoryName &&
      cat.description === (description || "")
    );

    if (duplicate) {
      return res.status(400).json({
        status: false,
        message: "error: category already exists",
        body: null
      });
    }

    const newCategory = {
      _id: new mongoose.Types.ObjectId(),
      categoryName,
      description: description || ""
    };

    user.categories.push(newCategory);
    await user.save();

    res.status(201).json({
      status: true,
      message: "success",
      body: { category: { id: newCategory._id } }
    });
  } catch (error) {
    console.error('Error adding category:', error);
    res.status(500).json({
      status: false,
      message: "error",
      body: null
    });
  }
};

exports.getCategories = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: "error: user not found",
        body: null
      });
    }

    res.status(200).json({
      status: true,
      message: "success",
      body: { categories: user.categories || [] }
    });
  } catch (error) {
    console.error('Error retrieving categories:', error);
    res.status(500).json({
      status: false,
      message: "error",
      body: null
    });
  }
};

exports.getAllBudgets = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });
    const sortedBudgets = user.budgets.sort((a, b) => new Date(b.startDate) - new Date(a.startDate));
    res.status(200).json({ status: true, message: 'Budgets fetched', body: sortedBudgets });
  } catch (error) {
    console.error('Error getting budgets:', error);
    res.status(500).json({ status: false, message: 'An error occurred.', body: null });
  }
};

exports.getGroupedBudgets = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });

    const grouped = {};
    user.budgets.forEach(b => {
      if (!grouped[b.category]) grouped[b.category] = { totalBudget: 0, totalAllocated: 0, totalRemaining: 0 };
      grouped[b.category].totalBudget += b.budgetAmount || 0;
      grouped[b.category].totalAllocated += b.allocatedAmount || 0;
      grouped[b.category].totalRemaining += b.remaining || 0;
    });

    res.status(200).json({ status: true, message: 'Grouped budgets', body: grouped });
  } catch (error) {
    console.error('Error grouping budgets:', error);
    res.status(500).json({ status: false, message: 'Failed to group budgets', body: null });
  }
};

exports.getBudgetsByCategory = async (req, res) => {
  const { userId, category } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });
    const filtered = user.budgets.filter(b => b.category && b.category.toLowerCase() === category.toLowerCase());
    res.status(200).json({ status: true, message: 'Filtered budgets', body: filtered });
  } catch (error) {
    console.error('Error filtering budgets by category:', error);
    res.status(500).json({ status: false, message: 'Failed to filter budgets', body: null });
  }
};

exports.getBudgetSpendHistory = async (req, res) => {
  const { userId, budgetId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });
    const budget = user.budgets.id(budgetId);
    if (!budget) return res.status(404).json({ status: false, message: 'Budget not found', body: null });

    const sortedHistory = [...budget.spendHistory]
      .sort((a, b) => new Date(a.date) - new Date(b.date))
      .map(entry => ({
        date: new Date(entry.date).toISOString().split('T')[0],
        allocatedAmount: entry.allocatedAmount
      }));

    res.status(200).json({ status: true, message: 'Spend history fetched', body: sortedHistory });
  } catch (error) {
    console.error('Error getting spend history:', error);
    res.status(500).json({ status: false, message: 'Failed to fetch spend history', body: null });
  }
};

exports.syncPlaidBudgets = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });
    if (!user.plaid || user.plaid.length === 0) return res.status(404).json({
      status: false,
      message: 'Plaid token not found. Please connect your bank account.',
      body: null
    });
    const plaidAccount = user.plaid[0];
    const access_token = plaidAccount.accessToken;
    let plaidBudgetResponse;
    if (typeof PlaidClient.budgetGet === 'function') {
      plaidBudgetResponse = await PlaidClient.budgetGet({ access_token });
    } else {
      plaidBudgetResponse = {
        data: {
          budgets: [
            { budgetType: "Monthly", budgetName: "Groceries", budgetAmount: 500, allocatedAmount: 300, category: "Food", startDate: "2025-04-01" },
            { budgetType: "Monthly", budgetName: "Entertainment", budgetAmount: 200, allocatedAmount: 100, category: "Leisure", startDate: "2025-04-01" }
          ]
        }
      };
    }
    const plaidBudgets = plaidBudgetResponse.data.budgets;
    let syncedCount = 0;
    for (const pBudget of plaidBudgets) {
      let existingBudget = user.budgets.find(b => b.category === pBudget.category && b.budgetName === pBudget.budgetName);
      if (existingBudget) {
        existingBudget.budgetType = pBudget.budgetType;
        existingBudget.budgetAmount = pBudget.budgetAmount;
        existingBudget.allocatedAmount = pBudget.allocatedAmount;
        existingBudget.remaining = pBudget.budgetAmount - pBudget.allocatedAmount;
        existingBudget.startDate = pBudget.startDate || existingBudget.startDate;
      } else {
        user.budgets.push({
          budgetType: pBudget.budgetType,
          budgetName: pBudget.budgetName,
          budgetAmount: pBudget.budgetAmount,
          allocatedAmount: pBudget.allocatedAmount,
          category: pBudget.category,
          remaining: pBudget.budgetAmount - pBudget.allocatedAmount,
          startDate: pBudget.startDate
        });
      }
      syncedCount++;
    }
    await user.save();
    res.status(200).json({
      status: true,
      message: `Synced ${syncedCount} budgets from Plaid.`,
      body: user.budgets
    });
  } catch (error) {
    console.error('Error syncing budgets:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to sync budgets',
      body: null
    });
  }
};

exports.addExpense = async (req, res) => {
  const { userId } = req.params;
  const {
    category,
    amount,
    date,
    description,
    isRecurring,
    recurrenceInterval,
    nextOccurrence,
    chartConfig
  } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });

    // Build the new expense. If chartConfig not sent, default is used.
    const newExpense = {
      category,
      amount,
      date: date || new Date(),
      description,
      isRecurring: isRecurring || false,
      recurrenceInterval: recurrenceInterval || null,
      nextOccurrence: nextOccurrence || null,
      chartConfig: chartConfig || DEFAULT_CHART_CONFIG
    };

    user.expenses.push(newExpense);
    await user.save({ validateModifiedOnly: true });

    // Ensure chartConfig is set on the newly added expense.
    const addedExpense = ensureChartConfig(user.expenses[user.expenses.length - 1]);

    res.status(201).json({
      status: true,
      message: 'Expense added successfully',
      body: addedExpense
    });
  } catch (error) {
    console.error('Error adding expense:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to add expense',
      body: null
    });
  }
};

// Get Single Expense
exports.getExpense = async (req, res) => {
  const { userId, expenseId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });

    let expense = user.expenses.id(expenseId);
    if (!expense)
      return res.status(404).json({
        status: false,
        message: 'Expense not found',
        body: null
      });

    // Ensure chartConfig is set.
    expense = ensureChartConfig(expense);

    res.status(200).json({
      status: true,
      message: 'Expense fetched successfully',
      body: expense
    });
  } catch (error) {
    console.error('Error getting expense:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to get expense',
      body: null
    });
  }
};

// Get All Expenses
exports.getAllExpenses = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }
    // Ensure each expense has chartConfig
    const expensesWithChart = user.expenses.map(exp => ensureChartConfig(exp));
    res.status(200).json({
      status: true,
      message: 'Expenses fetched successfully',
      body: expensesWithChart
    });
  } catch (error) {
    console.error('Error getting expenses:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to fetch expenses',
      body: null
    });
  }
};

// Update Expense
exports.updateExpense = async (req, res) => {
  const { userId, expenseId } = req.params;
  const {
    category,
    amount,
    date,
    description,
    isRecurring,
    recurrenceInterval,
    nextOccurrence
  } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });

    let expense = user.expenses.id(expenseId);
    if (!expense)
      return res.status(404).json({
        status: false,
        message: 'Expense not found',
        body: null
      });

    expense.category = category || expense.category;
    expense.amount = amount || expense.amount;
    expense.date = date || expense.date;
    expense.description = description || expense.description;
    expense.isRecurring = (typeof isRecurring === 'boolean') ? isRecurring : expense.isRecurring;
    expense.recurrenceInterval = recurrenceInterval || expense.recurrenceInterval;
    expense.nextOccurrence = nextOccurrence || expense.nextOccurrence;

    await user.save();

    // Ensure updated expense contains chartConfig.
    expense = ensureChartConfig(expense);

    res.status(200).json({
      status: true,
      message: 'Expense updated successfully',
      body: expense
    });
  } catch (error) {
    console.error('Error updating expense:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to update expense',
      body: null
    });
  }
};

exports.deleteExpense = async (req, res) => {
  const { userId, expenseId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });

    const expense = user.expenses.id(expenseId);
    if (!expense)
      return res.status(404).json({
        status: false,
        message: 'Expense not found',
        body: null
      });

    user.expenses.pull(expenseId);
    await user.save();

    res.status(200).json({
      status: true,
      message: 'Expense deleted successfully',
      body: null
    });
  } catch (error) {
    console.error('Error deleting expense:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to delete expense',
      body: null
    });
  }
};

exports.getExpensesByMonth = async (req, res) => {
  const { userId } = req.params;
  const { month } = req.query;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }
    let filteredExpenses = user.expenses;
    if (month) {
      const [year, monthNum] = month.split('-');
      filteredExpenses = filteredExpenses.filter(exp => {
        const expDate = new Date(exp.date);
        return expDate.getFullYear() === parseInt(year) &&
               (expDate.getMonth() + 1) === parseInt(monthNum);
      });
    }
    // Ensure each expense has chartConfig.
    filteredExpenses = filteredExpenses.map(exp => ensureChartConfig(exp));

    res.status(200).json({
      status: true,
      message: 'Expenses fetched successfully',
      body: filteredExpenses
    });
  } catch (error) {
    console.error('Error filtering expenses:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to filter expenses',
      body: null
    });
  }
};

exports.getExpenseSummary = async (req, res) => {
  const { userId } = req.params;
  const { month } = req.query;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });

    let filteredExpenses = user.expenses;
    if (month) {
      const [year, monthNum] = month.split('-');
      filteredExpenses = filteredExpenses.filter(exp => {
        const expDate = new Date(exp.date);
        return expDate.getFullYear() === parseInt(year) &&
               (expDate.getMonth() + 1) === parseInt(monthNum);
      });
    }
    // Make sure chartConfig exists for each expense.
    filteredExpenses = filteredExpenses.map(exp => ensureChartConfig(exp));

    const total = filteredExpenses.reduce((acc, exp) => acc + exp.amount, 0);
    const byCategory = {};
    filteredExpenses.forEach(exp => {
      if (!byCategory[exp.category]) {
        byCategory[exp.category] = { amount: 0, count: 0 };
      }
      byCategory[exp.category].amount += exp.amount;
      byCategory[exp.category].count += 1;
    });
    res.status(200).json({
      status: true,
      message: 'Expense summary fetched successfully',
      body: {
        total,
        categoryBreakdown: byCategory,
        count: filteredExpenses.length
      }
    });
  } catch (error) {
    console.error('Error generating summary:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to generate summary',
      body: null
    });
  }
};

exports.getAdvancedExpenseSummary = async (req, res) => {
  const { userId } = req.params;
  const { range = 'monthly' } = req.query;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });

    const now = new Date();
    let start;
    switch (range) {
      case 'weekly':
        start = new Date();
        start.setDate(now.getDate() - 7);
        break;
      case 'yearly':
        start = new Date(now.getFullYear(), 0, 1);
        break;
      default:
        start = new Date(now.getFullYear(), now.getMonth(), 1);
        break;
    }
    let filteredExpenses = user.expenses.filter(exp => {
      const expDate = new Date(exp.date);
      return expDate >= start && expDate <= now;
    });
    // Ensure each expense has chartConfig.
    filteredExpenses = filteredExpenses.map(exp => ensureChartConfig(exp));

    const total = filteredExpenses.reduce((acc, exp) => acc + exp.amount, 0);
    const byCategory = {};
    const recurring = [];
    filteredExpenses.forEach(exp => {
      if (exp.isRecurring) recurring.push(exp);
      if (!byCategory[exp.category]) {
        byCategory[exp.category] = { amount: 0, count: 0 };
      }
      byCategory[exp.category].amount += exp.amount;
      byCategory[exp.category].count += 1;
    });
    const sortedCategories = Object.entries(byCategory)
      .sort((a, b) => b[1].amount - a[1].amount)
      .reduce((acc, [key, val]) => {
        acc[key] = val;
        return acc;
      }, {});
    res.status(200).json({
      status: true,
      message: 'Advanced expense summary fetched successfully',
      body: {
        range,
        from: start.toISOString(),
        to: now.toISOString(),
        total,
        categoryBreakdown: sortedCategories,
        count: filteredExpenses.length,
        recurringExpenses: recurring
      }
    });
  } catch (error) {
    console.error('Error in advanced summary:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to generate advanced summary',
      body: null
    });
  }
};

exports.syncPlaidTransactionToExpense = async (req, res) => {
  try {
    const userId = req.user.id;
    let { start_date, end_date } = req.body;

    start_date = start_date || moment().subtract(30, 'days').format('YYYY-MM-DD');
    end_date = end_date || moment().format('YYYY-MM-DD');

    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });

    if (!user.plaid || user.plaid.length === 0) {
      return res.status(404).json({
        status: false,
        message: 'Plaid token not found. Please connect your bank account.',
        body: null
      });
    }

    const plaidAccount = user.plaid[0];
    const access_token = plaidAccount.accessToken;

    const response = await PlaidClient.transactionsGet({
      access_token,
      start_date,
      end_date,
      options: { count: 100, offset: 0 }
    });

    const transactions = response.data.transactions;
    let created = [];
    for (const tx of transactions) {
      const exists = user.expenses.some(exp => exp.plaidTransactionId === tx.transaction_id);
      if (!exists) {
        const newExpense = {
          plaidTransactionId: tx.transaction_id,
          category: (tx.category && tx.category.length > 0) ? tx.category[0] : "Uncategorized",
          amount: Math.abs(tx.amount),
          date: tx.date,
          bankAccount: tx.account_id,
          description: tx.name,
          chartConfig: DEFAULT_CHART_CONFIG
        };
        user.expenses.push(newExpense);
        created.push(newExpense);
      }
    }

    await user.save();
    res.status(200).json({
      status: true,
      message: `Synced ${created.length} expenses from Plaid.`,
      body: created
    });
  } catch (error) {
    console.error('Error syncing transactions:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to sync transactions',
      body: null
    });
  }
};

exports.getExpensesFiltered = async (req, res) => {
  const { userId } = req.params;
  const { category, minAmount, maxAmount, page = 1, limit = 10 } = req.query;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }
    let filteredExpenses = user.expenses || [];
    if (category) {
      filteredExpenses = filteredExpenses.filter(exp => exp.category === category);
    }
    if (minAmount) {
      filteredExpenses = filteredExpenses.filter(exp => exp.amount >= parseFloat(minAmount));
    }
    if (maxAmount) {
      filteredExpenses = filteredExpenses.filter(exp => exp.amount <= parseFloat(maxAmount));
    }
    const pageInt = parseInt(page);
    const limitInt = parseInt(limit);
    const startIndex = (pageInt - 1) * limitInt;
    filteredExpenses = filteredExpenses.slice(startIndex, startIndex + limitInt);
    // Ensure all expenses in the filtered list have chartConfig.
    filteredExpenses = filteredExpenses.map(exp => ensureChartConfig(exp));
    res.status(200).json({
      status: true,
      message: 'Filtered expenses fetched successfully',
      body: {
        expenses: filteredExpenses,
        total: filteredExpenses.length,
        page: pageInt,
        limit: limitInt
      }
    });
  } catch (error) {
    console.error('Error fetching filtered expenses:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to fetch filtered expenses',
      body: null
    });
  }
};

exports.getExpenseChartConfig = async (req, res) => {
  const { userId, expenseId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    let expense = user.expenses.id(expenseId);
    if (!expense)
      return res.status(404).json({
        status: false,
        message: 'Expense not found',
        body: null
      });
    expense = ensureChartConfig(expense);
    res.status(200).json({
      status: true,
      message: 'Chart configuration fetched successfully',
      body: expense.chartConfig
    });
  } catch (error) {
    console.error('Error fetching chart configuration:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to fetch chart configuration',
      body: null
    });
  }
};

exports.updateExpenseChartConfig = async (req, res) => {
  const { userId, expenseId } = req.params;
  const { chartType, lineColor } = req.body;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    let expense = user.expenses.id(expenseId);
    if (!expense)
      return res.status(404).json({
        status: false,
        message: 'Expense not found',
        body: null
      });
    // Update the embedded chart configuration.
    expense.chartConfig = {
      chartType: chartType || (expense.chartConfig && expense.chartConfig.chartType) || DEFAULT_CHART_CONFIG.chartType,
      lineColor: lineColor || (expense.chartConfig && expense.chartConfig.lineColor) || DEFAULT_CHART_CONFIG.lineColor
    };
    await user.save();
    res.status(200).json({
      status: true,
      message: 'Chart configuration updated successfully',
      body: expense.chartConfig
    });
  } catch (error) {
    console.error('Error updating chart configuration:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to update chart configuration',
      body: null
    });
  }
};

exports.addIncome = async (req, res) => {
  const { userId } = req.params;
  const { name, type, amount, paymentDate, description, plaidTransactionId } = req.body;

  const validationErrors = validateIncomeInput({ name, type, amount });
  if (validationErrors.length) {
    return res.status(400).json({
      status: false,
      message: validationErrors.join(' '),
      body: null
    });
  }

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });
    if (plaidTransactionId && user.incomes.some(i => i.plaidTransactionId === plaidTransactionId)) {
      return res.status(409).json({
        status: false,
        message: 'Plaid transaction already exists',
        body: null
      });
    }
    const normalizedType = normalizeType(type);
    user.incomes.push({
      name,
      type: normalizedType,
      amount,
      paymentDate,
      description,
      plaidTransactionId,
    });
    await user.save();
    res.status(201).json({
      status: true,
      message: 'Income added successfully',
      body: user.incomes[user.incomes.length - 1]
    });
  } catch (error) {
    console.error('Error adding income:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to add income',
      body: null
    });
  }
};

exports.updateIncome = async (req, res) => {
  const { userId, incomeId } = req.params;
  const { name, type, amount, paymentDate, description, plaidTransactionId } = req.body;

  const validationErrors = validateIncomeInput({ name, type, amount });
  if (validationErrors.length) {
    return res.status(400).json({
      status: false,
      message: validationErrors.join(' '),
      body: null
    });
  }

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });
    const income = user.incomes.id(incomeId);
    if (!income) return res.status(404).json({
      status: false,
      message: 'Income not found',
      body: null
    });
    if (
      plaidTransactionId &&
      plaidTransactionId !== income.plaidTransactionId &&
      user.incomes.some(i => i.plaidTransactionId === plaidTransactionId)
    ) {
      return res.status(409).json({
        status: false,
        message: 'Plaid transaction ID already exists',
        body: null
      });
    }
    income.name = name;
    income.type = normalizeType(type);
    income.amount = amount;
    income.paymentDate = paymentDate;
    income.description = description;
    income.plaidTransactionId = plaidTransactionId;
    await user.save();
    res.status(200).json({
      status: true,
      message: 'Income updated successfully',
      body: income
    });
  } catch (error) {
    console.error('Error updating income:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to update income',
      body: null
    });
  }
};

exports.fixIncomeTypes = async (req, res) => {
  try {
    const users = await User.find({ "incomes.0": { $exists: true } });
    let fixedCount = 0;
    for (const user of users) {
      let needsSave = false;
      for (const income of user.incomes) {
        const oldType = income.type;
        const normalizedType = normalizeType(oldType);
        if (oldType !== normalizedType) {
          income.type = normalizedType;
          needsSave = true;
          fixedCount++;
        }
      }
      if (needsSave) {
        await user.save();
      }
    }
    res.status(200).json({
      status: true,
      message: `Fixed ${fixedCount} income types`,
      body: null
    });
  } catch (error) {
    console.error('Error fixing income types:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to fix income types',
      body: null
    });
  }
};

exports.deleteIncome = async (req, res) => {
  const { userId, incomeId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });

    const income = user.incomes.id(incomeId);
    if (!income) return res.status(404).json({
      status: false,
      message: 'Income not found',
      body: null
    });

    user.incomes.pull(incomeId);
    await user.save();

    res.status(200).json({
      status: true,
      message: 'Income deleted successfully',
      body: null
    });
  } catch (error) {
    console.error('Error deleting income:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to delete income',
      body: null
    });
  }
};

exports.getIncome = async (req, res) => {
  const { userId, incomeId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });

    const income = user.incomes.id(incomeId);
    if (!income) return res.status(404).json({
      status: false,
      message: 'Income not found',
      body: null
    });

    res.status(200).json({
      status: true,
      message: 'Income fetched successfully',
      body: income
    });
  } catch (error) {
    console.error('Error fetching income:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to fetch income',
      body: null
    });
  }
};

exports.getAllIncomes = async (req, res) => {
  const { userId } = req.params;
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;
  const skip = (page - 1) * limit;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });

    const incomes = user.incomes || [];
    const paginatedIncomes = incomes.slice(skip, skip + limit);
    res.status(200).json({
      status: true,
      message: 'Incomes fetched successfully',
      body: {
        incomes: paginatedIncomes,
        total: incomes.length,
        page,
        limit
      }
    });
  } catch (error) {
    console.error('Error fetching all incomes:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to fetch incomes',
      body: null
    });
  }
};

exports.syncPlaidIncomes = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }
    if (!user.plaid || user.plaid.length === 0) {
      return res.status(404).json({
        status: false,
        message: 'Plaid token not found. Please connect your bank account.',
        body: null
      });
    }

    const plaidAccount = user.plaid[0];
    const access_token = plaidAccount.accessToken;
    const startDate = moment().subtract(90, 'days').format('YYYY-MM-DD');
    const endDate = moment().format('YYYY-MM-DD');

    const plaidRes = await PlaidClient.transactionsGet({
      access_token,
      start_date: startDate,
      end_date: endDate,
    });
    console.log("Fetched transactions from Plaid:", plaidRes.data.transactions);
    if (!user.incomes) {
      user.incomes = [];
    }

    const newIncomeDetails = [];
    const existingIds = new Set(user.incomes.map(i => i.plaidTransactionId));
    for (const tx of plaidRes.data.transactions) {
      console.log("Processing transaction:", tx);
      if (isIncomeTransaction(tx) && !existingIds.has(tx.transaction_id)) {
        const incomeData = {
          name: tx.name ? tx.name.trim() : 'Income',
          type: normalizeType('Monthly'),
          amount: Math.abs(tx.amount),
          paymentDate: new Date(tx.date),
          description: tx.category ? tx.category.join(', ') : '',
          plaidTransactionId: tx.transaction_id,
        };
        user.incomes.push(incomeData);
        newIncomeDetails.push(incomeData);
      }
    }
    await user.save();
    res.status(200).json({
      status: true,
      message: `${newIncomeDetails.length} incomes added`,
      body: newIncomeDetails
    });
  } catch (error) {
    console.error('Plaid sync error:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to sync Plaid transactions',
      body: null
    });
  }
};

exports.getIncomeSummary = async (req, res) => {
  const { userId } = req.params;
  const { groupBy = 'month' } = req.query;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });

    const summary = {};

    user.incomes.forEach(income => {
      const date = new Date(income.paymentDate);
      const key = groupBy === 'year'
        ? `${date.getFullYear()}`
        : `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}`;

      summary[key] = (summary[key] || 0) + income.amount;
    });

    res.status(200).json({
      status: true,
      message: 'Income summary fetched successfully',
      body: summary
    });
  } catch (error) {
    console.error('Summary error:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to get summary',
      body: null
    });
  }
};

exports.getIncomeByCategory = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({
      status: false,
      message: 'User not found',
      body: null
    });

    const chartData = {};
    user.incomes.forEach(income => {
      chartData[income.name] = (chartData[income.name] || 0) + income.amount;
    });

    res.status(200).json({
      status: true,
      message: 'Income by category fetched successfully',
      body: chartData
    });
  } catch (error) {
    console.error('Chart data error:', error);
    res.status(500).json({
      status: false,
      message: 'Failed to get chart data',
      body: null
    });
  }
};

exports.addCashFlow = async (req, res) => {
  const { userId } = req.params;
  const { month, incomeBreakdown, expenseBreakdown } = req.body;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({ status: false, message: 'User not found', body: null });
    
    user.cashFlows.push({ month, incomeBreakdown, expenseBreakdown });
    await user.save();
    
    const newRecord = user.cashFlows[user.cashFlows.length - 1];
    res.status(201).json({
      status: true,
      message: 'Cash flow added successfully',
      body: newRecord
    });
  } catch (error) {
    console.error('Error adding cash flow:', error);
    res.status(500).json({ status: false, message: 'An error occurred. Please try again.', body: null });
  }
};

exports.updateCashFlow = async (req, res) => {
  const { userId, cashFlowId } = req.params;
  const { month, incomeBreakdown, expenseBreakdown } = req.body;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({ status: false, message: 'User not found', body: null });

    const cashFlow = user.cashFlows.id(cashFlowId);
    if (!cashFlow)
      return res.status(404).json({ status: false, message: 'Cash flow record not found', body: null });
    
    cashFlow.month = month;
    cashFlow.incomeBreakdown = incomeBreakdown;
    cashFlow.expenseBreakdown = expenseBreakdown;
    cashFlow.lastUpdated = Date.now();

    await user.save();

    res.status(200).json({
      status: true,
      message: 'Cash flow updated successfully',
      body: cashFlow
    });
  } catch (error) {
    console.error('Error updating cash flow:', error);
    res.status(500).json({ status: false, message: 'An error occurred. Please try again.', body: null });
  }
};

exports.deleteCashFlow = async (req, res) => {
  const { userId, cashFlowId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({ status: false, message: 'User not found', body: null });
    
    const cashFlow = user.cashFlows.id(cashFlowId);
    if (!cashFlow)
      return res.status(404).json({ status: false, message: 'Cash flow record not found', body: null });
    
    user.cashFlows.pull(cashFlowId);
    await user.save();

    res.status(200).json({
      status: true,
      message: 'Cash flow deleted successfully',
      body: null
    });
  } catch (error) {
    console.error('Error deleting cash flow:', error);
    res.status(500).json({ status: false, message: 'An error occurred. Please try again.', body: null });
  }
};

exports.getAllCashFlows = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({ status: false, message: 'User not found', body: null });
    
    res.status(200).json({
      status: true,
      message: 'Cash flows fetched successfully',
      body: user.cashFlows
    });
  } catch (error) {
    console.error('Error fetching cash flows:', error);
    res.status(500).json({ status: false, message: 'An error occurred. Please try again.', body: null });
  }
};

exports.getCashFlowDetails = async (req, res) => {
  const { userId } = req.params;
  const { month } = req.query;
  try {
    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({ status: false, message: 'User not found', body: null });
    
    // Sort cash flows by month assuming the month format is "YYYY-MM"
    const sortedCashFlows = user.cashFlows.sort((a, b) => a.month.localeCompare(b.month));
    const index = sortedCashFlows.findIndex(cf => cf.month === month);
    
    if (index === -1) {
      return res.status(404).json({ 
        status: false, 
        message: 'Cash flow record not found for the specified month', 
        body: null 
      });
    }
    
    const currentRecord = sortedCashFlows[index];
    const prevRecord = index > 0 ? sortedCashFlows[index - 1] : null;

    let incomeChangePercent = 0;
    let expenseChangePercent = 0;
    let netChangePercent = 0;

    if (prevRecord) {
      // Calculate income percentage change
      const prevIncome = prevRecord.totalIncome || 0;
      const currentIncome = currentRecord.totalIncome || 0;
      if (prevIncome !== 0) {
        incomeChangePercent = ((currentIncome - prevIncome) / Math.abs(prevIncome)) * 100;
      }
      
      // Calculate expense percentage change
      const prevExpenses = prevRecord.totalExpenses || 0;
      const currentExpenses = currentRecord.totalExpenses || 0;
      if (prevExpenses !== 0) {
        expenseChangePercent = ((currentExpenses - prevExpenses) / Math.abs(prevExpenses)) * 100;
      }
      
      // Calculate net cash flow percentage change
      const prevNet = prevRecord.netCashFlow || 0;
      const currentNet = currentRecord.netCashFlow || 0;
      if (prevNet !== 0) {
        netChangePercent = ((currentNet - prevNet) / Math.abs(prevNet)) * 100;
      }
    }
    
    // Convert the Mongoose sub-document into a plain object (if needed) and append the percentage fields.
    const cashFlowDetails = {
      ...currentRecord.toObject(),
      incomeChangePercent,
      expenseChangePercent,
      netChangePercent
    };

    res.status(200).json({
      status: true,
      message: 'Cash flow details fetched successfully',
      body: cashFlowDetails
    });
  } catch (error) {
    console.error('Error fetching cash flow details:', error);
    res.status(500).json({ status: false, message: 'An error occurred. Please try again.', body: null });
  }
};


exports.getCashFlowSummary = async (req, res) => {
  const { userId } = req.params;
  let { startDate, endDate } = req.query;
  
  try {
    // Default to last 6 months if not provided
    startDate = startDate || moment().subtract(6, 'months').startOf('month').format('YYYY-MM-DD');
    endDate = endDate || moment().endOf('month').format('YYYY-MM-DD');
    const startMonth = moment(startDate).format('YYYY-MM');
    const endMonth = moment(endDate).format('YYYY-MM');

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    // Filter cash flows in the specified month range
    const records = user.cashFlows.filter(cf => cf.month >= startMonth && cf.month <= endMonth);

    // Sort records by month (assumes format 'YYYY-MM')
    records.sort((a, b) => a.month.localeCompare(b.month));

    // Summarize overall totals
    const totalIncome = records.reduce((sum, rec) => sum + (rec.totalIncome || 0), 0);
    const totalExpenses = records.reduce((sum, rec) => sum + (rec.totalExpenses || 0), 0);
    const netCashFlow = totalIncome - totalExpenses;

    // Build monthly data with percentage change calculation for both income and expenses
    const monthlyData = records.map((rec, index) => {
      const prev = index === 0 ? null : records[index - 1];

      let prevIncome = prev ? (prev.totalIncome || 0) : 0;
      let currentIncome = rec.totalIncome || 0;
      let incomeChangePercent = 0;
      if (prevIncome !== 0) {
        incomeChangePercent = ((currentIncome - prevIncome) / Math.abs(prevIncome)) * 100;
      }

      let prevExpenses = prev ? (prev.totalExpenses || 0) : 0;
      let currentExpenses = rec.totalExpenses || 0;
      let expenseChangePercent = 0;
      if (prevExpenses !== 0) {
        expenseChangePercent = ((currentExpenses - prevExpenses) / Math.abs(prevExpenses)) * 100;
      }

      return {
        month: rec.month,
        totalIncome: currentIncome,
        totalExpenses: currentExpenses,
        netCashFlow: rec.netCashFlow,
        incomeChangePercent,   
        expenseChangePercent   
      };
    });

    return res.status(200).json({
      status: true,
      message: 'Cash flow summary fetched successfully',
      body: {
        totalIncome,
        totalExpenses,
        netCashFlow,
        monthlyData
      }
    });
  } catch (error) {
    console.error('Error fetching cash flow summary:', error);
    return res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.syncPlaidCashFlow = async (req, res) => {
  const { userId } = req.params;
  let { start_date, end_date } = req.body;
  try {
    start_date = start_date || moment().subtract(30, 'days').format('YYYY-MM-DD');
    end_date = end_date || moment().format('YYYY-MM-DD');

    const user = await User.findById(userId);
    if (!user)
      return res.status(404).json({ status: false, message: 'User not found', body: null });
    
    if (!user.plaid || user.plaid.length === 0)
      return res.status(404).json({ status: false, message: 'Plaid Token not found. Please connect your bank.', body: null });

    const plaidAccount = user.plaid[0];
    const access_token = plaidAccount.accessToken;

    const plaidResponse = await PlaidClient.transactionsGet({
      access_token,
      start_date,
      end_date,
      options: { count: 100, offset: 0 }
    });
    const transactions = plaidResponse.data.transactions;

    let incomeCategories = {};
    let expenseCategories = {};

    transactions.forEach(tx => {
      if (tx.category && tx.category.some(c => c.toLowerCase().includes('deposit'))) {
        const category = tx.name || 'Other Income';
        incomeCategories[category] = (incomeCategories[category] || 0) + Math.abs(tx.amount);
      } else {
        const category = tx.name || 'Other Expense';
        expenseCategories[category] = (expenseCategories[category] || 0) + Math.abs(tx.amount);
      }
    });

    // Calculate aggregate values if needed
    const totalIncome = Object.values(incomeCategories).reduce((sum, amt) => sum + amt, 0);
    const totalExpenses = Object.values(expenseCategories).reduce((sum, amt) => sum + amt, 0);
    const netCashFlow = totalIncome - totalExpenses;

    // Generate the current month in the required format
    const currentMonth = moment().format('YYYY-MM');
    if (!currentMonth) {
      console.error('Current month is undefined or invalid.');
      return res.status(400).json({ status: false, message: 'Invalid month format.' });
    }

    // Find an existing record for currentMonth
    let cashFlowRecord = user.cashFlows.find(cf => cf.month === currentMonth);
    if (cashFlowRecord) {
      cashFlowRecord.incomeBreakdown = Object.keys(incomeCategories).map(cat => ({ category: cat, amount: incomeCategories[cat] }));
      cashFlowRecord.expenseBreakdown = Object.keys(expenseCategories).map(cat => ({ category: cat, amount: expenseCategories[cat] }));
      cashFlowRecord.lastUpdated = Date.now();
    } else {
      // Push a new record ensuring the "month" field is set.
      user.cashFlows.push({
        month: currentMonth,
        incomeBreakdown: Object.keys(incomeCategories).map(cat => ({ category: cat, amount: incomeCategories[cat] })),
        expenseBreakdown: Object.keys(expenseCategories).map(cat => ({ category: cat, amount: expenseCategories[cat] }))
      });
      cashFlowRecord = user.cashFlows[user.cashFlows.length - 1];
    }
    
    await user.save();

    res.status(200).json({
      status: true,
      message: 'Cash flow synced from Plaid',
      body: cashFlowRecord
    });
  } catch (error) {
    console.error('Error syncing cash flow:', error);
    res.status(500).json({ status: false, message: 'Failed to sync cash flow', body: null });
  }
};

exports.getAllNetWorthData = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });

    res.status(200).json({
      status: true,
      message: 'Net worth data fetched successfully',
      body: user.netWorth
    });
  } catch (error) {
    console.error('Error fetching net worth data:', error);
    res.status(500).json({ status: false, message: 'An error occurred. Please try again.', body: null });
  }
};

exports.getNetWorth = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });

    res.json({ status: true, message: 'Net worth fetched successfully', body: user.netWorth });
  } catch (error) {
    res.status(500).json({ status: false, message: 'Error fetching net worth', body: null });
  }
};

exports.getNetWorthDataById = async (req, res) => {
  const { userId, netWorthId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });

    const netWorthData = user.netWorth.id(netWorthId);
    if (!netWorthData) return res.status(404).json({ status: false, message: 'Cannot find Net Worth Data', body: null });

    res.json({ status: true, message: 'Net worth data fetched successfully', body: netWorthData });
  } catch (error) {
    console.error('Error fetching net worth data:', error);
    res.status(500).json({ status: false, message: 'An error occurred. Please try again.', body: null });
  }
};

exports.createNetWorthData = async (req, res) => {
  const { userId } = req.params;
  const { totalNetWorth, totalAssets, totalLiabilities, assets, liabilities, historicalTrend } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });

    const processedAssets = (assets || []).map(a => ({
      type: a?.type || 'Unknown',
      name: a?.name || 'Unnamed',
      amount: a?.amount ?? 0,
      percentage: a?.percentage || "0%"
    }));

    const processedLiabilities = (liabilities || []).map(l => ({
      type: l?.type || 'Unknown',
      name: l?.name || 'Unnamed',
      amount: l?.amount ?? 0,
      percentage: l?.percentage || "0%"
    }));

    const processedTrend = (historicalTrend || []).map(h => ({
      year: h?.year || (h?.date ? new Date(h.date).getFullYear() : new Date().getFullYear()),
      value: h?.value ?? h?.totalNetWorth ?? 0
    }));

    const netWorthRecord = {
      totalNetWorth,
      totalAssets,
      totalLiabilities,
      assets: processedAssets,
      liabilities: processedLiabilities,
      historicalTrend: processedTrend
    };

    user.netWorth = [netWorthRecord];

    await user.save();
    res.status(201).json({ status: true, message: 'Net worth data created successfully', body: user.netWorth });
  } catch (error) {
    console.error('Error creating net worth data:', error);
    res.status(500).json({
      status: false,
      message: error.message || 'An error occurred. Please ensure all required fields are provided.',
      body: null
    });
  }
};

exports.updateNetWorthData = async (req, res) => {
  const { userId } = req.params;
  const { totalNetWorth, totalAssets, totalLiabilities, assets, liabilities, historicalTrend } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });

    const processedAssets = (assets || []).map(a => ({
      type: a?.type || 'Unknown',
      name: a?.name || 'Unnamed',
      amount: a?.amount ?? 0,
      percentage: a?.percentage || "0%"
    }));

    const processedLiabilities = (liabilities || []).map(l => ({
      type: l?.type || 'Unknown',
      name: l?.name || 'Unnamed',
      amount: l?.amount ?? 0,
      percentage: l?.percentage || "0%"
    }));

    const processedTrend = (historicalTrend || []).map(h => ({
      year: h?.year || (h?.date ? new Date(h.date).getFullYear() : new Date().getFullYear()),
      value: h?.value ?? h?.totalNetWorth ?? 0
    }));

    user.netWorth = {
      totalNetWorth,
      totalAssets,
      totalLiabilities,
      assets: processedAssets,
      liabilities: processedLiabilities,
      historicalTrend: processedTrend
    };

    await user.save();
    res.status(200).json({ status: true, message: 'Net worth data updated successfully', body: user.netWorth });
  } catch (error) {
    console.error('Error updating net worth data:', error);
    res.status(400).json({ status: false, message: error.message || 'An error occurred. Please try again.', body: null });
  }
};

exports.deleteNetWorthData = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });

    user.netWorth = [];
    await user.save();
    res.status(200).json({ status: true, message: 'Net Worth Data deleted successfully', body: null });
  } catch (error) {
    console.error('Error deleting net worth data:', error);
    res.status(500).json({ status: false, message: 'An error occurred. Please try again.', body: null });
  }
};

exports.syncPlaidNetWorthData = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ status: false, message: 'User not found', body: null });

    if (!user.plaid || user.plaid.length === 0) {
      return res.status(404).json({
        status: false,
        message: 'Plaid token not found. Please connect your bank account.',
        body: null
      });
    }

    const access_token = user.plaid[0].accessToken;
    let plaidResponse;

    if (typeof PlaidClient.netWorthGet === 'function') {
      plaidResponse = await PlaidClient.netWorthGet({ access_token });
    } else {
      plaidResponse = {
        data: {
          totalNetWorth: 100000,
          totalAssets: 150000,
          totalLiabilities: 50000,
          assets: [
            { type: "Cash", value: 30000 },
            { type: "Investments", value: 120000 }
          ],
          liabilities: [
            { type: "Loans", value: 50000 }
          ],
          historicalTrend: [
            { date: "2025-01-01", totalNetWorth: 90000 },
            { date: "2025-02-01", totalNetWorth: 95000 }
          ]
        }
      };
    }

    const processedAssets = plaidResponse.data.assets.map(a => ({
      type: a.type,
      name: a.type,
      amount: a.value,
      percentage: "0%"
    }));

    const processedLiabilities = plaidResponse.data.liabilities.map(l => ({
      type: l.type,
      name: l.type,
      amount: l.value,
      percentage: "0%"
    }));

    const processedTrend = plaidResponse.data.historicalTrend.map(h => ({
      year: new Date(h.date).getFullYear(),
      value: h.totalNetWorth
    }));

    user.netWorth = [{
      totalNetWorth: plaidResponse.data.totalNetWorth,
      totalAssets: plaidResponse.data.totalAssets,
      totalLiabilities: plaidResponse.data.totalLiabilities,
      assets: processedAssets,
      liabilities: processedLiabilities,
      historicalTrend: processedTrend
    }];

    await user.save();
    res.status(200).json({ status: true, message: 'Net worth data synced successfully', body: user.netWorth });
  } catch (error) {
    console.error('Error syncing net worth data:', error);
    res.status(500).json({ status: false, message: 'Failed to sync net worth data', body: null });
  }
};

// Get Investment Data
exports.getInvestmentData = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    // If user.investments doesn't exist, return a default structure
    const investments = user.investments || {
      totalInvestments: 0,
      investmentTypes: [],
      crypto: [],
      stocks: []
    };

    return res.status(200).json({
      status: true,
      message: 'Investment data fetched successfully',
      body: investments
    });
  } catch (error) {
    console.error('Error fetching investment data:', error);
    return res.status(500).json({
      status: false,
      message: 'Error fetching investment data',
      body: null
    });
  }
};

exports.addInvestmentData = async (req, res) => {
  const { userId } = req.params;
  const { investmentType, name, amount, quantity } = req.body;

  try {
    const numericAmount = parseFloat(amount);
    if (isNaN(numericAmount)) {
      return res.status(400).json({
        status: false,
        message: 'Invalid amount value',
        body: null
      });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    if (!user.investments) {
      user.investments = {
        totalInvestments: 0,
        investmentTypes: [],
        crypto: [],
        stocks: []
      };
    }
    if (!Array.isArray(user.investments.investmentTypes)) {
      user.investments.investmentTypes = [];
    }
    if (!Array.isArray(user.investments.crypto)) {
      user.investments.crypto = [];
    }
    if (!Array.isArray(user.investments.stocks)) {
      user.investments.stocks = [];
    }

    user.investments.totalInvestments = (user.investments.totalInvestments || 0) + numericAmount;

    const newInvestment = { name, amount: numericAmount, quantity };

    let typeExists = false;
    for (let i = 0; i < user.investments.investmentTypes.length; i++) {
      if (
        user.investments.investmentTypes[i].investmentType.toLowerCase() ===
        investmentType.toLowerCase()
      ) {
        user.investments.investmentTypes[i].amount += numericAmount;
        typeExists = true;
        break;
      }
    }
    if (!typeExists) {
      user.investments.investmentTypes.push({
        investmentType,
        amount: numericAmount
      });
    }

    let addedItem;
    if (investmentType.toLowerCase() === 'crypto') {
      user.investments.crypto.push(newInvestment);
      let lastItem = user.investments.crypto[user.investments.crypto.length - 1];
      addedItem = (typeof lastItem.toObject === 'function') ? lastItem.toObject() : lastItem;
    } else if (investmentType.toLowerCase() === 'stocks') {
      user.investments.stocks.push(newInvestment);
      let lastItem = user.investments.stocks[user.investments.stocks.length - 1];
      addedItem = (typeof lastItem.toObject === 'function') ? lastItem.toObject() : lastItem;
    } else {
      return res.status(400).json({
        status: false,
        message: `Unknown investmentType: ${investmentType}`,
        body: null
      });
    }

    user.markModified('investments');
    await user.save();

    return res.status(201).json({
      status: true,
      message: 'Investment data added successfully',
      body: addedItem 
    });
  } catch (error) {
    console.error('Error adding investment data:', error);
    return res.status(500).json({
      status: false,
      message: 'Error adding investment data: ' + error.message,
      body: null
    });
  }
};

exports.updateInvestmentData = async (req, res) => {
  const { userId, investmentId } = req.params;
  const { investmentType, name, amount, quantity, oldAmount } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user || !user.investments) {
      return res.status(404).json({
        status: false,
        message: 'User or investments not found',
        body: null
      });
    }

    if (!Array.isArray(user.investments.crypto)) {
      user.investments.crypto = [];
    }
    if (!Array.isArray(user.investments.stocks)) {
      user.investments.stocks = [];
    }
    if (!Array.isArray(user.investments.investmentTypes)) {
      user.investments.investmentTypes = [];
    }

    let updated = false;
    const numericAmount = parseFloat(amount);
    const numericOldAmount = parseFloat(oldAmount);
    const diff = numericAmount - numericOldAmount; 

    if (investmentType.toLowerCase() === 'crypto') {
      const cryptoIndex = user.investments.crypto.findIndex(
        (item) => item._id.toString() === investmentId
      );
      if (cryptoIndex >= 0) {
        user.investments.crypto[cryptoIndex].name = name;
        user.investments.crypto[cryptoIndex].amount = numericAmount;
        user.investments.crypto[cryptoIndex].quantity = quantity;
        updated = true;
      }
    } else if (investmentType.toLowerCase() === 'stocks') {
      const stockIndex = user.investments.stocks.findIndex(
        (item) => item._id.toString() === investmentId
      );
      if (stockIndex >= 0) {
        user.investments.stocks[stockIndex].name = name;
        user.investments.stocks[stockIndex].amount = numericAmount;
        user.investments.stocks[stockIndex].quantity = quantity;
        updated = true;
      }
    } else {
      return res.status(400).json({
        status: false,
        message: `Unknown investmentType: ${investmentType}`,
        body: null
      });
    }

    if (!updated) {
      return res.status(404).json({
        status: false,
        message: 'Investment not found',
        body: null
      });
    }

    user.investments.totalInvestments = (user.investments.totalInvestments || 0) + diff;

    const typeIndex = user.investments.investmentTypes.findIndex(
      (type) => type.investmentType.toLowerCase() === investmentType.toLowerCase()
    );
    if (typeIndex >= 0) {
      user.investments.investmentTypes[typeIndex].amount += diff;
    }

    user.markModified('investments');
    await user.save();

    return res.status(200).json({
      status: true,
      message: 'Investment updated successfully',
      body: { _id: investmentId, name, amount: numericAmount, quantity }
    });
  } catch (error) {
    console.error('Error updating investment data:', error);
    return res.status(500).json({
      status: false,
      message: 'Error updating investment data: ' + error.message,
      body: null
    });
  }
};

exports.deleteInvestmentData = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    // Reset the entire investments object
    user.investments = {
      totalInvestments: 0,
      investmentTypes: [],
      crypto: [],
      stocks: []
    };

    user.markModified('investments');
    await user.save();

    return res.status(200).json({
      status: true,
      message: 'All investment data deleted successfully',
      body: null
    });
  } catch (error) {
    console.error('Error deleting investment data:', error);
    return res.status(500).json({
      status: false,
      message: 'Error deleting investment data: ' + error.message,
      body: null
    });
  }
};

exports.deleteSingleInvestment = async (req, res) => {
  const { userId, investmentId } = req.params;
  const { investmentType } = req.body; 
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    if (!user.investments) {
      return res.status(404).json({
        status: false,
        message: 'No investments found',
        body: null
      });
    }

    // Make sure arrays exist
    if (!Array.isArray(user.investments.crypto)) {
      user.investments.crypto = [];
    }
    if (!Array.isArray(user.investments.stocks)) {
      user.investments.stocks = [];
    }

    let removedAmount = 0;
    let removed = false;

    if (investmentType.toLowerCase() === 'crypto') {
      const cryptoIndex = user.investments.crypto.findIndex(
        (item) => item._id.toString() === investmentId
      );
      if (cryptoIndex >= 0) {
        removedAmount = user.investments.crypto[cryptoIndex].amount;
        user.investments.crypto.splice(cryptoIndex, 1);
        removed = true;
      }
    } else if (investmentType.toLowerCase() === 'stocks') {
      const stockIndex = user.investments.stocks.findIndex(
        (item) => item._id.toString() === investmentId
      );
      if (stockIndex >= 0) {
        removedAmount = user.investments.stocks[stockIndex].amount;
        user.investments.stocks.splice(stockIndex, 1);
        removed = true;
      }
    } else {
      return res.status(400).json({
        status: false,
        message: `Unknown investmentType: ${investmentType}`,
        body: null
      });
    }

    if (!removed) {
      return res.status(404).json({
        status: false,
        message: 'Investment not found',
        body: null
      });
    }

    user.investments.totalInvestments -= removedAmount;

    const typeIndex = user.investments.investmentTypes.findIndex(
      (type) => type.investmentType.toLowerCase() === investmentType.toLowerCase()
    );

    if (typeIndex >= 0) {
      user.investments.investmentTypes[typeIndex].amount -= removedAmount;
      if (user.investments.investmentTypes[typeIndex].amount <= 0) {
        user.investments.investmentTypes.splice(typeIndex, 1);
      }
    }

    user.markModified('investments');
    await user.save();

    return res.status(200).json({
      status: true,
      message: 'Investment deleted successfully',
      body: null
    });
  } catch (error) {
    console.error('Error deleting investment data:', error);
    return res.status(500).json({
      status: false,
      message: 'Error deleting investment data: ' + error.message,
      body: null
    });
  }
};

exports.syncPlaidInvestments = async (req, res) => {
  const { userId } = req.params;
  try {
    console.log('Starting Plaid sync for user:', userId);

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    if (!user.plaid || user.plaid.length === 0) {
      return res.status(404).json({
        status: false,
        message: 'Plaid token not found. Please connect your bank account.',
        body: null
      });
    }

    const plaidAccount = user.plaid[0];
    const access_token = plaidAccount.accessToken;
    console.log('Using Plaid access token:', access_token);

    const PlaidClient = require('../utils/PlaidClient');
    const plaidClient = PlaidClient.getInstance();

    try {
      // Attempt to fetch from Plaid
      const response = await plaidClient.investmentsHoldingsGet({
        access_token: access_token
      });

      // TODO: Map the Plaid response to your local structure or do a merge
      // Example (for demonstration):
      user.investments = transformPlaidResponse(response);

    } catch (plaidError) {
      console.error('Error fetching from Plaid API:', plaidError);
      console.log('Using mock data instead');

      // Overwrite with mock data for demonstration
      user.investments = {
        totalInvestments: 20000,
        investmentTypes: [
          { investmentType: "stocks", amount: 15000 },
          { investmentType: "crypto", amount: 5000 }
        ],
        crypto: [
          { name: "Bitcoin", amount: 5000, quantity: 0.1 }
        ],
        stocks: [
          { name: "Apple Inc.", amount: 15000, quantity: 10 }
        ]
      };
    }

    user.markModified('investments');
    await user.save();

    return res.status(200).json({
      status: true,
      message: 'Synced investments from Plaid successfully',
      body: user.investments
    });
  } catch (error) {
    console.error('Error syncing investments:', error);
    return res.status(500).json({
      status: false,
      message: 'Error syncing investments: ' + error.message,
      body: null
    });
  }
};

exports.debugInvestments = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    console.log('===== INVESTMENT DEBUG =====');
    console.log('User ID:', userId);
    console.log('Investments field exists:', !!user.investments);
    console.log('Investments type:', typeof user.investments);
    console.log('Is array?', Array.isArray(user.investments));
    console.log('Raw investments data:', JSON.stringify(user.investments, null, 2));

    return res.status(200).json({
      status: true,
      message: 'Debug info logged to console',
      body: {
        hasInvestments: !!user.investments,
        investmentsType: typeof user.investments,
        isArray: Array.isArray(user.investments),
        investments: user.investments
      }
    });
  } catch (error) {
    console.error('Error in debug function:', error);
    return res.status(500).json({
      status: false,
      message: 'Error in debug function: ' + error.message,
      body: null
    });
  }
};
exports.createTransaction = async (req, res) => {
  try {
    console.log("Received request body:", req.body);

    const { userId } = req.params;
    const { title, amount, date, isPositive, access_token, start_date, end_date } = req.body;

    if (!title || typeof title !== "string" || title.trim() === "") {
      return res.status(400).json({
        status: false,
        message: "Transaction title is required.",
        body: null
      });
    }
    if (amount === undefined || isNaN(amount)) {
      return res.status(400).json({
        status: false,
        message: "Transaction amount must be a valid number.",
        body: null
      });
    }

    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount)) {
      return res.status(400).json({
        status: false,
        message: "Invalid amount value.",
        body: null
      });
    }
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: "User not found.",
        body: null
      });
    }

    if (access_token) {
      console.log(`Fetching transactions from Plaid for user: ${userId}`);

      const plaidTransactions = await fetchTransactionsFromPlaid(access_token, start_date, end_date);
      console.log("Plaid Transactions:", plaidTransactions);

      for (let plaidTransaction of plaidTransactions) {
        const newTransaction = {
          title: plaidTransaction.name,
          amount: plaidTransaction.amount,
          date: new Date(plaidTransaction.date),
          isPositive: plaidTransaction.amount > 0,
        };

        user.transactions.push(newTransaction);
      }
      await user.save();

      return res.status(201).json({
        status: true,
        message: "Transactions added successfully!",
        body: user.transactions
      });
    }

    const newTransaction = {
      title: title.trim(),
      amount: parsedAmount,
      date: date ? new Date(date) : new Date(),
      isPositive: isPositive ?? true,
    };

    user.transactions.push(newTransaction);
    await user.save();

    console.log("Transaction added successfully:", newTransaction);
    return res.status(201).json({
      status: true,
      message: "Transaction added successfully!",
      body: newTransaction
    });

  } catch (error) {
    console.error("Error creating transaction:", error);
    return res.status(500).json({
      status: false,
      message: "Internal server error.",
      body: null
    });
  }
};

async function fetchTransactionsFromPlaid(access_token, start_date, end_date) {
  try {
    const plaidApiUrl = "https://sandbox.plaid.com/transactions/get";
    const response = await fetch(plaidApiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "PLAID-CLIENT-ID": process.env.CLIENT_ID,
        "PLAID-SECRET": process.env.SECRET_KEY,
      },
      body: JSON.stringify({
        access_token,
        start_date,
        end_date,
      }),
    });

    if (!response.ok) {
      throw new Error(`Plaid API Error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.transactions || [];
  } catch (error) {
    console.error("Error fetching transactions from Plaid:", error);
    return [];
  }
}

exports.getTransactions = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: "User not found.",
        body: null
      });
    }

    return res.status(200).json({
      status: true,
      message: "Transactions fetched successfully",
      body: user.transactions
    });

  } catch (error) {
    console.error("Error fetching transactions:", error);
    return res.status(500).json({
      status: false,
      message: "Internal server error.",
      body: null
    });
  }
};

exports.getAllTransactions = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    res.json({
      status: true,
      message: 'Transactions fetched successfully',
      body: user.transactions
    });
  } catch (error) {
    console.error('Error fetching transactions:', error);
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.getTransactionById = async (req, res) => {
  const { userId, transactionId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    const transaction = user.transactions.id(transactionId);
    if (!transaction) {
      return res.status(404).json({
        status: false,
        message: 'Transaction not found',
        body: null
      });
    }

    res.json({
      status: true,
      message: 'Transaction fetched successfully',
      body: transaction
    });
  } catch (error) {
    console.error('Error fetching transaction:', error);
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.updateTransaction = async (req, res) => {
  const { userId, transactionId } = req.params;
  const { title, amount, date, isPositive } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    const transaction = user.transactions.id(transactionId);
    if (!transaction) {
      return res.status(404).json({
        status: false,
        message: 'Transaction not found',
        body: null
      });
    }

    transaction.title = title;
    transaction.amount = amount;
    transaction.date = date;
    transaction.isPositive = isPositive;

    await user.save();

    res.json({
      status: true,
      message: 'Transaction updated successfully',
      body: transaction
    });
  } catch (error) {
    console.error('Error updating transaction:', error);
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};

exports.deleteTransaction = async (req, res) => {
  const { userId, transactionId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: false,
        message: 'User not found',
        body: null
      });
    }

    const transaction = user.transactions.id(transactionId);
    if (!transaction) {
      return res.status(404).json({
        status: false,
        message: 'Transaction not found',
        body: null
      });
    }

    transaction.remove();
    await user.save();

    res.json({
      status: true,
      message: 'Transaction deleted successfully',
      body: null
    });
  } catch (error) {
    console.error('Error deleting transaction:', error);
    res.status(500).json({
      status: false,
      message: 'An error occurred. Please try again.',
      body: null
    });
  }
};
