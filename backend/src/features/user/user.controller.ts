import User from "./user.model.js";
import cloudinary from "../../config/cloudinary.js";

const extractPublicId = (url: string) => {
  const parts = url.split("/");
  const fileWithExtension = parts[parts.length - 1];
  const publicId = fileWithExtension.split(".")[0];
  const folderPath = parts.slice(parts.indexOf("upload") + 2, parts.length - 1).join("/");
  return folderPath ? `${folderPath}/${publicId}` : publicId;
};

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
        fatherName,
        familyDetails,
        business,
        isMobileHidden,
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
            isMobileHidden,
            maritalStatus,
            jobRole,
            companyName,
            fatherName,
            familyDetails,
            ...(business && { business }),
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

  updateProfilePicture: async (req: any, res: any) => {
    const userId = req.params.userId;
    if (!userId) {
      return res.status(403).json({ message: "Unauthorized" });
    }
    if (!req.file) {
      return res.status(400).json({ message: "No image file provided" });
    }

    try {
      const user = await User.findOne({ uuid: userId });
      if (!user) {
        return res.status(404).json({ message: "No such user found" });
      }

      // Delete old profile picture if exists
      if (user.profilePicture) {
        try {
          const publicId = extractPublicId(user.profilePicture);
          await cloudinary.uploader.destroy(publicId);
        } catch (err) {
          console.error("Failed to delete old profile picture:", err);
        }
      }

      // Upload new image
      const streamUpload = (req: any) => {
        return new Promise((resolve, reject) => {
          const stream = cloudinary.uploader.upload_stream(
            { folder: "jjjf/profile_pictures" },
            (error, result) => {
              if (result) {
                resolve(result);
              } else {
                reject(error);
              }
            }
          );
          stream.write(req.file.buffer);
          stream.end();
        });
      };

      const result: any = await streamUpload(req);

      // Update user
      user.profilePicture = result.secure_url;
      await user.save();

      return res.status(200).json({ user });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: "Internal Server Error" });
    }
  },

  updateBusinessLogo: async (req: any, res: any) => {
    const userId = req.params.userId;
    if (!userId) {
      return res.status(403).json({ message: "Unauthorized" });
    }
    if (!req.file) {
      return res.status(400).json({ message: "No image file provided" });
    }

    try {
      const user = await User.findOne({ uuid: userId });
      if (!user || !user.business) {
        return res.status(404).json({ message: "No such user or business found" });
      }

      // Delete old logo if exists
      if (user.business.logo) {
        try {
          const publicId = extractPublicId(user.business.logo);
          await cloudinary.uploader.destroy(publicId);
        } catch (err) {
          console.error("Failed to delete old business logo:", err);
        }
      }

      // Upload new image
      const streamUpload = (req: any) => {
        return new Promise((resolve, reject) => {
          const stream = cloudinary.uploader.upload_stream(
            { folder: "jjjf/business_logos" },
            (error, result) => {
              if (result) {
                resolve(result);
              } else {
                reject(error);
              }
            }
          );
          stream.write(req.file.buffer);
          stream.end();
        });
      };

      const result: any = await streamUpload(req);

      // Update user
      user.business.logo = result.secure_url;
      await user.save();

      return res.status(200).json({ user });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: "Internal Server Error" });
    }
  },
};

export default UserController;
