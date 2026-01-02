import { Request, Response } from "express";
import User from "../user/user.model.js";

const directoryController = {
  getUser: async (req, res) => {
    const { id } = req.params;
    try {
      const user = await User.findOne({ uuid: id });
      res.status(200).json({ user });
    } catch (error) {
      res.status(500).json({ message: "Internal Server Error.", error });
    }
  },
  getUsers: async (req: Request, res: Response) => {
    const { userId } = req.params;
    try {
      const users = await User.find(
        { uuid: { $ne: userId } },
        {
          _id: 0,
          uuid: 1,
          firstName: 1,
          lastName: 1,
          email: 1,
          mobile: 1,
          address: 1,
        }
      );
      res.status(200).json({ users });
    } catch (error) {
      res.status(500).json({ message: "Internal Server Error.", error });
    }
  },
};
export default directoryController;
