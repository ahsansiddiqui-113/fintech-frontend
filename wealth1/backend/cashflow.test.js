// cashflow.test.js

const request = require('supertest');
const app = require('./app'); 
const mongoose = require('mongoose');
const User = require('./models/User');

let token =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3OWIyNDI1Yzg0M2RiMmM3MDIzNWE0NyIsImVtYWlsIjoiYWlAZ21haWwuY29tIiwiaWF0IjoxNzQ0MjgxNjQ4LCJleHAiOjE3NDY4NzM2NDh9.Rmdqc50-VKmEZxCHKHycgSbybRtfrunw1SPDUO1V30M';
let userId = '';
let cashFlowId = '';
let createdCashFlowPayload = {};

beforeAll(async () => {
  await mongoose.connect('mongodb://localhost:27017/WealthNx', {
    useNewUrlParser: true,
    useUnifiedTopology: true
  });

  await User.deleteMany({ email: 'testcashflow@example.com' });

  const user = new User({
    fullName: 'Test CashFlow User',
    email: 'testcashflow@example.com',
    password: 'hashedpassword123'
  });

  const savedUser = await user.save();

  savedUser.plaid.push({
    accessToken: 'access-sandbox-61e6c491-c97e-4085-b8c9-b2b27e4193bd',
    itemID: '8ejjQdk76NIlmGnarQBoiqBLzpxrvXSwwaA4d',
    institutionName: 'Dummy Bank',
    userId: savedUser._id
  });
  await savedUser.save();

  userId = savedUser._id.toString();
});

afterAll(async () => {
  await User.deleteMany({ email: 'testcashflow@example.com' });
  await mongoose.connection.close();
});

describe('CashFlow Module API Tests', () => {

  it('should add a new cash flow record', async () => {
    const payload = {
      month: "2025-04",
      incomeBreakdown: [
        { category: "Salary", amount: 5000 },
        { category: "Freelance", amount: 1500 }
      ],
      expenseBreakdown: [
        { category: "Rent", amount: 2000 },
        { category: "Utilities", amount: 300 }
      ]
    };

    createdCashFlowPayload = payload;
    
    const res = await request(app)
      .post(`/api/users/${userId}/cashflow`)
      .set('Authorization', `Bearer ${token}`)
      .send(payload);
      
    expect(res.statusCode).toBe(201);
    expect(res.body.status).toBe(true);
    expect(res.body.body).toHaveProperty('_id');
    expect(res.body.body).toHaveProperty('month', payload.month);
    expect(res.body.body).toHaveProperty('totalIncome');
    expect(res.body.body).toHaveProperty('totalExpenses');
    expect(res.body.body).toHaveProperty('netCashFlow');

    cashFlowId = res.body.body._id;
  });

  it('should update the existing cash flow record', async () => {
    const updatePayload = {
      month: "2025-04", 
      incomeBreakdown: [
        { category: "Salary", amount: 5500 },
        { category: "Freelance", amount: 1800 }
      ],
      expenseBreakdown: [
        { category: "Rent", amount: 2100 },
        { category: "Utilities", amount: 350 },
        { category: "Groceries", amount: 500 }
      ]
    };

    const res = await request(app)
      .put(`/api/users/${userId}/cashflow/${cashFlowId}`)
      .set('Authorization', `Bearer ${token}`)
      .send(updatePayload);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.body).toHaveProperty('incomeBreakdown');
    expect(Array.isArray(res.body.body.incomeBreakdown)).toBe(true);
    expect(res.body.body.incomeBreakdown.length).toBeGreaterThan(0);
    
    createdCashFlowPayload = updatePayload;
  });

  // 3. Get All Cash Flow Records
  it('should fetch all cash flow records for the user', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/cashflows`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(Array.isArray(res.body.body)).toBe(true);
    expect(res.body.body.length).toBeGreaterThan(0);
  });

  // 4. Get Detailed Cash Flow for a Specific Month
  it('should fetch detailed cash flow for the specified month', async () => {
    const month = "2025-04";
    const res = await request(app)
      .get(`/api/users/${userId}/cashflow-details?month=${month}`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.body).toHaveProperty('month', month);
  });

  // 5. Get Aggregated Cash Flow Summary
  it('should fetch aggregated cash flow summary for a date range', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/cashflow-summary?startDate=2025-01-01&endDate=2025-04-30`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.body).toHaveProperty('totalIncome');
    expect(res.body.body).toHaveProperty('totalExpenses');
    expect(res.body.body).toHaveProperty('netCashFlow');
    expect(res.body.body).toHaveProperty('monthlyData');
    expect(Array.isArray(res.body.body.monthlyData)).toBe(true);
  });

  // 6. Sync Cash Flow Data from Plaid
  it('should sync cash flow data from Plaid', async () => {
    const payload = {
      start_date: "2025-03-01",
      end_date: "2025-03-31"
    };
    const res = await request(app)
      .post(`/api/users/${userId}/sync-plaid`)
      .set('Authorization', `Bearer ${token}`)
      .send(payload);
      
    // Depending on your dummy Plaid config, allow a response code of 200 or 404.
    expect([200, 404]).toContain(res.statusCode);
    if (res.statusCode === 200) {
      expect(res.body.status).toBe(true);
      expect(res.body.body).toHaveProperty('incomeBreakdown');
      expect(res.body.body).toHaveProperty('expenseBreakdown');
    }
  });

  // 7. Delete Cash Flow Record
  it('should delete the cash flow record', async () => {
    const res = await request(app)
      .delete(`/api/users/${userId}/cashflow/${cashFlowId}`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.message).toMatch(/deleted successfully/i);
  });
});
