import mongoose from "mongoose";
import User from "../features/user/user.model.js";
import connectDB from "../config/db.config.js";
import { log } from "../utils/logger.js";

const cleanupUsers = async () => {
  await connectDB();

  try {
    const result = await User.deleteMany({
      $or: [{ address: { $exists: false } }, { business: { $exists: false } }],
    });
    log(
      `Successfully removed ${result.deletedCount} users without address or business details.`
    );
  } catch (error) {
    log(`Error cleaning up users: ${error}`);
  } finally {
    await mongoose.connection.close();
    process.exit(0);
  }
};

cleanupUsers();
