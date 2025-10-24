require('dotenv').config(); 

const request = require('supertest');
const app = require('./app'); 
const mongoose = require('mongoose');
const User = require('./models/User');

let token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3OWIyNDI1Yzg0M2RiMmM3MDIzNWE0NyIsImVtYWlsIjoiYWlAZ21haWwuY29tIiwiaWF0IjoxNzQ0MjgxNjQ4LCJleHAiOjE3NDY4NzM2NDh9.Rmdqc50-VKmEZxCHKHycgSbybRtfrunw1SPDUO1V30M';
let userId = '679b2425c843db2c70235a47';
let expenseId = '';

let createdExpense = {}; 

beforeAll(async () => {
  await User.deleteMany({ email: 'testexpense@example.com' });

  const user = new User({
    fullName: 'Expense Test User',
    email: 'testexpense@example.com',
    password: 'hashedpassword123',
    expenses: []
  });
  const savedUser = await user.save();
  userId = savedUser._id.toString();
});

afterAll(async () => {
  await User.deleteMany({});
  await mongoose.connection.close();
});

describe('Expense Module API Tests', () => {
  
  it('should add an expense with default chart configuration', async () => {
    const payload = {
      category: "food",
      amount: 100,
      date: "2025-05-11",
      description: "breakfast at the hotel",
      isRecurring: false
    };

    const res = await request(app)
      .post(`/api/users/${userId}/expense`)
      .set('Authorization', `Bearer ${token}`)
      .set('Content-Type', 'application/json')
      .send(payload);

    expect(res.statusCode).toBe(201);
    expect(res.body.status).toBe(true);
    expect(res.body.body).toHaveProperty('_id');
    expect(res.body.body).toHaveProperty('chartConfig');
    expect(res.body.body.chartConfig.chartType).toBe('line');
    expect(res.body.body.chartConfig.lineColor).toBe('#000000');

    expenseId = res.body.body._id;
    createdExpense = payload;
  });

  it('should get a single expense with chartConfig present', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/expense/${expenseId}`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.body).toHaveProperty('_id', expenseId);
    expect(res.body.body).toHaveProperty('chartConfig');
  });

  it('should update the expense fields', async () => {
    const updatePayload = {
      category: "entertainment",
      amount: 50,
      description: "movie ticket"
    };

    const res = await request(app)
      .put(`/api/users/${userId}/expense/${expenseId}`)
      .set('Authorization', `Bearer ${token}`)
      .set('Content-Type', 'application/json')
      .send(updatePayload);

    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.body.category).toBe('entertainment');
    expect(res.body.body.amount).toBe(50);
    expect(res.body.body.description).toBe('movie ticket');
  });

  it('should update the expense chart configuration', async () => {
    const chartConfigPayload = {
      chartType: "bar",
      lineColor: "#00ff00"
    };

    const res = await request(app)
      .put(`/api/users/${userId}/expense/${expenseId}/chart-config`)
      .set('Authorization', `Bearer ${token}`)
      .set('Content-Type', 'application/json')
      .send(chartConfigPayload);

    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.body.chartType).toBe('bar');
    expect(res.body.body.lineColor).toBe('#00ff00');
  });

  it('should fetch the expense chart configuration', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/expense/${expenseId}/chart-config`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.body.chartType).toBe('bar');
    expect(res.body.body.lineColor).toBe('#00ff00');
  });

  it('should fetch all expenses', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/expenses`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.body)).toBe(true);
  });

  it('should fetch expenses by month', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/expenses/month?month=2025-05`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.body)).toBe(true);
  });

  it('should fetch expense summary', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/expenses/summary?month=2025-05`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.body).toHaveProperty('total');
    expect(res.body.body).toHaveProperty('categoryBreakdown');
  });

  it('should fetch advanced expense summary', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/expenses/summary-advanced?range=monthly`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe(true);
    expect(res.body.body).toHaveProperty('total');
    expect(res.body.body).toHaveProperty('categoryBreakdown');
    expect(res.body.body).toHaveProperty('recurringExpenses');
  });

  it('should fetch filtered expenses', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/expenses/filtered?category=${createdExpense.category}&minAmount=50&maxAmount=150&page=1&limit=10`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.body.expenses)).toBe(true);
  });

  it('should delete the expense', async () => {
    const res = await request(app)
      .delete(`/api/users/${userId}/expense/${expenseId}`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(res.statusCode).toBe(200);
    expect(res.body.message.toLowerCase()).toMatch(/deleted successfully/i);
    
    const getRes = await request(app)
      .get(`/api/users/${userId}/expense/${expenseId}`)
      .set('Authorization', `Bearer ${token}`);
      
    expect(getRes.statusCode).toBe(404);
  });
});
