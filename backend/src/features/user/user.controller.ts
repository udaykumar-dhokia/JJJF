import User from "./user.model.js";

const UserController = {
  fetch: async (req, res) => {
    const userId = req.params.userId;
    if (!userId) {
      return res.status(403).json({ message: "Unauthorized" });
    }
    try {
      const user = await User.findOne({ uuid: userId });
      if (!user) {
        return res.status(404).json({ message: "No such user found" });
      }
      return res.status(200).json(user);
    } catch (error) {
      return res.status(500).json({ message: "Internal Server Error" });
    }
  },
};

export default UserController;
