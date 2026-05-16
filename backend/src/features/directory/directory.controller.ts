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
          fatherName: 1,
          isMobileHidden: 1,
          profilePicture: 1,
        },
      );
      res.status(200).json({ users });
    } catch (error) {
      res.status(500).json({ message: "Internal Server Error.", error });
    }
  },
  getUpcoming: async (req: Request, res: Response) => {
    try {
      const today = new Date();
      // Reset time to start of day for accurate comparison
      today.setHours(0, 0, 0, 0);

      const thirtyDaysLater = new Date(today);
      thirtyDaysLater.setDate(today.getDate() + 30);

      const users = await User.find(
        {
          $or: [
            { birthDate: { $exists: true } },
            { anniversaryDate: { $exists: true } },
          ],
        },
        {
          firstName: 1,
          lastName: 1,
          birthDate: 1,
          anniversaryDate: 1,
          uuid: 1,
        },
      );

      const events: any[] = [];

      users.forEach((user) => {
        // Check Birthday
        if (user.birthDate) {
          const bDate = new Date(user.birthDate);
          let nextBday = new Date(
            today.getFullYear(),
            bDate.getMonth(),
            bDate.getDate(),
          );

          if (nextBday < today) {
            nextBday.setFullYear(today.getFullYear() + 1);
          }

          if (nextBday >= today && nextBday <= thirtyDaysLater) {
            events.push({
              type: "birthday",
              originalDate: user.birthDate,
              eventDate: nextBday,
              user: {
                firstName: user.firstName,
                lastName: user.lastName,
                uuid: user.uuid,
              },
            });
          }
        }

        // Check Anniversary
        if (user.anniversaryDate) {
          const aDate = new Date(user.anniversaryDate);
          let nextAnniv = new Date(
            today.getFullYear(),
            aDate.getMonth(),
            aDate.getDate(),
          );

          if (nextAnniv < today) {
            nextAnniv.setFullYear(today.getFullYear() + 1);
          }

          if (nextAnniv >= today && nextAnniv <= thirtyDaysLater) {
            events.push({
              type: "anniversary",
              originalDate: user.anniversaryDate,
              eventDate: nextAnniv,
              user: {
                firstName: user.firstName,
                lastName: user.lastName,
                uuid: user.uuid,
              },
            });
          }
        }
      });

      // Sort by eventDate
      events.sort((a, b) => a.eventDate.getTime() - b.eventDate.getTime());

      res.status(200).json({ events });
    } catch (error) {
      console.error("Error fetching upcoming events:", error);
      res.status(500).json({ message: "Internal Server Error.", error });
    }
  },
};
export default directoryController;
