const fs = require("fs");
const path = require("path");
const { Configuration, PlaidApi, PlaidEnvironments } = require("plaid");

const PLAID_ENV_MAP = {
  'sandbox.plaid.com': PlaidEnvironments.sandbox,
  'development.plaid.com': PlaidEnvironments.development,
  'production.plaid.com': PlaidEnvironments.production
};

const ENV_PATH = path.resolve(__dirname, "../../assets/env.json");

class PlaidClient {
  static instance = null;

  static getInstance() {
    if (!this.instance) {
      this.instance = this.createClient();
    }
    return this.instance;
  }

  static createClient() {
    try {
      const envData = this.loadEnvironmentData();
      const { clientId, secretKey, envUrl } = this.extractCredentials(envData);
      const environment = this.getPlaidEnvironment(envUrl);
      
      this.logConfiguration(clientId, secretKey, envUrl);
      
      return new PlaidApi(
        new Configuration({
          basePath: environment,
          baseOptions: {
            headers: {
              "PLAID-CLIENT-ID": clientId,
              "PLAID-SECRET": secretKey,
              "Plaid-Version": "2020-09-14",
              "Content-Type": "application/json",
            },
          },
        })
      );
    } catch (error) {
      console.error("Error creating Plaid client:", error.message);
      throw error;
    }
  }
  
  static loadEnvironmentData() {
    try {
      return JSON.parse(fs.readFileSync(ENV_PATH, "utf-8"));
    } catch (error) {
      throw new Error(`Failed to load environment data: ${error.message}`);
    }
  }
  
  static extractCredentials(envData) {
    const findEnabledValue = (key) => 
      envData.values.find((item) => item.key === key && item.enabled)?.value;
    
    const clientId = findEnabledValue("client_id");
    const secretKey = findEnabledValue("secret_key");
    const envUrl = findEnabledValue("env_url");
    
    if (!clientId || !secretKey || !envUrl) {
      throw new Error("Plaid client_id, secret_key, or env_url is missing or not enabled in env.json");
    }
    
    return { clientId, secretKey, envUrl };
  }

  static getPlaidEnvironment(envUrl) {
    const environment = PLAID_ENV_MAP[envUrl];
    
    if (!environment) {
      throw new Error(`Invalid Plaid environment URL: ${envUrl}`);
    }
    
    return environment;
  }
  
  static logConfiguration(clientId, secretKey, envUrl) {
    console.log('Plaid Client Configuration:');
    console.log('Client ID:', clientId);
    console.log('Secret Key Loaded:', !!secretKey);
    console.log('Environment:', envUrl);
  }
}

module.exports = PlaidClient;