import mongoose from "mongoose";

const addressSchema = new mongoose.Schema(
  {
    lineOne: { type: String },
    lineTwo: { type: String },
    city: { type: String },
    state: { type: String },
    country: { type: String },
    zipCode: { type: Number },
  },
  { _id: false },
);

const userSchema = new mongoose.Schema(
  {
    uuid: {
      type: String,
      required: true,
      index: true,
      unique: true,
    },
    email: {
      type: String,
      required: true,
      index: true,
      unique: true,
    },
    gender: {
      type: String,
      enum: ["Male", "Female", "Other"],
    },
    firstName: {
      type: String,
      required: true,
    },
    lastName: {
      type: String,
      required: true,
    },
    fatherName: {
      type: String,
    },
    familyDetails: [
      {
        name: { type: String },
        relation: { type: String },
        occupation: { type: String },
      },
    ],
    mobile: {
      type: Number,
    },
    address: addressSchema,
    gaon: {
      type: String,
    },
    district: {
      type: String,
    },
    currentCity: {
      type: String,
    },
    maritalStatus: {
      type: String,
      enum: ["Single", "Married", "Widowed", "Divorced"],
    },
    jobRole: {
      type: String,
    },
    companyName: {
      type: String,
    },
    business: {
      name: {
        type: String,
      },
      category: {
        type: String,
      },
      contact: {
        type: Number,
      },
      website: {
        type: String,
      },
      address: addressSchema,
      logo: {
        type: String,
      },
    },
    isProfileCompleted: {
      type: Boolean,
      default: false,
    },
    isBusinessCompleted: {
      type: Boolean,
      default: false,
    },
    birthDate: {
      type: Date,
    },
    anniversaryDate: {
      type: Date,
    },
    profilePicture: {
      type: String,
    },
    isMobileHidden: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true },
);

const User = mongoose.model("User", userSchema);
export default User;
