import express from "express";
import userWebhookController from "./userWebhook.controller.js";

const router = express.Router();

router.post("/user", userWebhookController);

export default router;
