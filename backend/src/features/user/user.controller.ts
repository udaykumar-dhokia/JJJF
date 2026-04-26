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

  update: async (req, res) => {
    const userId = req.params.userId;
    if (!userId) {
      return res.status(403).json({ message: "Unauthorized" });
    }
    try {
      const {
        mobile,
        address,
        birthDate,
        anniversaryDate,
        gaon,
        district,
        currentCity,
        maritalStatus,
        jobRole,
        companyName,
      } = req.body;
      const user = await User.findOneAndUpdate(
        { uuid: userId },
        {
          $set: {
            mobile,
            address,
            birthDate,
            anniversaryDate,
            gaon,
            district,
            currentCity,
            maritalStatus,
            jobRole,
            companyName,
          },
        },
        { new: true },
      );
      if (!user) {
        return res.status(404).json({ message: "No such user found" });
      }
      return res.status(200).json({ user });
    } catch (error) {
      return res.status(500).json({ message: "Internal Server Error" });
    }
  },
};

export default UserController;
