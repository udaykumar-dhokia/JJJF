import { Request, Response } from "express";
import News from "./news.model.js";

const newsController = {
  getAllNews: async (req: Request, res: Response) => {
    try {
      const news = await News.find();
      return res.status(200).json({ news });
    } catch (error) {
      return res.status(500).json({ message: "Internal server error" });
    }
  },
  createNews: async (req: Request, res: Response) => {
    const { title, content, image, authorName } = req.body;
    const userId = req.params.userId;
    if (!title || !content || !userId || !authorName) {
      return res.status(400).json({ message: "All fields are required" });
    }
    try {
      const news = await News.create({
        title,
        content,
        image,
        userId,
        authorName,
      });
      return res.status(201).json({ news });
    } catch (error) {
      return res.status(500).json({ message: "Internal server error" });
    }
  },
};

export default newsController;
