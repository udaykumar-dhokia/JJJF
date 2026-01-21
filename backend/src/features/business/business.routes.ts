import express from "express";
import businessController from "./business.controller.js";

const router = express.Router();

router.get("/", businessController.fetch);

export default router;
