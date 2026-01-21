import User from "../user/user.model.js";

const businessController = {
  fetch: async (req, res) => {
    try {
      const businesses = await User.find(
        { isBusinessCompleted: true },
        {
          business: 1,
          uuid: 1,
          _id: 0,
        },
      );
      return res.status(200).json({ businesses });
    } catch (error) {
      return res.status(500).json({ message: "Internal Server Error" });
    }
  },
};

export default businessController;
