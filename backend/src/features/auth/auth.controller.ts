import User from "../user/user.model.js";

const AuthController = {
  onboard: async (req, res) => {
    const {
      mobile,
      lineOne,
      lineTwo,
      city,
      state,
      zip,
      uuid,
      birthDate,
      anniversaryDate,
      gender,
      gaon,
      district,
      currentCity,
      maritalStatus,
      jobRole,
      companyName,
    } = req.body;

    if (
      !mobile ||
      !lineOne ||
      !city ||
      !state ||
      !zip ||
      !uuid ||
      !birthDate ||
      !gender
    ) {
      return res.status(400).json({ message: "Missing required fields." });
    }

    try {
      const user = await User.findOneAndUpdate(
        { uuid },
        {
          isProfileCompleted: true,
          mobile,
          birthDate,
          anniversaryDate,
          address: {
            lineOne,
            lineTwo: lineTwo || "",
            city,
            state,
            zipCode: zip,
          },
          gender,
          gaon,
          district,
          currentCity,
          maritalStatus,
          jobRole,
          companyName,
        },
        { new: true },
      );

      if (!user) {
        return res.status(404).json({ message: "User not found." });
      }

      return res.status(200).json({
        message: "Onboarded successfully.",
        user,
      });
    } catch (error) {
      console.error("Onboarding error:", error);
      return res.status(500).json({ message: "Internal Server Error" });
    }
  },

  onboardBusiness: async (req, res) => {
    const {
      lineOne,
      lineTwo,
      city,
      state,
      zip,
      name,
      contact,
      website,
      category,
    } = req.body;

    const userId = req.params.userId;

    if (
      !lineOne ||
      !city ||
      !state ||
      !zip ||
      !userId ||
      !name ||
      !contact ||
      !category
    ) {
      return res.status(400).json({ message: "Missing required fields." });
    }

    try {
      const user = await User.findOneAndUpdate(
        { uuid: userId },
        {
          isBusinessCompleted: true,
          business: {
            name,
            contact,
            website: website || "",
            category,
            address: {
              lineOne,
              lineTwo: lineTwo || "",
              city,
              state,
              zipCode: zip,
            },
          },
        },
        { new: true },
      );

      if (!user) {
        return res.status(404).json({ message: "User not found." });
      }

      return res.status(200).json({
        message: "Business added successfully.",
        user,
      });
    } catch (error) {
      console.error("Onboarding error:", error);
      return res.status(500).json({ message: "Internal Server Error" });
    }
  },
};

export default AuthController;
