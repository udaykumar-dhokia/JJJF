import connectDB from "../config/db.config.js";
import User from "../features/user/user.model.js";
import mongoose from "mongoose";

const getRandomDate = (start: Date, end: Date) => {
  return new Date(
    start.getTime() + Math.random() * (end.getTime() - start.getTime()),
  );
};

export const backfillDates = async () => {
  await connectDB();

  try {
    const users = await User.find({});
    console.log(`Found ${users.length} users. Processing...`);

    for (const user of users) {
      const birthDate = getRandomDate(
        new Date(1970, 0, 1),
        new Date(2000, 0, 1),
      );

      // 70% chance to have an anniversary
      const hasAnniversary = Math.random() > 0.3;
      let anniversaryDate = undefined;

      if (hasAnniversary) {
        anniversaryDate = getRandomDate(new Date(2010, 0, 1), new Date());
      }

      // Check if fields are already present, if so, only update if you really want to overwrite.
      // The request says "For all the existing dummy users... fill then with random"
      // I'll assume we overwrite or fill if missing. Since they are dummy, overwriting is fine or just filling if null.
      // Let's just update.

      user.birthDate = birthDate;
      if (anniversaryDate) {
        user.anniversaryDate = anniversaryDate;
      }

      if (!user.isProfileCompleted) {
        // Maybe mark as completed if we are filling data?
        // User didn't ask for this, but if they have data they might be considered onboarded.
        // I will leave isProfileCompleted as is, only filling dates.
      }

      await user.save();
      console.log(
        `Updated user ${user.email}: DOB ${birthDate.toISOString().split("T")[0]}, Anniversary ${anniversaryDate ? anniversaryDate.toISOString().split("T")[0] : "None"}`,
      );
    }

    console.log("Backfill completed.");
  } catch (error) {
    console.error("Error backfilling users:", error);
  } finally {
    mongoose.connection.close();
    process.exit(0);
  }
};
