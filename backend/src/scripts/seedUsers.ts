import mongoose from "mongoose";
import User from "../features/user/user.model.js";
import connectDB from "../config/db.config.js";
import crypto from "crypto";
import { log } from "../utils/logger.js";

const firstNames = [
  "Aarav",
  "Vihaan",
  "Vivaan",
  "Ananya",
  "Diya",
  "Advik",
  "Kabir",
  "Riya",
  "Sneha",
  "Aryan",
  "Ishaan",
  "Avni",
  "Kavya",
  "Rohan",
  "Aditya",
  "Sai",
  "Prisha",
  "Arjun",
  "Zara",
  "Reyansh",
];

const lastNames = [
  "Patel",
  "Sharma",
  "Singh",
  "Kumar",
  "Gupta",
  "Desai",
  "Mehta",
  "Shah",
  "Reddy",
  "Nair",
  "Iyer",
  "Joshi",
  "Malhotra",
  "Verma",
  "Chopra",
  "Mishra",
  "Gowda",
  "Rao",
  "Bhat",
  "Saxena",
];

const cities = [
  { name: "Mumbai", state: "Maharashtra" },
  { name: "Delhi", state: "Delhi" },
  { name: "Bangalore", state: "Karnataka" },
  { name: "Hyderabad", state: "Telangana" },
  { name: "Ahmedabad", state: "Gujarat" },
  { name: "Chennai", state: "Tamil Nadu" },
  { name: "Kolkata", state: "West Bengal" },
  { name: "Pune", state: "Maharashtra" },
  { name: "Jaipur", state: "Rajasthan" },
  { name: "Surat", state: "Gujarat" },
];

const businessCategories = [
  "Retail",
  "Technology",
  "Food & Beverage",
  "Healthcare",
  "Consulting",
  "Real Estate",
  "Education",
];

const generateRandomMobile = () => {
  const start = Math.floor(Math.random() * 4) + 6;
  const rest = Math.floor(Math.random() * 1000000000)
    .toString()
    .padStart(9, "0");
  return Number(`${start}${rest}`);
};

const generateAddress = () => {
  const cityObj = cities[Math.floor(Math.random() * cities.length)];
  return {
    lineOne: `Flat No. ${Math.floor(Math.random() * 100) + 1}, Building ${
      Math.floor(Math.random() * 10) + 1
    }`,
    lineTwo: `Sector ${Math.floor(Math.random() * 20) + 1}, Main Road`,
    city: cityObj.name,
    state: cityObj.state,
    country: "India",
    zipCode: Number(
      `${Math.floor(Math.random() * 9) + 1}${Math.floor(Math.random() * 100000)
        .toString()
        .padStart(5, "0")}`
    ),
  };
};

const seedUsers = async () => {
  await connectDB();

  const users = [];
  const existingEmails = new Set();

  for (let i = 0; i < 15; i++) {
    const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
    const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
    let email = `${firstName.toLowerCase()}.${lastName.toLowerCase()}@example.com`;

    let counter = 1;
    while (existingEmails.has(email)) {
      email = `${firstName.toLowerCase()}.${lastName.toLowerCase()}${counter}@example.com`;
      counter++;
    }
    existingEmails.add(email);

    const address = generateAddress();
    const businessName = `${lastName} ${
      businessCategories[Math.floor(Math.random() * businessCategories.length)]
    }`;

    users.push({
      uuid: crypto.randomUUID(),
      email: email,
      firstName: firstName,
      lastName: lastName,
      mobile: generateRandomMobile(),
      address: address, // Added personal address
      business: {
        name: businessName,
        category:
          businessCategories[
            Math.floor(Math.random() * businessCategories.length)
          ],
        contact: generateRandomMobile(),
        website: `www.${businessName.toLowerCase().replace(/\s+/g, "")}.com`,
        address: generateAddress(), // Business address (could be different)
      },
      isProfileCompleted: true,
      isBusinessCompleted: true, // Now they have business details
    });
  }

  try {
    await User.insertMany(users);
    log(
      `Successfully added ${users.length} users with address and business details.`
    );
  } catch (error) {
    log(`Error seeding users: ${error}`);
  } finally {
    await mongoose.connection.close();
    process.exit(0);
  }
};

seedUsers();
