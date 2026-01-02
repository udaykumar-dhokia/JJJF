import express from "express";
import directoryController from "./directory.controller.js";

const router = express.Router();

router.get("/:userId", directoryController.getUsers);
router.get("/user/:id", directoryController.getUser);

export default router;
