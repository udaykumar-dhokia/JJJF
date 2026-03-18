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
      required: true,
    },
    firstName: {
      type: String,
      required: true,
    },
    lastName: {
      type: String,
      required: true,
    },
    mobile: {
      type: Number,
    },
    address: addressSchema,
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
  },
  { timestamps: true },
);

const User = mongoose.model("User", userSchema);
export default User;
