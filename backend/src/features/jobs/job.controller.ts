import { Request, Response } from "express";
import Job from "./job.model.js";

const jobController = {
  list: async (req: Request, res: Response) => {
    try {
      const { type } = req.query;
      const filter: Record<string, unknown> = {
        status: "approved",
      };

      if (type === "vacancy" || type === "seeker") {
        filter.type = type;
      }

      const jobs = await Job.find(filter).sort({ createdAt: -1 });
      return res.status(200).json({ jobs });
    } catch (error) {
      return res.status(500).json({ message: "Internal server error" });
    }
  },

  create: async (req: Request, res: Response) => {
    const userId = req.params.userId;
    const {
      title,
      description,
      type,
      role,
      city,
      state,
      contactName,
      contactPhone,
      contactEmail,
      link,
    } = req.body;

    if (
      !userId ||
      !title ||
      !description ||
      !type ||
      !role ||
      !city ||
      !state ||
      !contactName ||
      !contactPhone
    ) {
      return res.status(400).json({ message: "Missing required fields." });
    }

    if (type !== "vacancy" && type !== "seeker") {
      return res.status(400).json({ message: "Invalid job type." });
    }

    try {
      const job = await Job.create({
        title,
        description,
        type,
        role,
        city,
        state,
        contactName,
        contactPhone,
        contactEmail: contactEmail || "",
        link: link || "",
        createdBy: userId,
        status: "approved",
      });

      return res.status(201).json({ job });
    } catch (error) {
      return res.status(500).json({ message: "Internal server error" });
    }
  },

  apply: async (req: Request, res: Response) => {
    const { jobId, userId } = req.params;
    const { message } = req.body;

    if (!jobId || !userId) {
      return res.status(400).json({ message: "Missing required fields." });
    }

    try {
      const job = await Job.findById(jobId);
      if (!job) {
        return res.status(404).json({ message: "Job not found." });
      }

      job.applications.push({
        applicantId: userId,
        message: message || "",
      } as never);

      await job.save();

      return res.status(200).json({ job });
    } catch (error) {
      return res.status(500).json({ message: "Internal server error" });
    }
  },
};

export default jobController;
