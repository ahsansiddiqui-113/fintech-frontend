const mongoose = require('mongoose');
const User = require('../models/User'); 

mongoose.connect('mongodb://localhost:27017/WealthNx', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

async function cleanBudgets() {
  const users = await User.find({});

  for (const user of users) {
    let updated = false;

    user.budgets = user.budgets.filter(budget => {
      if (!budget.category || budget.category.trim() === '') {
        console.log(`Removing budget with missing category from user ${user._id}`);
        updated = true;
        return false;
      }
      return true;
    });

    if (updated) {
      await user.save();
      console.log(`Cleaned user ${user._id}`);
    }
  }

  console.log(' Data cleanup complete.');
  mongoose.connection.close();
}

cleanBudgets().catch(error => {
  console.error(' Error cleaning data:', error);
  mongoose.connection.close();
});
