import mongoose from "mongoose";
import { log } from "../utils/logger.js";

const connectDB = async () => {
  try {
    const url = process.env.MONGODB_URL;
    if (!url) {
      log("Missing database connection url.");
      return;
    }
    await mongoose.connect(url);
    log("Database connected successfully...");
  } catch (error) {
    log(`Error connecting with database: ${error}`);
  }
};

export default connectDB;
