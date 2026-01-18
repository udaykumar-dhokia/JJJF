import express from "express";
import newsController from "./news.controller.js";

const router = express.Router();

router.get("/", newsController.getAllNews);
router.post("/:userId", newsController.createNews);

export default router;
