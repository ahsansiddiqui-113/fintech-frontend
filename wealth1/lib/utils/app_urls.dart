class AppEndpoints {
  static const baseUrl =
      'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api/users/';

  // static const baseUrl = 'http://182.191.94.19:5008/api/users/';
  static const profileBaseUrl =
      'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net';

//WealthNX Auth urls
  static const signIn = 'signin';
  static const signUp = 'signup';
  static const sendOtp = 'send-otp-gmail';
  static const googleNewUserAuth ='google-auth';
  static const googleNewUserLogin ='google-login';

  //WealthNX Updated urls

  static const profileUpdate = '/profile/update';
  static const portfolioHomePage = '/holdings/stock-crypto';
  static const profileGet = '/profile/get';
  static const changePass = 'change-password';

//WealthNX urls
  static const investmentPortfolio = '/investments/sync-holdings';

  static const transactions = '/transactions';

  static const networth = '/networth';

  static const cashflow = '/cashflows';

  static const upcomingRecurringExpenses = '/upcoming-recurring-expenses';

  static const String notifications =
      '/notifications';

  static const expenses = '/expenses';
  static const expenseRecur = '/expenses/recurring';
  static const addExpenses = '/expense';
  static const expenseSchedule = '/expenses/schedule';

  static const addIncome = '/income';
  static const incomes = '/incomes';

  static const addBudget = '/budget';
  static const budgets = '/budgets';
  static const logOut = '/logout';

  static const Feedback = '/feedback';

  static const Delete = '/profile/delete';

  static const bankList = '/bank-totals';
  static const accounts = '/accountsfilter';

  static const connectedStatus = '/plaid-connection';

  // static const netWorthSummary = '/networth/summary';
  static const expensesCategoryBreakdown = '/expenses/category-breakdown';

// general crypto news urls
  static const String cryptoNews =
      "https://financialmodelingprep.com/stable/news/crypto?symbols=";
  static const String cryptoNewsApikey =
      "&apikey=uHqogK3lOZ3TDN6HbvvQc3vHUKLVkz3g";

// general stock news url end point cryptoNewsApiKey
  static const String stockNews =
      "https://financialmodelingprep.com/stable/news/stock?symbols=";

  // forgot password url
  static const String forgotPassword =
      'https://wealthnxapi-gra7hxd5decbd0d0.centralus-01.azurewebsites.net/api';
}
