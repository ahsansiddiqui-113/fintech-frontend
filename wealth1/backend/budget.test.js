const request = require('supertest');
const app = require('./app'); 
const mongoose = require('mongoose');
const User = require('./models/User');

let token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3OWIyNDI1Yzg0M2RiMmM3MDIzNWE0NyIsImVtYWlsIjoiYWlAZ21haWwuY29tIiwiaWF0IjoxNzQ0MjgxNjQ4LCJleHAiOjE3NDY4NzM2NDh9.Rmdqc50-VKmEZxCHKHycgSbybRtfrunw1SPDUO1V30M'; 
let userId = '679b2425c843db2c70235a47';
let budgetId = '';

beforeAll(async () => {
  // Ensure clean state
  await User.deleteMany({ email: 'testuser@example.com' });

  const user = new User({
    fullName: 'Test User',
    email: 'testuser@example.com',
    password: 'hashedpassword123', 
    budgets: []
  });

  const savedUser = await user.save();
  userId = savedUser._id.toString();
});

afterAll(async () => {
  await User.deleteMany({});
  await mongoose.connection.close();
});

describe('WealthNX Budget Module API Tests', () => {

  it('should add a budget', async () => {
    const payload = {
      budgetType: 'Monthly',
      budgetName: 'Satellite Internet',
      budgetAmount: 800,
      allocatedAmount: 500,
      category: 'Water',
      budgetSubCategory: 'Utility - Internet',
      startDate: '2025-04-05'
    };

    const res = await request(app)
      .post(`/api/users/${userId}/budget`)
      .set('Authorization', `Bearer ${token}`)
      .send(payload);

    expect(res.statusCode).toBe(201);
    expect(res.body.status).toBe(true);
    expect(res.body.body).toHaveProperty('_id');

    budgetId = res.body.body._id;
    createdBudget = payload;
  });

  it('should update a budget', async () => {
    const res = await request(app)
      .put(`/api/users/${userId}/budget/${budgetId}`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        budgetAmount: 900,
        allocatedAmount: 600,
        budgetSubCategory: 'Updated Subcategory'
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.body.budgetAmount).toBe(900);
    expect(res.body.body.allocatedAmount).toBe(600);
  });

  it('should fetch a single budget', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/budget/${budgetId}`)
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    const budget = res.body.body;

    expect(budget).toHaveProperty('budgetName', createdBudget.budgetName);
    expect(budget).toHaveProperty('category', createdBudget.category);
    expect(typeof budget.budgetAmount).toBe('number');
    expect(typeof budget.allocatedAmount).toBe('number');
  });

  it('should fetch all budgets', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/budgets`)
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.body)).toBe(true);
  });

  it('should fetch grouped budgets', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/budgets/grouped`)
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.body).toHaveProperty(createdBudget.category);
  });

  it('should filter budgets by category', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/budgets/category/${createdBudget.category}`)
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.body)).toBe(true);
  });

  it('should get spend history', async () => {
    const res = await request(app)
      .get(`/api/users/${userId}/budget/${budgetId}/history`)
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.body)).toBe(true);
    expect(res.body.body[0]).toHaveProperty('allocatedAmount');
    expect(res.body.body[0]).toHaveProperty('date');
  });

  it('should delete a budget', async () => {
    const res = await request(app)
      .delete(`/api/users/${userId}/budget/${budgetId}`)
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.message).toMatch(/deleted successfully/i);
  });

});