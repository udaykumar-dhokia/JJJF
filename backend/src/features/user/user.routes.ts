import express from "express";
import UserController from "./user.controller.js";
import upload from "../../config/multer.js";

const router = express.Router();

router.get("/:userId", UserController.fetch);
router.put("/:userId", UserController.update);
router.put("/:userId/profile-picture", upload.single("image"), UserController.updateProfilePicture);
router.put("/:userId/business-logo", upload.single("image"), UserController.updateBusinessLogo);

export default router;
