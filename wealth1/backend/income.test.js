const request = require('supertest');
const app = require('./app'); 
const mongoose = require('mongoose');
const User = require('./models/User');

let token =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3OWIyNDI1Yzg0M2RiMmM3MDIzNWE0NyIsImVtYWlsIjoiYWlAZ21haWwuY29tIiwiaWF0IjoxNzQ0MjgxNjQ4LCJleHAiOjE3NDY4NzM2NDh9.Rmdqc50-VKmEZxCHKHycgSbybRtfrunw1SPDUO1V30M';
let userId = '';
let incomeId = '';
let createdIncome = {};

beforeAll(async () => {
  await mongoose.connect('mongodb://localhost:27017/WealthNx', {
    useNewUrlParser: true,
    useUnifiedTopology: true
  });

  await User.deleteMany({ email: 'testincome@example.com' });

  const user = new User({
    fullName: 'Test Income User',
    email: 'testincome@example.com',
    password: 'hashedpassword123',
    incomes: [],
  });

  const savedUser = await user.save();
  userId = savedUser._id.toString();
});

afterAll(async () => {
  await User.deleteMany({});
  await mongoose.connection.close();
});

describe('WealthNX Income Module API Tests', () => {

    it('should add an income', async () => {
        const payload = {
          name: 'Salary',
          type: 'Monthly',
          amount: 5000,
          paymentDate: '2025-04-14',
          description: 'Monthly salary received'
        };
    
        const res = await request(app)
          .post(`/api/users/${userId}/income`)
          .set('Authorization', `Bearer ${token}`)
          .send(payload);
    
        expect(res.statusCode).toBe(201);
        expect(res.body.status).toBe(true);
        expect(res.body.body).toHaveProperty('_id');
    
        incomeId = res.body.body._id;
        createdIncome = { ...payload }; 
      });
    
      it('should update an income', async () => {
        const updatePayload = {
          name: 'Updated Salary',
          type: 'Monthly',
          amount: 5500,
          paymentDate: '2025-04-15',
          description: 'Updated salary description'
        };
    
        const res = await request(app)
          .put(`/api/users/${userId}/income/${incomeId}`)
          .set('Authorization', `Bearer ${token}`)
          .send(updatePayload);
    
        expect(res.statusCode).toBe(200);
        expect(res.body.body).toHaveProperty('name', 'Updated Salary');
        expect(res.body.body.amount).toBe(5500);
    
        createdIncome = { ...updatePayload };
      });
    
      it('should fix income types for unnormalized entries', async () => {
        const payload = {
          name: 'Bonus',
          type: 'monthly', 
          amount: 1000,
          paymentDate: '2025-04-20',
          description: 'One-time bonus'
        };
    
        const addRes = await request(app)
          .post(`/api/users/${userId}/income`)
          .set('Authorization', `Bearer ${token}`)
          .send(payload);
    
        expect(addRes.statusCode).toBe(201);
        const fixRes = await request(app)
          .post(`/api/users/${userId}/income/fix-types`)
          .set('Authorization', `Bearer ${token}`);
    
        expect(fixRes.statusCode).toBe(200);
        expect(fixRes.body.message).toMatch(/Fixed \d+ income types/);
    
        const userRes = await request(app)
          .get(`/api/users/${userId}/incomes?page=1&limit=50`)
          .set('Authorization', `Bearer ${token}`);
        expect(userRes.statusCode).toBe(200);
        const incomes = userRes.body.body.incomes;
        const bonusIncome = incomes.find(inc => inc.name === 'Bonus');
        expect(bonusIncome.type).toBe('Monthly'); 
      });
    
      it('should fetch a single income', async () => {
        const res = await request(app)
          .get(`/api/users/${userId}/income/${incomeId}`)
          .set('Authorization', `Bearer ${token}`);
    
        expect(res.statusCode).toBe(200);
        const income = res.body.body;
        expect(income).toHaveProperty('name', 'Updated Salary');
        expect(typeof income.amount).toBe('number');
      });
    
      it('should fetch all incomes with pagination', async () => {
        const res = await request(app)
          .get(`/api/users/${userId}/incomes?page=1&limit=10`)
          .set('Authorization', `Bearer ${token}`);
    
        expect(res.statusCode).toBe(200);
        expect(Array.isArray(res.body.body.incomes)).toBe(true);
        expect(res.body.body).toHaveProperty('total');
        expect(res.body.body).toHaveProperty('page', 1);
        expect(res.body.body).toHaveProperty('limit', 10);
      });
    
      it('should attempt to sync Plaid incomes', async () => {
        const res = await request(app)
          .post(`/api/users/${userId}/income/sync-plaid`)
          .set('Authorization', `Bearer ${token}`);
    
        expect([200, 404]).toContain(res.statusCode);
      });
    
      it('should fetch income summary grouped by month', async () => {
        const res = await request(app)
          .get(`/api/users/${userId}/income-summary?groupBy=month`)
          .set('Authorization', `Bearer ${token}`);
    
        expect(res.statusCode).toBe(200);
        expect(typeof res.body.body).toBe('object');
        expect(Object.keys(res.body.body).length).toBeGreaterThan(0);
      });
    
      it('should fetch income by category', async () => {
        const res = await request(app)
          .get(`/api/users/${userId}/income-by-category`)
          .set('Authorization', `Bearer ${token}`);
    
        expect(res.statusCode).toBe(200);
        expect(typeof res.body.body).toBe('object');
        expect(res.body.body).toHaveProperty(createdIncome.name);
      });
    
      it('should delete an income', async () => {
        const res = await request(app)
          .delete(`/api/users/${userId}/income/${incomeId}`)
          .set('Authorization', `Bearer ${token}`);
    
        expect(res.statusCode).toBe(200);
        expect(res.body.message).toMatch(/deleted successfully/i);
      });
    });