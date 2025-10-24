const { body } = require('express-validator');

exports.validateExpense = [
  body('category')
    .notEmpty()
    .withMessage('Category is required'),
  body('amount')
    .isFloat({ gt: 0 })
    .withMessage('Amount must be a number greater than 0'),
  body('date')
    .optional()
    .isISO8601()
    .toDate()
    .withMessage('Date must be in a valid ISO8601 format'),
  body('isRecurring')
    .optional()
    .isBoolean()
    .withMessage('isRecurring must be a boolean'),
  body('recurrenceInterval')
    .optional()
    .isIn(['daily', 'weekly', 'monthly', 'yearly'])
    .withMessage('recurrenceInterval must be one of: daily, weekly, monthly, yearly')
];
