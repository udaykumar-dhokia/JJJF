import express from "express";
import AuthController from "./auth.controller.js";
const router = express.Router();

router.post("/onboard", AuthController.onboard);
router.post("/onboard-business/:userId", AuthController.onboardBusiness);

export default router;
