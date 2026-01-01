import express from "express";
import UserController from "./user.controller.js";

const router = express.Router();

router.get("/:userId", UserController.fetch);

export default router;
