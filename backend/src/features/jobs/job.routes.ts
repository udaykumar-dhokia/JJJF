import express from "express";
import jobController from "./job.controller.js";

const router = express.Router();

router.get("/", jobController.list);
router.post("/:userId", jobController.create);
router.post("/:jobId/apply/:userId", jobController.apply);

export default router;

